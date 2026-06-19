import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/focus_shield_state.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.state,
    required this.onToggleProtection,
  });

  final FocusShieldState state;
  final VoidCallback onToggleProtection;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineLarge),
        const Text('Protection control center'),
        const SizedBox(height: 18),
        ShieldCard(
          child: StatGrid(
            items: {
              'Protection': state.protectionEnabled ? 'ON' : 'OFF',
              'Attempts': '${state.blockedAttempts}',
              'Recovery': '${state.recoveryRate}%',
              'XP': '${state.xp}',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.warning,
          child: const Text('Real system-wide filtering will require Android VPN/DNS service.'),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            children: [
              ActionButton(
                label: state.protectionEnabled ? 'Turn Protection Off' : 'Turn Protection On',
                onPressed: onToggleProtection,
              ),
              const SizedBox(height: 10),
              ActionButton(label: 'Protection Database', onPressed: () {}),
              const SizedBox(height: 10),
              ActionButton(label: 'URL Analysis Engine', onPressed: () {}),
              const SizedBox(height: 10),
              ActionButton(label: 'Lock Layer', onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
