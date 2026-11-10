# Proposal

## Why

Linux, Windows and macOS builds exist, but the desktop app is only a window. Closing it stops sync and
notifications, there is no tray icon to come back from, a second launch starts a second copy, and nothing outside
the window reaches quick add or the inbox. Android got Quick Settings tiles, notification actions and pinned
shortcuts for exactly this; the desktop should have the equivalent. `docs/widgets.md` already says the tray is the
desktop answer on Linux, and there is no tray.

## What Changes

- A tray (menu bar on macOS) icon on all three desktops with **Open tix**, **Quick add**, **Inbox** with the unread
  count, the active context and **Quit**. Clicking the icon shows or hides the window where the platform reports
  clicks (Windows, macOS); Linux trays open the menu. The tooltip carries the unread count, and so does the macOS
  Dock badge. Quick add and Inbox go through the same `tix://quick-add` and `tix://inbox` links as the Android
  tiles, and the count is the inbox's own.
- **Close to tray**: closing the window hides it while sync and notifications carry on, and Quit really quits. A
  setting, on by default where a tray shows and off (and explained) where none does, such as GNOME without the
  AppIndicator extension.
- **Start at login**, opt in, through the Run key on Windows, `SMAppService` on macOS 13 and later, an autostart
  entry on Linux and the Background portal inside Flatpak. A login launch starts hidden when a tray is there.
- **A global quick-add hotkey**, Ctrl+Shift+Space (⌃⇧Space on a Mac), opt in, on Windows, macOS and Linux under
  X11. Wayland has no global hotkeys, so the setting is not shown there.
- **One instance**: a second launch brings the running window forward. A `tix://` link opened on Linux or macOS,
  or passed on the Windows command line, does the same and is followed.

## Impact

- Capabilities: new `desktop-integration`.
- New dependencies, desktop only: `tray_manager` 0.5 and `window_manager` 0.5 (MIT, leanflutter), held below 0.6,
  where both move to `nativeapi`, which builds a C++ library for every target including Android and iOS. They pull
  in `menu_base`, `shortid` (BSD-3-Clause) and `screen_retriever`. Linux builds and runs need
  libayatana-appindicator3; Flatpak adds it from Flathub's shared modules and talks to
  `org.kde.StatusNotifierWatcher`.
- Start at login, the hotkey, single instance and links are runner code, not packages: `linux/runner/desktop.cc`,
  `windows/runner/flutter_window.cpp` and `main.cpp`, `macos/Runner/MainFlutterWindow.swift`, over two channels,
  `tix/links` (as on Android) and `tix/desktop`.
- Dart: `core/platform/desktop.dart`, `core/desktop/desktop_state.dart`, `core/widgets/desktop_host.dart`, a Desktop
  section in Settings, new strings in English, Bulgarian, French and German.
- Phones are untouched: the plugins declare desktop platforms only, and nothing calls them off the desktop.
