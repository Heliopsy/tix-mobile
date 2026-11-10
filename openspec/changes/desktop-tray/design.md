# Design

## Context

Android's tiles and pinned shortcuts open `tix://` links that `DeepLinkHost` follows, over the `tix/links` channel
`MainActivity` answers. The inbox already keeps an unread count (`inboxUnreadProvider`) that the navigation badge
watches. Desktop runners are the stock Flutter ones with an icon and a title.

## Decisions

### Packages: the 0.5 generation of tray_manager and window_manager

`tray_manager` and `window_manager` are the maintained choice (leanflutter, MIT, every desktop). Their newest
releases (0.8 and 0.6, from September to November 2026) moved onto `nativeapi`, whose `cnativeapi` build hook
compiles a C++ library for every target the app builds, Android and iOS included, and which is weeks old. The 0.5
line is a plain federated plugin that declares Linux, macOS and Windows only, so phones get no native code. Both
are pinned below 0.6 in `pubspec.yaml` with the reason.

`launch_at_startup` and `hotkey_manager` were not taken. The first needs hand-written native code on macOS anyway,
writes a path inside the sandbox under Flatpak, and pulls `win32_registry` for one registry value. The second's
desktop line (0.2) has not moved since 2024 and needs keybinder-3.0 on Linux, a third native library for Flatpak.
Each is a few dozen lines in the runners instead.

### One channel for what packages do not do

`tix/desktop` answers `capabilities` (tray, autostart, hotkey, and whether this launch came from the login item),
`autostart`, `setAutostart`, `setHotkey`, and calls `hotkey` into Dart. `PluginDesktopShell.start` asks it first; a
`MissingPluginException` (a test, a phone) answers `DesktopCaps.none` and no plugin is touched.

- **Tray detection on Linux.** libappindicator draws nothing when no StatusNotifierWatcher runs (plain GNOME), and
  says nothing either. The runner asks the session bus `NameHasOwner("org.kde.StatusNotifierWatcher")`. Without
  one, close to tray is forced off and the setting explains why, so the window can never vanish with no way back.
- **The icon.** Linux passes the bundle's `data/icon.png`, or under Flatpak the icon name `red.tix.tix_mobile`,
  since the host cannot see sandbox paths. Windows reads `app_icon.ico`, installed into `data/` by CMake. macOS
  takes a template image from `assets/branding/tray/menubar.png`, drawn by `scripts/icons.sh`.
- **Start at login.** Linux writes `~/.config/autostart/red.tix.tix_mobile.desktop`; Flatpak cannot, so it calls
  the Background portal's `RequestBackground` with `autostart`, and as the portal cannot be asked afterwards, the
  choice is kept in preferences. Windows writes `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`. macOS uses
  `SMAppService.mainApp` (13 and later; earlier versions do not offer it). Linux and Windows start with
  `--background`, which keeps the window hidden; Dart shows it if there is no tray or close to tray is off.
- **Hotkey.** `RegisterHotKey` on Windows, Carbon's `RegisterEventHotKey` on macOS (no accessibility prompt),
  `XGrabKey` on the X11 root window on Linux, with each NumLock and CapsLock combination. A key another app holds
  answers false and the switch stays off with a toast. Wayland offers nothing, so `hotkey` is false there and the
  setting is hidden. The key is fixed at Ctrl+Shift+Space: Ctrl+Alt combinations are AltGr on many Windows
  layouts, and recording a custom key is more UI than the feature is worth today.

### Single instance in the runners

- **Linux.** The GTK application drops `G_APPLICATION_NON_UNIQUE` for `G_APPLICATION_HANDLES_OPEN`. A second
  launch registers, finds itself remote, sends `activate` (or `open` with a `tix:` argument) to the first and
  exits. The first's `activate` shows its existing window instead of building another. The desktop entry declares
  `x-scheme-handler/tix`.
- **Windows.** A named mutex; a second process finds the window by a property the first sets (every Flutter runner
  shares the class name), allows it the foreground, sends `WM_COPYDATA` with the link and exits.
- **macOS.** LaunchServices already keeps one instance. `CFBundleURLTypes` declares `tix`, and the Dock icon
  brings a hidden window back.

Links arrive on `tix/links` exactly as on Android (`take`, then `opened` while running), so `DeepLinkHost` follows
them unchanged. Windows has no protocol registration, which needs an installer or MSIX packaging.

### Tray state from providers, menu picks as links

`DesktopHost` sits in `App`'s builder, above the router, so the tray exists signed out too. It builds the menu from
`trayMenu(l10n, unread, context)` and pushes it when it changes. The unread count is `trayUnreadProvider`, which
`main` overrides with `inboxUnreadProvider` (core cannot import the inbox); it is watched only while someone is
signed in, so nothing counts with no session. Quick add, Inbox and the hotkey show the window and hand
`tix://quick-add` or `tix://inbox` to `DeepLinkIntake.deliver`, which `DeepLinkHost` follows, or keeps until
someone signs in.

Close to tray is `window_manager`'s prevent-close: on a close request the window hides. Quit drops the icon, lifts
prevent-close and destroys the window. A tapped notification shows the window too.

## Risks

- The Linux bundle now needs libayatana-appindicator3 at run time. Ubuntu ships it; Fedora and Arch need a package.
  The README and the development docs say so.
- Nothing here is run by CI beyond compiling the runners. The hand checks are in the pull request.
