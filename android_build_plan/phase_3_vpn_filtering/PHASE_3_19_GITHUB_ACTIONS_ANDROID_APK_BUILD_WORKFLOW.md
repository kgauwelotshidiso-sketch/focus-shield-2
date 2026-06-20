# Phase 3.19 — GitHub Actions Android APK Build Workflow Preparation

## Status

Complete.

## Added

- .github/workflows/android-debug-apk.yml

## Purpose

Codespaces is currently unstable for APK builds because the Gradle daemon keeps disappearing.

This workflow moves APK building to GitHub Actions.

## Workflow Checks

The workflow runs:

- flutter pub get
- flutter analyze
- flutter test
- flutter build apk --debug

## APK Artifact

If the workflow passes, it uploads:

focus_shield_android/build/app/outputs/flutter-apk/app-debug.apk

Artifact name:

focus-shield-debug-apk

## Safety State

The app remains safe:

- liveTrafficReadEnabled: false
- blockingEnabled: false
- liveObservationSafetyGate: locked_until_android_sdk_testing

## Next Phase

Phase 3.20 — Run GitHub Actions APK Build
