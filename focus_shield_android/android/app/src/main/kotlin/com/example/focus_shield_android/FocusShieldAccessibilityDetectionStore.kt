package com.example.focus_shield_android

import android.content.Context
import org.json.JSONArray
import java.util.Locale
import java.util.regex.Pattern

object FocusShieldAccessibilityDetectionStore {
    private const val PREFS = "focus_shield_accessibility_detection"

    private const val KEY_EVENTS = "events"
    private const val KEY_RAW_DOMAIN_EVENTS = "raw_domain_events"
    private const val KEY_WEBSITES_SCANNED = "websites_scanned"
    private const val KEY_NEW_WEBSITES_SCANNED = "new_websites_scanned"
    private const val KEY_BLOCKED_DETECTIONS = "blocked_detections"
    private const val KEY_UNKNOWN_DETECTIONS = "unknown_detections"
    private const val KEY_SUPPRESSED_DUPLICATES = "suppressed_duplicates"
    private const val KEY_SUPPRESSED_NOISE = "suppressed_noise"

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

    private const val KEY_LAST_SYNC_ACTION = "last_sync_action"
    private const val KEY_LAST_SYNC_MESSAGE = "last_sync_message"
    private const val KEY_LAST_SYNC_AT = "last_sync_at"

    private const val KEY_LAST_SCAN_SIGNATURE = "last_scan_signature"
    private const val KEY_LAST_SCAN_AT = "last_scan_at"
    private const val KEY_LAST_UNKNOWN_DOMAIN = "last_unknown_domain"
    private const val KEY_LAST_UNKNOWN_AT = "last_unknown_at"
    private const val KEY_LAST_SUPPRESSED_DOMAIN = "last_suppressed_domain"
    private const val KEY_LAST_SUPPRESSED_REASON = "last_suppressed_reason"
    private const val KEY_LAST_SUPPRESSED_AT = "last_suppressed_at"

    private const val DUPLICATE_COOLDOWN_MS = 10_000L
    private const val UNKNOWN_COOLDOWN_MS = 60_000L

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
            .putString(KEY_LAST_SYNC_ACTION, "blocklist_synced")
            .putString(
                KEY_LAST_SYNC_MESSAGE,
                "Native Accessibility blocklist synced: ${cleanedDomains.size} domain(s)"
            )
            .putLong(KEY_LAST_SYNC_AT, System.currentTimeMillis())
            .apply()
    }

    fun recordVisibleText(
        context: Context,
        visibleText: String,
        sourcePackage: String
    ): AccessibilityClassification? {
        if (isIgnoredPackage(sourcePackage)) return null

        val cleanedText = visibleText
            .replace(Regex("\\s+"), " ")
            .trim()
            .take(4000)

        if (cleanedText.length < 4) return null

        val domain = extractDomain(cleanedText) ?: return null
        val classification = classify(context, domain)

        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val now = System.currentTimeMillis()

        prefs.edit()
            .putInt(KEY_RAW_DOMAIN_EVENTS, prefs.getInt(KEY_RAW_DOMAIN_EVENTS, 0) + 1)
            .apply()

        if (shouldSuppressDuplicate(prefs, domain, sourcePackage, classification, now)) {
            recordSuppressed(
                prefs = prefs,
                domain = domain,
                reason = "duplicate_cooldown",
                now = now,
            )
            return null
        }

        if (shouldSuppressUnknownNoise(prefs, classification, now)) {
            recordSuppressed(
                prefs = prefs,
                domain = domain,
                reason = "unknown_noise_cooldown",
                now = now,
            )
            return null
        }

        val seen = prefs.getStringSet(KEY_SEEN_DOMAINS, emptySet())?.toMutableSet()
            ?: mutableSetOf()

        val isNew = !seen.contains(domain)
        if (isNew) {
            seen.add(domain)
        }

        val events = prefs.getInt(KEY_EVENTS, 0) + 1
        val scanned = prefs.getInt(KEY_WEBSITES_SCANNED, 0) + 1
        val newScanned = prefs.getInt(KEY_NEW_WEBSITES_SCANNED, 0) + if (isNew) 1 else 0
        val blocked =
            prefs.getInt(KEY_BLOCKED_DETECTIONS, 0) + if (classification.decision == "blocked") 1 else 0
        val unknown =
            prefs.getInt(KEY_UNKNOWN_DETECTIONS, 0) + if (classification.decision == "unknown") 1 else 0

        val signature = scanSignature(domain, sourcePackage, classification.decision)

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
            .putLong(KEY_LAST_DETECTED_AT, now)
            .putString(KEY_LAST_PACKAGE, sourcePackage)
            .putString(KEY_LAST_MESSAGE, "Detected ${classification.decision}: $domain")
            .putString(KEY_LAST_SCAN_SIGNATURE, signature)
            .putLong(KEY_LAST_SCAN_AT, now)
            .apply()

        if (classification.decision == "unknown") {
            prefs.edit()
                .putString(KEY_LAST_UNKNOWN_DOMAIN, domain)
                .putLong(KEY_LAST_UNKNOWN_AT, now)
                .apply()
        }

        return classification
    }

    fun recordAction(context: Context, action: String, message: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_LAST_ACTION, action)
            .putString(KEY_LAST_MESSAGE, message)
            .apply()
    }

    fun status(context: Context): Map<String, Any?> {
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

        val rawLastAction = prefs.getString(KEY_LAST_ACTION, "") ?: ""
        val rawLastMessage = prefs.getString(KEY_LAST_MESSAGE, "") ?: ""
        val lastDecision = prefs.getString(KEY_LAST_DECISION, "") ?: ""
        val lastDomain = prefs.getString(KEY_LAST_DOMAIN, "") ?: ""

        val stableLastAction =
            if (rawLastAction == "blocklist_synced" && lastDecision == "blocked") {
                "opened_intervention"
            } else {
                rawLastAction
            }

        val stableLastMessage =
            if (rawLastAction == "blocklist_synced" &&
                lastDecision == "blocked" &&
                lastDomain.isNotBlank()
            ) {
                "Blocked detection preserved after native blocklist sync: $lastDomain"
            } else {
                rawLastMessage
            }

        val blockedCount = prefs.getInt(KEY_BLOCKED_DETECTIONS, 0)
        val scannedCount = prefs.getInt(KEY_WEBSITES_SCANNED, 0)
        val nativeDbCount = customBlocklist.size
        val interventionReady =
            stableLastAction == "opened_intervention" ||
                stableLastAction == "opened_app_fallback" ||
                stableLastAction == "notification_sent"

        val readinessScore =
            listOf(
                nativeDbCount > 0,
                scannedCount > 0,
                blockedCount > 0,
                interventionReady,
            ).count { it } * 25

        val readinessLabel =
            if (readinessScore >= 100) {
                "Production-ready"
            } else if (readinessScore >= 75) {
                "Almost ready"
            } else if (readinessScore >= 50) {
                "Needs more testing"
            } else {
                "Setup required"
            }

        return mapOf(
            "events" to prefs.getInt(KEY_EVENTS, 0),
            "rawDomainEvents" to prefs.getInt(KEY_RAW_DOMAIN_EVENTS, 0),
            "websitesScanned" to scannedCount,
            "newWebsitesScanned" to prefs.getInt(KEY_NEW_WEBSITES_SCANNED, 0),
            "blockedDetections" to blockedCount,
            "unknownDetections" to prefs.getInt(KEY_UNKNOWN_DETECTIONS, 0),
            "suppressedDuplicates" to prefs.getInt(KEY_SUPPRESSED_DUPLICATES, 0),
            "suppressedNoise" to prefs.getInt(KEY_SUPPRESSED_NOISE, 0),
            "nativeBlocklistDomains" to nativeDbCount,
            "lastDomain" to lastDomain,
            "lastCategory" to (prefs.getString(KEY_LAST_CATEGORY, "") ?: ""),
            "lastDecision" to lastDecision,
            "lastScore" to prefs.getInt(KEY_LAST_SCORE, 0),
            "lastConfidence" to prefs.getInt(KEY_LAST_CONFIDENCE, 0),
            "lastSignals" to signals,
            "lastDetectedAt" to prefs.getLong(KEY_LAST_DETECTED_AT, 0L),
            "lastPackage" to (prefs.getString(KEY_LAST_PACKAGE, "") ?: ""),
            "lastAction" to stableLastAction,
            "lastMessage" to stableLastMessage,
            "lastSyncAction" to (prefs.getString(KEY_LAST_SYNC_ACTION, "") ?: ""),
            "lastSyncMessage" to (prefs.getString(KEY_LAST_SYNC_MESSAGE, "") ?: ""),
            "lastSyncAt" to prefs.getLong(KEY_LAST_SYNC_AT, 0L),
            "lastSuppressedDomain" to (prefs.getString(KEY_LAST_SUPPRESSED_DOMAIN, "") ?: ""),
            "lastSuppressedReason" to (prefs.getString(KEY_LAST_SUPPRESSED_REASON, "") ?: ""),
            "lastSuppressedAt" to prefs.getLong(KEY_LAST_SUPPRESSED_AT, 0L),
            "duplicateCooldownSeconds" to (DUPLICATE_COOLDOWN_MS / 1000L).toInt(),
            "unknownCooldownSeconds" to (UNKNOWN_COOLDOWN_MS / 1000L).toInt(),
            "noiseControlMode" to "cooldown_active",
            "readinessScore" to readinessScore,
            "readinessLabel" to readinessLabel,
            "interventionReady" to interventionReady,
            "mode" to "local_detection_noise_control"
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

    private fun shouldSuppressDuplicate(
        prefs: android.content.SharedPreferences,
        domain: String,
        sourcePackage: String,
        classification: AccessibilityClassification,
        now: Long
    ): Boolean {
        val signature = scanSignature(domain, sourcePackage, classification.decision)
        val lastSignature = prefs.getString(KEY_LAST_SCAN_SIGNATURE, "") ?: ""
        val lastAt = prefs.getLong(KEY_LAST_SCAN_AT, 0L)

        return signature == lastSignature && now - lastAt < DUPLICATE_COOLDOWN_MS
    }

    private fun shouldSuppressUnknownNoise(
        prefs: android.content.SharedPreferences,
        classification: AccessibilityClassification,
        now: Long
    ): Boolean {
        if (classification.decision != "unknown") return false

        val lastUnknownDomain = prefs.getString(KEY_LAST_UNKNOWN_DOMAIN, "") ?: ""
        val lastUnknownAt = prefs.getLong(KEY_LAST_UNKNOWN_AT, 0L)

        return classification.domain == lastUnknownDomain &&
            now - lastUnknownAt < UNKNOWN_COOLDOWN_MS
    }

    private fun recordSuppressed(
        prefs: android.content.SharedPreferences,
        domain: String,
        reason: String,
        now: Long
    ) {
        val duplicateCount =
            prefs.getInt(KEY_SUPPRESSED_DUPLICATES, 0) +
                if (reason == "duplicate_cooldown") 1 else 0

        val noiseCount =
            prefs.getInt(KEY_SUPPRESSED_NOISE, 0) +
                if (reason == "unknown_noise_cooldown") 1 else 0

        prefs.edit()
            .putInt(KEY_SUPPRESSED_DUPLICATES, duplicateCount)
            .putInt(KEY_SUPPRESSED_NOISE, noiseCount)
            .putString(KEY_LAST_SUPPRESSED_DOMAIN, domain)
            .putString(KEY_LAST_SUPPRESSED_REASON, reason)
            .putLong(KEY_LAST_SUPPRESSED_AT, now)
            .apply()
    }

    private fun scanSignature(
        domain: String,
        sourcePackage: String,
        decision: String
    ): String {
        return "${sourcePackage.lowercase(Locale.US)}|$domain|$decision"
    }

    private fun isIgnoredPackage(sourcePackage: String): Boolean {
        val clean = sourcePackage.lowercase(Locale.US)

        return clean == "android" ||
            clean == "com.android.systemui" ||
            clean.contains("focus_shield_android") ||
            clean.contains("focus_shield") ||
            clean.contains("launcher") ||
            clean.contains("settings") ||
            clean.contains("packageinstaller") ||
            clean.contains("permissioncontroller") ||
            clean.contains("gallery") ||
            clean.contains("photos") ||
            clean.contains("screenshot")
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
        value = value.trim()

        return value
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

        if (joined.contains("casino") ||
            joined.contains("bet") ||
            joined.contains("gambling")
        ) {
            return "gambling"
        }

        if (joined.contains("adult") ||
            joined.contains("nsfw") ||
            joined.contains("xxx")
        ) {
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
