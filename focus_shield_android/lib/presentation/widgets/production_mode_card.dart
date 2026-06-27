import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import 'action_button.dart';
import 'shield_card.dart';
import 'stat_grid.dart';

class ProductionModeCard extends StatefulWidget {
  const ProductionModeCard({super.key, this.showControls = true});

  final bool showControls;

  @override
  State<ProductionModeCard> createState() => _ProductionModeCardState();
}

class _ProductionModeCardState extends State<ProductionModeCard> {
  static const String _modeKey = 'phase6i_real_use_mode';
  static const String _pauseReasonKey = 'phase6i_last_pause_reason';
  static const String _pauseAtKey = 'phase6i_last_pause_at';

  bool _realUseMode = true;
  String _lastPauseReason = 'No pause recorded.';
  String _lastPauseAt = 'Not recorded';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _realUseMode = prefs.getBool(_modeKey) ?? true;
      _lastPauseReason =
          prefs.getString(_pauseReasonKey) ?? 'No pause recorded.';
      _lastPauseAt = prefs.getString(_pauseAtKey) ?? 'Not recorded';
      _loaded = true;
    });
  }

  Future<void> _setRealUseMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, value);

    if (!mounted) return;

    setState(() {
      _realUseMode = value;
    });
  }

  Future<void> _recordPauseReason(String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();

    await prefs.setString(_pauseReasonKey, reason);
    await prefs.setString(_pauseAtKey, now);

    if (!mounted) return;

    setState(() {
      _lastPauseReason = reason;
      _lastPauseAt = now;
    });
  }

  Future<void> _showTestingModeWarning() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Switch to Testing Mode?'),
          content: const Text(
            'Testing Mode shows manual scanner tools and is meant for development only. Real Use Mode is safer for daily protection.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Stay in Real Use Mode'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _setRealUseMode(false);
              },
              child: const Text('Use Testing Mode'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPauseReasonDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Protection pause reason'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'Example: testing build, fixing settings, or debugging.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final reason = controller.text.trim().isEmpty
                    ? 'No reason written.'
                    : controller.text.trim();

                Navigator.of(context).pop();
                _recordPauseReason(reason);
              },
              child: const Text('Save Reason'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const ShieldCard(
        borderColor: AppTheme.warning,
        child: Text('Loading production mode...'),
      );
    }

    return ShieldCard(
      borderColor: _realUseMode ? AppTheme.primary : AppTheme.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Production Lockdown'),
          const SizedBox(height: 12),
          StatGrid(
            items: {
              'Mode': _realUseMode ? 'Real Use' : 'Testing',
              'Testing Tools': _realUseMode ? 'Hidden' : 'Visible',
              'Pause Log': _lastPauseAt == 'Not recorded' ? 'Clear' : 'Saved',
              'Status': _realUseMode ? 'Daily use' : 'Development',
            },
          ),
          const SizedBox(height: 12),
          Text(
            _realUseMode
                ? 'Real Use Mode keeps the dashboard focused on protection instead of test tools.'
                : 'Testing Mode is active. Manual scanner tools are visible for development checks.',
          ),
          const SizedBox(height: 8),
          Text('Last pause reason: $_lastPauseReason'),
          if (widget.showControls) ...[
            const SizedBox(height: 12),
            ActionButton(
              label: _realUseMode
                  ? 'Stay in Real Use Mode'
                  : 'Return to Real Use Mode',
              subtitle: _realUseMode
                  ? 'Recommended for daily protection'
                  : 'Hide testing tools again',
              onPressed: () => _setRealUseMode(true),
            ),
            const SizedBox(height: 10),
            ActionButton(
              label: 'Enable Testing Mode',
              subtitle: 'Shows manual scanner tools',
              onPressed: _showTestingModeWarning,
            ),
            const SizedBox(height: 10),
            ActionButton(
              label: 'Log Protection Pause Reason',
              subtitle: 'Record why protection was paused or tested',
              onPressed: _showPauseReasonDialog,
            ),
          ],
        ],
      ),
    );
  }
}

class TestingToolsVisibilityGate extends StatefulWidget {
  const TestingToolsVisibilityGate({super.key, required this.child});

  final Widget child;

  @override
  State<TestingToolsVisibilityGate> createState() =>
      _TestingToolsVisibilityGateState();
}

class _TestingToolsVisibilityGateState
    extends State<TestingToolsVisibilityGate> {
  static const String _modeKey = 'phase6i_real_use_mode';

  bool _realUseMode = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _realUseMode = prefs.getBool(_modeKey) ?? true;
      _loaded = true;
    });
  }

  Future<void> _showToolsTemporarily() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, false);

    if (!mounted) return;

    setState(() {
      _realUseMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const ShieldCard(
        borderColor: AppTheme.warning,
        child: Text('Loading testing tools visibility...'),
      );
    }

    if (!_realUseMode) {
      return widget.child;
    }

    return ShieldCard(
      borderColor: AppTheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Testing Tools Hidden'),
          const SizedBox(height: 8),
          const Text(
            'Real Use Mode is active, so manual scanner tools are hidden from the main daily-use view.',
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Show Testing Tools',
            subtitle: 'Switch to Testing Mode',
            onPressed: _showToolsTemporarily,
          ),
        ],
      ),
    );
  }
}
