# Focus Shield Phase 4C Flutter SDK Setup Plan

The previous environment check confirmed that Flutter is not installed in the current Codespace.

This is not a Focus Shield failure.
It only means this Codespace is currently a web-prototype environment, not a Flutter/Android build environment.

## Current status

- Web prototype: safe
- Git working tree: clean
- Flutter SDK: not installed
- Real Flutter project: not created yet
- Android build: not ready yet

## Correct options

### Option 1: Add Flutter to this Codespace

Use this only if the Codespace has enough storage and Android dependencies can be installed safely.

Pros:
- Keeps everything in one environment
- Simple repo continuity

Risks:
- Flutter and Android tools are large
- Codespace may become slower
- Installation may fail on limited storage

### Option 2: Use a Flutter-ready devcontainer

Create a dedicated Flutter-ready Codespace/devcontainer.

Pros:
- Cleaner setup
- Better long-term Android build environment
- Less risk to current web prototype

Risks:
- Requires devcontainer setup
- Codespace rebuild can take time

### Option 3: Keep this Codespace for planning, build Flutter elsewhere later

Continue using this Codespace for the web app and architecture, then build the real Flutter app later in a Flutter-ready environment.

Pros:
- Safest for current progress
- No risk to the working prototype
- Best for mobile-only workflow until build tools are ready

Risks:
- Real APK build waits until Flutter environment exists

## Recommended path

Recommended for Focus Shield:

1. Keep current Codespace safe.
2. Do not run `flutter create` yet.
3. Add Flutter-ready devcontainer template.
4. Use environment report script to check readiness.
5. Create real Flutter project only after Flutter SDK is available.

## Rule

Flutter missing should be treated as setup status, not system failure.
The app Health Check should not pretend Flutter exists.
