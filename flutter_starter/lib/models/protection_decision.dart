enum ProtectionDecisionType {
  allow,
  block,
}

class ProtectionDecision {
  final ProtectionDecisionType type;
  final String domain;
  final String category;
  final String reason;
  final double confidence;

  const ProtectionDecision({
    required this.type,
    required this.domain,
    required this.category,
    required this.reason,
    required this.confidence,
  });

  bool get shouldBlock => type == ProtectionDecisionType.block;

  factory ProtectionDecision.allow({
    required String domain,
    required String reason,
  }) {
    return ProtectionDecision(
      type: ProtectionDecisionType.allow,
      domain: domain,
      category: 'safe',
      reason: reason,
      confidence: 0.0,
    );
  }

  factory ProtectionDecision.block({
    required String domain,
    required String category,
    required String reason,
    required double confidence,
  }) {
    return ProtectionDecision(
      type: ProtectionDecisionType.block,
      domain: domain,
      category: category,
      reason: reason,
      confidence: confidence,
    );
  }
}
