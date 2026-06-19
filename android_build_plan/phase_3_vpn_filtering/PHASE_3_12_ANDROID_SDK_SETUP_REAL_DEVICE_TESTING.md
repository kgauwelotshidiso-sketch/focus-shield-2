# Phase 3.12 — Android SDK Setup Plan for Real Device Testing

## Status

Complete.

## Why This Phase Exists

Codespaces currently passes:

- flutter analyze
- flutter test

But APK build is blocked because the Android SDK is not configured.

The app code is not the problem. The build environment is the problem.

## Current Build Status

- Flutter code checks: passing
- Flutter tests: passing
- Android SDK: missing or not configured
- APK build: blocked by environment

## Goal

Prepare a safe route for building and testing Focus Shield on a real Android device.

## Testing Route

### Step 1 — Confirm SDK Status

Run:

bash android_build_plan/check_android_sdk_status.sh

This checks:

- ANDROID_HOME
- ANDROID_SDK_ROOT
- sdkmanager
- adb
- gradle wrapper
- flutter doctor
- AndroidManifest
- APK output folder

### Step 2 — Do Not Enable Live Traffic Yet

Even after APK build works, these must stay disabled:

- liveTrafficReadEnabled: false
- blockingEnabled: false

The app is still in safe dry-run preparation mode.

### Step 3 — Build Debug APK Later

Once Android SDK is installed/configured, run:

cd /workspaces/focus-shield-2/focus_shield_android
flutter build apk --debug

Expected APK path:

build/app/outputs/flutter-apk/app-debug.apk

### Step 4 — Real Device Test Order

Test only in this order:

1. App opens
2. Settings opens
3. Native Protection card appears
4. Start Protection asks for Android VPN permission
5. Permission flow does not crash
6. Status still says safe mode
7. Live traffic reading remains disabled
8. Blocking remains disabled

## Safety Rules

Do not enable live packet reading until:

- APK builds successfully
- Native parser tests can run
- VPN permission flow is confirmed on a real device
- Start/stop protection works without crashing
- Dry-run status behaves correctly

## Next Phase

Phase 3.13 — Android SDK Diagnostic Run
