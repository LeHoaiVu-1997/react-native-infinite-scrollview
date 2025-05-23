package com.infinitescrollview

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.widget.Toast
import com.facebook.react.bridge.ReactMethod
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

  @ReactProp(name = "color")
  override fun setColor(view: InfiniteScrollviewView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  @ReactProp(name = "test")
  override fun setTest(view: InfiniteScrollviewView?, value: Boolean) {
  }

  override fun doSomething(view: InfiniteScrollviewView) {
    Log.d(NAME, "doSomething: ")
    Toast.makeText(context, "doSomething", Toast.LENGTH_SHORT).show()
  }

  override fun setValue(view: InfiniteScrollviewView, value: String) {
    Log.d(NAME, "setValue $value")
    Toast.makeText(context, "setValue $value", Toast.LENGTH_SHORT).show()
  }

  companion object {
    const val NAME = "InfiniteScrollviewView"
  }
}
