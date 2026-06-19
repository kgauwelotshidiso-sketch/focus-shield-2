#!/usr/bin/env bash

echo "=== Focus Shield Android SDK Status Check ==="
echo ""

echo "Repository:"
pwd
echo ""

echo "1. Flutter"
if command -v flutter >/dev/null 2>&1; then
  flutter --version
else
  echo "flutter not found"
fi
echo ""

echo "2. Dart"
if command -v dart >/dev/null 2>&1; then
  dart --version
else
  echo "dart not found"
fi
echo ""

echo "3. Android environment variables"
echo "ANDROID_HOME=${ANDROID_HOME:-not set}"
echo "ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-not set}"
echo ""

echo "4. Android SDK tools"
if command -v sdkmanager >/dev/null 2>&1; then
  echo "sdkmanager found: $(command -v sdkmanager)"
else
  echo "sdkmanager not found"
fi

if command -v adb >/dev/null 2>&1; then
  echo "adb found: $(command -v adb)"
else
  echo "adb not found"
fi
echo ""

echo "5. Flutter project files"
cd /workspaces/focus-shield-2/focus_shield_android

test -f pubspec.yaml && echo "pubspec.yaml found" || echo "pubspec.yaml missing"
test -d android && echo "android folder found" || echo "android folder missing"
test -f android/app/src/main/AndroidManifest.xml && echo "AndroidManifest.xml found" || echo "AndroidManifest.xml missing"
test -f android/gradlew && echo "Gradle wrapper found" || echo "Gradle wrapper missing"
echo ""

echo "6. Flutter doctor"
flutter doctor -v || true
echo ""

echo "7. Safe app checks"
flutter analyze
flutter test
echo ""

echo "8. Build note"
echo "Do not run flutter build apk --debug unless Android SDK is configured."
echo "If Android SDK is configured, run:"
echo "cd /workspaces/focus-shield-2/focus_shield_android"
echo "flutter build apk --debug"
