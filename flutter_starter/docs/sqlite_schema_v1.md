# Focus Shield Phase 3E SQLite Schema Starter Upgrade

This document defines the first full SQLite schema plan for the future Flutter Android version of Focus Shield.

## Schema version

Database version: 1

## Tables

1. blocked_domains
2. blocked_attempts
3. recovery_actions
4. protection_settings
5. goals
6. daily_reflections
7. daily_end_reviews
8. timeline_events
9. coach_memory
10. xp_events
11. badges
12. streaks
13. focus_sessions
14. concentration_sessions

## Core rules

1. Every table must have a stable primary key.
2. Every long-term event should keep created_at or timestamp.
3. Protection privacy mode must be respected.
4. PIN values are never stored in plain text.
5. Blocked attempts may store [hidden] instead of exact domain.
6. XP and timeline events should be append-only where possible.
7. Recovery actions should connect to blocked attempts when possible.
8. Future schema changes must increase databaseVersion.

## Next step after this phase

Phase 3F should define SQLite DAO/repository starter classes for reading and writing these tables.
