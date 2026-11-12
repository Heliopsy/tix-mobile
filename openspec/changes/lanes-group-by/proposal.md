# Proposal

## Why

tix's web draws lanes by project, assignee, priority, tag or deadline ("Group lanes by"), and on a project page
offers lanes by assignee. Each lane heading links to the screen narrowed to that lane. The app only drew one lane
per project, and a project screen had no lanes at all.

## What Changes

- Lanes can be grouped by Project, Assignee, Priority, Tag or Due, picked under "Group lanes by" in the sort menu
  while lanes are drawn. The choice is kept per screen while the app runs.
- A project screen offers lanes too, grouped by anything but Project, by Assignee unless the reader picks another.
- Lanes are built as tix builds them: people A to Z then Unassigned; priorities highest first; tags named by the
  filter first, then A to Z, then No tag, a card with several tags drawn once under the first lane the reader's
  arrangement shows; deadline buckets only when a card lands in them. A person, priority or tag the filter names
  gets a lane even when empty.
- Each grouping keeps its own arrangement under tix's view names, `lanes` for projects and `lanes:assignee`,
  `lanes:priority`, `lanes:tag`, `lanes:due` for the rest, shared with the web.
- A lane's name narrows the screen to it, replacing the filter with `project:KEY`, `assignee:HANDLE`,
  `priority:NAME` or `tag:NAME`, as the web's heading link does. Unassigned, No tag and deadline lanes have no such
  term and are not links.

## Impact

- Capabilities: `task-views`.
- Code: `data/query/task_query`, `features/tasks` (screen state, lanes view, sort menu).
- No API change: the arrangement endpoints already take any view name.
