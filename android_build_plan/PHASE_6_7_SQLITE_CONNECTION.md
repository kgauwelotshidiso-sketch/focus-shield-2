# Phase 6.7 — Connect Real Local Database Storage

## Purpose

Move Focus Shield from in-memory-only state toward real local persistence.

## Added

- sqflite package
- path package
- sqflite_common_ffi for tests
- DatabaseProvider
- SQLite schema statements
- SqliteAppStateRepository
- SQLite repository tests
- App loading from repository
- App save hooks for:
  - XP
  - mission progress
  - blocked attempts
  - recovered attempts
  - protection settings
  - coach state

## App behavior

The app now loads state from the repository on startup.

The default app uses SQLite storage.

Widget tests inject the in-memory repository so UI tests remain stable.

## Next phase

Phase 6.8 — Add App Reset, Attempt History, and Database Debug Center
