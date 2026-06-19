import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
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

  void _goTo(int index) {
    setState(() {
      _selectedIndex = index;
      _showIntervention = false;
    });
  }

  void _openIntervention(ProtectionDecision decision) {
    setState(() {
      _lastBlockedDecision = decision;
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

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigate: _goTo),
      ScannerScreen(onBlocked: _openIntervention),
      const RecoveryScreen(),
      const ProgressScreen(),
      const CoachScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: _showIntervention
            ? InterventionScreen(
                decision: _lastBlockedDecision,
                onNavigate: _goTo,
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
