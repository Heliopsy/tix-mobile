# Design

## One provider, explicit state

`TaskSelection` keeps its name and family key (the screen's scope) so the list, board, lanes and bulk bar still
share one selection per scope. Its state becomes `TaskSelectionState`: `active`, the picked `refs`, `sticky` and
the Shift `anchor`.

- `enter()` is the Select button: active and sticky, so unpicking everything keeps the mode on.
- `toggle()` turns the mode on when it was off. When it empties the selection and the mode is not sticky, the
  mode ends, so a long press followed by a tap on the same row leaves the screen as it was.
- `selectRange(order, ref)` adds everything between the anchor and `ref` in the order the view draws them. With
  no anchor in that order it picks `ref` alone and makes it the anchor.
- `exit()` is every way out: Escape, the bar's close button, back, the Select button pressed again and the end
  of a bulk action.

## Taps

`tapTask` reads the modifier keys from `HardwareKeyboard` at the moment of the tap rather than threading pointer
events through the design components: Shift is a range, Ctrl or Cmd picks one, and in select mode a plain tap
picks. Each view passes the order it draws (list entries; visible, expanded columns or lanes in turn), so a
Shift range follows what is on screen.

## The tick in select mode

`TaskCheck(inert: true)` keeps the circle, filled when done, at reduced opacity inside `IgnorePointer` and
`ExcludeSemantics`. A tap on it falls through to the row and picks. The checkbox is a new `TaskPick` so rows and
cards draw the same control with the same "Select" label.

## Where the menu went

The long press used to open the action sheet on list rows and lane cards; it now picks. The sheet stays
reachable:

- List rows get a trailing "more" button (`onMore`), drawn only outside select mode. A secondary click opens the
  sheet, as before.
- Lane and board cards already had the dots; a secondary click now opens the sheet there too.
- The sheet keeps its Select entry.

On a compact board the long press already started a drag. That stays: a long press that is let go where it began
(within touch slop) picks the card, one that moves drags it. Wider boards drag on movement, so their long press
picks directly. In select mode cards do not drag at all.

## Back

The task screen wraps its page in `PopScope(canPop: !active)`. With select mode on, back (Android's button or
predictive back) leaves the mode instead of the screen.

## Goldens

Nothing in the gallery changes: the new parameters default to the old drawing, so the component goldens stay as
they are.
