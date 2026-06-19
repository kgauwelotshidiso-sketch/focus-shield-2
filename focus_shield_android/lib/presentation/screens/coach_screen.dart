import 'package:flutter/material.dart';

import '../../domain/services/coach_engine.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = CoachEngine().analyze(
      listeningWins: 0,
      targetWins: 3,
      recoveryRate: 100,
      morningCommandSet: false,
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
              Text(
                summary.command,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text('Weakness: ${summary.weakness}'),
            ],
          ),
        ),
        ShieldCard(
          child: StatGrid(
            items: {
              'Daily Score': '${summary.score}%',
              'Mission': '0/3',
              'Recovery': '100%',
              'Level': '2',
            },
          ),
        ),
        ShieldCard(
          child: Column(
            children: [
              ActionButton(label: 'Set Morning Command', onPressed: () {}),
              const SizedBox(height: 10),
              ActionButton(label: 'Save End Review', onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
