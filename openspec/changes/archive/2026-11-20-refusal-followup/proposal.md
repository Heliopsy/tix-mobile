# Proposal

## Why

The session-expiry change stopped a device from polling with a session the server had ended, but left two holes.

A refused API token still only showed an error. The periodic sync, the outbox replayer and live updates kept the
connection active and sent the same token again on every tick, and nothing told the person why their lists had
stopped changing.

The home widgets' headless background run has no `SessionController`, so nothing listened for the `401`. The
refresh worker woke every 30 minutes and asked the server again with the same dead credential, and the widgets kept
showing the last snapshot with no hint that it would never update.

## What Changes

- A refused credential, session or token, is confirmed once with `GET /api/v1/whoami` and then recorded on the
  connection as refused. The record is kept with the connection, so a cold start or another headless run reads it
  before sending anything.
- A refused token is kept in secure storage. The connection stops all background work and the app opens a
  screen to paste a new token or sign in, with the server and the cached data kept. A refused session is still
  deleted, as before.
- A notification on the Account channel says the token for the instance was refused.
- Saving a new working credential on that connection clears the refused state and sync starts again.
- The headless widget run confirms and records refusals with the same code as the app, stops asking the server
  for that connection, notifies when allowed, and draws its widgets as needing sign-in instead of the last
  snapshot.
- Starting the app with a refused active connection goes straight to the reconnect screen.
