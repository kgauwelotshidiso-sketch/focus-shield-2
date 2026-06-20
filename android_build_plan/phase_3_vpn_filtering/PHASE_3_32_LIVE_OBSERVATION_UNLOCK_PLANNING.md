# Phase 3.32 — Live Observation Unlock Planning

## Status

Complete.

## Purpose

Plan the first safe live observation unlock before changing the code gate.

This phase does not unlock live observation.

## Current Verified State

The real Android device confirmed:

- Native status version: 3
- Safe mode: On
- Code gate ready: Yes
- Code gate unlocked: No
- Gate version: 1
- Unlock attempts: 0
- Observation safety gate: Locked
- Live traffic reading: Disabled
- Blocking: Disabled
- Blocklist: Loaded
- Saved blocked domains: 3

## Unlock Target

The first unlock must only enable:

- liveTrafficReadEnabled: true

It must not enable:

- blockingEnabled: true

## First Live Mode

The first live mode name must be:

live_observation_only

## First Live Observation Goal

Confirm that the VPN packet loop can observe packet flow safely while blocking remains disabled.

## What Must Stay Disabled

The following must remain disabled during the first live observation test:

- Blocking
- Automatic domain blocking
- Background long-running monitoring
- Traffic upload
- Full browsing history storage
- Public blocklist enforcement

## First Live Observation Test Rules

The first test must be limited:

1. Install the APK built from the unlock branch
2. Open Native Protection screen
3. Start Protection
4. Tap Prepare Observation
5. Tap Refresh
6. Confirm:
   - Code gate unlocked: Yes
   - Protection mode: live_observation_only
   - Live traffic reading: Enabled
   - Blocking: Disabled
   - VPN service: Active
7. Leave it running briefly only
8. Tap Stop
9. Confirm:
   - VPN service: Inactive
   - Live traffic reading: Disabled
   - Blocking: Disabled

## Emergency Stop Rule

If the phone network becomes unstable, press Stop immediately.

## Safety Rule

If blocking becomes enabled during this phase, the test fails immediately.

## Required Success Criteria

The first unlock is only successful if:

- The app starts normally
- VPN shell activates
- Code gate reports unlocked
- Live traffic reading reports enabled
- Blocking remains disabled
- Stop returns VPN service to inactive
- No crash occurs
- No network instability occurs

## Decision

Phase 3.32 is a planning phase only.

The gate remains locked until the next code phase.

## Next Phase

Phase 3.33 — Live Observation Unlock Patch Without Blocking
