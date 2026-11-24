# Proposal

## Why

The widgets' headless run reads and writes preferences through its own cache. When it records a refusal while the
app is open, the app's cache never sees it.

For a sign-in, the headless run marks the connection refused and deletes the session. The app keeps the old
session, the next sync gets a `401`, and `record` finds the stored session gone, decides the refusal is someone
else's and returns without dropping the session. Sync goes on asking the server and `whoami` until a cold start.

For a token, the app's next write to the connections list, such as `activate` stamping `lastUsedAt`, rewrites
the list from the stale cache and erases the refusal.

## What Changes

- `KeyValueStore.reload` reads preferences again. The app reloads before it reads and then writes the
  connections list, before `record` decides, and when it comes back to the foreground.
- `InstancesRepository.update` keeps a refusal recorded since the connection was read. Only `save`, with a new
  secret, clears one.
- `record` answers true when the connection is already refused, or when it is a sign-in whose session is gone,
  so the app drops the session and opens reconnect. Neither case shows the notification again.
