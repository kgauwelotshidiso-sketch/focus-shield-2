import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/affirmation.dart';
import '../../domain/models/goal.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';

class ConcentrationScreen extends StatefulWidget {
  const ConcentrationScreen({
    super.key,
    required this.goals,
    required this.affirmations,
    required this.primaryAffirmation,
    required this.onBack,
    required this.onCompleted,
  });

  final List<Goal> goals;
  final List<Affirmation> affirmations;
  final String primaryAffirmation;
  final VoidCallback onBack;
  final ValueChanged<String> onCompleted;

  @override
  State<ConcentrationScreen> createState() => _ConcentrationScreenState();
}

class _ConcentrationScreenState extends State<ConcentrationScreen> {
  final _customThoughtController = TextEditingController();
  Timer? _timer;
  String _source = 'affirmation';
  int _remainingSeconds = 0;
  bool _running = false;
  bool _completed = false;

  @override
  void dispose() {
    _timer?.cancel();
    _customThoughtController.dispose();
    super.dispose();
  }

  String get _selectedThought {
    if (_source == 'goal') {
      if (widget.goals.isEmpty) {
        return 'Create a goal first, then concentrate on it.';
      }
      return widget.goals.first.title;
    }

    if (_source == 'custom') {
      final custom = _customThoughtController.text.trim();
      return custom.isEmpty
          ? 'Type one clear thought to concentrate on.'
          : custom;
    }

    if (widget.affirmations.isNotEmpty) {
      for (final affirmation in widget.affirmations) {
        if (affirmation.favorite) {
          return affirmation.text;
        }
      }
      return widget.affirmations.first.text;
    }

    if (widget.primaryAffirmation.trim().isNotEmpty) {
      return widget.primaryAffirmation;
    }

    return AppConstants.affirmation;
  }

  String get _countdownText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _start() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = 5 * 60;
      _running = true;
      _completed = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _finish();
        return;
      }

      setState(() {
        _remainingSeconds -= 1;
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() {
      _running = false;
    });
  }

  void _finish() {
    if (_completed) return;

    _timer?.cancel();

    setState(() {
      _running = false;
      _remainingSeconds = 0;
      _completed = true;
    });

    widget.onCompleted(_selectedThought);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Concentration',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ],
        ),
        const Text('Choose what to concentrate on, then hold attention.'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose concentration source'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Affirmation'),
                    selected: _source == 'affirmation',
                    onSelected: (_) => setState(() => _source = 'affirmation'),
                  ),
                  ChoiceChip(
                    label: const Text('Goal'),
                    selected: _source == 'goal',
                    onSelected: (_) => setState(() => _source = 'goal'),
                  ),
                  ChoiceChip(
                    label: const Text('Custom thought'),
                    selected: _source == 'custom',
                    onSelected: (_) => setState(() => _source = 'custom'),
                  ),
                ],
              ),
              if (_source == 'custom') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customThoughtController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Custom thought',
                    hintText: 'I pause, I listen, and I follow my dreams.',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Concentrate on this'),
              const SizedBox(height: 12),
              Text(
                _selectedThought,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.lightBlueAccent,
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  _remainingSeconds == 0 ? '05:00' : _countdownText,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(fontSize: 48),
                ),
              ),
              const SizedBox(height: 18),
              ActionButton(
                label: _running ? 'Pause Session' : 'Start 5 Minute Session',
                subtitle: _running
                    ? 'Keep attention steady'
                    : 'Begin concentration',
                onPressed: _running ? _pause : _start,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Complete Concentration',
                subtitle: '+15 XP',
                onPressed: _finish,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
