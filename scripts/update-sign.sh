#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Sign a release's SHA256SUMS for the desktop self-update, run by release.yaml
# only when the UPDATE_SIGNING_KEY secret exists (docs/releasing.md).
#
#   scripts/update-sign.sh FILE [PINNED]
#
# UPDATE_SIGNING_KEY holds an Ed25519 private key in PEM. FILE.sig gets the raw
# 64-byte signature over FILE's exact bytes, which the app checks against the
# public key it pins in PINNED (lib/src/data/update/signing_key.dart). The
# signature is verified straight away, and a pinned key that differs from this
# one is a warning: copies of the app built from this commit could not install
# the release.

set -euo pipefail

file=${1:?usage: $0 FILE [PINNED]}
pinned=${2:-}
: "${UPDATE_SIGNING_KEY:?UPDATE_SIGNING_KEY is not set}"

dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
(umask 077 && printf '%s\n' "$UPDATE_SIGNING_KEY" > "$dir/key.pem")

if ! openssl pkey -in "$dir/key.pem" -noout -text 2>/dev/null | grep -q '^ED25519 Private-Key'; then
  echo "update-sign: UPDATE_SIGNING_KEY is not an Ed25519 private key in PEM" >&2
  exit 1
fi
openssl pkey -in "$dir/key.pem" -pubout -out "$dir/pub.pem"
openssl pkeyutl -sign -rawin -inkey "$dir/key.pem" -in "$file" -out "$file.sig"
openssl pkeyutl -verify -rawin -pubin -inkey "$dir/pub.pem" -in "$file" -sigfile "$file.sig" >/dev/null

size=$(wc -c < "$file.sig")
if [ "$size" -ne 64 ]; then
  echo "update-sign: $file.sig is $size bytes, not 64" >&2
  exit 1
fi

public=$(openssl pkey -pubin -in "$dir/pub.pem" -outform DER | tail -c 32 | base64)
echo "signed $file with the update key $public"

if [ -n "$pinned" ]; then
  app=$(sed -nE "s/^const updateSigningPublicKey = '([^']*)';$/\1/p" "$pinned")
  if [ -z "$app" ]; then
    echo "::warning::$pinned pins no update key yet, so apps built from this commit only offer downloads."
  elif [ "$app" != "$public" ]; then
    echo "::warning::$pinned pins $app, but the release was signed with $public."
  fi
fi
