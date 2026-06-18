import '../models/blocked_attempt.dart';
import '../models/protection_decision.dart';
import '../repositories/blocked_attempt_repository.dart';
import '../repositories/blocked_domain_repository.dart';
import '../repositories/protection_settings_repository.dart';
import '../repositories/recovery_action_repository.dart';

class ProtectionEngine {
  final BlockedDomainRepository blockedDomainRepository;
  final BlockedAttemptRepository blockedAttemptRepository;
  final RecoveryActionRepository recoveryActionRepository;
  final ProtectionSettingsRepository protectionSettingsRepository;

  ProtectionEngine({
    required this.blockedDomainRepository,
    required this.blockedAttemptRepository,
    required this.recoveryActionRepository,
    required this.protectionSettingsRepository,
  });

  Future<ProtectionDecision> analyzeUrl(String input) async {
    final settings = await protectionSettingsRepository.getSettings();

    if (settings != null && settings.protectionEnabled == false) {
      return ProtectionDecision.allow(
        domain: extractDomain(input),
        reason: 'Protection is disabled by user setting',
      );
    }

    final domain = extractDomain(input);
    final blockedDomain = await blockedDomainRepository.findByDomain(domain);

    if (blockedDomain != null) {
      final decision = ProtectionDecision.block(
        domain: domain,
        category: blockedDomain.category,
        reason: 'Domain matched local blocklist',
        confidence: 0.98,
      );

      await logBlockedDecision(decision, settings?.privacyMode ?? 'stats-only');

      return decision;
    }

    if (containsRiskKeyword(input)) {
      final decision = ProtectionDecision.block(
        domain: domain,
        category: 'keyword-risk',
        reason: 'URL matched local risk keyword',
        confidence: 0.86,
      );

      await logBlockedDecision(decision, settings?.privacyMode ?? 'stats-only');

      return decision;
    }

    return ProtectionDecision.allow(
      domain: domain,
      reason: 'No local risk signal found',
    );
  }

  Future<void> logBlockedDecision(
    ProtectionDecision decision,
    String privacyMode,
  ) async {
    final now = DateTime.now();
    final dateKey = createDateKey(now);
    final website = privacyMode == 'full' ? decision.domain : '[hidden]';

    final attempt = BlockedAttempt(
      website: website,
      category: decision.category,
      reason: decision.reason,
      confidence: decision.confidence,
      timestamp: now,
    );

    await blockedAttemptRepository.insertAttempt(attempt);

    // Future upgrade:
    // Add dateKey and privacyMode directly to BlockedAttempt model.
  }

  Future<void> recordRecoveryAction({
    int? attemptId,
    required String actionName,
    String? notes,
  }) async {
    await recoveryActionRepository.insertRecoveryAction(
      attemptId: attemptId,
      actionName: actionName,
      notes: notes,
      dateKey: createDateKey(DateTime.now()),
    );

    if (attemptId != null) {
      await blockedAttemptRepository.markRecovered(attemptId);
    }
  }

  String extractDomain(String input) {
    final trimmed = input.trim().toLowerCase();
    final uri = Uri.tryParse(
      trimmed.startsWith('http') ? trimmed : 'https://$trimmed',
    );

    return uri?.host.replaceFirst('www.', '') ?? trimmed;
  }

  bool containsRiskKeyword(String input) {
    const keywords = [
      'blocked',
      'temptation',
      'risk',
      'unsafe',
      'trigger',
    ];

    final lower = input.toLowerCase();

    return keywords.any(lower.contains);
  }

  String createDateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}
