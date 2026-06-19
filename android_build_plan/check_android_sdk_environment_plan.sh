#!/usr/bin/env bash

echo "=== Android SDK Environment Plan Check ==="
echo ""

echo "Expected SDK location:"
echo "/workspaces/android-sdk"
echo ""

echo "Expected environment variables:"
echo "ANDROID_HOME=/workspaces/android-sdk"
echo "ANDROID_SDK_ROOT=/workspaces/android-sdk"
echo ""

echo "Expected PATH additions:"
echo "/workspaces/android-sdk/cmdline-tools/latest/bin"
echo "/workspaces/android-sdk/platform-tools"
echo ""

echo "Current values:"
echo "ANDROID_HOME=${ANDROID_HOME:-not set}"
echo "ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-not set}"
echo ""

echo "Tool availability:"
command -v sdkmanager >/dev/null 2>&1 && echo "sdkmanager found" || echo "sdkmanager not found"
command -v adb >/dev/null 2>&1 && echo "adb found" || echo "adb not found"
command -v flutter >/dev/null 2>&1 && echo "flutter found" || echo "flutter not found"
command -v dart >/dev/null 2>&1 && echo "dart found" || echo "dart not found"
echo ""

echo "Safe code checks:"
cd /workspaces/focus-shield-2/focus_shield_android
flutter analyze
flutter test
