# Tasks

## 1. Engine

- [x] 1.1 Background requests (polls, refresh quiet window) do not touch the idle timer or start an engine
- [x] 1.2 `LocalEngines` reports halts and starts

## 2. Live updates

- [x] 2.1 `LiveEvents.sleep` and `wake`, with `LiveMode.paused` shown as nothing
- [x] 2.2 The active local context's live updates sleep on a halt and wake on a start
- [x] 2.3 App resume and navigation start a resting engine

## 3. Docs

- [x] 3.1 docs/architecture.md describes sleeping live updates
