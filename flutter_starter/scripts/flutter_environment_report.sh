#!/usr/bin/env bash
set -e

echo "Focus Shield Flutter Environment Report"
echo "--------------------------------------"

echo ""
echo "1. Current folder:"
pwd

echo ""
echo "2. Git status:"
git status --short || true

echo ""
echo "3. Flutter:"
if command -v flutter >/dev/null 2>&1; then
  flutter --version
else
  echo "Flutter: NOT INSTALLED"
fi

echo ""
echo "4. Dart:"
if command -v dart >/dev/null 2>&1; then
  dart --version
else
  echo "Dart: NOT INSTALLED or not on PATH"
fi

echo ""
echo "5. Java:"
if command -v java >/dev/null 2>&1; then
  java -version
else
  echo "Java: NOT INSTALLED or not on PATH"
fi

echo ""
echo "6. Android SDK:"
if [ -n "${ANDROID_HOME:-}" ]; then
  echo "ANDROID_HOME=$ANDROID_HOME"
else
  echo "ANDROID_HOME: NOT SET"
fi

if [ -n "${ANDROID_SDK_ROOT:-}" ]; then
  echo "ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
else
  echo "ANDROID_SDK_ROOT: NOT SET"
fi

echo ""
echo "7. Disk space:"
df -h . || true

echo ""
echo "Result:"
if command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is available. You may proceed to Phase 4D after confirming Android tooling."
else
  echo "Flutter SDK is not installed. Do not run flutter create yet."
fi
