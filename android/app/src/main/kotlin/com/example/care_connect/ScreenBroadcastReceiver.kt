package com.example.care_connect

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.text.format.DateFormat
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.util.Date

class ScreenBroadcastReceiver : BroadcastReceiver() {
    var events: EventChannel.EventSink? = null

    override fun onReceive(context: Context?, intent: Intent?) {
        intent?.action?.let { action ->
            val timestamp = System.currentTimeMillis()
            val formattedTime = DateFormat.format("yyyy-MM-dd hh:mm:ss a", Date(timestamp)).toString()

            when (action) {
                Intent.ACTION_SCREEN_OFF -> {
                    Log.d(TAG, "SCREEN_OFF at: $formattedTime")
                    events?.success("SCREEN_OFF at: $formattedTime")
                }
                Intent.ACTION_SCREEN_ON -> {
                    Log.d(TAG, "SCREEN_ON at: $formattedTime")
                    events?.success("SCREEN_ON at: $formattedTime")
                }
                Intent.ACTION_USER_PRESENT->{
                    Log.d(TAG, "SCREEN_UNLOCKED at: $formattedTime")
                    events?.success("SCREEN_UNLOCKED at: $formattedTime")
                }

                else -> {}
            }
        }
    }

    companion object {
        const val TAG = "ScreenBroadcastReceiver"
    }
}
