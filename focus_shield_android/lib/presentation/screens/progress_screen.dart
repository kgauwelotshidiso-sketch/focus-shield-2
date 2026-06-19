import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              Text('Level 2', style: Theme.of(context).textTheme.headlineMedium),
              const Text('45 XP total'),
              const SizedBox(height: 12),
              const LinearProgressIndicator(value: 0.45),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: const {
              'Current Streak': '0',
              'Longest Streak': '0',
              'Listening Wins': '0',
              'Badges': '3',
            },
          ),
        ),
        ShieldCard(
          child: Column(
            children: [
              ActionButton(label: 'Log Listening Win', onPressed: () {}),
              const SizedBox(height: 10),
              ActionButton(label: 'Complete Focus Session', onPressed: () {}),
              const SizedBox(height: 10),
              ActionButton(label: 'Complete Reflection', onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
