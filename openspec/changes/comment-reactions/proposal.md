# Proposal

## Why

tix v0.57.0 adds emoji reactions to comments (heliopsy/tix#318): any single emoji grapheme, added with
`PUT /api/v1/comments/{id}/reactions/{emoji}` and taken away with `DELETE` on the same path, summarised on every
comment as `reactions` (`emoji`, `count`, `actor_ids`), and announced as `comment.reacted` and `comment.unreacted`.
The web shows chips under each comment and a quick picker. People want to acknowledge a comment without writing
one, and the app should do what the web does.

## What Changes

- Each comment shows its reactions as chips, emoji and count, in the server's order. The ones the reader made,
  told by their actor id in `actor_ids`, are highlighted. Tapping a chip toggles the reader's reaction.
- A button beside the chips, and a long press on the comment, open a picker: a row of eight common emoji, the
  same as the web's, and a field that takes any one emoji.
- A toggle draws at once and is put back with a message when the server refuses it.
- A server that predates reactions shows none, and once it refuses a reaction as an unknown route, offers none.
- The comments of an open task refresh on `comment.reacted` and `comment.unreacted`.
- The calls and models are the generated client's, now that `tix.lock` pins v0.57.0. Nothing is written by hand.

## Impact

- Capabilities: `task-detail`.
- Code: `core/errors` (telling a missing route), `core/design` (reaction chips and options),
  `data/models/task_detail`, `data/repositories/task_detail_repository`, `features/tasks` (comments provider,
  comment tile, picker), `core/events/invalidation`, `core/capability` (binds `comment.react` and
  `comment.unreact`), l10n.
