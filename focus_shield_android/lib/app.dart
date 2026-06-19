import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/sqlite_app_state_repository.dart';
import 'domain/models/attempt_record.dart';
import 'domain/models/focus_shield_state.dart';
import 'domain/models/settings_record.dart';
import 'domain/repositories/app_state_repository.dart';
import 'domain/services/protection_engine.dart';
import 'presentation/screens/coach_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/intervention_screen.dart';
import 'presentation/screens/progress_screen.dart';
import 'presentation/screens/recovery_screen.dart';
import 'presentation/screens/scanner_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/widgets/focus_shield_bottom_nav.dart';

class FocusShieldApp extends StatelessWidget {
  const FocusShieldApp({
    super.key,
    this.repository,
  });

  final AppStateRepository? repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Shield',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: FocusShieldShell(repository: repository),
    );
  }
}

class FocusShieldShell extends StatefulWidget {
  const FocusShieldShell({
    super.key,
    this.repository,
  });

  final AppStateRepository? repository;

  @override
  State<FocusShieldShell> createState() => _FocusShieldShellState();
}

class _FocusShieldShellState extends State<FocusShieldShell> {
  int _selectedIndex = 0;
  bool _showIntervention = false;
  bool _loading = true;
  ProtectionDecision? _lastBlockedDecision;
  FocusShieldState _state = FocusShieldState.initial();

  late final AppStateRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SqliteAppStateRepository();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final snapshot = await _repository.loadSnapshot();
    final settings = await _repository.loadSettings();

    if (!mounted) return;

    setState(() {
      _state = snapshot.state;
      _state.protectionEnabled = settings.protectionEnabled;
      _loading = false;
    });
  }

  void _persistState() {
    _repository.saveState(_state.copy());
  }

  void _persistSettings() {
    _repository.saveSettings(
      SettingsRecord(
        protectionEnabled: _state.protectionEnabled,
        lockEnabled: true,
        delayedDisableHours: 24,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void _goTo(int index) {
    setState(() {
      _selectedIndex = index;
      _showIntervention = false;
    });
  }

  void _openIntervention(ProtectionDecision decision) {
    setState(() {
      _lastBlockedDecision = decision;
      _state.blockedAttempts += 1;
      _selectedIndex = 1;
      _showIntervention = true;
    });

    _repository.saveAttempt(
      AttemptRecord(
        id: 0,
        domain: decision.domain,
        category: decision.category,
        confidence: decision.confidence,
        recovered: false,
        createdAt: DateTime.now(),
      ),
    );

    _persistState();
  }

  void _returnToScanner() {
    setState(() {
      _selectedIndex = 1;
      _showIntervention = false;
    });
  }

  void _logListeningWin() {
    setState(() {
      _state.listeningWinsToday += 1;
      _state.xp += 10;
    });

    _persistState();
  }

  void _completeFocusSession() {
    setState(() {
      _state.focusSessionsToday += 1;
      _state.xp += 20;
    });

    _persistState();
  }

  void _completeReflection() {
    setState(() {
      _state.reflectionsToday += 1;
      _state.xp += 15;
    });

    _persistState();
  }

  void _completeConcentration() {
    setState(() {
      _state.concentrationWinsToday += 1;
      _state.xp += 15;
    });

    _persistState();
  }

  void _markRecovered() {
    setState(() {
      if (_state.pendingRecoveries > 0) {
        _state.recoveredAttempts += 1;
        _state.xp += 10;
      }
      _showIntervention = false;
      _selectedIndex = 2;
    });

    _repository.markLatestAttemptRecovered();
    _persistState();
  }

  void _setMorningCommand() {
    setState(() {
      if (!_state.morningCommandSet) {
        _state.xp += 10;
      }
      _state.morningCommandSet = true;
    });

    _persistState();
  }

  void _saveEndReview() {
    setState(() {
      _state.endReviewsToday += 1;
      _state.reflectionsToday += 1;
      _state.xp += 15;
    });

    _persistState();
  }

  void _toggleProtection() {
    setState(() {
      _state.protectionEnabled = !_state.protectionEnabled;
    });

    _persistState();
    _persistSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('Loading Focus Shield...'),
          ),
        ),
      );
    }

    final screens = [
      HomeScreen(
        state: _state,
        onNavigate: _goTo,
        onListeningWin: _logListeningWin,
      ),
      ScannerScreen(
        protectionEnabled: _state.protectionEnabled,
        onBlocked: _openIntervention,
      ),
      RecoveryScreen(
        state: _state,
        onRecovered: _markRecovered,
        onFocusSession: _completeFocusSession,
      ),
      ProgressScreen(
        state: _state,
        onListeningWin: _logListeningWin,
        onFocusSession: _completeFocusSession,
        onReflection: _completeReflection,
        onConcentration: _completeConcentration,
      ),
      CoachScreen(
        state: _state,
        onMorningCommand: _setMorningCommand,
        onEndReview: _saveEndReview,
        onNavigate: _goTo,
      ),
      SettingsScreen(
        state: _state,
        onToggleProtection: _toggleProtection,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: _showIntervention
            ? InterventionScreen(
                state: _state,
                decision: _lastBlockedDecision,
                onNavigate: _goTo,
                onRecovered: _markRecovered,
                onBackToScanner: _returnToScanner,
              )
            : IndexedStack(
                index: _selectedIndex,
                children: screens,
              ),
      ),
      bottomNavigationBar: FocusShieldBottomNav(
        currentIndex: _selectedIndex,
        onTap: _goTo,
      ),
    );
  }
}
