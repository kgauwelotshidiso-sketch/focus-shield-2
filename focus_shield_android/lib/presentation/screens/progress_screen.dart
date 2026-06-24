import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/focus_shield_state.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    super.key,
    required this.state,
    required this.onListeningWin,
    required this.onFocusSession,
    required this.onReflection,
    required this.onConcentration,
    required this.onOpenDailyHistory,
  });

  final FocusShieldState state;
  final VoidCallback onListeningWin;
  final VoidCallback onFocusSession;
  final VoidCallback onReflection;
  final VoidCallback onConcentration;
  final VoidCallback onOpenDailyHistory;

  @override
  Widget build(BuildContext context) {
    final focusDone = state.focusSessionCompletedToday;
    final reflectionDone = state.reflectionCompletedToday;
    final concentrationDone = state.concentrationCompletedToday;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
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
              'Focus Task': focusDone ? 'Done' : 'Pending',
              'Reflection Task': reflectionDone ? 'Done' : 'Pending',
              'Concentration Task': concentrationDone ? 'Done' : 'Pending',
              'Daily Core': state.dailyCoreTasksComplete ? 'Complete' : 'Open',
              'Streak': '${state.currentStreak}',
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
                    ? 'Focus Session Completed'
                    : 'Complete Focus Session',
                subtitle: focusDone ? 'Completed today' : '+20 XP',
                onPressed: focusDone ? null : onFocusSession,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: reflectionDone
                    ? 'Reflection Completed'
                    : 'Complete Reflection',
                subtitle: reflectionDone ? 'Completed today' : '+15 XP',
                onPressed: reflectionDone ? null : onReflection,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: concentrationDone
                    ? 'Concentration Completed'
                    : 'Complete Concentration',
                subtitle: concentrationDone ? 'Completed today' : '+15 XP',
                onPressed: concentrationDone ? null : onConcentration,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Open Daily History',
                onPressed: onOpenDailyHistory,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
