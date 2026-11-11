# Proposal

## Why

Rows in the task list, and cards on the board and lanes, kept an accent mark after a task was opened with a tap or
a click. The keyboard cursor was moved to every task opened, including by pointer, and never cleared, so the card
stayed filled with the accent tint and the row kept the accent edge. On a wide window the open task also stayed
highlighted after the window narrowed and the panel went. With tix's default teal accent this reads as a green
highlight that never goes away. Separately, a row whose done status was only recognised once the workflows loaded
washed green as if it had just been ticked.

## What Changes

- The keyboard cursor appears only when the keyboard moves it. A pointer press on the list, board or lanes hides
  it, and opening a task with a tap or click no longer places it.
- The open task is highlighted only while its panel is shown beside the list.
- A row only animates the tick when the task itself changes, not when its status category becomes known.

## Impact

- Capabilities: `task-views`, `adaptive-layout`.
- Code: `features/tasks/presentation/task_screen.dart`, `core/design/components/task_row.dart`, tests.
