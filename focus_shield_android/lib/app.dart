import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/date_key.dart';
import 'data/repositories/sqlite_app_state_repository.dart';
import 'domain/models/affirmation.dart';
import 'domain/models/attempt_record.dart';
import 'domain/models/blocked_domain.dart';
import 'domain/models/daily_summary.dart';
import 'domain/models/focus_shield_state.dart';
import 'domain/models/goal.dart';
import 'domain/models/settings_record.dart';
import 'domain/repositories/app_state_repository.dart';
import 'domain/services/protection_engine.dart';
import 'platform/protection_channel.dart';
import 'presentation/screens/coach_screen.dart';
import 'presentation/screens/concentration_screen.dart';
import 'presentation/screens/daily_history_screen.dart';
import 'presentation/screens/debug_center_screen.dart';
import 'presentation/screens/focus_timer_screen.dart';
import 'presentation/screens/goals_affirmations_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/intervention_screen.dart';
import 'presentation/screens/progress_screen.dart';
import 'presentation/screens/protection_database_screen.dart';
import 'presentation/screens/production_readiness_screen.dart';
import 'presentation/screens/recovery_screen.dart';
import 'presentation/screens/reflection_screen.dart';
import 'presentation/screens/scanner_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/widgets/focus_shield_bottom_nav.dart';

class FocusShieldApp extends StatelessWidget {
  const FocusShieldApp({super.key, this.repository});

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
  const FocusShieldShell({super.key, this.repository});

  final AppStateRepository? repository;

  @override
  State<FocusShieldShell> createState() => _FocusShieldShellState();
}

class _FocusShieldShellState extends State<FocusShieldShell> {
  int _selectedIndex = 0;

  bool _showIntervention = false;
  bool _showDebugCenter = false;
  bool _showProtectionDatabase = false;
  bool _showDailyHistory = false;
  bool _showGoalsAffirmations = false;
  bool _showProductionReadiness = false;
  bool _showFocusTimer = false;
  bool _showConcentration = false;
  bool _showReflection = false;

  bool _loading = true;

  ProtectionDecision? _lastBlockedDecision;
  FocusShieldState _state = FocusShieldState.initial();

  List<AttemptRecord> _attempts = <AttemptRecord>[];
  List<BlockedDomain> _blockedDomains = <BlockedDomain>[];
  List<DailySummary> _dailySummaries = <DailySummary>[];
  List<Goal> _goals = <Goal>[];
  List<Affirmation> _affirmations = <Affirmation>[];

  late final AppStateRepository _repository;

  String get _primaryAffirmation {
    for (final affirmation in _affirmations) {
      if (affirmation.favorite) {
        return affirmation.text;
      }
    }

    if (_affirmations.isNotEmpty) {
      return _affirmations.first.text;
    }

    return AppConstants.affirmation;
  }

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
    final goals = await _repository.loadGoals();
    final affirmations = await _repository.loadAffirmations();

    final loadedState = snapshot.state;
    loadedState.protectionEnabled =
        settings.protectionEnabled && loadedState.commitmentActive;

    final needsDailyReset = loadedState.lastActiveDate != DateKey.today();

    if (needsDailyReset) {
      final summary = DailySummary.fromState(loadedState);
      await _repository.saveDailySummary(summary);

      loadedState.recordCompletedDay(
        missionWasComplete: summary.missionComplete,
      );

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
      _goals = goals;
      _affirmations = affirmations;
      _loading = false;
    });
  }

  Future<void> _refreshAttempts() async {
    final attempts = await _repository.loadAttempts();

    if (!mounted) return;

    setState(() {
      _attempts = attempts;
      _state.blockedAttempts = attempts.length;
      _state.recoveredAttempts = attempts
          .where((attempt) => attempt.recovered)
          .length;
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

  Future<void> _refreshGoalsAffirmations() async {
    final goals = await _repository.loadGoals();
    final affirmations = await _repository.loadAffirmations();

    if (!mounted) return;

    setState(() {
      _goals = goals;
      _affirmations = affirmations;
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

  void _hideOverlays() {
    _showIntervention = false;
    _showDebugCenter = false;
    _showProtectionDatabase = false;
    _showDailyHistory = false;
    _showGoalsAffirmations = false;
    _showProductionReadiness = false;
    _showFocusTimer = false;
    _showConcentration = false;
    _showReflection = false;
  }

  void _goTo(int index) {
    setState(() {
      _selectedIndex = index;
      _hideOverlays();
    });
  }

  void _openDailyHistory() {
    setState(() {
      _hideOverlays();
      _showDailyHistory = true;
    });

    _refreshDailySummaries();
  }

  void _closeDailyHistory() {
    setState(() {
      _showDailyHistory = false;
      _selectedIndex = 3;
    });
  }

  void _openDebugCenter() {
    setState(() {
      _hideOverlays();
      _showDebugCenter = true;
    });

    _refreshAttempts();
  }

  void _closeDebugCenter() {
    setState(() {
      _showDebugCenter = false;
      _selectedIndex = 5;
    });
  }

  void _openProtectionDatabase() {
    setState(() {
      _hideOverlays();
      _showProtectionDatabase = true;
    });

    _refreshBlockedDomains();
  }

  void _closeProtectionDatabase() {
    setState(() {
      _showProtectionDatabase = false;
      _selectedIndex = 5;
    });
  }

  void _openProductionReadiness() {
    setState(() {
      _hideOverlays();
      _showProductionReadiness = true;
    });
  }

  void _closeProductionReadiness() {
    setState(() {
      _showProductionReadiness = false;
      _selectedIndex = 5;
    });
  }

  void _openGoalsAffirmations() {
    setState(() {
      _hideOverlays();
      _showGoalsAffirmations = true;
    });

    _refreshGoalsAffirmations();
  }

  void _closeGoalsAffirmations() {
    setState(() {
      _showGoalsAffirmations = false;
      _selectedIndex = 5;
    });
  }

  void _openFocusTimer() {
    setState(() {
      _hideOverlays();
      _showFocusTimer = true;
    });
  }

  void _openConcentration() {
    setState(() {
      _hideOverlays();
      _showConcentration = true;
    });
  }

  void _openReflection() {
    setState(() {
      _hideOverlays();
      _showReflection = true;
    });
  }

  void _closeDisciplineTool() {
    setState(() {
      _showFocusTimer = false;
      _showConcentration = false;
      _showReflection = false;
      _selectedIndex = 3;
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
            category: category.trim().isEmpty
                ? 'custom-blocklist'
                : category.trim(),
            updatedAt: DateTime.now(),
          ),
        )
        .then((_) => _refreshBlockedDomains());
  }

  void _deleteBlockedDomain(int id) {
    _repository.deleteBlockedDomain(id).then((_) => _refreshBlockedDomains());
  }

  void _addGoal(String title, String description) {
    final cleanTitle = title.trim();

    if (cleanTitle.isEmpty) return;

    _repository
        .saveGoal(
          Goal(id: 0, title: cleanTitle, description: description.trim()),
        )
        .then((_) => _refreshGoalsAffirmations());
  }

  void _deleteGoal(int id) {
    _repository.deleteGoal(id).then((_) => _refreshGoalsAffirmations());
  }

  void _addAffirmation(String text, bool favorite) {
    final cleanText = text.trim();

    if (cleanText.isEmpty) return;

    _repository
        .saveAffirmation(
          Affirmation(id: 0, text: cleanText, favorite: favorite),
        )
        .then((_) => _refreshGoalsAffirmations());
  }

  void _deleteAffirmation(int id) {
    _repository.deleteAffirmation(id).then((_) => _refreshGoalsAffirmations());
  }

  void _setFavoriteAffirmation(Affirmation affirmation) {
    _repository
        .saveAffirmation(
          affirmation.copyWith(favorite: true, updatedAt: DateTime.now()),
        )
        .then((_) => _refreshGoalsAffirmations());
  }

  Future<void> _resetAppData() async {
    await _repository.clearAll();

    final snapshot = await _repository.loadSnapshot();
    final settings = await _repository.loadSettings();
    final attempts = await _repository.loadAttempts();
    final blockedDomains = await _repository.loadBlockedDomains();
    final dailySummaries = await _repository.loadDailySummaries();
    final goals = await _repository.loadGoals();
    final affirmations = await _repository.loadAffirmations();

    if (!mounted) return;

    setState(() {
      _state = snapshot.state;
      _state.protectionEnabled =
          settings.protectionEnabled && _state.commitmentActive;
      _attempts = attempts;
      _blockedDomains = blockedDomains;
      _dailySummaries = dailySummaries;
      _goals = goals;
      _affirmations = affirmations;
      _selectedIndex = 0;
      _hideOverlays();
      _lastBlockedDecision = null;
    });
  }

  void _openIntervention(ProtectionDecision decision) {
    setState(() {
      _lastBlockedDecision = decision;
      _state.blockedAttempts += 1;
      _selectedIndex = 1;
      _hideOverlays();
      _showIntervention = true;
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
      _hideOverlays();
    });
  }

  void _handleScannerDecision(ProtectionDecision decision) {
    setState(() {
      _state.recordWebsiteScan(decision.domain);
    });

    _persistState();

    if (decision.blocked && _state.protectionEnabled) {
      _openIntervention(decision);
    }
  }

  void _logListeningWin() {
    setState(() {
      _state.listeningWinsToday += 1;
      _state.xp += 10;
    });

    _persistState();
  }

  void _completeFocusSession(int minutes) {
    setState(() {
      _state.focusSessionsToday += 1;
      _state.xp += 20;
      _showFocusTimer = false;
      _selectedIndex = 3;
    });

    _persistState();
  }

  void _completeReflection(String reflectionText) {
    setState(() {
      _state.reflectionsToday += 1;
      _state.lastReflectionText = reflectionText;
      _state.xp += 15;
      _showReflection = false;
      _selectedIndex = 3;
    });

    _persistState();
  }

  void _completeConcentration(String thought) {
    setState(() {
      _state.concentrationWinsToday += 1;
      _state.xp += 15;
      _showConcentration = false;
      _selectedIndex = 3;
    });

    _persistState();
  }

  void _markRecovered() {
    setState(() {
      if (_state.pendingRecoveries > 0) {
        _state.recoveredAttempts += 1;
        _state.xp += 10;
      }

      _hideOverlays();
      _selectedIndex = 2;
    });

    _repository.markLatestAttemptRecovered().then((_) => _refreshAttempts());
    _persistState();
  }

  void _markAttemptRecoveredById(int id) {
    AttemptRecord? attempt;

    for (final item in _attempts) {
      if (item.id == id) {
        attempt = item;
        break;
      }
    }

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
    if (!_state.commitmentSet) {
      setState(() {
        _selectedIndex = 5;
      });
      return;
    }

    if (_state.commitmentActive && _state.protectionEnabled) {
      return;
    }

    setState(() {
      _state.protectionEnabled = !_state.protectionEnabled;
    });

    _persistState();
    _persistSettings();
  }

  void _setCommitmentDays(int days) {
    setState(() {
      _state.setCommitment(days);
    });

    _persistState();
    _persistSettings();
  }

  Future<void> _openAccessibilitySettings() async {
    await ProtectionChannel().openAccessibilitySettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: Text('Loading Focus Shield...'))),
      );
    }

    Widget? overlay;

    if (_showProductionReadiness) {
      overlay = ProductionReadinessScreen(onBack: _closeProductionReadiness);
    } else if (_showGoalsAffirmations) {
      overlay = GoalsAffirmationsScreen(
        goals: _goals,
        affirmations: _affirmations,
        onBack: _closeGoalsAffirmations,
        onAddGoal: _addGoal,
        onDeleteGoal: _deleteGoal,
        onAddAffirmation: _addAffirmation,
        onDeleteAffirmation: _deleteAffirmation,
        onSetFavoriteAffirmation: _setFavoriteAffirmation,
        onRefresh: _refreshGoalsAffirmations,
      );
    } else if (_showDailyHistory) {
      overlay = DailyHistoryScreen(
        state: _state,
        summaries: _dailySummaries,
        onBack: _closeDailyHistory,
      );
    } else if (_showProtectionDatabase) {
      overlay = ProtectionDatabaseScreen(
        blockedDomains: _blockedDomains,
        onBack: _closeProtectionDatabase,
        onAddDomain: _addBlockedDomain,
        onDeleteDomain: _deleteBlockedDomain,
        onRefresh: _refreshBlockedDomains,
      );
    } else if (_showDebugCenter) {
      overlay = DebugCenterScreen(
        state: _state,
        attempts: _attempts,
        onBack: _closeDebugCenter,
        onResetAppData: _resetAppData,
        onRefresh: _refreshAttempts,
        onMarkAttemptRecovered: _markAttemptRecoveredById,
      );
    } else if (_showFocusTimer) {
      overlay = FocusTimerScreen(
        onBack: _closeDisciplineTool,
        onCompleted: _completeFocusSession,
      );
    } else if (_showConcentration) {
      overlay = ConcentrationScreen(
        goals: _goals,
        affirmations: _affirmations,
        primaryAffirmation: _primaryAffirmation,
        onBack: _closeDisciplineTool,
        onCompleted: _completeConcentration,
      );
    } else if (_showReflection) {
      overlay = ReflectionScreen(
        onBack: _closeDisciplineTool,
        onSaved: _completeReflection,
        lastReflectionText: _state.lastReflectionText,
      );
    }

    if (overlay != null) {
      return Scaffold(
        body: SafeArea(child: overlay),
        bottomNavigationBar: FocusShieldBottomNav(
          currentIndex: _selectedIndex,
          onTap: _goTo,
        ),
      );
    }

    final screens = [
      HomeScreen(
        state: _state,
        goals: _goals,
        primaryAffirmation: _primaryAffirmation,
        onNavigate: _goTo,
        onListeningWin: _logListeningWin,
      ),
      ScannerScreen(
        protectionEnabled: _state.protectionEnabled,
        blockedDomains: _blockedDomains,
        state: _state,
        onDecision: _handleScannerDecision,
      ),
      RecoveryScreen(
        state: _state,
        onRecovered: _markRecovered,
        onOpenFocusTimer: _openFocusTimer,
        onOpenConcentration: _openConcentration,
        onOpenReflection: _openReflection,
      ),
      ProgressScreen(
        state: _state,
        onListeningWin: _logListeningWin,
        onOpenFocusTimer: _openFocusTimer,
        onOpenReflection: _openReflection,
        onOpenConcentration: _openConcentration,
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
        onSetCommitmentDays: _setCommitmentDays,
        onOpenAccessibilitySettings: _openAccessibilitySettings,
        onOpenProtectionDatabase: _openProtectionDatabase,
        onOpenGoalsAffirmations: _openGoalsAffirmations,
        onOpenDebugCenter: _openDebugCenter,
        onOpenProductionReadiness: _openProductionReadiness,
        onResetAppData: _resetAppData,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: _showIntervention
            ? InterventionScreen(
                state: _state,
                goals: _goals,
                primaryAffirmation: _primaryAffirmation,
                decision: _lastBlockedDecision,
                onNavigate: _goTo,
                onRecovered: _markRecovered,
                onBackToScanner: _returnToScanner,
              )
            : IndexedStack(index: _selectedIndex, children: screens),
      ),
      bottomNavigationBar: FocusShieldBottomNav(
        currentIndex: _selectedIndex,
        onTap: _goTo,
      ),
    );
  }
}
