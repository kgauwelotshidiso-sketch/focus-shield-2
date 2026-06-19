#!/usr/bin/env bash
set -u

ROOT_DIR="/workspaces/focus-shield-2"
APP_DIR="$ROOT_DIR/focus_shield_android"

cd "$APP_DIR" || exit 1

echo "========================================"
echo "Focus Shield — Debug APK Build"
echo "========================================"
echo ""

flutter pub get
flutter analyze
flutter test

echo ""
echo "Attempting debug APK build..."
flutter build apk --debug

echo ""
echo "If successful, APK path:"
echo "$APP_DIR/build/app/outputs/flutter-apk/app-debug.apk"
echo "========================================"
