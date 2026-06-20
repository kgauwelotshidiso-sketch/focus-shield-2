# Phase 3.25 — Real Device Stop and Restart Safety Test

## Status

Complete.

## Purpose

Verify that the native VPN shell can stop and restart safely on a real Android device.

## Test Steps

1. Tap Stop
2. Tap Refresh
3. Confirm VPN service becomes Inactive
4. Tap Start Protection
5. Tap Refresh
6. Confirm VPN service becomes Active again

## Expected Safe State After Restart

- VPN service: Active
- Safe mode: On
- Protection mode: dry_run_prepared
- Observation safety gate: Locked
- Live traffic reading: Disabled
- Blocking: Disabled
- Blocklist: Loaded
- Native DNS filter: Ready
- Packet loop: Prepared
- DNS parser: Prepared
- Dry-run mode: Ready

## Result

The stop and restart flow was tested on a real Android device.

## Safety State

The app remains safe:

- liveTrafficReadEnabled: false
- blockingEnabled: false
- liveObservationSafetyGate: locked_until_android_sdk_testing

## Next Phase

Phase 3.26 — Real Device Observation Button Safety Test
