# Proposal

## Why

The app lists one project's tasks in the server's default order and nothing else. The tix web UI draws the
same selection as a list, a board or lanes, filters it with tix's expression language, keeps saved filters and
My work in its sidebar, and acts on many tasks at once. People who carry the app need all of that, and need it
quicker than in a browser: one tap filters, a drag moves, a swipe completes.

## What Changes

- A Tasks screen over every project and the project screen share one task screen: a filter bar taking tix's
  filter expression, one-tap chips (mine, starred, snoozed, blocked, due windows, show finished), sort and
  direction, and a List, Board or Lanes switch.
- The list is keyset paged, grouped by status or project when asked, pulls to refresh, swipes to complete,
  snooze, assign to me or star, and enters a multi-select mode with a bulk bar: move, priority, tag add and
  remove, assign, star, unstar, copy and delete, all with one Undo.
- The board draws a workflow's columns, refuses (with the list in its place) when the selected projects run
  workflows that disagree, and moves a card by drag, optimistically, with haptics and Undo.
- Lanes draw one lane per project. Columns and lanes carry tix's per-reader arrangement from the view API:
  star, collapse, move, hide and reset.
- Saved filters (own and shared) are chips above the list, saved, renamed, shared, reordered and deleted.
- My work: the reader's open assigned tasks under deadline headings, arranged by the `mine` view.
- The projects screen shows each project's open count and colour.
- Keyboard: `j`/`k` move, Enter opens, `x` selects, `/` filters, `v` switches the view, Escape clears.

## Impact

- New capability `task-views`; `task-browsing` changes how a project's tasks are listed.
- Operations used: `task.list`, `task.bulk`, `task.star`, `task.unstar`, `task.snooze`, `task.unsnooze`,
  `view.groups`, `view.group.set`, `view.order`, `view.reset`, `filter.list`, `filter.save`, `filter.update`,
  `filter.delete`, `filter.order`, `workflow.list`, `project.list`, `stats.read`, `identity.whoami`.
- Every call goes through the generated client; the operations above move from pending to bound in the parity
  registry. No new dependencies.
