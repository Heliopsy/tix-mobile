# task-export

## MODIFIED Requirements

### Requirement: Tasks are imported after a dry run

A caller with `import` SHALL import tasks through a wizard of five steps: source, columns, values, preview and
result. Every step before the result SHALL run a dry run of `task.import` before moving on, and nothing SHALL be
written until Import is pressed on the preview.

#### Scenario: Dry run first

- **WHEN** a person picks a CSV for infra and goes on from the first step
- **THEN** the app sends `dry_run: true` first and imports only after Import is pressed

## ADDED Requirements

### Requirement: A pasted list is imported as quick-add lines

The first step SHALL take either a file or a pasted list of tasks. A pasted list SHALL be sent as `content` with
format `lines` and no mapping, unparsed by the app, and SHALL go straight to the preview.

#### Scenario: Paste two lines

- **WHEN** a person pastes "Fix login #bug" and "Write docs" and goes on
- **THEN** the app sends that text with format `lines` and opens the preview

### Requirement: Columns are mapped from the server's suggestion

The columns step SHALL list every column of the dry run with its samples and the target the server chose,
marked when it is a suggestion, and SHALL let the person change each target to any field tix offers, custom
fields included. Once seen, every column's target SHALL be sent in the mapping's `columns`.

#### Scenario: Change a column

- **WHEN** a person maps the column Summary to Description and goes on
- **THEN** the next dry run's mapping has `columns.Summary: body` and every other column's target

### Requirement: Values are mapped to the project's

The values step SHALL list the distinct statuses, priorities and assignees of the file with their counts and what
each becomes: a workflow state, one of the five priorities, or a handle. Each field SHALL offer a policy for a
value with no mapping. The choices SHALL be sent in the mapping's `values` and `unknown`.

#### Scenario: Map a status

- **WHEN** a person maps the status Open to todo and sets unknown assignees to skip the row
- **THEN** the mapping sent has `values.status.Open: todo` and `unknown.assignee: skip_row`

### Requirement: The preview shows rows in error and the mode

The preview step SHALL show the counts, every row in error, and the previewed rows with their action, error rows
drawn in the danger colour with their reasons. It SHALL offer the mode (upsert, create, skip), re-running the dry
run when it changes, and SHALL disable Import while any row is in error or nothing would be written.

#### Scenario: A row in error

- **WHEN** the dry run reports line 3 in error
- **THEN** the preview shows line 3 in the danger colour with its reason, and Import is disabled

### Requirement: The rows in error download as CSV

The preview and a failed result SHALL offer the rows in error as a CSV file with the line, the error and the row's
fields when the preview holds the row, saved the way an export is.

#### Scenario: Download the report

- **WHEN** a person downloads the error report for infra
- **THEN** the app saves `infra-import-errors.csv` starting with `line,error`

### Requirement: Every import step has a way back

Every step SHALL have Back, which keeps what was chosen, and Cancel, which leaves the wizard. The result SHALL
offer Back to the preview, Import another and a way to the project.

#### Scenario: Back from the values

- **WHEN** a person goes back from the values step
- **THEN** the columns step shows the targets they chose
