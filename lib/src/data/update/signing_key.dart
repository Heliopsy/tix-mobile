// SPDX-License-Identifier: AGPL-3.0-or-later

// TODO(thereisnotime): pin the public half of UPDATE_SIGNING_KEY below,
// as docs/releasing.md#desktop-update-signing says.

/// The Ed25519 public key that signs `SHA256SUMS` in every release, as the
/// base64 of its 32 raw bytes. Empty means checksum-only: an update is
/// installed when it matches the release's `SHA256SUMS`, both fetched over
/// HTTPS from GitHub. Once set, a missing or bad `SHA256SUMS.sig` stops
/// every install. Changing it leaves copies that pin the old key on manual
/// downloads.
const updateSigningPublicKey = '';
