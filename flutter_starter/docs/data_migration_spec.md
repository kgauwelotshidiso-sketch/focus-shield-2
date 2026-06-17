# Focus Shield Phase 3D Data Migration Specification

This document maps the current Focus Shield web prototype data into the future Flutter Android SQLite structure.

## Migration principle

The web app currently stores most data in localStorage. The future Flutter app should store long-term user data in SQLite.

## Main migration map

| Web Data Area | Current Storage | Future SQLite Table |
|---|---|---|
| Blocked domains | localStorage JSON | blocked_domains |
| Blocked attempts | localStorage JSON | blocked_attempts |
| Recovery actions | localStorage JSON | recovery_actions |
| Protection settings | localStorage JSON | protection_settings |
| Privacy mode | localStorage string | protection_settings.privacy_mode |
| Goals | localStorage JSON | goals |
| Daily reflections | localStorage JSON | daily_reflections |
| End reviews | localStorage JSON | daily_end_reviews |
| Timeline events | localStorage JSON | timeline_events |
| Coach memory | localStorage JSON | coach_memory |
| XP history | localStorage JSON | xp_events |
| Badges | localStorage JSON | badges |
| Focus sessions | localStorage JSON | focus_sessions |
| Concentration sessions | localStorage JSON | concentration_sessions |
| Migration checklist progress | localStorage JSON | migration_progress |

## Privacy rules

1. Do not force exact blocked websites into SQLite if privacy mode is stats-only.
2. If privacy mode is stats-only, store website as [hidden].
3. Keep recovery actions because they show discipline recovery, not explicit website detail.
4. Never export PIN values in plain text.
5. PIN hash may stay local-only unless the user intentionally migrates it.

## Migration order

1. Protection settings
2. Blocked domains
3. Blocked attempts
4. Recovery actions
5. Goals
6. Reflections and reviews
7. Timeline events
8. Coach memory
9. XP and badges
10. Focus and concentration sessions

## Validation rules

After migration, the Android app should confirm:

1. Blocked domain count matches.
2. Blocked attempt count matches.
3. Recovery rate matches or recalculates correctly.
4. Goals count matches.
5. XP total matches.
6. Badge count matches.
7. Privacy mode is preserved.
8. Protection enabled state is preserved.
9. PIN is reset or re-created safely if not migrated.
