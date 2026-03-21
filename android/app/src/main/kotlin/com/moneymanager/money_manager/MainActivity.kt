package com.moneymanager.money_manager

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.moneymanager/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPendingSms" -> {
                    val pending = SmsBroadcastReceiver.getPendingSms(this)
                    // Convert to list of maps for Flutter
                    val list = pending.map { mapOf("sender" to it["sender"], "body" to it["body"], "timestamp" to it["timestamp"]) }
                    result.success(list)
                }
                "clearPendingSms" -> {
                    SmsBroadcastReceiver.clearPendingSms(this)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
