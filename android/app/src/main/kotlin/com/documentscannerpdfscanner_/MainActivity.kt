package com.documentscannerpdfscanner_

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Early install in case camera init races during startup.
        CameraCrashProtector.install()
        super.onCreate(savedInstanceState)
        // Re-wrap after Flutter/Crashlytics handlers are attached.
        CameraCrashProtector.install(force = true)
    }
}
