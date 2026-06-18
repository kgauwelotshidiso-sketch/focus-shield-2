# Focus Shield Phase 3G Database Provider Connection Plan

This phase defines how the future Flutter repositories will connect to SQLite.

## Correct startup order

1. Open DatabaseProvider
2. Create schema if database is new
3. Run migrations if database version changed
4. Create repository instances
5. Inject repositories into services
6. Inject services into screens
7. Start protection engine after database is ready
8. Start native VPN/DNS layer only after protection engine is ready

## Repository dependency rule

Screens must not access SQLite directly.

Correct flow:

Flutter Screen
→ Dart Service
→ Repository / DAO
→ DatabaseProvider
→ SQLite database

## Important safety rules

1. Database must initialize before protection engine starts.
2. VPN/DNS filtering must not start until blocklist repository is ready.
3. Migrations must run before user data is read.
4. PIN values must never be stored in plain text.
5. Privacy mode must be checked before blocked attempts are saved.
6. User data must not be deleted during migration unless the user intentionally resets it.

## Future sqflite implementation

The real Flutter project will later add:

- sqflite
- path_provider or path
- openDatabase
- onCreate
- onUpgrade
- transaction support
- repository query methods
