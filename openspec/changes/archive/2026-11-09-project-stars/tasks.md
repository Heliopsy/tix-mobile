# Tasks

## 1. API

- [x] 1.1 Pin `tix.lock` to #293's merge commit on tix `main`, sync `api/tix-openapi.yaml`, regenerate the
      client, move the engine notices
- [x] 1.2 Bind `project.starred`, `project.star` and `project.unstar` in the capability registry

## 2. Data

- [x] 2.1 `StarredProjects` and `starredFirst` in `data/models/project.dart`
- [x] 2.2 `ProjectsRepository.starred`, `cachedStarred`, `star`, `unstar`, with the gate on 404 or 405
- [x] 2.3 `OutboxOp.projectStar` and `projectUnstar`: sender, replayer (404 refused, lost answer done), overlay

## 3. App

- [x] 3.1 `ProjectStars` provider with optimistic change, refresh on `project.*` and `view.arranged` on lanes
- [x] 3.2 `ProjectStarButton` on project rows and beside the project's title
- [x] 3.3 Starred section on the projects list, starred projects left out below
- [x] 3.4 Starred first, marked, in the switcher, bulk copy and quick add; starred first in the widget catalog
- [x] 3.5 Sync screen names queued project stars
- [x] 3.6 Strings in English, Bulgarian, German and French

## 4. Tests

- [x] 4.1 Model, repository, sender and replayer tests
- [x] 4.2 Provider test: load, gate, optimistic change and rollback, live refresh
- [x] 4.3 Widget tests: projects list at both widths, toggle, rollback, older server, pickers, widget catalog
