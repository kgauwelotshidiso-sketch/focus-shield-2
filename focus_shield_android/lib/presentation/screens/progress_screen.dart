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
    final xpProgress = (state.xp % 100) / 100;

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
              Text('Level ${state.level}', style: Theme.of(context).textTheme.headlineMedium),
              Text('${state.xp} XP total'),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: xpProgress),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: {
              'Listening Wins': '${state.listeningWinsToday}',
              'Focus Sessions': '${state.focusSessionsToday}',
              'Reflections': '${state.reflectionsToday}',
              'Concentration': '${state.concentrationWinsToday}',
            },
          ),
        ),
        ShieldCard(
          child: Column(
            children: [
              ActionButton(label: 'Log Listening Win', subtitle: '+10 XP', onPressed: onListeningWin),
              const SizedBox(height: 10),
              ActionButton(label: 'Complete Focus Session', subtitle: '+20 XP', onPressed: onFocusSession),
              const SizedBox(height: 10),
              ActionButton(label: 'Complete Reflection', subtitle: '+15 XP', onPressed: onReflection),
              const SizedBox(height: 10),
              ActionButton(label: 'Complete Concentration', subtitle: '+15 XP', onPressed: onConcentration),
              const SizedBox(height: 10),
              ActionButton(label: 'Open Daily History', onPressed: onOpenDailyHistory),
            ],
          ),
        ),
      ],
    );
  }
}
