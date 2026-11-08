# Quick actions: templates, quick add everywhere, share, palette and app shortcuts

## Why

The fastest way to get work into tix is one line. Today the app offers it only inside a project's list, cannot
start from a template, ignores text shared from other apps, and its command palette knows only the screens on
show. tix's web interface does all of these; the app should do them with fewer taps.

## What Changes

- Templates: list, save from a task (or from a new one), edit, delete, and create a task from one in one tap.
- Quick add from anywhere: a button above the navigation on phones and in the rail wider, Ctrl+N or Cmd+N on a
  keyboard, a project picker, completions for projects, tags and people, recent values, a live preview of what the
  server makes of the line, and "add another".
- The preview comes from the server: a dry run of tix's import of one quick-add line. The app still never parses
  the syntax itself.
- Shared text and links from Android's share sheet open quick add with the text as a draft; on a desktop Ctrl+Shift+V
  does the same with the clipboard.
- The command palette gains global commands (quick add, go to a project or a task by reference, switch context,
  theme, templates) and searches projects and recently opened tasks, with fuzzy matching.
- Launcher shortcuts on Android and quick actions on iOS: Quick add, Inbox, My work.

## Capabilities

### New Capabilities

- `templates`: task templates.
- `command-palette`: the global commands and searches in the palette and how features register them.
- `share-intake`: text shared into the app.
- `app-shortcuts`: launcher shortcuts and home-screen quick actions.

### Modified Capabilities

- `quick-add`: quick add opens from anywhere, previews the line and completes names.

## Impact

- New features `lib/src/features/quick/` and `lib/src/features/templates/`; template, tag, actor and import
  dry-run calls in `TixApi` behind `TemplatesRepository` and `TasksRepository`.
- `core/design/components/commands.dart` gains command sources and fuzzy matching.
- `core/quick/` holds the draft channel every feature opens quick add through.
- Android manifest and `MainActivity` for share intents; the `quick_actions` plugin (Android, iOS) for app
  shortcuts.
