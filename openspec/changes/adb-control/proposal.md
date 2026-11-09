# Proposal

## Why

Testing the app on a phone means tapping through it to see what state it is in, and there is no way to script it.
A developer at a laptop with the phone on USB wants to read the live status and the outbox without opening sheets,
jump straight to a task, and flip the theme or context from a shell. Nothing on Android offered that, and the
`tix://` scheme was not claimed, so a link in a note or a test could not open a screen either.

## What Changes

- `adb shell dumpsys activity service red.tix.tix_mobile/.adb.AdbService [section]` prints the app's state: the
  version and build, the saved contexts (names and hosts), the live status with the redacted connection details
  report, the outbox and conflicts per context, the local engine, the theme and the language. Sections: `all`,
  `connection`, `outbox`, `engine`, `contexts`.
- `tix://` links open screens: inbox, my work, tasks, projects, a project, a task, settings, about and the
  connection details, with an optional `?context=` that switches first and asks when the name fits several
  contexts. An unknown link says so and goes home. Links only navigate. Android only.
- `adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd <name>` runs commands:
  reconnect, sync-now, switch, quick-add, open, engine-stop, engine-start, clear-cache, theme, locale, dump and
  help. The receiver accepts only senders holding DUMP. A release build runs anything beyond help and dump only
  when Settings, Advanced, **Allow control over ADB** is on (off by default, this device only).
- `docs/adb.md` with every command, the sections, the links and the security model.

## Impact

- New capability `adb-control`; changed `app-settings` (the Advanced switch).
- Android: `AdbService`, `AdbReceiver`, `AdbHub` (channel `tix/adb`, the headless `adbHeadlessMain` entrypoint),
  a VIEW intent filter on `tix` and the `tix/links` channel in `MainActivity`. Flutter deep linking stays off, so
  widget links and share intake are untouched.
- Dart: `core/platform/adb_*`, `core/platform/deep_links.dart`, `core/session/context_match.dart`,
  `core/widgets/deep_link_host.dart`, mounted around the signed-in shell.
- New strings in English, French, German and Bulgarian. No new dependency.
