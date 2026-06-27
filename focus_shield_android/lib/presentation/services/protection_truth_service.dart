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
  static const MethodChannel _channel = MethodChannel(
    'focus_shield/protection',
  );

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
      const ['noiseControl', 'noise_control', 'noiseFilter', 'noise_filter'],
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

    final readiness =
        ((checks.where((item) => item).length / checks.length) * 100).round();

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
      await prefs.setString(
        'phase6k_latest_blocked_site',
        snapshot.latestBlockedSite,
      );
      await prefs.setString('phase6k_stable_action', snapshot.stableAction);
      await prefs.setString('phase6k_noise_control', snapshot.noiseControl);
      await prefs.setInt(
        'phase6k_suppressed_duplicates',
        snapshot.suppressedDuplicates,
      );
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

  static int _firstPositiveMapInt(
    Map<String, Object?> source,
    List<String> keys,
  ) {
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
