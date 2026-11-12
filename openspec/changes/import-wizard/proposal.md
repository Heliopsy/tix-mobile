# Proposal

## Why

The web imports in five steps (upload or paste, map columns, map values, preview, result), each with a way back,
and a CSV report of the rows in error. The app imports a file in one go: it picks a file, shows the dry run's
counts and up to five errors, and commits. There is no way to fix a column the server guessed wrong, to translate
a file's statuses, priorities or people into the project's, to pick what happens to rows imported before, to
paste a few tasks, or to keep the error report. `task.import` already takes all of this: `format`, a `mapping`
file (YAML or JSON), `mode` and a `preview` of up to 200 rows, and its dry run reports every column, the distinct
values of status, priority and assignee, and each previewed row's action and reasons.

## What Changes

- An import wizard on its own screen (`/manage/transfer/import?project=KEY`), reachable from the import section
  of Export and import and from a project's settings.
- Step 1: the project, and a file or a pasted list of tasks in quick-add syntax, sent as format `lines` and never
  parsed by the app. A file goes on to the columns; a list straight to the preview, as on the web.
- Step 2: every column of the file with its samples and the field the server suggested, changeable.
- Step 3: the file's statuses, priorities and assignees and what each becomes (workflow states, the five
  priorities, a handle), and what happens to a value with no mapping.
- Step 4: the counts, every row in error, the first rows as tix will write them with error rows in the danger
  colour and their reasons, the mode (upsert, create, skip), and Download error report.
- Step 5: the result, with Back, Import another and a way to the project.
- The choices travel as a JSON mapping file built from them; the server validates it.
- Every step has Back that keeps what was chosen, and Cancel.

## Impact

- Capabilities: `task-export`, `project-admin`.
- Code: `data/repositories/transfer_repository` (format, mapping, mode, preview; the project's workflow),
  `features/transfer` (wizard state, error report, the wizard screen; the transfer screen's import section opens
  it), `features/projects` (a link from project settings), `core/router`, l10n, README, docs.
