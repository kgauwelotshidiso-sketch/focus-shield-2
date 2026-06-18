#!/usr/bin/env bash
set -e

cd /workspaces/focus-shield-2

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed. Real Flutter project creation skipped."
  echo "Use this script later when Flutter SDK is available."
  exit 1
fi

if [ -d "focus_shield_flutter" ]; then
  echo "focus_shield_flutter already exists. Skipping flutter create."
else
  flutter create focus_shield_flutter
fi

echo "Flutter project created or already exists."
echo "Next step: copy starter files from flutter_starter/lib into focus_shield_flutter/lib."
