# Proposal

## Why

People open tix on trains, in planes and in basements. Today the app draws the last first page it saw and then
fails as soon as anything asks the server. They want to read their work offline, change it, and have the changes
reach the server once they are back online.

## What Changes

This change lands in two pull requests.

The first (this one) is offline reading:

- A read that cannot reach the server (no network, a timeout, a 502, 503 or 504) answers with the copy the cache
  holds for the same key, and the task screen says it is showing a saved copy and from when.
- A prefetch keeps the projects a person picks, plus My work and Starred, available offline: every page of each
  listing, each task with its comments and subtasks, the projects, workflows, fields, tags and actors needed to
  draw them. It runs on activation and every 30 minutes for remote instances, waits for Wi-Fi and battery on
  phones, and runs on demand from Settings.
- An Offline screen in Settings: what is kept, how much room it takes with a Clear button, the last sync and Sync
  now. A local instance is on the device, so the screen says so and offers nothing else.
- Connectivity and battery providers both pull requests share.

The follow-up adds the outbox: changes made offline are queued under the reserved `sync/` keys, replayed in order
before each prefetch, and conflicts are shown for the person to resolve.

## Impact

- Capabilities: `offline-cache` and `app-settings` change.
- New dependencies: `connectivity_plus` (whether there is a network and whether it is metered) and `battery_plus`
  (battery saver and level on phones). Both support Android, iOS, macOS, Linux and Windows.
