import 'package:flutter/material.dart';

import '../../domain/models/focus_shield_state.dart';
import '../../domain/services/coach_engine.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({
    super.key,
    required this.state,
    required this.onMorningCommand,
    required this.onEndReview,
    required this.onNavigate,
  });

  final FocusShieldState state;
  final VoidCallback onMorningCommand;
  final VoidCallback onEndReview;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final summary = CoachEngine().analyze(
      listeningWins: state.listeningWinsToday,
      targetWins: state.missionTarget,
      recoveryRate: state.recoveryRate,
      morningCommandSet: state.morningCommandSet,
    );

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Coach', style: Theme.of(context).textTheme.headlineLarge),
        const Text('Daily operating system'),
        const SizedBox(height: 18),
        ShieldCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Main Coach Command'),
              Text(summary.command, style: Theme.of(context).textTheme.headlineMedium),
              Text('Weakness: ${summary.weakness}'),
            ],
          ),
        ),
        ShieldCard(
          child: StatGrid(
            items: {
              'Coach Score': '${state.coachScore}%',
              'Mission': '${state.listeningWinsToday}/${state.missionTarget}',
              'Recovery': '${state.recoveryRate}%',
              'Level': '${state.level}',
            },
          ),
        ),
        ShieldCard(
          child: Column(
            children: [
              ActionButton(
                label: state.morningCommandSet ? 'Morning Command Set' : 'Set Morning Command',
                subtitle: state.morningCommandSet ? 'Ready' : '+10 XP',
                onPressed: onMorningCommand,
              ),
              const SizedBox(height: 10),
              ActionButton(label: 'Save End Review', subtitle: '+15 XP', onPressed: onEndReview),
              const SizedBox(height: 10),
              ActionButton(label: 'Open Progress', onPressed: () => onNavigate(3)),
              const SizedBox(height: 10),
              ActionButton(label: 'Open Recovery', onPressed: () => onNavigate(2)),
            ],
          ),
        ),
      ],
    );
  }
}
