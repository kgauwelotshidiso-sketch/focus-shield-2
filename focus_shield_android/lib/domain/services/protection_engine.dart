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
  const ProtectionEngine({required this.blockedDomains});

  final List<String> blockedDomains;

  ProtectionDecision analyze(String rawInput) {
    final classifier = AiLiteClassifier(blockedDomains: blockedDomains);
    final classification = classifier.classify(rawInput);
    return ProtectionDecision.fromAiLite(classification);
  }
}
