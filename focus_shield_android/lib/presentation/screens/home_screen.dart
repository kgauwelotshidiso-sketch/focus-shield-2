import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/models/goal.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';
import '../widgets/native_protection_counters_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.state,
    required this.goals,
    required this.primaryAffirmation,
    required this.onNavigate,
    required this.onListeningWin,
  });

  final FocusShieldState state;
  final List<Goal> goals;
  final String primaryAffirmation;
  final ValueChanged<int> onNavigate;
  final VoidCallback onListeningWin;

  @override
  Widget build(BuildContext context) {
    final visibleGoals = goals.take(3).toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 4),
        const Text('Discipline + protection dashboard'),
        Text('Active day: ${state.lastActiveDate}'),
        const SizedBox(height: 18),
        if (!state.commitmentSet)
          ShieldCard(
            borderColor: AppTheme.warning,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Commitment required'),
                const SizedBox(height: 8),
                const Text(
                  'Choose 7, 14, 30, 90, or 365 days before protection can activate.',
                ),
                const SizedBox(height: 12),
                ActionButton(
                  label: 'Set Commitment',
                  subtitle: 'Go to Settings',
                  onPressed: () => onNavigate(5),
                ),
              ],
            ),
          )
        else
          NativeHomeProtectionSummaryCard(
            commitmentLabel: state.commitmentSet ? 'Active' : 'Required',
            daysLeftLabel: state.commitmentSet
                ? '${state.commitmentDaysRemaining} days left'
                : 'Set commitment',
          ),
        const SizedBox(height: 16),
        ShieldCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today’s Mission'),
              Text(
                '${state.listeningWinsToday} / ${state.missionTarget}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: state.missionComplete
                      ? AppTheme.primary
                      : AppTheme.warning,
                ),
              ),
              const Text(
                'Pause and fully listen before speaking at least 3 times today.',
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Log Listening Win',
                subtitle: '+10 XP',
                onPressed: onListeningWin,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: {
              'Shield': state.protectionEnabled ? 'Active' : 'Off',
              'Recovery': '${state.recoveryRate}%',
              'Level': '${state.level}',
              'XP': '${state.xpInCurrentLevel}/${state.xpForNextLevel}',
              'Streak': '${state.currentStreak}',
              'Best': '${state.longestStreak}',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Goals'),
              const SizedBox(height: 8),
              if (visibleGoals.isEmpty)
                const Text('No goals saved yet.')
              else
                ...visibleGoals.map(
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
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick Actions'),
              const SizedBox(height: 12),
              ActionButton(label: 'Scanner', onPressed: () => onNavigate(1)),
              const SizedBox(height: 10),
              ActionButton(label: 'Recovery', onPressed: () => onNavigate(2)),
              const SizedBox(height: 10),
              ActionButton(label: 'Progress', onPressed: () => onNavigate(3)),
              const SizedBox(height: 10),
              ActionButton(label: 'Coach', onPressed: () => onNavigate(4)),
              const SizedBox(height: 10),
              ActionButton(label: 'Settings', onPressed: () => onNavigate(5)),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Text(
            '“$primaryAffirmation”',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.lightBlueAccent),
          ),
        ),
      ],
    );
  }
}
