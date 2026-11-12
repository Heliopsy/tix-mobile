# Proposal

## Why

A row's tick sent the task to the workflow's first done state, or back to its initial state, without asking.
In a workflow with two finishing states (done and shipped, say) that wrote a history nobody chose, and in one
where finishing needs a comment or a scope the reader lacks, the tick was offered and then refused. The web's
lanes pick the tick's routes the way tix's `tickRoutes` does: one route is a box, several are a menu, none is
a dashed tick that says why. A row's snooze also offered only three presets, while the web and the app's own
task screen offer Pick a date as well.

## What Changes

- The tick, on list rows and lane cards and in a row's menu, follows the web's rules: the shortest route to
  each terminal done state when completing, the routes with the fewest steps to an open state when reopening.
  One candidate is applied at once. Several are a menu naming each destination, and for a route through other
  states the journey and its length. A route picked from the menu that passes through another
  state is sent as an explicit `POST /tasks/{ref}/route` with `route`, so the journey picked is the one written.
- A tick with no usable route is drawn dashed and stays pressable: it says why ("Not from here: finishing it
  needs a comment."). The reasons are the web's: no right to move tasks, the workflow could not be read, no
  route, a comment needed, a scope needed.
- A row's snooze menu offers Later today, Tomorrow morning, Next week and Pick a date, the same choices as the
  task screen, plus Wake now on a snoozed task.

## Impact

- Capabilities: `task-views`.
- Code: `data/models/workflow` (routes and the tick plan), `data/repositories/task_list_repository` and
  `data/offline/sender` (explicit routes, offline too), `core/design` (`TaskCheck.locked`, `TaskRow` and
  `TaskCard`), `features/tasks` (tick, snooze), l10n.
