import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/daily_summary.dart';
import '../../domain/models/focus_shield_state.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class DailyHistoryScreen extends StatelessWidget {
  const DailyHistoryScreen({
    super.key,
    required this.state,
    required this.summaries,
    required this.onBack,
  });

  final FocusShieldState state;
  final List<DailySummary> summaries;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Daily History',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        const Text('Completed days, streaks, and mission history'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Current Streak': '${state.currentStreak}',
              'Longest Streak': '${state.longestStreak}',
              'Completed Days': '${state.completedDays}',
              'Saved Days': '${summaries.length}',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today'),
              const SizedBox(height: 8),
              Text('Active day: ${state.lastActiveDate}'),
              Text(
                'Mission: ${state.listeningWinsToday}/${state.missionTarget}',
              ),
              Text('Mission complete: ${state.missionComplete ? "YES" : "NO"}'),
              Text('XP total: ${state.xp}'),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saved Daily Summaries'),
              const SizedBox(height: 12),
              if (summaries.isEmpty)
                const Text('No completed day summaries saved yet.')
              else
                ...summaries.map((summary) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: summary.missionComplete
                            ? AppTheme.primary.withValues(alpha: 0.35)
                            : AppTheme.warning.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.dateKey,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Mission: ${summary.listeningWins}/${summary.missionTarget}',
                        ),
                        Text(
                          'Mission complete: ${summary.missionComplete ? "YES" : "NO"}',
                        ),
                        Text('Focus sessions: ${summary.focusSessions}'),
                        Text('Reflections: ${summary.reflections}'),
                        Text('Recovery: ${summary.recoveryRate}%'),
                        Text('Coach score: ${summary.coachScore}%'),
                        Text('XP total: ${summary.xpTotal}'),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}
