# Select mode

## Why

Picking tasks for a bulk action had no mode of its own: it was on while something was picked and off the moment
nothing was. The square checkbox and the round done tick sat next to each other on a picked row, both looked
tappable, and a stray tap on the tick completed a task when the person meant to pick it. The board and lanes
could not pick at all, and the only way in on touch was a long press, then Select in the action sheet. The tix
web app is moving to an explicit Select mode; the phone should behave the same way.

## What Changes

- Select mode is explicit state on the task screen. It turns on from a Select button in the app bar, `x`, a
  Shift-click or Ctrl/Cmd-click, or a long press on a row or card, and can be on with nothing picked.
- In select mode every row and card carries a square checkbox labelled Select, the done tick is muted and inert
  (no tap target, not in the semantics tree), a tap picks, Shift-click picks a range, and the bulk bar shows.
- It is left with Escape, the close button on the bulk bar, back (including predictive back), or by unpicking
  the last task when it was entered by picking one. Entered from the Select button, it stays on with nothing
  picked.
- A long press picks instead of opening the action sheet. The sheet moves to a trailing "more" button on each
  list row, and a secondary click still opens it on rows and cards.
- Keys: Shift+Up and Shift+Down extend the selection, `e` marks the focused task done.
- The board and lanes pick cards the same way, through the same selection and the same bulk bar. On a phone
  board a long press still drags a card; letting go where it started picks it.
- The tick reads "Mark done" to a screen reader and the checkbox "Select"; the bulk bar's count is a live
  region so changes are announced.

## Capabilities

### Modified Capabilities

- `task-views`: select mode, its entries and exits, board and lanes selection, keys, and the row menu moving off
  the long press.

## Impact

- `lib/src/features/tasks/application/screen.dart` (`TaskSelection` now holds `TaskSelectionState`)
- `lib/src/features/tasks/presentation/`: the task screen, list, board, lanes, bulk bar and a small
  `select_mode.dart` with the shared tap and long-press handling
- `lib/src/core/design/components/task_row.dart` and `task_card.dart`: `TaskPick`, the inert `TaskCheck`, the
  row's `onMore`
- Strings in all four languages
