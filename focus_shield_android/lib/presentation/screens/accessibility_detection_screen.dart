import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import '../widgets/action_button.dart';
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

    return <String>[];
  }

  String _cleanMode() {
    final mode = _value('mode').toLowerCase();

    if (mode.contains('local')) {
      return 'Local';
    }

    if (mode.isEmpty) {
      return 'Local';
    }

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
                'Blocked detections open the native intervention screen. Blocklist sync is now tracked separately so it does not overwrite the protection action.',
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
                'Android requires you to manually enable Focus Shield in Accessibility Settings. If Android shows Restricted setting, open Settings > Apps > Focus Shield > More options > Allow restricted settings.',
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
            'Phase 6D ignores Android System UI rescans, syncs the saved blocklist into native Accessibility detection, and opens a real intervention screen after blocked detection.',
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text(
            'Main app counter sync is active. Home, Scanner, and Progress can now read native Accessibility scanned, new, blocked, unknown, and last blocked site data.',
          ),
        ),
      ],
    );
  }
}
