# Tasks

## 1. Spec

- [x] 1.1 `statistics`, `actor-page`, `agent-connect` and `command-palette` deltas

## 2. Statistics

- [x] 2.1 `StatsRepository` reading `stats.read` with a window in hours and a project
- [x] 2.2 Window and project filter, the project walk and its short note
- [x] 2.3 Figures, per-day columns, category bar, leaderboard and waiting tasks, each with its empty line
- [x] 2.4 Statistics destination after Activity and its palette entry

## 3. Actor screen

- [x] 3.1 `ActorRepository`: actor by id or handle, assigned tasks, tokens, keys, last 20 audit entries
- [x] 3.2 The screen, with tokens and keys behind `token:admin` and activity behind `audit:read`
- [x] 3.3 `ActorLink` on comment authors, reactors, history, Activity rows, audit detail, leaderboard, token owners
- [x] 3.4 `@handle` in descriptions and comments links to the actor

## 4. Connect an agent

- [x] 4.1 Hand-off texts moved to `core/agents`; `onboard.dart` ports tix's snippets
- [x] 4.2 Issue sheet prefilled with `mcp-agent` and the agent preset
- [x] 4.3 The screen: facts, credential, the five ways and their snippets, Copy
- [x] 4.4 Settings entry and palette entry

## 5. Strings and docs

- [x] 5.1 Strings in English, Bulgarian, German and French
- [x] 5.2 README feature list

## 6. Tests

- [x] 6.1 Snippets match tix's, mentions are linked outside code and links
- [x] 6.2 Statistics: loading, data, empty and error at both widths; window and project are sent
- [x] 6.3 Actor screen: sections by scope, a name and a mention open it
- [x] 6.4 Connect an agent: issued token fills the commands; no token:admin says so
