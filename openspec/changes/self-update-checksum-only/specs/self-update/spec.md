# self-update

## MODIFIED Requirements

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

### Requirement: Fall back to the release page

When the install location cannot be written, the app runs in the macOS App Sandbox or the build is not a release build, the app SHALL still show an available update but SHALL offer Download, which opens the release page, instead of installing.

#### Scenario: Read-only install

- **WHEN** the Linux bundle sits in a directory the user cannot write
- **THEN** Settings shows the update with Download and What's new, and no Restart to update

## ADDED Requirements

### Requirement: Download only from GitHub over HTTPS

The app SHALL fetch a release's archive, `SHA256SUMS` and `SHA256SUMS.sig` only over HTTPS from `github.com` or a `githubusercontent.com` host, and SHALL refuse the update when a URL or the address a redirect ends at is anything else.

#### Scenario: Plain HTTP asset

- **WHEN** a release lists its archive under an `http://` URL
- **THEN** nothing is downloaded and the app offers Download
