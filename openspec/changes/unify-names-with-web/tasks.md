# Tasks

## 1. Spec

- [x] 1.1 Deltas for `event-watch`, `live-updates`, `audit-log`, `adaptive-layout`, `app-settings`,
  `design-system`, `task-views`, `task-detail`, `templates`, `quick-add` and `task-export`
- [x] 1.2 design.md records the decisions shared with tix web (C2 to C12)

## 2. Activity and Live events (C2)

- [x] 2.1 Activity at `/activity` is the audit screen; Live events at `/events` in the Manage branch
- [x] 2.2 Redirects: `/manage/audit` to `/activity`; `/watch` and `/manage/watch` to `/events`; `tix://events`
- [x] 2.3 Manage lists Live events instead of the audit log

## 3. Navigation (C9)

- [x] 3.1 Destinations, palette commands and shell branches in the web's order
- [x] 3.2 Activity's icon is a history clock

## 4. Colour scheme (C8)

- [x] 4.1 Six choices in the web's order; "System, OLED when dark" replaces the switch
- [x] 4.2 Low contrast built on `TixTokens.dim`, keeping its accent without a tenant one
- [x] 4.3 A stored system choice with the black flag reads as "System, OLED when dark"
- [x] 4.4 Palette group and commands; the gallery cycles through Low contrast; ADB takes `dim`

## 5. Wording (C4 to C7, C10, C12)

- [x] 5.1 Waiting on, Unsnooze, Reclaim the lease, All projects, Due in
- [x] 5.2 Copy reference checked: it copies the reference
- [x] 5.3 Quick-add hint

## 6. Import and export on a project (C11)

- [x] 6.1 `/projects/<KEY>/transfer` and the project header button

## 7. Strings, docs, tests

- [x] 7.1 English, Bulgarian, German and French; gen-l10n
- [x] 7.2 README and docs
- [x] 7.3 Tests for the redirects, the order, the colour scheme and its migration, Low contrast, the project entry
