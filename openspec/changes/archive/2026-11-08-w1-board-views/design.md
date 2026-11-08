# Design

## One selection, three drawings

As on the web, the list, the board and the lanes draw the same query. `TaskQuery` holds the expression, the
fixed scope (a project, or My work), the sort, the direction and whether finished work is shown. A listing
provider is keyed by the query, so switching the drawing never refetches, and changing the query starts at the
first page again. The listing is kept alive for a few minutes after the last screen leaves it, which makes going
back instant until the offline cache lands.

## The filter expression

`GET /tasks` takes parameters, not the expression. tix's CLI parses the expression on the client
(`internal/query`) and sends parameters (`internal/client/tasks.go`), and the app does the same in
`data/query/filter_expression.dart`, a port that maps terms to parameters and leaves values to the server.
Priority names become numbers, `due:` windows become bounds against the clock, `me` passes through. An
unknown key is refused before sending, with tix's message. A saved filter is checked by the server on save.

## Open work by default

The list narrows to the unfinished states of the tenant's workflows when the expression names no status, as
the web does. The board and lanes are exempt. The Finished chip turns the narrowing off.

## Board columns

The board needs one workflow. The projects a query can draw from are the `project:` terms, or the scoped
project, or every project. When their workflows' states and transitions agree structurally, those states are
the columns; otherwise the board is refused with a notice naming the workflows and the list is drawn. A drag
lights only the columns the card's own workflow reaches without a required comment. The move goes out as a
one-task `task.bulk` move, which walks the shortest route, and Undo moves it back the same way.

## Quick actions

Complete moves a task to its workflow's first terminal state in the done category, reopen to the initial state,
both through `task.bulk` move. Assign to me is a one-task bulk assign with the reader's actor id from
`whoami`. Star and snooze use their own routes. Every one goes through `runOptimistic` and sits in the row's
action sheet as well.

## Bulk Undo

One Undo per batch. The notifier remembers what it changed: a move or assign or priority is undone by one
bulk call per previous value, tag add by tag remove on the tasks that lacked it, star by unstar, copy by deleting
the copies, delete by restore. Refused tasks are named in the toast and left out of the Undo.

## Arrangements

`view.groups` gives the reader's preferences for `board`, `project:KEY`, `lanes` and `mine`. Groups are drawn
in the view's order: starred first, then by position, then the natural order. Changes are optimistic and sent
with `view.group.set` or `view.order`; Reset calls `view.reset`.

## Data layer

Every call goes through the generated client. `TaskListRepository` and `ViewPrefsRepository` keep first pages,
workflows, arrangements and saved filters in the response cache with `cached…` twins; the listing and the task
context load with `cachedFirst` and reload on `task.*`, `tag.added`, `project.*` and `workflow.updated` events.
Row quick actions are `OptimisticChange`s from the listing notifier, run through `runOptimistic`.
