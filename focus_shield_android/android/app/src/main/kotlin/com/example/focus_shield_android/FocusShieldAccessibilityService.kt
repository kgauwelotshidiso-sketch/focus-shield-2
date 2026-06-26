package com.example.focus_shield_android

import android.accessibilityservice.AccessibilityService
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.Toast

class FocusShieldAccessibilityService : AccessibilityService() {
    private val channelId = "focus_shield_blocked_site_alerts"
    private var lastDetectedDomain: String = ""
    private var lastDetectionAt: Long = 0L
    private var lastLaunchDomain: String = ""
    private var lastLaunchAt: Long = 0L
    private var lastNotificationDomain: String = ""
    private var lastNotificationAt: Long = 0L

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        createNotificationChannel()
        FocusShieldAccessibilityDetectionStore.recordAction(
            context = applicationContext,
            action = "accessibility_connected",
            message = "Focus Shield Accessibility detection is connected"
        )
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        val sourcePackage = event.packageName?.toString() ?: "unknown"
        if (sourcePackage.contains("focus_shield", ignoreCase = true)) return

        val visibleText = collectVisibleText(event)
        if (visibleText.length < 4) return

        val classification = FocusShieldAccessibilityDetectionStore.recordVisibleText(
            context = applicationContext,
            visibleText = visibleText,
            sourcePackage = sourcePackage
        ) ?: return

        val now = System.currentTimeMillis()
        val duplicateWindowMs = 2500L
        val isDuplicateDetection = classification.domain == lastDetectedDomain &&
            now - lastDetectionAt < duplicateWindowMs

        if (!isDuplicateDetection) {
            lastDetectedDomain = classification.domain
            lastDetectionAt = now
        }

        if (classification.shouldOpenApp) {
            handleBlockedDetection(classification, now)
        }
    }

    override fun onInterrupt() {
        FocusShieldAccessibilityDetectionStore.recordAction(
            context = applicationContext,
            action = "accessibility_interrupted",
            message = "Focus Shield Accessibility service was interrupted"
        )
    }

    private fun handleBlockedDetection(
        classification: FocusShieldAccessibilityDetectionStore.AccessibilityClassification,
        now: Long
    ) {
        val launchThrottleMs = 6000L
        val notificationThrottleMs = 6000L

        val duplicateLaunch = classification.domain == lastLaunchDomain &&
            now - lastLaunchAt < launchThrottleMs

        val duplicateNotification = classification.domain == lastNotificationDomain &&
            now - lastNotificationAt < notificationThrottleMs

        if (!duplicateNotification) {
            lastNotificationDomain = classification.domain
            lastNotificationAt = now
            showBlockedFeedback(classification)
        }

        if (!duplicateLaunch) {
            lastLaunchDomain = classification.domain
            lastLaunchAt = now
            openFocusShield(classification)
        }
    }

    private fun collectVisibleText(event: AccessibilityEvent): String {
        val parts = mutableListOf<String>()

        for (item in event.text) {
            val value = item?.toString()?.trim()
            if (!value.isNullOrBlank()) {
                parts.add(value)
            }
        }

        val contentDescription = event.contentDescription?.toString()?.trim()
        if (!contentDescription.isNullOrBlank()) {
            parts.add(contentDescription)
        }

        val source = event.source
        if (source != null) {
            collectNodeText(source, parts, depth = 0)
        }

        return parts
            .joinToString(" ")
            .replace(Regex("\\s+"), " ")
            .take(4000)
    }

    private fun collectNodeText(
        node: AccessibilityNodeInfo?,
        parts: MutableList<String>,
        depth: Int
    ) {
        if (node == null) return
        if (depth > 5) return
        if (parts.size > 80) return

        val text = node.text?.toString()?.trim()
        if (!text.isNullOrBlank()) {
            parts.add(text)
        }

        val description = node.contentDescription?.toString()?.trim()
        if (!description.isNullOrBlank()) {
            parts.add(description)
        }

        for (index in 0 until node.childCount) {
            collectNodeText(node.getChild(index), parts, depth + 1)
        }
    }

    private fun openFocusShield(
        classification: FocusShieldAccessibilityDetectionStore.AccessibilityClassification
    ) {
        Handler(Looper.getMainLooper()).post {
            try {
                val launchIntent = packageManager.getLaunchIntentForPackage(packageName)

                if (launchIntent != null) {
                    launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    launchIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    launchIntent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                    launchIntent.putExtra("phase6_accessibility_domain", classification.domain)
                    launchIntent.putExtra("phase6_accessibility_category", classification.category)
                    launchIntent.putExtra("phase6_accessibility_decision", classification.decision)
                    launchIntent.putExtra("phase6_accessibility_score", classification.score)
                    startActivity(launchIntent)

                    FocusShieldAccessibilityDetectionStore.recordAction(
                        context = applicationContext,
                        action = "opened_app",
                        message = "Focus Shield opened after blocked detection: ${classification.domain}"
                    )
                    return@post
                }

                val fallbackIntent = Intent(this, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                    putExtra("phase6_accessibility_domain", classification.domain)
                    putExtra("phase6_accessibility_category", classification.category)
                    putExtra("phase6_accessibility_decision", classification.decision)
                    putExtra("phase6_accessibility_score", classification.score)
                }

                startActivity(fallbackIntent)

                FocusShieldAccessibilityDetectionStore.recordAction(
                    context = applicationContext,
                    action = "opened_app_fallback",
                    message = "Focus Shield fallback launch used for: ${classification.domain}"
                )
            } catch (_: Exception) {
                FocusShieldAccessibilityDetectionStore.recordAction(
                    context = applicationContext,
                    action = "launch_blocked_by_android",
                    message = "Android blocked auto-open. Notification/toast used for: ${classification.domain}"
                )
            }
        }
    }

    private fun showBlockedFeedback(
        classification: FocusShieldAccessibilityDetectionStore.AccessibilityClassification
    ) {
        Handler(Looper.getMainLooper()).post {
            Toast.makeText(
                applicationContext,
                "Focus Shield blocked: ${classification.domain}",
                Toast.LENGTH_LONG
            ).show()
        }

        showBlockedNotification(classification)
    }

    private fun showBlockedNotification(
        classification: FocusShieldAccessibilityDetectionStore.AccessibilityClassification
    ) {
        try {
            createNotificationChannel()

            val openIntent = packageManager.getLaunchIntentForPackage(packageName)
                ?: Intent(this, MainActivity::class.java)

            openIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            openIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            openIntent.putExtra("phase6_accessibility_domain", classification.domain)
            openIntent.putExtra("phase6_accessibility_category", classification.category)
            openIntent.putExtra("phase6_accessibility_decision", classification.decision)
            openIntent.putExtra("phase6_accessibility_score", classification.score)

            val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }

            val pendingIntent = PendingIntent.getActivity(
                applicationContext,
                6001,
                openIntent,
                pendingIntentFlags
            )

            val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(applicationContext, channelId)
                    .setSmallIcon(android.R.drawable.ic_dialog_alert)
                    .setContentTitle("Focus Shield blocked a site")
                    .setContentText("${classification.domain} • ${classification.score}/100")
                    .setStyle(
                        Notification.BigTextStyle().bigText(
                            "Focus Shield blocked ${classification.domain}. Category: ${classification.category}. Score: ${classification.score}/100."
                        )
                    )
                    .setContentIntent(pendingIntent)
                    .setAutoCancel(true)
                    .build()
            } else {
                Notification.Builder(applicationContext)
                    .setSmallIcon(android.R.drawable.ic_dialog_alert)
                    .setContentTitle("Focus Shield blocked a site")
                    .setContentText("${classification.domain} • ${classification.score}/100")
                    .setStyle(
                        Notification.BigTextStyle().bigText(
                            "Focus Shield blocked ${classification.domain}. Category: ${classification.category}. Score: ${classification.score}/100."
                        )
                    )
                    .setContentIntent(pendingIntent)
                    .setAutoCancel(true)
                    .build()
            }

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.notify(6001, notification)

            FocusShieldAccessibilityDetectionStore.recordAction(
                context = applicationContext,
                action = "notification_sent",
                message = "Blocked-site notification sent for ${classification.domain}"
            )
        } catch (_: Exception) {
            FocusShieldAccessibilityDetectionStore.recordAction(
                context = applicationContext,
                action = "notification_failed",
                message = "Notification failed, toast still used for ${classification.domain}"
            )
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            channelId,
            "Focus Shield blocked site alerts",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Alerts when Focus Shield detects a blocked website through Accessibility"
        }

        manager.createNotificationChannel(channel)
    }
}
