import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/focus_shield_state.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.state,
    required this.onNavigate,
    required this.onListeningWin,
  });

  final FocusShieldState state;
  final ValueChanged<int> onNavigate;
  final VoidCallback onListeningWin;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(AppConstants.appName, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 4),
        const Text('Discipline + protection dashboard'),
        Text('Active day: ${state.lastActiveDate}'),
        const SizedBox(height: 18),
        ShieldCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today’s Mission'),
              Text(
                '${state.listeningWinsToday} / ${state.missionTarget}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: state.missionComplete ? AppTheme.primary : AppTheme.warning,
                    ),
              ),
              const Text('Pause and fully listen before speaking at least 3 times today.'),
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
              'XP': '${state.xp}',
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
