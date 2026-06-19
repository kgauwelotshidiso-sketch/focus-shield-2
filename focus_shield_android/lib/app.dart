import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'domain/models/focus_shield_state.dart';
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
  const FocusShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Shield',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const FocusShieldShell(),
    );
  }
}

class FocusShieldShell extends StatefulWidget {
  const FocusShieldShell({super.key});

  @override
  State<FocusShieldShell> createState() => _FocusShieldShellState();
}

class _FocusShieldShellState extends State<FocusShieldShell> {
  int _selectedIndex = 0;
  bool _showIntervention = false;
  ProtectionDecision? _lastBlockedDecision;
  final FocusShieldState _state = FocusShieldState.initial();

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
  }

  void _completeFocusSession() {
    setState(() {
      _state.focusSessionsToday += 1;
      _state.xp += 20;
    });
  }

  void _completeReflection() {
    setState(() {
      _state.reflectionsToday += 1;
      _state.xp += 15;
    });
  }

  void _completeConcentration() {
    setState(() {
      _state.concentrationWinsToday += 1;
      _state.xp += 15;
    });
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
  }

  void _setMorningCommand() {
    setState(() {
      if (!_state.morningCommandSet) {
        _state.xp += 10;
      }
      _state.morningCommandSet = true;
    });
  }

  void _saveEndReview() {
    setState(() {
      _state.endReviewsToday += 1;
      _state.reflectionsToday += 1;
      _state.xp += 15;
    });
  }

  void _toggleProtection() {
    setState(() {
      _state.protectionEnabled = !_state.protectionEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
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
