package com.infinitescrollview

import android.animation.TypeEvaluator
import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.view.ViewTreeObserver
import android.view.animation.LinearInterpolator
import android.widget.Scroller
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.views.view.ReactViewGroup
import androidx.core.animation.addListener
import androidx.core.view.children
import kotlin.math.abs
import kotlin.math.max

class InfiniteScrollviewView(context: Context?) : ReactViewGroup(context) {
  companion object {
    private const val TAG = "InfiniteScrollviewView"
    private const val DURATION_DEFAULT = 1000
  }

  private val scroller: Scroller = Scroller(context)
  private var lastX: Float = 0.0f
  private var lastY: Float = 0.0f

  private var scrollAnimator: ValueAnimator? = null
  private var isMethodScrolling = false // Scrolling by react native ref methods

  // Duration of animation, 1000 ms as default when continuously scrolling
  private var duration = DURATION_DEFAULT
  private var distanceScrollContinuously = Pair(0f, 0f) // Percentage of width each second

  // Continuously scrolling ignores these below values
  private var remainingDistance = Pair(0f, 0f)
  private var totalDistance = Pair(0f, 0f)

  var lockDirection: String? = null

  var disableTouch = false
    set(value) {
      if (field != value) {
        field = value
      }
    }

  private var spacingHorizontal = 0
  private var spacingVertical = 0

  private var spacing: ReadableMap? = null

  init {
    // Add a global layout listener to capture width and height after layout
    viewTreeObserver.addOnGlobalLayoutListener(object : ViewTreeObserver.OnGlobalLayoutListener {
      override fun onGlobalLayout() {
        viewTreeObserver.removeOnGlobalLayoutListener(this)
        if (spacing != null) {
          updateSpacing(spacing)
        }
      }
    })
  }

  private fun startScrollingContinuously() {
    isMethodScrolling = true

    // Reset important vars
    remainingDistance = Pair(0f, 0f)
    totalDistance = Pair(0f, 0f)
    duration = DURATION_DEFAULT

    // Stop or do nothing when distances is 0
    if (distanceScrollContinuously.first == 0.0f && distanceScrollContinuously.second == 0.0f) {
      stopScrollingAnimation()
      return
    }

    startScrollingAnimation(distanceScrollContinuously, true)
  }

  fun updateSpacing(spacingMap: ReadableMap?) {
    spacing = spacingMap
    if (spacingMap == null) {
      spacingHorizontal = 0
      spacingVertical = 0
    } else {
      val rnWidth = spacingMap.getDouble("rnWidth")
      val rnHeight = spacingMap.getDouble("rnHeight")
      val spacingHor = spacingMap.getInt("spacingHor")
      val spacingVer = spacingMap.getInt("spacingVer")
      spacingHorizontal = if (rnWidth <= 0 || spacingHor <= 0) 0 else (spacingHor * width / rnWidth).toInt()
      spacingVertical = if (rnHeight <= 0 || spacingVer <= 0) 0 else (spacingVer * height / rnHeight).toInt()
    }
    postInvalidate()
  }

  fun resetScroll() {
    scrollX = 0
    scrollY = 0
  }

  fun startScrollingContinuously(distanceX: Float, distanceY: Float) {
    if (distanceX == 0f && distanceY == 0f) {
      return
    }
    distanceScrollContinuously = Pair(distanceX, distanceY)
    startScrollingContinuously()
  }

  // Start scrolling a distance
  private fun startScrollingDistance(distances: Pair<Float, Float>) {
    isMethodScrolling = true
    remainingDistance = distances
    // Calculating duration
    val durationFir = if (totalDistance.first == 0.0f) 0 else (remainingDistance.first * duration / totalDistance.first).toInt()
    val durationSec = if (totalDistance.second == 0.0f) 0 else (remainingDistance.second * duration / totalDistance.second).toInt()
    duration = max(durationFir, durationSec)

    if (remainingDistance.first == 0f && remainingDistance.second == 0f) {
      totalDistance = Pair(0f, 0f)
      remainingDistance = Pair(0f, 0f)
      duration = DURATION_DEFAULT
      stopScrollingAnimation()
      return
    }

    startScrollingAnimation(remainingDistance, false)
  }

  fun startScrollingDistance(distanceX: Float, distanceY: Float, durationMs: Int) {
    if (distanceX == 0f && distanceY == 0f) {
      return
    }
    totalDistance = Pair(distanceX, distanceY)
    duration = durationMs

    startScrollingDistance(totalDistance)
  }

  private fun removeAnimation() {
    scrollAnimator?.removeAllUpdateListeners()
    scrollAnimator?.removeAllListeners()
    scrollAnimator?.cancel()
    scrollAnimator=null
  }

  // Stop automatic scrolling
  fun stopScrollingAnimation() {
    isMethodScrolling = false
    removeAnimation()
  }

  fun stopScrollingAnimation(reset: Boolean) {
    isMethodScrolling = false
    removeAnimation()
    if (reset) {
      resetScroll()
    }
  }

  private fun startScrollingAnimation(distances: Pair<Float, Float>, loop: Boolean) {
    // Cancel any existing animation
    removeAnimation()

    // Calculate target scroll position
    val startScrollX = scrollX
    val scrollDistanceX = (width * distances.first).toInt()
    val endScrollX = startScrollX + scrollDistanceX

    val startScrollY = scrollY
    val scrollDistanceY = (height * distances.second).toInt()
    val endScrollY = startScrollY + scrollDistanceY

    val durationMs = duration.toLong()
    val pairEvaluator = TypeEvaluator<Pair<Float, Float>> { fraction, startValue, endValue ->
      val first = startValue.first + (endValue.first - startValue.first) * fraction
      val second = startValue.second + (endValue.second - startValue.second) * fraction
      Pair(first, second)
    }

    // Set up the animator
    scrollAnimator = ValueAnimator.ofObject(pairEvaluator, Pair(startScrollX, startScrollY), Pair(endScrollX, endScrollY)).apply {
      duration = durationMs
      interpolator = LinearInterpolator()
      addUpdateListener { animator ->
        val currentScroll = animator.animatedValue as Pair<Float, Float>
        if (!loop) {
          remainingDistance = Pair(
            distances.first - (currentScroll.first - startScrollX) / width,
            distances.second - (currentScroll.second - startScrollY) / height
          )
        }
        scrollTo(currentScroll.first.toInt(), currentScroll.second.toInt()) // Update scroll position
      }
      addListener(onEnd = {
        if (loop) {
          startScrollingAnimation(distances, loop) // Continue scrolling
        }
      })
      start()
    }
  }

  private fun handleTouchEvent(event: MotionEvent): Boolean {
    when (event.action) {
      MotionEvent.ACTION_DOWN -> {
        lastX = event.x
        lastY = event.y
        return true
      }
      MotionEvent.ACTION_UP -> {
        if (!scroller.isFinished) {
          scroller.abortAnimation()
        }
        return true
      }
      MotionEvent.ACTION_MOVE -> {
        val dx = if (lockDirection != "ver") lastX - event.x else 0 // Not horizontal locked
        val dy = if (lockDirection != "hor") lastY - event.y else 0 // Not vertical locked
        lastX = event.x
        lastY = event.y
        scrollBy(dx.toInt(), dy.toInt())
        postInvalidate()
        return true
      }
    }

    return false
  }

  @SuppressLint("ClickableViewAccessibility")
  override fun onTouchEvent(ev: MotionEvent): Boolean {
    if (disableTouch) {
      return true
    } else {
      if (isMethodScrolling) {
        stopScrollingAnimation()
      }
    }
    return handleTouchEvent(ev)
  }

  override fun computeScroll() {
    if (scroller.computeScrollOffset()) {
      scrollTo(scroller.currX, scroller.currY)
      postInvalidate()
    }
  }

  override fun dispatchDraw(canvas: Canvas) {
    drawChildren(canvas)
  }

  private fun drawChildren(canvas: Canvas) {
    for (child in children) {
      drawAndClipOriginalChild(canvas, child)
      drawMirroredChildren(canvas, child)
      rePositioning(child)
    }
  }

  private fun drawClipCanvas(canvas: Canvas, view: View,
                             clipLeft: Int, clipTop: Int,
                             clipRight: Int, clipBottom: Int) {
    canvas.save()
    canvas.clipRect(clipLeft, clipTop, clipRight, clipBottom)
    drawChild(canvas, view, drawingTime)
    canvas.restore()
  }

  private fun drawClipCanvas(canvas: Canvas, view: View,
                             clipLeft: Int, clipTop: Int,
                             clipRight: Int, clipBottom: Int,
                             translateX: Float, translateY: Float) {
    canvas.save()
    canvas.translate(translateX, translateY)
    canvas.clipRect(clipLeft, clipTop, clipRight, clipBottom)
    drawChild(canvas, view, drawingTime)
    canvas.restore()
  }

  private fun rePositioning(childView: View) {
    val childLeft = childView.left - scrollX
    val childRight = childView.right - scrollX
    val childTop = childView.top - scrollY
    val childBottom = childView.bottom - scrollY

    var isReset = false
    var _scrollX = scrollX
    var _scrollY = scrollY
    if (childRight < 0) {
      _scrollX = -spacingHorizontal + if (width < childView.width) childView.left else childView.right - width
      isReset = true
    } else if (childLeft > width) {
      isReset = true
      _scrollX = spacingHorizontal + if (width < childView.width) childView.width - width + childView.left else childView.left
    }
    if (childBottom < 0) {
      _scrollY = -spacingVertical + if (height < childView.height) childView.top else childView.bottom - height
      isReset = true
    } else if (childTop > height) {
      _scrollY = spacingVertical + if (height < childView.height) childView.height - height + childView.top else childView.top
      isReset = true
    }
    if (isReset) {
      scrollX = _scrollX
      scrollY = _scrollY
      if (isMethodScrolling) {
        removeAnimation()
        if (remainingDistance.first != 0.0f || remainingDistance.second != 0.0f) {
          startScrollingDistance(remainingDistance)
        } else {
          startScrollingContinuously()
        }
        postInvalidate()
      }
    }
  }

  private fun drawAndClipOriginalChild(canvas: Canvas, child: View) {
    val childLeft = child.left - scrollX
    val childRight = child.right - scrollX
    val childTop = child.top - scrollY
    val childBottom = child.bottom - scrollY

    var clipLeft = 0.coerceAtMost(child.left)
    var clipRight = width.coerceAtLeast(child.right)
    var clipTop = 0.coerceAtMost(child.top)
    var clipBottom = height.coerceAtLeast(child.bottom)

    if (childLeft < 0) {
      clipLeft = abs(childLeft) + child.left
    }
    if (childRight > width) {
      clipRight = child.right - (childRight - width)
    }
    if (childTop < 0) {
      clipTop = abs(childTop) + child.top
    }
    if (childBottom > height) {
      clipBottom = child.bottom - (childBottom - height)
    }

    drawClipCanvas(canvas, child, clipLeft, clipTop, clipRight, clipBottom)
  }

  private fun drawMirroredChildren(canvas: Canvas, child: View) {
    var hasMirrorHorizontal = 0
    var hasMirrorVertical = 0

    val mirrorChildren = ArrayList<Float>() // Store mirror views. Every 6 elements is a view
    val childLeft = child.left - scrollX
    val childRight = child.right - scrollX
    val childTop = child.top - scrollY
    val childBottom = child.bottom - scrollY

    if (childLeft < -spacingHorizontal && childRight < width - spacingHorizontal) {
      hasMirrorHorizontal = 2 // At right side
    } else if (childRight > width + spacingHorizontal && childLeft > spacingHorizontal) {
      hasMirrorHorizontal = 1 // At left side
    }
    if (childTop < -spacingVertical && childBottom < height - spacingHorizontal) {
      hasMirrorVertical = 2 // At bottom
    } else if (childBottom > height + spacingVertical && childTop > spacingVertical) {
      hasMirrorVertical = 1 // At top
    }

    val case = hasMirrorHorizontal * 10 + hasMirrorVertical
    when (case) {
      0 -> { // 00
        return
      }
      1 -> { // 01: Only one mirror at top
        val partOutOfBounds = -spacingVertical + if (child.height > height) childTop else childBottom - height
        mirrorChildren.add(scrollX.toFloat())
        mirrorChildren.add((child.height - partOutOfBounds + child.top).toFloat())
        mirrorChildren.add((width + scrollX).toFloat())
        mirrorChildren.add((child.height + child.top).toFloat())
        mirrorChildren.add(0.0f)
        mirrorChildren.add(-(height.coerceAtLeast(child.height) + spacingVertical).toFloat())
      }
      2 -> { // 02: Only one mirror at bottom
        val partOutOfBounds = if (child.height > height) height - childBottom - spacingVertical else abs(childTop + spacingVertical)
        mirrorChildren.add(scrollX.toFloat())
        mirrorChildren.add(child.top.toFloat())
        mirrorChildren.add((width + scrollX.toFloat()).toFloat())
        mirrorChildren.add((partOutOfBounds + child.top).toFloat())
        mirrorChildren.add(0.0f)
        mirrorChildren.add(spacingVertical + height.coerceAtLeast(child.height).toFloat())
      }
      10 -> { // Only one mirror at left
        val partOutOfBounds = -spacingHorizontal + if (child.width > width) childLeft else childRight - width
        mirrorChildren.add((child.width - partOutOfBounds + child.left).toFloat())
        mirrorChildren.add(scrollY.toFloat())
        mirrorChildren.add((child.width + child.left).toFloat())
        mirrorChildren.add((height + scrollY).toFloat())
        mirrorChildren.add(-(width.coerceAtLeast(child.width) + spacingHorizontal).toFloat())
        mirrorChildren.add(0.0f)
      }
      11 -> { // Three mirrors at top-left, bottom-left, top-right or origin at bottom-right
        val partOutOfBoundsHor = -spacingHorizontal + if (child.width > width) childLeft else childRight - width
        val partOutOfBoundsVer = -spacingVertical + if (child.height > height) childTop else childBottom - height
        // Mirror at top-right
        mirrorChildren.add((if (width < child.width) child.left else 0).toFloat())
        mirrorChildren.add((child.height - partOutOfBoundsVer + child.top).toFloat())
        mirrorChildren.add(child.left - partOutOfBoundsHor - spacingHorizontal + (if (width < child.width) width else child.width).toFloat())
        mirrorChildren.add((child.height + child.top).toFloat())
        mirrorChildren.add(0.0f)
        mirrorChildren.add(-(height.coerceAtLeast(child.height) + spacingVertical).toFloat())
        // Mirror at top-left
        mirrorChildren.add((child.width - partOutOfBoundsHor + child.left).toFloat())
        mirrorChildren.add((child.height - partOutOfBoundsVer + child.top).toFloat())
        mirrorChildren.add((child.width + child.left).toFloat())
        mirrorChildren.add((child.height + child.top).toFloat())
        mirrorChildren.add(-(width.coerceAtLeast(child.width) + spacingHorizontal).toFloat())
        mirrorChildren.add(-(height.coerceAtLeast(child.height) + spacingVertical).toFloat())
        // Mirror at bottom-left
        mirrorChildren.add((child.width - partOutOfBoundsHor + child.left).toFloat())
        mirrorChildren.add(child.top.toFloat())
        mirrorChildren.add((child.width + child.left).toFloat())
        mirrorChildren.add(child.top - partOutOfBoundsVer - spacingVertical + (if (height < child.height) height else child.height).toFloat())
        mirrorChildren.add(-(width.coerceAtLeast(child.width) + spacingHorizontal).toFloat())
        mirrorChildren.add(0.0f)
      }
      12 -> { // Three mirrors at top-left, bottom-left, bottom-right or origin at top-right
        val partOutOfBoundsHor = -spacingHorizontal + if (child.width > width) childLeft else childRight - width
        val partOutOfBoundsVer = if (child.height > height) height - childBottom - spacingVertical else abs(childTop + spacingVertical)
        // Mirror at top-left
        mirrorChildren.add((child.width - partOutOfBoundsHor + child.left).toFloat())
        mirrorChildren.add((partOutOfBoundsVer + spacingVertical + (if (height < child.height) child.bottom - height else child.top).toFloat()))
        mirrorChildren.add((child.width + child.left).toFloat())
        mirrorChildren.add(child.bottom.toFloat())
        mirrorChildren.add(-(width.coerceAtLeast(child.width) + spacingHorizontal).toFloat())
        mirrorChildren.add(0.0f)
        // Mirror at bottom-left
        mirrorChildren.add((child.width - partOutOfBoundsHor + child.left).toFloat())
        mirrorChildren.add(child.top.toFloat())
        mirrorChildren.add((child.width + child.left).toFloat())
        mirrorChildren.add(partOutOfBoundsVer + child.top.toFloat())
        mirrorChildren.add(-(width.coerceAtLeast(child.width) + spacingHorizontal).toFloat())
        mirrorChildren.add(spacingVertical + height.coerceAtLeast(child.height).toFloat())
        // Mirror at bottom-right
        mirrorChildren.add(child.left.toFloat())
        mirrorChildren.add(child.top.toFloat())
        // Line below, lack 1 pixel in width. Don't know why yet
        mirrorChildren.add((-partOutOfBoundsHor - spacingHorizontal + if (width < child.width) 2*width - child.right + 1 else child.left + child.width).toFloat())
        mirrorChildren.add(partOutOfBoundsVer + child.top.toFloat())
        mirrorChildren.add(0.0f)
        mirrorChildren.add(spacingVertical + height.coerceAtLeast(child.height).toFloat())
      }
      20 -> { // Only one mirror at right
        val partOutOfBounds = if (child.width > width) width - childRight - spacingHorizontal else abs(childLeft + spacingHorizontal)
        mirrorChildren.add(child.left.toFloat())
        mirrorChildren.add(scrollY.toFloat())
        mirrorChildren.add((partOutOfBounds + child.left).toFloat())
        mirrorChildren.add((height + scrollY).toFloat())
        mirrorChildren.add(spacingHorizontal + width.coerceAtLeast(child.width).toFloat())
        mirrorChildren.add(0.0f)
      }
      21 -> { // Three mirrors at top-right, bottom-right, top-left or origin at bottom-left
        val partOutOfBoundsHor = if (child.width > width) width - childRight - spacingHorizontal else abs(childLeft + spacingHorizontal)
        val partOutOfBoundsVer = -spacingVertical + if (child.height > height) childTop else childBottom - height
        // Mirror at top-left
        mirrorChildren.add(((partOutOfBoundsHor + spacingHorizontal + if (child.width > width) -child.left else child.left).toFloat()))
        mirrorChildren.add((child.bottom-partOutOfBoundsVer).toFloat())
        mirrorChildren.add(child.right.toFloat())
        mirrorChildren.add(child.bottom.toFloat())
        mirrorChildren.add(0.0f)
        mirrorChildren.add(-(height.coerceAtLeast(child.height) + spacingVertical).toFloat())
        // Mirror at top-right
        mirrorChildren.add(child.left.toFloat())
        mirrorChildren.add((child.bottom-partOutOfBoundsVer).toFloat())
        mirrorChildren.add((partOutOfBoundsHor + child.left).toFloat())
        mirrorChildren.add(child.bottom.toFloat())
        mirrorChildren.add(spacingHorizontal + width.coerceAtLeast(child.width).toFloat())
        mirrorChildren.add(-(height.coerceAtLeast(child.height) + spacingVertical).toFloat())
        // Mirror at bottom-right
        mirrorChildren.add(child.left.toFloat())
        mirrorChildren.add(child.top.toFloat())
        mirrorChildren.add((partOutOfBoundsHor + child.left).toFloat())
        mirrorChildren.add((-partOutOfBoundsVer - spacingVertical + if (child.height < height) child.bottom else height + child.top).toFloat())
        mirrorChildren.add(spacingHorizontal + width.coerceAtLeast(child.width).toFloat())
        mirrorChildren.add(0.0f)
      }
      22 -> { // Three mirrors at top-right, bottom-right, bottom-left or origin at top-left
        val partOutOfBoundsHor = if (child.width > width) width - childRight - spacingHorizontal else abs(childLeft + spacingHorizontal)
        val partOutOfBoundsVer = if (child.height > height) height - childBottom - spacingVertical else abs(childTop + spacingVertical)
        // Mirror at bottom-right
        mirrorChildren.add(child.left.toFloat())
        mirrorChildren.add(child.top.toFloat())
        mirrorChildren.add((partOutOfBoundsHor + child.left).toFloat())
        mirrorChildren.add((partOutOfBoundsVer + child.top).toFloat())
        mirrorChildren.add(spacingHorizontal + width.coerceAtLeast(child.width).toFloat())
        mirrorChildren.add(spacingVertical + height.coerceAtLeast(child.height).toFloat())
        // Mirror at bottom-left
        mirrorChildren.add(((partOutOfBoundsHor + spacingHorizontal + if (child.width > width) -child.left else child.left).toFloat()))
        mirrorChildren.add(child.top.toFloat())
        mirrorChildren.add(child.right.toFloat())
        mirrorChildren.add((partOutOfBoundsVer + child.top).toFloat())
        mirrorChildren.add(0.0f)
        mirrorChildren.add(spacingVertical + height.coerceAtLeast(child.height).toFloat())
        // Mirror at top-right
        mirrorChildren.add(child.left.toFloat())
        mirrorChildren.add((partOutOfBoundsVer + spacingVertical + if (child.height > height) -child.top else child.top).toFloat())
        mirrorChildren.add((partOutOfBoundsHor + child.left).toFloat())
        mirrorChildren.add(child.bottom.toFloat())
        mirrorChildren.add(spacingHorizontal + width.coerceAtLeast(child.width).toFloat())
        mirrorChildren.add(0.0f)
      }
    }

    var i = 0
    while (i < mirrorChildren.size) {
      drawClipCanvas(canvas, child,
        mirrorChildren[i].toInt(), mirrorChildren[i+1].toInt(),
        mirrorChildren[i+2].toInt(), mirrorChildren[i+3].toInt(),
        mirrorChildren[i+4], mirrorChildren[i+5])

      i+=6
    }
  }
}
