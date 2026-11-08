# Proposal

## Why

People check what is due and what changed many times a day, and opening the app for that is slow. A home screen
widget answers at a glance, and a tick from it finishes a task without opening anything. The roadmap has had the
item since the first slice; the offline cache and live updates it waited on have landed.

## What Changes

- Four native widgets: My work (next tasks, tick to complete), Inbox (unread count and latest items), Quick add
  (one tap to the sheet) and Project (a picked project's open tasks by status). Glance on Android, WidgetKit on iOS
  17+ and macOS 14+, with the iOS lock screen showing the inbox count.
- The app writes a small versioned JSON snapshot per widget and context to widget storage, after events and
  mutations, on resume, and from a periodic background refresh. No credential is ever written there.
- Ticks queue in widget storage and are run by the app's own Dart code in a headless engine, or the next time the
  app opens.
- Widgets follow the active context or are pinned to one when added, and say which. Local instances are never
  started from the background; their widgets show the snapshot's age.
- A setting, on by default, keeps the lock screen to counts only.
- Windows and Linux: no widgets; the plan is in `docs/widgets.md`.

## Impact

- Capabilities: `home-widgets` is new; `app-settings` gains the widget privacy setting.
- New dependency: `home_widget` (Android and iOS; macOS uses a small channel of our own). It brings Glance and
  WorkManager on Android.
- Native: Glance widgets, a configuration activity and a worker on Android; a WidgetKit extension target and an App
  Group on iOS and macOS, a background refresh task on iOS. Release signing needs the extension and the App Group
  on the Apple provisioning profiles.
