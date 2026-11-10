# Delta for desktop-integration

## MODIFIED Requirements

### Requirement: The Linux tarball carries the tray libraries

The Linux release tarball SHALL contain libayatana-appindicator3 0.6 or later, built from upstream's release, and the libdbusmenu libraries it loads, and SHALL load them from its own `lib/` directory, so it starts on a distro that lacks them and has the tooltip API whatever version the distro ships. It SHALL NOT bundle glib, GTK or libc.

#### Scenario: Fedora without the appindicator package

- **WHEN** the x64 tarball is unpacked on Fedora 43 KDE, which has no libayatana-appindicator3 installed, and `tix_mobile` is started
- **THEN** the window opens and the tray icon shows

#### Scenario: A build that would load the system copy

- **WHEN** a CI or release build produces a Linux bundle in which `ldd` resolves any ayatana or dbusmenu library outside the bundle's `lib/`
- **THEN** the job fails

#### Scenario: A bundle without the tooltip API

- **WHEN** a CI or release build produces a Linux bundle whose libayatana-appindicator3 does not export `app_indicator_set_tooltip_title` and `app_indicator_set_tooltip_body`
- **THEN** the job fails
