#!/usr/bin/env bash
# Load GEMINI_API_KEY from .env and pass it to flutter as --dart-define.
# Usage:
#   tool/run.sh <device-id>    # flutter run on device
#   tool/run.sh --build        # flutter build appbundle --release
#   tool/run.sh --apk          # flutter build apk --release
set -euo pipefail

if [[ ! -f ".env" ]]; then
  echo "Error: .env not found. Copy .env.example to .env and set GEMINI_API_KEY." >&2
  exit 1
fi

KEY="$(grep -E '^GEMINI_API_KEY=' .env | head -n1 | cut -d'=' -f2- | tr -d '"' | tr -d ' ')"

if [[ -z "$KEY" ]]; then
  echo "Error: GEMINI_API_KEY is empty in .env" >&2
  exit 1
fi

case "${1:-}" in
  --build) flutter build appbundle --release --dart-define=GEMINI_API_KEY="$KEY" ;;
  --apk)   flutter build apk --release --dart-define=GEMINI_API_KEY="$KEY" ;;
  *)       flutter run -d "${1:-}" --dart-define=GEMINI_API_KEY="$KEY" ;;
esac
