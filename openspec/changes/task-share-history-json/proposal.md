# Proposal

## Why

The web's task screen has a Share menu (Share…, Copy link, Copy as Markdown, Copy key and title) and a lane
card's menu carries the same copies. Every history row on the web offers Raw, which shows the audit entry as
recorded, and Copy JSON. The app had neither: a task's address could only be copied by hand, and its history
rows said who changed what with no way to see the entry itself.

## What Changes

- A Share button in the task header and a Share item in a row's or card's menu open the Share menu: Share…
  (the system share sheet, where the platform has one), Copy link, Copy as Markdown and Copy key and title.
  The command palette offers it as "Share REF". Each copy says what it did in a toast.
- The link is the task's `web_url` when tix sends one, else `/tasks/REF` on the server the app is connected
  to. The Markdown and text forms match tix's `internal/tasklink`: the title on one line, `\`, `[` and `]`
  escaped in the label.
- Each history row gets Raw, a sheet with the entry's facts and its before and after records (the audit
  screen's detail, now shared), with Copy all as JSON; and Copy JSON, copying the entry as tix sent it.
- Not offered on offline drafts, which have no address yet.

## Impact

- Capabilities: `task-detail`, `task-views`.
- Code: `data/models/task_link` (new), `data/repositories/task_detail_repository` (history keeps the wire
  JSON), `core/widgets/audit_entry_detail` (moved from the audit screen), `features/tasks` (share menu, header,
  row menu, palette, history rows), l10n, docs.
