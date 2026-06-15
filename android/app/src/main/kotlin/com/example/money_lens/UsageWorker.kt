package com.example.money_lens

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.work.*
import java.util.concurrent.TimeUnit

class UsageWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        val prefs = applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val smartRemindersEnabled = prefs.getBoolean("flutter.smart_reminders_enabled", true)
        if (!smartRemindersEnabled) {
            return Result.success()
        }

        val lastTransactionTime = prefs.getLong("flutter.last_transaction_time", 0L)
        val currentTime = System.currentTimeMillis()

        // Confidence heuristic: ignore launches if a transaction was recorded in the last 10 minutes
        if (currentTime - lastTransactionTime < 10 * 60 * 1000) {
            return Result.success()
        }

        val paymentApps = mapOf(
            "com.google.android.apps.nbu.paisa.user" to "Google Pay",
            "com.phonepe.app" to "PhonePe",
            "net.one97.paytm" to "Paytm",
            "in.org.npci.upiapp" to "BHIM",
            "com.amazon.mShop.android.shopping" to "Amazon Pay"
        )

        val usm = applicationContext.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return Result.failure()

        val endTime = System.currentTimeMillis()
        // Check events in the last 15 minutes
        val startTime = endTime - 15 * 60 * 1000
        val events = usm.queryEvents(startTime, endTime)
        val event = UsageEvents.Event()

        var latestLaunchTime = 0L
        var latestLaunchPackage = ""

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                val pkg = event.packageName
                if (paymentApps.containsKey(pkg)) {
                    if (event.timeStamp > latestLaunchTime) {
                        latestLaunchTime = event.timeStamp
                        latestLaunchPackage = pkg
                    }
                }
            }
        }

        if (latestLaunchPackage.isNotEmpty() && latestLaunchTime > 0) {
            val lastNotifiedLaunchTime = prefs.getLong("flutter.last_notified_launch_time_$latestLaunchPackage", 0L)
            // Prevent duplicate notifications for the same launch
            if (latestLaunchTime > lastNotifiedLaunchTime) {
                // Save this launch time as the latest notified launch time
                prefs.edit().putLong("flutter.last_notified_launch_time_$latestLaunchPackage", latestLaunchTime).apply()

                // Save the launch event details to a list in SharedPreferences for Daily Review
                val launchesList = prefs.getString("flutter.detected_launches", "") ?: ""
                val newItem = "$latestLaunchTime:$latestLaunchPackage"
                val updatedList = if (launchesList.isEmpty()) newItem else "$launchesList,$newItem"
                prefs.edit().putString("flutter.detected_launches", updatedList).apply()

                // Confidence check: check if last transaction time was updated in the meantime
                if (latestLaunchTime - lastTransactionTime < 10 * 60 * 1000) {
                    return Result.success()
                }

                val timeSinceLaunch = currentTime - latestLaunchTime
                val delayMillis = (3 * 60 * 1000) - timeSinceLaunch
                if (delayMillis > 0) {
                    // Schedule a delayed one-time worker to trigger the notification
                    val delayRequest = OneTimeWorkRequestBuilder<DelayedNotificationWorker>()
                        .setInitialDelay(delayMillis, TimeUnit.MILLISECONDS)
                        .setInputData(workDataOf(
                            "package_name" to latestLaunchPackage,
                            "app_name" to paymentApps[latestLaunchPackage],
                            "launch_time" to latestLaunchTime
                        ))
                        .build()
                    WorkManager.getInstance(applicationContext).enqueueUniqueWork(
                        "DelayedNotification_$latestLaunchTime",
                        ExistingWorkPolicy.REPLACE,
                        delayRequest
                    )
                } else {
                    // Trigger notification immediately since 3 minutes have already passed
                    triggerNotification(applicationContext, latestLaunchPackage, paymentApps[latestLaunchPackage] ?: "Payment App", latestLaunchTime)
                }
            }
        }

        return Result.success()
    }
}

class DelayedNotificationWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        val prefs = applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val smartRemindersEnabled = prefs.getBoolean("flutter.smart_reminders_enabled", true)
        if (!smartRemindersEnabled) {
            return Result.success()
        }

        val lastTransactionTime = prefs.getLong("flutter.last_transaction_time", 0L)
        val launchTime = inputData.getLong("launch_time", 0L)

        // Confidence heuristic: check if a transaction was recorded within 10 minutes of launch
        if (lastTransactionTime > 0L && Math.abs(lastTransactionTime - launchTime) < 10 * 60 * 1000) {
            return Result.success()
        }

        val packageName = inputData.getString("package_name") ?: return Result.failure()
        val appName = inputData.getString("app_name") ?: "Payment App"

        triggerNotification(applicationContext, packageName, appName, launchTime)
        return Result.success()
    }
}

private fun triggerNotification(context: Context, packageName: String, appName: String, launchTime: Long) {
    val channelId = "payment_reminder_channel"
    val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val channel = NotificationChannel(
            channelId,
            "Smart Expense Reminders",
            NotificationManager.IMPORTANCE_DEFAULT
        ).apply {
            description = "Reminders to log transactions after using payment apps."
        }
        notificationManager.createNotificationChannel(channel)
    }

    val intent = Intent(context, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        putExtra("action", "quick_add")
        putExtra("detected_app", appName)
        putExtra("package_name", packageName)
        putExtra("launch_time", launchTime)
    }

    val pendingIntent = PendingIntent.getActivity(
        context,
        launchTime.toInt(),
        intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val builder = NotificationCompat.Builder(context, channelId)
        .setSmallIcon(android.R.drawable.ic_dialog_info)
        .setContentTitle("Possible Expense Detected")
        .setContentText("Did you just spend money via $appName? Tap to record it.")
        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
        .setContentIntent(pendingIntent)
        .setAutoCancel(true)

    notificationManager.notify(launchTime.toInt(), builder.build())
}
