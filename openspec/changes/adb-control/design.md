# Design

## Context

Android gives a shell two ways into an app: `dumpsys` reaches a Service's `dump()`, and `am broadcast` reaches a
receiver. Both run native code, while the state worth reading (sessions, live updates, the outbox) lives in Dart
providers. Widget links already reach the app through `home_widget`, with Flutter's own deep linking turned off so
`tixwidget://` URIs never become router paths.

## Decisions

### Dart decides, Kotlin carries

`AdbHub` passes `snapshot` and `command` calls over the `tix/adb` channel and prints whatever comes back. Parsing,
gating, the report and its redaction are Dart (`core/platform/adb_commands.dart`, `adb_snapshot.dart`), so they
are unit tested, and Kotlin stays a few hundred lines with one JVM test for its fallback text.

### The app's engine first, else a headless one

While the app is open its engine answers. Otherwise `AdbHub` starts a headless engine at `adbHeadlessMain`, the
way a widget tick wakes Dart, which reads only what is stored: no session, no live updates, no local engine. A
command that needs the session (switch, quick-add, sync-now, reconnect, the engine, clear-cache) answers
`needsApp` there, and `AdbHub` brings the activity up and sends it again. `open` answers with the link, which
`AdbHub` opens as a VIEW intent.

### dumpsys writes after `dump()` returns

The system calls `dump()` on the main thread and waits about two seconds for the pipe to close. Dart answers on the
main thread too, so `dump()` duplicates the descriptor, returns, and writes when Dart answers or after 1.5 s with
the native fallback (version and the widget index). A cold headless start rarely fits in that, so the fallback
says to run it again; the engine then stays up for a minute. A service is dumped only while it runs, so the app
binds it for the life of its process, from `MainActivity` and from the receiver.

### Links over a channel, deep linking still off

Turning Flutter deep linking on would push `tixwidget://open?...` to the router as a path. Instead `MainActivity`
keeps the latest `tix://` VIEW intent, like a share, and hands it over `tix/links`. `DeepLinkHost`, mounted around
the signed-in shell next to the widget and quick-add hosts, parses it and navigates with go_router. A link that
arrives signed out waits until a context is active.

### Security

The receiver is exported with `android:permission="android.permission.DUMP"`: the shell has it, ordinary apps
cannot get it. The service is not exported. Commands never take credentials (an extra named like one is refused)
and every reply goes through `redactSecrets` with the saved secrets, so neither a token nor a URL's query is
printed. Release builds run commands only with the device-local setting on; reading (help, dump, dumpsys) and
links stay available, since they print nothing secret and change nothing.

### iOS

Not done. iOS would need the URL type in Info.plist and forwarding from the scene delegate, which `home_widget`
already hooks for widget URLs; that is a change to make with a device at hand. `docs/adb.md` says Android only.
