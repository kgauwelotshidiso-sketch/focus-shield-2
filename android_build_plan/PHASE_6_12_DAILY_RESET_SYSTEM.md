# Phase 6.12 — Daily Reset System

## Purpose

Make Focus Shield behave like a real daily discipline system.

## Added

- DateKey helper
- FocusShieldState.lastActiveDate
- Daily reset method:
  - applyDailyResetIfNeeded()
- SQLite schema version 2
- Migration for app_state.last_active_date
- Startup daily reset check
- Daily reset tests
- UI active-day display

## Daily counters reset

- listeningWinsToday
- focusSessionsToday
- reflectionsToday
- concentrationWinsToday
- morningCommandSet
- endReviewsToday

## Preserved values

- lifetime XP
- level
- blocked attempt count
- recovered attempt count
- attempt history
- protection settings
- saved blocked domains

## Next phase

Phase 6.13 — Daily History and Streak System

Planned:
- Save daily summaries
- Track completed days
- Track current streak
- Track longest streak
- Show daily history
