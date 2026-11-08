#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Fail unless a build carries the embedded engine (libtix), and on Android
# unless it is stored the way Google Play requires.
#
#   scripts/engine-check.sh android FILE.apk...   libtix.so in each APK, stored
#                                                 uncompressed, 16 KB aligned in
#                                                 the zip and in its LOAD segments
#   scripts/engine-check.sh aab FILE.aab          libtix.so for every shipped ABI
#   scripts/engine-check.sh bundle DIR            libtix.{so,dll,dylib} somewhere
#                                                 under a desktop or iOS bundle
#
# A build without Go bundles no engine and still succeeds, by design, so CI
# runs this after every build to make sure release artifacts never lack it.

set -euo pipefail

die() { echo "engine-check: $*" >&2; exit 1; }

newest() { # newest file matching a glob, or nothing
  # shellcheck disable=SC2012 # the paths are tool installs, not user input
  ls -d "$@" 2>/dev/null | sort -V | tail -1
}

android_tools() {
  sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
  zipalign=$(newest "$sdk"/build-tools/*/zipalign)
  [ -n "$zipalign" ] || die "no zipalign under $sdk/build-tools"
  ndk="${ANDROID_NDK_HOME:-${ANDROID_NDK_LATEST_HOME:-${ANDROID_NDK_ROOT:-}}}"
  [ -n "$ndk" ] || ndk=$(newest "$sdk"/ndk/*)
  readelf=$(newest "$ndk"/toolchains/llvm/prebuilt/*/bin/llvm-readelf)
  [ -n "$readelf" ] || readelf=$(command -v llvm-readelf || command -v readelf || true)
  [ -n "$readelf" ] || die "no llvm-readelf or readelf"
}

load_aligned() { # SO NAME
  local aligns a
  aligns=$("$readelf" -lW "$1" | awk '$1 == "LOAD" {print $NF}')
  [ -n "$aligns" ] || die "$2: no LOAD segments"
  for a in $aligns; do
    [ $((a)) -ge $((0x4000)) ] || die "$2: LOAD segment aligned to $a, want 0x4000"
  done
}

check_apk() {
  local apk=$1 tmp
  mapfile -t libs < <(unzip -Z1 "$apk" | grep -E '^lib/[^/]+/libtix\.so$' || true)
  [ "${#libs[@]}" -gt 0 ] || die "$apk: no lib/*/libtix.so"
  for lib in "${libs[@]}"; do
    unzip -Z -v "$apk" "$lib" | grep -q 'compression method:.*none (stored)' \
      || die "$apk: $lib is compressed; native libraries must be stored"
    tmp=$(mktemp)
    unzip -p "$apk" "$lib" > "$tmp"
    load_aligned "$tmp" "$apk:$lib"
    rm -f "$tmp"
  done
  "$zipalign" -c -P 16 4 "$apk" >/dev/null || die "$apk: not 16 KB zip-aligned (zipalign -c -P 16)"
  echo "$apk: ${libs[*]} stored, 16 KB aligned"
}

case "${1:-}" in
  android)
    shift
    [ "$#" -gt 0 ] || die "android needs at least one APK"
    android_tools
    for apk in "$@"; do check_apk "$apk"; done
    ;;
  aab)
    [ -f "${2:-}" ] || die "aab needs an .aab file"
    for abi in arm64-v8a armeabi-v7a x86_64; do
      unzip -Z1 "$2" | grep -qx "base/lib/$abi/libtix.so" || die "$2: no base/lib/$abi/libtix.so"
    done
    echo "$2: libtix.so for arm64-v8a, armeabi-v7a, x86_64"
    ;;
  bundle)
    [ -d "${2:-}" ] || die "bundle needs a directory"
    found=$(find "$2" \( -name 'libtix.so' -o -name 'libtix.dll' -o -path '*libtix.framework/libtix' \) -print -quit)
    [ -n "$found" ] || die "$2: no libtix in the bundle"
    echo "$2: $found"
    ;;
  *)
    die "usage: engine-check.sh android APK... | aab AAB | bundle DIR"
    ;;
esac
