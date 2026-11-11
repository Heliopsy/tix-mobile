# Proposal

## Why

tix's web UI has a "Hand to an agent" button on every task screen. The app had nothing like it, so on a phone or the
desktop panel there was no way to give a task to a coding agent.

## What Changes

- The task view gets a Hand to an agent button in its header, the same entry in the task menu, and a palette command.
  It works the same on the phone screen and in the desktop task panel, which share the view.
- It opens a sheet with what the web dialog shows: the prompt for an agent driving the tix CLI, a chip per client
  that tix documents with the command that starts it on the prompt (or the MCP prompt to paste for clients without
  one), and the prompt for an agent holding the tix MCP tools. Each block copies with one tap.
- Nothing is sent to the server. The agent claims the task itself with its own token.

## Impact

- Capabilities: `task-detail`.
- Code: `features/tasks` (application text, detail sheet, header, menu, palette), l10n in every locale.
