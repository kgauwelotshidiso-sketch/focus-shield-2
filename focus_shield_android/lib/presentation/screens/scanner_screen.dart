import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/blocked_domain.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/services/protection_engine.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

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
  ProtectionDecision? _decision;

  void _scan(String value) {
    final engine = ProtectionEngine(
      blockedDomains: widget.blockedDomains.map((item) => item.domain).toList(),
    );

    final decision = engine.analyze(value);

    setState(() {
      _decision = decision;
    });

    widget.onDecision(decision);
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
              'DB Domains': '${widget.blockedDomains.length}',
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
              const Text('Live Website Scanner'),
              const SizedBox(height: 8),
              Text('Database domains loaded: ${widget.blockedDomains.length}'),
              const SizedBox(height: 12),
              TextField(
                key: const Key('scannerDomainInput'),
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'example.com or blocked-example.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Scan Website',
                subtitle: 'Updates scanned counters',
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
                subtitle: 'example.com',
                onPressed: () => _scan('example.com'),
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Test Blocked Domain',
                subtitle: 'blocked-example.com',
                onPressed: () => _scan('blocked-example.com'),
              ),
            ],
          ),
        ),
        if (decision != null)
          ShieldCard(
            borderColor: decision.blocked ? AppTheme.danger : AppTheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  decision.blocked
                      ? 'Domain matched block rules'
                      : 'Domain allowed',
                ),
                const SizedBox(height: 8),
                Text('Domain: ${decision.domain}'),
                Text('Category: ${decision.category}'),
                Text('Confidence: ${(decision.confidence * 100).round()}%'),
                Text(decision.reason),
              ],
            ),
          ),
      ],
    );
  }
}
