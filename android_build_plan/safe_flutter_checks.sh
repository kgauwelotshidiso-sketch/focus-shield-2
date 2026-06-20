#!/usr/bin/env bash
set -e

cd /workspaces/focus-shield-2/focus_shield_android

echo "Running Focus Shield safe checks..."
flutter pub get
flutter analyze
flutter test

echo ""
echo "Safe checks passed."
