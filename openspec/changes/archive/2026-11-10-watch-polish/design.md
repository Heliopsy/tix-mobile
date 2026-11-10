# Design

## What the server sends

An event carries `actor_id`, `payload.actor_handle` and `via` (`kind`, `token_name`, `job`, `origin`). It does not
carry the actor's display name, so Watch reads the tenant's actors once (`actor.list`) and maps ids to names. When
that is refused, rows fall back to the handle.

`comment.added` carries only `ref`, `task_id` and, for an edit, `edited`; no body and no author. Watch reads the
task's comments (`comment.list`) when a comment row is built and finds the comment by `subject_id`. A new comment
event invalidates that task's list so the next row sees it. There is no endpoint for one comment by id.

`task.updated` names the changed fields (`fields`) but not their values, so the row names the fields, using the CLI's
labels (`body` is "description", `due_at` "due date"). `task.created` carries `title` and `status`, a transition
`from` and `to`. Priority is not in any task event payload, so no priority mark is shown.

## Colours

The web's activity badges use ok for a creation, the accent for a change, danger for a deletion and warn for an
expired lease, everything else neutral. Watch maps event types the same way onto `TixBadge` tones, so the colours
come from the design tokens and follow light and dark. States use `StatusPill`, projects `ProjectChip`, actors a
hued `TixAvatar`.

The web groups consecutive changes to one record into one row. Watch does not: it is a tail in `seq` order, and the
sequence number is the resume cursor, so every event stays its own row.

## Motion

`LiveIndicator` gains `pulse`. Only Watch turns it on: the indicator sits in the shell on every screen, and a
repeating animation there would keep every screen from settling. The pulse is a fade between 30% and full opacity,
stopped at full opacity while `MediaQuery.disableAnimations` is set (the platform setting or the app's own reduce
motion switch) or while the route is offstage.

## Navigation

Rows `push` the task route instead of `go`. Watch stays in the stack under the task, so its widgets, scroll
position and filter survive, and the feed provider is kept alive while the screen is mounted, as before.
