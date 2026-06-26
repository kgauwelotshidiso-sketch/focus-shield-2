from pathlib import Path

ROOT = Path("focus_shield_android")


def write(path: str, text: str) -> None:
    full_path = ROOT / path
    full_path.parent.mkdir(parents=True, exist_ok=True)
    full_path.write_text(text.strip() + "\n", encoding="utf-8")
    print(f"wrote {full_path}")


def patch_file(path: str, transform) -> None:
    full_path = ROOT / path
    text = full_path.read_text(encoding="utf-8")
    new_text = transform(text)
    if new_text == text:
        print(f"no change needed for {full_path}")
    else:
        full_path.write_text(new_text, encoding="utf-8")
        print(f"patched {full_path}")


write("android/app/src/main/kotlin/com/example/focus_shield_android/FocusShieldAccessibilityDetectionStore.kt", r'''
package com.example.focus_shield_android

import android.content.Context
import org.json.JSONArray
import java.util.Locale
import java.util.regex.Pattern

object FocusShieldAccessibilityDetectionStore {
    private const val PREFS = "focus_shield_accessibility_detection"

    private const val KEY_EVENTS = "events"
    private const val KEY_WEBSITES_SCANNED = "websites_scanned"
    private const val KEY_NEW_WEBSITES_SCANNED = "new_websites_scanned"
    private const val KEY_BLOCKED_DETECTIONS = "blocked_detections"
    private const val KEY_UNKNOWN_DETECTIONS = "unknown_detections"
    private const val KEY_SEEN_DOMAINS = "seen_domains"
    private const val KEY_CUSTOM_BLOCKLIST = "custom_blocklist"

    private const val KEY_LAST_DOMAIN = "last_domain"
    private const val KEY_LAST_CATEGORY = "last_category"
    private const val KEY_LAST_DECISION = "last_decision"
    private const val KEY_LAST_SCORE = "last_score"
    private const val KEY_LAST_CONFIDENCE = "last_confidence"
    private const val KEY_LAST_SIGNALS = "last_signals"
    private const val KEY_LAST_DETECTED_AT = "last_detected_at"
    private const val KEY_LAST_PACKAGE = "last_package"
    private const val KEY_LAST_ACTION = "last_action"
    private const val KEY_LAST_MESSAGE = "last_message"

    private val domainPattern: Pattern = Pattern.compile(
        "\\b((?:https?://)?(?:www\\.)?[a-zA-Z0-9][a-zA-Z0-9-]{1,63}(?:\\.[a-zA-Z]{2,})+(?:/[^\\s]*)?)\\b"
    )

    data class AccessibilityClassification(
        val domain: String,
        val category: String,
        val decision: String,
        val score: Int,
        val confidence: Int,
        val signals: List<String>,
        val shouldOpenApp: Boolean
    )

    fun updateCustomBlocklist(context: Context, domains: List<String>) {
        val cleanedDomains = domains
            .map { normalizeDomain(it) }
            .filter { it.isNotBlank() && it.contains(".") }
            .toSet()

        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putStringSet(KEY_CUSTOM_BLOCKLIST, cleanedDomains)
            .putString(
                KEY_LAST_MESSAGE,
                "Native Accessibility blocklist synced: ${cleanedDomains.size} domain(s)"
            )
            .putString(KEY_LAST_ACTION, "blocklist_synced")
            .apply()
    }

    fun recordVisibleText(
        context: Context,
        visibleText: String,
        sourcePackage: String
    ): AccessibilityClassification? {
        if (isIgnoredPackage(sourcePackage)) return null

        val domain = extractDomain(visibleText) ?: return null
        val classification = classify(context, domain)

        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val seen = prefs.getStringSet(KEY_SEEN_DOMAINS, emptySet())?.toMutableSet() ?: mutableSetOf()
        val isNew = !seen.contains(domain)

        if (isNew) {
            seen.add(domain)
        }

        val events = prefs.getInt(KEY_EVENTS, 0) + 1
        val scanned = prefs.getInt(KEY_WEBSITES_SCANNED, 0) + 1
        val newScanned = prefs.getInt(KEY_NEW_WEBSITES_SCANNED, 0) + if (isNew) 1 else 0
        val blocked = prefs.getInt(KEY_BLOCKED_DETECTIONS, 0) +
            if (classification.decision == "blocked") 1 else 0
        val unknown = prefs.getInt(KEY_UNKNOWN_DETECTIONS, 0) +
            if (classification.decision == "unknown") 1 else 0

        prefs.edit()
            .putInt(KEY_EVENTS, events)
            .putInt(KEY_WEBSITES_SCANNED, scanned)
            .putInt(KEY_NEW_WEBSITES_SCANNED, newScanned)
            .putInt(KEY_BLOCKED_DETECTIONS, blocked)
            .putInt(KEY_UNKNOWN_DETECTIONS, unknown)
            .putStringSet(KEY_SEEN_DOMAINS, seen)
            .putString(KEY_LAST_DOMAIN, domain)
            .putString(KEY_LAST_CATEGORY, classification.category)
            .putString(KEY_LAST_DECISION, classification.decision)
            .putInt(KEY_LAST_SCORE, classification.score)
            .putInt(KEY_LAST_CONFIDENCE, classification.confidence)
            .putString(KEY_LAST_SIGNALS, JSONArray(classification.signals).toString())
            .putLong(KEY_LAST_DETECTED_AT, System.currentTimeMillis())
            .putString(KEY_LAST_PACKAGE, sourcePackage)
            .putString(KEY_LAST_MESSAGE, "Detected ${classification.decision}: $domain")
            .apply()

        return classification
    }

    fun recordAction(context: Context, action: String, message: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_LAST_ACTION, action)
            .putString(KEY_LAST_MESSAGE, message)
            .apply()
    }

    fun status(context: Context): Map<String, Any> {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val signalsText = prefs.getString(KEY_LAST_SIGNALS, "[]") ?: "[]"
        val signals = mutableListOf<String>()

        try {
            val array = JSONArray(signalsText)
            for (index in 0 until array.length()) {
                signals.add(array.optString(index))
            }
        } catch (_: Exception) {
            signals.clear()
        }

        val customBlocklist =
            prefs.getStringSet(KEY_CUSTOM_BLOCKLIST, emptySet()) ?: emptySet()

        return mapOf(
            "events" to prefs.getInt(KEY_EVENTS, 0),
            "websitesScanned" to prefs.getInt(KEY_WEBSITES_SCANNED, 0),
            "newWebsitesScanned" to prefs.getInt(KEY_NEW_WEBSITES_SCANNED, 0),
            "blockedDetections" to prefs.getInt(KEY_BLOCKED_DETECTIONS, 0),
            "unknownDetections" to prefs.getInt(KEY_UNKNOWN_DETECTIONS, 0),
            "nativeBlocklistDomains" to customBlocklist.size,
            "lastDomain" to (prefs.getString(KEY_LAST_DOMAIN, "") ?: ""),
            "lastCategory" to (prefs.getString(KEY_LAST_CATEGORY, "") ?: ""),
            "lastDecision" to (prefs.getString(KEY_LAST_DECISION, "") ?: ""),
            "lastScore" to prefs.getInt(KEY_LAST_SCORE, 0),
            "lastConfidence" to prefs.getInt(KEY_LAST_CONFIDENCE, 0),
            "lastSignals" to signals,
            "lastDetectedAt" to prefs.getLong(KEY_LAST_DETECTED_AT, 0L),
            "lastPackage" to (prefs.getString(KEY_LAST_PACKAGE, "") ?: ""),
            "lastAction" to (prefs.getString(KEY_LAST_ACTION, "") ?: ""),
            "lastMessage" to (prefs.getString(KEY_LAST_MESSAGE, "") ?: ""),
            "mode" to "local_detection"
        )
    }

    fun reset(context: Context) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val customBlocklist =
            prefs.getStringSet(KEY_CUSTOM_BLOCKLIST, emptySet()) ?: emptySet()

        prefs.edit()
            .clear()
            .putStringSet(KEY_CUSTOM_BLOCKLIST, customBlocklist)
            .apply()
    }

    private fun isIgnoredPackage(sourcePackage: String): Boolean {
        val clean = sourcePackage.lowercase(Locale.US)

        return clean == "android" ||
            clean == "com.android.systemui" ||
            clean.contains("focus_shield_android") ||
            clean.contains("focus_shield")
    }

    private fun extractDomain(text: String): String? {
        val matcher = domainPattern.matcher(text)

        while (matcher.find()) {
            val raw = matcher.group(1) ?: continue
            val domain = normalizeDomain(raw)
            if (domain.isNotBlank() && domain.contains(".")) {
                return domain
            }
        }

        return null
    }

    private fun normalizeDomain(raw: String): String {
        var value = raw.trim().lowercase(Locale.US)
        value = value.removePrefix("http://")
        value = value.removePrefix("https://")
        value = value.removePrefix("www.")
        value = value.substringBefore("/")
        value = value.substringBefore("?")
        value = value.substringBefore("#")
        value = value.substringBefore(":")
        return value.trim()
    }

    private fun classify(
        context: Context,
        domain: String
    ): AccessibilityClassification {
        val signals = mutableListOf<String>()
        var score = 0
        var category = "unknown"

        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val customBlocklist =
            prefs.getStringSet(KEY_CUSTOM_BLOCKLIST, emptySet()) ?: emptySet()

        val fallbackBlocklist = listOf(
            "blocked-example.com",
            "unsafe-example.com",
            "risk-example.com"
        )

        val fullBlocklist = customBlocklist + fallbackBlocklist

        if (fullBlocklist.any { domain == it || domain.endsWith(".$it") }) {
            score += 95
            category = "saved-blocklist"
            signals.add("Matched synced blocklist")
        }

        val highRiskSignals = listOf(
            "adult",
            "nsfw",
            "xxx",
            "casino",
            "bet",
            "gambling",
            "bypass",
            "proxy"
        )

        val mediumRiskSignals = listOf(
            "chat",
            "mirror",
            "leak",
            "stream",
            "torrent"
        )

        val productiveSignals = listOf(
            "study",
            "learn",
            "school",
            "college",
            "course",
            "docs",
            "github",
            "wikipedia"
        )

        for (signal in highRiskSignals) {
            if (domain.contains(signal)) {
                score += 75
                signals.add("High-risk signal: $signal")
            }
        }

        for (signal in mediumRiskSignals) {
            if (domain.contains(signal)) {
                score += 15
                signals.add("Medium-risk signal: $signal")
            }
        }

        for (signal in productiveSignals) {
            if (domain.contains(signal)) {
                score -= 20
                signals.add("Productive signal: $signal")
            }
        }

        if (domain.length > 35) {
            score += 10
            signals.add("Long domain shape")
        }

        val digitCount = domain.count { it.isDigit() }
        if (digitCount >= 4) {
            score += 10
            signals.add("Many digits in domain")
        }

        score = score.coerceIn(0, 100)

        if (category == "unknown") {
            category = categoryFromSignals(signals, score)
        }

        if (signals.isEmpty()) {
            signals.add("No strong local signal found")
            score = score.coerceAtLeast(25)
            category = "unknown"
        }

        val decision = when {
            score >= 70 -> "blocked"
            category == "unknown" -> "unknown"
            else -> "allowed"
        }

        return AccessibilityClassification(
            domain = domain,
            category = category,
            decision = decision,
            score = score,
            confidence = score,
            signals = signals,
            shouldOpenApp = decision == "blocked"
        )
    }

    private fun categoryFromSignals(signals: List<String>, score: Int): String {
        val joined = signals.joinToString(" ").lowercase(Locale.US)

        if (joined.contains("synced blocklist")) return "saved-blocklist"
        if (joined.contains("casino") || joined.contains("bet") || joined.contains("gambling")) {
            return "gambling"
        }
        if (joined.contains("adult") || joined.contains("nsfw") || joined.contains("xxx")) {
            return "adult-content"
        }
        if (joined.contains("bypass") || joined.contains("proxy")) {
            return "bypass-risk"
        }
        if (joined.contains("productive")) return "productive"
        if (score >= 70) return "high-risk"
        if (score >= 40) return "medium-risk"

        return "unknown"
    }
}
''')
write("android/app/src/main/kotlin/com/example/focus_shield_android/FocusShieldAccessibilityService.kt", r'''
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
                    launchIntent.putExtra("focus_shield_open_intervention", true)
                    launchIntent.putExtra("phase6_accessibility_domain", classification.domain)
                    launchIntent.putExtra("phase6_accessibility_category", classification.category)
                    launchIntent.putExtra("phase6_accessibility_decision", classification.decision)
                    launchIntent.putExtra("phase6_accessibility_score", classification.score)
                    startActivity(launchIntent)

                    FocusShieldAccessibilityDetectionStore.recordAction(
                        context = applicationContext,
                        action = "opened_app",
                        message = "Focus Shield opened intervention path after blocked detection: ${classification.domain}"
                    )
                    return@post
                }

                val fallbackIntent = Intent(this, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                    putExtra("focus_shield_open_intervention", true)
                    putExtra("phase6_accessibility_domain", classification.domain)
                    putExtra("phase6_accessibility_category", classification.category)
                    putExtra("phase6_accessibility_decision", classification.decision)
                    putExtra("phase6_accessibility_score", classification.score)
                }

                startActivity(fallbackIntent)

                FocusShieldAccessibilityDetectionStore.recordAction(
                    context = applicationContext,
                    action = "opened_app_fallback",
                    message = "Focus Shield fallback intervention launch used for: ${classification.domain}"
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
            openIntent.putExtra("focus_shield_open_intervention", true)
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
                            "Focus Shield blocked ${classification.domain}. Category: ${classification.category}. Score: ${classification.score}/100. Tap to return to Focus Shield."
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
                            "Focus Shield blocked ${classification.domain}. Category: ${classification.category}. Score: ${classification.score}/100. Tap to return to Focus Shield."
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
''')


def patch_main_activity(text: str) -> str:
    if '"syncAccessibilityBlocklist"' not in text:
        text = text.replace(
            '"resetAccessibilityDetections" -> resetAccessibilityDetections(result)',
            '"resetAccessibilityDetections" -> resetAccessibilityDetections(result)\n'
            '                "syncAccessibilityBlocklist" -> syncAccessibilityBlocklist(call.arguments, result)',
        )

    if "private fun syncAccessibilityBlocklist" not in text:
        insert = r'''
    private fun syncAccessibilityBlocklist(arguments: Any?, result: MethodChannel.Result) {
        val domains = mutableListOf<String>()

        if (arguments is List<*>) {
            for (item in arguments) {
                val value = item?.toString()?.trim() ?: ""
                if (value.isNotBlank()) {
                    domains.add(value)
                }
            }
        }

        FocusShieldAccessibilityDetectionStore.updateCustomBlocklist(
            context = applicationContext,
            domains = domains
        )

        result.success("accessibility_blocklist_synced:${domains.size}")
    }
'''
        text = text.replace(
            "    private fun accessibilityDetectionStatus(result: MethodChannel.Result) {",
            insert + "\n    private fun accessibilityDetectionStatus(result: MethodChannel.Result) {",
        )

    return text


patch_file(
    "android/app/src/main/kotlin/com/example/focus_shield_android/MainActivity.kt",
    patch_main_activity,
)


def patch_protection_channel(text: str) -> str:
    if "Future<String> syncAccessibilityBlocklist" not in text:
        insert = r'''
  Future<String> syncAccessibilityBlocklist(List<String> domains) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'syncAccessibilityBlocklist',
        domains,
      );

      return result ?? 'accessibility_blocklist_sync_no_response';
    } catch (error) {
      return 'error:${error.runtimeType}';
    }
  }
'''
        last_brace = text.rfind("}")
        if last_brace != -1:
            text = text[:last_brace] + insert + "\n" + text[last_brace:]

    return text


patch_file("lib/platform/protection_channel.dart", patch_protection_channel)
write("android/app/src/main/kotlin/com/example/focus_shield_android/FocusShieldInterventionActivity.kt", r'''
package com.example.focus_shield_android

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView

class FocusShieldInterventionActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val domain = intent.getStringExtra("phase6_accessibility_domain") ?: "blocked site"
        val category = intent.getStringExtra("phase6_accessibility_category") ?: "risk"
        val decision = intent.getStringExtra("phase6_accessibility_decision") ?: "blocked"
        val score = intent.getIntExtra("phase6_accessibility_score", 0)

        title = "Focus Shield Intervention"

        val scrollView = ScrollView(this)
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(42, 56, 42, 56)
            setBackgroundColor(Color.rgb(3, 7, 24))
        }

        root.addView(
            titleText("Temptation Detected")
        )

        root.addView(
            bodyText("Focus Shield interrupted a risky website before it pulled you away from your goals.")
        )

        root.addView(
            infoCard(
                "Blocked site",
                "Domain: $domain\nDecision: $decision\nCategory: $category\nRisk score: $score/100"
            )
        )

        root.addView(
            infoCard(
                "Return to your standard",
                "I pause, I listen, and I follow my dreams.\n\nThis is the moment where discipline wins."
            )
        )

        root.addView(
            actionButton("Open Focus Shield") {
                openMainApp()
            }
        )

        root.addView(
            actionButton("Close Intervention") {
                finish()
            }
        )

        scrollView.addView(root)
        setContentView(scrollView)
    }

    private fun titleText(text: String): TextView {
        return TextView(this).apply {
            this.text = text
            textSize = 32f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            setPadding(0, 0, 0, 22)
        }
    }

    private fun bodyText(text: String): TextView {
        return TextView(this).apply {
            this.text = text
            textSize = 18f
            setTextColor(Color.rgb(220, 230, 245))
            setPadding(0, 0, 0, 28)
        }
    }

    private fun infoCard(title: String, body: String): LinearLayout {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(28, 28, 28, 28)
            background = roundedBorder(
                fill = Color.rgb(10, 20, 45),
                stroke = Color.rgb(37, 99, 235)
            )
        }

        val titleView = TextView(this).apply {
            text = title
            textSize = 18f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            setPadding(0, 0, 0, 12)
        }

        val bodyView = TextView(this).apply {
            text = body
            textSize = 16f
            setTextColor(Color.rgb(220, 230, 245))
        }

        card.addView(titleView)
        card.addView(bodyView)

        val params = LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply {
            setMargins(0, 0, 0, 22)
        }

        card.layoutParams = params
        return card
    }

    private fun actionButton(label: String, action: () -> Unit): Button {
        return Button(this).apply {
            text = label
            textSize = 16f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(Color.rgb(3, 7, 24))
            background = roundedFill(Color.rgb(34, 197, 94))
            setPadding(18, 18, 18, 18)
            gravity = Gravity.CENTER
            setOnClickListener { action() }

            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 8, 0, 16)
            }
        }
    }

    private fun roundedBorder(fill: Int, stroke: Int): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = 28f
            setColor(fill)
            setStroke(2, stroke)
        }
    }

    private fun roundedFill(fill: Int): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = 28f
            setColor(fill)
        }
    }

    private fun openMainApp() {
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        startActivity(intent)
        finish()
    }
}
''')


def patch_service_for_intervention_activity(text: str) -> str:
    text = text.replace(
        "val launchIntent = packageManager.getLaunchIntentForPackage(packageName)",
        "val launchIntent = Intent(this, FocusShieldInterventionActivity::class.java)",
        1,
    )

    text = text.replace(
        """val openIntent = packageManager.getLaunchIntentForPackage(packageName)
                ?: Intent(this, MainActivity::class.java)""",
        """val openIntent = Intent(this, FocusShieldInterventionActivity::class.java)""",
    )

    text = text.replace(
        'action = "opened_app"',
        'action = "opened_intervention"',
    )

    text = text.replace(
        "Focus Shield opened intervention path after blocked detection:",
        "Focus Shield opened native intervention screen after blocked detection:",
    )

    return text


patch_file(
    "android/app/src/main/kotlin/com/example/focus_shield_android/FocusShieldAccessibilityService.kt",
    patch_service_for_intervention_activity,
)


def patch_android_manifest(text: str) -> str:
    if 'android.permission.POST_NOTIFICATIONS' not in text:
        text = text.replace(
            '<manifest xmlns:android="http://schemas.android.com/apk/res/android">',
            '<manifest xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />',
        )

    if "FocusShieldInterventionActivity" not in text:
        text = text.replace(
            "</application>",
            '''
        <activity
            android:name=".FocusShieldInterventionActivity"
            android:exported="false"
            android:theme="@style/LaunchTheme" />
''' + "\n    </application>",
        )

    return text


patch_file("android/app/src/main/AndroidManifest.xml", patch_android_manifest)


def patch_main_activity(text: str) -> str:
    if '"syncAccessibilityBlocklist"' not in text:
        text = text.replace(
            '"resetAccessibilityDetections" -> resetAccessibilityDetections(result)',
            '"resetAccessibilityDetections" -> resetAccessibilityDetections(result)\n'
            '                "syncAccessibilityBlocklist" -> syncAccessibilityBlocklist(call.arguments, result)',
        )

    if "private fun syncAccessibilityBlocklist" not in text:
        insert = r'''
    private fun syncAccessibilityBlocklist(arguments: Any?, result: MethodChannel.Result) {
        val domains = mutableListOf<String>()

        if (arguments is List<*>) {
            for (item in arguments) {
                val value = item?.toString()?.trim() ?: ""
                if (value.isNotBlank()) {
                    domains.add(value)
                }
            }
        }

        FocusShieldAccessibilityDetectionStore.updateCustomBlocklist(
            context = applicationContext,
            domains = domains
        )

        result.success("accessibility_blocklist_synced:${domains.size}")
    }
'''
        text = text.replace(
            "    private fun accessibilityDetectionStatus(result: MethodChannel.Result) {",
            insert + "\n    private fun accessibilityDetectionStatus(result: MethodChannel.Result) {",
        )

    return text


patch_file(
    "android/app/src/main/kotlin/com/example/focus_shield_android/MainActivity.kt",
    patch_main_activity,
)


def patch_protection_channel(text: str) -> str:
    if "Future<String> syncAccessibilityBlocklist" not in text:
        insert = r'''
  Future<String> syncAccessibilityBlocklist(List<String> domains) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'syncAccessibilityBlocklist',
        domains,
      );

      return result ?? 'accessibility_blocklist_sync_no_response';
    } catch (error) {
      return 'error:${error.runtimeType}';
    }
  }
'''
        last_brace = text.rfind("}")
        if last_brace != -1:
            text = text[:last_brace] + insert + "\n" + text[last_brace:]

    return text


patch_file("lib/platform/protection_channel.dart", patch_protection_channel)


write("lib/presentation/screens/accessibility_detection_screen.dart", r'''
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class AccessibilityDetectionScreen extends StatefulWidget {
  const AccessibilityDetectionScreen({
    super.key,
    required this.onBack,
    this.blockedDomains = const <String>[],
  });

  final VoidCallback onBack;
  final List<String> blockedDomains;

  @override
  State<AccessibilityDetectionScreen> createState() =>
      _AccessibilityDetectionScreenState();
}

class _AccessibilityDetectionScreenState
    extends State<AccessibilityDetectionScreen> {
  final ProtectionChannel _channel = ProtectionChannel();

  Map<String, dynamic> _status = <String, dynamic>{};
  bool _loading = true;
  String _message = 'Loading accessibility detection status...';

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _syncBlocklist();
  }

  Future<void> _loadStatus() async {
    final status = await _channel.accessibilityDetectionStatus();

    if (!mounted) return;

    setState(() {
      _status = status;
      _loading = false;
      _message = 'Accessibility detection status refreshed.';
    });
  }

  Future<void> _syncBlocklist() async {
    final domains = widget.blockedDomains
        .map((domain) => domain.trim().toLowerCase())
        .where((domain) => domain.isNotEmpty)
        .toSet()
        .toList();

    final result = await _channel.syncAccessibilityBlocklist(domains);
    final status = await _channel.accessibilityDetectionStatus();

    if (!mounted) return;

    setState(() {
      _status = status;
      _message = result;
    });
  }

  Future<void> _reset() async {
    final result = await _channel.resetAccessibilityDetections();
    final status = await _channel.accessibilityDetectionStatus();

    if (!mounted) return;

    setState(() {
      _status = status;
      _message = result;
    });
  }

  Future<void> _openAccessibilitySettings() async {
    final result = await _channel.openAccessibilitySettings();

    if (!mounted) return;

    setState(() {
      _message = result;
    });
  }

  String _value(String key) {
    final value = _status[key];
    if (value == null) return '';
    return value.toString();
  }

  String _safeValue(String key, String fallback) {
    final value = _value(key);
    if (value.trim().isEmpty) return fallback;
    return value;
  }

  List<String> _signals() {
    final raw = _status['lastSignals'];

    if (raw is List) {
      return raw.map((item) => item.toString()).toList();
    }

    return <String>[];
  }

  String _cleanMode() {
    final mode = _value('mode').toLowerCase();

    if (mode.contains('local')) {
      return 'Local';
    }

    if (mode.isEmpty) {
      return 'Local';
    }

    return 'Active';
  }

  Color _decisionColor() {
    final decision = _value('lastDecision').toLowerCase();

    if (decision == 'blocked') return AppTheme.danger;
    if (decision == 'unknown') return AppTheme.warning;

    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final signals = _signals();
    final lastAction = _safeValue('lastAction', '-');
    final lastMessage = _safeValue('lastMessage', 'No action recorded yet.');

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Accessibility Detection',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ],
        ),
        const Text('Visible website text detection powered by local AI-lite.'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Mode': _cleanMode(),
              'Events': _safeValue('events', '0'),
              'Scanned': _safeValue('websitesScanned', '0'),
              'New': _safeValue('newWebsitesScanned', '0'),
              'Blocked': _safeValue('blockedDetections', '0'),
              'Unknown': _safeValue('unknownDetections', '0'),
              'Native DB': _safeValue('nativeBlocklistDomains', '0'),
            },
          ),
        ),
        ShieldCard(
          borderColor: _decisionColor(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Last detection'),
              const SizedBox(height: 8),
              if (_loading)
                const Text('Loading...')
              else ...[
                Text('Domain: ${_safeValue('lastDomain', '-')}'),
                Text('Decision: ${_safeValue('lastDecision', '-')}'),
                Text('Category: ${_safeValue('lastCategory', '-')}'),
                Text('Score: ${_safeValue('lastScore', '0')}/100'),
                Text('Confidence: ${_safeValue('lastConfidence', '0')}%'),
                Text('Package: ${_safeValue('lastPackage', '-')}'),
              ],
              const SizedBox(height: 12),
              const Text('Risk signals'),
              const SizedBox(height: 6),
              if (signals.isEmpty)
                const Text('No signals captured yet.')
              else
                ...signals.map(
                  (signal) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $signal'),
                  ),
                ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Last protection action'),
              const SizedBox(height: 8),
              Text('Action: $lastAction'),
              const SizedBox(height: 6),
              Text(lastMessage),
              const SizedBox(height: 12),
              const Text(
                'Blocked detections now open the native intervention screen. If Android blocks auto-open, Focus Shield still uses toast and notification fallback.',
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Native blocklist sync'),
              const SizedBox(height: 8),
              Text(
                'Flutter saved blocklist domains: ${widget.blockedDomains.length}',
              ),
              const SizedBox(height: 8),
              Text(
                'Native Accessibility DB: ${_safeValue('nativeBlocklistDomains', '0')}',
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Sync Blocklist to Accessibility',
                subtitle: 'Use saved blocklist in native detection',
                onPressed: _syncBlocklist,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Setup'),
              const SizedBox(height: 8),
              const Text(
                'Android requires you to manually enable Focus Shield in Accessibility Settings. If Android shows Restricted setting, open Settings > Apps > Focus Shield > More options > Allow restricted settings.',
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Open Accessibility Settings',
                subtitle: 'Enable Focus Shield manually',
                onPressed: _openAccessibilitySettings,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Controls'),
              const SizedBox(height: 8),
              Text(_message),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Refresh Detection Status',
                subtitle: 'Read native accessibility counters',
                onPressed: _loadStatus,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Reset Detection Counters',
                subtitle: 'Clear native detection stats',
                onPressed: _reset,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: const Text(
            'Phase 6D ignores Android System UI rescans, syncs the saved blocklist into native Accessibility detection, and opens a real intervention screen after blocked detection.',
          ),
        ),
      ],
    );
  }
}
''')


def patch_app_dart(text: str) -> str:
    text = text.replace(
        """AccessibilityDetectionScreen(
        onBack: _closeAccessibilityDetection,
      );""",
        """AccessibilityDetectionScreen(
        onBack: _closeAccessibilityDetection,
        blockedDomains: _blockedDomains.map((item) => item.domain).toList(),
      );""",
    )

    return text


patch_file("lib/app.dart", patch_app_dart)

print("Phase 6D intervention sync patch completed successfully.")
