# Tasks

## 1. Diagnostics

- [x] 1.1 `LiveDiagnostics`, `LiveError`, `LiveLogEntry` and `redactSecrets` in `data/events/live_diagnostics.dart`
- [x] 1.2 `LiveEvents` records transitions, errors, contact, retries and probes, with a capped history
- [x] 1.3 `EventSocket.closeCode` and `closeReason`, `EventSocketClosed`, `TixException.cause`
- [x] 1.4 `LiveEvents.retryNow`, also after a refusal
- [x] 1.5 `liveDiagnosticsProvider`
- [x] 1.6 Unit tests: classification, ring buffer cap, redaction, after a fallback, after a timeout

## 2. Connection details

- [x] 2.1 The sheet in `core/widgets/live_details.dart`, with hints, Reconnect now and Copy details
- [x] 2.2 `LiveIndicator.onTap`; the phone bar's indicator opens it, the switcher on a long press
- [x] 2.3 Connection details on About
- [x] 2.4 Strings in English, French, German and Bulgarian
- [x] 2.5 Widget tests: opens from the indicator, the rail and About, error and hint, redacted copy, reconnect
