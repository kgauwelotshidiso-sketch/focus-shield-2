import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/services/protection_engine.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class InterventionScreen extends StatelessWidget {
  const InterventionScreen({
    super.key,
    required this.decision,
    required this.onNavigate,
    required this.onBackToScanner,
  });

  final ProtectionDecision? decision;
  final ValueChanged<int> onNavigate;
  final VoidCallback onBackToScanner;

  @override
  Widget build(BuildContext context) {
    final blockedDomain = decision?.domain ?? AppConstants.blockedTestDomain;
    final category = decision?.category ?? 'test-risk';
    final confidence = ((decision?.confidence ?? 0.96) * 100).round();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Intervention', style: Theme.of(context).textTheme.headlineLarge),
        const Text('Temptation detected response'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.danger,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠ Temptation Detected',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.danger,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Focus Shield blocked a risk signal before it pulled you away from your goals.',
              ),
              const SizedBox(height: 12),
              Text('Domain: $blockedDomain'),
              Text('Category: $category'),
              Text('Confidence: $confidence%'),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: const StatGrid(
            items: {
              'Current Streak': '0',
              'Longest Streak': '0',
              'Mission': '0/3',
              'Recovery': 'Ready',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Text(
            '“${AppConstants.affirmation}”',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.lightBlueAccent,
                ),
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.warning,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Remember'),
              SizedBox(height: 8),
              Text('Your future is worth more than this moment.'),
              Text('You do not need to follow the urge. Return to your goals now.'),
            ],
          ),
        ),
        ShieldCard(
          child: Column(
            children: [
              ActionButton(
                label: 'Breathing Exercise',
                subtitle: 'Open recovery reset',
                onPressed: () => onNavigate(2),
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Start Focus Session',
                subtitle: 'Redirect energy',
                onPressed: () => onNavigate(3),
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Journal Thoughts',
                subtitle: 'Reflect and recover',
                onPressed: () => onNavigate(4),
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Read Goals',
                subtitle: 'Return to purpose',
                onPressed: () => onNavigate(0),
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Back to Scanner',
                subtitle: 'Continue testing',
                onPressed: onBackToScanner,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
