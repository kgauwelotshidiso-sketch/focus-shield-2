# Phase 6.8 — App Reset, Attempt History, and Database Debug Center

## Purpose

Add visible tools for managing and inspecting Focus Shield's saved local data.

## Added

- Database Debug Center screen
- Attempt History section
- Saved app state summary
- Recovery / pending attempt summary
- Protection state summary
- Refresh Database View
- Reset App Data
- Settings shortcut to Debug Center

## Why this matters

SQLite is now connected, but the user needs a way to see and manage saved data.

This phase makes the database visible inside the app so future features can be tested properly.

## Next phase

Phase 6.9 — Protection Database Manager

Planned:
- Add blocked domains list UI
- Add custom blocked domain
- Remove blocked domain
- Persist blocked domains in SQLite
- Connect scanner to SQLite blocklist
