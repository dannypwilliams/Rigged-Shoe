#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT="RiggedShoe.xcodeproj"
SCHEME="RiggedShoe"
DERIVED_DATA="${DERIVED_DATA_PATH:-/tmp/RiggedShoeDerivedData}"
DESTINATION="${1:-generic/platform=iOS Simulator}"

echo "Building Rigged Shoe for iOS Simulator"
echo "Destination: ${DESTINATION}"
echo "DerivedData: ${DERIVED_DATA}"
echo

xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration Debug \
  -destination "${DESTINATION}" \
  -derivedDataPath "${DERIVED_DATA}" \
  CODE_SIGNING_ALLOWED=NO \
  build

echo
echo "Simulator build complete."
