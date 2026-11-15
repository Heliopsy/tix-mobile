// SPDX-License-Identifier: AGPL-3.0-or-later

import AppIntents

/// What Siri, Spotlight, Shortcuts and the Action Button offer without setup. Every phrase names the app; the
/// translations are in <lang>.lproj/AppShortcuts.strings, since the app's iOS 15 floor rules out a String Catalog.
@available(iOS 18.0, *)
struct TixAppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: OpenQuickAddIntent(),
      phrases: [
        "Add a task in \(.applicationName)",
        "New \(.applicationName) task",
        "Quick add in \(.applicationName)",
      ],
      shortTitle: "Add a task",
      systemImageName: "plus.circle"
    )
    AppShortcut(
      intent: OpenInboxIntent(),
      phrases: [
        "Open my \(.applicationName) inbox",
        "Show my inbox in \(.applicationName)",
      ],
      shortTitle: "Open inbox",
      systemImageName: "tray"
    )
    AppShortcut(
      intent: OpenMyWorkIntent(),
      phrases: [
        "Show my work in \(.applicationName)",
        "Open my work in \(.applicationName)",
      ],
      shortTitle: "Open my work",
      systemImageName: "checklist"
    )
  }
}
