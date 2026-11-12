# Design

## Where the screens live

Statistics is a shell destination after Activity, as the web's sidebar orders them; on a phone it sits under
More. The actor route `/actors/:id` is a second root of the Activity branch, so a name pushed from any tab opens
it with a way back. Connect an agent is under Settings at `/settings/connect-agent`, beside the reader's tokens,
since it issues one; the app's own `/connect` is adding a server and keeps that path.

## Statistics

`GET /stats` takes the window as hours (`336h` for 14 days) and the project key. The project picker walks the
project list a page at a time up to 500 and says so when it stopped short, as the web does. The bars are plain
boxes on design tokens, no chart package: columns per day with a label every few days when they would collide,
one divided bar by category in the status colours, and a track per leaderboard row. The leaderboard's measure is
the server's string, translated when it is the one tix ships.

## The actor screen

`GET /actors/{id}` resolves a handle too, so an `@handle` links without a lookup. The sections follow the web:
tokens and keys only with `token:admin` and never for the system actor, recent activity only with `audit:read`
(`GET /audit?actor_id=…&limit=20`, newest first). The web links "Tasks assigned to X" to a filtered list; the app
has no query route for that, so it lists the first 20 assigned tasks inline (`GET /tasks?assignee=…`).

## Linking names

`ActorLink` wraps whatever names an actor and pushes the actor route; inside a sheet or dialog it closes it
first. The system actor and an empty id draw no link. Mentions are linked by rewriting `@handle` outside code,
links and addresses to a `tix-actor:` link before the Markdown is drawn; that scheme only reaches `onMention`,
never a browser. Task rows keep opening the task; their assignee chip is not a separate target.

## Connect an agent

`core/agents/onboard.dart` ports tix's `internal/onboard` snippet builders, using the hand-off's client list and
shell quoting; the titles and notes are app strings keyed by the web's snippet ids. The token is issued with the
existing sheet, prefilled with `mcp-agent` and the agent preset's scopes the reader holds, for the reader's own
actor. Its value lives in the screen's state and replaces `$TIX_TOKEN` in every command; it is never stored.
The API does not say whether or where the server runs SSH, so the SSH commands use the server's host on port 22
and say so.
