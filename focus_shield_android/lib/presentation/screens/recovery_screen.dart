import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';

class RecoveryScreen extends StatelessWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Recovery', style: Theme.of(context).textTheme.headlineLarge),
        const Text('Reset and return'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            children: [
              const Icon(Icons.spa_rounded, size: 82, color: AppTheme.primary),
              const SizedBox(height: 10),
              Text('Breathe', style: Theme.of(context).textTheme.headlineMedium),
              const Text('Pause, breathe, and return to your goals.'),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Mark Latest As Recovered',
                onPressed: () {},
              ),
            ],
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
      ],
    );
  }
}
