# Focus Shield Phase 3H Protection Engine Database Integration Plan

This phase defines how the future Flutter ProtectionEngine connects to the repository and database layer.

## Required repositories

1. BlockedDomainRepository
2. BlockedAttemptRepository
3. RecoveryActionRepository
4. ProtectionSettingsRepository

## Decision flow

1. Read protection settings.
2. If protection is disabled, return ALLOW.
3. Normalize the URL/domain input.
4. Extract domain.
5. Check blocked_domains through BlockedDomainRepository.
6. Check local risk keywords.
7. Return ProtectionDecision.
8. If BLOCK, save blocked attempt through BlockedAttemptRepository.
9. Apply privacy mode before saving the attempt.
10. If user completes recovery action, save it through RecoveryActionRepository.
11. Mark the attempt as recovered if linked.
12. Send the event to SmartCoachService later.

## Privacy rules

1. If privacy mode is stats-only, save website as [hidden].
2. If privacy mode is full, save the exact domain.
3. PIN values are never handled by ProtectionEngine.
4. ProtectionEngine only reads protection settings, it does not manage PIN setup.
5. Blocked attempts must be logged through repositories.

## VPN readiness rule

The future native Android VPN/DNS layer must not directly write to SQLite.

Correct flow:

Android VPN Service
→ Flutter MethodChannel / Native bridge
→ ProtectionEngine
→ Repository layer
→ SQLite database
→ Intervention / Attempt Intelligence

## Next phase

Phase 3I should define the native Android VPN/DNS filtering preparation plan.
