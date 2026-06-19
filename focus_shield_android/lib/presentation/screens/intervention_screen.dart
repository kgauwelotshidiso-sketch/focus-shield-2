import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';

class InterventionScreen extends StatelessWidget {
  const InterventionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Intervention', style: Theme.of(context).textTheme.headlineLarge),
        const Text('Temptation detected'),
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
              const Text('Your future is worth more than this moment.'),
            ],
          ),
        ),
        ShieldCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('“${AppConstants.affirmation}”'),
              const SizedBox(height: 12),
              ActionButton(label: 'Read Goals', onPressed: () {}),
              const SizedBox(height: 10),
              ActionButton(label: 'Start Focus Session', onPressed: () {}),
              const SizedBox(height: 10),
              ActionButton(label: 'Journal Thoughts', onPressed: () {}),
              const SizedBox(height: 10),
              ActionButton(label: 'Breathing Exercise', onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
