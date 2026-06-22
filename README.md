# Rigged Shoe

Canonical local project for the baccarat simulator / rigged shoe app.

## Project

- Xcode project: `RiggedShoe.xcodeproj`
- Scheme: `RiggedShoe`
- Current branch: `main`
- Bundle ID: `com.danielwilliams.RiggedShoe`
- Apple Team ID: `ZESFN7D6AD`
- Version: `1.1`
- Build: `202606201232`

## Windows Development Handoff

Use `README_DEV.md` for the Windows-to-Mac workflow. Short version:

1. Edit code on Windows.
2. Commit and push changes to a private Git repo.
3. Pull the same repo on a Mac with Xcode installed.
4. Run the scripts in `Scripts/` to build, archive, and upload.

Native iOS Simulator testing, signing, archiving, and TestFlight upload still require macOS/Xcode.

## Local Verification

```sh
xcodebuild -project RiggedShoe.xcodeproj -scheme RiggedShoe -configuration Debug -destination generic/platform=iOS\ Simulator build
xcodebuild -project RiggedShoe.xcodeproj -scheme RiggedShoe -configuration Release -destination generic/platform=iOS\ Simulator build
```

## Xcode Cloud Starting Workflow

- Trigger: push to `main`
- Action: Build and Archive
- Tests: none configured yet
- Distribution: TestFlight Internal Testing after App Store Connect app record and signing are configured

## GitHub Remote

After creating the private GitHub repo:

```sh
git remote add origin https://github.com/YOUR_USERNAME/rigged-shoe.git
git push -u origin main
```
