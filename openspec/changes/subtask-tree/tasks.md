# Tasks

## 1. Spec

- [x] 1.1 `task-detail` delta

## 2. Data

- [x] 2.1 `SubtaskTree`: nodes from the depth-first list, drawn three levels, the fourth counted
- [x] 2.2 The repository reads `task.tree` at depth 4, falls back to depth 1 on `precondition_failed`, caches both

## 3. Task screen

- [x] 3.1 The subtasks provider answers the tree, drafts and new subtasks as direct subtasks
- [x] 3.2 Indented rows, fold controls, "Show N subtasks" loading in place, the too-large line
- [x] 3.3 The delete confirmation counts every subtask, or says every level when the tree was not read whole

## 4. Strings and docs

- [x] 4.1 Strings in English, Bulgarian, German and French
- [x] 4.2 README feature list

## 5. Tests

- [x] 5.1 Model: levels, the fourth counted, drafts as direct subtasks, shallow
- [x] 5.2 Repository: depth 4, the fallback, no retry on other errors, the cache
- [x] 5.3 Section at compact and expanded width: indentation, folding, a deeper level, too large, error and retry
- [x] 5.4 Delete confirmation counts
