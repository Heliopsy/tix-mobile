# Design

## Diagnosis of the report

- The phone shell draws a quick add button (`shell.quickAdd`) beside the context switcher above the navigation bar,
  and a project's task screen has a New task floating button. A widget test at 393x852 with `TargetPlatform.iOS`
  and 59/34 pt insets finds both on screen, clear of the notch, the home indicator and the bar, and the button opens
  the sheet. The phone button is icon-only (`add_task`), which is easy to miss; that is the same on Android.
- The 0.19.0 release run's iOS job passed `fastlane ios ipa`, which fails when `PlugIns/TixWidgets.appex` is missing
  from the IPA or signed without the App Group. Widgets ship.
- `quick_actions_ios` 1.2.5 registers as a scene delegate, so quick actions work with the UIScene lifecycle; they are
  installed after sign-in by `QuickActionsHost`.
- What iOS lacks is a system entry point outside the home screen. That is what this change adds.

## Opening the app from an intent

The intents return `OpenURLIntent` with a `tixwidget://` link (iOS 18). The link is the one the widgets already use,
so `home_widget` hands it to `WidgetSync.open`, which switches context when needed and opens quick add or the route.
`OpenURLIntent` opens the URL through the system, so on a cold start the link arrives in the scene's connection
options, where `home_widget` keeps it as the launch link. Calling `UIApplication.open` from inside an
`openAppWhenRun` intent would deliver it to an already-connected scene before Dart listens, and lose it.

Everything new is gated `@available(iOS 18.0, *)`: controls need iOS 18, and so does `OpenURLIntent`. The app keeps
its iOS 15 floor and the extension its iOS 17 floor; older systems simply do not offer the controls or shortcuts.

The intents are compiled into the app and the extension: the controls in the extension run them, and
`AppShortcutsProvider` must live in the app.

## Inbox count

`InboxControl` uses a `ControlValueProvider` that reads the active context's inbox snapshot through the same
`EntryLoader` the Inbox widget uses. The app asks for `ControlCenter.reloadAllControls()` when the App Group storage
changes (debounced), when it goes to the background and after a background refresh, so the count follows the
snapshot. With no snapshot the control reads just "Inbox".

## Localization

Control names, intent titles and parameter titles are in `ios/TixWidgets/Localizable.xcstrings`, which the app
target now also copies so intent metadata resolves in both bundles. Siri phrases must be in a catalog named
`AppShortcuts.xcstrings` in the app target. The native strings test checks both in all four languages.

## Live Activity: not built

The useful case would be "agents at work": how many tasks agents hold. Today that number is counted from whatever
listing a task screen has loaded, not tracked globally. A Live Activity updated only by the running app stops
updating seconds after the app leaves the foreground, which is exactly when the Lock Screen and Dynamic Island show
it; background refresh comes every 30 minutes at best. That would put a confidently wrong number on the Lock Screen.
Doing it properly needs ActivityKit push: the app registers a push-to-start and an update token with the tix server,
and the server sends APNs updates on `task.claimed`, `task.released` and `task.lease_expired`. That is a server
feature with APNs credentials per deployment, so it is a follow-up, not part of this change.
