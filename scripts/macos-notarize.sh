#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Developer ID signing and notarisation for the macOS release, run by
# release.yaml only when the signing secrets exist (docs/releasing.md).
#
#   scripts/macos-notarize.sh keychain     import MACOS_CERT_P12_BASE64 into a
#                                          throwaway keychain and print the
#                                          Developer ID identity's hash
#   scripts/macos-notarize.sh sign APP ID  re-sign APP inside out with the
#                                          hardened runtime and a timestamp
#   scripts/macos-notarize.sh notarize APP submit to Apple's notary service,
#                                          wait, and staple the ticket to APP
#
# Environment: MACOS_CERT_P12_BASE64, MACOS_CERT_PASSWORD (keychain);
# APP_STORE_CONNECT_KEY_ID, APP_STORE_CONNECT_ISSUER_ID,
# APP_STORE_CONNECT_KEY_BASE64 (notarize); RUNNER_TEMP or TMPDIR for scratch.

set -euo pipefail

die() { echo "macos-notarize: $*" >&2; exit 1; }

[ "$(uname -s)" = Darwin ] || die "needs macOS"
tmp="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
keychain="$tmp/tix-signing.keychain-db"
entitlements="macos/Runner/Release.entitlements"

cmd_keychain() {
  : "${MACOS_CERT_P12_BASE64:?}" "${MACOS_CERT_PASSWORD:?}"
  local pass p12
  pass=$(openssl rand -hex 16)
  p12="$tmp/developer-id.p12"
  (umask 077; printf '%s' "$MACOS_CERT_P12_BASE64" | base64 --decode > "$p12")
  security create-keychain -p "$pass" "$keychain" >&2
  security set-keychain-settings -lut 3600 "$keychain" >&2
  security unlock-keychain -p "$pass" "$keychain" >&2
  security import "$p12" -k "$keychain" -P "$MACOS_CERT_PASSWORD" -T /usr/bin/codesign >&2
  rm -f "$p12"
  # codesign may use the key without a prompt nobody is there to answer.
  security set-key-partition-list -S apple-tool:,apple: -s -k "$pass" "$keychain" >/dev/null
  # Search this keychain first, keeping the login keychain for the system's
  # own certificates.
  # shellcheck disable=SC2046
  security list-keychains -d user -s "$keychain" $(security list-keychains -d user | tr -d '"')
  local id
  id=$(security find-identity -v -p codesigning "$keychain" \
         | awk '/"Developer ID Application: / { print $2; exit }')
  [ -n "$id" ] || die "the certificate holds no Developer ID Application identity"
  echo "$id"
}

cmd_sign() {
  local app=${1:?app} id=${2:?identity}
  [ -d "$app" ] || die "no app at $app"
  local opts=(--force --timestamp --options runtime --sign "$id")
  [ -f "$keychain" ] && opts+=(--keychain "$keychain")
  # Inside out: every nested framework and dylib (libtix among them) before
  # the bundle that contains it, deepest first. --deep would sign them all
  # with the app's entitlements, which Apple advises against.
  if [ -d "$app/Contents/Frameworks" ]; then
    while IFS= read -r -d '' nested; do
      codesign "${opts[@]}" "$nested"
    done < <(find "$app/Contents/Frameworks" -depth \( -name '*.framework' -o -name '*.dylib' \) -print0)
  fi
  codesign "${opts[@]}" --entitlements "$entitlements" "$app"
  codesign --verify --strict --deep --verbose=2 "$app"
}

cmd_notarize() {
  local app=${1:?app}
  : "${APP_STORE_CONNECT_KEY_ID:?}" "${APP_STORE_CONNECT_ISSUER_ID:?}" "${APP_STORE_CONNECT_KEY_BASE64:?}"
  local key="$tmp/AuthKey.p8" zip="$tmp/notarize.zip" out="$tmp/notarize.json"
  trap 'rm -f "$tmp/AuthKey.p8"' EXIT
  (umask 077; printf '%s' "$APP_STORE_CONNECT_KEY_BASE64" | base64 --decode > "$key")
  local auth=(--key "$key" --key-id "$APP_STORE_CONNECT_KEY_ID" --issuer "$APP_STORE_CONNECT_ISSUER_ID")
  ditto -c -k --keepParent "$app" "$zip"
  xcrun notarytool submit "$zip" "${auth[@]}" --wait --timeout 30m --output-format json > "$out"
  local status id
  status=$(jq -r '.status' "$out")
  id=$(jq -r '.id' "$out")
  if [ "$status" != Accepted ]; then
    xcrun notarytool log "$id" "${auth[@]}" >&2 || true
    die "notarisation $id ended $status"
  fi
  echo "notarised: submission $id"
  xcrun stapler staple "$app"
  xcrun stapler validate "$app"
  spctl --assess --type execute --verbose=2 "$app"
}

case "${1:-}" in
  keychain) cmd_keychain ;;
  sign) shift; cmd_sign "$@" ;;
  notarize) shift; cmd_notarize "$@" ;;
  *) die "usage: $0 keychain | sign APP IDENTITY | notarize APP" ;;
esac
