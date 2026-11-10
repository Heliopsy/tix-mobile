# Proposal

## Why

On a wide window a project's list was squeezed into a 420 pixel column next to a pane that only said "Pick a task
to see it here." The list never used the window, and a task opened beside it got a fixed split that could not be
resized, unlike a task opened beside a board.

## What Changes

- With no task open, the list takes the whole width. The empty second pane is gone.
- An open task shows in the same resizable, closable panel the board and lanes use, at every view.

## Impact

- `lib/src/features/tasks/presentation/task_screen.dart`, `task_list_screen.dart`
- The `noTaskSelected` string is removed.
