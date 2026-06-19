# Phase 6.9 — Protection Database Manager

## Purpose

Move the scanner from a hardcoded test blocklist toward a real local protection database.

## Added

- BlockedDomain model upgrade
- BlockedDomainMapper
- Repository methods:
  - loadBlockedDomains
  - saveBlockedDomain
  - deleteBlockedDomain
- SQLite-backed blocked domain storage
- Default local blocklist seeding
- Protection Database Manager screen
- Add custom blocked domain
- Remove saved blocked domain
- Scanner connected to saved blocklist
- Reset restores default blocklist
- Tests for:
  - in-memory blocklist
  - SQLite blocklist
  - UI blocklist manager
  - custom domain scanning

## Safe test domains

- blocked-example.com
- temptation-test.net
- focus-risk.org
- custom-risk.test

## Next phase

Phase 6.10 — Attempt History Actions + Recovery Intelligence

Planned:
- Mark individual attempts recovered
- Attempt details screen
- Recovery trend
- Coach feedback from attempt history
