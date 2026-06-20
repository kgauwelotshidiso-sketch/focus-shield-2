# Phase 3.20 — GitHub Actions Heap Fix

## Status

Complete.

## Problem Found

GitHub Actions APK build failed with:

Java heap space

## Fix Added

The Android Debug APK workflow now configures stronger Gradle memory settings for CI:

- GRADLE_OPTS
- JAVA_TOOL_OPTIONS
- org.gradle.jvmargs
- kotlin compiler in-process mode
- Gradle daemon disabled
- Gradle parallel disabled

## Safety State

The app remains safe:

- liveTrafficReadEnabled: false
- blockingEnabled: false
- liveObservationSafetyGate: locked_until_android_sdk_testing

## Next Phase

Phase 3.21 — Re-run GitHub Actions APK Build
