# Project pickers show the project's mark

## Why

The project switcher at the top of a project's tasks lists projects as plain text, and so do the copy, template,
transfer and delete-target pickers. The project list draws every project with its icon and colour, so the picker
is the one place a person cannot spot a project by its mark.

## What Changes

- A shared `ProjectOption` in the design system: the project's mark, its name and key, an archived badge, and a
  check on the current one.
- `showProjectPicker` opens a sheet of them. The task screen's switcher and bulk copy use it.
- The quick add, template, copy, transfer and project-delete pickers draw their choices with the same mark.
- The switcher's closed state shows the built-in icon too, not only a text icon.

## Impact

- `lib/src/core/design/components/project_option.dart`, `pickers.dart` (`TixOption.leading`)
- The task screen, bulk bar, task copy sheet, quick add, templates, transfer and project delete sheet
