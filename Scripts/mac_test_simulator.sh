#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT="RiggedShoe.xcodeproj"
SCHEME="RiggedShoe"
DERIVED_DATA="${DERIVED_DATA_PATH:-/tmp/RiggedShoeDerivedData}"
DESTINATION="${1:-platform=iOS Simulator,name=RiggedShoe-SE-Layout-Test}"

echo "Testing Rigged Shoe on iOS Simulator"
echo "Destination: ${DESTINATION}"
echo "DerivedData: ${DERIVED_DATA}"
echo

xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -destination "${DESTINATION}" \
  -derivedDataPath "${DERIVED_DATA}" \
  CODE_SIGNING_ALLOWED=NO \
  test

echo
echo "Simulator tests complete."
