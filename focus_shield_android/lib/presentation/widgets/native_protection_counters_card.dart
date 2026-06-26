import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import 'action_button.dart';
import 'shield_card.dart';
import 'stat_grid.dart';

class NativeProtectionCountersCard extends StatefulWidget {
  const NativeProtectionCountersCard({
    super.key,
    required this.title,
    this.reviewQueueCount,
    this.commitmentLabel,
    this.showControls = false,
  });

  final String title;
  final int? reviewQueueCount;
  final String? commitmentLabel;
  final bool showControls;

  @override
  State<NativeProtectionCountersCard> createState() =>
      _NativeProtectionCountersCardState();
}

class _NativeProtectionCountersCardState
    extends State<NativeProtectionCountersCard> {
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
    final raw = _status[key];

    if (raw == null) return fallback;

    final clean = raw.toString().trim();

    if (clean.isEmpty) return fallback;

    return clean;
  }

  bool get _hasBlocked {
    return _value('lastDecision', fallback: '').toLowerCase() == 'blocked';
  }

  Color get _borderColor {
    if (_hasBlocked) return AppTheme.danger;
    if (_loading) return AppTheme.warning;
    return AppTheme.primary;
  }

  String get _stableAction {
    final action = _value('lastAction', fallback: 'No action yet');

    if (action == 'blocklist_synced' && _hasBlocked) {
      return 'opened_intervention';
    }

    return action;
  }

  @override
  Widget build(BuildContext context) {
    final items = <String, String>{
      'Scanned Today': _loading ? 'Loading' : _value('websitesScanned'),
      'New Today': _loading ? 'Loading' : _value('newWebsitesScanned'),
      'Total Scanned': _loading ? 'Loading' : _value('websitesScanned'),
      'Blocked': _loading ? 'Loading' : _value('blockedDetections'),
    };

    if (widget.reviewQueueCount != null) {
      items['Review Queue'] = '${widget.reviewQueueCount}';
    }

    if (widget.commitmentLabel != null) {
      items['Commitment'] = widget.commitmentLabel!;
    }

    return ShieldCard(
      borderColor: _borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title),
          const SizedBox(height: 12),
          StatGrid(items: items),
          const SizedBox(height: 12),
          Text(
            'Latest blocked site: ${_value('lastDomain', fallback: 'None')}',
          ),
          const SizedBox(height: 6),
          Text('Stable protection action: $_stableAction'),
          if (widget.showControls) ...[
            const SizedBox(height: 12),
            ActionButton(
              label: 'Refresh Protection Counters',
              subtitle: 'Read Accessibility protection stats',
              onPressed: _refresh,
            ),
          ],
        ],
      ),
    );
  }
}

class NativeHomeProtectionSummaryCard extends StatefulWidget {
  const NativeHomeProtectionSummaryCard({
    super.key,
    required this.commitmentLabel,
    required this.daysLeftLabel,
  });

  final String commitmentLabel;
  final String daysLeftLabel;

  @override
  State<NativeHomeProtectionSummaryCard> createState() =>
      _NativeHomeProtectionSummaryCardState();
}

class _NativeHomeProtectionSummaryCardState
    extends State<NativeHomeProtectionSummaryCard> {
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
    final raw = _status[key];

    if (raw == null) return fallback;

    final clean = raw.toString().trim();

    if (clean.isEmpty) return fallback;

    return clean;
  }

  bool get _hasBlocked {
    return _value('lastDecision', fallback: '').toLowerCase() == 'blocked';
  }

  @override
  Widget build(BuildContext context) {
    return ShieldCard(
      borderColor: _hasBlocked ? AppTheme.danger : AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Protection Active'),
          const SizedBox(height: 12),
          StatGrid(
            items: {
              'Commitment': widget.commitmentLabel,
              'Days Left': widget.daysLeftLabel,
              'Scanned Today': _loading ? 'Loading' : _value('websitesScanned'),
              'New Sites': _loading ? 'Loading' : _value('newWebsitesScanned'),
              'Blocked': _loading ? 'Loading' : _value('blockedDetections'),
              'Native DB': _loading
                  ? 'Loading'
                  : _value('nativeBlocklistDomains'),
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Latest blocked site: ${_value('lastDomain', fallback: 'None')}',
          ),
        ],
      ),
    );
  }
}
