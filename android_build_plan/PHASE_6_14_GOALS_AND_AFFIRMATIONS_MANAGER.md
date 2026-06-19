# Phase 6.14 — Goals and Affirmations Manager

## Purpose

Make Focus Shield personal by saving the user's goals and affirmations in SQLite.

## Added

- Goal model upgrade
- Affirmation model upgrade
- GoalMapper
- AffirmationMapper
- Repository methods:
  - loadGoals
  - saveGoal
  - deleteGoal
  - loadAffirmations
  - saveAffirmation
  - deleteAffirmation
- SQLite-backed goals
- SQLite-backed affirmations
- Default goals
- Default favorite affirmation
- Goals & Affirmations Manager screen
- Home screen reads goals and favorite affirmation
- Intervention screen shows goals and favorite affirmation
- Reset restores default goals and default affirmation
- Tests for repository and UI flow

## Default affirmation

“I pause, I listen, and I follow my dreams.”

## Next phase

Phase 6.15 — Production Polish and Android Run Test

Planned:
- App polish
- Empty-state improvements
- Android run checks
- Flutter build readiness check
- APK preparation path
