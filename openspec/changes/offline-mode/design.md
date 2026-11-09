# Design

## Store

The response cache stays one JSON file per key under `cache/v1/<connection>/<tenant>/`. Offline mode adds nothing
that needs a query: every screen still reads by key, so files remain enough and no database comes in. `CacheStore`
gains `sizeOf(scope)` and `clearScope(scope)` for the Settings screen; removing a connection still deletes its
whole directory.

## Serving the stored copy

`ResponseCache.remember` takes an optional `decode`. When the read fails with a network, timeout or upstream
error and a copy exists, it returns the decoded copy and records when that copy was kept; every other error (403,
404, 500) is still the caller's, since the server answered. The fallback ignores the once-per-key rule of `peek`,
which only exists so a refresh asks the server. Repository and provider signatures are unchanged.
`savedCopySinceProvider` streams the age of the oldest copy served since the last successful read; the task
screen shows it in its header.

## Key reuse

The prefetch goes through the repositories, so every answer lands under the key the screens read. The task screen's
request is built by `TaskListRepository.requestFor(query, index, now)`, which the listing provider and the
prefetch share; `TaskQuery`, `TaskScreenState` and `TaskIndex` moved to `data/query` so the data layer can build
it. `listAll` and `allProjects` merge every page under the first page's key with no cursor, so a screen opened
offline holds the whole list. Tags, the actor list and `project.show` are now cached too, and a single actor falls
back to the cached actor list.

## Prefetch policy

`OfflineSync` (core/offline) runs, for a remote context: on activation, every 30 minutes (an injectable periodic
timer) and when the network comes back. On Android and iOS it skips automatic runs on mobile data, in battery
saver or under 20% out of the charger. Sync now always runs. At most four requests run at once. A failure to reach
the server stops the run; any other failure skips that read and is reported after the rest is fetched. The
prefetch runs inside `ResponseCache.strict`, so it never mistakes a stored copy for a fresh one.

## Connectivity contract

`networkStateProvider` streams `offline`, `metered` or `unmetered` from connectivity_plus. `onlineProvider` is
true for a local instance and otherwise false only with no network at all. `syncStepsProvider` holds steps that
`syncNow` awaits in order before prefetching; the outbox replay registers there.

## Reserved prefix

Keys under `sync/` hold the outbox, conflicts and drafts of the follow-up. `clearScope` never deletes them, since
they are unsent work rather than copies; `sizeOf` counts them.

## Preferences

Per context, under `offline.<connection>.<tenant>.`: `projects` (a JSON list of keys), `mywork`, `starred` (both on
until turned off) and `synced`. The tenant part matches the cache scope.
