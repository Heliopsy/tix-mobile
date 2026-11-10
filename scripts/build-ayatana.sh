#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Build the libayatana-appindicator3 the Linux tarball ships, from upstream's
# release tag, into a prefix that `scripts/bundle-linux-libs.sh copy` takes.
#
#   scripts/build-ayatana.sh PREFIX    build into PREFIX/lib, licence files
#                                      into PREFIX/share/doc; a no-op when
#                                      PREFIX already holds this version
#   scripts/build-ayatana.sh version   print the pinned version
#
# Ubuntu 24.04 ships 0.5.x, which has no tooltip API, so KDE shows only the
# title on hover. 0.6.0 added the tooltip, and 0.6.1 no longer needs
# libayatana-indicator3 or ayatana-ido3. The soname is libayatana-appindicator3.so.1
# in both, so the app still builds against the distro's 0.5 headers.
#
# Only the library target is built: upstream's GObject introspection step has
# no switch, and the .gir and typelib are of no use to the bundle.

set -euo pipefail

version=0.6.1
sha256=56c0b938ffaa3e17b10c38d3e54c16d316f41f0da61949eda028adbf19ee767f
url=https://github.com/AyatanaIndicators/libayatana-appindicator/archive/refs/tags/$version.tar.gz
soname=libayatana-appindicator3.so.1

die() { echo "build-ayatana: $*" >&2; exit 1; }

[ $# -eq 1 ] || die "usage: $0 PREFIX|version"
if [ "$1" = version ]; then
  echo "$version"
  exit 0
fi

prefix=$(realpath -m "$1")
stamp="$version $sha256"
if [ -f "$prefix/lib/$soname" ] && [ "$(cat "$prefix/STAMP" 2>/dev/null)" = "$stamp" ]; then
  echo "libayatana-appindicator $version already in $prefix"
  exit 0
fi

for tool in curl cmake ninja pkg-config patchelf nm readelf; do
  command -v "$tool" >/dev/null || die "$tool is missing; run \`just setup-linux\`"
done
pkg-config --exists 'dbusmenu-gtk3-0.4 gtk+-3.0 >= 3.24' || die "dbusmenu-gtk3 or GTK headers missing; run \`just setup-linux\`"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

curl -fsSL --retry 3 -o "$work/src.tar.gz" "$url"
echo "$sha256  $work/src.tar.gz" | sha256sum -c --quiet - || die "checksum mismatch for $url"
mkdir "$work/src"
tar -xzf "$work/src.tar.gz" -C "$work/src" --strip-components=1

cmake -S "$work/src" -B "$work/build" -G Ninja \
  -DCMAKE_INSTALL_PREFIX="$prefix" \
  -DFLAVOUR_GTK3=ON \
  -DENABLE_TESTS=OFF \
  -DENABLE_COVERAGE=OFF \
  -DENABLE_GTKDOC=OFF \
  -DENABLE_BINDINGS_VALA=OFF \
  -DENABLE_BINDINGS_MONO=OFF
cmake --build "$work/build" --target ayatana-appindicator3

built=$(readlink -f "$work/build/src/$soname")
readelf -d "$built" | grep -q "(SONAME).*\[$soname\]" || die "the built library's soname is not $soname"
for sym in app_indicator_set_tooltip_title app_indicator_set_tooltip_body; do
  nm -D --defined-only "$built" | awk '{ print $NF }' | grep -qx "$sym" || die "the built library does not export $sym"
done

rm -rf "$prefix"
install -D -m 0644 "$built" "$prefix/lib/$soname"
patchelf --remove-rpath "$prefix/lib/$soname"
# LGPL-2.1 or LGPL-3; the notices travel with the library.
for f in AUTHORS COPYING COPYING.LGPL.2.1 COPYING.GPL.3; do
  install -D -m 0644 "$work/src/$f" "$prefix/share/doc/libayatana-appindicator3/$f"
done
echo "$stamp" >"$prefix/STAMP"
echo "built libayatana-appindicator $version into $prefix"
