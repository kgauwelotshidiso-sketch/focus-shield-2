#!/usr/bin/env bash
set -e

source /workspaces/focus-shield-2/android_build_plan/android_sdk_environment_variables.sh

echo "=== Verify Android SDK Install ==="
echo ""

echo "ANDROID_HOME=$ANDROID_HOME"
echo "ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
echo ""

echo "sdkmanager:"
command -v sdkmanager
sdkmanager --version || true
echo ""

echo "adb:"
command -v adb
adb version || true
echo ""

echo "Installed SDK packages:"
sdkmanager --list_installed | head -80
echo ""

cd /workspaces/focus-shield-2/focus_shield_android

echo "Flutter doctor:"
flutter doctor -v || true
echo ""

echo "Safe checks:"
flutter analyze
flutter test
