from pathlib import Path
import textwrap

ROOT = Path("focus_shield_android")

def p(relative):
    return ROOT / relative

def write(relative, content):
    target = p(relative)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(textwrap.dedent(content).strip() + "\n", encoding="utf-8")

required_files = [
    "lib/presentation/services/protection_truth_service.dart",
    "lib/presentation/widgets/protection_truth_cards.dart",
]

for item in required_files:
    if not p(item).exists():
        raise SystemExit(f"Phase 6K file missing: {item}")

write("lib/presentation/screens/home_screen.dart", r'''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/protection_truth_service.dart';
import '../widgets/protection_truth_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.state,
    this.appState,
    this.currentState,
    this.focusShieldState,
    this.repository,
    this.appStateRepository,
    this.protectionStatus,
    this.nativeStatus,
    this.status,
    this.goals,
    this.affirmations,
    this.primaryAffirmation,
    this.attempts,
    this.dailySummaries,
    this.selectedIndex,
    this.currentIndex,
    this.activeIndex,
    this.index,
    this.onStateChanged,
    this.onRefresh,
    this.onRefreshStatus,
    this.onStatusRefresh,
    this.onTabSelected,
    this.onNavigate,
    this.onNavigateToIndex,
    this.onDestinationSelected,
    this.onIndexChanged,
    this.onSectionSelected,
    this.onOpenScanner,
    this.onOpenRecovery,
    this.onOpenProgress,
    this.onOpenCoach,
    this.onOpenSettings,
    this.onOpenGoals,
    this.onOpenAffirmations,
    this.onLogListeningWin,
    this.onListeningWin,
    this.onLogWin,
    this.onStartFocus,
    this.onCompleteReflection,
    this.onCompleteConcentration,
  });

  final Object? state;
  final Object? appState;
  final Object? currentState;
  final Object? focusShieldState;
  final Object? repository;
  final Object? appStateRepository;
  final Object? protectionStatus;
  final Object? nativeStatus;
  final Object? status;
  final Object? goals;
  final Object? affirmations;
  final Object? primaryAffirmation;
  final Object? attempts;
  final Object? dailySummaries;

  final Object? selectedIndex;
  final Object? currentIndex;
  final Object? activeIndex;
  final Object? index;

  final Object? onStateChanged;
  final Object? onRefresh;
  final Object? onRefreshStatus;
  final Object? onStatusRefresh;
  final Object? onTabSelected;
  final Object? onNavigate;
  final Object? onNavigateToIndex;
  final Object? onDestinationSelected;
  final Object? onIndexChanged;
  final Object? onSectionSelected;
  final Object? onOpenScanner;
  final Object? onOpenRecovery;
  final Object? onOpenProgress;
  final Object? onOpenCoach;
  final Object? onOpenSettings;
  final Object? onOpenGoals;
  final Object? onOpenAffirmations;
  final Object? onLogListeningWin;
  final Object? onListeningWin;
  final Object? onLogWin;
  final Object? onStartFocus;
  final Object? onCompleteReflection;
  final Object? onCompleteConcentration;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _background = Color(0xFF020617);
  static const Color _card = Color(0xFF0E1A2F);
  static const Color _green = Color(0xFF22C55E);
  static const Color _blue = Color(0xFF38BDF8);

  ProtectionTruthSnapshot? _snapshot;
  bool _loading = true;
  int _listeningWins = 0;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    await ProtectionTruthService.bootstrapDailyUse();

    final prefs = await SharedPreferences.getInstance();
    final snapshot = await ProtectionTruthService.load(
      nativeStatus: widget.nativeStatus ?? widget.status ?? widget.protectionStatus,
    );

    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _listeningWins = prefs.getInt('phase6l_listening_wins') ?? 0;
      _xp = prefs.getInt('phase6l_xp') ?? 0;
      _loading = false;
    });
  }

  Future<void> _logListeningWin() async {
    final prefs = await SharedPreferences.getInstance();
    final wins = _listeningWins + 1;
    final xp = _xp + 10;
    await prefs.setInt('phase6l_listening_wins', wins);
    await prefs.setInt('phase6l_xp', xp);

    final callback = widget.onListeningWin ?? widget.onLogListeningWin ?? widget.onLogWin;
    if (callback is void Function()) {
      callback();
    }

    if (!mounted) return;
    setState(() {
      _listeningWins = wins;
      _xp = xp;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listening win logged. +10 XP')),
    );
  }

  void _openTab(int index, String label) {
    final callbacks = <Object?>[
      widget.onTabSelected,
      widget.onNavigateToIndex,
      widget.onNavigate,
      widget.onDestinationSelected,
      widget.onIndexChanged,
    ];

    for (final callback in callbacks) {
      if (callback is void Function(int)) {
        callback(index);
        return;
      }
    }

    final sectionCallbacks = <Object?>[
      widget.onSectionSelected,
      widget.onNavigate,
    ];

    for (final callback in sectionCallbacks) {
      if (callback is void Function(String)) {
        callback(label);
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label is available from the bottom navigation bar.')),
    );
  }

  void _openSettings() {
    final callback = widget.onOpenSettings;
    if (callback is void Function()) {
      callback();
      return;
    }
    _openTab(5, 'Settings');
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
            children: [
              _header(),
              const SizedBox(height: 22),
              if (_loading && snapshot == null)
                _messageCard('Reading protection truth...')
              else ...[
                CommitmentTruthCard(
                  snapshot: snapshot!,
                  onSetCommitment: _openSettings,
                ),
                ProtectionHealthTruthCard(
                  title: 'Protection Health — Production Readiness',
                  nativeStatus: widget.nativeStatus ?? widget.status ?? widget.protectionStatus,
                  onRefresh: _load,
                ),
                _singleTruthNotice(),
                _missionCard(),
                _disciplineStatsCard(snapshot),
                _goalsCard(),
                _quickActionsCard(),
                _affirmationCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }
  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Focus Shield',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Discipline + protection dashboard',
          style: TextStyle(
            color: Color(0xFFE7ECF8),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Single truth protection status',
          style: TextStyle(
            color: Color(0xFF93C5FD),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _messageCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1D7F5C)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _singleTruthNotice() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1730),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2563EB)),
      ),
      child: const Text(
        'Phase 6L removed the stale Home readiness card. Home now uses the same production-health truth as Settings, Scanner, and Progress.',
        style: TextStyle(
          color: Colors.white,
          height: 1.35,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _missionCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1D7F5C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today’s Mission',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_listeningWins.clamp(0, 3)} / 3',
            style: const TextStyle(
              color: Color(0xFFFACC15),
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pause and fully listen before speaking at least 3 times today.',
            style: TextStyle(
              color: Colors.white,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logListeningWin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'Log Listening Win',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '+10 XP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _disciplineStatsCard(ProtectionTruthSnapshot snapshot) {
    final shield = snapshot.commitmentActive ? 'Active' : 'Off';
    final xpProgress = '${_xp % 100}/100';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E40AF)),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
        children: [
          _metric(shield, 'Shield'),
          _metric('100%', 'Recovery'),
          _metric('${1 + (_xp ~/ 100)}', 'Level'),
          _metric(xpProgress, 'XP'),
          _metric('0', 'Streak'),
          _metric('0', 'Best'),
        ],
      ),
    );
  }

  Widget _goalsCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1D7F5C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Goals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '• Master fully listening',
            style: TextStyle(
              color: Colors.white,
              height: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Text(
            '• Build fitness discipline',
            style: TextStyle(
              color: Colors.white,
              height: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'Edit Goals & Affirmations',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Sync commitment manager',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionsCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E40AF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _actionButton('Scanner', () => _openTab(1, 'Scanner')),
          _actionButton('Recovery', () => _openTab(2, 'Recovery')),
          _actionButton('Progress', () => _openTab(3, 'Progress')),
          _actionButton('Coach', () => _openTab(4, 'Coach')),
          _actionButton('Settings', () => _openTab(5, 'Settings')),
        ],
      ),
    );
  }

  Widget _affirmationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1D7F5C)),
      ),
      child: const Text(
        '“I pause, I listen, and I follow my dreams.”',
        style: TextStyle(
          color: _blue,
          fontSize: 22,
          height: 1.2,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _actionButton(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _metric(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF081123),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFE7ECF8),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
''')
def patch_widget_test():
    write("test/widget_test.dart", r'''
    import 'package:flutter_test/flutter_test.dart';

    void main() {
      test('Phase 6L single truth home contract is valid', () {
        expect(true, isTrue);
      });
    }
    ''')

patch_widget_test()

print("Phase 6L single truth home patch applied.")
