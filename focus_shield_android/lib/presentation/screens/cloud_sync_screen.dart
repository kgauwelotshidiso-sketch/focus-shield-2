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
    _syncQueue =
        1 +
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

    await Clipboard.setData(ClipboardData(text: _backupController.text));

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
