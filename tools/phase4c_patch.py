from pathlib import Path

ROOT = Path("focus_shield_android")


def write(path: str, text: str) -> None:
    full_path = ROOT / path
    full_path.parent.mkdir(parents=True, exist_ok=True)
    full_path.write_text(text.strip() + "\n", encoding="utf-8")
    print(f"wrote {full_path}")


def patch_file(path: str, transform) -> None:
    full_path = ROOT / path
    text = full_path.read_text(encoding="utf-8")
    new_text = transform(text)
    if new_text == text:
        print(f"no change needed for {full_path}")
    else:
        full_path.write_text(new_text, encoding="utf-8")
        print(f"patched {full_path}")


write("lib/presentation/screens/cloud_sync_screen.dart", r'''
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/affirmation.dart';
import '../../domain/models/blocked_domain.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/models/goal.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class CloudSyncScreen extends StatefulWidget {
  const CloudSyncScreen({
    super.key,
    required this.state,
    required this.goals,
    required this.affirmations,
    required this.blockedDomains,
    required this.onBack,
  });

  final FocusShieldState state;
  final List<Goal> goals;
  final List<Affirmation> affirmations;
  final List<BlockedDomain> blockedDomains;
  final VoidCallback onBack;

  @override
  State<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends State<CloudSyncScreen> {
  final TextEditingController _backupController = TextEditingController();
  final TextEditingController _restoreController = TextEditingController();

  String _syncStatus = 'Cloud foundation ready. No provider connected yet.';
  String _lastSync = 'Not synced yet';
  int _syncQueue = 0;

  @override
  void initState() {
    super.initState();
    _recalculateQueue();
  }

  @override
  void dispose() {
    _backupController.dispose();
    _restoreController.dispose();
    super.dispose();
  }

  void _recalculateQueue() {
    _syncQueue = 1 +
        widget.goals.length +
        widget.affirmations.length +
        widget.blockedDomains.length;
  }

  Map<String, dynamic> _backupMap() {
    return {
      'backupVersion': 1,
      'app': 'Focus Shield',
      'phase': '4C Cloud Sync Foundation',
      'createdAt': DateTime.now().toIso8601String(),
      'state': widget.state.toMap(),
      'goals': widget.goals.map((goal) {
        return {
          'id': goal.id,
          'title': goal.title,
          'description': goal.description,
        };
      }).toList(),
      'affirmations': widget.affirmations.map((affirmation) {
        return {
          'id': affirmation.id,
          'text': affirmation.text,
          'favorite': affirmation.favorite,
        };
      }).toList(),
      'blockedDomains': widget.blockedDomains.map((domain) {
        return {
          'id': domain.id,
          'domain': domain.domain,
          'category': domain.category,
          'updatedAt': domain.updatedAt.toIso8601String(),
        };
      }).toList(),
    };
  }

  void _generateBackup() {
    final encoder = const JsonEncoder.withIndent('  ');
    final backupText = encoder.convert(_backupMap());

    setState(() {
      _backupController.text = backupText;
      _syncStatus = 'Backup JSON generated locally.';
      _lastSync = 'Manual backup generated now';
      _recalculateQueue();
    });
  }

  Future<void> _copyBackup() async {
    if (_backupController.text.trim().isEmpty) {
      _generateBackup();
    }

    await Clipboard.setData(
      ClipboardData(text: _backupController.text),
    );

    if (!mounted) return;

    setState(() {
      _syncStatus = 'Backup copied to clipboard.';
    });
  }

  void _validateRestoreText() {
    final text = _restoreController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _syncStatus = 'Paste backup JSON first.';
      });
      return;
    }

    try {
      final decoded = jsonDecode(text);

      if (decoded is! Map<String, dynamic>) {
        setState(() {
          _syncStatus = 'Invalid backup: root value is not an object.';
        });
        return;
      }

      final hasState = decoded.containsKey('state');
      final hasGoals = decoded.containsKey('goals');
      final hasAffirmations = decoded.containsKey('affirmations');
      final hasDomains = decoded.containsKey('blockedDomains');

      if (!hasState || !hasGoals || !hasAffirmations || !hasDomains) {
        setState(() {
          _syncStatus =
              'Backup readable, but some sections are missing. Required: state, goals, affirmations, blockedDomains.';
        });
        return;
      }

      final goals = decoded['goals'];
      final affirmations = decoded['affirmations'];
      final domains = decoded['blockedDomains'];

      final goalCount = goals is List ? goals.length : 0;
      final affirmationCount = affirmations is List ? affirmations.length : 0;
      final domainCount = domains is List ? domains.length : 0;

      setState(() {
        _syncStatus =
            'Backup validated: $goalCount goals, $affirmationCount affirmations, $domainCount blocked domains. Restore write will be connected in the next cloud sprint.';
      });
    } catch (error) {
      setState(() {
        _syncStatus = 'Invalid JSON: ${error.runtimeType}.';
      });
    }
  }

  void _simulateCloudSync() {
    setState(() {
      _lastSync = DateTime.now().toIso8601String();
      _syncStatus =
          'Simulated cloud sync complete. Data is still local until Firebase is connected.';
      _syncQueue = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unsyncedItems = _syncQueue;

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
                'Cloud Sync',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ],
        ),
        const Text('Backup, restore, and cloud-ready sync foundation.'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Sync Mode': 'Local',
              'Queue': '$unsyncedItems',
              'Goals': '${widget.goals.length}',
              'Affirmations': '${widget.affirmations.length}',
              'Domains': '${widget.blockedDomains.length}',
              'Provider': 'Not connected',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sync Status'),
              const SizedBox(height: 8),
              Text(_syncStatus),
              const SizedBox(height: 8),
              Text('Last sync: $_lastSync'),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Simulate Cloud Sync',
                subtitle: 'Marks local queue as synced',
                onPressed: _simulateCloudSync,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Export Backup JSON'),
              const SizedBox(height: 8),
              const Text(
                'This creates a local backup that can later be uploaded to Firebase or copied to another device.',
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Generate Backup JSON',
                subtitle: 'State, goals, affirmations, domains',
                onPressed: _generateBackup,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Copy Backup JSON',
                subtitle: 'Copy to clipboard',
                onPressed: _copyBackup,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _backupController,
                minLines: 6,
                maxLines: 12,
                readOnly: true,
                decoration: const InputDecoration(
                  hintText: 'Backup JSON will appear here.',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Import / Restore Validator'),
              const SizedBox(height: 8),
              const Text(
                'Paste a backup JSON here to check whether it is readable. Actual restore-writing will be connected after the cloud model is stable.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _restoreController,
                minLines: 6,
                maxLines: 12,
                decoration: const InputDecoration(
                  hintText: 'Paste backup JSON here.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Validate Backup JSON',
                subtitle: 'Check restore structure',
                onPressed: _validateRestoreText,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text(
            'Next cloud sprint: connect Firebase project, add google-services.json, then sync this local backup model to cloud storage.',
          ),
        ),
      ],
    );
  }
}
''')
write("lib/presentation/screens/settings_screen.dart", r'''
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/focus_shield_state.dart';
import '../widgets/action_button.dart';
import '../widgets/protection_status_card.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.state,
    required this.onToggleProtection,
    required this.onSetCommitmentDays,
    required this.onOpenAccessibilitySettings,
    required this.onOpenProtectionDatabase,
    required this.onOpenGoalsAffirmations,
    required this.onOpenDebugCenter,
    required this.onOpenProductionReadiness,
    required this.onResetAppData,
    this.onOpenCloudSync,
  });

  final FocusShieldState state;
  final VoidCallback onToggleProtection;
  final ValueChanged<int> onSetCommitmentDays;
  final VoidCallback onOpenAccessibilitySettings;
  final VoidCallback onOpenProtectionDatabase;
  final VoidCallback onOpenGoalsAffirmations;
  final VoidCallback onOpenDebugCenter;
  final VoidCallback onOpenProductionReadiness;
  final VoidCallback onResetAppData;
  final VoidCallback? onOpenCloudSync;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const ProtectionStatusCard(),
        const SizedBox(height: 16),
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const Text('Protection control center'),
        Text('Active day: ${state.lastActiveDate}'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: state.commitmentSet ? AppTheme.primary : AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Commitment Lock'),
              const SizedBox(height: 8),
              Text(
                state.commitmentSet
                    ? 'Commitment: ${state.commitmentDays} days. Days remaining: ${state.commitmentDaysRemaining}.'
                    : 'Protection cannot activate until a commitment duration is set.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [7, 14, 30, 90, 365].map((days) {
                  return ChoiceChip(
                    label: Text('$days days'),
                    selected: state.commitmentDays == days,
                    onSelected: state.commitmentActive
                        ? null
                        : (_) => onSetCommitmentDays(days),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                state.commitmentActive
                    ? 'In-app protection settings are locked during this commitment.'
                    : 'Choose a duration to activate the commitment gate.',
              ),
            ],
          ),
        ),
        ShieldCard(
          child: StatGrid(
            items: {
              'Protection': state.protectionEnabled ? 'ON' : 'OFF',
              'Attempts': '${state.blockedAttempts}',
              'Recovery': '${state.recoveryRate}%',
              'XP': '${state.xp}',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Scanned Today': '${state.websitesScannedToday}',
              'New Today': '${state.newWebsitesScannedToday}',
              'Total Scanned': '${state.totalWebsitesScanned}',
              'Commitment': state.commitmentSet ? 'Set' : 'Required',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.warning,
          child: const Text(
            'System-wide VPN filtering is paused while the DNS route issue is repaired. Accessibility setup must be enabled manually by the user.',
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            children: [
              ActionButton(
                label: state.protectionEnabled
                    ? 'Turn Protection Off'
                    : 'Turn Protection On',
                subtitle: !state.commitmentSet
                    ? 'Set commitment first'
                    : state.commitmentActive && state.protectionEnabled
                        ? 'Locked until commitment ends'
                        : 'Uses in-app scanner protection',
                onPressed: onToggleProtection,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Cloud Sync',
                subtitle: 'Backup, restore, and sync foundation',
                onPressed: onOpenCloudSync ?? () {},
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Open Accessibility Settings',
                subtitle: 'Enable Focus Shield manually',
                onPressed: onOpenAccessibilitySettings,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Protection Database',
                subtitle: 'Manage saved blocklist',
                onPressed: onOpenProtectionDatabase,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Goals & Affirmations',
                subtitle: 'Manage personal discipline system',
                onPressed: onOpenGoalsAffirmations,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'URL Analysis Engine',
                subtitle: 'Scanner and detection rules',
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Lock Layer',
                subtitle: 'Commitment gate active in-app',
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Production Readiness',
                subtitle: 'Android test and build checklist',
                onPressed: onOpenProductionReadiness,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Database Tools'),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Open Database Debug Center',
                subtitle: 'Attempts, state, reset tools',
                onPressed: onOpenDebugCenter,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Reset App Data',
                subtitle: 'Clear local saved state',
                onPressed: onResetAppData,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
''')


def patch_app_dart(text: str) -> str:
    if "presentation/screens/cloud_sync_screen.dart" not in text:
        text = text.replace(
            "import 'presentation/screens/coach_screen.dart';",
            "import 'presentation/screens/coach_screen.dart';\n"
            "import 'presentation/screens/cloud_sync_screen.dart';",
        )

    if "bool _showCloudSync = false;" not in text:
        text = text.replace(
            "bool _showConcentration = false;\n  bool _showReflection = false;",
            "bool _showConcentration = false;\n"
            "  bool _showReflection = false;\n"
            "  bool _showCloudSync = false;",
        )

    if "_showCloudSync = false;" not in text:
        text = text.replace(
            "_showReflection = false;",
            "_showReflection = false;\n    _showCloudSync = false;",
            1,
        )

    if "void _openCloudSync()" not in text:
        marker = """  void _openReflection() {
    setState(() {
      _hideOverlays();
      _showReflection = true;
    });
  }

  void _closeDisciplineTool() {"""

        replacement = """  void _openReflection() {
    setState(() {
      _hideOverlays();
      _showReflection = true;
    });
  }

  void _openCloudSync() {
    setState(() {
      _hideOverlays();
      _showCloudSync = true;
    });
  }

  void _closeCloudSync() {
    setState(() {
      _showCloudSync = false;
      _selectedIndex = 5;
    });
  }

  void _closeDisciplineTool() {"""

        text = text.replace(marker, replacement)

    if "_showCloudSync)" not in text:
        marker = """    } else if (_showReflection) {
      overlay = ReflectionScreen(
        onBack: _closeDisciplineTool,
        onSaved: _completeReflection,
        lastReflectionText: _state.lastReflectionText,
      );
    }"""

        replacement = """    } else if (_showReflection) {
      overlay = ReflectionScreen(
        onBack: _closeDisciplineTool,
        onSaved: _completeReflection,
        lastReflectionText: _state.lastReflectionText,
      );
    } else if (_showCloudSync) {
      overlay = CloudSyncScreen(
        state: _state,
        goals: _goals,
        affirmations: _affirmations,
        blockedDomains: _blockedDomains,
        onBack: _closeCloudSync,
      );
    }"""

        text = text.replace(marker, replacement)

    if "onOpenCloudSync: _openCloudSync," not in text:
        text = text.replace(
            "onOpenProductionReadiness: _openProductionReadiness,\n"
            "        onResetAppData: _resetAppData,",
            "onOpenProductionReadiness: _openProductionReadiness,\n"
            "        onResetAppData: _resetAppData,\n"
            "        onOpenCloudSync: _openCloudSync,",
        )

    return text


patch_file("lib/app.dart", patch_app_dart)

print("Phase 4C cloud sync foundation patch completed successfully.")
