# Design

## One source of truth

The lists read `Connection.refused` and nothing else. They never read secure storage: the context directory is
synchronous, and reading a secret per row would be slow on some keyrings.

0.22.0 left a refused sign-in with its session deleted and no `refusedAt`. `InstancesRepository.migrate` now calls
`markSignedOut` once per run, which stamps `refusedAt` on every remote sign-in whose session is missing. The same
covers a device restored without its keychain. A session secure storage cannot read right now is left alone, so a
locked keyring does not sign anyone out. After 0.22.1 every refusal records `refusedAt` itself, so the check only
finds old or lost sessions.

Such a connection was already sent to reconnect when made active, because `awaitingSignIn` names any sign-in with
no session. Marking it refused changes nothing there, and `openStoredFeed` and the widget writer already skip it.

## One widget

`RefusedMark` in `core/widgets/refused_mark.dart` draws the icon and the line and carries the semantics label. It
draws nothing for a connection that is not refused. The instances screen and the switcher sheet put it under the
row's details; both are features, so the widget lives in `core`.

## Taps

`activateEntry`, which the switcher and the palette's "Switch to" commands share, goes to `Routes.reconnect` for a
refused connection instead of activating it. The instances screen does the same on a row tap, including for the
active connection, and adds Sign in again to a refused token's menu.

## Clearing

`InstancesRepository.save` already clears `refusedAt`, and saving activates the connection, which rebuilds the
context directory. No new code is needed for the mark to go.
