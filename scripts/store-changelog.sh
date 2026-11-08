#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Turn one version's CHANGELOG.md section, which release-please writes, into
# the plain "what's new" text the stores show, and write it where fastlane
# supply (Google Play) and F-Droid read it:
#
#   scripts/store-changelog.sh VERSION VERSION_CODE
#     -> fastlane/metadata/android/en-US/changelogs/VERSION_CODE.txt
#
# Links, commit hashes and headings are dropped, bullets kept, and the text cut
# at 500 characters, Google Play's limit, on a whole line.

set -euo pipefail

version=${1:?usage: $0 VERSION VERSION_CODE}
code=${2:?usage: $0 VERSION VERSION_CODE}
version=${version#v}
root=$(cd "$(dirname "$0")/.." && pwd)
out="$root/fastlane/metadata/android/en-US/changelogs/$code.txt"
limit=500

section=$(awk -v v="$version" '
  /^## / { if (found) exit; if (index($0, "[" v "]") || index($0, " " v " ") || $0 ~ (" " v "$")) { found = 1; next } }
  found' "$root/CHANGELOG.md")
[ -n "$section" ] || { echo "store-changelog: no CHANGELOG.md section for $version" >&2; exit 1; }

# "* **scope:** text ([abc1234](url))" -> "- scope: text"
text=$(sed -E \
  -e '/^#/d' \
  -e '/^[[:space:]]*$/d' \
  -e 's/ \(\[[0-9a-f]{7,40}\]\([^)]*\)\)//g' \
  -e 's/ \(\[#[0-9]+\]\([^)]*\)\)//g' \
  -e 's/\[([^]]*)\]\([^)]*\)/\1/g' \
  -e 's/\*\*//g' \
  -e 's/^\* /- /' <<<"$section")
[ -n "$text" ] || text="Maintenance release."

mkdir -p "$(dirname "$out")"
: > "$out"
while IFS= read -r line; do
  if [ $(( $(wc -m < "$out") + ${#line} + 1 )) -gt "$limit" ]; then break; fi
  printf '%s\n' "$line" >> "$out"
done <<<"$text"
[ -s "$out" ] || printf '%s\n' "${text:0:$((limit - 1))}" > "$out"
echo "wrote $out ($(wc -m < "$out") characters)"
