# Proposal

## Why

The desktop builds from the GitHub release have no update check at all. Someone who unpacked the Linux tarball or
the Windows zip runs that version until they notice a newer one by chance, and the app never tells them. Phones get
their updates from Play or F-Droid; the desktop tarball and zip have nothing.

## What Changes

- **Update check** on Linux, Windows and macOS: `releases/latest` of heliopsy/tix-mobile at start and every six
  hours, drafts and prereleases skipped, compared with the running version. A newer one shows as "Update
  available" in Settings, in About and in the tray menu, with a "What's new" link to its release notes.
- **Download, verify, install on restart.** The asset for this OS and architecture is downloaded and checked
  against `SHA256SUMS`, and `SHA256SUMS` against an Ed25519 signature (`SHA256SUMS.sig`) made with a key whose
  public half is pinned in the app. A missing or bad signature, or no pinned key, means nothing is installed.
  "Restart to update" swaps the install and relaunches; "Install updates automatically" applies it on quit.
  - Linux: extract next to the bundle, swap the directories, start the new one once this process is gone.
  - Windows: a PowerShell helper in the temp folder waits for the process to end, swaps the folder and relaunches.
  - macOS: replace `tix.app` where it runs from and relaunch with `open`. Only outside the App Sandbox; the
    sandboxed release build gets the Download fallback.
  - Install location not writable: "Download" opens the release page instead.
- **Off where something else updates the app**: Flatpak (`/.flatpak-info`), Snap, and any build made with
  `--dart-define=TIX_SELF_UPDATE=false`, which the Flatpak build, the Play bundle and the F-Droid recipe pass.
  Android shows a notice with a link, never installs, and only for APKs installed through the system package
  installer (the GitHub APK), never for Play or F-Droid installs. iOS has nothing.
- **Settings**: an Updates section with "Check for updates" (on), "Install updates automatically" (off) and Check
  now. Strings in English, Bulgarian, German and French.
- **Release workflow**: signs `SHA256SUMS` into `SHA256SUMS.sig` with the `UPDATE_SIGNING_KEY` secret, only when it
  exists. `docs/releasing.md` says how to make the key, set the secret and pin the public key.

## Impact

- Capabilities: new `self-update`; `release-channels` gains the update signature.
- New dependencies: `cryptography` 2.9 (Apache-2.0, pure Dart Ed25519) and `crypto` (BSD-3-Clause, already a
  transitive dependency, now direct for SHA-256). Both are pure Dart and run on every platform.
- Dart: `data/update/` (release model, version comparison, asset choice, verification, the GitHub feed, the
  installers behind `UpdateInstaller`), `core/update/` (support, settings, the controller), a shared update panel
  in `core/widgets`, the tray entry in `core/desktop` and `core/widgets/desktop_host.dart`, Settings and About.
- CI: `release.yaml` publish job, `justfile` (`build-aab`), `flatpak/build.sh`, `fdroid/` recipe.
