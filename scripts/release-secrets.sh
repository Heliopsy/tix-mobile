#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Decide whether a release channel runs, from which of its secrets exist.
# Writes OUTPUT=true or OUTPUT=false to $GITHUB_OUTPUT and never fails, so a
# repository without the store accounts still releases everything else.
#
#   scripts/release-secrets.sh OUTPUT OWN... [-- SHARED...]
#
# OWN are the secrets only this channel uses, SHARED ones it needs but other
# channels use too (the App Store Connect key, the Android upload keystore).
# The values are read from environment variables of the same names and never
# printed. None of OWN set: a notice, the channel is simply not set up. Some
# of OWN, or all of OWN but not SHARED: a warning naming what is missing,
# because that looks like a half-finished setup.

set -euo pipefail

out=${1:?usage: $0 OUTPUT OWN... [-- SHARED...]}
shift
own=() shared=()
while [ "$#" -gt 0 ]; do
  if [ "$1" = -- ]; then shift; shared=("$@"); break; fi
  own+=("$1"); shift
done
[ "${#own[@]}" -gt 0 ] || { echo "release-secrets: no secrets named" >&2; exit 2; }

set_own=0 missing=()
for name in "${own[@]}"; do
  if [ -n "${!name:-}" ]; then set_own=$((set_own + 1)); else missing+=("$name"); fi
done
for name in "${shared[@]}"; do
  [ -n "${!name:-}" ] || missing+=("$name")
done

emit() { echo "$out=$1" >> "${GITHUB_OUTPUT:-/dev/stdout}"; }

if [ "${#missing[@]}" -eq 0 ]; then
  echo "$out: every secret is set"
  emit true
elif [ "$set_own" -eq 0 ]; then
  echo "::notice::$out skipped: ${own[*]} not set (docs/releasing.md)."
  emit false
else
  echo "::warning::$out skipped: missing ${missing[*]} (docs/releasing.md)."
  emit false
fi
