import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/focus_shield_state.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';
import '../widgets/protection_chain_status_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    super.key,
    required this.state,
    required this.onListeningWin,
    required this.onOpenFocusTimer,
    required this.onOpenReflection,
    required this.onOpenConcentration,
    required this.onOpenDailyHistory,
  });

  final FocusShieldState state;
  final VoidCallback onListeningWin;
  final VoidCallback onOpenFocusTimer;
  final VoidCallback onOpenReflection;
  final VoidCallback onOpenConcentration;
  final VoidCallback onOpenDailyHistory;

  @override
  Widget build(BuildContext context) {
    final focusDone = state.focusSessionCompletedToday;
    final reflectionDone = state.reflectionCompletedToday;
    final concentrationDone = state.concentrationCompletedToday;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const ProtectionChainStatusCard(compact: true, showControls: false),
        const SizedBox(height: 16),

        Text('Progress', style: Theme.of(context).textTheme.headlineLarge),
        const Text('XP, streaks, badges, wins'),
        const SizedBox(height: 18),
        ShieldCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Level ${state.level}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text('${state.xpInCurrentLevel} / ${state.xpForNextLevel} XP'),
              Text('${state.xp} total XP'),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: state.levelProgress),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: {
              'Listening Wins': '${state.listeningWinsToday}',
              'Focus Task': focusDone ? 'Done' : 'Open',
              'Reflection Task': reflectionDone ? 'Done' : 'Open',
              'Concentration Task': concentrationDone ? 'Done' : 'Open',
              'Daily Core': state.dailyCoreTasksComplete ? 'Complete' : 'Open',
              'Streak': '${state.currentStreak}',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Scanned Today': '${state.websitesScannedToday}',
              'New Today': '${state.newWebsitesScannedToday}',
              'Total Scanned': '${state.totalWebsitesScanned}',
              'Commitment': state.commitmentSet
                  ? '${state.commitmentDaysRemaining} days left'
                  : 'Not set',
            },
          ),
        ),
        ShieldCard(
          child: Column(
            children: [
              ActionButton(
                label: 'Log Listening Win',
                subtitle: '+10 XP',
                onPressed: onListeningWin,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: focusDone
                    ? 'Open Focus Timer Again'
                    : 'Complete Focus Session',
                subtitle: focusDone
                    ? 'Already completed today'
                    : 'Opens countdown screen',
                onPressed: onOpenFocusTimer,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: reflectionDone
                    ? 'Open Reflection Again'
                    : 'Complete Reflection',
                subtitle: reflectionDone
                    ? 'Already saved today'
                    : 'Opens guided prompts',
                onPressed: onOpenReflection,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: concentrationDone
                    ? 'Open Concentration Again'
                    : 'Complete Concentration',
                subtitle: concentrationDone
                    ? 'Already completed today'
                    : 'Choose goal, affirmation, or thought',
                onPressed: onOpenConcentration,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Open Daily History',
                subtitle: 'Review previous days',
                onPressed: onOpenDailyHistory,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
