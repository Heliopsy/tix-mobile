# Design

## Context

Widgets cannot run Flutter. On Android a Glance widget runs in the app's process but outside any Flutter engine;
on Apple platforms a widget is a separate extension process. Both can read storage the app shares with them and
can wake the app's code in limited ways.

## Decisions

### Native UI, one JSON contract

Each platform draws its widgets natively from the same JSON (`docs/widgets.md`). The app does the work that needs
the server's knowledge (sorting, workflow states, accent resolution, translated labels) and the widget only
draws. Native code holds the fixed design tokens; only the tenant accent and project colours travel in the
snapshot.

### Headless Dart for ticks and refresh, with a queue

A tick appends to a queue in widget storage and hides the task at once. The widget then wakes Dart: `home_widget`'s
background receiver on Android, the App Intent in the app process on iOS, a Darwin notification to the running
app on macOS. Dart drains the queue with the app's session code, reading the credential from secure storage.
Alternatives: queue only (a tick reaches the server whenever the app next opens, which can be days), or native
HTTP clients (a second implementation of auth, workflows and errors per platform, and a token in native reach).
The queue stays as the fallback for every case the headless run cannot handle.

### No credential in widget storage

Snapshot types carry no field for a secret, the context is named by instance and tenant only, and a test fails if
a token appears in anything the bridge receives.

### Local instances stay cold

The background runner skips local contexts. A local context's snapshot is refreshed only while the app runs it.

### Configuration

Android uses a small native activity rather than the Flutter app, so adding a widget does not boot the whole app.
Apple platforms use App Intent configuration. Both read a catalog of contexts and projects from the index, and
record what configured widgets need in `tix.widget.wanted`, which the app reads to decide which contexts and
projects to write.

### macOS without home_widget

`home_widget` has no macOS implementation, so a `tix/widgets` channel in the runner writes the App Group defaults
and reloads timelines. The Dart side hides both behind `WidgetBridge`.

### Windows and Linux

Skipped. The Windows widgets board needs a packaged COM provider (MSIX identity); Linux has no common host.

## Risks

- Interactive widgets on iOS run their intent in the app process only through `ForegroundContinuableIntent`, which
  `home_widget` relies on; if iOS runs it in the extension instead, the tick still queues and runs on next open.
- iOS keychain items are unreadable while the phone is locked; ticks then wait.
- None of the native widgets run in CI; CI compiles them.
