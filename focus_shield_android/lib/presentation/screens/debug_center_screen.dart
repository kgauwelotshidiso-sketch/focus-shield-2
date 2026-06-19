import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/attempt_record.dart';
import '../../domain/models/focus_shield_state.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

enum AttemptFilter { all, pending, recovered }

class DebugCenterScreen extends StatefulWidget {
  const DebugCenterScreen({
    super.key,
    required this.state,
    required this.attempts,
    required this.onBack,
    required this.onResetAppData,
    required this.onRefresh,
    required this.onMarkAttemptRecovered,
  });

  final FocusShieldState state;
  final List<AttemptRecord> attempts;
  final VoidCallback onBack;
  final VoidCallback onResetAppData;
  final VoidCallback onRefresh;
  final ValueChanged<int> onMarkAttemptRecovered;

  @override
  State<DebugCenterScreen> createState() => _DebugCenterScreenState();
}

class _DebugCenterScreenState extends State<DebugCenterScreen> {
  AttemptFilter _filter = AttemptFilter.all;
  AttemptRecord? _selectedAttempt;

  List<AttemptRecord> get _filteredAttempts {
    final attempts = [...widget.attempts];

    switch (_filter) {
      case AttemptFilter.pending:
        attempts.removeWhere((attempt) => attempt.recovered);
        break;
      case AttemptFilter.recovered:
        attempts.removeWhere((attempt) => !attempt.recovered);
        break;
      case AttemptFilter.all:
        break;
    }

    return attempts;
  }

  String get _coachFeedback {
    final pending = widget.attempts
        .where((attempt) => !attempt.recovered)
        .length;

    if (widget.attempts.isEmpty) {
      return 'No saved attempts yet. Keep protection active and continue building discipline.';
    }

    if (pending == 0) {
      return 'Strong recovery discipline. Every saved attempt has been closed.';
    }

    if (pending == 1) {
      return 'One attempt still needs recovery. Close the loop before moving on.';
    }

    return '$pending attempts still need recovery. Your next mission is not perfection — it is returning quickly.';
  }

  @override
  Widget build(BuildContext context) {
    final recovered = widget.attempts
        .where((attempt) => attempt.recovered)
        .length;
    final pending = widget.attempts
        .where((attempt) => !attempt.recovered)
        .length;
    final filteredAttempts = _filteredAttempts;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
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
        const Text('Attempt history, recovery intelligence, and SQLite tools'),
        Text('Active day: ${widget.state.lastActiveDate}'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: {
              'XP': '${widget.state.xp}',
              'Level': '${widget.state.level}',
              'Mission':
                  '${widget.state.listeningWinsToday}/${widget.state.missionTarget}',
              'Coach': '${widget.state.coachScore}%',
              'Streak': '${widget.state.currentStreak}',
              'Best': '${widget.state.longestStreak}',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Attempts': '${widget.attempts.length}',
              'Recovered': '$recovered',
              'Pending': '$pending',
              'Recovery': '${widget.state.recoveryRate}%',
            },
          ),
        ),
        ShieldCard(
          borderColor: pending == 0 ? AppTheme.primary : AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recovery Intelligence'),
              const SizedBox(height: 8),
              Text(_coachFeedback),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Attempt Filters'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == AttemptFilter.all,
                    onSelected: (_) =>
                        setState(() => _filter = AttemptFilter.all),
                  ),
                  ChoiceChip(
                    label: const Text('Pending'),
                    selected: _filter == AttemptFilter.pending,
                    onSelected: (_) =>
                        setState(() => _filter = AttemptFilter.pending),
                  ),
                  ChoiceChip(
                    label: const Text('Recovered'),
                    selected: _filter == AttemptFilter.recovered,
                    onSelected: (_) =>
                        setState(() => _filter = AttemptFilter.recovered),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_selectedAttempt != null)
          ShieldCard(
            borderColor: _selectedAttempt!.recovered
                ? AppTheme.primary
                : AppTheme.warning,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attempt Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Domain: ${_selectedAttempt!.domain}'),
                Text('Category: ${_selectedAttempt!.category}'),
                Text(
                  'Confidence: ${(_selectedAttempt!.confidence * 100).round()}%',
                ),
                Text(
                  'Recovered: ${_selectedAttempt!.recovered ? "YES" : "NO"}',
                ),
                Text('Saved: ${_selectedAttempt!.createdAt.toIso8601String()}'),
                const SizedBox(height: 12),
                if (!_selectedAttempt!.recovered)
                  ActionButton(
                    label: 'Mark This Attempt Recovered',
                    subtitle: 'Close this recovery loop',
                    onPressed: () {
                      widget.onMarkAttemptRecovered(_selectedAttempt!.id);
                      setState(() {
                        _selectedAttempt = _selectedAttempt!.copyWith(
                          recovered: true,
                        );
                      });
                    },
                  ),
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
              if (filteredAttempts.isEmpty)
                const Text('No attempts match this filter.')
              else
                ...filteredAttempts.map((attempt) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: attempt.recovered
                            ? AppTheme.primary.withValues(alpha: 0.35)
                            : AppTheme.warning.withValues(alpha: 0.45),
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
                        Text(
                          'Confidence: ${(attempt.confidence * 100).round()}%',
                        ),
                        Text('Recovered: ${attempt.recovered ? "YES" : "NO"}'),
                        Text('Saved: ${attempt.createdAt.toIso8601String()}'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  setState(() => _selectedAttempt = attempt),
                              icon: const Icon(Icons.info_outline_rounded),
                              label: const Text('Details'),
                            ),
                            if (!attempt.recovered)
                              OutlinedButton.icon(
                                onPressed: () =>
                                    widget.onMarkAttemptRecovered(attempt.id),
                                icon: const Icon(
                                  Icons.check_circle_outline_rounded,
                                ),
                                label: const Text('Mark Recovered'),
                              ),
                          ],
                        ),
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
                onPressed: widget.onRefresh,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Reset App Data',
                subtitle: 'Clear local SQLite app state',
                onPressed: widget.onResetAppData,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
