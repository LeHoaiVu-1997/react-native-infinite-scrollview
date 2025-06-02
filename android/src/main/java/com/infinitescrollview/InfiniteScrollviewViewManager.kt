package com.infinitescrollview

import android.content.Context
import android.util.Log
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.viewmanagers.InfiniteScrollviewViewManagerDelegate
import com.facebook.react.viewmanagers.InfiniteScrollviewViewManagerInterface

@ReactModule(name = InfiniteScrollviewViewManager.NAME)
class InfiniteScrollviewViewManager : SimpleViewManager<InfiniteScrollviewView>(),
  InfiniteScrollviewViewManagerInterface<InfiniteScrollviewView> {
  private val mDelegate: ViewManagerDelegate<InfiniteScrollviewView>
  private lateinit var context: Context

  init {
    mDelegate = InfiniteScrollviewViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<InfiniteScrollviewView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): InfiniteScrollviewView {
    this.context = context
    return InfiniteScrollviewView(context)
  }

  companion object {
    const val NAME = "InfiniteScrollviewView"
  }

  override fun setLockDirection(view: InfiniteScrollviewView?, value: Boolean) {
    Log.d(NAME, "setLockDirection: $value")
  }

  override fun setDisableTouch(view: InfiniteScrollviewView?, value: Boolean) {
    Log.d(NAME, "setDisableTouch: $value")
  }

  override fun setSpacingHorizontal(view: InfiniteScrollviewView?, value: Float) {
    Log.d(NAME, "setSpacingHorizontal: $value")
  }

  override fun setSpacingVertical(view: InfiniteScrollviewView?, value: Float) {
    Log.d(NAME, "setSpacingVertical: $value")
  }

  override fun scrollDistances(
    view: InfiniteScrollviewView?,
    distanceX: Float,
    distanceY: Float,
    durationMs: Int
  ) {
  }

  override fun scrollContinuously(
    view: InfiniteScrollviewView?,
    distanceX: Float,
    distanceY: Float
  ) {
  }

  override fun stopScrolling(view: InfiniteScrollviewView?, reset: Boolean) {
  }

  override fun reset(view: InfiniteScrollviewView?) {
  }
}
