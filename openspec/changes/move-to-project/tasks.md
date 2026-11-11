# Tasks

## 1. Spec

- [x] 1.1 `task-detail` and `task-views` deltas

## 2. Data

- [x] 2.1 `TixException.missingRoute` tells a server without a route from a missing record
- [x] 2.2 The repository sends `task.move` and reports a server without it
- [x] 2.3 Bind `task.move` in the capability registry

## 3. Task screen

- [x] 3.1 `TaskDetailController.moveToProject`, reloading every list
- [x] 3.2 Per-connection move support, refused by an unknown route
- [x] 3.3 The move sheet: other projects, starred first, what the move does, Move once one is picked
- [x] 3.4 Task menu (phone screen and desktop panel) and command palette, not on offline drafts
- [x] 3.5 Open the new reference and toast the old and new reference, a lost status and dropped fields
- [x] 3.6 Refusals with the server's reason

## 4. Bulk

- [x] 4.1 Bulk bar action sending `move_project`, the lists reloading, no Undo

## 5. Strings and docs

- [x] 5.1 Strings in English, Bulgarian, German and French
- [x] 5.2 README feature list

## 6. Tests

- [x] 6.1 Controller: request, answer, reload, refusals, missing route
- [x] 6.2 Sheet, move and navigation, toast details, 409, older server, no other project, palette
- [x] 6.3 Bulk bar request and no Undo; listing reloads after a bulk move
