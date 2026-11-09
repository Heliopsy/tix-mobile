# Design

## Background requests

`LocalWakeInterceptor` asks a predicate whether a request is background work; by default that is a request to
`/events/poll`. A background request is sent to the running (or starting) engine without touching the idle timer or
the in-flight count, and is refused with `engineUnavailable` when the engine is not running. Only a request someone
asked for starts an engine.

A periodic refresh reports a gap, and the reads it causes come from ordinary providers that cannot be tagged. So the
refresh tick opens a short quiet window on `LocalEngines` (five seconds, well past the 300 ms debounce) during which
requests to a running engine count as background. A halt closes the window, so a read after the engine stops is a
normal request again and never fails because of it. The cost is that a tap inside a window does not restart the idle
timer; the next one does.

## Sleeping

`LocalEngines` reports, synchronously, each instance whose engine halts and each one whose engine starts.
`tixEventStream` puts its `LiveEvents` to sleep on a halt of the active local instance and wakes it on a start.
Sleeping closes the socket and the probe and stops polling and refresh before the engine goes away, so no reconnect
attempt is ever made against a stopped engine. Waking opens the WebSocket from the cursor, as at start, reporting a
gap only when there is no cursor after having been live.

## Coming back

`SessionController.wakeLocal` ensures the active local engine (start if resting, otherwise restart the idle timer).
It runs on app resume and on every navigation. A request the person makes goes through the interceptor and starts
the engine on its own. Each start wakes live updates; an engine that comes back on another address rebuilds the
session as before.

## Mode

`LiveMode.paused` is new. The indicator shows nothing for it: the engine is asleep and there is nothing to retry.
