# Proposal

## Why

The tray tooltip on Linux needs libayatana-appindicator 0.6.0 or later, which added `tooltip-title` and
`tooltip-body`. The tarball bundles the runner's Ubuntu 24.04 copy, 0.5.93, and the bundled copy loads ahead of the
system's, so even on Fedora 43, which ships 0.6.0, KDE shows only the title on hover.

## What Changes

- `scripts/build-ayatana.sh` downloads libayatana-appindicator 0.6.1 by tag, checks a pinned SHA-256, and builds
  only the library with cmake (no introspection, Vala, Mono, tests or docs) into `build/ayatana`. `just
  linux-ayatana` runs it; CI caches the prefix by version, runner image, architecture and script.
- `just linux-libs copy` bundles that build instead of the system's copy, with upstream's licence files under
  `share/doc/libayatana-appindicator3/`. libayatana-indicator3, ayatana-ido3 and libdbusmenu
  still come from the system: the tray plugin links them directly.
- `just linux-libs check` also fails unless the bundled library exports `app_indicator_set_tooltip_title` and
  `app_indicator_set_tooltip_body`.
- `just setup-linux` adds `libdbusmenu-gtk3-dev` and `curl`.

## Impact

- `scripts/build-ayatana.sh`, `scripts/bundle-linux-libs.sh`, `justfile`, the Linux jobs in `ci.yaml` and
  `release.yaml`, README and docs.
- The app still compiles against Ubuntu's 0.5 headers; the soname `libayatana-appindicator3.so.1` is unchanged.
- Flatpak is unchanged.
- Capability `desktop-integration`: one modified requirement.
