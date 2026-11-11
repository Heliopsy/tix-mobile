# Proposal

## Why

tix is adding emoji reactions to comments (Heliopsy/tix#TIXPR): a fixed set of eight, toggled with
`PUT`/`DELETE /api/v1/comments/{id}/reactions/{reaction}`, summarised on every comment as `reactions`, and announced
as `comment.reacted` and `comment.unreacted`. People want to acknowledge a comment without writing one, and the
web and CLI get it first.

## What Changes

- Each comment shows its reactions as chips, emoji and count, the reader's own ones highlighted. Tapping a chip
  toggles the reader's reaction. A small button beside them, and a long press on the comment, open a picker of the
  eight.
- A toggle draws at once and is undone with a message when the server refuses it.
- A server that predates reactions shows none and, once it refuses a reaction as an unknown route, offers none.
  The embedded engine is pinned at tix v0.53.0, before reactions, so a local instance offers none.
- The comments of an open task refresh on `comment.reacted` and `comment.unreacted`.
- Until `tix.lock` pins a tix release that describes reactions, the two calls and the listing that keeps the
  `reactions` field are written by hand beside the generated client. `api/tix-openapi.yaml` stays tix's document.

## Impact

- Capabilities: `task-detail`, `api-client`.
- Code: `data/api` (reaction calls), `data/models` (reaction summary), `data/repositories/task_detail_repository`,
  `features/tasks` (comments provider, comment tile, picker), `core/events/invalidation`, l10n.
