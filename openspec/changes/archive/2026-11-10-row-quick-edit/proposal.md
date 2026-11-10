# Quick edits and a completion animation on task rows

## Why

Ticking a task on the list changed the row in one frame: the circle filled, the title was struck through, and
when the list grouped by status the row jumped to another group before anyone saw it was done. Nothing told the
hand that it had worked. Changing anything else about a task, its priority, status, assignee, due date or tags,
meant opening it, although the row already drew the status and priority. tix web makes both of those controls on
its list rows.

## What Changes

- Ticking a row plays a short completion: the circle fills with a small bounce and the check draws from left to
  right, the title is struck through from left to right and fades to muted, and the row washes green and fades
  back. A light haptic fires on the tick. Unticking plays it backwards. With reduced motion it changes at once.
- A row just ticked keeps its place while that plays, then moves to its new place, or collapses away when the
  listing no longer holds it. Only the drawing waits; the move is sent at once, and Undo works as before.
- The status pill and the priority mark on a list row open the move sheet and the priority picker. Ctrl, Cmd or
  Shift on them picks the row, and in select mode they only pick.
- The row's action sheet (dots, secondary click, and the board and lane cards) gains Move to, Assign to, Priority,
  Due date and Add tag, each applied to the row at once with Undo.
- Keys on the focused row: `m` move, `p` priority, `a` assign, `u` due date, `t` add tag, as on the task screen.
  They are left to the task when it is open beside the list.

## Capabilities

### Modified Capabilities

- `task-views`: the row's quick actions, its in-place status and priority, the completion animation and the keys.

## Impact

- `lib/src/core/design/components/task_row.dart`: `TaskRow` and `TaskCheck` animate the change of done
- `lib/src/core/design/tokens.dart` (`TixMotion.settle`), `motion.dart` (`TixHaptics.light`)
- `lib/src/features/tasks/presentation/`: `task_list_view.dart` (holds and collapses), `task_actions.dart`
  (priority, due date, tag, menu), `task_screen.dart` (keys), `select_mode.dart`
- `lib/src/features/tasks/application/listing.dart`: `sendPatch` and `sendTag`
- Strings in English, German, French and Bulgarian
