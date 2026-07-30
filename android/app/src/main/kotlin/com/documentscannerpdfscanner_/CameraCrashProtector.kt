package com.documentscannerpdfscanner_

import android.util.Log

/**
 * Swallows a known Android 8.1 / legacy Camera2 HAL race that crashes the
 * process from a framework callback thread (CaptureCallbackHolder NPE).
 * App Dart code cannot catch this; preventing process death is the mitigation.
 */
object CameraCrashProtector {
    private const val TAG = "CameraCrashProtector"

    @Volatile
    private var installed = false

    fun install(force: Boolean = false) {
        if (installed && !force) return
        installed = true

        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            if (isLegacyCameraCallbackCrash(throwable)) {
                Log.w(
                    TAG,
                    "Ignored known Camera2 legacy HAL NPE on ${thread.name}",
                    throwable,
                )
                return@setDefaultUncaughtExceptionHandler
            }
            previous?.uncaughtException(thread, throwable)
        }
    }

    private fun isLegacyCameraCallbackCrash(throwable: Throwable?): Boolean {
        var current = throwable
        while (current != null) {
            if (current is NullPointerException) {
                val message = current.message.orEmpty()
                if (message.contains("CaptureCallbackHolder.getRequest") ||
                    message.contains("CaptureCallbackHolder")
                ) {
                    return true
                }
                val stack = current.stackTraceToString()
                if (stack.contains("CameraDeviceImpl\$CameraDeviceCallbacks") &&
                    stack.contains("onResultReceived")
                ) {
                    return true
                }
            }
            current = current.cause
        }
        return false
    }
}
