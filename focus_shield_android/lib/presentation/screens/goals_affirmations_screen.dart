import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/affirmation.dart';
import '../../domain/models/goal.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class GoalsAffirmationsScreen extends StatefulWidget {
  const GoalsAffirmationsScreen({
    super.key,
    required this.goals,
    required this.affirmations,
    required this.onBack,
    required this.onAddGoal,
    required this.onDeleteGoal,
    required this.onAddAffirmation,
    required this.onDeleteAffirmation,
    required this.onSetFavoriteAffirmation,
    required this.onRefresh,
  });

  final List<Goal> goals;
  final List<Affirmation> affirmations;
  final VoidCallback onBack;
  final void Function(String title, String description) onAddGoal;
  final ValueChanged<int> onDeleteGoal;
  final void Function(String text, bool favorite) onAddAffirmation;
  final ValueChanged<int> onDeleteAffirmation;
  final ValueChanged<Affirmation> onSetFavoriteAffirmation;
  final VoidCallback onRefresh;

  @override
  State<GoalsAffirmationsScreen> createState() =>
      _GoalsAffirmationsScreenState();
}

class _GoalsAffirmationsScreenState extends State<GoalsAffirmationsScreen> {
  final _goalTitleController = TextEditingController();
  final _goalDescriptionController = TextEditingController();
  final _affirmationController = TextEditingController();
  bool _newAffirmationFavorite = false;

  @override
  void dispose() {
    _goalTitleController.dispose();
    _goalDescriptionController.dispose();
    _affirmationController.dispose();
    super.dispose();
  }

  void _addGoal() {
    widget.onAddGoal(
      _goalTitleController.text,
      _goalDescriptionController.text,
    );

    _goalTitleController.clear();
    _goalDescriptionController.clear();
  }

  void _addAffirmation() {
    widget.onAddAffirmation(
      _affirmationController.text,
      _newAffirmationFavorite,
    );

    _affirmationController.clear();
    setState(() {
      _newAffirmationFavorite = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteAffirmation = widget.affirmations
        .where((item) => item.favorite)
        .firstOrNull;

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
                'Goals & Affirmations',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        const Text('Personal discipline targets saved in SQLite'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Goals': '${widget.goals.length}',
              'Affirmations': '${widget.affirmations.length}',
              'Favorite': favoriteAffirmation == null ? 'None' : 'Set',
              'Storage': 'SQLite',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Goal'),
              const SizedBox(height: 12),
              TextField(
                key: const Key('goalTitleInput'),
                controller: _goalTitleController,
                decoration: const InputDecoration(
                  labelText: 'Goal title',
                  hintText: 'Master fully listening',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('goalDescriptionInput'),
                controller: _goalDescriptionController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe what this goal means.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Add Goal',
                subtitle: 'Save goal locally',
                onPressed: _addGoal,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saved Goals'),
              const SizedBox(height: 12),
              if (widget.goals.isEmpty)
                const Text('No goals saved yet.')
              else
                ...widget.goals.map((goal) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (goal.description.isNotEmpty) Text(goal.description),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => widget.onDeleteGoal(goal.id),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Remove Goal'),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Affirmation'),
              const SizedBox(height: 12),
              TextField(
                key: const Key('affirmationInput'),
                controller: _affirmationController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Affirmation',
                  hintText: 'I pause, I listen, and I follow my dreams.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _newAffirmationFavorite,
                onChanged: (value) =>
                    setState(() => _newAffirmationFavorite = value),
                title: const Text('Set as favorite affirmation'),
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Add Affirmation',
                subtitle: 'Save affirmation locally',
                onPressed: _addAffirmation,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saved Affirmations'),
              const SizedBox(height: 12),
              if (widget.affirmations.isEmpty)
                const Text('No affirmations saved yet.')
              else
                ...widget.affirmations.map((affirmation) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: affirmation.favorite
                            ? AppTheme.primary.withValues(alpha: 0.45)
                            : AppTheme.secondary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          affirmation.favorite ? '★ Favorite' : 'Affirmation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(affirmation.text),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (!affirmation.favorite)
                              OutlinedButton.icon(
                                onPressed: () => widget
                                    .onSetFavoriteAffirmation(affirmation),
                                icon: const Icon(Icons.star_border_rounded),
                                label: const Text('Set Favorite'),
                              ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  widget.onDeleteAffirmation(affirmation.id),
                              icon: const Icon(Icons.delete_outline_rounded),
                              label: const Text('Remove'),
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
          child: ActionButton(
            label: 'Refresh Goals & Affirmations',
            subtitle: 'Reload from SQLite',
            onPressed: widget.onRefresh,
          ),
        ),
      ],
    );
  }
}
