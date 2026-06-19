# Phase 3 — Native Android VPN/DNS Filtering

## Current Status

Focus Shield currently has:

- Flutter Android app shell
- SQLite saved blocklist
- App-level scanner
- Attempt history
- Recovery system
- Coach intelligence
- Goals and affirmations
- Daily reset and streak system

## What Phase 3 Adds

Phase 3 will add real Android-level filtering using a local VPN/DNS service.

## Why VPN/DNS Is Needed

The Flutter app can scan domains inside the app, but it cannot block the whole phone by itself.

To block apps and browsers system-wide, Android needs a native VPN service.

## Phase 3 Build Order

### 3.1 Native Android VPN Service Skeleton

Create Android service files:

- FocusShieldVpnService.kt
- AndroidManifest VPN permission
- VPN foreground service setup

### 3.2 Flutter to Android MethodChannel

Create bridge commands:

- startProtection()
- stopProtection()
- protectionStatus()
- reloadBlocklist()

### 3.3 Local DNS Filter Logic

The native layer must:

- read domains
- compare against saved blocklist
- block matching domains
- allow safe domains

### 3.4 SQLite Bridge

The native side must access the same saved blocklist used by Flutter.

### 3.5 Protection Status UI

Flutter Settings screen must show:

- VPN service active/inactive
- blocklist loaded
- last reload time
- native filtering status

## Safety Rule

Do not add random public blocklists yet.

Start only with safe test domains:

- blocked-example.com
- temptation-test.net
- focus-risk.org
- custom-risk.test

## Next Step

Phase 3.1 — Native Android VPN Service Skeleton
