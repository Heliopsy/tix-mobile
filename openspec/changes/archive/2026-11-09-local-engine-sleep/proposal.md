# Proposal

## Why

A local engine is meant to stop after the idle timeout to save battery, but live updates keep it awake. Once the
WebSocket has failed three times (which it does when the engine stops under it) live updates fall back to long
polling, and every poll goes through the same wake interceptor as a screen's read. Each poll restarts the idle timer
and wakes a resting engine, so the engine never sleeps.

## What Changes

- Polls, and the reads a periodic refresh triggers, no longer count as activity for a local instance: they neither
  restart the idle timer nor hold the engine awake. A poll never starts a stopped engine.
- When a local engine stops (idle, hidden, suspended or stopped from Instances), the live updates of that context
  go to sleep: no WebSocket, no reconnect attempts, no polling, no refresh. The live indicator shows nothing.
- They wake, WebSocket first and from the cursor, when the engine starts again. The engine starts again when the
  person comes back: the app returns to the foreground, they navigate, or any request they make.

## Impact

- `lib/src/core/session/local.dart`: `LocalEngines` tells background requests apart, reports halts and starts.
- `lib/src/data/local/local_wake.dart`: the interceptor marks polls as background.
- `lib/src/data/events/live_events.dart`: `sleep` and `wake`, and `LiveMode.paused`.
- `lib/src/core/events/events.dart`, `lib/src/core/router/router.dart`: the wiring.
- Specs: local-instances, live-updates.
