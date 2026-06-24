import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/models/goal.dart';
import '../../domain/services/protection_engine.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class InterventionScreen extends StatelessWidget {
  const InterventionScreen({
    super.key,
    required this.state,
    required this.goals,
    required this.primaryAffirmation,
    required this.decision,
    required this.onNavigate,
    required this.onRecovered,
    required this.onBackToScanner,
  });

  final FocusShieldState state;
  final List<Goal> goals;
  final String primaryAffirmation;
  final ProtectionDecision? decision;
  final ValueChanged<int> onNavigate;
  final VoidCallback onRecovered;
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
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: AppTheme.danger),
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
          child: StatGrid(
            items: {
              'Attempts': '${state.blockedAttempts}',
              'Recovered': '${state.recoveredAttempts}',
              'Pending': '${state.pendingRecoveries}',
              'Recovery': '${state.recoveryRate}%',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Text(
            '“$primaryAffirmation”',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.lightBlueAccent),
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Remember Your Goals'),
              const SizedBox(height: 8),
              if (goals.isEmpty)
                const Text('No goals saved yet.')
              else
                ...goals.take(3).map(
                      (goal) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('• ${goal.title}'),
                      ),
                    ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Edit Goals & Affirmations',
                subtitle: 'Go to Settings manager',
                onPressed: () => onNavigate(5),
              ),
            ],
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
              Text('Return to your goals now.'),
            ],
          ),
        ),
        ShieldCard(
          child: Column(
            children: [
              ActionButton(
                label: 'I am back in control',
                subtitle: '+10 XP',
                onPressed: onRecovered,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Breathing Exercise',
                onPressed: () => onNavigate(2),
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Start Focus Session',
                onPressed: () => onNavigate(3),
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Journal Thoughts',
                onPressed: () => onNavigate(4),
              ),
              const SizedBox(height: 10),
              ActionButton(label: 'Read Goals', onPressed: () => onNavigate(0)),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Back to Scanner',
                onPressed: onBackToScanner,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
