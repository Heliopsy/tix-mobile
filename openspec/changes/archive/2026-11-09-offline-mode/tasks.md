# Tasks

## 1. Offline reads

- [x] 1.1 `ResponseCache` serves the stored copy on network, timeout and upstream errors, with `staleSince`
- [x] 1.2 Every cached repository read passes its decoder; tags, actors and `project.show` are cached
- [x] 1.3 `CacheStore.sizeOf` and `clearScope`, keeping `sync/`
- [x] 1.4 The task screen says when it shows a saved copy

## 2. Prefetch

- [x] 2.1 `TaskListRepository.requestFor`, `listAll` and `TasksRepository.allProjects`
- [x] 2.2 `Prefetcher`: listings, tasks, comments, subtasks, projects, fields, workflows, tags and actors
- [x] 2.3 `networkStateProvider`, `onlineProvider`, `deviceProbeProvider` with connectivity_plus and battery_plus
- [x] 2.4 `OfflineSync` with `syncStepsProvider`, automatic runs and Sync now
- [x] 2.5 Forgetting a connection cancels its prefetch, and the cache refuses writes for it afterwards

## 3. Settings

- [x] 3.1 Per-context offline preferences
- [x] 3.2 The Offline screen at `/settings/offline` and its Settings entry
- [x] 3.3 Strings in English, Bulgarian, French and German
- [x] 3.4 Tests

## 4. Outbox and conflicts

- [x] 4.1 Queue changes made offline under `sync/`, with base version, base task and Idempotency-Key
- [x] 4.2 Drafts for offline creates, rewritten to the real reference after replay; links redirect
- [x] 4.3 Replay in order per task, in parallel across tasks, as a sync step and on reconnect
- [x] 4.4 Three-way merge on 409, the conflict policy, deleted tasks, refused moves and refusals
- [x] 4.5 "Needs check" for creates while the server has not shown it honours Idempotency-Key
- [x] 4.6 Sync marks and banner (design system, gallery, golden), shell badge, Conflicts screen with history
- [x] 4.7 Policy per context and Discard all unsynced changes in the Offline settings
- [x] 4.8 Strings in English, Bulgarian, French and German; tests
- [x] 4.9 Archive this change
