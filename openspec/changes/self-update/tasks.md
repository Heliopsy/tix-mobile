# Tasks

## 1. Spec and dependencies

- [x] 1.1 `self-update` spec and the `release-channels` addition
- [x] 1.2 `cryptography` and `crypto`, licence and platform check

## 2. Data

- [x] 2.1 Release model, version comparison and asset choice; tests
- [x] 2.2 SHA256SUMS parsing, file hashing and Ed25519 verification; tests with a keypair made in the test
- [x] 2.3 The GitHub release feed
- [x] 2.4 `UpdateInstaller` and the Linux, Windows and macOS installers; `Updater`; tests with a fake installer

## 3. Application and UI

- [x] 3.1 Update mode, settings and the update controller; tests
- [x] 3.2 Update panel in Settings and About; tray entry, install on quit; strings in four languages; tests

## 4. Release and packaging

- [x] 4.1 `release.yaml` signs `SHA256SUMS` when `UPDATE_SIGNING_KEY` exists
- [x] 4.2 `TIX_SELF_UPDATE=false` for Flatpak, the Play bundle and F-Droid
- [x] 4.3 `docs/releasing.md`, README, `docs/architecture.md`
