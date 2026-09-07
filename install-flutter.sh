#!/bin/bash
set -euo pipefail

echo "=== Installing Flutter SDK ==="

FLUTTER_VERSION="3.38.4"
FLUTTER_CHANNEL="stable"
INSTALL_DIR="$HOME/flutter-sdk"

if [ -d "$INSTALL_DIR" ] && [ -x "$INSTALL_DIR/bin/flutter" ]; then
  echo "Flutter SDK already installed at $INSTALL_DIR"
  export PATH="$INSTALL_DIR/bin:$PATH"
  flutter --version
  exit 0
fi

echo "Downloading Flutter ${FLUTTER_CHANNEL} v${FLUTTER_VERSION}..."
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz"
if command -v curl >/dev/null 2>&1; then
  curl -fL "$FLUTTER_URL" -o /tmp/flutter.tar.xz
elif command -v wget >/dev/null 2>&1; then
  wget -q "$FLUTTER_URL" -O /tmp/flutter.tar.xz
else
  echo "ERROR: Neither curl nor wget is available. Cannot download Flutter SDK."
  exit 1
fi

echo "Extracting Flutter SDK..."
mkdir -p "$INSTALL_DIR"
tar xf /tmp/flutter.tar.xz -C "$INSTALL_DIR" --strip-components=1

export PATH="$INSTALL_DIR/bin:$PATH"

echo "Running flutter config..."
flutter config --no-analytics
flutter config --enable-web

echo "Verifying Flutter installation..."
flutter --version
flutter doctor --verbose || true

echo "=== Flutter SDK installed successfully ==="
