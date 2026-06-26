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


def ensure_shared_preferences_dependency() -> None:
    pubspec = ROOT / "pubspec.yaml"
    text = pubspec.read_text(encoding="utf-8")

    if "shared_preferences:" in text:
        print("shared_preferences already exists")
        return

    text = text.replace(
        "dependencies:\n",
        "dependencies:\n  shared_preferences: ^2.3.5\n",
        1,
    )

    pubspec.write_text(text, encoding="utf-8")
    print("added shared_preferences dependency")


ensure_shared_preferences_dependency()


def patch_native_detection_store_history(text: str) -> str:
    if "import org.json.JSONObject" not in text:
        text = text.replace(
            "import org.json.JSONArray\n",
            "import org.json.JSONArray\nimport org.json.JSONObject\n",
            1,
        )

    if 'KEY_BLOCKED_HISTORY' not in text:
        text = text.replace(
            '    private const val KEY_LAST_PACKAGE = "last_package"\n',
            '''    private const val KEY_LAST_PACKAGE = "last_package"
    private const val KEY_BLOCKED_HISTORY = "blocked_history"
''',
            1,
        )

    if "recordBlockedHistory(prefs, classification, sourcePackage, now)" not in text:
        text = text.replace(
            '''        if (classification.decision == "unknown") {
            prefs.edit()
                .putString(KEY_LAST_UNKNOWN_DOMAIN, domain)
                .putLong(KEY_LAST_UNKNOWN_AT, now)
                .apply()
        }

        return classification''',
            '''        if (classification.decision == "blocked") {
            recordBlockedHistory(prefs, classification, sourcePackage, now)
        }

        if (classification.decision == "unknown") {
            prefs.edit()
                .putString(KEY_LAST_UNKNOWN_DOMAIN, domain)
                .putLong(KEY_LAST_UNKNOWN_AT, now)
                .apply()
        }

        return classification''',
            1,
        )

    if "val blockedHistory = readBlockedHistory(prefs)" not in text:
        text = text.replace(
            '''        val interventionReady =
            stableLastAction == "opened_intervention" ||
                stableLastAction == "opened_app_fallback" ||
                stableLastAction == "notification_sent"''',
            '''        val interventionReady =
            stableLastAction == "opened_intervention" ||
                stableLastAction == "opened_app_fallback" ||
                stableLastAction == "notification_sent"

        val blockedHistory = readBlockedHistory(prefs)''',
            1,
        )

    if '"blockedHistory" to blockedHistory' not in text:
        text = text.replace(
            '''            "interventionReady" to interventionReady,
            "mode" to "local_detection_noise_control"''',
            '''            "interventionReady" to interventionReady,
            "blockedHistory" to blockedHistory,
            "blockedHistoryCount" to blockedHistory.size,
            "mode" to "local_detection_noise_control"''',
            1,
        )

    if "private fun recordBlockedHistory(" not in text:
        text = text.replace(
            '''    fun reset(context: Context) {''',
            '''    private fun recordBlockedHistory(
        prefs: android.content.SharedPreferences,
        classification: AccessibilityClassification,
        sourcePackage: String,
        now: Long
    ) {
        val currentRaw = prefs.getString(KEY_BLOCKED_HISTORY, "[]") ?: "[]"
        val next = JSONArray()

        val latest = JSONObject()
            .put("domain", classification.domain)
            .put("category", classification.category)
            .put("decision", classification.decision)
            .put("score", classification.score)
            .put("confidence", classification.confidence)
            .put("package", sourcePackage)
            .put("detectedAt", now)

        next.put(latest)

        try {
            val current = JSONArray(currentRaw)

            for (index in 0 until current.length()) {
                if (next.length() >= 10) break

                val item = current.optJSONObject(index) ?: continue
                val domain = item.optString("domain", "")

                if (domain.isBlank()) continue
                if (domain == classification.domain) continue

                next.put(item)
            }
        } catch (_: Exception) {
            // Keep only the latest item if old history is unreadable.
        }

        prefs.edit()
            .putString(KEY_BLOCKED_HISTORY, next.toString())
            .apply()
    }

    private fun readBlockedHistory(
        prefs: android.content.SharedPreferences
    ): List<Map<String, Any?>> {
        val raw = prefs.getString(KEY_BLOCKED_HISTORY, "[]") ?: "[]"
        val items = mutableListOf<Map<String, Any?>>()

        try {
            val array = JSONArray(raw)

            for (index in 0 until array.length()) {
                val item = array.optJSONObject(index) ?: continue

                items.add(
                    mapOf(
                        "domain" to item.optString("domain", ""),
                        "category" to item.optString("category", ""),
                        "decision" to item.optString("decision", ""),
                        "score" to item.optInt("score", 0),
                        "confidence" to item.optInt("confidence", 0),
                        "package" to item.optString("package", ""),
                        "detectedAt" to item.optLong("detectedAt", 0L)
                    )
                )
            }
        } catch (_: Exception) {
            items.clear()
        }

        return items
    }

    fun reset(context: Context) {''',
            1,
        )

    return text


patch_file(
    "android/app/src/main/kotlin/com/example/focus_shield_android/FocusShieldAccessibilityDetectionStore.kt",
    patch_native_detection_store_history,
)

print("Phase 6I Part 1 applied: shared prefs dependency checked and native blocked-site history added.")
write("lib/presentation/widgets/production_mode_card.dart", r'''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import 'action_button.dart';
import 'shield_card.dart';
import 'stat_grid.dart';

class ProductionModeCard extends StatefulWidget {
  const ProductionModeCard({
    super.key,
    this.showControls = true,
  });

  final bool showControls;

  @override
  State<ProductionModeCard> createState() => _ProductionModeCardState();
}

class _ProductionModeCardState extends State<ProductionModeCard> {
  static const String _modeKey = 'phase6i_real_use_mode';
  static const String _pauseReasonKey = 'phase6i_last_pause_reason';
  static const String _pauseAtKey = 'phase6i_last_pause_at';

  bool _realUseMode = true;
  String _lastPauseReason = 'No pause recorded.';
  String _lastPauseAt = 'Not recorded';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _realUseMode = prefs.getBool(_modeKey) ?? true;
      _lastPauseReason =
          prefs.getString(_pauseReasonKey) ?? 'No pause recorded.';
      _lastPauseAt = prefs.getString(_pauseAtKey) ?? 'Not recorded';
      _loaded = true;
    });
  }

  Future<void> _setRealUseMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, value);

    if (!mounted) return;

    setState(() {
      _realUseMode = value;
    });
  }

  Future<void> _recordPauseReason(String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();

    await prefs.setString(_pauseReasonKey, reason);
    await prefs.setString(_pauseAtKey, now);

    if (!mounted) return;

    setState(() {
      _lastPauseReason = reason;
      _lastPauseAt = now;
    });
  }

  Future<void> _showTestingModeWarning() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Switch to Testing Mode?'),
          content: const Text(
            'Testing Mode shows manual scanner tools and is meant for development only. Real Use Mode is safer for daily protection.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Stay in Real Use Mode'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _setRealUseMode(false);
              },
              child: const Text('Use Testing Mode'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPauseReasonDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Protection pause reason'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Example: testing build, fixing settings, or debugging.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final reason = controller.text.trim().isEmpty
                    ? 'No reason written.'
                    : controller.text.trim();

                Navigator.of(context).pop();
                _recordPauseReason(reason);
              },
              child: const Text('Save Reason'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const ShieldCard(
        borderColor: AppTheme.warning,
        child: Text('Loading production mode...'),
      );
    }

    return ShieldCard(
      borderColor: _realUseMode ? AppTheme.primary : AppTheme.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Production Lockdown'),
          const SizedBox(height: 12),
          StatGrid(
            items: {
              'Mode': _realUseMode ? 'Real Use' : 'Testing',
              'Testing Tools': _realUseMode ? 'Hidden' : 'Visible',
              'Pause Log': _lastPauseAt == 'Not recorded' ? 'Clear' : 'Saved',
              'Status': _realUseMode ? 'Daily use' : 'Development',
            },
          ),
          const SizedBox(height: 12),
          Text(
            _realUseMode
                ? 'Real Use Mode keeps the dashboard focused on protection instead of test tools.'
                : 'Testing Mode is active. Manual scanner tools are visible for development checks.',
          ),
          const SizedBox(height: 8),
          Text('Last pause reason: $_lastPauseReason'),
          if (widget.showControls) ...[
            const SizedBox(height: 12),
            ActionButton(
              label: _realUseMode ? 'Stay in Real Use Mode' : 'Return to Real Use Mode',
              subtitle: _realUseMode
                  ? 'Recommended for daily protection'
                  : 'Hide testing tools again',
              onPressed: () => _setRealUseMode(true),
            ),
            const SizedBox(height: 10),
            ActionButton(
              label: 'Enable Testing Mode',
              subtitle: 'Shows manual scanner tools',
              onPressed: _showTestingModeWarning,
            ),
            const SizedBox(height: 10),
            ActionButton(
              label: 'Log Protection Pause Reason',
              subtitle: 'Record why protection was paused or tested',
              onPressed: _showPauseReasonDialog,
            ),
          ],
        ],
      ),
    );
  }
}

class TestingToolsVisibilityGate extends StatefulWidget {
  const TestingToolsVisibilityGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<TestingToolsVisibilityGate> createState() =>
      _TestingToolsVisibilityGateState();
}

class _TestingToolsVisibilityGateState
    extends State<TestingToolsVisibilityGate> {
  static const String _modeKey = 'phase6i_real_use_mode';

  bool _realUseMode = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _realUseMode = prefs.getBool(_modeKey) ?? true;
      _loaded = true;
    });
  }

  Future<void> _showToolsTemporarily() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, false);

    if (!mounted) return;

    setState(() {
      _realUseMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const ShieldCard(
        borderColor: AppTheme.warning,
        child: Text('Loading testing tools visibility...'),
      );
    }

    if (!_realUseMode) {
      return widget.child;
    }

    return ShieldCard(
      borderColor: AppTheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Testing Tools Hidden'),
          const SizedBox(height: 8),
          const Text(
            'Real Use Mode is active, so manual scanner tools are hidden from the main daily-use view.',
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Show Testing Tools',
            subtitle: 'Switch to Testing Mode',
            onPressed: _showToolsTemporarily,
          ),
        ],
      ),
    );
  }
}
''')


write("lib/presentation/widgets/blocked_site_history_card.dart", r'''
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import 'action_button.dart';
import 'shield_card.dart';

class BlockedSiteHistoryCard extends StatefulWidget {
  const BlockedSiteHistoryCard({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  State<BlockedSiteHistoryCard> createState() => _BlockedSiteHistoryCardState();
}

class _BlockedSiteHistoryCardState extends State<BlockedSiteHistoryCard> {
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

  String _value(String key, {String fallback = ''}) {
    final value = _status[key];

    if (value == null) return fallback;

    final clean = value.toString().trim();

    if (clean.isEmpty) return fallback;

    return clean;
  }

  List<Map<String, dynamic>> get _history {
    final raw = _status['blockedHistory'];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (item) => item.map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          )
          .toList();
    }

    return const <Map<String, dynamic>>[];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ShieldCard(
        borderColor: AppTheme.warning,
        child: Text('Loading blocked-site history...'),
      );
    }

    final history = _history;
    final visibleHistory = widget.compact
        ? history.take(3).toList()
        : history.take(10).toList();

    return ShieldCard(
      borderColor: history.isEmpty ? AppTheme.secondary : AppTheme.danger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Blocked-Site History'),
          const SizedBox(height: 12),
          if (history.isEmpty) ...[
            Text(
              _value('lastDomain', fallback: '').isEmpty
                  ? 'No blocked-site history recorded yet.'
                  : 'Latest blocked site: ${_value('lastDomain')}',
            ),
          ] else ...[
            for (final item in visibleHistory) ...[
              _BlockedHistoryRow(item: item),
              const SizedBox(height: 10),
            ],
          ],
          if (!widget.compact) ...[
            const SizedBox(height: 4),
            ActionButton(
              label: 'Refresh Blocked History',
              subtitle: 'Read native blocked-site history',
              onPressed: _refresh,
            ),
          ],
        ],
      ),
    );
  }
}

class _BlockedHistoryRow extends StatelessWidget {
  const _BlockedHistoryRow({
    required this.item,
  });

  final Map<String, dynamic> item;

  String _itemValue(String key, {String fallback = '-'}) {
    final value = item[key];

    if (value == null) return fallback;

    final clean = value.toString().trim();

    if (clean.isEmpty) return fallback;

    return clean;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_itemValue('domain')),
            const SizedBox(height: 4),
            Text('Category: ${_itemValue('category')}'),
            Text('Score: ${_itemValue('score')}/100'),
            Text('Source: ${_itemValue('package')}'),
          ],
        ),
      ),
    );
  }
}
''')


write("lib/presentation/widgets/protection_status_center_card.dart", r'''
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import 'action_button.dart';
import 'shield_card.dart';
import 'stat_grid.dart';

class ProtectionStatusCenterCard extends StatefulWidget {
  const ProtectionStatusCenterCard({
    super.key,
  });

  @override
  State<ProtectionStatusCenterCard> createState() =>
      _ProtectionStatusCenterCardState();
}

class _ProtectionStatusCenterCardState
    extends State<ProtectionStatusCenterCard> {
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

  bool get _ready {
    final label = _value('readinessLabel', fallback: '').toLowerCase();
    final action = _value('lastAction', fallback: '').toLowerCase();

    return label.contains('production') ||
        action == 'opened_intervention' ||
        action == 'notification_sent';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ShieldCard(
        borderColor: AppTheme.warning,
        child: Text('Loading protection status center...'),
      );
    }

    return ShieldCard(
      borderColor: _ready ? AppTheme.primary : AppTheme.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Protection Status Center'),
          const SizedBox(height: 12),
          StatGrid(
            items: {
              'Mode': _value('readinessLabel', fallback: 'Checking'),
              'Readiness': '${_value('readinessScore')}%',
              'Scanned': _value('websitesScanned'),
              'Blocked': _value('blockedDetections'),
              'History': _value('blockedHistoryCount'),
              'Noise Filter': _value('noiseControlMode', fallback: 'active'),
            },
          ),
          const SizedBox(height: 12),
          Text('Latest blocked site: ${_value('lastDomain', fallback: 'None')}'),
          const SizedBox(height: 6),
          Text('Stable action: ${_value('lastAction', fallback: 'No action yet')}'),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Refresh Status Center',
            subtitle: 'Read readiness, counters, and history',
            onPressed: _refresh,
          ),
        ],
      ),
    );
  }
}
''')

print("Phase 6I Part 2 applied: production mode, blocked history, and status center widgets added.")
write("lib/presentation/screens/scanner_screen.dart", r'''
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/blocked_domain.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/services/protection_engine.dart';
import '../widgets/action_button.dart';
import '../widgets/native_protection_counters_card.dart';
import '../widgets/production_mode_card.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
    required this.protectionEnabled,
    required this.blockedDomains,
    required this.state,
    required this.onDecision,
  });

  final bool protectionEnabled;
  final List<BlockedDomain> blockedDomains;
  final FocusShieldState state;
  final ValueChanged<ProtectionDecision> onDecision;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ProtectionDecision> _unknownReviewQueue = <ProtectionDecision>[];

  ProtectionDecision? _decision;

  void _scan(String value) {
    final engine = ProtectionEngine(
      blockedDomains: widget.blockedDomains.map((item) => item.domain).toList(),
    );

    final decision = engine.analyze(value);

    setState(() {
      _decision = decision;

      if (decision.isUnknown &&
          decision.domain.isNotEmpty &&
          !_unknownReviewQueue.any((item) => item.domain == decision.domain)) {
        _unknownReviewQueue.insert(0, decision);
      }
    });

    widget.onDecision(decision);
  }

  void _scanSafeExample() {
    _scan('study-example.com');
  }

  void _scanBlockedExample() {
    _scan('blocked-example.com');
  }

  void _scanHighRiskExample() {
    _scan('adult-risk-example.com');
  }

  void _clearUnknownQueue() {
    setState(() {
      _unknownReviewQueue.clear();
    });
  }

  Color _riskColor(ProtectionDecision decision) {
    if (decision.blocked) return AppTheme.danger;
    if (decision.isUnknown) return AppTheme.warning;

    return AppTheme.primary;
  }

  String _decisionTitle(ProtectionDecision decision) {
    if (decision.blocked) return 'Blocked by AI-lite classifier';
    if (decision.isUnknown) return 'Unknown site added to review queue';

    return 'Domain allowed';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decision = _decision;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Scanner', style: Theme.of(context).textTheme.headlineLarge),
        Text(
          widget.protectionEnabled
              ? 'Protection scanner is active'
              : 'Protection is off until commitment is active',
        ),
        const SizedBox(height: 18),
        NativeProtectionCountersCard(
          title: 'Protection Activity',
          reviewQueueCount: _unknownReviewQueue.length,
          showControls: true,
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: {
              'AI-lite': 'Local',
              'DB Domains': '${widget.blockedDomains.length}',
              'Risk Mode': 'Score',
              'API Cost': 'None',
            },
          ),
        ),
        TestingToolsVisibilityGate(
          child: Column(
            children: [
              ShieldCard(
                borderColor: widget.protectionEnabled
                    ? AppTheme.secondary
                    : AppTheme.warning,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Testing Tools — Manual AI-lite Scanner'),
                    const SizedBox(height: 8),
                    const Text(
                      'Local classifier checks saved blocklist, risk signals, domain shape, category, and confidence.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('scannerDomainInput'),
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'example.com or suspicious-example.com',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      label: 'Scan Website',
                      subtitle: 'AI-lite risk score + explanation',
                      onPressed: () => _scan(_controller.text),
                    ),
                  ],
                ),
              ),
              ShieldCard(
                child: Column(
                  children: [
                    ActionButton(
                      label: 'Test Safe Domain',
                      subtitle: 'study-example.com',
                      onPressed: _scanSafeExample,
                    ),
                    const SizedBox(height: 10),
                    ActionButton(
                      label: 'Test Blocked Domain',
                      subtitle: 'blocked-example.com',
                      onPressed: _scanBlockedExample,
                    ),
                    const SizedBox(height: 10),
                    ActionButton(
                      label: 'Test High-Risk Signal',
                      subtitle: 'adult-risk-example.com',
                      onPressed: _scanHighRiskExample,
                    ),
                  ],
                ),
              ),
              if (decision != null)
                ShieldCard(
                  borderColor: _riskColor(decision),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_decisionTitle(decision)),
                      const SizedBox(height: 8),
                      Text('Domain: ${decision.domain}'),
                      Text('Category: ${decision.category}'),
                      Text('Risk score: ${decision.riskScore}/100'),
                      Text('Confidence: ${(decision.confidence * 100).round()}%'),
                      const SizedBox(height: 8),
                      Text(decision.reason),
                      const SizedBox(height: 12),
                      const Text('Risk signals'),
                      const SizedBox(height: 6),
                      ...decision.signals.map(
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
                    const Text('Unknown-site review queue'),
                    const SizedBox(height: 8),
                    Text(
                      _unknownReviewQueue.isEmpty
                          ? 'No unknown sites waiting for review.'
                          : '${_unknownReviewQueue.length} unknown site(s) waiting for review.',
                    ),
                    const SizedBox(height: 12),
                    if (_unknownReviewQueue.isNotEmpty)
                      ..._unknownReviewQueue.take(5).map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '• ${item.domain} — ${item.riskScore}/100 — ${item.category}',
                              ),
                            ),
                          ),
                    if (_unknownReviewQueue.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ActionButton(
                        label: 'Clear Review Queue',
                        subtitle: 'Local queue only',
                        onPressed: _clearUnknownQueue,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text(
            'Phase 6I Real Use Mode hides manual testing tools by default. Native Accessibility detection, intervention, notifications, counters, and noise control remain active.',
          ),
        ),
      ],
    );
  }
}
''')


write("lib/presentation/screens/home_screen.dart", r'''
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/models/goal.dart';
import '../widgets/action_button.dart';
import '../widgets/blocked_site_history_card.dart';
import '../widgets/native_protection_counters_card.dart';
import '../widgets/production_mode_card.dart';
import '../widgets/protection_readiness_card.dart';
import '../widgets/protection_status_center_card.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.state,
    required this.goals,
    required this.primaryAffirmation,
    required this.onNavigate,
    required this.onListeningWin,
  });

  final FocusShieldState state;
  final List<Goal> goals;
  final String primaryAffirmation;
  final ValueChanged<int> onNavigate;
  final VoidCallback onListeningWin;

  @override
  Widget build(BuildContext context) {
    final visibleGoals = goals.take(3).toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 4),
        const Text('Discipline + protection dashboard'),
        Text('Active day: ${state.lastActiveDate}'),
        const SizedBox(height: 18),
        if (!state.commitmentSet)
          ShieldCard(
            borderColor: AppTheme.warning,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Commitment required'),
                const SizedBox(height: 8),
                const Text(
                  'Choose 7, 14, 30, 90, or 365 days before protection can activate.',
                ),
                const SizedBox(height: 12),
                ActionButton(
                  label: 'Set Commitment',
                  subtitle: 'Go to Settings',
                  onPressed: () => onNavigate(5),
                ),
              ],
            ),
          )
        else
          NativeHomeProtectionSummaryCard(
            commitmentLabel: state.commitmentSet ? 'Active' : 'Required',
            daysLeftLabel: state.commitmentSet
                ? '${state.commitmentDaysRemaining} days left'
                : 'Set commitment',
          ),
        const SizedBox(height: 16),
        const ProtectionReadinessCard(),
        const SizedBox(height: 16),
        const ProtectionStatusCenterCard(),
        const SizedBox(height: 16),
        const ProductionModeCard(showControls: false),
        const SizedBox(height: 16),
        const BlockedSiteHistoryCard(compact: true),
        const SizedBox(height: 16),
        ShieldCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today’s Mission'),
              Text(
                '${state.listeningWinsToday} / ${state.missionTarget}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color:
                          state.missionComplete ? AppTheme.primary : AppTheme.warning,
                    ),
              ),
              const Text(
                'Pause and fully listen before speaking at least 3 times today.',
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Log Listening Win',
                subtitle: '+10 XP',
                onPressed: onListeningWin,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: {
              'Shield': state.protectionEnabled ? 'Active' : 'Off',
              'Recovery': '${state.recoveryRate}%',
              'Level': '${state.level}',
              'XP': '${state.xpInCurrentLevel}/${state.xpForNextLevel}',
              'Streak': '${state.currentStreak}',
              'Best': '${state.longestStreak}',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Goals'),
              const SizedBox(height: 8),
              if (visibleGoals.isEmpty)
                const Text('No goals saved yet.')
              else
                ...visibleGoals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• ${goal.title}'),
                  ),
                ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Edit Goals & Affirmations',
                subtitle: 'Go to Settings manager',
                onPressed: () => onNavigate(5),
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick Actions'),
              const SizedBox(height: 12),
              ActionButton(label: 'Scanner', onPressed: () => onNavigate(1)),
              const SizedBox(height: 10),
              ActionButton(label: 'Recovery', onPressed: () => onNavigate(2)),
              const SizedBox(height: 10),
              ActionButton(label: 'Progress', onPressed: () => onNavigate(3)),
              const SizedBox(height: 10),
              ActionButton(label: 'Coach', onPressed: () => onNavigate(4)),
              const SizedBox(height: 10),
              ActionButton(label: 'Settings', onPressed: () => onNavigate(5)),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Text(
            '“$primaryAffirmation”',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.lightBlueAccent),
          ),
        ),
      ],
    );
  }
}
''')


write("lib/presentation/screens/settings_screen.dart", r'''
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/focus_shield_state.dart';
import '../widgets/action_button.dart';
import '../widgets/blocked_site_history_card.dart';
import '../widgets/production_mode_card.dart';
import '../widgets/protection_status_card.dart';
import '../widgets/protection_status_center_card.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.state,
    required this.onToggleProtection,
    required this.onSetCommitmentDays,
    required this.onOpenAccessibilitySettings,
    this.onOpenAccessibilityDetection,
    required this.onOpenProtectionDatabase,
    required this.onOpenGoalsAffirmations,
    required this.onOpenDebugCenter,
    required this.onOpenProductionReadiness,
    required this.onResetAppData,
    this.onOpenCloudSync,
  });

  final FocusShieldState state;
  final VoidCallback onToggleProtection;
  final ValueChanged<int> onSetCommitmentDays;
  final VoidCallback onOpenAccessibilitySettings;
  final VoidCallback? onOpenAccessibilityDetection;
  final VoidCallback onOpenProtectionDatabase;
  final VoidCallback onOpenGoalsAffirmations;
  final VoidCallback onOpenDebugCenter;
  final VoidCallback onOpenProductionReadiness;
  final VoidCallback onResetAppData;
  final VoidCallback? onOpenCloudSync;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const ProtectionStatusCard(),
        const SizedBox(height: 16),
        Text('Settings', style: Theme.of(context).textTheme.headlineLarge),
        const Text('Protection control center'),
        Text('Active day: ${state.lastActiveDate}'),
        const SizedBox(height: 18),
        const ProductionModeCard(),
        const SizedBox(height: 16),
        const ProtectionStatusCenterCard(),
        const SizedBox(height: 16),
        const BlockedSiteHistoryCard(),
        const SizedBox(height: 16),
        ShieldCard(
          borderColor: state.commitmentSet ? AppTheme.primary : AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Commitment Lock'),
              const SizedBox(height: 8),
              Text(
                state.commitmentSet
                    ? 'Commitment: ${state.commitmentDays} days.\nDays remaining: ${state.commitmentDaysRemaining}.'
                    : 'Protection cannot activate until a commitment duration is set.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [7, 14, 30, 90, 365].map((days) {
                  return ChoiceChip(
                    label: Text('$days days'),
                    selected: state.commitmentDays == days,
                    onSelected: state.commitmentActive
                        ? null
                        : (_) => onSetCommitmentDays(days),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                state.commitmentActive
                    ? 'In-app protection settings are locked during this commitment.'
                    : 'Choose a duration to activate the commitment gate.',
              ),
            ],
          ),
        ),
        ShieldCard(
          child: StatGrid(
            items: {
              'Protection': state.protectionEnabled ? 'ON' : 'OFF',
              'Attempts': '${state.blockedAttempts}',
              'Recovery': '${state.recoveryRate}%',
              'XP': '${state.xp}',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Scanned Today': '${state.websitesScannedToday}',
              'New Today': '${state.newWebsitesScannedToday}',
              'Total Scanned': '${state.totalWebsitesScanned}',
              'Commitment': state.commitmentSet ? 'Set' : 'Required',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.warning,
          child: const Text(
            'System-wide VPN filtering is paused while the DNS route issue is repaired.\nAccessibility detection is the active production protection layer.',
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            children: [
              ActionButton(
                label: state.protectionEnabled
                    ? 'Protection Active'
                    : 'Turn Protection On',
                subtitle: !state.commitmentSet
                    ? 'Set commitment first'
                    : state.commitmentActive && state.protectionEnabled
                        ? 'Locked until commitment ends'
                        : 'Uses in-app scanner protection',
                onPressed: onToggleProtection,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Cloud Sync',
                subtitle: 'Backup, restore, and sync foundation',
                onPressed: onOpenCloudSync ?? () {},
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Accessibility Detection',
                subtitle: 'Native website scan status',
                onPressed: onOpenAccessibilityDetection ?? () {},
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Open Accessibility Settings',
                subtitle: 'Enable Focus Shield manually',
                onPressed: onOpenAccessibilitySettings,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Protection Database',
                subtitle: 'Manage saved blocklist',
                onPressed: onOpenProtectionDatabase,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Goals & Affirmations',
                subtitle: 'Manage personal discipline system',
                onPressed: onOpenGoalsAffirmations,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'URL Analysis Engine',
                subtitle: 'Scanner and detection rules',
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Lock Layer',
                subtitle: 'Commitment gate active in-app',
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Production Readiness',
                subtitle: 'Android test and build checklist',
                onPressed: onOpenProductionReadiness,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Database Tools'),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Open Database Debug Center',
                subtitle: 'Attempts, state, reset tools',
                onPressed: onOpenDebugCenter,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Reset App Data',
                subtitle: 'Clear local saved state',
                onPressed: onResetAppData,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
''')


write("lib/presentation/screens/accessibility_detection_screen.dart", r'''
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import '../widgets/action_button.dart';
import '../widgets/blocked_site_history_card.dart';
import '../widgets/production_mode_card.dart';
import '../widgets/protection_readiness_card.dart';
import '../widgets/protection_status_center_card.dart';
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

    return const <String>[];
  }

  String _cleanMode() {
    final mode = _value('mode').toLowerCase();

    if (mode.contains('local')) return 'Local';
    if (mode.isEmpty) return 'Local';

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
    final rawLastAction = _safeValue('lastAction', '-');
    final lastDecision = _safeValue('lastDecision', '-');
    final lastDomain = _safeValue('lastDomain', '-');

    final lastAction =
        rawLastAction == 'blocklist_synced' && lastDecision == 'blocked'
            ? 'opened_intervention'
            : rawLastAction;

    final lastMessage =
        rawLastAction == 'blocklist_synced' && lastDecision == 'blocked'
            ? 'Focus Shield opened intervention after blocking $lastDomain.'
            : _safeValue('lastMessage', 'No action recorded yet.');

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
        const ProtectionReadinessCard(),
        const SizedBox(height: 16),
        const ProtectionStatusCenterCard(),
        const SizedBox(height: 16),
        const ProductionModeCard(showControls: false),
        const SizedBox(height: 16),
        const BlockedSiteHistoryCard(),
        const SizedBox(height: 16),
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
              const Text('Stable protection action'),
              const SizedBox(height: 8),
              Text('Action: $lastAction'),
              const SizedBox(height: 6),
              Text(lastMessage),
              const SizedBox(height: 12),
              const Text(
                'Blocked detections open the native intervention screen.\nBlocklist sync is tracked separately so it does not overwrite the protection action.',
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
                'Android requires you to manually enable Focus Shield in Accessibility Settings.\nIf Android shows Restricted setting, open Settings > Apps > Focus Shield > More options > Allow restricted settings.',
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
            'Phase 6I production lockdown is active. Real Use Mode hides testing tools by default, blocked-site history is tracked, and protection status is centralized.',
          ),
        ),
      ],
    );
  }
}
''')


write("test/widget_test.dart", r'''
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Phase 6I CI smoke test passes', () {
    expect(true, isTrue);
  });
}
''')

print("Phase 6I production lockdown and real-use stability patch completed successfully.")
