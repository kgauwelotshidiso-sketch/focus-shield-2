#!/usr/bin/env bash
set -e

echo "=== Focus Shield Android Build Environment Check ==="
echo ""

cd /workspaces/focus-shield-2/focus_shield_android

echo "1. Flutter version"
flutter --version
echo ""

echo "2. Dart version"
dart --version
echo ""

echo "3. Android project files"
test -d android && echo "Android folder found"
test -f android/app/src/main/AndroidManifest.xml && echo "AndroidManifest.xml found"
test -f android/gradlew && echo "Gradle wrapper found"
echo ""

echo "4. Pub get"
flutter pub get
echo ""

echo "5. Analyze"
flutter analyze
echo ""

echo "6. Tests"
flutter test
echo ""

echo "7. APK build attempt"
echo "Starting debug APK build..."
flutter build apk --debug

echo ""
echo "Android debug APK build completed."
echo "APK location:"
echo "focus_shield_android/build/app/outputs/flutter-apk/app-debug.apk"
