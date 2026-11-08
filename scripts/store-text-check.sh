#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Fail if any store listing under fastlane/metadata/android is missing a file
# or exceeds Google Play's limits, counted in characters, not bytes: title 30,
# short description 80, full description 4000.

set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
declare -A limit=([title.txt]=30 [short_description.txt]=80 [full_description.txt]=4000)
failed=0
for dir in "$root"/fastlane/metadata/android/*/; do
  locale=$(basename "$dir")
  for file in title.txt short_description.txt full_description.txt; do
    path="$dir$file"
    if [ ! -s "$path" ]; then
      echo "store-text: $locale/$file is missing or empty" >&2; failed=1; continue
    fi
    # The trailing newline is not part of the text the store shows.
    n=$(printf '%s' "$(cat "$path")" | LC_ALL=C.UTF-8 wc -m)
    if [ "$n" -gt "${limit[$file]}" ]; then
      echo "store-text: $locale/$file has $n characters, the limit is ${limit[$file]}" >&2; failed=1
    fi
  done
done
[ "$failed" -eq 0 ] && echo "store text is within the limits"
exit "$failed"
