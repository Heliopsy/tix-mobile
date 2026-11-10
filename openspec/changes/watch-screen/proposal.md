# Proposal

## Why

tix has a live tail of the tenant's domain events in two places: `tix watch` on the command line and the Watch view
in the terminal interface. The app already follows the same stream, but only to know when to reload a list; nobody
can see it. Audit is the historical log, after the fact and only for `audit:read`. Someone running agents against a
tenant from a phone wants what `tix watch` gives them: who took which task, what moved where, as it happens.

The web interface has no event tail. Its Activity page is the audit log refreshed when an event arrives, which the
app already has as Audit.

## What Changes

- A **Watch** screen under Manage, next to Audit, and in the command palette. Events arrive live, newest on top.
  Each row shows the sequence number, the time, the actor, the event type and a one-line summary of the subject,
  written the way tix's `FormatEventLine` writes it.
- Tapping a row opens its task or project; every row also has a details view with every field and the payload.
- Filters like `tix watch`: projects and event types (a trailing `*` matches a prefix) go to the server as the
  subscription's filter, the actor is matched on the device, as the CLI does.
- Pause and resume, with a count of what arrived while paused. The screen keeps the latest 500 events.
- Replay from a sequence number, as `tix watch --since`.
- The tail rides the connection the app already holds for live updates: a second subscription on the same
  WebSocket with its own filter and cursor, or, while live updates fall back to polling, a filtered poll after each
  of the app's own. It resumes from its cursor after a reconnect, and says so when the server no longer keeps it.
- Connecting, offline, refused and empty states use the live status indicator and connection details.

## Impact

- Capabilities: new `event-watch`; `live-updates` gains extra subscriptions on the shared connection.
- `data/events`: `EventTail`, extra subscriptions in `TixEventStream`, tails in `LiveEvents`, `project_ids` on the
  poller, `webhook.ping` in the known event types.
- `LiveStatusIndicator` moves from the shell feature to `core/widgets`, so Watch can show it.
- New feature `features/watch`, a route at `/manage/watch`, a Manage entry shown with `event:subscribe`, a palette
  command, strings in English, Bulgarian, German and French.
- No server change. No new dependency.
