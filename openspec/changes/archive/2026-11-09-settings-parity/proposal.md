# Proposal

## Why

Settings held the theme, the language, notifications, instances and About, with nothing saying which of them stay
on this device and which the server keeps. tix's web Settings offers more (date format, time zone, inbox,
saved filters, arrangements), and some of those live with the person's account so they follow them everywhere.
The app ignored the reader's date preference entirely: every date was written in the device's locale and zone,
so a person who chose `dotted` or `Europe/Sofia` on the web saw something else on their phone.

## What Changes

- Settings is grouped by where a setting is kept: **This device**, **Your account on <tenant>** and, for
  administrators, **This tenant**. Every section carries a label saying so ("On this device", "Synced to your
  account", "Whole tenant").
- New device settings: reduce motion, touch feedback, and the screen the app opens on.
- New account settings: date format and time zone (`GET`/`PATCH /me/time`), showing what is in force and where it
  came from (your choice, the tenant default, the server default) and offering Inherit; a saved filters screen;
  resetting the board, lanes and My work arrangement (`view.reset`). Inbox kinds and channels link to their screen.
- This tenant links into the Manage hub rather than duplicating it.
- Every date and time on every screen follows the effective server preference (person, then tenant, then
  deployment, resolved by tix), with the device's locale formats and zone only where the server names none or
  cannot answer.
- A search field filters every setting, and the command palette offers "Settings: …" for each.

## Impact

- Capabilities: changed `app-settings`; new `reader-time`.
- Operations bound: `time.settings`, `time.prefs.set`.
- `timezone` becomes a direct dependency (it was already in the tree through `flutter_local_notifications`); pure
  Dart, every platform.
- tix gaps: no week-start preference and no language preference on the account (the web keeps language in a
  cookie per browser), so the app keeps language per device and offers no week start.
