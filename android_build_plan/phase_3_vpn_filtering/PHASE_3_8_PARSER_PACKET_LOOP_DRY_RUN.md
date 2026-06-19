# Phase 3.8 — Parser to Packet Loop Dry-Run Mode

## Status

Complete.

## Added

- DNS parser connected to VPN packet loop
- Dry-run mode flag
- Dry-run would-block counter
- Last dry-run decision status
- Flutter status model updated
- Settings Native Protection card updated
- Widget test mock updated

## Important Safety Decision

Live packet reading is still disabled.

The packet loop now knows how to use the DNS parser and filter, but the service starts it with:

liveReadEnabled = false

This means no live phone traffic is blocked or disrupted yet.

## What Dry-Run Means

When live reading is enabled later, dry-run mode will observe DNS queries and decide:

- would allow
- would block

But it will not block traffic until the blocking mode is deliberately enabled in a later phase.

## Next Phase

Phase 3.9 — Safe Native Parser Unit Test Scaffolding
