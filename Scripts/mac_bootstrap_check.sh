#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT="RiggedShoe.xcodeproj"
SCHEME="RiggedShoe"

echo "Rigged Shoe Mac bootstrap check"
echo "Project: ${PROJECT}"
echo "Scheme: ${SCHEME}"
echo

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "ERROR: xcodebuild was not found. Install Xcode and select it with xcode-select."
  exit 1
fi

xcodebuild -version
echo

echo "Available project schemes:"
xcodebuild -list -project "${PROJECT}"
echo

echo "Key build settings:"
xcodebuild -showBuildSettings -project "${PROJECT}" -scheme "${SCHEME}" -configuration Release 2>/dev/null \
  | grep -E "PRODUCT_BUNDLE_IDENTIFIER|DEVELOPMENT_TEAM|MARKETING_VERSION|CURRENT_PROJECT_VERSION|CODE_SIGN_STYLE" \
  | sed 's/^ *//'

echo
echo "Bootstrap check complete."
