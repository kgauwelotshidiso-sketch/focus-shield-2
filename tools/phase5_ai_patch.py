from pathlib import Path

ROOT = Path("focus_shield_android")


def write(path: str, text: str) -> None:
    full_path = ROOT / path
    full_path.parent.mkdir(parents=True, exist_ok=True)
    full_path.write_text(text.strip() + "\n", encoding="utf-8")
    print(f"wrote {full_path}")


write("lib/domain/services/ai_lite_classifier.dart", r'''
class AiLiteClassification {
  const AiLiteClassification({
    required this.input,
    required this.domain,
    required this.category,
    required this.riskScore,
    required this.confidence,
    required this.shouldBlock,
    required this.isUnknown,
    required this.signals,
    required this.explanation,
  });

  final String input;
  final String domain;
  final String category;
  final int riskScore;
  final double confidence;
  final bool shouldBlock;
  final bool isUnknown;
  final List<String> signals;
  final String explanation;
}

class AiLiteClassifier {
  const AiLiteClassifier({
    required this.blockedDomains,
  });

  final List<String> blockedDomains;

  AiLiteClassification classify(String rawInput) {
    final input = rawInput.trim().toLowerCase();
    final domain = _normalizeDomain(input);

    if (domain.isEmpty) {
      return const AiLiteClassification(
        input: '',
        domain: '',
        category: 'empty',
        riskScore: 0,
        confidence: 0.0,
        shouldBlock: false,
        isUnknown: true,
        signals: ['No website entered'],
        explanation: 'Enter a website before scanning.',
      );
    }

    final signals = <String>[];
    var score = 0;
    var category = 'safe';
    var isUnknown = false;

    final exactBlocklistHit = blockedDomains.any((blocked) {
      final cleanBlocked = _normalizeDomain(blocked);
      return domain == cleanBlocked || domain.endsWith('.$cleanBlocked');
    });

    if (exactBlocklistHit) {
      score += 95;
      category = 'saved-blocklist';
      signals.add('Matched saved blocklist');
    }

    final highRiskSignals = <String>[
      'adult',
      'nsfw',
      'xxx',
      'cam',
      'escort',
      'casino',
      'bet',
      'gambling',
      'crack',
      'piracy',
      'torrent',
    ];

    final mediumRiskSignals = <String>[
      'dating',
      'chat',
      'stream',
      'leak',
      'proxy',
      'bypass',
      'mirror',
      'free-movie',
      'freegame',
    ];

    final productivitySignals = <String>[
      'learn',
      'study',
      'school',
      'college',
      'course',
      'docs',
      'github',
      'flutter',
      'wikipedia',
      'khanacademy',
    ];

    for (final signal in highRiskSignals) {
      if (domain.contains(signal)) {
        score += 30;
        signals.add('High-risk signal: $signal');
      }
    }

    for (final signal in mediumRiskSignals) {
      if (domain.contains(signal)) {
        score += 15;
        signals.add('Medium-risk signal: $signal');
      }
    }

    for (final signal in productivitySignals) {
      if (domain.contains(signal)) {
        score -= 20;
        signals.add('Productive signal: $signal');
      }
    }

    final suspiciousShapeScore = _suspiciousDomainShapeScore(domain);
    if (suspiciousShapeScore > 0) {
      score += suspiciousShapeScore;
      signals.add('Suspicious domain shape');
    }

    score = score.clamp(0, 100);

    if (category == 'safe') {
      category = _categoryFromSignals(signals, score);
    }

    if (signals.isEmpty) {
      isUnknown = true;
      signals.add('No strong local signal found');
      category = 'unknown';
      score = score < 25 ? 25 : score;
    }

    final shouldBlock = score >= 70;
    final confidence = (score / 100).clamp(0.0, 1.0);

    return AiLiteClassification(
      input: rawInput,
      domain: domain,
      category: category,
      riskScore: score,
      confidence: confidence,
      shouldBlock: shouldBlock,
      isUnknown: isUnknown && !shouldBlock,
      signals: signals,
      explanation: _explain(
        domain: domain,
        score: score,
        category: category,
        shouldBlock: shouldBlock,
        isUnknown: isUnknown,
      ),
    );
  }

  String _normalizeDomain(String value) {
    var clean = value.trim().toLowerCase();

    clean = clean.replaceFirst(RegExp(r'^https?://'), '');
    clean = clean.replaceFirst(RegExp(r'^www\.'), '');
    clean = clean.split('/').first;
    clean = clean.split('?').first;
    clean = clean.split('#').first;
    clean = clean.split(':').first;

    return clean.trim();
  }

  int _suspiciousDomainShapeScore(String domain) {
    var score = 0;

    final digitCount = RegExp(r'\d').allMatches(domain).length;
    final hyphenCount = RegExp('-').allMatches(domain).length;

    if (digitCount >= 4) {
      score += 10;
    }

    if (hyphenCount >= 3) {
      score += 10;
    }

    if (domain.length > 35) {
      score += 10;
    }

    if (!domain.contains('.')) {
      score += 5;
    }

    return score;
  }

  String _categoryFromSignals(List<String> signals, int score) {
    final joined = signals.join(' ').toLowerCase();

    if (joined.contains('saved blocklist')) return 'saved-blocklist';
    if (joined.contains('casino') ||
        joined.contains('bet') ||
        joined.contains('gambling')) {
      return 'gambling';
    }
    if (joined.contains('adult') ||
        joined.contains('nsfw') ||
        joined.contains('xxx') ||
        joined.contains('escort') ||
        joined.contains('cam')) {
      return 'adult-content';
    }
    if (joined.contains('proxy') ||
        joined.contains('bypass') ||
        joined.contains('mirror')) {
      return 'bypass-risk';
    }
    if (joined.contains('productive')) return 'productive';
    if (score >= 70) return 'high-risk';
    if (score >= 40) return 'medium-risk';

    return 'unknown';
  }

  String _explain({
    required String domain,
    required int score,
    required String category,
    required bool shouldBlock,
    required bool isUnknown,
  }) {
    if (shouldBlock) {
      return '$domain was blocked because the local AI-lite classifier gave it a high risk score of $score/100 in category $category.';
    }

    if (isUnknown) {
      return '$domain was not blocked, but it was added to the unknown-site review queue because there were not enough local signals.';
    }

    return '$domain was allowed because the local AI-lite classifier found low risk signals. Score: $score/100.';
  }
}
''')
write("lib/domain/services/protection_engine.dart", r'''
import 'ai_lite_classifier.dart';

class ProtectionDecision {
  const ProtectionDecision({
    required this.domain,
    required this.blocked,
    required this.category,
    required this.confidence,
    required this.reason,
    this.riskScore = 0,
    this.signals = const <String>[],
    this.isUnknown = false,
  });

  final String domain;
  final bool blocked;
  final String category;
  final double confidence;
  final String reason;
  final int riskScore;
  final List<String> signals;
  final bool isUnknown;

  factory ProtectionDecision.fromAiLite(AiLiteClassification classification) {
    return ProtectionDecision(
      domain: classification.domain,
      blocked: classification.shouldBlock,
      category: classification.category,
      confidence: classification.confidence,
      reason: classification.explanation,
      riskScore: classification.riskScore,
      signals: classification.signals,
      isUnknown: classification.isUnknown,
    );
  }
}

class ProtectionEngine {
  const ProtectionEngine({
    required this.blockedDomains,
  });

  final List<String> blockedDomains;

  ProtectionDecision analyze(String rawInput) {
    final classifier = AiLiteClassifier(blockedDomains: blockedDomains);
    final classification = classifier.classify(rawInput);
    return ProtectionDecision.fromAiLite(classification);
  }
}
''')

write("lib/presentation/screens/scanner_screen.dart", r'''
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/blocked_domain.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/services/protection_engine.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
    required this.protectionEnabled,
    required this.blockedDomains,
    required this.state,
    required this.onDecision,
  });

  final bool protectionEnabled;
  final List<BlockedDomain> blockedDomains;
  final FocusShieldState state;
  final ValueChanged<ProtectionDecision> onDecision;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _controller = TextEditingController();
  final List<ProtectionDecision> _unknownReviewQueue = <ProtectionDecision>[];

  ProtectionDecision? _decision;

  void _scan(String value) {
    final engine = ProtectionEngine(
      blockedDomains: widget.blockedDomains.map((item) => item.domain).toList(),
    );

    final decision = engine.analyze(value);

    setState(() {
      _decision = decision;

      if (decision.isUnknown &&
          decision.domain.isNotEmpty &&
          !_unknownReviewQueue.any((item) => item.domain == decision.domain)) {
        _unknownReviewQueue.insert(0, decision);
      }
    });

    widget.onDecision(decision);
  }

  void _scanSafeExample() {
    _scan('study-example.com');
  }

  void _scanBlockedExample() {
    _scan('blocked-example.com');
  }

  void _scanHighRiskExample() {
    _scan('adult-risk-example.com');
  }

  void _clearUnknownQueue() {
    setState(() {
      _unknownReviewQueue.clear();
    });
  }

  Color _riskColor(ProtectionDecision decision) {
    if (decision.blocked) return AppTheme.danger;
    if (decision.isUnknown) return AppTheme.warning;
    return AppTheme.primary;
  }

  String _decisionTitle(ProtectionDecision decision) {
    if (decision.blocked) return 'Blocked by AI-lite classifier';
    if (decision.isUnknown) return 'Unknown site added to review queue';
    return 'Domain allowed';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decision = _decision;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Scanner',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Text(
          widget.protectionEnabled
              ? 'Protection scanner is active'
              : 'Protection is off until commitment is active',
        ),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: StatGrid(
            items: {
              'Scanned Today': '${widget.state.websitesScannedToday}',
              'New Today': '${widget.state.newWebsitesScannedToday}',
              'Total Scanned': '${widget.state.totalWebsitesScanned}',
              'Review Queue': '${_unknownReviewQueue.length}',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: StatGrid(
            items: {
              'AI-lite': 'Local',
              'DB Domains': '${widget.blockedDomains.length}',
              'Risk Mode': 'Score',
              'API Cost': 'None',
            },
          ),
        ),
        ShieldCard(
          borderColor:
              widget.protectionEnabled ? AppTheme.secondary : AppTheme.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI-lite Website Scanner'),
              const SizedBox(height: 8),
              const Text(
                'Local classifier checks saved blocklist, risk signals, domain shape, category, and confidence.',
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('scannerDomainInput'),
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'example.com or suspicious-example.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Scan Website',
                subtitle: 'AI-lite risk score + explanation',
                onPressed: () => _scan(_controller.text),
              ),
            ],
          ),
        ),
        ShieldCard(
          child: Column(
            children: [
              ActionButton(
                label: 'Test Safe Domain',
                subtitle: 'study-example.com',
                onPressed: _scanSafeExample,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Test Blocked Domain',
                subtitle: 'blocked-example.com',
                onPressed: _scanBlockedExample,
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Test High-Risk Signal',
                subtitle: 'adult-risk-example.com',
                onPressed: _scanHighRiskExample,
              ),
            ],
          ),
        ),
        if (decision != null)
          ShieldCard(
            borderColor: _riskColor(decision),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_decisionTitle(decision)),
                const SizedBox(height: 8),
                Text('Domain: ${decision.domain}'),
                Text('Category: ${decision.category}'),
                Text('Risk score: ${decision.riskScore}/100'),
                Text('Confidence: ${(decision.confidence * 100).round()}%'),
                const SizedBox(height: 8),
                Text(decision.reason),
                const SizedBox(height: 12),
                const Text('Risk signals'),
                const SizedBox(height: 6),
                ...decision.signals.map(
                  (signal) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $signal'),
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
              const Text('Unknown-site review queue'),
              const SizedBox(height: 8),
              Text(
                _unknownReviewQueue.isEmpty
                    ? 'No unknown sites waiting for review.'
                    : '${_unknownReviewQueue.length} unknown site(s) waiting for review.',
              ),
              const SizedBox(height: 12),
              if (_unknownReviewQueue.isNotEmpty)
                ..._unknownReviewQueue.take(5).map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '• ${item.domain} — ${item.riskScore}/100 — ${item.category}',
                        ),
                      ),
                    ),
              if (_unknownReviewQueue.isNotEmpty) ...[
                const SizedBox(height: 8),
                ActionButton(
                  label: 'Clear Review Queue',
                  subtitle: 'Local queue only',
                  onPressed: _clearUnknownQueue,
                ),
              ],
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text(
            'Phase 5 is local-only. No paid API, no cloud dependency, and no VPN route changes.',
          ),
        ),
      ],
    );
  }
}
''')

print("Phase 5 AI-lite classifier patch completed successfully.")
