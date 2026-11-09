# Proposal

## Why

A production instance often shows "Offline" on the phone, and the app gives no way to see why. `LiveEvents` keeps
the last error, the failure count, the transport and the cursor, but none of it reaches the screen: the indicator
shows a state and a tooltip, nothing more. When the drop is intermittent it has recovered by the time anyone
looks.

## What Changes

- `LiveEvents.diagnostics`: mode and transport, the server's host, when the mode started, the last contact and
  event, consecutive failures and those counting towards the fallback, whether the poll endpoint is missing, the
  next retry and background WebSocket try, the last error described (class, exception type, HTTP status, OS
  error, WebSocket close code and reason, time), and a ring buffer of the last 20 mode changes and errors.
- The WebSocket's close code and reason are kept (`EventSocket.closeCode`, `closeReason`, `EventSocketClosed`),
  and `TixException.cause` keeps what Dio threw underneath, so a `SocketException` or `HandshakeException`
  behind a failed poll is not lost.
- Every message is redacted when recorded: the connection's header values, credential headers and parameters,
  query strings and long opaque strings.
- A Connection details sheet, opened by tapping the indicator in the phone bar, by a long press on the switcher
  (the rail's dot is too small to tap) and from About. It shows the above in plain language with a hint per error
  class, Reconnect now and Copy details.
- `LiveEvents.retryNow` tries the WebSocket at once, also after a refusal.

## Impact

- Capabilities: changed `live-updates`, `about`.
- Design system: `LiveIndicator.onTap`. The goldens do not change.
- New strings in all four languages.
