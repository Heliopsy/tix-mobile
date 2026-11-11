# Proposal

## Why

tix's web task list says, in the line under its heading, how many of the tasks on the page an agent is holding right
now ("3 held by an agent", in the accent). The app only says how many tasks it loaded, so on a phone or the desktop
there is no way to see at a glance that agents are at work on the list.

## What Changes

- The task screen's subtitle (every task, my work, a project; list, board and lanes) adds "N held by an agent" after
  the count, in the accent, when at least one loaded task carries a claim whose lease has not run out.
- It counts the way the web's summary does: a task with a claimant and a lease expiry still in the future.
- It follows the listing, which already reloads on `task.claimed`, `task.released`, `task.lease_expired` and
  `task.reclaimed`, so it updates live.
- `TixPage` and `TixPageHeader` take an optional `subtitleNote`, drawn after the subtitle in the accent.

## Impact

- Capabilities: `task-browsing`.
- Code: `core/design` (page), `features/tasks`, l10n (one string).
- Server: none. `claimed_by_actor_id` and `lease_expires_at` are in the pinned engine's task model.
