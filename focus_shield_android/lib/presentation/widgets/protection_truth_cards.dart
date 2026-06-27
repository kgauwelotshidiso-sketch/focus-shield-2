import 'package:flutter/material.dart';

import '../services/protection_truth_service.dart';

class ProtectionTruthPanel extends StatelessWidget {
  const ProtectionTruthPanel({
    super.key,
    required this.title,
    required this.children,
    this.warning = false,
  });

  final String title;
  final List<Widget> children;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1A2F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: warning ? const Color(0xFFB04C6A) : const Color(0xFF1D7F5C),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class ProtectionTruthMetricGrid extends StatelessWidget {
  const ProtectionTruthMetricGrid({super.key, required this.items});

  final List<ProtectionTruthMetric> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        for (final item in items)
          Container(
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
                  item.value,
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
                  item.label,
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
          ),
      ],
    );
  }
}

class ProtectionTruthMetric {
  const ProtectionTruthMetric(this.value, this.label);

  final String value;
  final String label;
}

class ProtectionTruthButton extends StatelessWidget {
  const ProtectionTruthButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22C55E),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProtectionActivityTruthCard extends StatefulWidget {
  const ProtectionActivityTruthCard({
    super.key,
    this.nativeStatus,
    this.status,
    this.title = 'Protection Activity',
    this.onRefresh,
    this.showCommitment = false,
  });

  final Object? nativeStatus;
  final Object? status;
  final String title;
  final Future<void> Function()? onRefresh;
  final bool showCommitment;

  @override
  State<ProtectionActivityTruthCard> createState() =>
      _ProtectionActivityTruthCardState();
}

class _ProtectionActivityTruthCardState
    extends State<ProtectionActivityTruthCard> {
  ProtectionTruthSnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }
    final snapshot = await ProtectionTruthService.load(
      nativeStatus: widget.nativeStatus ?? widget.status,
    );
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    if (_loading && snapshot == null) {
      return const ProtectionTruthPanel(
        title: 'Protection Activity',
        children: [
          Text(
            'Reading protection status...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    final data =
        snapshot ??
        const ProtectionTruthSnapshot(
          commitmentActive: false,
          commitmentDays: 0,
          daysLeft: 0,
          savedDomains: 0,
          nativeDbReady: false,
          scanningReady: false,
          blockingReady: false,
          interventionReady: false,
          readiness: 0,
          mode: 'Setup required',
          scannedToday: 0,
          newToday: 0,
          totalScanned: 0,
          blocked: 0,
          unknown: 0,
          historyCount: 0,
          latestBlockedSite: 'None',
          stableAction: 'No action yet',
          noiseControl: 'cooldown_active',
          suppressedDuplicates: 0,
          suppressedNoise: 0,
        );

    final metrics = <ProtectionTruthMetric>[
      ProtectionTruthMetric('${data.scannedToday}', 'Scanned Today'),
      ProtectionTruthMetric('${data.newToday}', 'New Today'),
      ProtectionTruthMetric('${data.totalScanned}', 'Total Scanned'),
      ProtectionTruthMetric('${data.blocked}', 'Blocked'),
      ProtectionTruthMetric('${data.unknown}', 'Review Queue'),
    ];

    if (widget.showCommitment) {
      metrics.add(
        ProtectionTruthMetric(
          data.commitmentActive ? '${data.daysLeft} days left' : 'Not set',
          'Commitment',
        ),
      );
    }

    return ProtectionTruthPanel(
      title: widget.title,
      warning: data.blocked > 0,
      children: [
        ProtectionTruthMetricGrid(items: metrics),
        const SizedBox(height: 14),
        Text(
          'Latest blocked site: ${data.latestBlockedSite}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stable protection action: ${data.stableAction}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        ProtectionTruthButton(
          title: 'Refresh Protection Counters',
          subtitle: 'Read Accessibility protection stats',
          onPressed: _load,
        ),
      ],
    );
  }
}

class ProtectionHealthTruthCard extends StatefulWidget {
  const ProtectionHealthTruthCard({
    super.key,
    this.nativeStatus,
    this.status,
    this.title = 'Protection Health — Production Readiness',
    this.onRefresh,
  });

  final Object? nativeStatus;
  final Object? status;
  final String title;
  final Future<void> Function()? onRefresh;

  @override
  State<ProtectionHealthTruthCard> createState() =>
      _ProtectionHealthTruthCardState();
}

class _ProtectionHealthTruthCardState extends State<ProtectionHealthTruthCard> {
  ProtectionTruthSnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }
    final snapshot = await ProtectionTruthService.load(
      nativeStatus: widget.nativeStatus ?? widget.status,
    );
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    if (_loading && snapshot == null) {
      return const ProtectionTruthPanel(
        title: 'Protection Health — Production Readiness',
        children: [
          Text(
            'Reading production health...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    final data =
        snapshot ??
        const ProtectionTruthSnapshot(
          commitmentActive: false,
          commitmentDays: 0,
          daysLeft: 0,
          savedDomains: 0,
          nativeDbReady: false,
          scanningReady: false,
          blockingReady: false,
          interventionReady: false,
          readiness: 0,
          mode: 'Setup required',
          scannedToday: 0,
          newToday: 0,
          totalScanned: 0,
          blocked: 0,
          unknown: 0,
          historyCount: 0,
          latestBlockedSite: 'None',
          stableAction: 'No action yet',
          noiseControl: 'cooldown_active',
          suppressedDuplicates: 0,
          suppressedNoise: 0,
        );

    return ProtectionTruthPanel(
      title: widget.title,
      warning: data.readiness < 100,
      children: [
        ProtectionTruthMetricGrid(
          items: [
            ProtectionTruthMetric('${data.readiness}%', 'Readiness'),
            ProtectionTruthMetric(data.mode, 'Mode'),
            ProtectionTruthMetric(
              data.nativeDbReady ? 'Ready' : 'Check',
              'Native DB',
            ),
            ProtectionTruthMetric(
              data.scanningReady ? 'Ready' : 'Check',
              'Scanning',
            ),
            ProtectionTruthMetric(
              data.blockingReady ? 'Ready' : 'Check',
              'Blocking',
            ),
            ProtectionTruthMetric(
              data.interventionReady ? 'Ready' : 'Check',
              'Intervention',
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Latest blocked site: ${data.latestBlockedSite}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stable action: ${data.stableAction}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Noise control: ${data.noiseControl}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Suppressed duplicates: ${data.suppressedDuplicates} | Suppressed noise: ${data.suppressedNoise}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        ProtectionTruthButton(
          title: 'Refresh Protection Health',
          subtitle: 'Read readiness and noise-control stats',
          onPressed: _load,
        ),
      ],
    );
  }
}

class CommitmentTruthCard extends StatelessWidget {
  const CommitmentTruthCard({
    super.key,
    required this.snapshot,
    required this.onSetCommitment,
  });

  final ProtectionTruthSnapshot snapshot;
  final VoidCallback onSetCommitment;

  @override
  Widget build(BuildContext context) {
    if (snapshot.commitmentActive) {
      return ProtectionTruthPanel(
        title: 'Protection Active',
        warning: false,
        children: [
          ProtectionTruthMetricGrid(
            items: [
              const ProtectionTruthMetric('Active', 'Commitment'),
              ProtectionTruthMetric(
                '${snapshot.daysLeft} days left',
                'Days Left',
              ),
              ProtectionTruthMetric(
                '${snapshot.scannedToday}',
                'Scanned Today',
              ),
              ProtectionTruthMetric('${snapshot.newToday}', 'New Sites'),
              ProtectionTruthMetric('${snapshot.blocked}', 'Blocked'),
              ProtectionTruthMetric('${snapshot.savedDomains}', 'Native DB'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Latest blocked site: ${snapshot.latestBlockedSite}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
    }

    return ProtectionTruthPanel(
      title: 'Commitment required',
      warning: true,
      children: [
        const Text(
          'Choose 7, 14, 30, 90, or 365 days before protection can activate.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        ProtectionTruthButton(
          title: 'Set Commitment',
          subtitle: 'Go to Settings',
          onPressed: onSetCommitment,
        ),
      ],
    );
  }
}
