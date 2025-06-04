package com.infinitescrollview

import android.content.Context
import android.util.Log
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.InfiniteScrollviewViewManagerDelegate
import com.facebook.react.viewmanagers.InfiniteScrollviewViewManagerInterface

@ReactModule(name = InfiniteScrollviewViewManager.NAME)
class InfiniteScrollviewViewManager : ViewGroupManager<InfiniteScrollviewView>(),
  InfiniteScrollviewViewManagerInterface<InfiniteScrollviewView> {

  companion object {
    const val NAME = "InfiniteScrollviewView"
  }

  private val mDelegate: ViewManagerDelegate<InfiniteScrollviewView> =
    InfiniteScrollviewViewManagerDelegate(this)
  private lateinit var context: Context

  override fun getDelegate(): ViewManagerDelegate<InfiniteScrollviewView> {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): InfiniteScrollviewView {
    this.context = context
    return InfiniteScrollviewView(context)
  }

  @ReactProp(name = "lockDirection")
  override fun setLockDirection(view: InfiniteScrollviewView?, value: String?) {
    if (view != null) {
      view.lockDirection = value
    }
  }

  @ReactProp(name = "disableTouch")
  override fun setDisableTouch(view: InfiniteScrollviewView?, value: Boolean) {
    if (view != null) {
      view.disableTouch = value
    }
  }

  @ReactProp(name = "spacing")
  override fun setSpacing(view: InfiniteScrollviewView?, value: ReadableMap?) {
    view?.updateSpacing(value)
  }

  override fun setSpacingHorizontal(view: InfiniteScrollviewView?, value: Float) {
  }

  override fun setSpacingVertical(view: InfiniteScrollviewView?, value: Float) {
  }

  override fun scrollDistances(
    view: InfiniteScrollviewView?,
    distanceX: Float,
    distanceY: Float,
    durationMs: Int
  ) {
    view?.startScrollingDistance(-distanceX, -distanceY, durationMs)
  }

  override fun scrollContinuously(
    view: InfiniteScrollviewView?,
    distanceX: Float,
    distanceY: Float
  ) {
    view?.startScrollingContinuously(-distanceX, -distanceY)
  }

  override fun stopScrolling(view: InfiniteScrollviewView?, reset: Boolean) {
    view?.stopScrollingAnimation(reset)
  }

  override fun reset(view: InfiniteScrollviewView?) {
    view?.resetScroll()
  }

}
