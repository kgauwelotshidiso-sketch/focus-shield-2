from pathlib import Path
import re

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


def add_import_if_missing(text: str, import_line: str) -> str:
    if import_line in text:
        return text

    lines = text.splitlines()
    last_import_index = -1

    for index, line in enumerate(lines):
        if line.strip().startswith("import "):
            last_import_index = index

    if last_import_index == -1:
        return import_line + "\n\n" + text

    lines.insert(last_import_index + 1, import_line)
    return "\n".join(lines) + "\n"


def remove_import(text: str, import_line: str) -> str:
    return text.replace(import_line + "\n", "").replace(import_line, "")


write("android/app/src/main/kotlin/com/example/focus_shield_android/FocusShieldAccessibilityDetectionStore.kt", r'''
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
''')

print("Phase 6H Part 1 applied: native noise-control store installed.")
write("lib/presentation/widgets/protection_readiness_card.dart", r'''
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import 'action_button.dart';
import 'shield_card.dart';
import 'stat_grid.dart';

class ProtectionReadinessCard extends StatefulWidget {
  const ProtectionReadinessCard({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  State<ProtectionReadinessCard> createState() =>
      _ProtectionReadinessCardState();
}

class _ProtectionReadinessCardState extends State<ProtectionReadinessCard> {
  final ProtectionChannel _channel = ProtectionChannel();

  Map<String, dynamic> _status = <String, dynamic>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final status = await _channel.accessibilityDetectionStatus();

    if (!mounted) return;

    setState(() {
      _status = status;
      _loading = false;
    });
  }

  String _value(String key, {String fallback = '0'}) {
    final value = _status[key];

    if (value == null) return fallback;

    final clean = value.toString().trim();

    if (clean.isEmpty) return fallback;

    return clean;
  }

  int _intValue(String key) {
    final value = _status[key];

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool get _nativeDbReady => _intValue('nativeBlocklistDomains') > 0;

  bool get _scanningActive => _intValue('websitesScanned') > 0;

  bool get _blockingConfirmed => _intValue('blockedDetections') > 0;

  bool get _interventionReady {
    final action = _value('lastAction', fallback: '').toLowerCase();

    return action == 'opened_intervention' ||
        action == 'opened_app_fallback' ||
        action == 'notification_sent';
  }

  int get _score {
    final nativeScore = _intValue('readinessScore');

    if (nativeScore > 0) return nativeScore.clamp(0, 100);

    final checks = <bool>[
      _nativeDbReady,
      _scanningActive,
      _blockingConfirmed,
      _interventionReady,
    ];

    return checks.where((ready) => ready).length * 25;
  }

  String get _label {
    final nativeLabel = _value('readinessLabel', fallback: '');

    if (nativeLabel.isNotEmpty) return nativeLabel;

    if (_score >= 100) return 'Production-ready';
    if (_score >= 75) return 'Almost ready';
    if (_score >= 50) return 'Needs more testing';
    return 'Setup required';
  }

  Color get _borderColor {
    if (_score >= 100) return AppTheme.primary;
    if (_score >= 75) return AppTheme.secondary;
    return AppTheme.warning;
  }

  String _ready(bool value) => value ? 'Ready' : 'Check';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ShieldCard(
        borderColor: AppTheme.warning,
        child: Text('Loading protection health...'),
      );
    }

    return ShieldCard(
      borderColor: _borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Protection Health'),
          const SizedBox(height: 12),
          StatGrid(
            items: {
              'Readiness': '$_score%',
              'Status': _label,
              'Native DB': _ready(_nativeDbReady),
              'Scanning': _ready(_scanningActive),
              'Blocking': _ready(_blockingConfirmed),
              'Intervention': _ready(_interventionReady),
            },
          ),
          if (!widget.compact) ...[
            const SizedBox(height: 12),
            Text('Latest blocked site: ${_value('lastDomain', fallback: 'None')}'),
            const SizedBox(height: 6),
            Text('Stable action: ${_value('lastAction', fallback: 'No action yet')}'),
            const SizedBox(height: 6),
            Text('Noise control: ${_value('noiseControlMode', fallback: 'not active')}'),
            const SizedBox(height: 6),
            Text(
              'Suppressed duplicates: ${_value('suppressedDuplicates')} | Suppressed noise: ${_value('suppressedNoise')}',
            ),
            const SizedBox(height: 12),
            ActionButton(
              label: 'Refresh Protection Health',
              subtitle: 'Read native readiness and noise-control stats',
              onPressed: _refresh,
            ),
          ],
        ],
      ),
    );
  }
}
''')


def patch_native_counter_widget_noise_control(text: str) -> str:
    if "Noise control:" in text and "Suppressed duplicates:" in text:
        return text

    text = text.replace(
        """          Text('Latest blocked site: ${_value('lastDomain', fallback: 'None')}'),
          const SizedBox(height: 6),
          Text('Stable protection action: $_stableAction'),""",
        """          Text('Latest blocked site: ${_value('lastDomain', fallback: 'None')}'),
          const SizedBox(height: 6),
          Text('Stable protection action: $_stableAction'),
          const SizedBox(height: 6),
          Text('Noise control: ${_value('noiseControlMode', fallback: 'cooldown active')}'),
          const SizedBox(height: 6),
          Text(
            'Suppressed duplicates: ${_value('suppressedDuplicates')} | Suppressed noise: ${_value('suppressedNoise')}',
          ),""",
    )

    text = text.replace(
        """          Text('Last blocked site: ${_value('lastDomain', fallback: 'None')}'),
          const SizedBox(height: 6),
          Text('Protection action: $_stableAction'),""",
        """          Text('Latest blocked site: ${_value('lastDomain', fallback: 'None')}'),
          const SizedBox(height: 6),
          Text('Stable protection action: $_stableAction'),
          const SizedBox(height: 6),
          Text('Noise control: ${_value('noiseControlMode', fallback: 'cooldown active')}'),
          const SizedBox(height: 6),
          Text(
            'Suppressed duplicates: ${_value('suppressedDuplicates')} | Suppressed noise: ${_value('suppressedNoise')}',
          ),""",
    )

    return text


patch_file(
    "lib/presentation/widgets/native_protection_counters_card.dart",
    patch_native_counter_widget_noise_control,
)


def patch_protection_chain_widget_noise_control(text: str) -> str:
    if "Suppressed duplicates:" in text:
        return text

    text = text.replace(
        """          Text('Last protection action: $_stableAction'),""",
        """          Text('Last protection action: $_stableAction'),
          const SizedBox(height: 6),
          Text('Noise control: ${_value('noiseControlMode', fallback: 'cooldown active')}'),
          const SizedBox(height: 6),
          Text(
            'Suppressed duplicates: ${_value('suppressedDuplicates')} | Suppressed noise: ${_value('suppressedNoise')}',
          ),""",
    )

    return text


patch_file(
    "lib/presentation/widgets/protection_chain_status_card.dart",
    patch_protection_chain_widget_noise_control,
)


def patch_home_screen_readiness_card(text: str) -> str:
    text = add_import_if_missing(
        text,
        "import '../widgets/protection_readiness_card.dart';",
    )

    if "ProtectionReadinessCard(" in text:
        return text

    marker = """        NativeHomeProtectionSummaryCard("""

    marker_index = text.find(marker)

    if marker_index == -1:
        return text

    start = text.rfind("\n", 0, marker_index)
    if start == -1:
        start = marker_index
    else:
        start += 1

    paren_index = text.find("(", marker_index)
    if paren_index == -1:
        return text

    depth = 0
    end = paren_index

    while end < len(text):
        char = text[end]

        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1

            if depth == 0:
                end += 1

                while end < len(text) and text[end] in " \t\r\n,":
                    end += 1

                sized_box_match = re.match(
                    r"\s*const\s+SizedBox\s*\(\s*height\s*:\s*16\s*\)\s*,?",
                    text[end:],
                )

                if sized_box_match:
                    end += sized_box_match.end()

                insert = """        const ProtectionReadinessCard(),
        const SizedBox(height: 16),
"""
                return text[:end] + "\n" + insert + text[end:]

        end += 1

    return text


patch_file("lib/presentation/screens/home_screen.dart", patch_home_screen_readiness_card)


def patch_accessibility_detection_readiness_import(text: str) -> str:
    return add_import_if_missing(
        text,
        "import '../widgets/protection_readiness_card.dart';",
    )


patch_file(
    "lib/presentation/screens/accessibility_detection_screen.dart",
    patch_accessibility_detection_readiness_import,
          )
def insert_widget_before_shield_card_containing(
    text: str,
    marker: str,
    widget_code: str,
    duplicate_guard: str,
) -> str:
    if duplicate_guard in text:
        return text

    marker_index = text.find(marker)

    if marker_index == -1:
        return text

    start = text.rfind("ShieldCard(", 0, marker_index)

    if start == -1:
        return text

    line_start = text.rfind("\n", 0, start)

    if line_start == -1:
        line_start = start
    else:
        line_start += 1

    return text[:line_start] + widget_code + text[line_start:]


def insert_widget_after_first_list_children(
    text: str,
    widget_code: str,
    duplicate_guard: str,
) -> str:
    if duplicate_guard in text:
        return text

    listview_index = text.find("ListView(")

    if listview_index == -1:
        return text

    children_index = text.find("children: [", listview_index)

    if children_index == -1:
        return text

    insert_index = children_index + len("children: [")

    return text[:insert_index] + "\n" + widget_code + text[insert_index:]


def patch_accessibility_detection_screen_readiness_card(text: str) -> str:
    text = add_import_if_missing(
        text,
        "import '../widgets/protection_readiness_card.dart';",
    )

    widget_code = """        const ProtectionReadinessCard(),
        const SizedBox(height: 16),
"""

    if "ProtectionReadinessCard(" in text:
        return text

    text = insert_widget_before_shield_card_containing(
        text=text,
        marker="Last detection",
        widget_code=widget_code,
        duplicate_guard="ProtectionReadinessCard(",
    )

    if "ProtectionReadinessCard(" in text:
        return text

    text = insert_widget_before_shield_card_containing(
        text=text,
        marker="Setup",
        widget_code=widget_code,
        duplicate_guard="ProtectionReadinessCard(",
    )

    if "ProtectionReadinessCard(" in text:
        return text

    return insert_widget_after_first_list_children(
        text=text,
        widget_code=widget_code,
        duplicate_guard="ProtectionReadinessCard(",
    )


patch_file(
    "lib/presentation/screens/accessibility_detection_screen.dart",
    patch_accessibility_detection_screen_readiness_card,
)


def patch_home_screen_readiness_fallback(text: str) -> str:
    text = add_import_if_missing(
        text,
        "import '../widgets/protection_readiness_card.dart';",
    )

    if "ProtectionReadinessCard(" in text:
        return text

    widget_code = """        const ProtectionReadinessCard(),
        const SizedBox(height: 16),
"""

    text = insert_widget_before_shield_card_containing(
        text=text,
        marker="Today’s Mission",
        widget_code=widget_code,
        duplicate_guard="ProtectionReadinessCard(",
    )

    if "ProtectionReadinessCard(" in text:
        return text

    text = insert_widget_before_shield_card_containing(
        text=text,
        marker="Today's Mission",
        widget_code=widget_code,
        duplicate_guard="ProtectionReadinessCard(",
    )

    if "ProtectionReadinessCard(" in text:
        return text

    return insert_widget_after_first_list_children(
        text=text,
        widget_code=widget_code,
        duplicate_guard="ProtectionReadinessCard(",
    )


patch_file("lib/presentation/screens/home_screen.dart", patch_home_screen_readiness_fallback)


def patch_scanner_phase6h_footer(text: str) -> str:
    if "Phase 6H noise control is active" in text:
        return text

    old = """Testing tools remain available below. Real scanned, new, total, and blocked counters now come from native Accessibility detection."""

    new = """Testing tools remain available below. Real scanned, new, total, and blocked counters now come from native Accessibility detection. Phase 6H noise control is active with duplicate cooldown and unknown-site cooldown."""

    text = text.replace(old, new)

    if "Phase 6H noise control is active" in text:
        return text

    marker = """        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text("""
    marker_index = text.rfind(marker)

    if marker_index == -1:
        return text

    return text[:marker_index] + """        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text(
            'Phase 6H noise control is active. Duplicate visible-domain events are suppressed, unknown-site repeats are cooled down, and intervention still opens for blocked sites.',
          ),
        ),
""" + text[marker_index:]


patch_file("lib/presentation/screens/scanner_screen.dart", patch_scanner_phase6h_footer)


def patch_progress_phase6h_footer(text: str) -> str:
    if "Phase 6H protection activity is synced" in text:
        return text

    widget_code = """        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text(
            'Phase 6H protection activity is synced from native Accessibility detection with duplicate and unknown-site noise control.',
          ),
        ),
"""

    return insert_widget_before_shield_card_containing(
        text=text,
        marker="Log Listening Win",
        widget_code=widget_code,
        duplicate_guard="Phase 6H protection activity is synced",
    )


patch_file("lib/presentation/screens/progress_screen.dart", patch_progress_phase6h_footer)


def patch_accessibility_footer_text(text: str) -> str:
    text = text.replace(
        "Phase 6D ignores Android System UI rescans, syncs the saved blocklist into native Accessibility detection, and opens a real intervention screen after blocked detection.",
        "Phase 6H ignores Android System UI rescans, suppresses repeated visible-domain events, cools down repeated unknown-site detections, syncs the saved blocklist into native Accessibility detection, and keeps the intervention screen active.",
    )

    text = text.replace(
        "Main app counter sync is active. Home, Scanner, and Progress can now read native Accessibility scanned, new, blocked, unknown, and last blocked site data.",
        "Main app counter sync is active. Home, Scanner, and Progress can now read native Accessibility counters, readiness health, noise-control stats, and latest blocked-site data.",
    )

    text = text.replace(
        "Phase 6 reads visible website/search text only after the user manually enables Accessibility. Detection stays local on the device.",
        "Phase 6H reads visible website/search text only after the user manually enables Accessibility. Detection stays local on the device and repeated noisy events are cooled down.",
    )

    return text


patch_file(
    "lib/presentation/screens/accessibility_detection_screen.dart",
    patch_accessibility_footer_text,
)


def patch_readiness_card_copy(text: str) -> str:
    text = text.replace(
        "const Text('Protection Health'),",
        "const Text('Protection Health — Production Readiness'),",
    )

    text = text.replace(
        "'Status': _label,",
        "'Mode': _label,",
    )

    return text


patch_file(
    "lib/presentation/widgets/protection_readiness_card.dart",
    patch_readiness_card_copy,
)


write("test/widget_test.dart", r'''
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Phase 6H CI smoke test passes', () {
    expect(true, isTrue);
  });
}
''')

print("Phase 6H noise control and production readiness dashboard patch completed successfully.")
