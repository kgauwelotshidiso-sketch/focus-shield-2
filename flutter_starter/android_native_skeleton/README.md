# Focus Shield Native Android VPN Skeleton

This folder contains starter Kotlin skeleton files for the future native Android protection layer.

It is not active VPN filtering code.

## Files

- FocusShieldVpnService.kt
- DnsPacketParser.kt
- DomainDecisionBridge.kt
- VpnPermissionActivity.kt
- VpnStatusReceiver.kt
- AndroidManifest_notes.xml

## Rule

Native Android should not write directly to SQLite.

Correct future flow:

Android VPN Service
→ MethodChannel / DomainDecisionBridge
→ Dart ProtectionEngine
→ Repositories
→ SQLite
→ Intervention screen
