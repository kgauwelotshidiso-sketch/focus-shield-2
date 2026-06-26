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
  String _message = 'Reading protection status...';

  @override
  void initState() {
    super.initState();
    _refreshStatus();

    if (widget.blockedDomains.isNotEmpty) {
      _syncNativeBlocklistSilently();
    }
  }

  Future<void> _refreshStatus() async {
    final status = await _channel.accessibilityDetectionStatus();

    if (!mounted) return;

    setState(() {
      _status = status;
      _loading = false;
      _message = 'Protection status refreshed.';
    });
  }

  Future<void> _syncNativeBlocklistSilently() async {
    final domains = widget.blockedDomains
        .map((domain) => domain.trim().toLowerCase())
        .where((domain) => domain.isNotEmpty)
        .toSet()
        .toList();

    await _channel.syncAccessibilityBlocklist(domains);
    final status = await _channel.accessibilityDetectionStatus();

    if (!mounted) return;

    setState(() {
      _status = status;
      _loading = false;
      _message = 'Native blocklist synced without replacing protection action.';
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
    if (_loading) return 'Loading';
    if (_hasBlockedSite) return 'Blocking';
    if (_hasNativeActivity) return 'Active';
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

  String get _stableAction {
    final action = _value('lastAction', fallback: 'No protection action yet');

    if (action == 'blocklist_synced' && _hasBlockedSite) {
      return 'opened_intervention';
    }

    return action;
  }

  String get _stableMessage {
    final message = _value('lastMessage', fallback: '');

    if (_stableAction == 'opened_intervention' && _hasBlockedSite) {
      return 'Focus Shield opened intervention after blocking $_lastBlockedSite.';
    }

    if (message.isNotEmpty) return message;

    return _message;
  }

  @override
  Widget build(BuildContext context) {
    return ShieldCard(
      borderColor: _statusColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.compact ? 'Protection Active' : 'Protection Chain'),
          const SizedBox(height: 12),
          StatGrid(
            items: {
              'Status': _chainStatus,
              'Scanned': _value('websitesScanned'),
              'New': _value('newWebsitesScanned'),
              'Blocked': _value('blockedDetections'),
              if (!widget.compact) 'Unknown': _value('unknownDetections'),
              if (!widget.compact)
                'Native DB': _value('nativeBlocklistDomains'),
            },
          ),
          const SizedBox(height: 12),
          Text('Latest blocked site: $_lastBlockedSite'),
          const SizedBox(height: 6),
          Text('Last protection action: $_stableAction'),
          if (!widget.compact) ...[
            const SizedBox(height: 6),
            Text(_stableMessage),
            const SizedBox(height: 8),
            Text(
              'Last sync: ${_value('lastSyncMessage', fallback: 'No sync message yet')}',
            ),
          ],
          if (widget.showControls) ...[
            const SizedBox(height: 12),
            ActionButton(
              label: 'Refresh Protection Status',
              subtitle: 'Read native Accessibility counters',
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
