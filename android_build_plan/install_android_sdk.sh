#!/usr/bin/env bash
set -e

SDK_ROOT="/workspaces/android-sdk"
TOOLS_ZIP="/tmp/android-commandline-tools.zip"
TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-14742923_latest.zip"

echo "=== Focus Shield Android SDK Installer ==="
echo ""

echo "1. Preparing SDK folders..."
mkdir -p "$SDK_ROOT/cmdline-tools"
rm -rf "$SDK_ROOT/cmdline-tools/latest"
rm -f "$TOOLS_ZIP"

echo "2. Installing system dependencies if available..."
if command -v sudo >/dev/null 2>&1 && command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y unzip curl
else
  echo "sudo or apt-get not available. Skipping system dependency install."
fi

echo "3. Downloading Android command-line tools..."
if command -v curl >/dev/null 2>&1; then
  curl -L "$TOOLS_URL" -o "$TOOLS_ZIP"
elif command -v wget >/dev/null 2>&1; then
  wget "$TOOLS_URL" -O "$TOOLS_ZIP"
else
  echo "Neither curl nor wget found."
  exit 1
fi

echo "4. Extracting command-line tools..."
unzip -q "$TOOLS_ZIP" -d "$SDK_ROOT/cmdline-tools"
mv "$SDK_ROOT/cmdline-tools/cmdline-tools" "$SDK_ROOT/cmdline-tools/latest"

export ANDROID_HOME="$SDK_ROOT"
export ANDROID_SDK_ROOT="$SDK_ROOT"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

echo "5. Writing persistent environment file..."
cat > /workspaces/focus-shield-2/android_build_plan/android_sdk_environment_variables.sh <<EOF
#!/usr/bin/env bash
export ANDROID_HOME=/workspaces/android-sdk
export ANDROID_SDK_ROOT=/workspaces/android-sdk
export PATH="\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH"
echo "Android SDK environment loaded."
echo "ANDROID_HOME=\$ANDROID_HOME"
echo "ANDROID_SDK_ROOT=\$ANDROID_SDK_ROOT"
EOF

chmod +x /workspaces/focus-shield-2/android_build_plan/android_sdk_environment_variables.sh

echo "6. Accepting SDK licenses..."
yes | sdkmanager --licenses >/dev/null || true

echo "7. Installing required SDK packages..."
sdkmanager \
  "platform-tools" \
  "platforms;android-35" \
  "build-tools;35.0.0" \
  "cmdline-tools;latest"

echo "8. Verifying installed tools..."
sdkmanager --list_installed | head -80
echo ""

echo "9. Running Flutter doctor..."
flutter doctor -v || true
echo ""

echo "10. Running Focus Shield safe checks..."
cd /workspaces/focus-shield-2/focus_shield_android
flutter analyze
flutter test

echo ""
echo "Android SDK setup script completed."
echo ""
echo "To load the SDK variables in a new terminal, run:"
echo "source /workspaces/focus-shield-2/android_build_plan/android_sdk_environment_variables.sh"
