# self-update

## ADDED Requirements

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

Before installing, the app SHALL verify `SHA256SUMS` against `SHA256SUMS.sig` with the Ed25519 public key built into the app, and the downloaded asset's SHA-256 against its line in `SHA256SUMS`. A missing signature, an invalid signature, no built-in key, a missing line or a different hash SHALL stop the install, and the app SHALL offer the release page instead.

#### Scenario: Unsigned release

- **WHEN** the latest release has `SHA256SUMS` but no `SHA256SUMS.sig`
- **THEN** the app says the update could not be verified, installs nothing and offers Download

#### Scenario: Tampered download

- **WHEN** the downloaded archive's SHA-256 differs from the signed checksum
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

When the install location cannot be written, the app runs in the macOS App Sandbox, the build is not a release build or no signing key is built in, the app SHALL still show an available update but SHALL offer Download, which opens the release page, instead of installing.

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
