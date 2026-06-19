import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onNavigate,
  });

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 4),
        const Text('Discipline + protection dashboard'),
        const SizedBox(height: 18),
        ShieldCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today’s Mission'),
              Text(
                '0 / 3',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                    ),
              ),
              const Text('Pause and fully listen before speaking at least 3 times today.'),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Log Listening Win',
                onPressed: () => onNavigate(3),
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: const {
              'Shield': 'Active',
              'Protection': 'ON',
              'Level': '2',
              'XP': '45',
            },
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
              ActionButton(label: 'Coach', onPressed: () => onNavigate(4)),
              const SizedBox(height: 10),
              ActionButton(label: 'Settings', onPressed: () => onNavigate(5)),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
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
