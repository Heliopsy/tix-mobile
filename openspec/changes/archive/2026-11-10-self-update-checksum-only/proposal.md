# Proposal

## Why

Self-update installs nothing until an update signing key is created and pinned, so the Linux and Windows downloads
cannot update in place yet. Checking the archive against `SHA256SUMS` from the same release, both fetched over
HTTPS from GitHub, is the trust someone has today downloading the archive by hand from the release page.

## What Changes

- With no key pinned (`updateSigningPublicKey` empty), an update installs after its SHA-256 matches `SHA256SUMS`.
  This is checksum-only, and the code and docs say so.
- With a key pinned nothing changes: a missing or bad `SHA256SUMS.sig` stops the install, with no fallback.
- Every release download (the archive, `SHA256SUMS`, `SHA256SUMS.sig`) has to be HTTPS on `github.com` or
  `*.githubusercontent.com`, before and after redirects.
- An unpinned build is no longer held to Download. macOS still is, because of the App Sandbox.
- The release workflow keeps signing when `UPDATE_SIGNING_KEY` exists.

## Impact

`data/update/updater.dart`, `release_feed.dart`, `signing_key.dart`, `core/update/updates.dart`, their tests,
`docs/releasing.md`, `docs/architecture.md` and the README.
