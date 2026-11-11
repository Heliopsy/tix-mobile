# Proposal

## Why

The web calls the tenant's live event feed Activity, at `/activity`, with a pulse-line icon. The app called the same
feed Watch, so the two surfaces name one thing differently.

## What Changes

- Watch becomes Activity everywhere a person reads it: the rail and More, the screen title, the palette's Go to
  Activity, keyboard settings, the tray menu and the screen's messages, in English, Bulgarian, German and French.
- The destination moves to `/activity`. `/watch` and `/manage/watch` redirect there, and `tix://activity` joins
  `tix://watch`, which keeps working. The tray opens `tix://activity`.
- The destination's icon becomes a line chart, the closest Material icon to the web's pulse line.
- `g w` stays bound, so nobody's muscle memory breaks; `g a` is already Manage.

## Impact

- Capabilities: `event-watch`, `desktop-integration`, `live-updates`, `adaptive-layout`.
- Code: `core/router`, `core/platform`, `core/desktop`, `core/widgets/desktop_host`, `features/shell`, l10n, docs.
  The `features/watch` folder and its class names stay as they are.
