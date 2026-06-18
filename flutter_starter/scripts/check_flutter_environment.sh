#!/usr/bin/env bash
set -e

echo "Checking Flutter environment..."

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed in this environment."
  echo "Install Flutter or use a Codespace/devcontainer that includes Flutter before creating the real project."
  exit 1
fi

flutter --version

echo "Flutter is available."
