# Proposal

## Why

The task screen only reads. Everything a person does to a task in the tix web UI (rename it, move it along the
workflow, tick its checklist, reassign it, comment, attach a file, snooze, copy, delete) still needs the browser.
The app should do all of it, with fewer taps than the web: edits in place, changes that show at once with an
Undo, keys on desktop and the task beside its list on a wide screen.

## What Changes

- The task screen becomes the hub for one task: every attribute the web edits, edited where it is read.
- Title, description (Markdown, checklist ticked in place), status moves along the workflow including moves
  that pass through other states, priority, assignee from the actor directory, due date, tags, custom fields of
  every type, repeat rule.
- Subtasks (list, add, open), parent and copied-from links, dependencies (list, add, remove, open).
- Comments (list, add, edit, delete, Markdown, `@handle` completion), history from the task's audit trail,
  artifacts (list, attach a file or a photo, open, save).
- Star, snooze with presets, copy into a project with its subtasks, comments and dependencies, delete with Undo
  when the tenant keeps a trash, and permanently with a confirmation.
- Quick changes are optimistic with Undo, keys on desktop, haptics on touch, properties beside the description
  on a wide pane.

## Impact

- New capability: `task-detail`.
- Operations bound in the parity registry (wave 1): `task.update`, `task.check`, `task.route`, `task.star`,
  `task.unstar`, `task.snooze`, `task.unsnooze`, `task.copy`, `task.delete`, `task.restore`, `task.tree`,
  `task.audit`, `tag.add`, `tag.remove`, `tag.list`, `comment.list|add|edit|delete`, `dependency.list|add|remove`,
  `artifact.list|put`, `field.list`, `workflow.get`, `project.show`, `actor.list`, `trash.status`; `task.create`
  gains `parent_ref` for subtasks.
- New dependencies: `image_picker`, to attach a photo from the camera, and `url_launcher`, to open links in
  descriptions and comments.
- Not in tix's API, so not in the app: time tracking, deleting an artifact, the reverse "blocks" list.
