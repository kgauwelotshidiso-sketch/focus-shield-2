#!/usr/bin/env bash

echo "=== Focus Shield Gradle Diagnostics ==="
echo ""

cd /workspaces/focus-shield-2

source android_build_plan/android_sdk_environment_variables.sh 2>/dev/null || true

echo "1. Memory"
free -h || true
echo ""

echo "2. Disk"
df -h || true
echo ""

echo "3. Java"
java -version || true
echo ""

echo "4. Flutter"
flutter --version || true
echo ""

echo "5. Android SDK variables"
echo "ANDROID_HOME=${ANDROID_HOME:-not set}"
echo "ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-not set}"
echo ""

echo "6. Gradle files"
cd /workspaces/focus-shield-2/focus_shield_android/android
pwd
ls -la gradlew || true
cat gradle.properties || true
echo ""

echo "7. Gradle daemon logs"
find /home/vscode/.gradle/daemon -name "*.out.log" -type f -print 2>/dev/null | tail -5 || true
echo ""

echo "8. Latest daemon log tail"
latest_log=$(find /home/vscode/.gradle/daemon -name "*.out.log" -type f -print 2>/dev/null | tail -1)
if [ -n "$latest_log" ]; then
  echo "$latest_log"
  tail -120 "$latest_log"
else
  echo "No daemon log found."
fi
