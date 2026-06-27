import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import 'action_button.dart';
import 'shield_card.dart';
import 'stat_grid.dart';

class ProtectionStatusCenterCard extends StatefulWidget {
  const ProtectionStatusCenterCard({super.key});

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
          Text(
            'Latest blocked site: ${_value('lastDomain', fallback: 'None')}',
          ),
          const SizedBox(height: 6),
          Text(
            'Stable action: ${_value('lastAction', fallback: 'No action yet')}',
          ),
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
