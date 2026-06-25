import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/focus_shield_state.dart';
import '../widgets/action_button.dart';
import '../widgets/protection_status_card.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.state,
    required this.onToggleProtection,
    required this.onSetCommitmentDays,
    required this.onOpenAccessibilitySettings,
    required this.onOpenProtectionDatabase,
    required this.onOpenGoalsAffirmations,
    required this.onOpenDebugCenter,
    required this.onOpenProductionReadiness,
    required this.onResetAppData,
  });

  final FocusShieldState state;
  final VoidCallback onToggleProtection;
  final ValueChanged<int> onSetCommitmentDays;
  final VoidCallback onOpenAccessibilitySettings;
  final VoidCallback onOpenProtectionDatabase;
  final VoidCallback onOpenGoalsAffirmations;
  final VoidCallback onOpenDebugCenter;
  final VoidCallback onOpenProductionReadiness;
  final VoidCallback onResetAppData;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const ProtectionStatusCard(),
        const SizedBox(height: 16),
        Text('Settings', style: Theme.of(context).textTheme.headlineLarge),
        const Text('Protection control center'),
        Text('Active day: ${state.lastActiveDate}'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: state.commitmentSet
              ? AppTheme.primary
              : AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Commitment Lock'),
              const SizedBox(height: 8),
              Text(
                state.commitmentSet
                    ? 'Commitment: ${state.commitmentDays} days. Days remaining: ${state.commitmentDaysRemaining}.'
                    : 'Protection cannot activate until a commitment duration is set.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [7, 14, 30, 90, 365].map((days) {
                  return ChoiceChip(
                    label: Text('$days days'),
                    selected: state.commitmentDays == days,
                    onSelected: state.commitmentActive
                        ? null
                        : (_) => onSetCommitmentDays(days),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                state.commitmentActive
                    ? 'In-app protection settings are locked during this commitment.'
                    : 'Choose a duration to activate the commitment gate.',
              ),
            ],
          ),
        ),
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
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Scanned Today': '${state.websitesScannedToday}',
              'New Today': '${state.newWebsitesScannedToday}',
              'Total Scanned': '${state.totalWebsitesScanned}',
              'Commitment': state.commitmentSet ? 'Set' : 'Required',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.warning,
          child: const Text(
            'System-wide VPN filtering is paused while the DNS route issue is repaired. Accessibility setup must be enabled manually by the user.',
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            children: [
              ActionButton(
                label: state.protectionEnabled
                    ? 'Turn Protection Off'
                    : 'Turn Protection On',
                subtitle: !state.commitmentSet
                    ? 'Set commitment first'
                    : state.commitmentActive && state.protectionEnabled
                    ? 'Locked until commitment ends'
                    : 'Uses in-app scanner protection',
                onPressed: onToggleProtection,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Open Accessibility Settings',
                subtitle: 'Enable Focus Shield manually',
                onPressed: onOpenAccessibilitySettings,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Protection Database',
                subtitle: 'Manage saved blocklist',
                onPressed: onOpenProtectionDatabase,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Goals & Affirmations',
                subtitle: 'Manage personal discipline system',
                onPressed: onOpenGoalsAffirmations,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'URL Analysis Engine',
                subtitle: 'Scanner and detection rules',
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Lock Layer',
                subtitle: 'Commitment gate active in-app',
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Production Readiness',
                subtitle: 'Android test and build checklist',
                onPressed: onOpenProductionReadiness,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Database Tools'),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Open Database Debug Center',
                subtitle: 'Attempts, state, reset tools',
                onPressed: onOpenDebugCenter,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Reset App Data',
                subtitle: 'Clear local saved state',
                onPressed: onResetAppData,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
