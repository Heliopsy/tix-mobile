# Tasks

- [x] Widget test at iPhone size on iOS for the shell's quick add button and a project's New task button
- [x] `text` on `tixwidget://quickadd`, filling in quick add; test in `widget_sync_test.dart`
- [x] `Links` moved into `WidgetStore.swift` so the app target can build links; `quickAdd` takes `text`
- [x] `OpenQuickAddIntent`, `OpenInboxIntent`, `OpenMyWorkIntent` returning `OpenURLIntent`, in both targets
- [x] `QuickAddControl` and `InboxControl` (with the unread count) in the widget bundle on iOS 18
- [x] `TixAppShortcuts` with phrases that name the app, and `AppShortcuts.xcstrings` in en, bg, de and fr
- [x] Control reloads from the app when widget storage changes, on background and after a background refresh
- [x] Xcode project: target membership for the new Swift files and catalogs
- [x] Native strings test covers `AppShortcuts.xcstrings`
- [x] docs/widgets.md: controls, shortcuts, the `text` parameter
