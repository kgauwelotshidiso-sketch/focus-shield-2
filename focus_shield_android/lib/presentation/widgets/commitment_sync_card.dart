import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../services/commitment_sync_service.dart';
import 'action_button.dart';
import 'shield_card.dart';
import 'stat_grid.dart';

class CommitmentSyncCard extends StatefulWidget {
  const CommitmentSyncCard({
    super.key,
    this.title = 'Commitment Sync',
    this.showControls = true,
    this.onChanged,
  });

  final String title;
  final bool showControls;
  final VoidCallback? onChanged;

  @override
  State<CommitmentSyncCard> createState() => _CommitmentSyncCardState();
}

class _CommitmentSyncCardState extends State<CommitmentSyncCard> {
  CommitmentSnapshot? _snapshot;
  String _message = 'Syncing commitment status...';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snapshot = await CommitmentSyncService.load();

    if (!mounted) return;

    setState(() {
      _snapshot = snapshot;
      _message = snapshot.isSet
          ? 'Commitment synced across Home, Scanner, Progress, and Settings.'
          : 'Commitment still needs to be set.';
    });

    widget.onChanged?.call();
  }

  Future<void> _setDays(int days) async {
    final snapshot = await CommitmentSyncService.save(days);

    if (!mounted) return;

    setState(() {
      _snapshot = snapshot;
      _message = '$days-day commitment synced across the app.';
    });

    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;

    return ShieldCard(
      borderColor: snapshot?.isSet == true
          ? AppTheme.primary
          : AppTheme.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title),
          const SizedBox(height: 12),
          StatGrid(
            items: {
              'Status': snapshot?.statusLabel ?? 'Syncing',
              'Days Left': snapshot?.daysLeftLabel ?? 'Syncing',
              'Duration': snapshot?.isSet == true
                  ? '${snapshot!.days} days'
                  : 'Not set',
              'Sync': snapshot?.isSet == true ? 'Repaired' : 'Pending',
            },
          ),
          const SizedBox(height: 12),
          Text(_message),
          if (widget.showControls) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [7, 14, 30, 90, 365].map((days) {
                return ChoiceChip(
                  label: Text('$days days'),
                  selected: snapshot?.days == days,
                  onSelected: (_) => _setDays(days),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            ActionButton(
              label: 'Repair Commitment Sync',
              subtitle: 'Apply 365-day daily-use commitment',
              onPressed: () => _setDays(365),
            ),
          ],
        ],
      ),
    );
  }
}

class CommitmentStatusText extends StatefulWidget {
  const CommitmentStatusText({
    super.key,
    required this.activeText,
    required this.inactiveText,
  });

  final String activeText;
  final String inactiveText;

  @override
  State<CommitmentStatusText> createState() => _CommitmentStatusTextState();
}

class _CommitmentStatusTextState extends State<CommitmentStatusText> {
  CommitmentSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snapshot = await CommitmentSyncService.load();

    if (!mounted) return;

    setState(() {
      _snapshot = snapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = _snapshot?.isSet == true;

    return Text(active ? widget.activeText : widget.inactiveText);
  }
}
