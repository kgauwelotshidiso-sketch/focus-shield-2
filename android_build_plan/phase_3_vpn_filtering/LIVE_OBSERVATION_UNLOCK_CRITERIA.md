# Live Observation Unlock Criteria

## Current State

Locked.

## Required Before Unlock

- GitHub Actions APK build success
- Real device VPN activation success
- Real device stop/restart success
- Real device observation safety success
- Real device blocklist reload success
- Full native regression success
- Clear status reporting
- Blocking remains disabled

## First Unlock Target

Only unlock:

liveTrafficReadEnabled

Do not unlock:

blockingEnabled

## First Live Mode Name

live_observation_only

## First Live Test Goal

Confirm the VPN packet loop can observe packet flow without blocking.

## First Live Test Must Not

- Block domains
- Upload traffic
- Save full browsing history
- Run indefinitely
- Use large public blocklists

## Emergency Stop Rule

If the phone network becomes unstable, press Stop immediately.
