# Focus Shield Real Device Testing Checklist

## Before Installing APK

Confirm:

- flutter analyze passes
- flutter test passes
- Android SDK is configured
- Debug APK builds successfully

## First Device Test

Install the debug APK only after build succeeds.

## Test Order

### 1. Open App

Expected:

- App opens normally
- Home screen loads
- No crash

### 2. Open Settings

Expected:

- Native Protection card appears
- Safe mode shows On
- Live traffic reading shows Disabled
- Blocking shows Disabled

### 3. Press Start Protection

Expected:

- Android may ask for VPN permission
- App must not crash
- Protection status should remain safe

### 4. Press Prepare Observation

Expected:

- Observation request may show as prepared
- Safety gate remains locked
- Live traffic reading remains disabled
- Blocking remains disabled

### 5. Press Disable Observation

Expected:

- Observation request clears
- Safe dry-run preparation remains available

### 6. Press Stop

Expected:

- VPN shell stops
- App must not crash

## Do Not Test Yet

Do not test real blocking yet.

Do not enable live packet reading yet.

Do not enable blocking yet.

## Pass Condition

Phase passes when:

- APK installs
- app opens
- Settings status works
- VPN permission flow does not crash
- all safety flags remain disabled
