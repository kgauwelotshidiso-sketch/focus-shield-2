import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({
    super.key,
    required this.onBack,
    required this.onCompleted,
  });

  final VoidCallback onBack;
  final ValueChanged<int> onCompleted;

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  final _minutesController = TextEditingController(text: '10');
  Timer? _timer;
  int _remainingSeconds = 0;
  int _selectedMinutes = 10;
  bool _running = false;
  bool _completed = false;

  @override
  void dispose() {
    _timer?.cancel();
    _minutesController.dispose();
    super.dispose();
  }

  String get _countdownText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _start() {
    final parsed = int.tryParse(_minutesController.text.trim()) ?? 10;
    final minutes = parsed < 1
        ? 1
        : parsed > 180
        ? 180
        : parsed;

    _timer?.cancel();

    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
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

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _remainingSeconds = 0;
      _completed = false;
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

    widget.onCompleted(_selectedMinutes);
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
                'Focus Timer',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ],
        ),
        const Text('Set your own time, then complete a real focus session.'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Custom focus duration'),
              const SizedBox(height: 12),
              TextField(
                controller: _minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minutes',
                  hintText: '10',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  _remainingSeconds == 0 ? 'Ready' : _countdownText,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(fontSize: 54),
                ),
              ),
              const SizedBox(height: 18),
              ActionButton(
                label: _running ? 'Pause Timer' : 'Start Timer',
                subtitle: _running ? 'Keep control' : 'Begin countdown',
                onPressed: _running ? _pause : _start,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Reset Timer',
                subtitle: 'Clear current countdown',
                onPressed: _reset,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Complete Focus Session',
                subtitle: '+20 XP',
                onPressed: _finish,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text(
            'Focus rule: one session, one task, no switching until the countdown ends.',
          ),
        ),
      ],
    );
  }
}
