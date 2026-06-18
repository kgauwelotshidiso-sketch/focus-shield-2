# Focus Shield Phase 4A Real Flutter Project Creation Plan

This phase prepares the transition from web prototype to real Flutter Android project.

## Goal

Create the correct plan for a real Flutter app without damaging the current Focus Shield web prototype.

## Important rule

The current web app remains the working prototype.

The future Flutter app should live separately in:

focus_shield_flutter/

## Correct project structure

focus-shield-2/
  app/
    current web prototype

  flutter_starter/
    starter templates and planning files

  focus_shield_flutter/
    future real Flutter project

## Flutter project creation command

When Flutter SDK is available:

flutter create focus_shield_flutter

Then copy starter files from:

flutter_starter/lib/

into:

focus_shield_flutter/lib/

## Required future Flutter packages

1. sqflite
2. path
3. path_provider
4. flutter_secure_storage
5. provider or riverpod
6. permission_handler

## Android native preparation

The native Kotlin skeleton from flutter_starter/android_native_skeleton should later be moved into the real Android project under:

focus_shield_flutter/android/app/src/main/kotlin/

## Safe build order

1. Check Flutter SDK availability
2. Create focus_shield_flutter project
3. Run default Flutter app
4. Copy starter lib files
5. Add dependencies
6. Add SQLite initialization
7. Add repositories
8. Add ProtectionEngine integration
9. Add UI screens
10. Add MethodChannel bridge
11. Add native Android skeleton
12. Only later add real VPN/DNS filtering

## Not ready if

- Flutter SDK is not installed
- Android build tools are missing
- Current web app has unsaved changes
- Git working tree is not clean
- Starter files are missing
