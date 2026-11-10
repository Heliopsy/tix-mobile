#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Ship the tray icon's libraries inside the Linux bundle, so the tarball starts
# on distros without libayatana-appindicator3 (Fedora, Arch, openSUSE).
#
#   AYATANA_PREFIX=P scripts/bundle-linux-libs.sh copy DIR
#       copy them into DIR/lib and point the libraries that load them there.
#       libayatana-appindicator3 comes from P, which scripts/build-ayatana.sh
#       built; the rest from the system.
#   scripts/bundle-linux-libs.sh check DIR
#       fail unless every one of them resolves inside DIR/lib, and the bundled
#       libayatana-appindicator3 has the tooltip API (0.6.0 and later)
#
# The distro's libayatana-appindicator3 is not shipped: Ubuntu 24.04 has 0.5.x,
# without the tooltip, and the bundled copy wins over a newer one on the user's
# machine. The soname is the same in 0.5 and 0.6.
#
# Only the tray stack is bundled. glib, GTK and libc stay the system's: every
# desktop that can show the window has them, and a second copy of GTK in one
# process breaks.
#
# The binary's $ORIGIN/lib runpath does not reach these: DT_RUNPATH covers only
# an object's own direct dependencies, and libtray_manager_plugin.so is the one
# that needs them (with the build machine's path as its runpath). So the copy
# step sets $ORIGIN on the plugin and on each copied library with patchelf.

set -euo pipefail

# A literal $ORIGIN for ld.so to expand, not the shell.
# shellcheck disable=SC2016
origin='$ORIGIN'

die() { echo "bundle-linux-libs: $*" >&2; exit 1; }

# The tray stack: libayatana-appindicator3 and what it pulls in beyond GTK.
pattern='^lib(ayatana-appindicator3|ayatana-indicator3|ayatana-ido3-[0-9.]+|dbusmenu-glib|dbusmenu-gtk3)\.so\.'
appindicator=libayatana-appindicator3.so.1
# What a 0.6 library exports and 0.5 does not; desktop.cc sets the matching
# tooltip-title and tooltip-body properties.
tooltip_syms='app_indicator_set_tooltip_title app_indicator_set_tooltip_body'

# The tray libraries the binary loads, as "SONAME PATH" lines, PATH being
# "not" when ldd found none. LD_LIBRARY_PATH is the second argument, empty by
# default, so the answer is what a user's machine would see, give or take the
# system copies.
tray_libs() {
  local out
  out=$(LD_LIBRARY_PATH=${2:-} ldd "$1") || die "ldd $1 failed"
  awk -v re="$pattern" '$1 ~ re { print $1, $3 }' <<<"$out"
}

# Fail unless $1 exports every tooltip symbol.
has_tooltip() {
  local syms sym
  syms=$(nm -D --defined-only "$1" | awk '{ print $NF }') || die "nm $1 failed"
  for sym in $tooltip_syms; do
    grep -qx "$sym" <<<"$syms" || { echo "$1 does not export $sym" >&2; return 1; }
  done
}

copy() {
  local bundle=$1 bin=$1/tix_mobile prefix=${AYATANA_PREFIX:-} soname path real pkg n=0
  [ -x "$bin" ] || die "no executable at $bin"
  command -v patchelf >/dev/null || die "patchelf is missing; run \`just setup-linux\`"
  [ -n "$prefix" ] || die "AYATANA_PREFIX is not set; build libayatana-appindicator with \`just linux-ayatana\`"
  prefix=$(realpath "$prefix")
  [ -f "$prefix/lib/$appindicator" ] || die "no $appindicator in $prefix/lib; run \`just linux-ayatana\`"
  has_tooltip "$prefix/lib/$appindicator" || die "$prefix/lib/$appindicator has no tooltip API; is it 0.6 or later?"
  [ -n "$(tray_libs "$bin" "$prefix/lib")" ] || die "the binary loads no tray library; is tray_manager still a dependency?"
  while read -r soname path; do
    [ "$path" != not ] || die "$soname: not found on this machine; run \`just setup-linux\`"
    real=$(readlink -f "$path")
    case $real in "$(realpath "$bundle/lib")"/*) continue ;; esac
    if [ "$soname" = "$appindicator" ]; then
      case $real in "$prefix"/*) ;; *) die "$soname resolves to $real, not to the build in $prefix" ;; esac
    fi
    install -m 0644 "$real" "$bundle/lib/$soname"
    patchelf --set-rpath "$origin" "$bundle/lib/$soname"
    echo "bundled $soname from $real"
    n=$((n + 1))
    # The libraries are LGPL and GPL; their copyright notices travel with them.
    if [ "$soname" = "$appindicator" ]; then
      mkdir -p "$bundle/share/doc"
      cp -R "$prefix/share/doc/." "$bundle/share/doc/"
    elif pkg=$({ dpkg -S "$real" || dpkg -S "${real#/usr}"; } 2>/dev/null | cut -d: -f1 | head -1) && [ -n "$pkg" ] \
      && [ -f "/usr/share/doc/$pkg/copyright" ]; then
      install -D -m 0644 "/usr/share/doc/$pkg/copyright" "$bundle/share/doc/$pkg/copyright"
    fi
  done < <(tray_libs "$bin" "$prefix/lib")
  echo "copied $n libraries"

  local lib
  for lib in "$bundle"/lib/*.so; do
    if readelf -d "$lib" | grep -Eq '\(NEEDED\).*\[lib(ayatana|dbusmenu)-'; then
      patchelf --set-rpath "$origin" "$lib"
      echo "runpath \$ORIGIN on $(basename "$lib")"
    fi
  done
}

check() {
  local bundle=$1 bin=$1/tix_mobile soname path libdir bad=0 n=0
  [ -x "$bin" ] || die "no executable at $bin"
  libdir=$(realpath "$bundle/lib")
  while read -r soname path; do
    n=$((n + 1))
    if [ "$path" = not ]; then
      echo "$soname: not found" >&2
      bad=1
    elif [ "$(dirname "$(realpath "$path")")" != "$libdir" ]; then
      echo "$soname: resolves to $path, outside $libdir" >&2
      bad=1
    else
      echo "$soname => $path"
    fi
  done < <(tray_libs "$bin")
  [ "$n" -gt 0 ] || die "ldd lists no tray library at all; nothing to check"
  if [ ! -f "$libdir/$appindicator" ]; then
    echo "$appindicator: not in $libdir" >&2
    bad=1
  elif has_tooltip "$libdir/$appindicator"; then
    echo "$appindicator exports $tooltip_syms"
  else
    echo "$appindicator: no tooltip API; the bundle carries the distro's 0.5 copy, not scripts/build-ayatana.sh's" >&2
    bad=1
  fi
  [ "$bad" = 0 ] || die "the bundle's tray libraries are not the ones it should ship; run \`just linux-libs copy $bundle\`"
  echo "all $n tray libraries load from the bundle"
}

[ $# -eq 2 ] || die "usage: $0 copy|check BUNDLE_DIR"
[ -d "$2" ] || die "no bundle directory at $2"
case $1 in
  copy) copy "$2" ;;
  check) check "$2" ;;
  *) die "unknown mode $1; want copy or check" ;;
esac
