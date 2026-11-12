# Proposal

## Why

tix's web UI has two ways to add a task: the one-line box and "Add with details", a form with a field per
attribute whose title is stored as typed. The app only has the one-line box, so a description, a repeat rule, a
parent, dependencies or a lease length can only be set after the task exists, and a title that happens to contain
`!`, `#` or `@` is always read as quick-add syntax.

## What Changes

- An "Add with details" sheet in the quick feature, matching the web form's fields and wording: title (required),
  description, project, priority, due date, assignee, tags, and under More options the repeat rule, parent task,
  dependencies and lease. It sends `POST /api/v1/tasks` with structured fields and no `parse`, leaving empty fields
  out so the server applies its defaults.
- Quick add gets a "More details" button that closes the sheet and opens the form holding the typed line as the
  title, in the project quick add had chosen.
- The command palette gets "Add with details".
- A refusal naming a field is shown under that field and the form keeps every value; any other refusal is shown
  above the form. Without a network the task is queued as a draft, as quick add queues its line.
- No status field: the web form carries a status only from the board column it was opened in, and the API starts
  the task in the workflow's initial state when none is sent.

## Impact

- Capabilities: `quick-add`, `command-palette`.
- Code: `core/quick` (drafts can ask for the full form), `data/repositories/tasks_repository` (a structured
  create beside quick add, both through the outbox), `features/quick` (the form, the More details button, the
  host and the palette command), l10n, README and `docs/architecture.md`.
- API: `task.create`, already bound. Nothing new is needed from tix.
