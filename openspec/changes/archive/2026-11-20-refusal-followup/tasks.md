# Tasks

## 1. Spec

- [x] 1.1 `sign-in` and `home-widgets` deltas

## 2. Shared refusal handling

- [x] 2.1 `Connection.refusedAt`
- [x] 2.2 `RefusedCredentials`: confirm with `whoami`, record, check a stored connection
- [x] 2.3 Token refused notification; en, bg, de, fr

## 3. App

- [x] 3.1 `SessionController` checks tokens too and records through `RefusedCredentials`
- [x] 3.2 No session for a refused connection; `awaitingSignIn` names it
- [x] 3.3 `connect(replacing:)` for a new token; `saveSignIn` over a token connection; both clear the refusal
- [x] 3.4 Reconnect screen for a refused token: explanation, token and sign-in forms

## 4. Widgets

- [x] 4.1 `openStoredFeed` skips refused connections
- [x] 4.2 Writer checks a `401` on refresh and on ticks, clears refused contexts and marks them in the index
- [x] 4.3 Headless run and foreground sync pass the shared check
- [x] 4.4 Android and iOS draw a refused context as sign in again

## 5. Tests

- [x] 5.1 Token refused by the periodic sync: polling stops, survives a restart, a new token resumes sync
- [x] 5.2 A token `401` the token survives
- [x] 5.3 Headless refresh with an expired session and with a revoked token
- [x] 5.4 App started after a headless refusal goes to reconnect

## 6. Docs

- [x] 6.1 README and `docs/architecture.md`
