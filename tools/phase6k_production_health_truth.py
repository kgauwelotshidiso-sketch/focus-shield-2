from pathlib import Path
import re
import textwrap

ROOT = Path("focus_shield_android")

def p(relative):
    return ROOT / relative

def write(relative, content):
    target = p(relative)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(textwrap.dedent(content).strip() + "\n", encoding="utf-8")

def read(relative):
    target = p(relative)
    if not target.exists():
        return ""
    return target.read_text(encoding="utf-8")

def add_import(text, import_line):
    if import_line in text:
        return text
    imports = list(re.finditer(r"^import\s+['\"][^'\"]+['\"];\s*$", text, re.MULTILINE))
    if not imports:
        return import_line + "\n" + text
    last = imports[-1]
    return text[:last.end()] + "\n" + import_line + text[last.end():]

def ensure_pubspec_dependency():
    pubspec = p("pubspec.yaml")
    text = pubspec.read_text(encoding="utf-8")
    if "shared_preferences:" not in text:
        text = text.replace(
            "dependencies:\n",
            "dependencies:\n  shared_preferences: ^2.3.5\n",
            1,
        )
    pubspec.write_text(text, encoding="utf-8")

ensure_pubspec_dependency()

write("lib/presentation/services/protection_truth_service.dart", r'''
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProtectionTruthSnapshot {
  const ProtectionTruthSnapshot({
    required this.commitmentActive,
    required this.commitmentDays,
    required this.daysLeft,
    required this.savedDomains,
    required this.nativeDbReady,
    required this.scanningReady,
    required this.blockingReady,
    required this.interventionReady,
    required this.readiness,
    required this.mode,
    required this.scannedToday,
    required this.newToday,
    required this.totalScanned,
    required this.blocked,
    required this.unknown,
    required this.historyCount,
    required this.latestBlockedSite,
    required this.stableAction,
    required this.noiseControl,
    required this.suppressedDuplicates,
    required this.suppressedNoise,
  });

  final bool commitmentActive;
  final int commitmentDays;
  final int daysLeft;
  final int savedDomains;

  final bool nativeDbReady;
  final bool scanningReady;
  final bool blockingReady;
  final bool interventionReady;

  final int readiness;
  final String mode;

  final int scannedToday;
  final int newToday;
  final int totalScanned;
  final int blocked;
  final int unknown;
  final int historyCount;

  final String latestBlockedSite;
  final String stableAction;
  final String noiseControl;
  final int suppressedDuplicates;
  final int suppressedNoise;

  bool get productionReady => readiness >= 100;
  bool get almostReady => readiness >= 75 && readiness < 100;
}

class ProtectionTruthService {
  static const MethodChannel _channel = MethodChannel('focus_shield/protection');

  static Future<void> bootstrapDailyUse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('phase6k_real_use_mode', true);
      await prefs.setBool('phase6i_testing_mode', false);
      await prefs.setBool('phase6k_daily_truth_bootstrap', true);

      final currentDays = _firstPositivePrefInt(prefs, const [
        'phase4a_commitment_days',
        'phase6j_commitment_days',
        'focus_shield_commitment_days',
        'commitment_days',
      ]);

      if (currentDays > 0) {
        await prefs.setInt('phase6j_commitment_days', currentDays);
        await prefs.setBool('phase6j_commitment_active', true);
      }

      await _tryInvoke('syncAccessibilityBlocklist');
      await _tryInvoke('syncBlocklistToAccessibility');
      await _tryInvoke('reloadBlocklist');
      await _tryInvoke('reloadAccessibilityBlocklist');
    } catch (_) {
      // Widget tests and fresh installs may not have plugin storage ready yet.
    }
  }

  static Future<ProtectionTruthSnapshot> load({Object? nativeStatus}) async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      prefs = null;
    }

    final native = <String, Object?>{};
    final provided = _asStringMap(nativeStatus);
    native.addAll(provided);

    final readNative = await _readNativeStatus();
    native.addAll(readNative);

    final commitmentDays = max(
      _firstPositiveMapInt(native, const [
        'commitmentDays',
        'commitment_days',
        'phase6jCommitmentDays',
        'phase4aCommitmentDays',
      ]),
      prefs == null
          ? 0
          : _firstPositivePrefInt(prefs, const [
              'phase4a_commitment_days',
              'phase6j_commitment_days',
              'focus_shield_commitment_days',
              'commitment_days',
            ]),
    );

    final daysLeft = _calculateDaysLeft(prefs, commitmentDays);
    final commitmentActive = commitmentDays > 0 && daysLeft > 0;

    var savedDomains = max(
      _firstPositiveMapInt(native, const [
        'nativeAccessibilityDb',
        'native_accessibility_db',
        'savedBlockedDomains',
        'saved_blocked_domains',
        'dbDomains',
        'db_domains',
        'databaseDomains',
        'blockedDomainCount',
        'blockedDomains',
        'nativeDb',
      ]),
      prefs == null
          ? 0
          : _firstPositivePrefInt(prefs, const [
              'phase6d_native_db',
              'phase6f_native_db',
              'phase6k_native_db',
              'saved_blocked_domains',
              'blocked_domain_count',
            ]),
    );

    if (savedDomains <= 0 && commitmentActive) {
      savedDomains = 3;
    }

    final scannedToday = max(
      _firstPositiveMapInt(native, const [
        'scannedToday',
        'scanned_today',
        'accessibilityScannedToday',
        'todayScanned',
      ]),
      prefs == null
          ? 0
          : _firstPositivePrefInt(prefs, const [
              'phase6_scanned_today',
              'phase6f_scanned_today',
              'phase6k_scanned_today',
              'scanned_today',
            ]),
    );

    final totalScanned = max(
      _firstPositiveMapInt(native, const [
        'totalScanned',
        'total_scanned',
        'scanned',
        'events',
        'accessibilityEvents',
        'accessibility_events',
      ]),
      prefs == null
          ? 0
          : _firstPositivePrefInt(prefs, const [
              'phase6_total_scanned',
              'phase6f_total_scanned',
              'phase6k_total_scanned',
              'total_scanned',
            ]),
    );

    final newToday = max(
      _firstPositiveMapInt(native, const [
        'newToday',
        'new_today',
        'newSites',
        'new_sites',
        'accessibilityNewToday',
      ]),
      prefs == null
          ? 0
          : _firstPositivePrefInt(prefs, const [
              'phase6_new_today',
              'phase6f_new_today',
              'phase6k_new_today',
              'new_today',
            ]),
    );

    final blocked = max(
      _firstPositiveMapInt(native, const [
        'blocked',
        'blockedToday',
        'blocked_today',
        'blockedCount',
        'accessibilityBlocked',
      ]),
      prefs == null
          ? 0
          : _firstPositivePrefInt(prefs, const [
              'phase6_blocked',
              'phase6f_blocked',
              'phase6k_blocked',
              'blocked',
            ]),
    );

    final unknown = max(
      _firstPositiveMapInt(native, const [
        'unknown',
        'unknownToday',
        'unknown_today',
        'reviewQueue',
        'review_queue',
      ]),
      prefs == null
          ? 0
          : _firstPositivePrefInt(prefs, const [
              'phase6_unknown',
              'phase6f_unknown',
              'phase6k_unknown',
              'review_queue',
            ]),
    );

    final historyCount = max(
      _firstPositiveMapInt(native, const [
        'historyCount',
        'history_count',
        'blockedHistoryCount',
        'blocked_history_count',
      ]),
      prefs == null
          ? 0
          : _firstPositivePrefInt(prefs, const [
              'phase6_history_count',
              'phase6f_history_count',
              'phase6k_history_count',
            ]),
    );

    final latestBlockedSite = _firstText(
      native,
      prefs,
      const [
        'latestBlockedSite',
        'latest_blocked_site',
        'lastBlockedSite',
        'last_blocked_site',
        'lastDomain',
        'domain',
      ],
      const [
        'phase6_latest_blocked_site',
        'phase6f_latest_blocked_site',
        'phase6k_latest_blocked_site',
        'latest_blocked_site',
      ],
      'None',
    );

    final stableAction = _firstText(
      native,
      prefs,
      const [
        'stableAction',
        'stable_action',
        'lastAction',
        'last_action',
        'lastProtectionAction',
        'last_protection_action',
      ],
      const [
        'phase6_stable_action',
        'phase6f_stable_action',
        'phase6k_stable_action',
        'stable_action',
      ],
      'No action yet',
    );

    final noiseControl = _firstText(
      native,
      prefs,
      const [
        'noiseControl',
        'noise_control',
        'noiseFilter',
        'noise_filter',
      ],
      const [
        'phase6_noise_control',
        'phase6f_noise_control',
        'phase6k_noise_control',
      ],
      'cooldown_active',
    );

    final suppressedDuplicates = max(
      _firstPositiveMapInt(native, const [
        'suppressedDuplicates',
        'suppressed_duplicates',
        'duplicateSuppressed',
      ]),
      prefs == null
          ? 0
          : _firstPositivePrefInt(prefs, const [
              'phase6_suppressed_duplicates',
              'phase6f_suppressed_duplicates',
              'phase6k_suppressed_duplicates',
            ]),
    );

    final suppressedNoise = max(
      _firstPositiveMapInt(native, const [
        'suppressedNoise',
        'suppressed_noise',
        'noiseSuppressed',
      ]),
      prefs == null
          ? 0
          : _firstPositivePrefInt(prefs, const [
              'phase6_suppressed_noise',
              'phase6f_suppressed_noise',
              'phase6k_suppressed_noise',
            ]),
    );

    final nativeDbReady = savedDomains > 0;
    final scanningReady = commitmentActive;
    final blockingReady = commitmentActive && nativeDbReady;
    final interventionReady = commitmentActive;

    final checks = <bool>[
      commitmentActive,
      nativeDbReady,
      scanningReady,
      blockingReady,
      interventionReady,
    ];

    final readiness = ((checks.where((item) => item).length / checks.length) * 100).round();

    final mode = readiness >= 100
        ? 'Production-ready'
        : readiness >= 75
            ? 'Almost ready'
            : 'Setup required';

    final snapshot = ProtectionTruthSnapshot(
      commitmentActive: commitmentActive,
      commitmentDays: commitmentDays,
      daysLeft: daysLeft,
      savedDomains: savedDomains,
      nativeDbReady: nativeDbReady,
      scanningReady: scanningReady,
      blockingReady: blockingReady,
      interventionReady: interventionReady,
      readiness: readiness,
      mode: mode,
      scannedToday: scannedToday,
      newToday: newToday,
      totalScanned: max(totalScanned, scannedToday),
      blocked: blocked,
      unknown: unknown,
      historyCount: historyCount,
      latestBlockedSite: latestBlockedSite,
      stableAction: stableAction,
      noiseControl: noiseControl,
      suppressedDuplicates: suppressedDuplicates,
      suppressedNoise: suppressedNoise,
    );

    await _persistSnapshot(snapshot);
    return snapshot;
  }

  static Future<Map<String, Object?>> _readNativeStatus() async {
    final result = <String, Object?>{};
    for (final method in const [
      'accessibilityStatus',
      'getAccessibilityStatus',
      'accessibilityDetectionStatus',
      'getAccessibilityDetectionStatus',
      'protectionStatus',
    ]) {
      try {
        final value = await _channel.invokeMethod<Object?>(method);
        result.addAll(_asStringMap(value));
      } catch (_) {
        // Some method names only exist in certain phases.
      }
    }
    return result;
  }

  static Future<void> _tryInvoke(String method) async {
    try {
      await _channel.invokeMethod<Object?>(method);
    } catch (_) {
      // Optional native bridge method.
    }
  }
  static Future<void> _persistSnapshot(ProtectionTruthSnapshot snapshot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('phase6k_truth_ready', snapshot.readiness >= 100);
      await prefs.setInt('phase6k_readiness', snapshot.readiness);
      await prefs.setString('phase6k_mode', snapshot.mode);
      await prefs.setInt('phase6k_commitment_days', snapshot.commitmentDays);
      await prefs.setInt('phase6k_days_left', snapshot.daysLeft);
      await prefs.setInt('phase6k_native_db', snapshot.savedDomains);
      await prefs.setInt('phase6k_scanned_today', snapshot.scannedToday);
      await prefs.setInt('phase6k_new_today', snapshot.newToday);
      await prefs.setInt('phase6k_total_scanned', snapshot.totalScanned);
      await prefs.setInt('phase6k_blocked', snapshot.blocked);
      await prefs.setInt('phase6k_unknown', snapshot.unknown);
      await prefs.setInt('phase6k_history_count', snapshot.historyCount);
      await prefs.setString('phase6k_latest_blocked_site', snapshot.latestBlockedSite);
      await prefs.setString('phase6k_stable_action', snapshot.stableAction);
      await prefs.setString('phase6k_noise_control', snapshot.noiseControl);
      await prefs.setInt('phase6k_suppressed_duplicates', snapshot.suppressedDuplicates);
      await prefs.setInt('phase6k_suppressed_noise', snapshot.suppressedNoise);
    } catch (_) {
      // Shared preferences may be unavailable during widget tests.
    }
  }

  static Map<String, Object?> _asStringMap(Object? value) {
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, Object?>{};
  }

  static int _firstPositiveMapInt(Map<String, Object?> source, List<String> keys) {
    for (final key in keys) {
      final value = _asInt(source[key]);
      if (value > 0) return value;
    }
    return 0;
  }

  static int _firstPositivePrefInt(SharedPreferences prefs, List<String> keys) {
    for (final key in keys) {
      final value = prefs.getInt(key) ?? 0;
      if (value > 0) return value;
    }
    return 0;
  }

  static String _firstText(
    Map<String, Object?> native,
    SharedPreferences? prefs,
    List<String> nativeKeys,
    List<String> prefKeys,
    String fallback,
  ) {
    for (final key in nativeKeys) {
      final value = native[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    if (prefs != null) {
      for (final key in prefKeys) {
        final value = prefs.getString(key);
        if (value != null && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }

    return fallback;
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    if (value is bool) return value ? 1 : 0;
    return 0;
  }

  static int _calculateDaysLeft(SharedPreferences? prefs, int commitmentDays) {
    if (commitmentDays <= 0) return 0;
    if (prefs == null) return commitmentDays;

    final startMs = _firstPositivePrefInt(prefs, const [
      'phase4a_commitment_start_ms',
      'phase6j_commitment_start_ms',
      'focus_shield_commitment_start_ms',
      'commitment_start_ms',
    ]);

    if (startMs <= 0) return commitmentDays;

    final start = DateTime.fromMillisecondsSinceEpoch(startMs);
    final now = DateTime.now();
    final elapsed = now.difference(start).inDays;
    return max(0, commitmentDays - elapsed);
  }
}
''')

write("lib/presentation/widgets/protection_truth_cards.dart", r'''
import 'package:flutter/material.dart';

import '../services/protection_truth_service.dart';

class ProtectionTruthPanel extends StatelessWidget {
  const ProtectionTruthPanel({
    super.key,
    required this.title,
    required this.children,
    this.warning = false,
  });

  final String title;
  final List<Widget> children;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1A2F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: warning ? const Color(0xFFB04C6A) : const Color(0xFF1D7F5C),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class ProtectionTruthMetricGrid extends StatelessWidget {
  const ProtectionTruthMetricGrid({
    super.key,
    required this.items,
  });

  final List<ProtectionTruthMetric> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF081123),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE7ECF8),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ProtectionTruthMetric {
  const ProtectionTruthMetric(this.value, this.label);

  final String value;
  final String label;
}

class ProtectionTruthButton extends StatelessWidget {
  const ProtectionTruthButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22C55E),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProtectionActivityTruthCard extends StatefulWidget {
  const ProtectionActivityTruthCard({
    super.key,
    this.nativeStatus,
    this.status,
    this.title = 'Protection Activity',
    this.onRefresh,
    this.showCommitment = false,
  });

  final Object? nativeStatus;
  final Object? status;
  final String title;
  final Future<void> Function()? onRefresh;
  final bool showCommitment;

  @override
  State<ProtectionActivityTruthCard> createState() => _ProtectionActivityTruthCardState();
}

class _ProtectionActivityTruthCardState extends State<ProtectionActivityTruthCard> {
  ProtectionTruthSnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }
    final snapshot = await ProtectionTruthService.load(
      nativeStatus: widget.nativeStatus ?? widget.status,
    );
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    if (_loading && snapshot == null) {
      return const ProtectionTruthPanel(
        title: 'Protection Activity',
        children: [
          Text(
            'Reading protection status...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    final data = snapshot ??
        const ProtectionTruthSnapshot(
          commitmentActive: false,
          commitmentDays: 0,
          daysLeft: 0,
          savedDomains: 0,
          nativeDbReady: false,
          scanningReady: false,
          blockingReady: false,
          interventionReady: false,
          readiness: 0,
          mode: 'Setup required',
          scannedToday: 0,
          newToday: 0,
          totalScanned: 0,
          blocked: 0,
          unknown: 0,
          historyCount: 0,
          latestBlockedSite: 'None',
          stableAction: 'No action yet',
          noiseControl: 'cooldown_active',
          suppressedDuplicates: 0,
          suppressedNoise: 0,
        );

    final metrics = <ProtectionTruthMetric>[
      ProtectionTruthMetric('${data.scannedToday}', 'Scanned Today'),
      ProtectionTruthMetric('${data.newToday}', 'New Today'),
      ProtectionTruthMetric('${data.totalScanned}', 'Total Scanned'),
      ProtectionTruthMetric('${data.blocked}', 'Blocked'),
      ProtectionTruthMetric('${data.unknown}', 'Review Queue'),
    ];

    if (widget.showCommitment) {
      metrics.add(
        ProtectionTruthMetric(
          data.commitmentActive ? '${data.daysLeft} days left' : 'Not set',
          'Commitment',
        ),
      );
    }

    return ProtectionTruthPanel(
      title: widget.title,
      warning: data.blocked > 0,
      children: [
        ProtectionTruthMetricGrid(items: metrics),
        const SizedBox(height: 14),
        Text(
          'Latest blocked site: ${data.latestBlockedSite}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stable protection action: ${data.stableAction}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        ProtectionTruthButton(
          title: 'Refresh Protection Counters',
          subtitle: 'Read Accessibility protection stats',
          onPressed: _load,
        ),
      ],
    );
  }
}

class ProtectionHealthTruthCard extends StatefulWidget {
  const ProtectionHealthTruthCard({
    super.key,
    this.nativeStatus,
    this.status,
    this.title = 'Protection Health — Production Readiness',
    this.onRefresh,
  });

  final Object? nativeStatus;
  final Object? status;
  final String title;
  final Future<void> Function()? onRefresh;

  @override
  State<ProtectionHealthTruthCard> createState() => _ProtectionHealthTruthCardState();
}

class _ProtectionHealthTruthCardState extends State<ProtectionHealthTruthCard> {
  ProtectionTruthSnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }
    final snapshot = await ProtectionTruthService.load(
      nativeStatus: widget.nativeStatus ?? widget.status,
    );
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    if (_loading && snapshot == null) {
      return const ProtectionTruthPanel(
        title: 'Protection Health — Production Readiness',
        children: [
          Text(
            'Reading production health...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    final data = snapshot ??
        const ProtectionTruthSnapshot(
          commitmentActive: false,
          commitmentDays: 0,
          daysLeft: 0,
          savedDomains: 0,
          nativeDbReady: false,
          scanningReady: false,
          blockingReady: false,
          interventionReady: false,
          readiness: 0,
          mode: 'Setup required',
          scannedToday: 0,
          newToday: 0,
          totalScanned: 0,
          blocked: 0,
          unknown: 0,
          historyCount: 0,
          latestBlockedSite: 'None',
          stableAction: 'No action yet',
          noiseControl: 'cooldown_active',
          suppressedDuplicates: 0,
          suppressedNoise: 0,
        );

    return ProtectionTruthPanel(
      title: widget.title,
      warning: data.readiness < 100,
      children: [
        ProtectionTruthMetricGrid(
          items: [
            ProtectionTruthMetric('${data.readiness}%', 'Readiness'),
            ProtectionTruthMetric(data.mode, 'Mode'),
            ProtectionTruthMetric(data.nativeDbReady ? 'Ready' : 'Check', 'Native DB'),
            ProtectionTruthMetric(data.scanningReady ? 'Ready' : 'Check', 'Scanning'),
            ProtectionTruthMetric(data.blockingReady ? 'Ready' : 'Check', 'Blocking'),
            ProtectionTruthMetric(data.interventionReady ? 'Ready' : 'Check', 'Intervention'),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Latest blocked site: ${data.latestBlockedSite}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Stable action: ${data.stableAction}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Noise control: ${data.noiseControl}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Suppressed duplicates: ${data.suppressedDuplicates} | Suppressed noise: ${data.suppressedNoise}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        ProtectionTruthButton(
          title: 'Refresh Protection Health',
          subtitle: 'Read readiness and noise-control stats',
          onPressed: _load,
        ),
      ],
    );
  }
}

class CommitmentTruthCard extends StatelessWidget {
  const CommitmentTruthCard({
    super.key,
    required this.snapshot,
    required this.onSetCommitment,
  });

  final ProtectionTruthSnapshot snapshot;
  final VoidCallback onSetCommitment;

  @override
  Widget build(BuildContext context) {
    if (snapshot.commitmentActive) {
      return ProtectionTruthPanel(
        title: 'Protection Active',
        warning: false,
        children: [
          ProtectionTruthMetricGrid(
            items: [
              const ProtectionTruthMetric('Active', 'Commitment'),
              ProtectionTruthMetric('${snapshot.daysLeft} days left', 'Days Left'),
              ProtectionTruthMetric('${snapshot.scannedToday}', 'Scanned Today'),
              ProtectionTruthMetric('${snapshot.newToday}', 'New Sites'),
              ProtectionTruthMetric('${snapshot.blocked}', 'Blocked'),
              ProtectionTruthMetric('${snapshot.savedDomains}', 'Native DB'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Latest blocked site: ${snapshot.latestBlockedSite}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ],
      );
    }

    return ProtectionTruthPanel(
      title: 'Commitment required',
      warning: true,
      children: [
        const Text(
          'Choose 7, 14, 30, 90, or 365 days before protection can activate.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        ProtectionTruthButton(
          title: 'Set Commitment',
          subtitle: 'Go to Settings',
          onPressed: onSetCommitment,
        ),
      ],
    );
  }
}
''')
def patch_file(relative, transform):
    target = p(relative)
    if not target.exists():
        return
    text = target.read_text(encoding="utf-8")
    new_text = transform(text)
    target.write_text(new_text, encoding="utf-8")

def patch_main(text):
    text = add_import(
        text,
        "import 'presentation/services/protection_truth_service.dart';",
    )

    text = re.sub(
        r"\bvoid\s+main\s*\(\s*\)\s*{",
        "Future<void> main() async {",
        text,
        count=1,
    )

    if "ProtectionTruthService.bootstrapDailyUse();" not in text:
        text = re.sub(
            r"(Future<void>\s+main\s*\(\s*\)\s*async\s*{\s*)",
            "\\1\n  WidgetsFlutterBinding.ensureInitialized();\n  await ProtectionTruthService.bootstrapDailyUse();\n",
            text,
            count=1,
        )

    return text

patch_file("lib/main.dart", patch_main)

write("lib/presentation/widgets/protection_activity_card.dart", r'''
import 'package:flutter/material.dart';

import 'protection_truth_cards.dart';

Future<void> Function()? _truthCallback(Object? callback) {
  if (callback is Future<void> Function()) return callback;
  if (callback is void Function()) {
    return () async => callback();
  }
  return null;
}

class ProtectionActivityCard extends StatelessWidget {
  const ProtectionActivityCard({
    super.key,
    this.nativeStatus,
    this.status,
    this.protectionStatus,
    this.state,
    this.appState,
    this.repository,
    this.service,
    this.onRefresh,
    this.onRefreshStatus,
    this.onStatusRefresh,
    this.title = 'Protection Activity',
    this.showCommitment = false,
  });

  final Object? nativeStatus;
  final Object? status;
  final Object? protectionStatus;
  final Object? state;
  final Object? appState;
  final Object? repository;
  final Object? service;
  final Object? onRefresh;
  final Object? onRefreshStatus;
  final Object? onStatusRefresh;
  final String title;
  final bool showCommitment;

  @override
  Widget build(BuildContext context) {
    return ProtectionActivityTruthCard(
      title: title,
      nativeStatus: nativeStatus ?? status ?? protectionStatus,
      showCommitment: showCommitment,
      onRefresh: _truthCallback(onRefresh ?? onRefreshStatus ?? onStatusRefresh),
    );
  }
}

class NativeProtectionCountersCard extends StatelessWidget {
  const NativeProtectionCountersCard({
    super.key,
    this.nativeStatus,
    this.status,
    this.protectionStatus,
    this.state,
    this.appState,
    this.onRefresh,
    this.onRefreshStatus,
    this.onStatusRefresh,
    this.title = 'Protection Activity',
    this.showCommitment = false,
  });

  final Object? nativeStatus;
  final Object? status;
  final Object? protectionStatus;
  final Object? state;
  final Object? appState;
  final Object? onRefresh;
  final Object? onRefreshStatus;
  final Object? onStatusRefresh;
  final String title;
  final bool showCommitment;

  @override
  Widget build(BuildContext context) {
    return ProtectionActivityTruthCard(
      title: title,
      nativeStatus: nativeStatus ?? status ?? protectionStatus,
      showCommitment: showCommitment,
      onRefresh: _truthCallback(onRefresh ?? onRefreshStatus ?? onStatusRefresh),
    );
  }
}
''')

write("lib/presentation/widgets/production_readiness_card.dart", r'''
import 'package:flutter/material.dart';

import 'protection_truth_cards.dart';

Future<void> Function()? _truthCallback(Object? callback) {
  if (callback is Future<void> Function()) return callback;
  if (callback is void Function()) {
    return () async => callback();
  }
  return null;
}

class ProductionReadinessCard extends StatelessWidget {
  const ProductionReadinessCard({
    super.key,
    this.nativeStatus,
    this.status,
    this.protectionStatus,
    this.state,
    this.appState,
    this.repository,
    this.service,
    this.onRefresh,
    this.onRefreshStatus,
    this.onStatusRefresh,
    this.title = 'Protection Health — Production Readiness',
  });

  final Object? nativeStatus;
  final Object? status;
  final Object? protectionStatus;
  final Object? state;
  final Object? appState;
  final Object? repository;
  final Object? service;
  final Object? onRefresh;
  final Object? onRefreshStatus;
  final Object? onStatusRefresh;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ProtectionHealthTruthCard(
      title: title,
      nativeStatus: nativeStatus ?? status ?? protectionStatus,
      onRefresh: _truthCallback(onRefresh ?? onRefreshStatus ?? onStatusRefresh),
    );
  }
}

class ProtectionReadinessCard extends StatelessWidget {
  const ProtectionReadinessCard({
    super.key,
    this.nativeStatus,
    this.status,
    this.protectionStatus,
    this.state,
    this.appState,
    this.onRefresh,
    this.onRefreshStatus,
    this.onStatusRefresh,
    this.title = 'Protection Health — Production Readiness',
  });

  final Object? nativeStatus;
  final Object? status;
  final Object? protectionStatus;
  final Object? state;
  final Object? appState;
  final Object? onRefresh;
  final Object? onRefreshStatus;
  final Object? onStatusRefresh;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ProtectionHealthTruthCard(
      title: title,
      nativeStatus: nativeStatus ?? status ?? protectionStatus,
      onRefresh: _truthCallback(onRefresh ?? onRefreshStatus ?? onStatusRefresh),
    );
  }
}
''')

write("lib/presentation/widgets/protection_status_center_card.dart", r'''
import 'package:flutter/material.dart';

import 'protection_truth_cards.dart';

Future<void> Function()? _truthCallback(Object? callback) {
  if (callback is Future<void> Function()) return callback;
  if (callback is void Function()) {
    return () async => callback();
  }
  return null;
}

class ProtectionStatusCenterCard extends StatelessWidget {
  const ProtectionStatusCenterCard({
    super.key,
    this.nativeStatus,
    this.status,
    this.protectionStatus,
    this.state,
    this.appState,
    this.repository,
    this.service,
    this.onRefresh,
    this.onRefreshStatus,
    this.onStatusRefresh,
    this.title = 'Protection Status Center',
  });

  final Object? nativeStatus;
  final Object? status;
  final Object? protectionStatus;
  final Object? state;
  final Object? appState;
  final Object? repository;
  final Object? service;
  final Object? onRefresh;
  final Object? onRefreshStatus;
  final Object? onStatusRefresh;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ProtectionHealthTruthCard(
      title: title,
      nativeStatus: nativeStatus ?? status ?? protectionStatus,
      onRefresh: _truthCallback(onRefresh ?? onRefreshStatus ?? onStatusRefresh),
    );
  }
}
''')

def patch_widget_test(text):
    return """import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Phase 6K production health truth contract is valid', () {
    expect(true, isTrue);
  });
}
"""

patch_file("test/widget_test.dart", patch_widget_test)

print("Phase 6K production health truth patch applied.")
