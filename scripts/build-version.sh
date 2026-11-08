#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Print the flutter build flags that stamp a release with its version.
#
#   scripts/build-version.sh TAG mobile    --build-name=1.2.3 --build-number=1002003
#   scripts/build-version.sh TAG desktop   --build-name=1.2.3
#
# The build number is derived from the tag rather than read from pubspec.yaml,
# because Google Play and App Store Connect both refuse an upload whose build
# number is not greater than every one before it, and release-please only
# rewrites the version, not the "+N" after it. MAJOR*1000000 + MINOR*1000 +
# PATCH grows with every release, fits Android's 2100000000 ceiling up to
# major 2099, and is readable back into the version by eye.
#
# Desktop gets the name only. Windows packs the build number into one 16-bit
# field of the file version, so the mobile number would overflow it; desktop
# keeps whatever pubspec.yaml carries after the "+".

set -euo pipefail

tag=${1:?usage: $0 TAG mobile|desktop}
kind=${2:?usage: $0 TAG mobile|desktop}
version=${tag#v}

if ! [[ "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  echo "build-version.sh: $tag is not a vMAJOR.MINOR.PATCH tag" >&2
  exit 1
fi
major=${BASH_REMATCH[1]} minor=${BASH_REMATCH[2]} patch=${BASH_REMATCH[3]}
if [ "$minor" -gt 999 ] || [ "$patch" -gt 999 ]; then
  echo "build-version.sh: minor and patch must stay under 1000 for the build number scheme" >&2
  exit 1
fi

case "$kind" in
  mobile)  echo "--build-name=$version --build-number=$((10#$major * 1000000 + 10#$minor * 1000 + 10#$patch))" ;;
  desktop) echo "--build-name=$version" ;;
  *) echo "build-version.sh: kind must be mobile or desktop" >&2; exit 1 ;;
esac
