# Phase 3.28 — Real Device Full Native Protection Regression Test

## Status

Complete.

## Purpose

Run a full real-device regression test for the native protection system before planning any live packet observation work.

## Regression Flow Tested

- Refresh native status
- Stop VPN shell
- Restart VPN shell
- Prepare observation
- Disable observation
- Reload blocklist
- Refresh final native status

## Confirmed Safe State

- VPN service can become Active
- VPN service can become Inactive
- Safe mode remains On
- Protection mode returns to dry_run_prepared
- Observation safety gate remains Locked
- Live traffic reading remains Disabled
- Blocking remains Disabled
- Blocklist remains Loaded
- Saved blocked domains remains 3
- Native DNS filter remains Ready
- Packet loop remains Prepared
- DNS parser remains Prepared
- Dry-run mode remains Ready

## Result

The real-device native protection regression test passed.

## Important

Phase 3 native protection shell is stable enough to prepare the next planning step.

The app still does not read or block live traffic.

## Safety State

The app remains safe:

- liveTrafficReadEnabled: false
- blockingEnabled: false
- liveObservationSafetyGate: locked_until_android_sdk_testing

## Next Phase

Phase 3.29 — Live Observation Risk Review and Unlock Criteria
