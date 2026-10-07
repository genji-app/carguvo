package com.dulichpdlogistics.carguvo

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Chẩn đoán lỗi channel-error url_launcher_android khi bấm NCC sport.
        // Lọc: adb logcat -s CarguvoPlugins:I GeneratedPluginRegistrant:E
        val hasUrlLauncher = flutterEngine.plugins.has(
            io.flutter.plugins.urllauncher.UrlLauncherPlugin::class.java
        )
        Log.i("CarguvoPlugins", "UrlLauncherPlugin registered=$hasUrlLauncher")
    }
}
