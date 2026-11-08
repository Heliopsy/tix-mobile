# Tasks

## 1. Pipeline

- [x] 1.1 `scripts/release-secrets.sh` gate, used by every store channel
- [x] 1.2 release-please comments and docs for the release GitHub App; release-files check for queued release commits
- [x] 1.3 Gemfile, Gemfile.lock, `.github/actions/fastlane`, Dependabot for bundler

## 2. Apple

- [x] 2.1 `ios/ExportOptions.plist`, fastlane `ios ipa` and `ios testflight` lanes, signed path in the iOS job
- [x] 2.2 `scripts/macos-notarize.sh` and the notarised path in the macOS job

## 3. Stores

- [x] 3.1 Store text in en-US, bg, fr-FR and de-DE, icon, `scripts/store-changelog.sh`
- [x] 3.2 fastlane `android internal` lane and the `play` job
- [x] 3.3 `dependenciesInfo` off for APKs, `scripts/fdroid-check.sh` in CI and release, F-Droid recipe and srclib
- [x] 3.4 Metainfo, `scripts/metainfo-releases.py`, CMake install, Flatpak manifest and build script

## 4. Docs

- [x] 4.1 `docs/releasing.md` checklist per channel, README and ROADMAP
