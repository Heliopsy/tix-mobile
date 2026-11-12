# Design

## Where the grouping lives

`LaneGrouping` sits beside `TaskGrouping` in `data/query/task_query.dart` and `TaskScreenState.lanes` holds the
reader's pick, null for the scope's default. `lanesOf` resolves it against `laneGroupingsFor(scope)`, so a pick of
Project carried to a project screen falls back to Assignee rather than drawing one lane. The web remembers the
pick in a cookie for the task list only; the app keeps it with the rest of the screen state, which lasts while the
app runs. A saved filter stores the view but not the grouping, on the web as here.

## Building the lanes

`buildLanes` is a pure function over the loaded tasks, ported from tix's `lanegroup.go`, so it is unit tested
without widgets. Assignee lanes are keyed by handle, which is what the web's arrangement names them by; a person
whose handle has not loaded yet is keyed by actor id until it does. `assignee:me` names the reader's own lane
through `meProvider`. Tag lanes read the arrangement to decide where a card with several tags goes, so hiding a
tag lane moves its cards to their next tag instead of losing them.

## The heading link

The web's heading is a link to `?q=TERM&view=lanes&lanes=BY`, which replaces the filter. `TaskScreen.showLane`
does the same through `setExpression`, keeping the drawing and the grouping.
