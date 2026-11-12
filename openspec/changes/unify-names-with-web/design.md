# Design

## The shared vocabulary

tix web and the app agreed these names and this order; the app implements its side here. Each row is one thing,
called the same on both surfaces. The TUI is not part of the agreement.

| Decision | Web | App | Notes |
| --- | --- | --- | --- |
| C2 Activity | Activity is the audit feed at `/activity` (already) | Activity is the audit feed at `/activity`; the raw stream is Live events at `/events`, under Manage | `/manage/audit` -> `/activity`; `/watch`, `/manage/watch` -> `/events`. The stored destination id stays `activity`. |
| C3 Manage | Sidebar and palette group "Admin" -> "Manage"; Templates moves into the main nav after Projects | Already "Manage"; Templates already outside Manage | Nothing to change in the app. |
| C4 Waiting on | (web wording) | Filter chip "Waiting on", task notice "Waiting on a task that is not finished.", dependencies info "This task waits until each task listed here reaches a finished state." | The status category Blocked keeps its name on both. |
| C5 Unsnooze | Unsnooze | "Wake now" -> "Unsnooze" | Matches `tix task unsnooze` and the API. |
| C6 Reclaim the lease | Reclaim the lease | "Force-release claim" -> "Reclaim the lease" | Matches ReclaimTask and the TUI. |
| C7 Templates | "This project" / "All projects", "Due in" | "Every project" -> "All projects", "Due after" -> "Due in" | |
| C8 Colour scheme | Colour scheme: System, Light, Dark, OLED, Low contrast, System OLED when dark | Same six, same order; replaces the "Pure black when dark" switch | "Theme" means only the tenant accent on both. |
| C9 Order | Inbox, My work, Tasks, Projects, Templates, Activity, Statistics, Manage, Settings | Inbox, My work, Tasks, Projects, Activity, Manage, Settings | The app has no Statistics screen and keeps Templates inside Projects. Activity's icon is a history clock. |
| C10 Copy reference | Actions menu copies the reference | Copy reference copies the reference (it already did) | The key `y` belongs to the keyboard change. |
| C11 Import and export | Project header Export | Project header Import and export, opening the transfer screen on the project | |
| C12 Quick-add hint | `Fix login !high #auth @raj due:fri +web ^web-3` | Same line | Only "Fix login" is translated. |

## Activity and Live events

The audit screen moves out of Manage into the Activity branch, unchanged. The event stream screen keeps its code
(`features/watch`) and moves to `/events`, a second route in the Manage branch after `/manage`, so the Manage
destination stays selected while it is open and the branch still starts on `/manage`. Manage lists it as Live
events for a credential with `event:subscribe`; the audit log entry under Manage goes, since Activity is a
destination. The tray's Activity entry keeps opening `tix://activity`, which is now the audit feed, as on the web.

## Order by id, not index

The shell's branches are reordered to match the destinations. Nothing stores a branch index: commands and the
More sheet look destinations up by id, the start screen is stored by name, and context switches land on a tab's
root path. The phone bar shows the first four (Inbox, My work, Tasks, Projects) and More.

## Colour scheme storage

`ThemeChoice` gains `dim` and `systemOled`. "System, OLED when dark" is stored as it was before it was a choice: the
system choice (`settings.theme = system`) with `settings.systemBlack = true`. A device that had the old switch on
therefore opens on the new choice, and the home screen widgets, which read the same two keys, need no change.
Picking any other choice clears the flag. Low contrast is stored as `dim`; widgets have no such palette and draw it
dark.

The Low contrast tokens are `TixTokens.dim`, already carrying the web's `dim` palette from `010-tokens.css`. The
dark theme is built on them, as OLED is built on `TixTokens.oled`. With no tenant accent, Low contrast keeps its
own muted accent; a tenant accent replaces it, as the web's tenant colour does on `data-theme="dim"`.

## Import and export on a project

The transfer screen already opens on a project (`initialProject`). The project screen gets a header button that
goes to `/projects/<KEY>/transfer`, a route inside the Projects branch, so going back returns to the project.
It shows only when the credential may export or import, as the Manage entry does. No server change.

## Not changed here

The key table, Ctrl+digit numbering and the shortcut help belong to the keyboard change. The `features/watch` and
`features/audit` folders and class names stay. The old event-watch purpose line still says Activity until the
change is archived and the purpose is rewritten.
