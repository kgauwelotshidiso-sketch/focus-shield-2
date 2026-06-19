class ProtectionDecision {
  const ProtectionDecision({
    required this.domain,
    required this.blocked,
    required this.category,
    required this.confidence,
    required this.reason,
  });

  final String domain;
  final bool blocked;
  final String category;
  final double confidence;
  final String reason;
}

class ProtectionEngine {
  ProtectionEngine({
    List<String>? blockedDomains,
  }) : _blockedDomains = blockedDomains ??
            const [
              'blocked-example.com',
              'temptation-test.net',
              'focus-risk.org',
            ];

  final List<String> _blockedDomains;

  ProtectionDecision analyze(String input) {
    final domain = _normalizeDomain(input);

    final localMatch = _blockedDomains.any(
      (blocked) => domain == blocked || domain.endsWith('.$blocked'),
    );

    final keywordMatch = _safeRiskKeywords.any(domain.contains);

    if (localMatch) {
      return ProtectionDecision(
        domain: domain,
        blocked: true,
        category: 'local-blocklist',
        confidence: 0.96,
        reason: 'Matched local offline database.',
      );
    }

    if (keywordMatch) {
      return ProtectionDecision(
        domain: domain,
        blocked: true,
        category: 'keyword-risk',
        confidence: 0.88,
        reason: 'Matched local risk keyword.',
      );
    }

    return ProtectionDecision(
      domain: domain,
      blocked: false,
      category: 'safe',
      confidence: 0.10,
      reason: 'No local risk match found.',
    );
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

  static const _safeRiskKeywords = [
    'blocked',
    'temptation',
    'focus-risk',
    'unsafe',
    'risk',
  ];
}
