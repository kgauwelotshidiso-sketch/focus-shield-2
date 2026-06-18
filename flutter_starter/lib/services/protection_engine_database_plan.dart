class ProtectionEngineDatabasePlan {
  static const requiredRepositories = [
    'BlockedDomainRepository',
    'BlockedAttemptRepository',
    'RecoveryActionRepository',
    'ProtectionSettingsRepository',
  ];

  static const analysisFlow = [
    'Read protection settings',
    'If protection is disabled, return ALLOW',
    'Normalize URL input',
    'Extract domain',
    'Check blocked domain repository',
    'Check local risk keywords',
    'Create ProtectionDecision',
    'If BLOCK, write blocked attempt',
    'If user recovers, write recovery action',
    'Send result to SmartCoachService',
  ];

  static const safetyRules = [
    'Protection settings must be read before any decision',
    'Privacy mode must be applied before saving blocked attempts',
    'The engine must not store plain PIN values',
    'The engine must not bypass the repository layer',
    'The VPN layer must only call the engine after database initialization',
  ];
}
