class AndroidBuildReadinessChecklist {
  static const requiredPreparationPhases = [
    'Phase 3A Android Migration Roadmap',
    'Phase 3B Flutter Project Blueprint',
    'Phase 3C Flutter Starter Files',
    'Phase 3D Data Migration Specification',
    'Phase 3E SQLite Schema Starter Upgrade',
    'Phase 3F SQLite Repository DAO Starters',
    'Phase 3G Database Provider Connection Plan',
    'Phase 3H Protection Engine Database Integration Plan',
    'Phase 3I Native Android VPN DNS Filtering Preparation Plan',
    'Phase 3J Native VPN Service Starter Skeleton',
    'Phase 3K MethodChannel Contract Expansion',
  ];

  static const readinessGates = [
    'Flutter starter files exist',
    'SQLite schema v1 exists',
    'Repository starter layer exists',
    'Database provider plan exists',
    'ProtectionEngine database integration exists',
    'Native VPN/DNS architecture exists',
    'Kotlin skeleton files exist',
    'MethodChannel contract exists',
    'Privacy rules are documented',
    'Safety limits are documented',
  ];

  static const notReadyIf = [
    'Database provider is missing',
    'Repositories are missing',
    'ProtectionEngine bypasses repositories',
    'Native layer writes directly to SQLite',
    'MethodChannel contract is undefined',
    'VPN starts before user permission',
    'Privacy mode is not respected',
    'Delayed disable is not planned',
  ];
}
