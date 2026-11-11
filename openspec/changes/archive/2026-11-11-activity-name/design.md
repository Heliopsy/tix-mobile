# Design

## Names

Only what a person sees changes. The ARB keys (`watchTitle`, `goWatch`, `trayWatch`, ...), the `features/watch`
folder, `WatchScreen` and the `nav.watch` key action keep their names: renaming them is churn with nothing to show
for it. Key action ids are not persisted (the keyboard setting keeps only the preset id), so no migration is needed.

Identifiers that name a place or an entry do change: `Routes.activity`, `TrayAction.activity`, and the shell
destination id `activity`.

## Old links

`Routes.legacyWatch` (`/watch`) is a redirect-only route beside the shell, and `/manage/watch` keeps its redirect,
both to `/activity`. The deep link parser maps both `tix://activity` and `tix://watch` to `/activity`, which also
covers the desktop host, since the tray goes through the same intake.

## Icon

The web draws a pulse line. Material has no exact match; `monitor_heart` is taken by Server status, so the
destination and the empty state use `show_chart`.
