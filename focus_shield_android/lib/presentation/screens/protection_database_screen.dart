import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/blocked_domain.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class ProtectionDatabaseScreen extends StatefulWidget {
  const ProtectionDatabaseScreen({
    super.key,
    required this.blockedDomains,
    required this.onBack,
    required this.onAddDomain,
    required this.onDeleteDomain,
    required this.onRefresh,
  });

  final List<BlockedDomain> blockedDomains;
  final VoidCallback onBack;
  final void Function(String domain, String category) onAddDomain;
  final ValueChanged<int> onDeleteDomain;
  final VoidCallback onRefresh;

  @override
  State<ProtectionDatabaseScreen> createState() => _ProtectionDatabaseScreenState();
}

class _ProtectionDatabaseScreenState extends State<ProtectionDatabaseScreen> {
  final _domainController = TextEditingController();
  final _categoryController = TextEditingController(text: 'custom-blocklist');

  @override
  void dispose() {
    _domainController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _addDomain() {
    widget.onAddDomain(
      _domainController.text,
      _categoryController.text,
    );

    _domainController.clear();
    _categoryController.text = 'custom-blocklist';
  }

  @override
  Widget build(BuildContext context) {
    final sortedDomains = [...widget.blockedDomains]
      ..sort((a, b) => a.domain.compareTo(b.domain));

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Protection Database',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        const Text('Saved SQLite-backed blocklist'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Saved Domains': '${widget.blockedDomains.length}',
              'Database': 'SQLite',
              'Mode': 'Offline',
              'Scanner': 'Connected',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Custom Blocked Domain'),
              const SizedBox(height: 12),
              TextField(
                key: const Key('blockedDomainInput'),
                controller: _domainController,
                decoration: const InputDecoration(
                  hintText: 'example-risk.com',
                  labelText: 'Domain',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('blockedCategoryInput'),
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Add Domain',
                subtitle: 'Save to local database',
                onPressed: _addDomain,
              ),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saved Blocked Domains'),
              const SizedBox(height: 12),
              if (sortedDomains.isEmpty)
                const Text('No blocked domains saved.')
              else
                ...sortedDomains.map((blockedDomain) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blockedDomain.domain,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('Category: ${blockedDomain.category}'),
                        Text('Updated: ${blockedDomain.updatedAt.toIso8601String()}'),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => widget.onDeleteDomain(blockedDomain.id),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Remove'),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.warning,
          child: ActionButton(
            label: 'Refresh Blocklist',
            subtitle: 'Reload from SQLite',
            onPressed: widget.onRefresh,
          ),
        ),
      ],
    );
  }
}
