# Live Observation First Test Plan

## Test Type

Live observation only.

## Blocking

Disabled.

## Allowed First Unlock Flags

- liveObservationCodeGateUnlocked: true
- liveTrafficReadEnabled: true
- protectionMode: live_observation_only

## Forbidden Flags

- blockingEnabled: true
- automatic blocking
- hidden logging
- traffic upload
- full browsing history storage

## Phone Test Order

1. Install new APK
2. Open Native Protection
3. Tap Refresh
4. Tap Start Protection
5. Tap Refresh
6. Tap Prepare Observation
7. Tap Refresh
8. Confirm live observation only
9. Stop protection
10. Confirm safe shutdown

## Pass Condition

Live observation reports enabled, but blocking remains disabled.

## Fail Condition

Any sign of blocking enabled, crash, unstable network, or unsafe status.
