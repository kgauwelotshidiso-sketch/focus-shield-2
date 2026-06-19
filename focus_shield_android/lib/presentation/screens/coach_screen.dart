import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/attempt_record.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/services/coach_engine.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({
    super.key,
    required this.state,
    required this.attempts,
    required this.onMorningCommand,
    required this.onEndReview,
    required this.onNavigate,
  });

  final FocusShieldState state;
  final List<AttemptRecord> attempts;
  final VoidCallback onMorningCommand;
  final VoidCallback onEndReview;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final coachEngine = CoachEngine();

    final summary = coachEngine.analyze(
      listeningWins: state.listeningWinsToday,
      targetWins: state.missionTarget,
      recoveryRate: state.recoveryRate,
      morningCommandSet: state.morningCommandSet,
    );

    final recoveryInsight = coachEngine.analyzeRecoveryHistory(attempts);
    final borderColor = recoveryInsight.pendingAttempts == 0 ? AppTheme.primary : AppTheme.warning;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Coach', style: Theme.of(context).textTheme.headlineLarge),
        const Text('Daily operating system'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: borderColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Main Coach Command'),
              const SizedBox(height: 8),
              Text(
                recoveryInsight.pendingAttempts > 0 ? recoveryInsight.command : summary.command,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text('Weakness: ${recoveryInsight.pendingAttempts > 0 ? "Recovery Discipline" : summary.weakness}'),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: {
              'Coach Score': '${state.coachScore}%',
              'Mission': '${state.listeningWinsToday}/${state.missionTarget}',
              'Recovery': '${recoveryInsight.recoveryRate}%',
              'Level': '${state.level}',
            },
          ),
        ),
        ShieldCard(
          borderColor: borderColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recovery Intelligence'),
              const SizedBox(height: 12),
              StatGrid(
                items: {
                  'Attempts': '${recoveryInsight.totalAttempts}',
                  'Recovered': '${recoveryInsight.recoveredAttempts}',
                  'Pending': '${recoveryInsight.pendingAttempts}',
                  'Grade': recoveryInsight.grade,
                },
              ),
              const SizedBox(height: 12),
              Text(recoveryInsight.warning),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today’s Coach Plan'),
              const SizedBox(height: 8),
              Text('1. Set your morning command.'),
              Text('2. Complete your listening mission.'),
              Text('3. Recover every blocked attempt.'),
              Text('4. Save your end review.'),
            ],
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
              ActionButton(
                label: 'Save End Review',
                subtitle: '+15 XP',
                onPressed: onEndReview,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Open Progress',
                onPressed: () => onNavigate(3),
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Open Recovery',
                onPressed: () => onNavigate(2),
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Open Database Debug Center',
                subtitle: 'Close pending attempts',
                onPressed: () => onNavigate(5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
