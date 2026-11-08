# manage-hub Specification

## Purpose
One place that lists every management area the active credential can use, grouped, and offers nothing the server would refuse.

## Requirements

### Requirement: One place lists what the credential can manage

The app SHALL offer a Manage destination listing every management area, grouped as Projects, Workflows, Fields,
People, Access, Tenant and Server. Each entry SHALL open its screen.

#### Scenario: Opening an area

- **WHEN** an admin opens Manage and taps Workflows
- **THEN** the workflow list opens

### Requirement: Entries follow the credential's scopes

An entry SHALL be shown only when the actor `whoami` reports holds the entry's scope, directly or through its
role, as tix grants them. A group with no entry shown SHALL be left out. A person SHALL never learn of a missing
scope from a refusal for something the hub offered.

#### Scenario: A member

- **WHEN** a member, whose role grants `workflow:read` but not `workflow:write`, opens Manage
- **THEN** Workflows is listed and opens read only

#### Scenario: A narrow token

- **WHEN** a token holding only `task:read` opens Manage
- **THEN** no group is listed and the screen says the credential manages nothing here

### Requirement: The hub draws without the network

The hub SHALL draw from the last `whoami` answer kept for the context while a fresh one loads, and say when it
cannot read the actor at all.

#### Scenario: Offline

- **WHEN** Manage opens offline after an earlier visit
- **THEN** the entries from the last answer are shown
