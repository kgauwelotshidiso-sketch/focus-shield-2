import '../models/protection_decision.dart';
import 'blocklist_service.dart';

class ProtectionEngine {
  final BlocklistService blocklistService;

  ProtectionEngine(this.blocklistService);

  Future<ProtectionDecision> analyzeUrl(String input) async {
    final domain = extractDomain(input);
    final blockedDomain = await blocklistService.findDomain(domain);

    if (blockedDomain != null) {
      return ProtectionDecision.block(
        domain: domain,
        category: blockedDomain.category,
        reason: 'Domain matched local blocklist',
        confidence: 0.98,
      );
    }

    if (containsRiskKeyword(input)) {
      return ProtectionDecision.block(
        domain: domain,
        category: 'keyword-risk',
        reason: 'URL matched local risk keyword',
        confidence: 0.86,
      );
    }

    return ProtectionDecision.allow(
      domain: domain,
      reason: 'No local risk signal found',
    );
  }

  String extractDomain(String input) {
    final trimmed = input.trim().toLowerCase();
    final uri = Uri.tryParse(
      trimmed.startsWith('http') ? trimmed : 'https://$trimmed',
    );

    return uri?.host.replaceFirst('www.', '') ?? trimmed;
  }

  bool containsRiskKeyword(String input) {
    const keywords = ['blocked', 'temptation', 'risk', 'unsafe', 'trigger'];
    final lower = input.toLowerCase();
    return keywords.any(lower.contains);
  }
}
