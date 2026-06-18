# Focus Shield Phase 3L Android Build Readiness Checklist

This phase verifies the full Flutter/native preparation stack before real Android implementation begins.

## Readiness areas

1. Flutter starter files exist
2. SQLite schema exists
3. Repository starters exist
4. Database provider plan exists
5. ProtectionEngine database integration exists
6. Native VPN/DNS preparation exists
7. Native Kotlin skeleton exists
8. MethodChannel contract exists
9. Safety rules are documented
10. Build order is clear

## Build readiness rule

Do not begin real VPN filtering until these are true:

- Database startup order is defined
- Repositories are defined
- ProtectionEngine uses repositories
- Native layer has a MethodChannel contract
- Privacy rules are documented
- Delayed disable is planned
- Intervention flow is planned
- Health Check shows all Phase 3 modules as PASS

## Correct implementation order after Phase 3L

1. Create real Flutter project
2. Add starter `lib/` files
3. Add sqflite and database initialization
4. Implement repositories with real SQL queries
5. Connect ProtectionEngine to repositories
6. Build Flutter UI screens
7. Add native MethodChannel implementation
8. Add VPN permission flow
9. Add non-filtering VPN service test
10. Add DNS/domain detection prototype
11. Connect BLOCK decisions to intervention and attempt logging
12. Test privacy, battery, and safety behavior
