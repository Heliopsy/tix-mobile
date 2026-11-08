# Design

How the app looks and feels, and the rules every screen follows. The reference is tix's own web interface: its
stylesheet under `internal/web/assets/css/` in the [tix repository](https://github.com/heliopsy/tix) and its
`AGENTS.md` ("Web interface"). The app ports that look to Flutter and adapts it for touch.

Everything here lives in `lib/src/core/design/`. Screens import one file:

```dart
import 'package:tix_mobile/src/core/design/design.dart';
```

Open the gallery to see every component in light, dark, OLED black and any tenant accent: Settings, then
Components, or the command palette (Ctrl+K), or `/gallery`. It is routed in debug and profile builds, and in a
release build only with `--dart-define=TIX_GALLERY=true`.

## Tokens

`TixTokens` (`tokens.dart`) is a `ThemeExtension` holding tix's `010-tokens.css`, one instance per scheme. Read it
with `context.tix`. Never write a colour literal in a screen.

### Colours

| Token | CSS | Light | Dark | Use |
| --- | --- | --- | --- | --- |
| `bg` | `--bg` | `#ffffff` | `#14171b` | The page |
| `surface` | `--surface` | `#f6f7f9` | `#1b1f24` | Recessed regions: lists, the rail, sheets, dialogs |
| `ink` | `--ink` | `#0f1319` | `#e7eaee` | Text |
| `muted` | `--muted` | `#5f6b7a` | `#98a2b3` | Secondary text, labels, icons |
| `line` | `--line` | `#ebedf1` | `#2b3138` | Hairlines, card and field borders |
| `lineStrong` | `--line-strong` | `#d6dae1` | `#3a424b` | Control borders, the faint `#` and `@` |
| `accent` | `--accent` | `#0f766e` | `#2dd4bf` | The tenant's colour: primary buttons, links, selection |
| `accentSoft` | `--accent-soft` | `#e6f4f1` | `#123b36` | What the accent sits on |
| `onAccent` | `--on-accent` | `#ffffff` | `#08231a` | Text on the accent |
| `brand` | | `#0f766e` | `#2dd4bf` | tix's teal, kept by the in-progress status whatever the tenant picks |
| `danger`, `dangerSoft` | `--danger` | `#b42318` | `#f87171` | Destructive actions, highest priorities, errors |
| `warn`, `warnSoft` | `--warn` | `#b54708` | `#fbbf24` | Blocked, due soon |
| `ok`, `okSoft`, `onOk` | `--ok` | `#067647` | `#34d399` | Done, success |
| `scrim` | `--scrim` | 45% `#101828` | same | Behind a modal |
| `projects[...]` | `--proj-*` | eight shades | eight shades | Project colours: slate, red, amber, green, teal, blue, violet, pink |

`TixTokens.dim` carries tix's low-contrast scheme for a later setting.

### OLED black

`TixTokens.oled` is the dark scheme for OLED screens, where a black pixel is switched off. tix's web interface has
no equivalent; it is the dark tokens with these changes:

| Token | OLED | Why |
| --- | --- | --- |
| `bg` | `#000000` | The page is off |
| `surface` | `#0a0b0d` | Near black: sheets, dialogs and the rail are told apart by their hairline, not a fill |
| `line` | `#24292f` | A little brighter than dark's, since it now does the work a fill did |
| `accentSoft`, `brandSoft`, `dangerSoft`, `warnSoft`, `okSoft` | darker tints | Fewer lit pixels behind a pill |
| `scrim` | 70% `#000000` | Dims to black rather than to slate |

Text, status, priority and project colours are dark's, unchanged, so a status means the same thing in either dark
theme. A tenant accent applies as in dark; its tint is mixed 40% towards black. `TixTokens.isBlack` tells the two
dark schemes apart.

Settings offers System, Light, Dark and OLED black. Under System a switch, "Pure black when dark", picks OLED black
for the system's dark: a fourth segment alone could not say "follow the system, but black". Both are per device
(`settings.theme`, `settings.systemBlack`).

Status colours key off the category, never the state's name and never the accent:

| Category | Colour |
| --- | --- |
| todo, unknown | `muted` |
| in progress | `brand` (tix's teal, not the tenant accent) |
| blocked | `warn` |
| waiting | `projects[violet]` |
| done | `ok` |
| cancelled | `lineStrong`, text in `muted` |

The web paints "doing" in `--accent`, which a tenant can change. The app keeps it on tix's teal, because tix's
theming rule is that state and priority colours are not themeable. Priority: highest and high are `danger` with an
up caret, low and lowest `muted` with a down caret, normal fades to 30% on rows.

A project stores a palette name or `#rrggbb`. `context.tix.projectColour(value)` returns the scheme's shade, or a
custom colour moved to clear 4.5:1 on the page and the surface, as tix's `schemeShade` does.

### Space, shape, type and motion

| Group | Values |
| --- | --- |
| `TixSpace` | `s1` 4, `s2` 8, `s3` 12, `s4` 16, `s5` 24, `s6` 32, `s7` 48; `gutter` 16, `headGap` 16, `headSub` 4 |
| `TixRadius` | `sm` 6 (marks), `md` 8 (controls), `base` 10 (lists, toasts), `lg` 12 (cards, sheets), `pill` |
| `TixSize` | `control` 36, `controlSmall` 28, `controlTouch` 44, `target` 48, `check` 22 |
| `TixText` | `xs2` 11, `xs` 12, `sm` 13, `md` 15 (body), `base` 16, `lg` 18 (h2), `xl` 21, `xl2` 24 (h1), `xl3` 32 |
| `TixMeasure` | `page` 1560, `text` 600 (about 76 characters), `field` 512, `form` 920, `chart` 760, `side` 224 |
| `TixMotion` | `fast` 120 ms (colour), `base` 200 ms (rows, toasts), `slow` 320 ms (the tick); `ease`, `pop` |

The text theme maps the scale onto Material's roles: `headlineSmall` is the page title (24/600, tight tracking),
`titleLarge` a section (18/600), `titleMedium` 15/600, `bodyMedium` the body (15/1.55), `bodySmall` help text
(13, muted), `labelLarge` buttons (13/500). The font is the platform's own UI face, as tix's
`system-ui` stack is; nothing is bundled.

`TixMotion.of(context, d)` returns zero when the platform asks for reduced motion. Skeletons stop breathing and
busy spinners stand still then.

## Theme and the tenant accent

`buildTixTheme(brightness, accent:)` (`theme.dart`) builds Material 3 `ThemeData` from the tokens: the colour
scheme, the text theme, and a theme for every Material component the app uses, so a stock `ListTile`, `Card`,
`SegmentedButton` or `SnackBar` already looks like tix. tix's look wins over Material's defaults: no tinted
surfaces, hairlines instead of elevation, filled accent only for the one primary action.

The tenant's accent arrives through `tenantAccentProvider` (`accent_provider.dart`), which `App` watches:

1. When a context becomes active, the accent remembered for it (`accent.<connection>.<tenant>` in preferences)
   applies at once, so the app opens in the tenant's colour.
2. In the background it reads `GET /api/v1/tenants/{key}`. The tenant's `theme` field names a built-in theme,
   a `#rrggbb`, or nothing. `TixAccent.resolve` turns it into colours exactly as tix's
   `ThemeRegistry.Resolve` and `CustomTheme` do (the tests compare against values printed by tix itself).
3. An empty theme is tix's teal. A name only the server's configuration defines cannot be read through the API
   and falls back to the default. A credential without `tenant:admin` cannot read the tenant at all; the
   remembered accent, or the default, stays.

`TixTokens.withAccent` derives `onAccent` (white or `#08231a`, whichever reads better) and moves the accent just
far enough to clear 4.5:1 on the page and the surface. Only forest's light accent needs it (4.37:1 on white). The
dynamic colour option is gone: tix's identity and the tenant's accent come first.

## Components

All in `lib/src/core/design/components/`. Each has a doc comment saying when to use it.

| Component | Use it for |
| --- | --- |
| `TixPage`, `TixPageHeader` | Every screen. Title, a subtitle line, secondary tools and the one primary create action. On a phone an app bar and an extended floating button; wider, tix's page head with the button on the right |
| `TixButton` (`primary`, `secondary`, `quiet`, `danger`; `regular`, `small`) | Every labelled action. One primary per screen. `busy` shows a spinner and blocks presses |
| `TixIconButton` | Icon-only tools; the tooltip is the label |
| `TaskRow` | A task in any list: tick, star, title, status, priority, tags, assignee, project, due, snooze, reference, project stripe |
| `TaskCard` | A task on a board or in lanes |
| `TaskCheck` | The completion circle, on its own |
| `InboxRow` | An inbox item: who did what, the task, the excerpt or the move, when; unread dot |
| `UpdatedMark`, `FreshHighlight` | A list refreshed itself from a live event; a row that just arrived |
| `ChangedElsewhereBanner` | What the person is editing changed elsewhere: keep editing or reload, never a silent reload |
| `StatusPill` | A task status. The only filled mark on a row. `framed` makes it a control |
| `PriorityMark` | A priority, caret and word |
| `TagChip`, `MoreMark` | Tags, and the count of the ones left out |
| `ProjectChip`, `ProjectMark` | A project in its colour on a row; its square mark in a list |
| `AssigneeRef`, `TixAvatar` | `@handle` on a row; initials in a circle (accent, or `hued` from the handle) |
| `RefText`, `DueMark`, `SnoozeMark` | The reference in mono; due dates; snoozes |
| `TixBadge`, `TixCounter`, `Kbd` | A non-task state or role; a count; a key |
| `EmptyState` | Any list or screen with nothing in it. Carries the screen's create action |
| `ErrorState` | A failure: the message, Retry, Sign in again when the session ended, and Back |
| `SkeletonList`, `SkeletonBox` | Loading. Never a spinner for a list's first page |
| `SectionHeader`, `TixSection`, `InfoTip` | Headed, always-visible groups; a short explanation behind (i) |
| `TixTextField`, `TixSearchField`, `TixSwitchRow` | Form inputs: label above, help and errors below, capped at the field measure |
| `TixChoices` | A pick-one setting (theme, language): chips that wrap, so a long label or 200% text never hides an option |
| `TixPropertyList`, `TixPropertyRow` | A record's attributes, each a 48 dp row that opens its editor; the label moves above the value at large text |
| `TixMarkdown` | Descriptions and comments: images become links, only `http`, `https` and `mailto` open, and checklist items are ticks |
| `TixFilterBar`, `TixFilterChip` | A list's query and toggles |
| `TixSelectField`, `TixFieldLabel` | A labelled choice from a short list; the label above a control without one |
| `TixColourPicker`, `ProjectIconPicker` | A project's colour (none, the eight swatches, custom hex) and icon (none, emoji, built-in, image) |
| `TixNotice` | A message inside a screen or form: a refusal above the form, a warning, why it is read only |
| `QuickAddField`, `QuickChip` | One line that becomes a task; what the server made of it |
| `showTixSheet`, `TixSheetBody` | Opening a form or chooser: a sheet on a phone, a dialog wider |
| `confirmDestructive` | Every action that cannot be undone |
| `showActionSheet` | A row's actions on touch |
| `showTixToast` | Saying what just happened, with Undo |
| `runOptimistic` | Apply a change at once, send it, roll back with an error toast or undo |
| `TixSwipeActions` | Swipe shortcuts on rows (complete, snooze, assign, star), with haptics |
| `TixHaptics` | The three kinds of touch feedback |
| `CommandScope`, `TixShortcuts`, `showCommandPalette`, `showShortcutHelp` | Keyboard shortcuts, the `?` help and the Ctrl+K / ⌘K palette |

### Commands and shortcuts

`HomeShell` wraps the signed-in screens in `TixShortcuts`. A screen adds its own commands by wrapping its body:

```dart
CommandScope(
  commands: [
    TixCommand(
      id: 'tasks.new',
      label: l10n.newTask,
      group: l10n.commandsTasks,
      icon: Icons.add,
      shortcut: const SingleActivator(LogicalKeyboardKey.keyN),
      run: add,
    ),
  ],
  child: TixPage(...),
)
```

The commands appear in the palette and, when they have a key, in the `?` help, for as long as the screen is
mounted. Keys pressed while a text field has focus stay in the field. Ids are `<feature>.<verb>`; a later scope
with the same id wins.

**Searches.** Things too many to register one by one (projects, recent tasks, a task by reference) come from
sources: a function from what the person typed to commands, read from data already loaded and never awaited.

```dart
CommandScope(
  commands: const [],
  sources: [
    (query) => [
      for (final p in projects)
        TixCommand(id: 'project.${p.key}', label: p.name, keywords: p.key, run: () => open(p)),
    ],
  ],
  child: ...,
)
```

The palette ranks commands and source results together by letters in order (`fuzzyScore`): consecutive letters,
word starts and prefixes first. `keywords` are matched as well as the label.

**Global commands.** A command that should exist on every screen is registered by a widget the router mounts around
the signed-in shell, not by a screen: `QuickActionsHost` (quick add, the clipboard, templates, inbox and my work once
routed, projects, recent tasks, task by reference, using a template), `TemplatesCommands` (new template, from the
open task), `SettingsCommands` (theme) and `ContextCommands` in the shell (switch context). A feature adds its own
the same way: a small widget wrapping `child` in a `CommandScope`, composed in `core/router/router.dart`.

**Keys.** Use `primaryKey(LogicalKeyboardKey.keyN)` for Ctrl on Linux and Windows and Cmd on Apple platforms. Taken:
`?`, Ctrl/Cmd K (palette), Ctrl/Cmd N (quick add), Ctrl/Cmd Shift V (quick add from the clipboard), and on the task
list `N` and `R`.

### Share intake and launcher shortcuts

Android: `MainActivity` takes `ACTION_SEND` with `text/plain`, holds the latest share, and Dart takes it over the
`tix/share` channel (`ShareIntake` in `core/platform`), on a cold start and when the activity says `shared`. Subject
and text become one line, and quick add opens holding it; nothing is added until the person presses Add.

iOS needs a share extension: a separate target that cannot run Flutter, so it would write the text to an App Group
container and open the app with a `tix://share` URL that `ShareIntake` reads. That brings a target, an App Group
entitlement and provisioning changes, and lands in its own change. Desktop drag and drop waits on `desktop_drop` 0.9,
whose `cross_file` 0.4 conflicts with `share_plus` 13; until then Ctrl+Shift+V or Cmd+Shift+V opens quick add with
the clipboard.

Launcher shortcuts (Android) and home-screen quick actions (iOS) come from `quick_actions`: Quick add, Inbox and My
work. A shortcut whose screen is not routed yet goes to Projects.

### Optimistic updates

Quick actions change the screen before the server answers. The notifier owns the state; the widget calls:

```dart
await runOptimistic(
  context,
  apply: () => notifier.markDone(task.id),
  rollback: () => notifier.restore(task),
  commit: () => notifier.sendDone(task.id),
  describe: (e) => errorMessage(l10n, e),
  success: l10n.taskCompleted(task.ref),
  undo: () => notifier.sendReopen(task.id),
);
```

The change shows at once. A refusal rolls it back, buzzes, and shows the server's reason in a danger toast. A
success shows a toast with Undo, which rolls back locally and calls `undo`.

## Live updates and notifications

Lists follow tix's event stream through `refreshOn` and `onEvents` (`core/events`). A list that refreshes in
place marks the new rows with `FreshHighlight` and shows `UpdatedMark` for a few seconds; it never moves the
scroll position. A screen with unsaved input never reloads under the person: it listens for events about its
item (`EventTopics.taskDetail`, matching the subject) and shows `ChangedElsewhereBanner` instead.

New inbox items become local notifications (`core/notifications`, over `flutter_local_notifications`) while the
app runs or was put away a moment ago, on Android, iOS, macOS, Linux and Windows. They are off until the person
turns them on, per context; the platform's permission is asked at that moment and never at start. Each item
notifies once; items already there when the app starts never do. A tap opens the task and marks the item read.

### What real push would need

A closed app hears nothing: there is no push service, and the app does not pretend otherwise. Push through FCM
(Android) and APNs (Apple platforms) would need, from tix:

1. **Device registration**: a route for the app to register a push token per device, actor and tenant
   (`POST /devices`, `DELETE /devices/{id}`), scoped like the inbox (the caller's own, `task:read`), listed and
   revocable from the web as personal channels are.
2. **A sender**: tix delivering each inbox item to the actor's devices, beside the channel dispatcher it already
   has (same queue, retries and network guard), with FCM service-account and APNs key configuration per
   installation. A self-hosted tix cannot use the app's own FCM project and APNs key without a relay, so either
   each installation configures its own (and ships its own build), or a relay run for the public app forwards
   opaque payloads.
3. **A payload with no content**: the item id and tenant only, the app fetching the text over its own connection
   when woken, so neither Google nor Apple, nor a relay, sees task titles or comments.
4. **Mute and kind rules applied server side**, as channels already do, so a muted kind costs no wake-up.

Until then, personal channels (ntfy in particular) are how a person is reached when the app is closed.

## UX rules

tix's web rules, adapted for touch. They hold on every screen.

1. **No expander sections for page actions or settings.** No `ExpansionTile` for a create form, a settings group
   or a danger zone. Settings are `TixSection`s, always drawn; a thing's settings that are not the screen's point
   go on a screen of their own.
2. **A create action is a primary button with a plus icon and a label** in the page header (`TixPage.primaryAction`)
   or on the right of its section's heading, and it opens the form with `showTixSheet`: a bottom sheet on a phone,
   a dialog wider. On a phone the header button becomes an extended floating button, which is where a thumb
   reaches. An empty list carries the same button (`EmptyState.action`).
3. **A destructive action is a red button** (`TixButton.danger`) that opens `confirmDestructive`, whose confirm
   button is red and names the verb. A row's destructive menu item is red too, and still confirms.
4. **An explanation is visible text or an (i) tip** (`InfoTip`), never a fold.
5. **Every state has a visible way back**: errors carry Back (or the navigation, on a tab root), sheets and dialogs
   a Cancel, results and previews a way to the screen they came from.
6. **One primary action per screen.** Everything else is secondary or quiet.
7. **Status and priority colours never follow the tenant.** Only the accent does.
8. **Layout follows the window width, not the platform**: under 600 a phone layout, from 840 two panes.
9. **Swipes and shortcuts are shortcuts.** Whatever they do is also in a menu or on a button.

## Accessibility

### Contrast

Measured with the WCAG 2 formula; `test/core/design/tokens_test.dart` fails if any of these drop under the floor.

| Token | Light on page | Light on surface | Dark on page | Dark on surface |
| --- | --- | --- | --- | --- |
| `ink` | 18.63:1 | 17.38:1 | 14.90:1 | 13.72:1 |
| `muted` | 5.43:1 | 5.06:1 | 6.98:1 | 6.43:1 |
| `accent` (default) | 5.47:1 | 5.11:1 | 9.66:1 | 8.90:1 |
| `danger` | 6.57:1 | 6.13:1 | 6.50:1 | 5.99:1 |
| `warn` | 5.43:1 | 5.06:1 | 10.77:1 | 9.92:1 |
| `ok` | 5.69:1 | 5.31:1 | 9.35:1 | 8.61:1 |

OLED black, against `#000000` and the `#0a0b0d` surface:

| Token | OLED on page | OLED on surface |
| --- | --- | --- |
| `ink` | 17.40:1 | 16.32:1 |
| `muted` | 8.15:1 | 7.65:1 |
| `accent` (default) | 11.28:1 | 10.58:1 |
| `danger` | 7.59:1 | 7.12:1 |
| `warn` | 12.58:1 | 11.79:1 |
| `ok` | 10.92:1 | 10.24:1 |
| `line`, `lineStrong` (not text) | 1.43:1, 2.06:1 | 1.34:1, 1.93:1 |

Nothing needed moving: every text token is brighter against black than against dark's page.

Every built-in tenant theme, and a sample custom accent (`#ffcc00`), is tested for text on the accent (4.5:1),
the accent on its tint (3:1) and the accent on the page (3:1):

| Theme | Light accent on page | Text on light accent | Dark accent on page | Text on dark accent |
| --- | --- | --- | --- | --- |
| default | 5.47:1 | 5.47:1 (`#ffffff`) | 9.66:1 | 8.91:1 (`#08231a`) |
| indigo | 5.67:1 | 5.67:1 (`#ffffff`) | 7.44:1 | 6.87:1 (`#08231a`) |
| forest | 4.37:1, moved to `#29823b` | 4.83:1 (`#ffffff`) | 11.67:1 | 10.77:1 (`#08231a`) |
| ember | 5.18:1 | 5.18:1 (`#ffffff`) | 7.94:1 | 7.33:1 (`#08231a`) |
| violet | 5.55:1 | 5.55:1 (`#ffffff`) | 9.74:1 | 8.99:1 (`#08231a`) |
| ocean | 5.59:1 | 5.59:1 (`#ffffff`) | 12.40:1 | 11.45:1 (`#08231a`) |
| plum | 7.21:1 | 7.21:1 (`#ffffff`) | 9.91:1 | 9.15:1 (`#08231a`) |
| slate | 10.35:1 | 10.35:1 (`#ffffff`) | 8.72:1 | 8.05:1 (`#08231a`) |

On OLED black every dark accent reads higher still: default 11.28:1, indigo 8.69:1, forest 13.64:1, ember 9.28:1,
violet 11.38:1, ocean 14.49:1, plum 11.58:1, slate 10.19:1 on the page, with text on the accent as in dark.

A custom accent is derived to 4.5:1 on both pages, so it passes by construction.

### Text size

Nothing that holds text has a fixed height; rows, buttons and headers grow with the text. Components are tested at
twice the text size at phone and desktop width (`task_row_test.dart`, `page_test.dart`) and must not overflow.
Avatars keep their initials at a fixed size because the circle is decorative and excluded from semantics.

### Semantics

- Every icon-only control has a tooltip, which is its label.
- The tick is a checkbox with "Complete" or "Reopen"; a priority reads as its word ("Highest"), not as a caret.
- Section and page titles are headers.
- Skeletons announce "Loading".
- Swipe actions are also custom semantics actions, so a screen reader can reach them.

### Touch targets

Anything pressable is at least 48 dp to the finger (`MaterialTapTargetSize.padded` and minimum sizes), even where it
draws smaller: a 36 dp button, the 22 dp tick (40 dp target in the row), the star. Marks that share a line on a row
(status and priority as controls, an inline (i)) get 32 dp, tix's rule for controls with neighbours.

## Building a new screen

Follow this for every screen. Reviewers check it.

1. Start from `TixPage`. Give it the title, a subtitle when the screen has a scope to state, and its create action
   as `primaryAction` with `Icons.add` and a verb label.
2. Draw async data with `AsyncBody`: a skeleton while loading, `ErrorState` on failure. Lists use `PagedListView`
   with an `EmptyState` that carries the same create action.
3. Use the components above before writing a widget. A task is a `TaskRow` or `TaskCard`, a status a
   `StatusPill`, a field a `TixTextField`. If something is missing, add it to `core/design/components/` with a doc
   comment, a gallery entry and a golden, rather than styling it inside the feature.
4. No colour, size or duration literals: tokens only (`context.tix`, `TixSpace`, `TixText`, `TixRadius`,
   `TixMotion`).
5. Forms and choosers open with `showTixSheet` and `TixSheetBody`, primary action last, Cancel quiet.
6. Destructive actions: `TixButton.danger` then `confirmDestructive`. Settings: `TixSection`s, never folds.
7. Quick actions on rows go through `runOptimistic`, with Undo where the server can undo.
8. Register the screen's actions with `CommandScope`; give the main ones a single-letter key when it does not
   clash with the list in the `?` help.
9. Every string from `lib/l10n/`, in English and Bulgarian.
10. Check it at 400 and 1280 wide, light, dark and OLED black, a non-default accent (the gallery's palette menu
    shows how), and at 200% text, in English, German and French.
11. Tests: loading, data, empty and error at a compact and an expanded width; that the primary action and any
    destructive action work; that a guard fails when broken.

## Goldens

The components have goldens under `test/core/design/goldens/`, light, dark and OLED black at 400 and 1280 wide,
plus a tenant accent in each. They render real Roboto and the Material icons, loaded from the pinned Flutter SDK's
cache by `test/core/design/flutter_test_config.dart`, so any Linux host with that Flutter draws the same pixels.

```sh
just goldens          # regenerate, then look at every changed image before committing
```

They are generated and compared on Linux only; see [testing.md](testing.md#golden-tests).
