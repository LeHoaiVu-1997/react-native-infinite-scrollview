package com.infinitescrollview

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.InfiniteScrollviewViewManagerInterface
import com.facebook.react.viewmanagers.InfiniteScrollviewViewManagerDelegate

@ReactModule(name = InfiniteScrollviewViewManager.NAME)
class InfiniteScrollviewViewManager : SimpleViewManager<InfiniteScrollviewView>(),
  InfiniteScrollviewViewManagerInterface<InfiniteScrollviewView> {
  private val mDelegate: ViewManagerDelegate<InfiniteScrollviewView>

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
    return InfiniteScrollviewView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: InfiniteScrollviewView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  companion object {
    const val NAME = "InfiniteScrollviewView"
  }
}
