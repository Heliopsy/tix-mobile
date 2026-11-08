#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Regenerate every app icon and splash image from assets/branding/mark.svg.
#
#   scripts/icons.sh            masters, then every platform
#   scripts/icons.sh masters    only the PNG masters in assets/branding/
#
# Tools: rsvg-convert (librsvg) renders the SVGs and ImageMagick (`magick`, or
# `convert` on ImageMagick 6) flattens, resizes and packs the Windows .ico.
# flutter_launcher_icons writes the Android, iOS and macOS sets and
# flutter_native_splash the splash screens, both from the masters. Windows and
# Linux are done here: the launcher-icons package writes a single-size .ico
# and knows nothing about Linux.
#
# The mark is drawn in a 64-unit box. Each master places that box differently:
#   icon-1024           the mark as is, rounded corners transparent
#   icon-ios-1024       full-bleed opaque square; iOS applies its own mask
#   icon-ios-dark-1024  the glyph on transparent, for iOS 18 dark icons
#   icon-ios-tinted-1024 white glyph on black, for iOS 18 tinted icons
#   icon-macos-1024     Apple's template: an 824 px body inset 100 px, shadowed
#   adaptive-*-1024     Android's 108 dp canvas; the mark's box fills the 72 dp
#                       visible area, so the glyph sits well inside the 66 dp
#                       safe circle
#   splash-*            the mark small enough for Android 12's 768 px circle

set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
brand="$root/assets/branding"
app_id="red.tix.tix_mobile"

if command -v magick >/dev/null; then
  im=(magick)
elif command -v convert >/dev/null; then
  im=(convert)
else
  echo "icons.sh: ImageMagick (magick or convert) is required" >&2
  exit 1
fi
command -v rsvg-convert >/dev/null || {
  echo "icons.sh: rsvg-convert (librsvg) is required" >&2
  exit 1
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

gradient='<linearGradient id="g" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="64" y2="64"><stop offset="0" stop-color="#14b8a6"/><stop offset="1" stop-color="#0f766e"/></linearGradient>'

# glyph STROKE: the tix glyph's two strokes in the 64-unit box.
glyph() {
  printf '<g fill="none" stroke="%s" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"><path d="M26 13 V34 a5 5 0 0 0 8.4 3.6 L48 24"/><path d="M17 24 H35"/></g>' "$1"
}

# svg NAME VIEWBOX BODY: write $tmp/NAME.svg.
svg() {
  printf '<svg xmlns="http://www.w3.org/2000/svg" viewBox="%s"><defs>%s</defs>%s</svg>\n' \
    "$2" "$gradient" "$3" >"$tmp/$1.svg"
}

# render NAME SIZE OUT: rasterise $tmp/NAME.svg to a SIZE px square PNG.
render() {
  rsvg-convert -w "$2" -h "$2" "$tmp/$1.svg" -o "$3"
}

# opaque FILE: drop the alpha channel; the App Store rejects icons with one.
opaque() {
  "${im[@]}" "$1" -background black -alpha remove -alpha off -strip "$1"
}

masters() {
  local mark='<rect width="64" height="64" rx="15" fill="url(#g)"/>'

  svg icon "0 0 64 64" "$mark$(glyph '#fff')"
  render icon 1024 "$brand/icon-1024.png"

  svg ios "0 0 64 64" "<rect width=\"64\" height=\"64\" fill=\"url(#g)\"/>$(glyph '#fff')"
  render ios 1024 "$brand/icon-ios-1024.png"
  opaque "$brand/icon-ios-1024.png"

  svg ios-dark "0 0 64 64" "$(glyph '#2dd4bf')"
  render ios-dark 1024 "$brand/icon-ios-dark-1024.png"

  svg ios-tinted "0 0 64 64" "<rect width=\"64\" height=\"64\" fill=\"#000\"/>$(glyph '#fff')"
  render ios-tinted 1024 "$brand/icon-ios-tinted-1024.png"
  opaque "$brand/icon-ios-tinted-1024.png"

  # 1024 px is 64 units here, so the 824 px body is 51.5 units at 6.25 in.
  # Apple's corner radius on that body is 185.4 px, 11.5875 units.
  svg macos "0 0 64 64" "<filter id=\"s\" x=\"-10%\" y=\"-10%\" width=\"120%\" height=\"130%\"><feDropShadow dx=\"0\" dy=\"0.75\" stdDeviation=\"0.9\" flood-opacity=\"0.3\"/></filter><g filter=\"url(#s)\"><svg x=\"6.25\" y=\"6.25\" width=\"51.5\" height=\"51.5\" viewBox=\"0 0 64 64\"><defs>$gradient</defs><rect width=\"64\" height=\"64\" rx=\"14.4\" fill=\"url(#g)\"/>$(glyph '#fff')</svg></g>"
  render macos 1024 "$brand/icon-macos-1024.png"

  # 108 dp shows 72 dp, so the 64-unit box widens to 96 units, 16 each side.
  svg adaptive-fg "-16 -16 96 96" "$(glyph '#fff')"
  render adaptive-fg 1024 "$brand/adaptive-foreground-1024.png"
  svg adaptive-bg "-16 -16 96 96" '<rect x="-16" y="-16" width="96" height="96" fill="url(#g)"/>'
  render adaptive-bg 1024 "$brand/adaptive-background-1024.png"
  opaque "$brand/adaptive-background-1024.png"

  # flutter_native_splash reads the legacy image as xxxhdpi: 384 px is 96 dp.
  render icon 384 "$brand/splash-384.png"
  # Android 12 draws a 1152 px canvas clipped to a 768 px circle; a 520 px
  # square has a 735 px diagonal, so its corners stay inside.
  svg splash-12 "0 0 1152 1152" "<svg x=\"316\" y=\"316\" width=\"520\" height=\"520\" viewBox=\"0 0 64 64\"><defs>$gradient</defs>$mark$(glyph '#fff')</svg>"
  render splash-12 1152 "$brand/splash-android12-1152.png"

  # The in-app mark, at 1x, 2x and 3x of its 64 dp default size.
  mkdir -p "$brand/app/2.0x" "$brand/app/3.0x"
  render icon 64 "$brand/app/mark.png"
  render icon 128 "$brand/app/2.0x/mark.png"
  render icon 192 "$brand/app/3.0x/mark.png"
}

windows() {
  local sizes=(16 20 24 32 40 48 64 96 128 256) frames=() s
  for s in "${sizes[@]}"; do
    render icon "$s" "$tmp/win-$s.png"
    frames+=("$tmp/win-$s.png")
  done
  "${im[@]}" "${frames[@]}" -strip "$root/windows/runner/resources/app_icon.ico"
}

linux() {
  local hicolor="$root/linux/packaging/icons/hicolor" s
  for s in 16 24 32 48 64 128 256 512; do
    mkdir -p "$hicolor/${s}x$s/apps"
    render icon "$s" "$hicolor/${s}x$s/apps/$app_id.png"
  done
  mkdir -p "$hicolor/scalable/apps"
  cp "$tmp/icon.svg" "$hicolor/scalable/apps/$app_id.svg"
}

masters
if [[ "${1:-}" == masters ]]; then
  exit 0
fi

cd "$root"
dart run flutter_launcher_icons
# flutter_launcher_icons 0.14 rewrites every ASSETCATALOG_* setting to the icon
# name, including this boolean one, which Xcode then rejects.
sed -i.bak 's/\(ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = \)AppIcon;/\1YES;/' \
  ios/Runner.xcodeproj/project.pbxproj
rm ios/Runner.xcodeproj/project.pbxproj.bak
dart run flutter_native_splash:create
windows
linux
