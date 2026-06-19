# Phase 3.14 — Android SDK Environment Setup Plan

## Status

Complete.

## Purpose

Codespaces can currently run:

- flutter analyze
- flutter test

But APK build is blocked because the Android SDK is not fully configured.

## Current Stable Checks

These are passing:

- flutter analyze
- flutter test
- 24 Flutter/Dart tests

## Problem

APK build needs:

- Android SDK command-line tools
- Android platform SDK
- Android build-tools
- ANDROID_HOME
- ANDROID_SDK_ROOT
- accepted Android SDK licenses

## Target SDK Location

Use:

/workspaces/android-sdk

## Required Environment Variables

ANDROID_HOME=/workspaces/android-sdk
ANDROID_SDK_ROOT=/workspaces/android-sdk
PATH includes:
/workspaces/android-sdk/cmdline-tools/latest/bin
/workspaces/android-sdk/platform-tools

## Safe Setup Order

1. Prepare SDK folder
2. Install Android command-line tools
3. Install platform-tools
4. Install Android platform SDK
5. Install Android build-tools
6. Accept licenses
7. Run flutter doctor
8. Run flutter analyze
9. Run flutter test
10. Only then attempt debug APK build

## Important Safety Rule

Even after APK build works, do not enable:

- liveTrafficReadEnabled
- blockingEnabled

Focus Shield must remain in safe dry-run mode until real-device testing confirms the VPN shell is stable.

## Next Phase

Phase 3.15 — Android SDK Setup Script
