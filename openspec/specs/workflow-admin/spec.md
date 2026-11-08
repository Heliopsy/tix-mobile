# workflow-admin Specification

## Purpose
Listing, creating, editing and deleting workflows: states in order with their categories and rules, the moves between them, and where the tasks of removed states go.

## Requirements

### Requirement: Workflows are listed and created

With `workflow:read` the app SHALL list the tenant's workflows with their state count and a builtin mark. With
`workflow:write` a New workflow action SHALL ask for a key, a name and a starting point (a copy of an existing
workflow or a minimal one) and open it in the editor.

#### Scenario: Copy a workflow

- **WHEN** a person creates "support" from the default workflow
- **THEN** `PUT /workflows/support` carries the default's states and transitions

### Requirement: States are edited and reordered on a phone

The editor SHALL list states in order with drag to reorder, and edit each state's key, label, category,
terminal flag, revert on lease expiry with its target, and which state is initial. Adding and removing states
SHALL be buttons, not gestures alone.

#### Scenario: Reorder

- **WHEN** a person drags Done above Doing and saves
- **THEN** the states are sent in the new order

### Requirement: Transitions are chosen per state

Each state SHALL show the other states as "can move to" chips; a chip toggles the transition. A chosen chip SHALL
open its rules: comment required and a required scope. The editor SHALL show how many steps each state is from
the initial one, and name states no route reaches.

#### Scenario: Comment required

- **WHEN** a person marks doing to blocked as needing a comment and saves
- **THEN** that transition is sent with `requires_comment: true`

#### Scenario: Unreachable

- **WHEN** no transition leads to a state
- **THEN** the editor says no route reaches it

### Requirement: Removed states offer a migration

When a saved workflow loses a state, the editor SHALL offer a target state for its tasks and send the choices as
`migrate`. A refusal SHALL be shown in the editor with the server's message and the draft kept.

#### Scenario: Stranded tasks

- **WHEN** the server refuses a save as a conflict
- **THEN** its message shows above the editor and nothing typed is lost

### Requirement: Delete is red and confirmed

A workflow that is not builtin SHALL offer Delete, confirmed, sent as `DELETE /workflows/{key}`.

#### Scenario: Builtin

- **WHEN** the builtin workflow is open
- **THEN** no delete control is shown
