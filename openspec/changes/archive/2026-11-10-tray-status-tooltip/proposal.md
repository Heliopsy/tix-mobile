# Proposal

## Why

Hovering the tray icon shows "tix" or "tix: 4 unread" on Windows and macOS, and on KDE only the app's name, because
tray_manager has no tooltip on Linux. The tray is where a desktop user glances to see whether tix is connected,
whether it has synced and whether writes are stuck in the outbox. All of that is already known to the app.

## What Changes

- The tray icon's hover text becomes a short status: a headline with the number of instances, one line per
  instance (the active one first) with live, syncing, offline, when it last synced and how many changes are
  queued, and the active context's unread inbox count.
- The text is built by a pure function from a `TrayStatus` value, which a provider assembles from the session,
  the context directory, live status, offline sync, the outbox and the inbox count.
- The tray host pushes it separately from the menu, at most once every two seconds, and once a minute so
  relative times stay right.
- Windows and macOS get it through tray_manager's `setToolTip`, cut to Windows' 127 characters by dropping
  instance lines.
- Linux sets the AppIndicator's title and, where libayatana-appindicator has tooltip support (0.6.0 and later),
  its tooltip title and body, through the runner's `tix/desktop` channel. tray_manager has neither on Linux.
- Strings in en, de, fr and bg, with plural forms. The old `trayTooltip` string goes.

## Impact

- `lib/src/core/desktop/tray_status.dart` (new), `desktop_host.dart`, `desktop.dart`, `desktop_state.dart`.
- `linux/runner/desktop.cc` and its CMake target (links `${CMAKE_DL_LIBS}`).
- Capability `desktop-integration`: one added requirement.
