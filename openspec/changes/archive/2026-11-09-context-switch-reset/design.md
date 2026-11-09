# Design

## Where the reset happens

The session decides whether a move leaves the active context, since it knows both ends. The router knows how to
take screens down. `ContextMoves` joins them: a holder in `core/session` with a `leave` and a `land` hook that the
router fills in when it is built. Without a router (unit tests, screen tests) both are null and a move only changes
the session.

`SessionController.activate` compares the target with the active context: same connection, and the same tenant
where both sides know it. A different one calls `leave`, activates, then `land(landing)` in a `finally`, so a
failed activation still leaves the switching screen. Code challenges and refusals throw before `leave`, so a
switch that never happens moves nothing.

## Why the shell is taken down, not patched

`StatefulNavigationShellState` keeps each branch's last location privately, and go_router has no way to reset an
inactive branch. Navigating every branch back to its root one by one would build each old screen once more
against whichever context is active. What does reset the branches is the shell leaving the tree: its state is
disposed, and the next visit builds fresh branch navigators at their initial locations.

So `leave` pops the pageless routes on the root navigator (sheets and dialogs opened from the hosts), goes to
`/switching`, and waits for a frame to be drawn there. The `StatefulShellRoute`'s page is replaced in that frame,
which disposes the shell, its branch navigators and every sheet on them. Only then does the session change, so no
screen of the old context is still listening when the repositories rebuild against the new one, and none fetches
its old id there.

Waiting for the frame matters: Riverpod rebuilds listened providers on its own schedule, before the widget tree
drops them, so a reset that only followed the new session would still let the old task screen ask once. When the
app is in the background no frame comes; the wait gives up after a short timeout.

## Keeping the hosts

`DeepLinkHost`, `HomeWidgetsScope`, `InboxAlertsScope`, `QuickActionsHost` and the command scopes used to wrap
`HomeShell` inside the `StatefulShellRoute` builder. They now sit in a plain `ShellRoute` around it, with
`/switching` as its other child. Taking the shell down leaves them mounted, which keeps two things working:

- a host that switched context and then acts (a deep link that goes on to open quick add, a widget tap that marks
  an item read) is still mounted to do so;
- the launch link, widget and notification a host reads once at start up are not read again, which would replay
  them in the new context.

## Landing

`land(null)` goes to `landingFrom(left)`: the first path segment when it is a tab root, the location itself for
the instances and about screens, else the start screen. Targeted callers pass the route they open as `landing`:
`DeepLinkHost` (every `tix://` link with a context, which ADB `open`, tiles and shortcuts go through) and
`WidgetSync.open`. Their own `go` after the switch stays; it goes to the same place.

`redirectFor` takes `moving`: while set, everything leads to `/switching`, and `/switching` outside a move leads
home like the splash.
