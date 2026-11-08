# Tasks

## Spec and client

- [x] Vendor `api/tix-openapi.yaml` at the `tix.lock` commit; `just openapi-sync` and `just openapi-check`, in CI
- [x] Generator for freezed models and a grouped Dio client; `just gen` runs it, `just gen-check` covers it
- [x] `TixTransport`: query encoding, JSON, text, files, NDJSON, envelope mapping
- [x] `TixApi` over the generated client; repositories moved over; dead hand-written models replaced by re-exports

## Live updates

- [x] `TixEventStream` with cursor resume, backoff, gap and refusal handling
- [x] Event stream provider per active context, resume on foreground
- [x] `refreshOn`, `onEvents` and `EventTopics`; projects, task lists and task pages refresh on events

## Cache and optimistic updates

- [x] File cache store, response cache per context, cleared with the connection
- [x] `cachedFirst` in projects, task lists and task pages
- [x] `OptimisticChange` for the design system's `runOptimistic`

## Parity

- [x] Registry, exemptions and pending waves; parity test; `just parity`

## Docs

- [x] Architecture, development, building a feature on the data layer
