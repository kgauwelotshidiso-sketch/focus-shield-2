# Phase 3.44 — VPN Route Coverage Patch Without Blocking

## Status

Complete.

## Purpose

Patch VPN route coverage so Focus Shield can attempt safer DNS-route diagnostics without enabling blocking.

## What Changed

The VPN builder now attempts diagnostic DNS routes for:

- 1.1.1.1
- 8.8.8.8
- 2606:4700:4700::1111
- 2001:4860:4860::8888

The patch also attempts IPv6 tunnel address setup.

## Important Safety Choice

This patch does not add full traffic capture routes:

- No 0.0.0.0/0 route
- No ::/0 route

This is safer because the current packet loop observes packets but does not yet forward traffic.

## Expected Diagnostic Effect

The next real-device test may show increases in:

- IPv4 UDP packets
- IPv6 UDP packets
- DNS candidates
- IPv6 DNS candidates
- DNS parse attempts
- DNS queries parsed

## Blocking State

Blocking remains disabled.

- blockingEnabled: false

## Live Observation State

Live traffic reading may only run during:

- protectionMode: live_observation_only

## Next Phase

Phase 3.45 — Build APK and Real Device DNS Route Coverage Test
