# Proposal

## Why

tix keeps saved filters on the server with an order (`position`, `PUT /api/v1/filters/order`) and the view the
task screen opens in (`view`: list, board or lanes). The web saves the view with a filter, and opening one sets
its view switch; the sidebar menu moves one of the reader's own filters up or down, offered only where it has a
neighbour. The app already saved and restored the view, and its menu moved filters, but it offered both moves
on every filter, gave no way to drag the list into order, and never said that a saved filter keeps the view.

## What Changes

- Settings, Saved filters lists the reader's own filters as a reorderable list: drag a row by its handle to
  reorder, stored with `filter.order`. Shared filters stay below, by name, and do not move.
- The saved filter menu offers Move up only where the reader has an own filter above it and Move down only where
  one is below, as the web does.
- The save sheet says that the filter keeps its sort and the view in force, naming the view.
- Each row in Saved filters names the view the filter opens in, when it names one.

Lane grouping (by project, assignee, ...) is not part of a saved filter: tix stores only list, board or lanes,
and the web keeps its lane grouping elsewhere too. Applying a filter keeps the grouping the screen has.

## Impact

- Capabilities: `task-views`.
- Code: `features/tasks` (saved filters state, the menu, the save sheet, the Saved filters screen).
- No API change: `filter.save` already takes `view` and `filter.order` already exists in tix v0.61.0.
