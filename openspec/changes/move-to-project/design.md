# Design

## One sheet picks and confirms

The move is not destructive, so it does not go through `confirmDestructive`. `askMoveProject` is one sheet: the
projects from `copyTargetsProvider` (the copy sheet's, archived ones already out) drawn with `ProjectOption` and
starred first as `showProjectPicker` draws them, the task's own project left out, then a line that changes once a
project is picked and says what the move does. The Move button stays disabled until then. The bulk bar uses the
same sheet with its own title and wording, and leaves out the source project only when every picked task is in
it; a task already in the target is refused by the server and named in the partial toast.

## Where the moved task goes

`TaskDetailController.moveToProject` answers the generated `TaskMove`. The screen then goes to
`Routes.task(project, newRef)`: on a phone that is the task screen under its new reference, on a wide window the
target project's list with the task open beside it. The toast is raised on the root navigator, as delete does,
since the hub it came from is gone.

## Lists and caches

A move takes a task out of one project's lists and into another's, so `tasksChangedProvider` ticks and every
listing reloads, the way a quick add does. The detail and section providers for the old reference are dropped
with the hub; the old reference still resolves on the server, so a stale link or cache entry opens the moved task.

## Errors

The server's reasons matter here (claimed by somebody else, archived target, already there), and the generic
conflict text would drop them, so the toast uses `errorDetail`, which adds the server's message.

## Older servers

A server before v0.57.0 answers `POST /tasks/{ref}/move` with 404 `no such route` (or 405). The repository turns
that into `TaskMoveUnsupported`; `TaskMoveSupport` flips to false for the connection until the session changes,
and the menu item, the palette command and the bulk action go. `TixException.missingRoute` tells such an answer
from a 404 for a missing task or project, which names it.

## No Undo for a bulk move

`undoRequests` answers nothing for `move_project` and the bulk toast offers no Undo for it. Moving the tasks back
would number them again in their old project, which is not what Undo promises.
