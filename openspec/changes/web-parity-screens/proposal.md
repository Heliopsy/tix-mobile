# Proposal

## Why

tix's web has three screens the app lacks: Statistics (`/stats`), a person's or agent's page (`/actors/ID`) and
Connect an agent (`/connect`). Somebody on the app could not see throughput or the leaderboard, could not open
who did something from a comment, the history or Activity, and had to go to a browser to get the commands that
point a CLI, an MCP client or an agent at the server.

## What Changes

- A Statistics destination after Activity, reading `GET /stats`: a window (7, 14, 30, 90 days) and a project,
  completed, created, median and slowest lead time, completed per day, where the work is by state category, the
  leaderboard with what it counts, and the tasks waiting longest. Wording follows the web's.
- An actor screen at `/actors/{id or handle}`: who it is (handle, name, kind, id with Copy), the tasks assigned
  to it, its API tokens and SSH keys for a reader holding `token:admin`, and its last 20 audit entries for a
  reader holding `audit:read`. A comment's author, a reactor, a history entry, an Activity row, an audit entry,
  a leaderboard row, a token's owner and an `@handle` in a description or comment open it.
- A Connect an agent screen under Settings, Security, and in the palette: the server, tenant and handle, a token
  issued with the agent preset whose value fills every command (kept only in the screen's state), and the CLI,
  MCP (one tab per client), SSH, API and skill commands of tix's `internal/onboard`, each with Copy.
- The hand-off texts move from `features/tasks` to `core/agents` so the hand-off sheet and Connect an agent share
  the client list and quoting.

## Impact

- Capabilities: `statistics`, `actor-page`, `agent-connect` (new), `command-palette`.
- Code: `data/repositories` (stats, actor), `core/agents` (hand-off, onboard), `core/markdown/mentions`,
  `core/widgets/actor_link`, `core/design/components/markdown` (`onMention`), `core/router`, `features/stats`,
  `features/people` (actor screen), `features/tokens` (connect screen, prefilled issue sheet), `features/shell`,
  `features/settings`, the task activity and history, Activity, audit and tokens rows, l10n, README.
