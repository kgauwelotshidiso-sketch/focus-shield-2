#!/usr/bin/env bash
set -u

echo "========================================"
echo "Focus Shield — Flutter Environment Check"
echo "========================================"
echo ""

READY=1

check_cmd() {
  local name="$1"
  local cmd="$2"

  if command -v "$cmd" >/dev/null 2>&1; then
    echo "✅ $name found: $(command -v "$cmd")"
  else
    echo "❌ $name not found"
    READY=0
  fi
}

check_cmd "Flutter" "flutter"
check_cmd "Dart" "dart"
check_cmd "Git" "git"

echo ""

if command -v flutter >/dev/null 2>&1; then
  echo "Flutter version:"
  flutter --version || true
  echo ""
  echo "Flutter doctor:"
  flutter doctor || true
else
  echo "Flutter is not installed in this environment."
  echo "This Codespace can continue as the web MVP environment."
  echo "Use a Flutter-ready Codespace/devcontainer or install Flutter before creating the Android app."
fi

echo ""
echo "========================================"

if [ "$READY" -eq 1 ]; then
  echo "✅ Environment likely ready for Flutter project creation."
  echo "Next command later:"
  echo "flutter create focus_shield_android"
else
  echo "⚠️ Environment not ready for Flutter project creation yet."
  echo "Keep the web MVP as the demo/prototype until Flutter is available."
fi

echo "========================================"
