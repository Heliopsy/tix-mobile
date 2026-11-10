# Proposal

## Why

Since 0.11.0 the Linux tarball links the tray plugin against libayatana-appindicator3, which Ubuntu and Debian
ship but Fedora, Arch and openSUSE mostly do not install. There the binary stops before the window opens:
`error while loading shared libraries: libayatana-appindicator3.so.1`. Reported on Fedora 43 KDE under Wayland;
with the libraries present the app runs fine, Wayland included.

## What Changes

- The release and CI Linux jobs copy libayatana-appindicator3, libayatana-indicator3, libayatana-ido3,
  libdbusmenu-glib and libdbusmenu-gtk3 into the bundle's `lib/`, under their sonames, with their Debian copyright
  files under `share/doc/`. glib, GTK and libc stay the system's.
- The tray plugin and the copied libraries get `$ORIGIN` as their runpath. The binary's `$ORIGIN/lib` runpath does
  not cover a plugin's dependencies, so copying alone would still load the system copies or fail.
- A CI step runs `ldd` on the bundled binary and fails while any of those libraries resolves outside `bundle/lib`.
- README and docs stop listing libayatana-appindicator3 as something to install, and say the icon needs a
  StatusNotifier host (KDE has one, GNOME needs the AppIndicator extension).

## Impact

- `scripts/bundle-linux-libs.sh`, a `just linux-libs` recipe, `patchelf` in `just setup-linux`.
- `.github/workflows/release.yaml` and `.github/workflows/ci.yaml`, Linux jobs only.
- The bundle grows by about 560 KB (x64). Flatpak is unchanged; it takes these libraries from Flathub's shared modules.
- Capability `desktop-integration`: one added requirement.
