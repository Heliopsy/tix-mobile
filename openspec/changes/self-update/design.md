# Design

## Context

Desktop releases are a tarball (Linux x64 and arm64), a zip of the Windows runner output and a zip of `tix.app`,
all attached to the GitHub release with `SHA256SUMS` and a cosign bundle. The cosign bundle proves the workflow
made the file, but checking it needs Sigstore's trust root and a transparency log client, which is far more than
an app should carry. The tray, close to tray and Quit live in `core/desktop` and `DesktopHost`.

## Decisions

### GitHub releases as the source

`GET https://api.github.com/repos/heliopsy/tix-mobile/releases/latest` already leaves out drafts and prereleases;
the flags are checked again anyway. Unauthenticated requests get 60 an hour per address, and one check every six
hours is far inside that. tix.red's `mobile-release.json` follows the same releases but adds a hop that can lag.

The feed is its own small client in `data/update/release_feed.dart`, on its own Dio. It is not the tix API client
and shares nothing with it: no credential, no base URL, no tix error envelope. It marshals and nothing else, like
the API client; version comparison, asset choice and verification are separate pure functions.

### Versions

`ReleaseVersion` parses `vMAJOR.MINOR.PATCH`, an optional `-prerelease` and ignores `+build`. Comparison follows
semver precedence. The running version is `package_info`'s, which the release workflow stamps with
`--build-name` from the tag.

### Which file

| Running on | Asset |
| --- | --- |
| Linux x64 | `tix-mobile-<v>-linux-x64.tar.gz` |
| Linux arm64 | `tix-mobile-<v>-linux-arm64.tar.gz` |
| Windows x64 | `tix-mobile-<v>-windows-x64.zip` |
| macOS (either) | `tix-mobile-<v>-macos.zip` |

The architecture is `Abi.current()`, the process's own, so an x64 build under emulation asks for x64 again.
Windows on arm64 has no asset, so it gets the notice and the Download link.

### Authenticity: an Ed25519 signature over SHA256SUMS

`SHA256SUMS` from the same release only proves the download was not damaged. The release workflow signs it with
an Ed25519 key held in the `UPDATE_SIGNING_KEY` secret (`openssl pkeyutl -sign -rawin`, a raw 64-byte signature in
`SHA256SUMS.sig`), and the app pins the public key in `data/update/signing_key.dart`. Before anything large is
downloaded, the app fetches both files and verifies the signature; then it downloads the asset and compares its
SHA-256 with the signed line. No pinned key, no `.sig`, a bad signature or a wrong hash all end in "could not be
verified" and the Download link, never an install.

The secret is optional: without it the release goes out unsigned and installed apps keep offering only Download.
The key is created by the owner (docs/releasing.md); none is generated or committed here.

`cryptography` (Apache-2.0) does Ed25519 in pure Dart; `crypto` (BSD-3-Clause, the Dart team's) hashes the file as
a stream. `pinenacl` was the alternative; `cryptography` is more widely used and has a streaming-friendly API.

### Staging and the swap behind `UpdateInstaller`

`UpdateInstaller` has three calls: `target()` (where the app is installed and whether that can be written),
`stage(archive)` (extract next to it and check the result looks like this app), and `apply(staged, relaunch)`.
`Updater` does everything else and is tested with a fake installer. The platform classes only run the system's
own tools and move directories:

- **Linux.** The bundle directory is `dirname(/proc/self/exe)`. `tar -xzf` into `.<bundle>.update` beside it, the
  swap is two renames on the same filesystem (bundle to `.<bundle>.old`, staged to bundle, renamed back if the
  second fails), and a detached `sh` waits for this PID to exit before starting the new binary, since the GTK
  application is unique and a second copy would only hand over to this one.
- **Windows.** The running exe and its DLLs are locked. `tar.exe` (in System32 since Windows 10 1803) extracts the
  zip beside the folder; a PowerShell script written to the temp folder waits for the PID, retries the rename for a
  few seconds (antivirus holds files briefly), puts the old folder back if the new one cannot be moved in, starts
  the new exe and removes the old folder.
- **macOS.** `ditto -x -k` keeps symlinks, permissions and the code signature intact and adds no quarantine; the
  app is swapped by rename and a detached `sh` runs `open` on it once this PID exits. The App Sandbox forbids all
  of this, and the release build is sandboxed, so `target()` answers "not writable" when
  `APP_SANDBOX_CONTAINER_ID` is set and macOS falls back to Download until the GitHub build drops the sandbox.

Leftover `.update` and `.old` directories are removed at the next start.

### When it installs

The update is downloaded and staged in the background as soon as it is found, so the tray and Settings can offer
"Restart to update" straight away. With "Install updates automatically" on, the staged update is applied on quit:
Quit in the tray, and the window's close button when it is not hiding to the tray (close is intercepted while an
update waits). The macOS app menu's Quit is not intercepted and leaves the update for the next restart.

### Where it is off

`UpdateMode` is `off`, `notify` (show and link) or `install`:

| Situation | Mode |
| --- | --- |
| Built with `TIX_SELF_UPDATE=false` (Flatpak, Play bundle, F-Droid) | off |
| Flatpak (`/.flatpak-info`) or Snap (`SNAP`) | off |
| iOS | off |
| Android installed by Play, F-Droid or any store | off |
| Android installed by the system package installer (the GitHub APK) | notify |
| Desktop, debug build, no pinned key, sandboxed, or not writable | notify |
| Desktop release build, key pinned, writable | install |

On Android `package_info_plus`'s `installerStore` gives the installer: null (adb) or the system package installer
means the GitHub APK. F-Droid forbids self-updaters, so Android never installs anything, and F-Droid builds turn
even the notice off at build time.

### UI

One `UpdatePanel` in `core/widgets` reads the controller and is shown in Settings (Updates section) and About.
The tray menu gets one entry while an update is known: "Update available (v)" shows the window on About, "Restart
to update (v)" installs.
