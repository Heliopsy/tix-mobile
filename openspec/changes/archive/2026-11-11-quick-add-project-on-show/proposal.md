# Proposal

## Why

Quick add opened on a project the person was looking at could start in another one. The sheet kept the project on
show only when the cached project list held it, and that list was loaded once per sign-in, so a project created or
joined since, an archived one, or one past the list's cap fell back to the last project used.

## What Changes

- The project on show, or the one a caller asks for, always starts quick add and shows as the picker's choice, even
  when the loaded list lacks it.
- The last project used, then the first, is only the fallback when no project is on show.
- Opening quick add on a project the loaded list lacks reloads the list.

## Impact

- `lib/src/features/quick/presentation/quick_add_sheet.dart`, `quick_actions_host.dart`
