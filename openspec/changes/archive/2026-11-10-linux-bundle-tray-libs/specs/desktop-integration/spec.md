# desktop-integration

## ADDED Requirements

### Requirement: The Linux tarball carries the tray libraries

The Linux release tarball SHALL contain libayatana-appindicator3 and the libayatana-indicator3, libayatana-ido3 and libdbusmenu libraries it loads, and SHALL load them from its own `lib/` directory, so it starts on a distro that lacks them. It SHALL NOT bundle glib, GTK or libc.

#### Scenario: Fedora without the appindicator package

- **WHEN** the x64 tarball is unpacked on Fedora 43 KDE, which has no libayatana-appindicator3 installed, and `tix_mobile` is started
- **THEN** the window opens and the tray icon shows

#### Scenario: A build that would load the system copy

- **WHEN** a CI or release build produces a Linux bundle in which `ldd` resolves any ayatana or dbusmenu library outside the bundle's `lib/`
- **THEN** the job fails
