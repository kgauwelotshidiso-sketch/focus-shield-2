import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/date_key.dart';
import 'data/repositories/sqlite_app_state_repository.dart';
import 'domain/models/attempt_record.dart';
import 'domain/models/blocked_domain.dart';
import 'domain/models/daily_summary.dart';
import 'domain/models/focus_shield_state.dart';
import 'domain/models/settings_record.dart';
import 'domain/repositories/app_state_repository.dart';
import 'domain/services/protection_engine.dart';
import 'presentation/screens/coach_screen.dart';
import 'presentation/screens/debug_center_screen.dart';
import 'presentation/screens/daily_history_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/intervention_screen.dart';
import 'presentation/screens/progress_screen.dart';
import 'presentation/screens/protection_database_screen.dart';
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
  bool _showDebugCenter = false;
  bool _showProtectionDatabase = false;
      _showDailyHistory = false;
  bool _showDailyHistory = false;
  bool _loading = true;

  ProtectionDecision? _lastBlockedDecision;
  FocusShieldState _state = FocusShieldState.initial();
  List<AttemptRecord> _attempts = [];
  List<BlockedDomain> _blockedDomains = [];
  List<DailySummary> _dailySummaries = [];

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
    final attempts = await _repository.loadAttempts();
    final blockedDomains = await _repository.loadBlockedDomains();

    final loadedState = snapshot.state;
    loadedState.protectionEnabled = settings.protectionEnabled;

    final needsDailyReset = loadedState.lastActiveDate != DateKey.today();
    if (needsDailyReset) {
      final summary = DailySummary.fromState(loadedState);
      await _repository.saveDailySummary(summary);
      loadedState.recordCompletedDay(missionWasComplete: summary.missionComplete);
      loadedState.applyDailyResetIfNeeded();
      await _repository.saveState(loadedState.copy());
    }

    final dailySummaries = await _repository.loadDailySummaries();

    if (!mounted) return;

    setState(() {
      _state = loadedState;
      _attempts = attempts;
      _blockedDomains = blockedDomains;
      _dailySummaries = dailySummaries;
      _loading = false;
    });
  }

  Future<void> _refreshAttempts() async {
    final attempts = await _repository.loadAttempts();

    if (!mounted) return;

    setState(() {
      _attempts = attempts;
      _state.blockedAttempts = attempts.length;
      _state.recoveredAttempts = attempts.where((attempt) => attempt.recovered).length;
    });

    _persistState();
  }

  Future<void> _refreshDailySummaries() async {
    final summaries = await _repository.loadDailySummaries();

    if (!mounted) return;

    setState(() {
      _dailySummaries = summaries;
    });
  }

  Future<void> _refreshBlockedDomains() async {
    final blockedDomains = await _repository.loadBlockedDomains();

    if (!mounted) return;

    setState(() {
      _blockedDomains = blockedDomains;
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
      _showDebugCenter = false;
      _showProtectionDatabase = false;
      _showDailyHistory = false;
    });
  }

  void _openDebugCenter() {
    setState(() {
      _showDebugCenter = true;
      _showIntervention = false;
      _showProtectionDatabase = false;
      _showDailyHistory = false;
    });

    _refreshAttempts();
  }

  void _closeDebugCenter() {
    setState(() {
      _showDebugCenter = false;
      _selectedIndex = 5;
    });
  }

  void _openDailyHistory() {
    setState(() {
      _showDailyHistory = true;
      _showProtectionDatabase = false;
      _showDailyHistory = false;
      _showDebugCenter = false;
      _showIntervention = false;
    });

    _refreshDailySummaries();
  }

  void _closeDailyHistory() {
    setState(() {
      _showDailyHistory = false;
      _selectedIndex = 3;
    });
  }

  void _openProtectionDatabase() {
    setState(() {
      _showProtectionDatabase = true;
      _showDebugCenter = false;
      _showIntervention = false;
    });

    _refreshBlockedDomains();
  }

  void _closeProtectionDatabase() {
    setState(() {
      _showProtectionDatabase = false;
      _showDailyHistory = false;
      _selectedIndex = 5;
    });
  }

  String _normalizeDomain(String input) {
    var value = input.trim().toLowerCase();
    value = value.replaceFirst(RegExp(r'^https?://'), '');
    value = value.replaceFirst(RegExp(r'^www\.'), '');
    value = value.split('/').first;
    value = value.split('?').first;
    value = value.split('#').first;
    return value;
  }

  void _addBlockedDomain(String domain, String category) {
    final normalizedDomain = _normalizeDomain(domain);
    if (normalizedDomain.isEmpty) return;

    _repository
        .saveBlockedDomain(
          BlockedDomain(
            id: 0,
            domain: normalizedDomain,
            category: category.trim().isEmpty ? 'custom-blocklist' : category.trim(),
            updatedAt: DateTime.now(),
          ),
        )
        .then((_) => _refreshBlockedDomains());
  }

  void _deleteBlockedDomain(int id) {
    _repository.deleteBlockedDomain(id).then((_) => _refreshBlockedDomains());
  }

  Future<void> _resetAppData() async {
    await _repository.clearAll();

    final snapshot = await _repository.loadSnapshot();
    final settings = await _repository.loadSettings();
    final attempts = await _repository.loadAttempts();
    final blockedDomains = await _repository.loadBlockedDomains();

    if (!mounted) return;

    setState(() {
      _state = snapshot.state;
      _state.protectionEnabled = settings.protectionEnabled;
      _attempts = attempts;
      _blockedDomains = blockedDomains;
      _selectedIndex = 0;
      _showIntervention = false;
      _showDebugCenter = false;
      _showProtectionDatabase = false;
      _showDailyHistory = false;
      _lastBlockedDecision = null;
    });
  }

  void _openIntervention(ProtectionDecision decision) {
    setState(() {
      _lastBlockedDecision = decision;
      _state.blockedAttempts += 1;
      _selectedIndex = 1;
      _showIntervention = true;
      _showDebugCenter = false;
      _showProtectionDatabase = false;
      _showDailyHistory = false;
    });

    _repository
        .saveAttempt(
          AttemptRecord(
            id: 0,
            domain: decision.domain,
            category: decision.category,
            confidence: decision.confidence,
            recovered: false,
            createdAt: DateTime.now(),
          ),
        )
        .then((_) => _refreshAttempts());

    _persistState();
  }

  void _returnToScanner() {
    setState(() {
      _selectedIndex = 1;
      _showIntervention = false;
      _showDebugCenter = false;
      _showProtectionDatabase = false;
      _showDailyHistory = false;
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
      _showDebugCenter = false;
      _showProtectionDatabase = false;
      _showDailyHistory = false;
      _selectedIndex = 2;
    });

    _repository.markLatestAttemptRecovered().then((_) => _refreshAttempts());
    _persistState();
  }

  void _markAttemptRecoveredById(int id) {
    final attempt = _attempts.where((item) => item.id == id).firstOrNull;
    final shouldReward = attempt != null && !attempt.recovered;

    setState(() {
      if (shouldReward) {
        _state.xp += 10;
      }
    });

    _repository.markAttemptRecovered(id).then((_) => _refreshAttempts());
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

    if (_showDailyHistory) {
      return Scaffold(
        body: SafeArea(
          child: DailyHistoryScreen(
            state: _state,
            summaries: _dailySummaries,
            onBack: _closeDailyHistory,
          ),
        ),
        bottomNavigationBar: FocusShieldBottomNav(
          currentIndex: _selectedIndex,
          onTap: _goTo,
        ),
      );
    }

    if (_showProtectionDatabase) {
      return Scaffold(
        body: SafeArea(
          child: ProtectionDatabaseScreen(
            blockedDomains: _blockedDomains,
            onBack: _closeProtectionDatabase,
            onAddDomain: _addBlockedDomain,
            onDeleteDomain: _deleteBlockedDomain,
            onRefresh: _refreshBlockedDomains,
          ),
        ),
        bottomNavigationBar: FocusShieldBottomNav(
          currentIndex: _selectedIndex,
          onTap: _goTo,
        ),
      );
    }

    if (_showDebugCenter) {
      return Scaffold(
        body: SafeArea(
          child: DebugCenterScreen(
            state: _state,
            attempts: _attempts,
            onBack: _closeDebugCenter,
            onResetAppData: _resetAppData,
            onRefresh: _refreshAttempts,
            onMarkAttemptRecovered: _markAttemptRecoveredById,
          ),
        ),
        bottomNavigationBar: FocusShieldBottomNav(
          currentIndex: _selectedIndex,
          onTap: _goTo,
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
        blockedDomains: _blockedDomains,
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
        onOpenDailyHistory: _openDailyHistory,
      ),
      CoachScreen(
        state: _state,
        attempts: _attempts,
        onMorningCommand: _setMorningCommand,
        onEndReview: _saveEndReview,
        onNavigate: _goTo,
      ),
      SettingsScreen(
        state: _state,
        onToggleProtection: _toggleProtection,
        onOpenProtectionDatabase: _openProtectionDatabase,
        onOpenDebugCenter: _openDebugCenter,
        onResetAppData: _resetAppData,
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
