# Proposal

## Why

tix v0.57.0 moves a task into another project (heliopsy/tix#310): `POST /api/v1/tasks/{ref}/move` with a
`project_ref`. The task keeps its identifier, comments, artifacts, history, links, tags and assignee, takes the
target's next number, and its old reference keeps resolving to it. Its status is kept when the target's workflow
has it, else it starts in the target's initial state, and custom fields the target does not define are dropped.
The bulk endpoint gains `move_project`, answering each task's new reference as `moved_ref`. The web offers
"Move to…" on the task screen and in the bulk bar. Until now the app could only copy a task across, which leaves
the original behind.

## What Changes

- "Move to project…" in the task menu, which the phone's task screen and the desktop task panel share, and in
  the command palette beside Copy to….
- A sheet lists the other projects, starred first. Once one is picked it says what the move does: the new
  number, the old reference that keeps leading to the task, and what happens to the status and custom fields.
- On success the app opens the task under its new reference, every task list reloads, and a toast names the old
  and new reference, adding when the status started over and which fields were left behind.
- The bulk bar gets the same action, sent as one `move_project` request. It has no Undo: moving back would give
  each task yet another number.
- Refusals use the usual error toast with the server's reason: 403, 404 (task or project), 409 (claimed by
  somebody else), 422 (archived target), 400 (already there).
- Hidden on an offline draft, and for the session once a server answers the route as unknown.

## Impact

- Capabilities: `task-detail`, `task-views`.
- Code: `core/errors` (telling a missing route), `data/repositories/task_detail_repository`, `features/tasks`
  (detail controller, move sheet, task menu, palette, bulk bar, listing reload), `core/capability` (binds
  `task.move`), l10n, README.
