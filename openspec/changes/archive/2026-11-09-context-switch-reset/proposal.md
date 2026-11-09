# Switching context starts the new one fresh

## Why

Switching to another tenant, connection or instance kept the screen the app was on. Sitting on
`/projects/OPS/tasks/OPS-12` and switching asked the new context for `OPS-12`, which is a 404 at best and someone
else's task at worst. The other tabs kept their stacks as well, so opening one later did the same with whatever
workflow, user or channel it last showed.

## What Changes

- A move to another context takes the shell down before the session changes: every tab's stack, and every sheet
  and dialog over it, goes with the old context. A switching screen shows until the new one is active.
- Without a target the app lands on the root of the tab that was showing (Projects, Inbox, Manage and so on).
  The instances and about screens hold nothing of a context and stay.
- A switch with a target (a `tix://` link naming a context, ADB `open`, a home screen widget tap) lands on that
  target in the new context, with the other tabs at their roots.
- Activating the active context again, or the session reloading with the same context, moves nothing.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `tenants`: switching drops the old context's screens and lands on the tab root or the switch's target.

## Impact

- `lib/src/core/session/session.dart`: `activate` takes a `landing`, and a move between contexts goes through
  `ContextMoves`, which the router fills in.
- `lib/src/core/router/router.dart`: the signed-in hosts sit in a `ShellRoute` around the `StatefulShellRoute`,
  with a `/switching` route beside it; `redirectFor` holds everything there while moving; `landingFrom`.
- `lib/src/core/widgets/deep_link_host.dart` and `lib/src/features/widgets/application/widget_sync.dart` pass
  their target as the landing.
