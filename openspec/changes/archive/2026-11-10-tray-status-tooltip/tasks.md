# Tasks

## 1. Status

- [x] 1.1 `TrayStatus`, `trayStatusLines` and `fitTrayTooltip` in `core/desktop/tray_status.dart`, with unit tests
- [x] 1.2 `trayStatusProvider` from the session, context directory, live status, offline sync, outbox and inbox count
- [x] 1.3 Strings in en, de, fr and bg; `trayTooltip` removed

## 2. Tray

- [x] 2.1 `DesktopShell.setTrayStatus`; the tooltip leaves `TrayMenu`
- [x] 2.2 `DesktopHost` sends it throttled to two seconds and refreshes it every minute, with a host test
- [x] 2.3 Linux runner: find the AppIndicator through a `new-status` emission hook and set title and tooltip on `setTrayStatus`
