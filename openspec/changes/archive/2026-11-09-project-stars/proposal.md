# Star projects

## Why

tix now lets a person star projects as their own favourites (heliopsy/tix#293): the web lists them first, the
sidebar keeps them, the terminal stars with `*`. On the phone the projects list and every project picker are in
server order, so the projects someone opens all day sit wherever the server puts them.

## What Changes

- Bump `tix.lock` to the tix commit that adds `project.starred`, `project.star` and `project.unstar`, with the
  vendored OpenAPI document, the generated client (`Project.starred`, `ProjectOps.star/unstar/starred`) and the
  engine notices moved with it. The three operations are bound in the capability registry.
- A star toggle on every row of the projects list and beside the project's name at the top of its tasks. It
  changes at once, is put back with the server's reason when refused, and has Undo.
- The projects list draws a Starred section first and the other projects under it, each project once.
- The project switcher, bulk copy, quick add and the Project widget's picker list starred projects first, marked
  with a star.
- A star made while the server is out of reach goes through the outbox like a task star, and is drawn on the
  list until it is sent.
- The stars are read again when a project changes or a lane star changes (`view.arranged` on `lanes`), since a
  project star is the star on its lane.
- On a tix without project stars (`/me/starred-projects` answers 404 or 405) no star control is drawn.

## Capabilities

### New Capabilities

- `project-stars`: starring projects, the Starred section, starred-first pickers, live refresh and the gate.

### Modified Capabilities

- `offline-sync`: project stars queue in the outbox.

## Impact

- `tix.lock`, `api/tix-openapi.yaml`, `assets/licenses/libtix.json`, `lib/src/data/api/gen/`
- `lib/src/data/models/project.dart`, `lib/src/data/repositories/projects_repository.dart`, `lib/src/data/offline/`
- `lib/src/core/session/project_stars.dart`, `lib/src/core/widgets/project_star_button.dart`,
  `lib/src/core/design/components/project_option.dart`, `lib/src/core/capability/registry.dart`
- The projects screen, the task screen's switcher, bulk copy, quick add, the sync screen and the widget catalog
- Strings in all four languages
