# API foundation

## Why

The tix web UI covers all 178 operations of tix's API; the app covered about 8, through a hand-written client
that grew one method per screen. Reaching parity needs a client that covers the whole API, stays in step with the
engine the app embeds, and gives feature work a shared way to show live changes, cached data and optimistic
edits, plus a check that no operation is forgotten.

## What changes

- tix's `api/openapi.yaml` is vendored as `api/tix-openapi.yaml` at the commit `tix.lock` pins, so one bump moves
  the engine and the API together. `just openapi-sync` refreshes it and `just openapi-check`, run in CI, fails on
  drift.
- A small generator (`tool/openapi.dart`) turns the spec into freezed models and a Dio client over one
  `TixTransport`, which maps every failure to `TixException`. It replaces the hand-written `TixApi` internals;
  repositories and providers keep their public shape.
- A typed client for tix's WebSocket event stream with cursor resume and backoff, a provider per active context,
  and `refreshOn` to refresh a provider on matching events.
- A best-effort response cache per context, files on disk, that lets a screen draw its last good data at once,
  and `OptimisticChange`, the state half of the design system's `runOptimistic`.
- A parity guard: every operationId in the spec is bound in `core/capability/registry.dart`, or exempt or pending
  by wave in `exemptions.yaml`, and `just parity` reports coverage.

## Capabilities

- New: `api-client`, `live-updates`, `offline-cache`, `operation-parity`

## Impact

No new runtime dependency: the event stream uses `dart:io` WebSockets and the cache plain files. `yaml` becomes a
dev dependency for the generator and the parity guard. The app now keeps a copy of server data on the device,
under the app support directory, removed with its connection.
