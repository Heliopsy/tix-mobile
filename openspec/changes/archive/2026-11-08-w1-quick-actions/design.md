# Design

## Preview without a client parser

tix's API has no quick-add preview, and the app must not parse the syntax. tix's import does: `POST
/projects/{ref}/tasks/import` with `format: lines`, `dry_run: true` and one line returns the row as tix would
create it (title, priority, tags, assignee, due, status, parent) or its refusal, and writes nothing. The sheet
sends that, debounced by 300 ms, and draws the row as `QuickChip`s. Only the newest answer is drawn.

- It needs the `import` scope. A refusal (403) turns the preview off for the session; quick add still works.
- A line naming a project (`+ops`) is refused by the import ("a line cannot name a project"). The sheet shows the
  refusal muted, as a preview, and Add still sends the line, which `POST /tasks` accepts. Completing a project
  after `+` moves it into the project picker instead, so the preview keeps working.
- Relative dates count in UTC in both calls, so the preview and the task agree.

The app recognises a sigil (`#`, `@`, `+`) only in the word under the cursor, to offer completions. It never
reads the line's meaning.

## One quick add

`core/quick/quick_add.dart` holds `quickAddDraftProvider`, a notifier any feature writes a draft into (text and
project). `QuickActionsHost`, mounted by the router around the signed-in shell, listens and opens the sheet. The
shell's button, Ctrl+N, the palette, share intents and app shortcuts all write a draft; none imports the sheet.

The project picker starts from the project in the location (`/projects/:key`), then the last one used, then the
first project. Recent projects, tags and handles are kept per context in preferences (identifiers only, eight of
each). Recently opened tasks are kept in memory for the palette.

## Offline

The API foundation brings a read cache, not a write queue. A quick add that fails for want of a network keeps the
line and says it needs a connection. A queue, when one exists, takes the request instead.

## Templates

tix keeps a template from a task (`template.save`); there is no "empty template" operation. "From scratch" creates
the task from a quick-add line first and says so, then saves it. Editing uses `template.update` with only the
fields changed. Use creates the task in the template's project, or the chosen one, and offers to open it.

## Palette

`CommandRegistry` gains sources: a function from the query to commands, registered by an owner like commands are.
The palette shows static commands and source results together, ranked by a subsequence match (consecutive and
word-start letters score higher). Sources: projects (go to), recently opened tasks, a task by reference when the
query looks like one (`web-12`), and saved contexts. Global commands are registered by widgets the router mounts
around the shell (`QuickActionsHost`, `SettingsCommands`), so they exist whichever screen shows.

## Share intake

Android: an `ACTION_SEND` `text/plain` intent filter on `MainActivity`, which hands `EXTRA_TEXT` (and
`EXTRA_SUBJECT`) to Dart over the `tix/share` method channel, for a cold start and while running. Dart joins
subject and text into one line.

iOS needs a share extension: a separate target that cannot run Flutter, writes the text to an App Group and opens
the app with a `tix://share` URL. That is a target, an entitlement and signing changes; it follows in its own
change. Desktop drag and drop needs `desktop_drop` 0.9, whose `cross_file` 0.4 conflicts with `share_plus`; until
`share_plus` moves, Ctrl+Shift+V opens quick add with the clipboard.

## App shortcuts

`quick_actions` registers Quick add, Inbox and My work at start on Android and iOS. A shortcut whose screen is not
routed yet (Inbox, My work arrive with other changes) goes to Projects.
