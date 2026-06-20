# Android Build Blocker Notes

## Current Blocker

APK build is blocked by Gradle daemon instability in Codespaces.

## Passing Checks

- flutter analyze
- flutter test

## Failing Check

- flutter build apk --debug
- ./gradlew assembleDebug

## Current Interpretation

The build environment is unstable or resource-limited.

## Do Not Enable Yet

Do not enable:

- live packet reading
- traffic blocking
- unlocked observation mode

## Safe Next Build Route

The safest next route is to prepare GitHub Actions to build the APK outside Codespaces.
