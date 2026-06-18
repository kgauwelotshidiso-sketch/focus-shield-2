# Focus Shield Phase 3F SQLite Repository / DAO Starters

This phase creates starter repository classes for reading and writing the future SQLite tables.

## Repository layer purpose

Screens should not directly access SQLite.

Correct flow:

Flutter Screen
→ Service
→ Repository
→ SQLite database

## Created repositories

1. BlockedDomainRepository
2. BlockedAttemptRepository
3. RecoveryActionRepository
4. ProtectionSettingsRepository
5. GoalRepository
6. CoachMemoryRepository
7. XpRepository
8. SessionRepository

## Build rule

The repository files are starter templates. They do not connect to sqflite yet.

Phase 3G should connect these repositories to the database provider and real SQL queries.
