# Proposal

## Why

tix web and the app named the same things differently and ordered the navigation differently. The app's Activity
was the raw event stream while the web's Activity is the audit feed; the app said Theme for the reader's light and
dark choice, which the web calls Colour scheme, and Theme for the tenant accent too; dependency waits read as
Blocked, which is also a status category. A person moving between the two had to translate. The web and app
agreed one vocabulary and one order; this is the app's half.

## What Changes

- Activity is the audit feed at `/activity` (the screen that was the audit log under Manage). The raw stream is
  Live events at `/events`, listed under Manage. `/manage/audit` opens Activity; `/watch` and `/manage/watch`
  open Live events; `tix://events` joins `tix://watch`. Activity's icon is a history clock.
- The destinations follow the web's order: Inbox, My work, Tasks, Projects, Activity, Manage, Settings. A phone bar
  shows Inbox, My work, Tasks, Projects and More.
- The reader's choice is the Colour scheme: System, Light, Dark, OLED, Low contrast, and "System, OLED when dark",
  which replaces the "Pure black when dark" switch. Low contrast is the web's dim palette. A stored system choice
  with the old switch on reads as "System, OLED when dark". The tenant accent keeps the name Theme.
- Dependency waits read "Waiting on": the filter chip, the task's notice and the dependencies section. The status
  category Blocked keeps its name.
- Wake now becomes Unsnooze, Force-release claim becomes Reclaim the lease, a template's Every project becomes All
  projects and Due after becomes Due in. Copy reference copies the reference, as it already did.
- The quick-add hint is the web's line, `Fix login !high #auth @raj due:fri +web ^web-3`.
- A project's header gets Import and export, opening the transfer screen on that project.

## Impact

- Capabilities: `event-watch`, `live-updates`, `audit-log`, `adaptive-layout`, `app-settings`, `design-system`,
  `task-views`, `task-detail`, `templates`, `quick-add`, `task-export`.
- Code: `core/router`, `core/platform` (deep links, ADB), `core/design/tokens.dart`, `features/shell`,
  `features/settings`, `features/manage`, `features/audit`, `features/watch`, `features/tasks/presentation/task_screen.dart`,
  `features/gallery`, `features/widgets`, l10n in English, Bulgarian, German and French, README and docs.
- No server change. The keyboard (Ctrl+digit numbering, `g` chords) changes in a separate change.
