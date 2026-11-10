# Tasks

## 1. Spec

- [x] 1.1 `event-watch` spec and the `live-updates` delta

## 2. Data

- [x] 2.1 `EventTail` and its updates; `webhook.ping` in the known types
- [x] 2.2 Extra subscriptions in `TixEventStream`, routed by id, resubscribed from their cursor; tests
- [x] 2.3 Tails in `LiveEvents` across WebSocket, polling, refresh, refusal and the probe; `project_ids` on the poller; tests

## 3. Watch

- [x] 3.1 `WatchFilter`, `WatchFeed` (cap, pause, held count, expiry, refusal), `watchVisible`; tests
- [x] 3.2 Watch screen: rows, summaries, details, filters sheet, replay, notices and states; widget tests at both widths
- [x] 3.3 Route, Manage entry, palette command; `LiveStatusIndicator` moved to `core/widgets`
- [x] 3.4 Strings in English, Bulgarian, German and French

## 4. Docs

- [x] 4.1 `docs/architecture.md` live updates, README feature list
