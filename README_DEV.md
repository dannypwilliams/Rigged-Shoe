# Rigged Shoe Development Handoff

This project can be edited comfortably on Windows, but it still needs a Mac for native iOS build, Simulator testing, signing, archiving, and TestFlight upload.

## Recommended Setup

### Windows PC

- Git
- VS Code, Cursor, or Codex
- GitHub Desktop or command-line Git
- Optional Swift syntax extension

Use Windows for:

- SwiftUI source edits
- model/gameplay changes
- documentation
- simulation script work
- Git commits and reviews

### Mac Build Machine

- Xcode installed from Apple
- Apple Developer account signed into Xcode
- App Store Connect access for Rigged Shoe
- Existing signing team: `ZESFN7D6AD`
- Bundle identifier: `com.danielwilliams.RiggedShoe`

Use the Mac for:

- Xcode project opening
- iOS Simulator playtesting
- archive creation
- App Store Connect/TestFlight upload

## Daily Workflow

1. Pull latest code on Windows.
2. Make focused changes.
3. Commit and push to the private repo.
4. On the Mac, pull latest code.
5. Run `Scripts/mac_build_simulator.sh`.
6. Open Xcode or Simulator for visual verification when UI changes are involved.
7. For TestFlight, run `Scripts/mac_archive_appstore.sh`, then upload from Xcode Organizer or the transporter step.

## Git Rules

Track:

- `RiggedShoe/`
- `RiggedShoe.xcodeproj/`
- `Docs/`
- `Tools/`
- `Scripts/`
- `ReleaseAssets/`
- `README.md`
- `README_DEV.md`

Do not track:

- `DerivedData/`
- `BuildProducts/`
- `BuildLogs/`
- `.ipa` files
- `.xcarchive` files
- local signing secrets
- App Store Connect `.p8` keys

The `.gitignore` in this project is set up for that split.

## App Store Connect API Key

For automated uploads later, create an App Store Connect API key and store it outside Git.

Needed values:

- Issuer ID
- Key ID
- private key file, usually `AuthKey_XXXXXXXXXX.p8`

Never commit the `.p8` file. Keep it in a private local path or CI secret store.

## Useful Mac Commands

Check the local toolchain:

```sh
Scripts/mac_bootstrap_check.sh
```

Build for iOS Simulator:

```sh
Scripts/mac_build_simulator.sh
```

Archive for App Store distribution:

```sh
Scripts/mac_archive_appstore.sh
```

## If Xcode Opens An Older Build

Open this project directly:

```sh
open RiggedShoe.xcodeproj
```

The current local pointer on Daniel's Mac is:

```text
/Users/danielwilliams/Documents/RiggedShoe_Current
```

That path is a symlink to the newest full project folder.

## Before TestFlight

- Increment build number in Xcode.
- Run a Release archive.
- Confirm signing uses team `ZESFN7D6AD`.
- Confirm bundle ID is `com.danielwilliams.RiggedShoe`.
- Upload archive to App Store Connect.
- Add the build to the TestFlight testing group.
