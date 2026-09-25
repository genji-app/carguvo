package com.caxilo.engine.compositor

import android.app.Activity
import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import android.webkit.WebView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.ref.WeakReference

/**
 * Android surface compositor plugin coordinating native window surface hierarchy and focus state.
 *
 * NOTE: Compatible with all Android versions (API 21+ through Android 15+).
 * Resolves IME InputMethodManager "view is not served" rejection (especially on Android 11+
 * with strict ImeTracker validation) for embedded WebGL / Canvas games by ensuring
 * the active WebView has proper native window focus and is bound as mServedView.
 */
class CaxiloSurfaceCompositorPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    companion object {
        const val CHANNEL_NAME = "com.caxilo.engine.surface_compositor"
    }

    private var channel: MethodChannel? = null
    private var activityRef: WeakReference<Activity>? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "syncRenderSurface") {
            try {
                result.success(syncActiveSurface())
            } catch (_: Throwable) {
                result.success(false)
            }
        } else {
            result.notImplemented()
        }
    }

    /**
     * Finds the active surface [WebView] inside the native Android view hierarchy,
     * primes native view focus, and informs [InputMethodManager] to bind it as
     * the active `mServedView`.
     */
    private fun syncActiveSurface(): Boolean {
        return try {
            val activity = activityRef?.get() ?: return false
            if (activity.isFinishing || activity.isDestroyed) return false
            val root = activity.window?.decorView ?: return false
            val webView = findActiveSurfaceView(root) ?: return false

            webView.post {
                try {
                    val currentActivity = activityRef?.get()
                    if (currentActivity == null || currentActivity.isFinishing || currentActivity.isDestroyed) return@post
                    if (!webView.isAttachedToWindow) return@post

                    webView.isFocusable = true
                    webView.isFocusableInTouchMode = true
                    webView.requestFocusFromTouch()
                    webView.requestFocus()

                    val imm = currentActivity.getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
                    imm?.restartInput(webView)
                } catch (_: Throwable) {
                    // Safe guard against OEM-specific IMM / window token quirks
                }
            }
            true
        } catch (_: Throwable) {
            false
        }
    }

    private fun findActiveSurfaceView(view: View?): WebView? {
        if (view == null) return null
        if (view is WebView && view.isShown) return view
        if (view is ViewGroup) {
            for (i in 0 until view.childCount) {
                val child = view.getChildAt(i) ?: continue
                val found = findActiveSurfaceView(child)
                if (found != null) return found
            }
        }
        if (view is WebView) return view
        return null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityRef = WeakReference(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityRef = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityRef = WeakReference(binding.activity)
    }

    override fun onDetachedFromActivity() {
        activityRef = null
    }
}
