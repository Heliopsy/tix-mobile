# release-channels

## ADDED Requirements

### Requirement: Signed checksums for desktop updates

When the `UPDATE_SIGNING_KEY` secret exists, the release workflow SHALL sign `SHA256SUMS` with that Ed25519 key into `SHA256SUMS.sig`, verify the signature before publishing, and attach it to the release. Without the secret it SHALL skip the signature with a notice and still publish the release.

#### Scenario: Key configured

- **WHEN** a release runs with `UPDATE_SIGNING_KEY` set
- **THEN** the release carries `SHA256SUMS.sig`, and `openssl pkeyutl -verify` with the public key accepts it

#### Scenario: No key

- **WHEN** a release runs without `UPDATE_SIGNING_KEY`
- **THEN** the release is published without `SHA256SUMS.sig` and the workflow prints a skip notice
