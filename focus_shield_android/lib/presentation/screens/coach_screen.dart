import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/attempt_record.dart';
import '../../domain/models/focus_shield_state.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({
    super.key,
    required this.state,
    required this.attempts,
    required this.onMorningCommand,
    required this.onEndReview,
    this.onNavigate,
  });

  final FocusShieldState state;
  final List<AttemptRecord> attempts;
  final VoidCallback onMorningCommand;
  final VoidCallback onEndReview;
  final ValueChanged<int>? onNavigate;

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  static const _afternoonCommandKey = 'phase6p_afternoon_command_set';
  static const _eveningCommandKey = 'phase6p_evening_command_set';
  static const _lastCommandDateKey = 'phase6p_last_command_date';

  bool _afternoonCommandSet = false;
  bool _eveningCommandSet = false;
  bool _loaded = false;

  String get _today {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  List<String> get _motivations => const [
    'Discipline is built by the next choice, not by yesterday’s mood.',
    'Pause first. Choose your future before your feelings choose for you.',
    'A strong day is made from small wins repeated on purpose.',
    'Your standard is simple: protect your attention and return quickly.',
    'The moment you want to quit is the moment the shield matters most.',
    'You are not chasing comfort. You are training control.',
    'Today, win the small battle before it becomes a big one.',
  ];

  String get _dailyMotivation {
    final dayNumber = DateTime.now().day;
    return _motivations[dayNumber % _motivations.length];
  }

  @override
  void initState() {
    super.initState();
    _loadCommands();
  }

  Future<void> _loadCommands() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_lastCommandDateKey);

    if (lastDate != _today) {
      await prefs.setString(_lastCommandDateKey, _today);
      await prefs.setBool(_afternoonCommandKey, false);
      await prefs.setBool(_eveningCommandKey, false);
    }

    if (!mounted) return;
    setState(() {
      _afternoonCommandSet = prefs.getBool(_afternoonCommandKey) ?? false;
      _eveningCommandSet = prefs.getBool(_eveningCommandKey) ?? false;
      _loaded = true;
    });
  }

  Future<void> _setAfternoonCommand() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCommandDateKey, _today);
    await prefs.setBool(_afternoonCommandKey, true);
    if (!mounted) return;
    setState(() => _afternoonCommandSet = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Afternoon Command set. Return to the mission.'),
      ),
    );
  }

  Future<void> _setEveningCommand() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCommandDateKey, _today);
    await prefs.setBool(_eveningCommandKey, true);
    if (!mounted) return;
    setState(() => _eveningCommandSet = true);
    widget.onEndReview();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Evening Review saved. Day closed with discipline.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingRecoveries = widget.state.pendingRecoveries;
    final morningSet = widget.state.morningCommandSet;
    final afternoonSet = _afternoonCommandSet;
    final eveningSet = _eveningCommandSet || widget.state.endReviewsToday > 0;
    final commandsComplete = morningSet && afternoonSet && eveningSet;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Coach', style: Theme.of(context).textTheme.headlineLarge),
        const Text('Daily command center'),
        Text('Active day: ${widget.state.lastActiveDate}'),
        const SizedBox(height: 18),

        ShieldCard(
          borderColor: commandsComplete ? AppTheme.primary : AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily Discipline Motivation'),
              const SizedBox(height: 10),
              Text(
                '“$_dailyMotivation”',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.lightBlueAccent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                commandsComplete
                    ? 'All command points are complete today.'
                    : 'Reminder: set Morning, Afternoon, and Evening commands before the day ends.',
              ),
            ],
          ),
        ),

        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: {
              'Coach Score': '${widget.state.coachScore}%',
              'Morning': morningSet ? 'Set' : 'Missing',
              'Afternoon': afternoonSet ? 'Set' : 'Missing',
              'Evening': eveningSet ? 'Done' : 'Missing',
              'Recovery': '${widget.state.recoveryRate}%',
              'Pending': '$pendingRecoveries',
            },
          ),
        ),

        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Morning Command'),
              const SizedBox(height: 8),
              const Text(
                'Set your standard before the day starts: pause, listen, and protect your goals.',
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: morningSet
                    ? 'Morning Command Set'
                    : 'Set Morning Command',
                subtitle: morningSet ? 'Already complete today' : '+10 XP',
                onPressed: morningSet ? () {} : widget.onMorningCommand,
              ),
            ],
          ),
        ),

        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Afternoon Command'),
              const SizedBox(height: 8),
              const Text(
                'Midday reset: return to your mission before tiredness or emotion takes control.',
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: afternoonSet
                    ? 'Afternoon Command Set'
                    : 'Set Afternoon Command',
                subtitle: afternoonSet
                    ? 'Midday reset complete'
                    : 'Refocus for the second half',
                onPressed: afternoonSet ? () {} : _setAfternoonCommand,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Evening Review'),
              const SizedBox(height: 8),
              const Text(
                'Close the day properly: review what pulled you away, what you recovered from, and what standard you will protect tomorrow.',
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: eveningSet
                    ? 'Evening Review Complete'
                    : 'Complete Evening Review',
                subtitle: eveningSet ? 'Day closed' : 'End review + reflection',
                onPressed: eveningSet ? () {} : _setEveningCommand,
              ),
            ],
          ),
        ),

        ShieldCard(
          borderColor: commandsComplete ? AppTheme.primary : AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Command Reminder Status'),
              const SizedBox(height: 10),
              Text(
                commandsComplete
                    ? 'No reminders needed. Your daily command system is complete.'
                    : 'Focus Shield should remind you outside the app if Morning, Afternoon, or Evening commands are still missing.',
              ),
              const SizedBox(height: 12),
              StatGrid(
                items: {
                  'Morning': morningSet ? 'Done' : 'Remind',
                  'Afternoon': afternoonSet ? 'Done' : 'Remind',
                  'Evening': eveningSet ? 'Done' : 'Remind',
                  'Outside Alerts': 'Ready',
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
              const Text('Coach Recovery View'),
              const SizedBox(height: 10),
              Text(
                widget.attempts.isEmpty
                    ? 'No risky attempts recorded. Stay ahead by completing your daily commands.'
                    : 'Recorded attempts: ${widget.attempts.length}. Pending recovery: $pendingRecoveries.',
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Open Recovery',
                subtitle: 'Review and recover',
                onPressed: () => widget.onNavigate?.call(2),
              ),
            ],
          ),
        ),

        if (!_loaded)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
