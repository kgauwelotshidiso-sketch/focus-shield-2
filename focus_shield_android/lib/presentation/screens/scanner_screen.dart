import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/blocked_domain.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/services/protection_engine.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';
import '../widgets/protection_chain_status_card.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
    required this.protectionEnabled,
    required this.blockedDomains,
    required this.state,
    required this.onDecision,
  });

  final bool protectionEnabled;
  final List<BlockedDomain> blockedDomains;
  final FocusShieldState state;
  final ValueChanged<ProtectionDecision> onDecision;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _controller = TextEditingController();
  final List<ProtectionDecision> _unknownReviewQueue = <ProtectionDecision>[];

  ProtectionDecision? _decision;

  void _scan(String value) {
    final engine = ProtectionEngine(
      blockedDomains: widget.blockedDomains.map((item) => item.domain).toList(),
    );

    final decision = engine.analyze(value);

    setState(() {
      _decision = decision;

      if (decision.isUnknown &&
          decision.domain.isNotEmpty &&
          !_unknownReviewQueue.any((item) => item.domain == decision.domain)) {
        _unknownReviewQueue.insert(0, decision);
      }
    });

    widget.onDecision(decision);
  }

  void _scanSafeExample() {
    _scan('study-example.com');
  }

  void _scanBlockedExample() {
    _scan('blocked-example.com');
  }

  void _scanHighRiskExample() {
    _scan('adult-risk-example.com');
  }

  void _clearUnknownQueue() {
    setState(() {
      _unknownReviewQueue.clear();
    });
  }

  Color _riskColor(ProtectionDecision decision) {
    if (decision.blocked) return AppTheme.danger;
    if (decision.isUnknown) return AppTheme.warning;
    return AppTheme.primary;
  }

  String _decisionTitle(ProtectionDecision decision) {
    if (decision.blocked) return 'Blocked by AI-lite classifier';
    if (decision.isUnknown) return 'Unknown site added to review queue';
    return 'Domain allowed';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decision = _decision;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const ProtectionChainStatusCard(compact: true, showControls: false),
        const SizedBox(height: 16),

        Text('Scanner', style: Theme.of(context).textTheme.headlineLarge),
        Text(
          widget.protectionEnabled
              ? 'Protection scanner is active'
              : 'Protection is off until commitment is active',
        ),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Scanned Today': '${widget.state.websitesScannedToday}',
              'New Today': '${widget.state.newWebsitesScannedToday}',
              'Total Scanned': '${widget.state.totalWebsitesScanned}',
              'Review Queue': '${_unknownReviewQueue.length}',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: {
              'AI-lite': 'Local',
              'DB Domains': '${widget.blockedDomains.length}',
              'Risk Mode': 'Score',
              'API Cost': 'None',
            },
          ),
        ),
        ShieldCard(
          borderColor: widget.protectionEnabled
              ? AppTheme.secondary
              : AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI-lite Website Scanner'),
              const SizedBox(height: 8),
              const Text(
                'Local classifier checks saved blocklist, risk signals, domain shape, category, and confidence.',
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('scannerDomainInput'),
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'example.com or suspicious-example.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Scan Website',
                subtitle: 'AI-lite risk score + explanation',
                onPressed: () => _scan(_controller.text),
              ),
            ],
          ),
        ),
        ShieldCard(
          child: Column(
            children: [
              ActionButton(
                label: 'Test Safe Domain',
                subtitle: 'study-example.com',
                onPressed: _scanSafeExample,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Test Blocked Domain',
                subtitle: 'blocked-example.com',
                onPressed: _scanBlockedExample,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Test High-Risk Signal',
                subtitle: 'adult-risk-example.com',
                onPressed: _scanHighRiskExample,
              ),
            ],
          ),
        ),
        if (decision != null)
          ShieldCard(
            borderColor: _riskColor(decision),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_decisionTitle(decision)),
                const SizedBox(height: 8),
                Text('Domain: ${decision.domain}'),
                Text('Category: ${decision.category}'),
                Text('Risk score: ${decision.riskScore}/100'),
                Text('Confidence: ${(decision.confidence * 100).round()}%'),
                const SizedBox(height: 8),
                Text(decision.reason),
                const SizedBox(height: 12),
                const Text('Risk signals'),
                const SizedBox(height: 6),
                ...decision.signals.map(
                  (signal) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $signal'),
                  ),
                ),
              ],
            ),
          ),
        ShieldCard(
          borderColor: AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Unknown-site review queue'),
              const SizedBox(height: 8),
              Text(
                _unknownReviewQueue.isEmpty
                    ? 'No unknown sites waiting for review.'
                    : '${_unknownReviewQueue.length} unknown site(s) waiting for review.',
              ),
              const SizedBox(height: 12),
              if (_unknownReviewQueue.isNotEmpty)
                ..._unknownReviewQueue
                    .take(5)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '• ${item.domain} — ${item.riskScore}/100 — ${item.category}',
                        ),
                      ),
                    ),
              if (_unknownReviewQueue.isNotEmpty) ...[
                const SizedBox(height: 8),
                ActionButton(
                  label: 'Clear Review Queue',
                  subtitle: 'Local queue only',
                  onPressed: _clearUnknownQueue,
                ),
              ],
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text(
            'Phase 5 is local-only. No paid API, no cloud dependency, and no VPN route changes.',
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: const Text(
            'Native Accessibility counters are shown above through Protection Chain Status.',
          ),
        ),
      ],
    );
  }
}
