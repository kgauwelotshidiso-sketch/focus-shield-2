# Phase 3.46 — DNS Route Safety Rollback Without Blocking

## Status

Complete.

## Purpose

Remove DNS-route capture after the real-device test proved it can interrupt internet access when packet forwarding is not implemented.

## What Changed

The VPN builder no longer adds diagnostic DNS routes for:

- 1.1.1.1/32
- 8.8.8.8/32
- 2606:4700:4700::1111/128
- 2001:4860:4860::8888/128

## Why

Phase 3.45 confirmed DNS parsing works, but route capture breaks internet access because captured packets are not forwarded yet.

## Current Safety State

- Blocking remains disabled
- Live observation remains observation-only
- DNS route capture is disabled
- VPN shell can still start safely
- Packet forwarding/proxy logic is required before route capture returns

## Next Phase

Phase 3.47 — DNS Forwarding or Local DNS Proxy Planning
