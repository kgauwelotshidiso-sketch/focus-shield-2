#!/usr/bin/env bash
set -e

echo "Focus Shield Flutter Setup Decision Helper"
echo "-----------------------------------------"

if command -v flutter >/dev/null 2>&1; then
  echo "Decision: Flutter is already installed."
  echo "Next phase: Phase 4D Real Flutter Project Creation."
  exit 0
fi

echo "Decision: Flutter is not installed."
echo ""
echo "Recommended path:"
echo "1. Keep this Codespace safe."
echo "2. Do not run flutter create yet."
echo "3. Use the Flutter-ready devcontainer template later."
echo "4. Rebuild only after git status is clean."
echo ""
echo "Template location:"
echo "flutter_starter/templates/flutter_devcontainer/"
