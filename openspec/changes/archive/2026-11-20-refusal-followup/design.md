# Design

## One place that decides

`RefusedCredentials` (`core/session/refused.dart`) holds the two steps both callers need: `confirmed` asks `whoami`
with the refused credential and answers true only for a `401`; `record` cancels the connection's jobs, stamps
`refusedAt` on the connection, deletes a session (never a token) and shows the account notification. `check` reads
a stored connection's credential and runs both. The `SessionController` uses it for the active connection, heard
through `credentialRefusalsProvider`; the widget writer uses it for any context it reads with a stored credential,
in the foreground and in the headless run.

`record` does nothing when the connection is already refused or when its stored secret is no longer the one that
was refused, so a refusal heard twice, or one that raced with signing in again, changes nothing.

## The refused state

`Connection.refusedAt` is a new optional field, stored with the connection in preferences. It is not a secret.
`SessionController.build` returns no session for a refused connection, so `OfflineSync`, the outbox replayer and
live updates rebuild without timers, exactly as for a deleted session. `awaitingSignIn` answers the active
connection when it is a sign-in or refused, and the router sends everything to `Routes.reconnect` for it. That
path is the same for a refusal heard now and for one a headless run recorded while the app was closed.

`openStoredFeed` returns nothing for a refused connection, so no caller can build a client for it from storage.

## Reconnecting a token

The reconnect screen for a token connection opens on the token form, with the sign-in form one tap away and the
server address fixed. `SessionController.connect` takes `replacing`: the new token lands on the same connection id,
so its cache and outbox stay. Signing in instead turns the connection into a sign-in with the same id and deletes
the old token, since secrets are stored by kind. Both clear `refusedAt` and the account notification, then
activate the connection, which starts sync again.

## Widgets

`WidgetContext` gains `refused`. For a refused context the writer skips the network, removes its My work, inbox and
project snapshots and marks it in the index. Android and iOS draw a refused context as "Sign in again to show this"
and a tap opens the app, which lands on reconnect. Removing the snapshots also means an older widget build shows
"Open tix" instead of stale data.

The writer notices a refusal from a `401` on a snapshot read or on a queued tick (`ActionOutcome.credentialRefused`,
which keeps the tick queued). It then calls the shared check, and the rest of that run already treats the context
as refused. The Android worker keeps its 30-minute schedule because it serves every context; for a refused one a
run reads two preferences and sends nothing.

## Not covered

The connections list in Settings does not mark a refused connection; opening it leads to reconnect.
