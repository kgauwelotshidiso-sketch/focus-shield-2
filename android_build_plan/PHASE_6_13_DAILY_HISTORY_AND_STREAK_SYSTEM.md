# Phase 6.13 — Daily History and Streak System

## Purpose

Save what happened yesterday before resetting today.

## Added

- DailySummary model
- DailySummaryMapper
- daily_summaries SQLite table
- SQLite schema version 3
- currentStreak
- longestStreak
- completedDays
- Daily History screen
- Streak display on Home / Progress / Debug Center
- Startup summary creation before daily reset
- Repository methods:
  - saveDailySummary
  - loadDailySummaries
- Tests for:
  - streak logic
  - daily summary creation
  - repository summary save/load

## Preserved

- lifetime XP
- attempt history
- saved blocked domains
- protection settings

## Next phase

Phase 6.14 — Goals and Affirmations Manager

Planned:
- Add custom goals
- Add custom affirmations
- Save goals and affirmations in SQLite
- Show selected affirmation on Home / Intervention
