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
import org.json.JSONObject
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
    private const val KEY_LAST_DOMAIN = "last_domain"
    private const val KEY_LAST_CATEGORY = "last_category"
    private const val KEY_LAST_DECISION = "last_decision"
    private const val KEY_LAST_SCORE = "last_score"
    private const val KEY_LAST_CONFIDENCE = "last_confidence"
    private const val KEY_LAST_SIGNALS = "last_signals"
    private const val KEY_LAST_DETECTED_AT = "last_detected_at"
    private const val KEY_LAST_PACKAGE = "last_package"

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

    fun recordVisibleText(
        context: Context,
        visibleText: String,
        sourcePackage: String
    ): AccessibilityClassification? {
        val domain = extractDomain(visibleText) ?: return null
        val classification = classify(domain)

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
            .apply()

        return classification
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

        return mapOf(
            "events" to prefs.getInt(KEY_EVENTS, 0),
            "websitesScanned" to prefs.getInt(KEY_WEBSITES_SCANNED, 0),
            "newWebsitesScanned" to prefs.getInt(KEY_NEW_WEBSITES_SCANNED, 0),
            "blockedDetections" to prefs.getInt(KEY_BLOCKED_DETECTIONS, 0),
            "unknownDetections" to prefs.getInt(KEY_UNKNOWN_DETECTIONS, 0),
            "lastDomain" to (prefs.getString(KEY_LAST_DOMAIN, "") ?: ""),
            "lastCategory" to (prefs.getString(KEY_LAST_CATEGORY, "") ?: ""),
            "lastDecision" to (prefs.getString(KEY_LAST_DECISION, "") ?: ""),
            "lastScore" to prefs.getInt(KEY_LAST_SCORE, 0),
            "lastConfidence" to prefs.getInt(KEY_LAST_CONFIDENCE, 0),
            "lastSignals" to signals,
            "lastDetectedAt" to prefs.getLong(KEY_LAST_DETECTED_AT, 0L),
            "lastPackage" to (prefs.getString(KEY_LAST_PACKAGE, "") ?: ""),
            "mode" to "accessibility_local_detection"
        )
    }

    fun reset(context: Context) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .clear()
            .apply()
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

    private fun classify(domain: String): AccessibilityClassification {
        val signals = mutableListOf<String>()
        var score = 0
        var category = "unknown"

        val savedBlocklist = listOf(
            "blocked-example.com",
            "unsafe-example.com",
            "risk-example.com"
        )

        if (savedBlocklist.any { domain == it || domain.endsWith(".$it") }) {
            score += 95
            category = "saved-blocklist"
            signals.add("Matched saved blocklist")
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

        if (joined.contains("saved blocklist")) return "saved-blocklist"
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
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class FocusShieldAccessibilityService : AccessibilityService() {
    private var lastDetectedDomain: String = ""
    private var lastDetectionAt: Long = 0L

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
        val isDuplicate = classification.domain == lastDetectedDomain &&
            now - lastDetectionAt < duplicateWindowMs

        if (isDuplicate) return

        lastDetectedDomain = classification.domain
        lastDetectionAt = now

        if (classification.shouldOpenApp) {
            openFocusShield(classification)
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
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("phase6_accessibility_domain", classification.domain)
            putExtra("phase6_accessibility_category", classification.category)
            putExtra("phase6_accessibility_decision", classification.decision)
            putExtra("phase6_accessibility_score", classification.score)
        }

        try {
            startActivity(intent)
        } catch (_: Exception) {
            // If Android blocks launch, the detection is still saved locally.
        }
    }
}
''')

write("android/app/src/main/res/xml/focus_shield_accessibility_service.xml", r'''
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged|typeWindowContentChanged|typeViewTextChanged|typeViewFocused"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:accessibilityFlags="flagReportViewIds"
    android:canRetrieveWindowContent="true"
    android:description="@string/app_name"
    android:notificationTimeout="150" />
''')

write("android/app/src/main/res/values/strings.xml", r'''
<resources>
    <string name="app_name">Focus Shield</string>
</resources>
''')

write("android/app/src/main/kotlin/com/example/focus_shield_android/MainActivity.kt", r'''
package com.example.focus_shield_android

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val protectionChannelName = "focus_shield/protection"

    private val blocklistStore: FocusShieldBlocklistStore by lazy {
        FocusShieldBlocklistStore(applicationContext)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            protectionChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startProtection" -> startProtection(result)
                "stopProtection" -> stopProtection(result)
                "protectionStatus" -> protectionStatus(result)
                "reloadBlocklist" -> reloadBlocklist(result)
                "prepareLiveObservation" -> prepareLiveObservation(result)
                "disableLiveObservation" -> disableLiveObservation(result)
                "openVpnSettings" -> openVpnSettings(result)
                "openAccessibilitySettings" -> openAccessibilitySettings(result)
                "requestLiveObservationUnlock" -> requestLiveObservationUnlock(result)
                "testDnsForwarder" -> testDnsForwarder(result)
                "accessibilityDetectionStatus" -> accessibilityDetectionStatus(result)
                "resetAccessibilityDetections" -> resetAccessibilityDetections(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun startProtection(result: MethodChannel.Result) {
        // Phase 3 VPN route capture stays paused so internet does not break.
        result.success("phase3_paused_vpn_route_capture_disabled")
    }

    private fun stopProtection(result: MethodChannel.Result) {
        val serviceIntent = Intent(this, FocusShieldVpnService::class.java).apply {
            action = FocusShieldVpnService.ACTION_STOP
        }
        startService(serviceIntent)
        result.success("stopped")
    }

    private fun protectionStatus(result: MethodChannel.Result) {
        val blocklistStatus = blocklistStore.status()
        val nativeStatus = FocusShieldProtectionStatus.build(blocklistStatus)
        result.success(nativeStatus.toMap())
    }

    private fun reloadBlocklist(result: MethodChannel.Result) {
        blocklistStore.status()
        result.success("blocklist_loaded")
    }

    private fun prepareLiveObservation(result: MethodChannel.Result) {
        val serviceIntent = Intent(this, FocusShieldVpnService::class.java).apply {
            action = FocusShieldVpnService.ACTION_PREPARE_LIVE_OBSERVATION
        }
        startService(serviceIntent)
        result.success("observation_prepared_locked")
    }

    private fun disableLiveObservation(result: MethodChannel.Result) {
        val serviceIntent = Intent(this, FocusShieldVpnService::class.java).apply {
            action = FocusShieldVpnService.ACTION_DISABLE_LIVE_OBSERVATION
        }
        startService(serviceIntent)
        result.success("observation_disabled")
    }

    private fun requestLiveObservationUnlock(result: MethodChannel.Result) {
        result.success("phase3_paused_unlock_not_required")
    }

    private fun testDnsForwarder(result: MethodChannel.Result) {
        Thread {
            val response = try {
                val success = FocusShieldDnsProxy.runForwarderDiagnostic()
                if (success) {
                    "dns_forwarder_diagnostic_success"
                } else {
                    "dns_forwarder_diagnostic_failed"
                }
            } catch (error: Exception) {
                "dns_forwarder_diagnostic_error:${error.javaClass.simpleName}"
            }

            runOnUiThread {
                result.success(response)
            }
        }.start()
    }

    private fun accessibilityDetectionStatus(result: MethodChannel.Result) {
        result.success(
            FocusShieldAccessibilityDetectionStore.status(applicationContext)
        )
    }

    private fun resetAccessibilityDetections(result: MethodChannel.Result) {
        FocusShieldAccessibilityDetectionStore.reset(applicationContext)
        result.success("accessibility_detections_reset")
    }

    private fun openVpnSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_VPN_SETTINGS)
            startActivity(intent)
            result.success("vpn_settings_opened")
        } catch (_: Exception) {
            result.success("vpn_settings_unavailable")
        }
    }

    private fun openAccessibilitySettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            startActivity(intent)
            result.success("accessibility_settings_opened")
        } catch (_: Exception) {
            result.success("accessibility_settings_unavailable")
        }
    }
}
''')

manifest_path = ROOT / "android/app/src/main/AndroidManifest.xml"
manifest_text = manifest_path.read_text(encoding="utf-8")

service_block = '''
        <service
            android:name=".FocusShieldAccessibilityService"
            android:exported="true"
            android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE">
            <intent-filter>
                <action android:name="android.accessibilityservice.AccessibilityService" />
            </intent-filter>
            <meta-data
                android:name="android.accessibilityservice"
                android:resource="@xml/focus_shield_accessibility_service" />
        </service>
'''

if "FocusShieldAccessibilityService" not in manifest_text:
    manifest_text = manifest_text.replace(
        "</application>",
        service_block + "\n    </application>",
    )
    manifest_path.write_text(manifest_text, encoding="utf-8")
    print("patched AndroidManifest.xml accessibility service")
  write("lib/platform/protection_channel.dart", r'''
import 'package:flutter/services.dart';

class ProtectionChannel {
  factory ProtectionChannel() {
    return _instance;
  }

  ProtectionChannel._internal();

  static final ProtectionChannel _instance = ProtectionChannel._internal();

  static const MethodChannel _channel = MethodChannel('focus_shield/protection');

  Future<String> _invokeString(String method) async {
    try {
      final result = await _channel.invokeMethod<String>(method);
      return result ?? 'no_response';
    } catch (error) {
      return 'error:${error.runtimeType}';
    }
  }

  Future<Map<String, dynamic>> _invokeMap(String method) async {
    try {
      final result = await _channel.invokeMethod<dynamic>(method);

      if (result is Map) {
        return result.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }

      return <String, dynamic>{
        'error': 'unexpected_response',
        'method': method,
      };
    } catch (error) {
      return <String, dynamic>{
        'error': error.runtimeType.toString(),
        'method': method,
      };
    }
  }

  Future<String> startProtection() async {
    return _invokeString('startProtection');
  }

  Future<String> stopProtection() async {
    return _invokeString('stopProtection');
  }

  Future<Map<String, dynamic>> protectionStatus() async {
    return _invokeMap('protectionStatus');
  }

  Future<String> reloadBlocklist() async {
    return _invokeString('reloadBlocklist');
  }

  Future<String> prepareLiveObservation() async {
    return _invokeString('prepareLiveObservation');
  }

  Future<String> disableLiveObservation() async {
    return _invokeString('disableLiveObservation');
  }

  Future<String> openVpnSettings() async {
    return _invokeString('openVpnSettings');
  }

  Future<String> openAccessibilitySettings() async {
    return _invokeString('openAccessibilitySettings');
  }

  Future<String> requestLiveObservationUnlock() async {
    return _invokeString('requestLiveObservationUnlock');
  }

  Future<String> testDnsForwarder() async {
    return _invokeString('testDnsForwarder');
  }

  Future<Map<String, dynamic>> accessibilityDetectionStatus() async {
    return _invokeMap('accessibilityDetectionStatus');
  }

  Future<String> resetAccessibilityDetections() async {
    return _invokeString('resetAccessibilityDetections');
  }
}
''')

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
  });

  final VoidCallback onBack;

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

  List<String> _signals() {
    final raw = _status['lastSignals'];

    if (raw is List) {
      return raw.map((item) => item.toString()).toList();
    }

    return <String>[];
  }

  @override
  Widget build(BuildContext context) {
    final signals = _signals();

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
              'Mode': _value('mode').isEmpty
                  ? 'Local'
                  : _value('mode').replaceAll('_', ' '),
              'Events': _value('events').isEmpty ? '0' : _value('events'),
              'Scanned': _value('websitesScanned').isEmpty
                  ? '0'
                  : _value('websitesScanned'),
              'New': _value('newWebsitesScanned').isEmpty
                  ? '0'
                  : _value('newWebsitesScanned'),
              'Blocked': _value('blockedDetections').isEmpty
                  ? '0'
                  : _value('blockedDetections'),
              'Unknown': _value('unknownDetections').isEmpty
                  ? '0'
                  : _value('unknownDetections'),
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Last detection'),
              const SizedBox(height: 8),
              if (_loading)
                const Text('Loading...')
              else ...[
                Text('Domain: ${_value('lastDomain').isEmpty ? '-' : _value('lastDomain')}'),
                Text('Decision: ${_value('lastDecision').isEmpty ? '-' : _value('lastDecision')}'),
                Text('Category: ${_value('lastCategory').isEmpty ? '-' : _value('lastCategory')}'),
                Text('Score: ${_value('lastScore').isEmpty ? '0' : _value('lastScore')}/100'),
                Text('Confidence: ${_value('lastConfidence').isEmpty ? '0' : _value('lastConfidence')}%'),
                Text('Package: ${_value('lastPackage').isEmpty ? '-' : _value('lastPackage')}'),
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
            'Phase 6 reads visible website/search text only after the user manually enables Accessibility. Detection stays local on the device.',
          ),
        ),
      ],
    );
  }
}
''')
def patch_settings_screen(text: str) -> str:
    if "this.onOpenAccessibilityDetection," not in text:
        text = text.replace(
            "this.onOpenAccessibilitySettings,",
            "this.onOpenAccessibilitySettings,\n    this.onOpenAccessibilityDetection,",
        )

    if "final VoidCallback? onOpenAccessibilityDetection;" not in text:
        text = text.replace(
            "final VoidCallback onOpenAccessibilitySettings;",
            "final VoidCallback onOpenAccessibilitySettings;\n"
            "  final VoidCallback? onOpenAccessibilityDetection;",
        )

    if "Accessibility Detection" not in text:
        text = text.replace(
            "ActionButton(\n                label: 'Open Accessibility Settings',",
            "ActionButton(\n"
            "                label: 'Accessibility Detection',\n"
            "                subtitle: 'Native website scan status',\n"
            "                onPressed: onOpenAccessibilityDetection ?? () {},\n"
            "              ),\n"
            "              const SizedBox(height: 10),\n"
            "              ActionButton(\n"
            "                label: 'Open Accessibility Settings',",
        )

    return text


patch_file("lib/presentation/screens/settings_screen.dart", patch_settings_screen)


def patch_app_dart(text: str) -> str:
    if "presentation/screens/accessibility_detection_screen.dart" not in text:
        text = text.replace(
            "import 'presentation/screens/coach_screen.dart';",
            "import 'presentation/screens/coach_screen.dart';\n"
            "import 'presentation/screens/accessibility_detection_screen.dart';",
        )

    if "bool _showAccessibilityDetection = false;" not in text:
        text = text.replace(
            "bool _showReflection = false;",
            "bool _showReflection = false;\n"
            "  bool _showAccessibilityDetection = false;",
        )

    if "_showAccessibilityDetection = false;" not in text:
        text = text.replace(
            "_showReflection = false;",
            "_showReflection = false;\n"
            "    _showAccessibilityDetection = false;",
            1,
        )

    if "void _openAccessibilityDetection()" not in text:
        marker = """  void _openReflection() {
    setState(() {
      _hideOverlays();
      _showReflection = true;
    });
  }"""

        replacement = """  void _openReflection() {
    setState(() {
      _hideOverlays();
      _showReflection = true;
    });
  }

  void _openAccessibilityDetection() {
    setState(() {
      _hideOverlays();
      _showAccessibilityDetection = true;
    });
  }

  void _closeAccessibilityDetection() {
    setState(() {
      _showAccessibilityDetection = false;
      _selectedIndex = 5;
    });
  }"""

        text = text.replace(marker, replacement)

    if "_showAccessibilityDetection)" not in text:
        marker = """    } else if (_showReflection) {
      overlay = ReflectionScreen(
        onBack: _closeDisciplineTool,
        onSaved: _completeReflection,
        lastReflectionText: _state.lastReflectionText,
      );
    }"""

        replacement = """    } else if (_showReflection) {
      overlay = ReflectionScreen(
        onBack: _closeDisciplineTool,
        onSaved: _completeReflection,
        lastReflectionText: _state.lastReflectionText,
      );
    } else if (_showAccessibilityDetection) {
      overlay = AccessibilityDetectionScreen(
        onBack: _closeAccessibilityDetection,
      );
    }"""

        text = text.replace(marker, replacement)

    if "onOpenAccessibilityDetection: _openAccessibilityDetection," not in text:
        text = text.replace(
            "onOpenAccessibilitySettings: _openAccessibilitySettings,",
            "onOpenAccessibilitySettings: _openAccessibilitySettings,\n"
            "        onOpenAccessibilityDetection: _openAccessibilityDetection,",
        )

    return text


patch_file("lib/app.dart", patch_app_dart)

print("Phase 6 accessibility detection patch completed successfully.")
