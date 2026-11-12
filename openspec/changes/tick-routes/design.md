# Design

## Routes on the client

`Workflow.routesFrom` ports tix's `core.Routes` (breadth first, at most four equally short routes per state,
at most 16 steps) and `Workflow.tickPlan` ports the web's `tickRoutes` and `routeBlocked`. The reader's scopes
come from `whoami` (`currentAccessProvider`); until it answers the tick is offered and the server decides.

## Sending

A tick with one candidate keeps the existing single-task move with `to`: one candidate means one shortest route,
which is the one tix finds, so offline queueing and Undo are unchanged. A multi-hop route picked from the menu
(where equally short routes may exist) goes through `task.route` with the keys in order; the outbox stores them under `route` beside `to`, and
the replayer sends the same explicit route. A hop the server refuses fails the write with its reason, which
rolls the row back.

## Locked tick

`TaskCheck` gains `locked`: dashed like the placeholder but still pressable, with "Why this cannot be ticked"
as its accessible name. The gallery is unchanged so its goldens stay put; the widget tests cover the variant.
