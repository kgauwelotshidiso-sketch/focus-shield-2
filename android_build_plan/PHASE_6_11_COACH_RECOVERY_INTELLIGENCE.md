# Phase 6.11 — Coach Intelligence From Recovery History

## Purpose

Make the Coach screen use real saved attempt history instead of only mission counters.

## Added

- CoachRecoveryInsight model
- Recovery-history analysis in CoachEngine
- Coach detects:
  - no attempts
  - pending attempts
  - fully recovered history
  - weak recovery behavior
- Coach screen now receives saved attempt history
- Recovery Intelligence card on Coach screen
- Recovery grade:
  - Clean
  - Strong
  - Needs Action
  - Weak Recovery
- Coach command changes when recovery is incomplete
- Tests for recovery intelligence

## Why this matters

The app should not only count progress. It should detect the user’s weak point and give the correct command.

If there are pending recovery loops, the Coach should prioritize recovery before normal progress.

## Next phase

Phase 6.12 — Daily Reset System

Planned:
- New day detection
- Reset daily mission counters
- Preserve lifetime XP
- Preserve attempt history
- Reset morning command/end review daily
