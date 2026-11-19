# Proposal

## Why

A device kept asking a tix server for its projects and workflows every 30 minutes for hours after its session
expired. Every one of those requests was answered `401`. The periodic sync stored the error and tried again on the
next tick with the same cookie, the timer kept running, and nothing told the person to sign in. A screen showed a
Sign in again button only once somebody opened it.

tix has no route that renews a session. Each use of a live session pushes its expiry out (`session.ttl`, capped by
`session.max_lifetime`), so a session the server has already refused cannot be brought back. It has to be signed in
again.

## What Changes

- Every API client the app builds reports a `401` answered to the credential it presented.
- When that credential is the active remote sign-in's session, the app checks it once with `GET /api/v1/whoami`.
  A `401` there too means the session is gone: the app stops the connection's background work, forgets the stored
  session and lands on Sign in again for that connection, with the server and the email kept. Anything else (the
  first `401` was a wrong code, the network dropped) changes nothing.
- A notification on a new Account channel says the server signed the person out, when notifications are allowed.
  Signing in again removes it.
- The sign-in form says why it is showing when it opens for a session the server ended.
- Starting the app with a sign-in that has no stored session opens Sign in again for it, not the empty connect form.

API tokens are unchanged: a refused token still shows the error and nothing is forgotten, because the app cannot
get a token back once it drops it.
