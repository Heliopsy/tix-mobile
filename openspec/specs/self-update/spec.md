# self-update Specification

## Purpose
The Linux, Windows and macOS downloads from the GitHub release look for newer releases, verify them against a signed `SHA256SUMS` and install them on restart, falling back to a link to the release page where they cannot; builds that a store or package manager updates never check.

## Requirements

### Requirement: Check GitHub releases for a newer version

Where updates are not off, the app SHALL ask GitHub for the latest release of heliopsy/tix-mobile at start and every six hours while "Check for updates" is on, and whenever the person picks Check now. It SHALL skip drafts and prereleases and SHALL offer the release only when its version is newer than the running one by semantic version precedence.

#### Scenario: Newer release

- **WHEN** version 0.11.0 runs and the latest release is v0.12.0
- **THEN** Settings and About say an update to 0.12.0 is available, with a What's new link to its release notes

#### Scenario: Same version

- **WHEN** version 0.12.0 runs and the latest release is v0.12.0
- **THEN** Settings says tix is up to date and nothing is downloaded

#### Scenario: Checking turned off

- **WHEN** "Check for updates" is off
- **THEN** nothing is fetched until the person picks Check now

### Requirement: Pick the asset for this system

The app SHALL download only the release asset built for its own operating system and architecture: the Linux tarball for x64 or arm64, the Windows x64 zip, or the macOS zip. When the release has no such asset, it SHALL offer the release page instead of installing.

#### Scenario: Linux on arm64

- **WHEN** the app runs on Linux arm64 and v0.12.0 is offered
- **THEN** it downloads `tix-mobile-0.12.0-linux-arm64.tar.gz`

#### Scenario: Windows on arm64

- **WHEN** the app runs on Windows arm64
- **THEN** it shows the update with a Download link to the release page and installs nothing

### Requirement: Verify before installing

Before installing, the app SHALL check the downloaded asset's SHA-256 against its line in the release's `SHA256SUMS`. When an Ed25519 public key is built into the app, it SHALL first verify `SHA256SUMS` against `SHA256SUMS.sig` with that key, and a missing or invalid signature SHALL stop the install. With no key built in the check SHALL be checksum-only. A missing `SHA256SUMS`, a missing line or a different hash SHALL stop the install.

#### Scenario: Unsigned release

- **WHEN** the app pins a key and the latest release has `SHA256SUMS` but no `SHA256SUMS.sig`
- **THEN** the app says the update could not be verified, installs nothing and offers Download

#### Scenario: Checksum-only

- **WHEN** the app pins no key and the downloaded archive matches its line in `SHA256SUMS`
- **THEN** the update is staged and installs on restart

#### Scenario: Tampered download

- **WHEN** the downloaded archive's SHA-256 differs from its line in `SHA256SUMS`, with or without a key pinned
- **THEN** the archive is deleted and nothing is installed

### Requirement: Install on restart

On Linux, Windows and macOS, a verified update SHALL be staged next to the installed app and applied only when the app restarts: when the person picks Restart to update, or, with "Install updates automatically" on, when the app quits. Applying SHALL replace the installed directory or app bundle as a whole and keep the old one until the new one is in place.

#### Scenario: Restart to update

- **WHEN** an update is staged and the person picks Restart to update
- **THEN** the app quits, the new version replaces the old one and starts

#### Scenario: Install on quit

- **WHEN** "Install updates automatically" is on, an update is staged and the person picks Quit tix in the tray
- **THEN** the new version is in place the next time tix starts, and tix does not start by itself

### Requirement: Fall back to the release page

When the install location cannot be written, the app runs in the macOS App Sandbox or the build is not a release build, the app SHALL still show an available update but SHALL offer Download, which opens the release page, instead of installing.

#### Scenario: Read-only install

- **WHEN** the Linux bundle sits in a directory the user cannot write
- **THEN** Settings shows the update with Download and What's new, and no Restart to update

### Requirement: Off where something else updates the app

Updates SHALL be off, with no check and no Updates section, in a Flatpak, in a Snap, on iOS, in any build made with `TIX_SELF_UPDATE=false`, and on Android when a store or any installer other than the system package installer installed the app. On Android installed from the GitHub APK the app SHALL only show a notice with a link and SHALL never download or install an APK.

#### Scenario: Flathub

- **WHEN** the app runs inside Flatpak
- **THEN** it never contacts GitHub and Settings has no Updates section

#### Scenario: Play install

- **WHEN** Google Play installed the app
- **THEN** no update check runs

#### Scenario: GitHub APK

- **WHEN** the APK from the GitHub release was installed through the system package installer and a newer release exists
- **THEN** Settings shows the update with a Download link to the release page and nothing is installed

### Requirement: Update settings

Settings SHALL offer, where updates are not off, "Check for updates" (on by default), Check now, and, where the app can install updates itself, "Install updates automatically" (off by default). The choices SHALL be kept on the device.

#### Scenario: Defaults

- **WHEN** a Linux tarball install opens Settings for the first time
- **THEN** "Check for updates" is on and "Install updates automatically" is off

### Requirement: Tray shows the update

On a desktop with a tray, while an update is available the tray menu SHALL carry one entry for it: "Update available" with the version, which shows the window on About, or, once staged, "Restart to update" with the version, which installs it as Restart to update does.

#### Scenario: Staged update in the tray

- **WHEN** v0.12.0 is staged
- **THEN** the tray menu shows "Restart to update (0.12.0)", and picking it restarts into 0.12.0

### Requirement: Download only from GitHub over HTTPS

The app SHALL fetch a release's archive, `SHA256SUMS` and `SHA256SUMS.sig` only over HTTPS from `github.com` or a `githubusercontent.com` host, and SHALL refuse the update when a URL or the address a redirect ends at is anything else.

#### Scenario: Plain HTTP asset

- **WHEN** a release lists its archive under an `http://` URL
- **THEN** nothing is downloaded and the app offers Download
