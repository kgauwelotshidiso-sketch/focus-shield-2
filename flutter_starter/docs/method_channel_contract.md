# Focus Shield Phase 3K MethodChannel Contract Expansion

This phase defines the Flutter ↔ Android native communication contract.

## Channels

### MethodChannel

`focus_shield/vpn`

Used for commands from Flutter to Android.

### EventChannel

`focus_shield/vpn_events`

Used for events from Android to Flutter.

## Flutter → Android methods

1. `requestVpnPermission`
2. `startVpn`
3. `stopVpn`
4. `isVpnRunning`
5. `getVpnStatus`

## Android → Flutter events

1. `onBlockedDomain`
2. `onVpnStatusChanged`
3. `onVpnError`

## Blocked domain payload

Fields:

- eventType
- domain
- category
- reason
- confidence
- timestamp

## VPN status payload

Fields:

- eventType
- status
- message
- timestamp

Status values:

- stopped
- starting
- running
- stopping
- error

## Error payload

Fields:

- eventType
- errorCode
- message
- timestamp

Error codes:

- permission_denied
- service_start_failed
- engine_unavailable
- database_unavailable

## Safety rules

1. Native Android must not write directly to SQLite.
2. Native Android sends events to Flutter.
3. Flutter ProtectionEngine decides block/allow.
4. Privacy mode must be applied before attempt logging.
5. Full packet contents must not be sent over the channel.
6. The MethodChannel contract must remain stable before real VPN code is added.
