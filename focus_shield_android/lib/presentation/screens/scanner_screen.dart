import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/blocked_domain.dart';
import '../../domain/services/protection_engine.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
    required this.protectionEnabled,
    required this.blockedDomains,
    required this.onBlocked,
  });

  final bool protectionEnabled;
  final List<BlockedDomain> blockedDomains;
  final ValueChanged<ProtectionDecision> onBlocked;

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

    if (decision.blocked && widget.protectionEnabled) {
      widget.onBlocked(decision);
    }
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
              ? 'Live protection scanner'
              : 'Protection is currently off',
        ),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: widget.protectionEnabled
              ? AppTheme.secondary
              : AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Live URL Scanner'),
              const SizedBox(height: 8),
              Text('Database domains loaded: ${widget.blockedDomains.length}'),
              const SizedBox(height: 12),
              TextField(
                key: const Key('scannerDomainInput'),
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'study-example.com or blocked-example.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Scan',
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
                onPressed: () => _scan(AppConstants.safeTestDomain),
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Test Blocked Domain',
                onPressed: () => _scan(AppConstants.blockedTestDomain),
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
                Text(decision.blocked ? 'Domain blocked' : 'Domain allowed'),
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
