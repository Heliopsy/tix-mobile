# Design

## The contract

From heliopsy/tix#293 (`feat/project-stars`, pinned at 83e131ca):

- `PUT` and `DELETE /api/v1/projects/{ref}/star` (`project.star`, `project.unstar`), 204, scope `project:read`,
  with `Idempotency-Key`. Starring a starred project writes nothing.
- `GET /api/v1/me/starred-projects` (`project.starred`): the caller's starred projects in lane order, not
  paginated, archived ones included.
- `Project.starred`, set only on reads that know the reader (`project.list`, `project.show`), omitted when false.
- A star is the `starred` flag of the reader's own `lanes` group preference for the project, per account and per
  tenant. Starring emits `view.arranged` with `{"view": "lanes", "groups": ["KEY"]}`; there is no
  `project.starred` event.

## Pinning an unreleased tix

`tix.lock` has always pinned tix by commit, never by release (it was at `v0.50.0-73`), and the API description
and the engine move together with it. The pin goes to the head of the server branch so the client is generated,
not hand-bound, and the parity check binds the real operation ids. It must move to the merge commit on tix's
`main` before this merges; the server branch only adds the three operations and the field, so nothing else in
the app changes with it.

## Where the stars live

`ProjectStars` (`core/session`) holds the starred list read from `project.starred`. Features never import each
other, and the projects list, the task screen and quick add all need it, so it sits in `core` with the toggle
widget beside it in `core/widgets`. Every screen reads stars from it rather than from `Project.starred`: the
project list and the task context are cached and not re-read on `view.arranged`, so their flag goes stale after a
toggle. The Project widget's catalog is written in the background from a fresh `project.list` and orders by
`Project.starred` directly.

A toggle is an `OptimisticChange` run through `runOptimistic`: the list changes, the write is sent, a refusal
puts the list back and shows the reason, success shows a toast with Undo (the opposite star). It also bumps
`ArrangementResets` so the lanes draw the moved star.

## Offline

`OutboxOp.projectStar` and `projectUnstar` target the project key. They are additive, so they never conflict.
The replayer sends them through `ProjectOps`; a 404 is a refusal rather than a deleted task (there is nothing to
restore), and an applied-but-lost answer is done without reading a task. The entry carries the project's JSON so
a queued star of a project the server list lacks can be drawn. `ProjectsRepository.starred()` lays the waiting
stars over what the server (or the cache) returned.

## Gate

The read of `/me/starred-projects` answering 404 or 405 makes the provider's value null, which hides every star
and the section. This is the probe `ReaderTime` and the poll fallback use; there is no version comparison.
