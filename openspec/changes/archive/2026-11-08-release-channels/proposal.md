# Proposal

## Why

Releases are files on GitHub and nothing else. The release pull request needs an admin to merge it, because its
checks are held when `GITHUB_TOKEN` opens it. The macOS zip is ad-hoc signed, so Gatekeeper fights every
download, and iOS has no installable build at all. Google Play, F-Droid and Flathub are on the roadmap with
nothing in the repository to start from. The owner should only have to create the accounts and paste secrets.

## What Changes

- Release pull requests opened with the release GitHub App run their checks and go through the merge queue like
  any other pull request. `release-files-check` recognises a release commit that other commits sit on top of.
- iOS: with the signing secrets, the release builds an App Store signed IPA with fastlane and uploads it to
  TestFlight. Without them it builds unsigned, as today. `ios/ExportOptions.plist` is committed.
- macOS: with a Developer ID certificate and the App Store Connect key, the app is re-signed with the hardened
  runtime, notarised and stapled before it is zipped. Without them it stays ad-hoc signed.
- Google Play: store text in English, Bulgarian, French and German under `fastlane/metadata/android/`, a
  changelog made from release-please's `CHANGELOG.md`, and an internal-track upload after publishing when
  `PLAY_SERVICE_ACCOUNT_JSON` exists.
- F-Droid: the same metadata tree, an fdroiddata recipe and tix srclib under `fdroid/`, APKs without AGP's
  encrypted dependency blob, and a CI check that no APK carries known non-free code.
- Flathub: AppStream metainfo with releases generated from `CHANGELOG.md`, installed with the Linux bundle, and a
  Flatpak manifest under `flatpak/` that builds the app and libtix from source.
- Every channel is skipped with a notice while its secrets are absent, so CI and releases stay green.

## Impact

- New capability: `release-channels`.
- New files: `Gemfile`, `Gemfile.lock`, `fastlane/`, `fdroid/`, `flatpak/`, `ios/ExportOptions.plist`,
  `linux/packaging/red.tix.tix_mobile.metainfo.xml`, `scripts/{release-secrets,macos-notarize,store-changelog,
  fdroid-check}.sh`, `scripts/metainfo-releases.py`, `.github/actions/fastlane`, `LICENSES/CC0-1.0.txt`.
- New dependency, release CI only: fastlane (Ruby), tracked by Dependabot. Nothing in the app changes.
- The release workflow gains a `play` job, and the iOS and macOS jobs gain signed paths.
