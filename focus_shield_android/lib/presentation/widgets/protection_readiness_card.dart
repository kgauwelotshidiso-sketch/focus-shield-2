import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import 'action_button.dart';
import 'shield_card.dart';
import 'stat_grid.dart';

class ProtectionReadinessCard extends StatefulWidget {
  const ProtectionReadinessCard({super.key, this.compact = false});

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
          const Text('Protection Health — Production Readiness'),
          const SizedBox(height: 12),
          StatGrid(
            items: {
              'Readiness': '$_score%',
              'Mode': _label,
              'Native DB': _ready(_nativeDbReady),
              'Scanning': _ready(_scanningActive),
              'Blocking': _ready(_blockingConfirmed),
              'Intervention': _ready(_interventionReady),
            },
          ),
          if (!widget.compact) ...[
            const SizedBox(height: 12),
            Text(
              'Latest blocked site: ${_value('lastDomain', fallback: 'None')}',
            ),
            const SizedBox(height: 6),
            Text(
              'Stable action: ${_value('lastAction', fallback: 'No action yet')}',
            ),
            const SizedBox(height: 6),
            Text(
              'Noise control: ${_value('noiseControlMode', fallback: 'not active')}',
            ),
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
