# Phase 3.47 — DNS Forwarding or Local DNS Proxy Planning

## Status

Complete.

## Purpose

Plan the next safe technical path after Phase 3.45 proved that DNS route capture works but breaks internet access when captured packets are not forwarded.

## Key Finding From Phase 3.45

DNS route capture successfully produced:

- DNS candidates
- DNS parse attempts
- DNS queries parsed
- Last parsed host
- Dry-run allow decisions

But internet access stopped because Focus Shield captured DNS packets without forwarding or proxying them.

## Safety Decision

Do not re-enable DNS route capture until Focus Shield has one of these:

1. Local DNS proxy
2. DNS packet forwarding
3. Full VPN packet forwarding
4. Safer app-level protection approach

## Recommended Direction

The safest next direction is:

Local DNS proxy first.

## Why Local DNS Proxy First

A local DNS proxy is safer than full packet forwarding because it focuses only on DNS requests instead of trying to forward all traffic.

It allows Focus Shield to:

- Receive DNS queries
- Parse the requested hostname
- Compare hostname against the blocklist
- Forward allowed DNS queries to an upstream DNS server
- Return safe responses
- Keep blocking disabled during testing

## What Must Stay Disabled

During planning and first implementation:

- blockingEnabled must remain false
- automatic blocking must remain disabled
- full traffic capture must remain disabled
- DNS route capture must stay disabled until proxy forwarding exists

## First DNS Proxy Goal

The first implementation should only prove that allowed DNS queries can be forwarded without breaking internet.

## First DNS Proxy Test Mode

Mode name:

dns_proxy_diagnostic_only

## First DNS Proxy Safety Rules

The first test must:

- Keep blocking disabled
- Forward allowed DNS queries
- Not block anything
- Not upload traffic data
- Not store full browsing history
- Log only diagnostic counters
- Stop cleanly when VPN stops

## Required Diagnostic Counters

The next implementation should track:

- dnsProxyPrepared
- dnsProxyRunning
- dnsProxyQueriesReceived
- dnsProxyQueriesForwarded
- dnsProxyResponsesReturned
- dnsProxyErrors
- lastDnsProxyHost
- lastDnsProxyDecision

## Blocking Rule

Blocking may only be considered later after:

1. DNS proxy forwarding works
2. Internet continues working
3. DNS query parsing is stable
4. Stop command works
5. Dry-run decisions are reliable
6. Safe test domains are confirmed
7. Multiple real-device tests pass

## Next Phase

Phase 3.48 — DNS Proxy Diagnostic Architecture Preparation
