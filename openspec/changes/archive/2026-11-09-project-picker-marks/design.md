# Design

## One component for a project as a choice

Every picker draws the same row, so `ProjectOption` lives in `core/design` next to `ProjectMark`, which it reuses.
Features never import each other, and the project list's `ProjectTile` is not reused because it navigates and
watches the open count.

The row reads the project model directly, as `TaskRow` reads a task. The mark is decorative: the row's semantics
label is the project's name, with "archived" as its value and the selected flag on the current one.

## Fallback

A project without an icon or colour gets `ProjectMark`'s monogram on a muted tint, as in the project list. The
uploaded icon image is not drawn in pickers, matching the project list, which does not fetch it either.

## Select fields

`TixSelectField` gains an optional `leading` widget per option, so the delete sheet's target field can show the
mark without a second dropdown style.
