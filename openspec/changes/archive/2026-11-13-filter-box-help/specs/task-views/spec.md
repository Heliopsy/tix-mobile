# task-views

## MODIFIED Requirements

### Requirement: Filters use tix's expression

The filter field SHALL take tix's filter expression and send it as `GET /api/v1/tasks` parameters: project,
status, tag, assignee, creator, claimed-by, priority, due, is, has, checklist, text, title, body, negation with
`-`, `@handle` as an assignee term, and free words as `q`. An unknown key SHALL be reported under the field.

#### Scenario: Mine and a tag

- **WHEN** a person types `assignee:me tag:ops -status:done`
- **THEN** the request carries `assignee=me`, `tag=ops` and `not_status=done`

#### Scenario: Unknown key

- **WHEN** a person types `colour:red`
- **THEN** the field says the key is unknown and the list keeps its rows

#### Scenario: A handle names the assignee

- **WHEN** a person types `@raj -@mia`
- **THEN** the request carries `assignee=raj` and `not_assignee=mia`

## ADDED Requirements

### Requirement: The filter field suggests as you type

While the caret is in a word of the filter field, the app SHALL list under it what the word completes to, at most
eight: keys for a bare word, handles after `@`, tags after `#` written as `tag:`, and the tenant's projects, tags,
people, workflow states, priorities, due windows and `is:` states after their key. A leading minus SHALL be kept.
A key still waiting for its value SHALL not be applied while typing.

#### Scenario: A status completes

- **WHEN** a person types `status:in` in a project whose workflow has `in_progress`
- **THEN** `status:in_progress` is offered, and tapping it makes the field read `status:in_progress` and a space, and applies it

#### Scenario: A tag after a hash

- **WHEN** a person types `#op` and the tenant has the tag `ops`
- **THEN** `tag:ops` is offered and taking it replaces `#op`

#### Scenario: A bare key waits

- **WHEN** a person types `status:` and pauses
- **THEN** no error shows and the states are offered

### Requirement: Suggestions answer the keyboard

With suggestions listed, Down and Up SHALL move through them, Enter SHALL take the one reached, Tab SHALL take the
reached or the first, and Escape SHALL close the list. Enter with none reached SHALL apply the filter as typed.

#### Scenario: Arrow then Enter

- **WHEN** a person types `prio`, presses Down and Enter
- **THEN** the field reads `priority:` and the priorities are offered

### Requirement: Filters has pickers

A Filters button by the sort SHALL open pickers for status, priority, assignee and tag. Picking a value SHALL
replace that key's selecting terms in the expression with the one picked; Any SHALL take them out.

#### Scenario: Pick a priority

- **WHEN** the field reads `priority:low tag:ops` and a person picks High under priority
- **THEN** the field reads `tag:ops priority:high`

### Requirement: Each term is a removable chip

Under the field each term of the applied expression SHALL show as a chip with a labelled remove button, which
SHALL take that one term out and apply the rest.

#### Scenario: Remove one term

- **WHEN** the filter is `tag:ops status:todo` and a person removes the `tag:ops` chip
- **THEN** the field reads `status:todo` and the list is filtered by it
