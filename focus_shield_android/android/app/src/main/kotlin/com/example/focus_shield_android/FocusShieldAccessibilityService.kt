package com.example.focus_shield_android

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class FocusShieldAccessibilityService : AccessibilityService() {
    private var lastDetectedDomain: String = ""
    private var lastDetectionAt: Long = 0L
    private var lastLaunchDomain: String = ""
    private var lastLaunchAt: Long = 0L

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
            val launchThrottleMs = 6000L
            val isDuplicateLaunch = classification.domain == lastLaunchDomain &&
                now - lastLaunchAt < launchThrottleMs

            if (!isDuplicateLaunch) {
                lastLaunchDomain = classification.domain
                lastLaunchAt = now
                openFocusShield(classification)
            }
        }
    }

    override fun onInterrupt() {
        // Required by AccessibilityService.
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

                    Toast.makeText(
                        applicationContext,
                        "Focus Shield blocked: ${classification.domain}",
                        Toast.LENGTH_LONG
                    ).show()
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

                Toast.makeText(
                    applicationContext,
                    "Focus Shield blocked: ${classification.domain}",
                    Toast.LENGTH_LONG
                ).show()
            } catch (_: Exception) {
                Toast.makeText(
                    applicationContext,
                    "Focus Shield detected blocked site: ${classification.domain}",
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }
}
