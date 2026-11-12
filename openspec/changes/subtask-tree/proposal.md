# Proposal

## Why

The web's task screen draws the whole subtask tree under a task, three levels at a time, with a fold arrow on
every node that has subtasks of its own. The app listed only the direct subtasks, so a plan broken down two or
three levels deep had to be walked one screen at a time.

## What Changes

- Subtasks on the task screen draw the tree from `GET /tasks/{ref}/tree`, read four levels deep and drawn three,
  each level indented under its parent.
- A node with subtasks carries a fold arrow. Every node starts open; folds last while the screen is open.
- A node on the third level with subtasks of its own offers "Show N subtasks", which reads that node's tree and
  draws it in place, again three levels deep.
- A tree the server refuses as too large to walk is read one level deep, with a line saying so, as the web does.
- The count beside the heading stays the direct subtasks, as on the web. The delete confirmation counts every
  subtask when the whole tree was read, and otherwise says they are deleted at every level.
- Offline drafts still show as direct subtasks, and the tree is cached for offline reading.

## Impact

- Capabilities: `task-detail`.
- Code: `data/models/subtask_tree`, `data/repositories/task_detail_repository`, `features/tasks` (subtasks
  provider, subtasks section, delete confirmation), l10n, README.
