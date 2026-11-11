# Proposal

## Why

When an agent changes a task with an API token, tix records the token's name with the change, and the web prints
it: "deploy-bot via token ci-runner". The app's task History printed only the bare channel (`api`), and Watch
printed the name without saying it was a token: "via API (ci-runner)" read the same as a job such as
"via system (lease-sweep)".

## What Changes

- One label for a change's channel, shared by Watch and task History, worded as tix's web words it:
  "via token ci-runner" for a plain API token, "via MCP (token claude)" when a client named itself,
  "via system (lease-sweep)" for background work, "via web" when nothing identifies the caller.
- Task History shows that label after the time, beside the actor, instead of the bare channel.
- Watch rows and details use the same label.
- No server change is needed: `via.token_name` has been in tix's audit entries and events since the pinned
  engine. An entry without `via` (an older server) still shows its surface, as before.

## Impact

- Capabilities: `event-watch`, `task-detail`.
- Code: `core/l10n` (the shared label), `features/watch`, `features/tasks`, l10n (two strings added).
