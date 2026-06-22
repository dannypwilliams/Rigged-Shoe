#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

ARCHIVE_PATH="${1:-${PWD}/ReleaseExports/Archives/RiggedShoe.xcarchive}"
EXPORT_PATH="${2:-${PWD}/ReleaseExports/AppStore}"
EXPORT_OPTIONS="${3:-${PWD}/ReleaseExports/ExportOptionsLocalAppStore.plist}"

if [ ! -d "${ARCHIVE_PATH}" ]; then
  echo "ERROR: Archive not found: ${ARCHIVE_PATH}"
  echo "Run Scripts/mac_archive_appstore.sh first."
  exit 1
fi

if [ ! -f "${EXPORT_OPTIONS}" ]; then
  echo "ERROR: Export options plist not found: ${EXPORT_OPTIONS}"
  exit 1
fi

mkdir -p "${EXPORT_PATH}"

echo "Exporting App Store IPA"
echo "Archive: ${ARCHIVE_PATH}"
echo "Export: ${EXPORT_PATH}"
echo "Options: ${EXPORT_OPTIONS}"
echo

xcodebuild \
  -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${EXPORT_PATH}" \
  -exportOptionsPlist "${EXPORT_OPTIONS}"

echo
echo "Export complete."
