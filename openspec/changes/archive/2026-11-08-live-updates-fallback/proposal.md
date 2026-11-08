# Proposal

## Why

Live updates ride on one WebSocket. Some networks break it: a proxy that refuses the upgrade, a captive portal,
a load balancer that drops long connections. Today the app then retries forever and the screens quietly go
stale, with nothing to say so. The owner asked for WebSocket first, falling back to HTTP when the socket keeps
failing.

## What Changes

- One state machine owns live updates for the active context: WebSocket first; after a few failures within a
  window, long polling of `GET /api/v1/events/poll` from the same cursor; back to the WebSocket when a
  background attempt succeeds. No gap and no duplicate across either handover.
- A server without the poll endpoint (older than the tix that adds it) gets periodic refresh of what is on
  screen instead, shown as a degraded mode.
- Polling stops while a phone app is in the background, and everything retries at once when it comes back.
- A small live indicator next to the context switcher says Live, Connecting, Polling, Refreshing, Offline or Not
  available, with a tooltip explaining each.
- The mode and the last error are readable by a provider, for the diagnostics screen.

## Impact

- `live-updates`: new requirements for the fallback, the indicator and the diagnostics provider.
- `design-system`: a `LiveIndicator` component.
- `tix.lock` moves to the tix that adds `event.poll` (and `token.rotate`, pending for wave 3); `event.poll` is bound
  in the parity registry.
