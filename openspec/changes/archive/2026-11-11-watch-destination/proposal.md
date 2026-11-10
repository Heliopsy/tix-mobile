# Proposal

## Why

Watch was reachable from a bare `stream` icon wedged into the shell's bar and the top of the rail, which reads as a
frozen spinner, and from an entry under Manage. People expect it next to the other destinations, once.

## What Changes

- Watch becomes a destination of its own at `/watch`, between Inbox and Manage, with a sensors icon, always shown
  like the others. Without `event:subscribe` its page explains what is missing.
- The Watch button in the shell's bar and the rail goes away, and Manage no longer lists Watch.
- `tix://watch`, the tray entry, the palette's Go to Watch and `g w` open the new destination. `/manage/watch`
  redirects to `/watch`.
- The refused state points to Instances, where the token can be replaced, instead of going back to Manage.

## Impact

- Capabilities: `event-watch`, `adaptive-layout`.
- Code: `core/router`, `features/shell`, `features/manage`, `features/watch`, l10n (one string removed).
