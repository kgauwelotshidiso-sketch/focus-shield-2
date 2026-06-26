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
  const AiLiteClassifier({required this.blockedDomains});

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
