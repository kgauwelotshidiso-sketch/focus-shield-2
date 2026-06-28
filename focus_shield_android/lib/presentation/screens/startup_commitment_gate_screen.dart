import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/focus_shield_state.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class StartupCommitmentGateScreen extends StatelessWidget {
  const StartupCommitmentGateScreen({
    super.key,
    required this.state,
    required this.onSetCommitmentDays,
    required this.onOpenAccessibilitySettings,
    required this.onOpenVpnSetup,
    required this.onContinueToApp,
  });

  final FocusShieldState state;
  final ValueChanged<int> onSetCommitmentDays;
  final VoidCallback onOpenAccessibilitySettings;
  final VoidCallback onOpenVpnSetup;
  final VoidCallback onContinueToApp;

  @override
  Widget build(BuildContext context) {
    final commitmentSet = state.commitmentSet;
    final commitmentActive = commitmentSet;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Setup must be completed before daily-use features unlock.',
            ),
            const SizedBox(height: 18),

            ShieldCard(
              borderColor: commitmentSet ? AppTheme.primary : AppTheme.warning,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commitmentSet
                        ? 'Step 1 complete — Commitment locked'
                        : 'Step 1 — Choose your commitment',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    commitmentSet
                        ? 'Commitment: ${state.commitmentDays} days.\nDays remaining: ${state.commitmentDaysRemaining}.'
                        : 'Choose how many days Focus Shield should protect your discipline before the main app unlocks.',
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [7, 14, 30, 90, 365].map((days) {
                      return ChoiceChip(
                        label: Text('$days days'),
                        selected: state.commitmentDays == days,
                        onSelected: commitmentActive
                            ? null
                            : (_) => onSetCommitmentDays(days),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            ShieldCard(
              borderColor: commitmentSet ? AppTheme.primary : AppTheme.warning,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 2 — Enable Accessibility Detection',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'After choosing a commitment, enable Focus Shield in Android Accessibility Settings so it can detect risky visible website text.',
                  ),
                  const SizedBox(height: 12),
                  ActionButton(
                    label: 'Open Accessibility Settings',
                    subtitle: commitmentSet
                        ? 'Enable Focus Shield manually'
                        : 'Choose commitment first',
                    onPressed: commitmentSet
                        ? onOpenAccessibilitySettings
                        : () {},
                  ),
                ],
              ),
            ),

            ShieldCard(
              borderColor: commitmentSet ? AppTheme.primary : AppTheme.warning,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 3 — Allow VPN Setup',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'System-wide VPN filtering is still paused while the DNS route issue is repaired, but this setup step prepares the Android protection layer for the next production stage.',
                  ),
                  const SizedBox(height: 12),
                  ActionButton(
                    label: 'Open VPN Setup',
                    subtitle: commitmentSet
                        ? 'Prepare Android protection permission'
                        : 'Choose commitment first',
                    onPressed: commitmentSet ? onOpenVpnSetup : () {},
                  ),
                ],
              ),
            ),

            ShieldCard(
              borderColor: commitmentSet
                  ? AppTheme.secondary
                  : AppTheme.warning,
              child: StatGrid(
                items: {
                  'Commitment': commitmentSet ? 'Set' : 'Required',
                  'Protection': state.protectionEnabled ? 'ON' : 'Locked',
                  'Days Left': commitmentSet
                      ? '${state.commitmentDaysRemaining}'
                      : '0',
                  'App Access': commitmentSet ? 'Unlocked' : 'Blocked',
                },
              ),
            ),

            ActionButton(
              label: commitmentSet
                  ? 'Continue to Focus Shield'
                  : 'Choose Commitment First',
              subtitle: commitmentSet
                  ? 'Open protected daily-use dashboard'
                  : 'Main features stay locked until commitment is set',
              onPressed: commitmentSet ? onContinueToApp : () {},
            ),

            const SizedBox(height: 18),
            ShieldCard(
              borderColor: AppTheme.primary,
              child: const Text(
                'Normal Android apps cannot make themselves impossible to uninstall. Focus Shield will use commitment locking, Accessibility setup, VPN setup, and tamper-resistance reminders to make quitting harder and more intentional.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
