# Tasks

## 1. Spec and dependencies

- [x] 1.1 `desktop-integration` spec
- [x] 1.2 `tray_manager` and `window_manager` below 0.6, licence and platform check, Linux deps in `just setup-linux`

## 2. Dart

- [x] 2.1 `DesktopShell` and `PluginDesktopShell` over the plugins and `tix/desktop`; `DeepLinkIntake.deliver`
- [x] 2.2 Caps, tray menu, close to tray, start at login and hotkey providers; settings stored per device; tests
- [x] 2.3 `DesktopHost` keeps the tray in step and turns picks and the hotkey into links; widget tests
- [x] 2.4 Desktop section in Settings, hidden pieces per platform; strings in four languages; tests

## 3. Runners

- [x] 3.1 Linux: unique GApplication, `tix/links`, tray detection, autostart file and portal, X11 hotkey
- [x] 3.2 Windows: mutex and `WM_COPYDATA`, `tix/links`, Run key, `RegisterHotKey`, the icon in `data/`
- [x] 3.3 macOS: `tix` scheme, Dock reopen, `SMAppService`, Carbon hotkey

## 4. Packaging and docs

- [x] 4.1 Flatpak: appindicator from shared modules, `org.kde.StatusNotifierWatcher`; desktop entry `x-scheme-handler/tix`
- [x] 4.2 README, `docs/development.md`, `docs/releasing.md`, `docs/widgets.md`
