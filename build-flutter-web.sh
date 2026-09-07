#!/bin/bash
set -euo pipefail

echo "=== Building Flutter Web ==="

export PATH="$HOME/flutter-sdk/bin:$PATH"

if [ ! -x "$HOME/flutter-sdk/bin/flutter" ]; then
  echo "ERROR: Flutter SDK not found. Run install-flutter.sh first."
  exit 1
fi

echo "Step 1: flutter pub get"
flutter pub get

echo "Step 2: flutter clean (optional but recommended)"
flutter clean || true
flutter pub get

echo "Step 3: flutter build web --release"
flutter build web --release --web-renderer canvaskit

echo "=== Flutter Web build complete ==="
echo "Output directory: $(pwd)/build/web"
ls -la build/web/
