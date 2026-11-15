# iOS Controls and App Shortcuts

## Why

An iPhone tester on TestFlight found no quick way to add a task and nothing in Control Center, where Android has
Quick Settings tiles for Quick add and Inbox. The in-app quick add button, the home-screen widgets and the icon's
quick actions all ship on iOS (checked against the 0.19.0 build: the IPA embeds `TixWidgets` and fastlane checks its
signature), but iOS has no Control Center control, no Lock Screen or Action Button entry and nothing Siri or
Spotlight can run.

## What Changes

- Two iOS 18 controls in the `TixWidgets` extension, for Control Center, the Lock Screen and the Action Button:
  **Quick add** opens the quick add sheet, and **Inbox** opens the inbox and shows the active context's unread count
  from the inbox widget snapshot.
- Three App Intents with an `AppShortcutsProvider`, for Siri, Spotlight, Shortcuts and the Action Button: **Add a
  task** (with an optional title that fills in quick add), **Open inbox** and **Open my work**. Every Siri phrase
  names the app. English, Bulgarian, German and French.
- The `tixwidget://quickadd` link takes an optional `text`, the line quick add opens with.
- A widget test at iPhone size on iOS, with notch and home-indicator insets, guards the shell's quick add button and
  a project's New task button.

## Non-goals

- A Live Activity. Without ActivityKit push updates from the server, an activity could only be updated while the app
  runs in the foreground, so on the Lock Screen it would show stale numbers. See design.md.
- Creating a task straight from Siri without opening the app. Quick add stays the one place a line is sent, with
  `"parse": true`.

## Impact

- `ios/TixWidgets/`: `Controls.swift`, `OpenIntents.swift`; `Links` moves into `WidgetStore.swift`.
- `ios/Runner/`: `TixAppShortcuts.swift`, `AppShortcuts.strings`, control reloads in `AppDelegate.swift`.
- `ios/Runner.xcodeproj`: target membership for the new files.
- `lib/src/features/widgets/application/widget_sync.dart`: `text` on the quickadd link.
- Docs: `docs/widgets.md`.
