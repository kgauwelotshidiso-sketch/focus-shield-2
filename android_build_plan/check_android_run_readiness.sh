#!/usr/bin/env bash
set -u

ROOT_DIR="/workspaces/focus-shield-2"
APP_DIR="$ROOT_DIR/focus_shield_android"

echo "========================================"
echo "Focus Shield — Android Run Readiness"
echo "========================================"
echo ""

if [ ! -d "$APP_DIR" ]; then
  echo "❌ Flutter project not found at: $APP_DIR"
  exit 1
fi

cd "$APP_DIR" || exit 1

echo "Project:"
pwd
echo ""

flutter --version || true
flutter doctor -v || true
flutter pub get
flutter analyze
flutter test
flutter devices || true

echo ""
echo "If analyze and test pass, the app code is healthy."
echo "If flutter devices shows an Android device/emulator, run:"
echo "flutter run"
