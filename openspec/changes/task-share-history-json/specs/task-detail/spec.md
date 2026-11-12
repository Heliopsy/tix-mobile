# task-detail

## ADDED Requirements

### Requirement: Share a task

The task header and the command palette SHALL open a Share menu offering Copy link, Copy as Markdown and Copy key
and title, and Share… where the platform has a share sheet. The link SHALL be the task's `web_url`, else
`/tasks/REF` on the connected server. Each copy SHALL say what it copied in a toast. Drafts SHALL not offer it.

#### Scenario: Copy as Markdown

- **WHEN** a person picks Copy as Markdown for infra-1 "Fix [login]" with `web_url` `https://t.example/tasks/infra-1`
- **THEN** the clipboard holds `[infra-1 Fix \[login\]](https://t.example/tasks/infra-1)` and a toast says
  "Markdown link copied"

#### Scenario: No web address from the server

- **WHEN** the task has no `web_url` and the app is connected to `https://tix.example`
- **THEN** Copy link copies `https://tix.example/tasks/infra-1`

#### Scenario: Share sheet

- **WHEN** a person picks Share… on a phone
- **THEN** the system share sheet receives the task's link

### Requirement: A history row shows its entry raw

Each history row SHALL offer Raw, a sheet with the entry's facts and its before and after records and a Copy
all as JSON button, and Copy JSON, which copies the entry as tix sent it.

#### Scenario: Copy JSON from a history row

- **WHEN** a person presses Copy JSON on a history row
- **THEN** the clipboard holds the entry's JSON, indented, and a toast says JSON was copied

#### Scenario: Raw entry

- **WHEN** a person presses Raw on a history row that changed the priority
- **THEN** a sheet titled "Raw entry" shows the entry's sequence, actor, before and after records
