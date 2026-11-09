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

## Outbox

`data/offline` holds the outbox for one context in a single document under `sync/state`: the waiting entries, the
conflict records, the map from sent drafts to their real references, the next draft number and order, and whether
the server has shown it honours `Idempotency-Key`. It is written through `CacheStore` but is not best effort: a
failed write is logged and the copy in memory stays the truth.

Repositories take an optional `Outbox`. Each write goes through `Outbox.write`: it is sent at once unless the
server is known to be out of reach (`serverOfflineProvider`, kept by the replay from `onlineProvider`), the target
is a draft, or writes for the same task still wait; a network failure queues it too. A queued write answers with
how it will look, so the screens keep drawing it, and lists and records draw every waiting write on top of what the
server sent (`overlay`), plus the drafts of the project. Public signatures only gained optional `base:` arguments.

## Replay

`OutboxReplayer` groups entries by task (a draft and the task it became are one group) and runs groups in parallel,
each in order. A group stops at the first entry that waits for the person. A successful write moves the following
entries that shared its base version to the version it produced, so a run of offline edits does not 409 against
itself. A write naming another draft waits until that draft's create has its real reference, or stays queued.

A 409 on an update reads the task and merges per attribute against the stored base (`merge3`): custom fields one by
one, tags as sets. The policy settles same-attribute conflicts; every conflict, settled or open, is recorded. A move
first reads the task and treats someone else's move as a conflict on `status`; a 422 on the move is a conflict
carrying the server's reason. A 404 is a "deleted" conflict. 400, 401, 403 and 422 elsewhere fail the entry with
the reason.

## Idempotency

Every write, sent at once or replayed, carries the entry's key through the generated `idempotencyKey` argument;
a body changed by a merge gets a new key, since tix refuses the same key with another body. tix (from the pin in
`tix.lock`) keeps the answer per tenant, actor and key. The replay asks each server once whether it reads the
header: a key longer than tix's 200 characters on a `DELETE` of a task that does not exist is refused with 400 by a
server that reads it and answered 404 by one that does not. With support, a lost create is sent again with the same
key; a 409 saying the request is still running stops the run for a retry; a 409 saying it was applied but its answer
was not kept counts as done (a create's task is found, anything else is read back). Without support, a create whose
answer was lost is marked "needs check": the next replay lists the caller's newest tasks in the project and adopts a
single task whose title the queued line starts with, sends the create when there is none, and leaves it to the
person when there are several.

## Catching up

`OutboxSync` (core/offline, keepAlive, kept alive by the shell's badge) replays when the network returns, when the
event stream goes live, when a write is queued, every minute while writes wait, and as the first `syncSteps` step.
After it sends anything it calls `LiveEvents.reportGap()`, which emits `EventsMissed`, so every provider using
`refreshOn` reloads from the server.
