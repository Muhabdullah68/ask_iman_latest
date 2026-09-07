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
wget -q https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz -O /tmp/flutter.tar.xz

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
