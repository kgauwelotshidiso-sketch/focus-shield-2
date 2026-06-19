# Phase 6.10 — Attempt History Actions + Recovery Intelligence

## Purpose

Upgrade saved blocked attempts from passive history into active recovery tools.

## Added

- Mark individual attempts recovered
- Attempt details card
- Attempt filters:
  - All
  - Pending
  - Recovered
- Recovery intelligence message
- Debug Center recovery summary
- Repository method:
  - markAttemptRecovered(id)
- SQLite support for individual attempt recovery
- In-memory support for individual attempt recovery
- Tests for:
  - specific attempt recovery
  - Debug Center recovery action

## Why this matters

Focus Shield should not only block risk signals. It should help the user close the loop after a block.

A block without recovery is incomplete.

## Next phase

Phase 6.11 — Coach Intelligence From Recovery History

Planned:
- Coach uses pending attempts
- Coach detects weak recovery behavior
- Coach gives daily recommendation
- Coach shows discipline score trend
