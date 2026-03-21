package com.moneymanager.money_manager

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Telephony
import android.util.Log
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import org.json.JSONObject

class SmsBroadcastReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "SmsBroadcastReceiver"
        private const val PREFS_NAME = "pending_sms_prefs"
        private const val KEY_PENDING = "pending_sms"
        private const val CHANNEL_ID = "bank_sms_channel"
        private const val NOTIFICATION_ID = 9001

        private val BANK_KEYWORDS = listOf(
            "SBI", "HDFC", "ICICI", "AXIS", "KOTAK",
            "PNB", "PNBSMS", "BOB", "BOBONE", "BOBCARD",
            "CANARA", "UNION", "IDBI"
        )

        /** Read and clear pending SMS from SharedPreferences (called from Flutter). */
        fun getPendingSms(context: Context): List<Map<String, String>> {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val json = prefs.getString(KEY_PENDING, "[]") ?: "[]"
            val arr = JSONArray(json)
            val result = mutableListOf<Map<String, String>>()
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                result.add(mapOf(
                    "sender" to obj.getString("sender"),
                    "body" to obj.getString("body"),
                    "timestamp" to obj.getString("timestamp")
                ))
            }
            return result
        }

        fun clearPendingSms(context: Context) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().putString(KEY_PENDING, "[]").apply()
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isNullOrEmpty()) return

        for (sms in messages) {
            val sender = sms.displayOriginatingAddress ?: ""
            val body = sms.messageBody ?: ""
            val timestamp = sms.timestampMillis

            val senderUpper = sender.uppercase()
            val isBank = BANK_KEYWORDS.any { senderUpper.contains(it) }

            if (!isBank || body.isBlank()) continue

            Log.d(TAG, "Bank SMS from: $sender")

            // Store in SharedPreferences
            storePendingSms(context, sender, body, timestamp)

            // Show notification
            showNotification(context)
        }
    }

    private fun storePendingSms(context: Context, sender: String, body: String, timestamp: Long) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val existing = prefs.getString(KEY_PENDING, "[]") ?: "[]"
        val arr = JSONArray(existing)

        val obj = JSONObject().apply {
            put("sender", sender)
            put("body", body)
            put("timestamp", java.time.Instant.ofEpochMilli(timestamp).toString())
        }
        arr.put(obj)

        prefs.edit().putString(KEY_PENDING, arr.toString()).apply()
    }

    private fun showNotification(context: Context) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create channel for Android 8+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Bank Transactions",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications for detected bank SMS transactions"
            }
            manager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("Money Manager")
            .setContentText("New bank transaction detected. Open app to review.")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .build()

        manager.notify(NOTIFICATION_ID, notification)
    }
}
