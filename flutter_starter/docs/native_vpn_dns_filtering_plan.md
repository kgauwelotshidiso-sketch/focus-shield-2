# Focus Shield Phase 3I Native Android VPN / DNS Filtering Preparation Plan

This phase prepares the native Android protection architecture.

It does not implement full VPN filtering yet.

## Goal

Prepare the real Android protection layer that will eventually support:

1. Android VPN Service
2. DNS/domain detection
3. MethodChannel bridge
4. ProtectionEngine decisions
5. Block or allow response
6. Blocked attempt logging
7. Intervention trigger
8. Battery and performance safety rules

## Native components

### FocusShieldVpnService

Future Android service responsible for running the local VPN interface.

### DnsPacketParser

Future native helper that extracts domain-level metadata from DNS requests.

### DomainDecisionBridge

Bridge between native Android and Flutter/Dart ProtectionEngine.

### VpnPermissionActivity

Future screen or flow that asks Android for VPN permission.

### VpnStatusReceiver

Tracks whether protection is running, stopped, or needs attention.

## Correct flow

Flutter protection toggle
→ Android VPN permission request
→ FocusShieldVpnService starts
→ DNS/domain request is detected
→ domain is sent to ProtectionEngine
→ ProtectionEngine checks SQLite-backed repositories
→ ALLOW or BLOCK decision
→ blocked attempts are logged
→ intervention screen is shown when needed

## Safety limits

1. Do not inspect private message content.
2. Do not store full packets.
3. Do not log exact domains when privacy mode is stats-only.
4. Do not start VPN before database initialization is complete.
5. Do not allow VPN layer to write directly to SQLite.
6. Do not bypass ProtectionEngine.
7. Do not hide protection status from the user.
8. Do not allow instant disable if delayed disable is active.

## Battery and performance rules

1. Keep analysis domain-level and lightweight.
2. Cache recent ALLOW decisions briefly.
3. Cache blocklist in memory after database initialization.
4. Avoid heavy work inside native packet loop.
5. Push logging through a controlled repository flow.

## Future build order

1. Build Flutter settings screen for protection status.
2. Add VPN permission request bridge.
3. Add native FocusShieldVpnService skeleton.
4. Add DNS/domain metadata extraction prototype.
5. Connect native domain request to ProtectionEngine.
6. Connect BLOCK result to attempt logging.
7. Connect BLOCK result to intervention screen.
8. Add battery and reliability testing.
