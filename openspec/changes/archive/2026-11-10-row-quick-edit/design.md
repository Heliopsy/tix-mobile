# Design

## Where the animation lives

`TaskRow` and `TaskCheck` own it, since they are the only things that know a task turned done. Each keeps an
`AnimationController` that starts at the current state, so a row drawn already done never plays anything; only a
change of done animates. The check is the Material check icon revealed by a clip, and the strike-through is
painted line by line over the title while it sweeps. At rest both are exactly what was drawn before (the icon,
`TextDecoration.lineThrough`), so the goldens do not move. Durations come from `TixMotion.of`, which is zero with
reduced motion, and a zero duration sets the end state at once.

## Holding a row in place

The listing is the source of truth and changes the moment the move is applied, so the list view decides what to
draw: when a row turns done and the listing now puts it after a different line, or a refresh drops it, the view
keeps it at the old place for `TixMotion.settle` (440 ms). A dropped row then collapses over `TixMotion.base`.
Every row sits in the same `_Slot` wrapper whether held or not, so the element under it, and the tick playing in
it, survives. Nothing here touches the request: `runOptimistic` sends it as before.

A refresh draws the cached first page before the server's, which shows a ticked task open for a moment. The view
remembers what was ticked while it is drawn, so the row still collapses when the server's page arrives.

## Quick edits

The pickers are the task screen's (`pickPriority`, `pickDue`, `pickTag`, `pickActor`). The writes go through the
listing's optimistic change rather than the task screen's `TaskEdits`, which work on the task detail controller:
that controller is only loaded while the task is open, and changing it does not redraw the row. `TaskListing`
gains `sendPatch` (a `TaskPatch` through `TaskDetailRepository.update`, outbox included) and `sendTag`, and Undo
sends the inverse patch or the opposite tag call.

Like the task screen, the row does not hide edits by scope: the server refuses, the row rolls back and the toast
says why.

## Long press

The request asked for the menu on a long press. Select mode moved the menu off the long press a day earlier on
purpose (a long press picks, and the spec says no action sheet opens), so this keeps it there: the menu stays on
the dots and the secondary click, and gains the new edits.

## Compared with tix web

tix web's list rows make the status pill and the priority caret popover menus and leave tags, assignee and
project as filter links. The app does the same on the row and puts the other edits in the menu, which tix web
does not have, so the row stays as compact on a phone as it was.
