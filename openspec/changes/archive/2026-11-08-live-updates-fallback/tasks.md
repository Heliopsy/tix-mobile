# Tasks

## 1. Data

- [x] 1.1 `TixEventPoller` over the generated `event.poll`, 404/405 as `EventPollUnsupported`, cancellable; bump `tix.lock`
- [x] 1.2 `TixEventStream` resumes from a starting cursor and reports an expired one
- [x] 1.3 `LiveEvents`: WebSocket, polling, periodic refresh, probes, pause, cursor handover

## 2. Application

- [x] 2.1 `tixEventStreamProvider` builds `LiveEvents`; `liveStatusProvider` for the indicator and diagnostics
- [x] 2.2 Pause in the background on phones, retry on resume

## 3. Presentation

- [x] 3.1 `LiveIndicator` with a gallery entry and a golden; strings in English and Bulgarian
- [x] 3.2 The indicator beside the context switcher

## 4. Tests and docs

- [x] 4.1 Fake poll endpoint in `FakeTix`; tests for fallback, handover both ways, recovery, 403, refresh mode, pause
- [x] 4.2 docs/architecture.md live updates section
