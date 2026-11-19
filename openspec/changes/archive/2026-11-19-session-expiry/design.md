# Design

## Where the 401 is noticed

The cause was that no layer owned "this credential was refused". The periodic sync, the outbox replayer and every
screen built their own client and treated a `401` as one more failed request. Patching each of them would leave the
next caller with the same bug.

`tixApiFactoryProvider` now wraps the bare factory (`tixClientFactoryProvider`, which tests swap for the fake
server) and adds a `RefusalInterceptor` to every client that presents a credential. The interceptor lives in
`data/api` and only reports the credential to a callback; it changes no error and makes no decision. The reports go
to `credentialRefusalsProvider`, a broadcast stream the `SessionController` listens to. Every client in the app,
foreground or background, goes through that factory.

## Checking before signing out

tix answers `401` for more than a dead session: a wrong TOTP code on `POST /auth/totp/confirm`, or a wrong code on a
tenant switch, comes back as `unauthenticated` on a request that carried a good cookie. The refusal reason
(`session_expired`, `session_idle`, `unknown_session`) is only in the server's log, never in the answer. So the
controller asks `GET /whoami` with the same credential once. tix has no refresh route, and `whoami` on a live
session is itself a use that renews it, so this is the only renewal there is. If `whoami` is refused too, the
session is gone; otherwise nothing changes. One check runs at a time, so a sync that gets four `401`s at once costs
one extra request.

## Signing out

The controller cancels the connection's jobs with a new `ConnectionJobs.cancel`, which, unlike `stop`, does not
refuse later work: the connection keeps its id when the person signs in again. It deletes only the stored session.
The connection, its email, its instance, its cache and its outbox stay, so queued writes are sent after the next
sign-in. With no session, `OfflineSync` and the outbox replayer rebuild without their timers, and live updates
stop.

The router gets `awaitingSignIn`, the active sign-in connection while there is no session, and sends every
location but the connect screen to `Routes.reconnect` for it. That also covers an app started after the session
was dropped. Back from that screen goes to the plain connect screen, where another server can be added.

Connections being removed are skipped, since their logout may be answered `401` too.

## Notification

`NoteChannel.account` is a third Android channel. The note has one fixed id, so a second expiry replaces it, and
`saveSignIn` cancels it when it replaces a connection.

## Not covered

The home widgets' headless background run reads stored credentials without a `SessionController`. It does not
sign out; the next time the app runs, the first `401` does.
