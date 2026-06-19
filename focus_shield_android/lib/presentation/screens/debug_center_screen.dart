import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/attempt_record.dart';
import '../../domain/models/focus_shield_state.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class DebugCenterScreen extends StatelessWidget {
  const DebugCenterScreen({
    super.key,
    required this.state,
    required this.attempts,
    required this.onBack,
    required this.onResetAppData,
    required this.onRefresh,
  });

  final FocusShieldState state;
  final List<AttemptRecord> attempts;
  final VoidCallback onBack;
  final VoidCallback onResetAppData;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final recovered = attempts.where((attempt) => attempt.recovered).length;
    final pending = attempts.where((attempt) => !attempt.recovered).length;

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
                'Database Debug Center',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        const Text('SQLite data tools and attempt history'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: {
              'XP': '${state.xp}',
              'Level': '${state.level}',
              'Mission': '${state.listeningWinsToday}/${state.missionTarget}',
              'Coach': '${state.coachScore}%',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Attempts': '${attempts.length}',
              'Recovered': '$recovered',
              'Pending': '$pending',
              'Recovery': '${state.recoveryRate}%',
            },
          ),
        ),
        ShieldCard(
          borderColor: state.protectionEnabled ? AppTheme.primary : AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Protection State'),
              const SizedBox(height: 8),
              Text('Protection enabled: ${state.protectionEnabled ? "YES" : "NO"}'),
              Text('Morning command set: ${state.morningCommandSet ? "YES" : "NO"}'),
              Text('Focus sessions today: ${state.focusSessionsToday}'),
              Text('Reflections today: ${state.reflectionsToday}'),
              Text('Concentration wins today: ${state.concentrationWinsToday}'),
              Text('End reviews today: ${state.endReviewsToday}'),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Attempt History'),
              const SizedBox(height: 12),
              if (attempts.isEmpty)
                const Text('No blocked attempts saved yet.')
              else
                ...attempts.map((attempt) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: attempt.recovered
                            ? AppTheme.primary.withOpacity(0.35)
                            : AppTheme.warning.withOpacity(0.45),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attempt.domain,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('Category: ${attempt.category}'),
                        Text('Confidence: ${(attempt.confidence * 100).round()}%'),
                        Text('Recovered: ${attempt.recovered ? "YES" : "NO"}'),
                        Text('Saved: ${attempt.createdAt.toIso8601String()}'),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.warning,
          child: Column(
            children: [
              ActionButton(
                label: 'Refresh Database View',
                subtitle: 'Reload saved data',
                onPressed: onRefresh,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Reset App Data',
                subtitle: 'Clear local SQLite app state',
                onPressed: onResetAppData,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
