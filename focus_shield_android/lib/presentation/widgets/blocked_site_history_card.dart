import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import 'action_button.dart';
import 'shield_card.dart';

class BlockedSiteHistoryCard extends StatefulWidget {
  const BlockedSiteHistoryCard({super.key, this.compact = false});

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
            (item) => item.map((key, value) => MapEntry(key.toString(), value)),
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
  const _BlockedHistoryRow({required this.item});

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
        color: AppTheme.cardSoft.withValues(alpha: 0.45),
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
