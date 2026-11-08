#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Fail if an APK contains code F-Droid would reject as non-free: Google Play
# services, Firebase, the Play Core libraries, or the other proprietary SDKs
# fdroidserver's scanner looks for. CI runs it on every Android build, so a
# dependency that pulls one in fails the pull request that adds it rather than
# the F-Droid build months later.
#
#   scripts/fdroid-check.sh FILE.apk...

set -euo pipefail

[ "$#" -gt 0 ] || { echo "usage: $0 FILE.apk..." >&2; exit 2; }

# Dex type descriptors, as they appear in classes*.dex.
nonfree='L(com/google/android/gms|com/google/firebase|com/google/android/play/core|com/google/android/play/integrity|com/google/android/play/review|com/google/android/play/appupdate|com/google/android/play/feature|com/google/android/datatransport|com/google/mlkit|com/crashlytics|io/fabric|com/huawei/hms|com/amazon/device/messaging|com/onesignal|com/appsflyer|com/facebook/appevents)/'

failed=0
for apk in "$@"; do
  [ -f "$apk" ] || { echo "fdroid-check: no such file: $apk" >&2; exit 1; }
  found=$(unzip -p "$apk" 'classes*.dex' | LC_ALL=C grep -a -o -E "$nonfree" | sort -u || true)
  if [ -n "$found" ]; then
    echo "fdroid-check: $apk carries non-free code:" >&2
    while IFS= read -r hit; do echo "  $hit" >&2; done <<<"$found"
    failed=1
  else
    echo "fdroid-check: $apk carries no known non-free code"
  fi
done
exit "$failed"
