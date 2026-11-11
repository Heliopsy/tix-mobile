# Draw blocked in red

## Why

tix draws the `blocked` category in red: the terminal always has, and the web now does too. The app drew it in
the warning amber, on status pills, board columns, the inbox summary, the row's "blocked by another task" mark and
the home screen widgets, so one state was a different colour here than on every other surface.

## What Changes

- `TixTokens.status(StatusCategory.blocked)` is `danger` instead of `warn`, in light, dark and OLED black. Every
  status pill, column header, row dot and summary bar reads it, so they all follow.
- The row's mark for a task blocked by an unfinished dependency is drawn in `danger`.
- The Android and iOS home screen widgets map `blocked` to their `danger` token.
- docs/design.md and docs/widgets.md say blocked is `danger`; `warn` is left for warnings and due soon.
- The component goldens that show a blocked task are regenerated.
