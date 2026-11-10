// SPDX-License-Identifier: AGPL-3.0-or-later

// TODO(thereisnotime): pin the public half of UPDATE_SIGNING_KEY below,
// as docs/releasing.md#desktop-update-signing says.

/// The Ed25519 public key that signs `SHA256SUMS` in every release, as the
/// base64 of its 32 raw bytes. Empty means no key is pinned, and then no
/// update is ever installed, only offered as a download. Changing it leaves
/// every installed copy that pins the old key on manual downloads.
const updateSigningPublicKey = '';
