import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import 'action_button.dart';
import 'shield_card.dart';

class LatestBlockedSiteCard extends StatefulWidget {
  const LatestBlockedSiteCard({super.key, this.showControls = true});

  final bool showControls;

  @override
  State<LatestBlockedSiteCard> createState() => _LatestBlockedSiteCardState();
}

class _LatestBlockedSiteCardState extends State<LatestBlockedSiteCard> {
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

  bool get _hasBlockedSite {
    return _value('lastDecision').toLowerCase() == 'blocked' &&
        _value('lastDomain').isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ShieldCard(
        borderColor: AppTheme.warning,
        child: Text('Loading latest protection activity...'),
      );
    }

    if (!_hasBlockedSite) {
      return ShieldCard(
        borderColor: AppTheme.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Last blocked site'),
            const SizedBox(height: 8),
            const Text('No blocked site recorded yet.'),
            if (widget.showControls) ...[
              const SizedBox(height: 12),
              ActionButton(
                label: 'Refresh',
                subtitle: 'Check native Accessibility status',
                onPressed: _refresh,
              ),
            ],
          ],
        ),
      );
    }

    final domain = _value('lastDomain', fallback: 'Unknown');
    final category = _value('lastCategory', fallback: 'unknown');
    final score = _value('lastScore', fallback: '0');
    final packageName = _value('lastPackage', fallback: '-');
    final action = _value('lastAction', fallback: '-');

    return ShieldCard(
      borderColor: AppTheme.danger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Last blocked site'),
          const SizedBox(height: 8),
          Text('Domain: $domain'),
          Text('Category: $category'),
          Text('Risk score: $score/100'),
          Text('Source: $packageName'),
          Text('Last action: $action'),
          const SizedBox(height: 10),
          const Text(
            'Focus Shield detected and interrupted this site through Accessibility.',
          ),
          if (widget.showControls) ...[
            const SizedBox(height: 12),
            ActionButton(
              label: 'Refresh',
              subtitle: 'Update latest blocked site',
              onPressed: _refresh,
            ),
          ],
        ],
      ),
    );
  }
}
