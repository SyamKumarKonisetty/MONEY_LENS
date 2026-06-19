package com.syamkumar.moneylens

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.moneylens/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSmsMessages" -> {
                        val limit = call.argument<Int>("limit") ?: 500
                        val messages = readSmsInbox(limit)
                        result.success(messages)
                    }
                    "checkSmsPermission" -> {
                        val hasPermission = ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.READ_SMS
                        ) == PackageManager.PERMISSION_GRANTED
                        result.success(hasPermission)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun readSmsInbox(limit: Int): List<Map<String, Any>> {
        val smsList = mutableListOf<Map<String, Any>>()

        val hasPermission = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_SMS
        ) == PackageManager.PERMISSION_GRANTED

        if (!hasPermission) {
            return smsList
        }

        var cursor: Cursor? = null
        try {
            cursor = contentResolver.query(
                Uri.parse("content://sms/inbox"),
                arrayOf("_id", "address", "body", "date"),
                null,
                null,
                "date DESC LIMIT $limit"
            )

            cursor?.let {
                val idIndex = it.getColumnIndex("_id")
                val bodyIndex = it.getColumnIndex("body")
                val addressIndex = it.getColumnIndex("address")
                val dateIndex = it.getColumnIndex("date")

                while (it.moveToNext()) {
                    val id = if (idIndex >= 0) it.getString(idIndex) ?: "" else ""
                    val body = if (bodyIndex >= 0) it.getString(bodyIndex) ?: "" else ""
                    val address = if (addressIndex >= 0) it.getString(addressIndex) ?: "" else ""
                    val date = if (dateIndex >= 0) it.getLong(dateIndex) else 0L

                    if (body.isNotEmpty()) {
                        smsList.add(
                            mapOf(
                                "id" to id,
                                "address" to address,
                                "body" to body,
                                "date" to date
                            )
                        )
                    }
                }
            }
        } catch (e: Exception) {
            // Return empty list on error
        } finally {
            cursor?.close()
        }

        return smsList
    }
}
