# Phase 3.48 — DNS Proxy Diagnostic Architecture Preparation

## Status

Complete.

## Purpose

Prepare the technical architecture for a safe local DNS proxy diagnostic system.

This phase does not change runtime protection behavior.

## Why This Phase Exists

Phase 3.45 proved that DNS route capture works, but it also stopped internet access because captured DNS packets were not forwarded.

Therefore, the next safe design must include a DNS forwarding/proxy layer before DNS route capture is restored.

## Architecture Goal

Build a local DNS proxy that can:

1. Receive DNS query packets
2. Parse the hostname
3. Check the hostname against the local blocklist
4. Keep blocking disabled during diagnostics
5. Forward allowed DNS queries to upstream DNS
6. Return the upstream DNS response
7. Track diagnostic counters
8. Stop cleanly when VPN stops

## First Runtime Mode

dns_proxy_diagnostic_only

## Required Native Components

### 1. FocusShieldDnsProxy.kt

Responsible for:

- starting DNS proxy diagnostics
- stopping DNS proxy diagnostics
- receiving DNS query packets
- forwarding queries to upstream DNS
- returning responses
- tracking proxy counters

### 2. FocusShieldDnsProxyStatus.kt

Responsible for exposing:

- dnsProxyPrepared
- dnsProxyRunning
- dnsProxyQueriesReceived
- dnsProxyQueriesForwarded
- dnsProxyResponsesReturned
- dnsProxyErrors
- lastDnsProxyHost
- lastDnsProxyDecision
- lastDnsProxyError

### 3. FocusShieldDnsForwarder.kt

Responsible for:

- sending DNS requests to upstream DNS
- receiving upstream DNS responses
- returning response bytes safely

### 4. FocusShieldDnsProxyMode.kt

Responsible for named modes:

- disabled
- dns_proxy_diagnostic_only
- dns_proxy_dry_run
- dns_proxy_blocking_candidate

Only diagnostic mode is allowed at first.

## First Allowed Behavior

Allowed:

- Receive DNS queries
- Parse hostnames
- Forward DNS queries
- Return upstream DNS responses
- Count diagnostics
- Make dry-run decisions

Not allowed:

- Blocking domains
- Replacing DNS responses
- Dropping DNS packets
- Uploading DNS logs
- Saving full browsing history
- Running hidden enforcement

## First Diagnostic Counters

The next implementation should expose:

- dnsProxyPrepared
- dnsProxyRunning
- dnsProxyQueriesReceived
- dnsProxyQueriesForwarded
- dnsProxyResponsesReturned
- dnsProxyErrors
- lastDnsProxyHost
- lastDnsProxyDecision
- lastDnsProxyError

## Required Safety State

The following must remain true:

- blockingEnabled: false
- liveTrafficReadEnabled only runs inside live_observation_only
- DNS route capture remains disabled until forwarding exists
- Stop must return VPN service to inactive
- Internet must keep working during diagnostic mode

## First Success Criteria

The DNS proxy diagnostic system is successful only if:

1. VPN starts
2. DNS proxy starts
3. Internet still works
4. DNS queries are received
5. DNS queries are forwarded
6. DNS responses are returned
7. Blocking remains disabled
8. Stop works safely

## Failure Criteria

The test fails if:

- Internet stops working
- Blocking becomes enabled
- DNS responses are not returned
- VPN cannot stop
- App crashes
- Phone network becomes unstable

## Next Phase

Phase 3.49 — DNS Proxy Diagnostic Skeleton Without Routing
