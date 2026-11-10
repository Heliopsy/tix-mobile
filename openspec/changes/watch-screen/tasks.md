# Tasks

## 1. Spec

- [x] 1.1 `event-watch` spec and the `live-updates` delta

## 2. Data

- [ ] 2.1 `EventTail` and its updates; `webhook.ping` in the known types
- [ ] 2.2 Extra subscriptions in `TixEventStream`, routed by id, resubscribed from their cursor; tests
- [ ] 2.3 Tails in `LiveEvents` across WebSocket, polling, refresh, refusal, sleep and probe; `project_ids` on the poller; tests

## 3. Watch

- [ ] 3.1 `WatchFilter`, `WatchFeed` (cap, pause, held count, expiry, refusal), `watchVisible`; tests
- [ ] 3.2 Watch screen: rows, summaries, details, filters sheet, replay, notices and states; widget tests at both widths
- [ ] 3.3 Route, Manage entry, palette command; `LiveStatusIndicator` moved to `core/widgets`
- [ ] 3.4 Strings in English, Bulgarian, German and French

## 4. Docs

- [ ] 4.1 `docs/architecture.md` live updates, README feature list
