# Focus Shield Phase 3J Native VPN Service Starter Skeleton

This phase creates non-active starter files for the future Android native VPN layer.

## Created skeleton files

1. FocusShieldVpnService.kt
2. DnsPacketParser.kt
3. DomainDecisionBridge.kt
4. VpnPermissionActivity.kt
5. VpnStatusReceiver.kt
6. AndroidManifest_notes.xml
7. native_vpn_service_skeleton_plan.dart

## Important

This is not live VPN filtering.

The skeleton is intentionally non-active so the project remains safe and stable.

## Future flow

Android VPN Service
→ DNS/domain metadata
→ DomainDecisionBridge
→ Flutter/Dart ProtectionEngine
→ Repository layer
→ SQLite
→ Intervention screen

## Safety rules

1. Do not inspect private message content.
2. Do not store full packets.
3. Do not write directly to SQLite from native layer.
4. Do not bypass ProtectionEngine.
5. Do not start VPN without user permission.
6. Do not hide protection status.
7. Respect delayed disable protection.
