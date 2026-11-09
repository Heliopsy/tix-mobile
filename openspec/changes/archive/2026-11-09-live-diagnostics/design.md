# Design

## Where the facts live

`LiveEvents` already sees every transition and failure, so it records them: no second observer re-deriving state
from `statuses`. The snapshot is an immutable `LiveDiagnostics` built on demand, and `diagnosticsChanges` emits
one on each change. `liveDiagnosticsProvider` is a sibling of `liveStatusProvider` rather than an extension of
`LiveStatus`, so the indicator does not rebuild on every event, and it is auto-disposed: nothing listens to the
per-event snapshots unless the sheet or About is open.

Times come from `clockProvider` through a `now` function, so `fakeAsync` tests read exact instants.

## Describing an error

`LiveError.from` classifies once: unreachable (socket or DNS, `TixErrorKind.network`), timeout, TLS, upgrade
refused (a `WebSocketException` with a status other than 401 or 403), closed (with code and reason), refused
(401, 403, or an error frame), HTTP (a poll answered with a status) and other. A `TixException` is read through
its `cause`, which `TixException.fromDio` now fills with Dio's underlying error, or the Dio failure type when
there is none (a receive timeout).

The socket's `onDone` used to report a drop as `null`; it now reports `EventSocketClosed(code, reason)`. Neither
counts as a network error, so the mode it leads to is unchanged.

## Redaction

Redaction happens when an error is recorded, so neither the snapshot nor the report ever holds a secret, and
the report runs through it again. It removes the connection's own header values and their parts (the token
after `Bearer`, the cookie value), then patterns: credential headers to the end of the line, `Bearer` and `Basic`
values, credential parameters, the user info, query and fragment of URLs, and runs of 32 or more token
characters. The host is shown as scheme, host and port only.

## Hints

`liveHints` maps the last error and the mode to hints: a timeout, or a socket closed with 1001, 1006 or no code,
points at a proxy's idle or read timeout; an upgrade refused, or polling working while the WebSocket does not,
points at a proxy not forwarding upgrades; unreachable, TLS, refused, HTTP and a missing poll endpoint each have
their own.

## The sheet

It lives in `core/widgets` because the shell and About both open it and a feature may not import another. The
phone bar's indicator gets a target of its own (`LiveIndicator.onTap`), so a tap on it opens the details and a tap
elsewhere on the bar still opens the switcher. The rail's dot is 8 dp, so the switcher opens the details on a long
press, and the dot's semantics say so. Reconnect now calls `LiveEvents.retryNow`, which after a refusal starts
the WebSocket again from the cursor; otherwise it is `reconnectNow`, which also probes the WebSocket at once while
polling. The copied report is English plain text, like About's diagnostics, so it reads the same in a bug report.
