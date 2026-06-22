#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT="RiggedShoe.xcodeproj"
SCHEME="RiggedShoe"
ARCHIVE_DIR="${PWD}/ReleaseExports/Archives"
ARCHIVE_PATH="${ARCHIVE_DIR}/RiggedShoe.xcarchive"

mkdir -p "${ARCHIVE_DIR}"

echo "Archiving Rigged Shoe for App Store/TestFlight"
echo "Archive: ${ARCHIVE_PATH}"
echo

xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "${ARCHIVE_PATH}" \
  archive

echo
echo "Archive complete."
echo "Open Xcode Organizer to validate and distribute, or export with an ExportOptions.plist."
