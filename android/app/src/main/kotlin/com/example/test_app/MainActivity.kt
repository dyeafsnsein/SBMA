package com.example.test_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.core.app.NotificationManagerCompat
import android.provider.Settings

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.test_app/notification"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "areNotificationsEnabled") {
                val notificationManager = NotificationManagerCompat.from(context)
                val areEnabled = notificationManager.areNotificationsEnabled()
                result.success(areEnabled)
            } else if (call.method == "openNotificationSettings") {
                openNotificationSettings()
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
    
    private fun openNotificationSettings() {
        val intent = when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O -> {
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                }
            }
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP -> {
                Intent("android.settings.APP_NOTIFICATION_SETTINGS").apply {
                    putExtra("app_package", packageName)
                    putExtra("app_uid", applicationInfo.uid)
                }
            }
            else -> {
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    val uri = android.net.Uri.fromParts("package", packageName, null)
                    data = uri
                }
            }
        }
        startActivity(intent)
    }
}
