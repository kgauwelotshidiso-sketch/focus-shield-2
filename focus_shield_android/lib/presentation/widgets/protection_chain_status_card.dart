import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import 'action_button.dart';
import 'shield_card.dart';
import 'stat_grid.dart';

class ProtectionChainStatusCard extends StatefulWidget {
  const ProtectionChainStatusCard({
    super.key,
    this.compact = false,
    this.showControls = true,
    this.blockedDomains = const <String>[],
  });

  final bool compact;
  final bool showControls;
  final List<String> blockedDomains;

  @override
  State<ProtectionChainStatusCard> createState() =>
      _ProtectionChainStatusCardState();
}

class _ProtectionChainStatusCardState extends State<ProtectionChainStatusCard> {
  final ProtectionChannel _channel = ProtectionChannel();

  Map<String, dynamic> _status = <String, dynamic>{};
  bool _loading = true;
  String _message = 'Reading native protection chain...';

  @override
  void initState() {
    super.initState();
    _refreshStatus();
    if (widget.blockedDomains.isNotEmpty) {
      _syncNativeBlocklist();
    }
  }

  Future<void> _refreshStatus() async {
    final status = await _channel.accessibilityDetectionStatus();

    if (!mounted) return;

    setState(() {
      _status = status;
      _loading = false;
      _message = 'Protection chain status refreshed.';
    });
  }

  Future<void> _syncNativeBlocklist() async {
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
      _loading = false;
      _message = result;
    });
  }

  String _value(String key, {String fallback = '0'}) {
    final value = _status[key];

    if (value == null) {
      return fallback;
    }

    final clean = value.toString().trim();

    if (clean.isEmpty) {
      return fallback;
    }

    return clean;
  }

  int _intValue(String key) {
    final raw = _status[key];

    if (raw is int) return raw;
    if (raw is num) return raw.toInt();

    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  bool get _hasNativeActivity {
    return _intValue('events') > 0 ||
        _intValue('websitesScanned') > 0 ||
        _intValue('blockedDetections') > 0;
  }

  bool get _hasBlockedSite {
    return _value('lastDecision', fallback: '').toLowerCase() == 'blocked' &&
        _value('lastDomain', fallback: '').isNotEmpty;
  }

  String get _chainStatus {
    if (_hasBlockedSite) {
      return 'Blocking';
    }

    if (_hasNativeActivity) {
      return 'Active';
    }

    return 'Ready';
  }

  Color get _statusColor {
    if (_hasBlockedSite) return AppTheme.danger;
    if (_hasNativeActivity) return AppTheme.primary;
    return AppTheme.warning;
  }

  String get _lastBlockedSite {
    if (!_hasBlockedSite) return 'None';

    return _value('lastDomain', fallback: 'None');
  }

  @override
  Widget build(BuildContext context) {
    return ShieldCard(
      borderColor: _statusColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.compact ? 'Protection Sync' : 'Protection Chain Status'),
          const SizedBox(height: 12),
          StatGrid(
            items: {
              'Chain': _loading ? 'Loading' : _chainStatus,
              'Scanned': _value('websitesScanned'),
              'New': _value('newWebsitesScanned'),
              'Blocked': _value('blockedDetections'),
              if (!widget.compact) 'Unknown': _value('unknownDetections'),
              if (!widget.compact)
                'Native DB': _value('nativeBlocklistDomains'),
            },
          ),
          const SizedBox(height: 12),
          Text('Last blocked site: $_lastBlockedSite'),
          const SizedBox(height: 6),
          Text(
            'Last action: ${_value('lastAction', fallback: 'No action yet')}',
          ),
          if (!widget.compact) ...[
            const SizedBox(height: 6),
            Text(_value('lastMessage', fallback: _message)),
          ],
          if (widget.showControls) ...[
            const SizedBox(height: 12),
            ActionButton(
              label: 'Refresh Protection Status',
              subtitle: 'Sync native Accessibility counters',
              onPressed: _refreshStatus,
            ),
            if (widget.blockedDomains.isNotEmpty) ...[
              const SizedBox(height: 10),
              ActionButton(
                label: 'Sync Blocklist',
                subtitle: '${widget.blockedDomains.length} saved domain(s)',
                onPressed: _syncNativeBlocklist,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
