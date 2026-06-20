# Phase 3.29 — Live Observation Risk Review and Unlock Criteria

## Status

Complete.

## Purpose

Define the exact safety rules before Focus Shield is allowed to move from VPN shell preparation into live packet observation.

## Current Confirmed Stable State

The following have passed:

- APK builds through GitHub Actions
- APK installs on a real Android device
- Native Protection screen works
- Android VPN permission flow works
- VPN shell activates
- Stop and restart work safely
- Prepare Observation stays locked
- Disable Observation works
- Reload Blocklist works
- Full native regression test passed

## Current Safety State

Focus Shield remains safe:

- Safe mode: On
- liveTrafficReadEnabled: false
- blockingEnabled: false
- liveObservationSafetyGate: locked_until_android_sdk_testing
- protectionMode: dry_run_prepared or observation_prepared_locked

## Why Live Observation Is Risky

Live packet observation is more serious than the current VPN shell because it begins reading traffic metadata moving through the local VPN layer.

Risks include:

- App crash causing phone connection issues
- VPN staying active unexpectedly
- Battery drain
- Network slowdown
- DNS parsing errors
- False positives
- Reading more packet data than needed
- Confusing status reporting
- Blocking accidentally being enabled too early

## Non-Negotiable Rule

Live observation must only read the minimum needed DNS packet metadata for safety testing.

It must not enable blocking.

It must not inspect personal content.

It must not log full browsing history.

It must not upload traffic data anywhere.

## Unlock Criteria Before Live Observation

Live observation can only be unlocked after all of these are true:

1. APK builds successfully in GitHub Actions
2. Real device VPN shell activates
3. Stop/restart safety test passes
4. Observation button safety test passes
5. Blocklist reload safety test passes
6. Full native regression test passes
7. Native status screen clearly shows:
   - liveTrafficReadEnabled
   - blockingEnabled
   - packetsObserved
   - dnsQueriesParsed
   - lastParsedHostname
8. Safety gate can be changed only by code, not by a normal UI button
9. Blocking remains disabled
10. The first live observation test is limited and reversible

## First Live Observation Rules

When live observation is eventually unlocked, the first test must follow these rules:

- Duration: very short test only
- Blocking: disabled
- App status visible
- Stop button available
- No background long-running test
- No public blocklist
- Only safe test domains
- Immediately stop if phone network becomes unstable

## Required Safety Flags During First Live Observation

Allowed:

- liveTrafficReadEnabled: true
- blockingEnabled: false
- protectionMode: live_observation_only

Not allowed:

- blockingEnabled: true
- liveObservationSafetyGate: unlocked without documentation
- automatic blocking
- hidden traffic logging

## Decision

Phase 3.29 does not unlock live observation.

It only defines the conditions required before unlocking.

## Next Phase

Phase 3.30 — Live Observation Code Gate Preparation
