# tenants Specification

## Purpose
The active context, the switcher, pinned and switchable connections, and tenants served at their own address.

## Requirements

### Requirement: The active context is instance, connection and tenant

The app SHALL have at most one active context: an instance, one of its connections, and the tenant that connection targets. Every request SHALL go to that instance with that connection's credential. Changing the active context SHALL rebuild the API client and reload every list.

#### Scenario: Switching reloads the lists

- **WHEN** a person switches from one context to another
- **THEN** the projects shown are the new context's, with no project of the previous one left

### Requirement: A switcher is on every signed-in screen

Every signed-in screen SHALL show the active context as Instance › Tenant, at the bottom above the navigation bar on a phone and at the top of the navigation rail on a wider window. It SHALL open a list of contexts, recent ones first, then every other context grouped by instance, with a way to manage instances.

#### Scenario: Pick a recent context

- **WHEN** a person opens the switcher on a phone and picks a recent context
- **THEN** that context becomes active and the switcher shows its instance and tenant

### Requirement: Connections are pinned or switchable

A token connection SHALL be pinned to its token's tenant. A sign-in connection SHALL be either pinned to one tenant or switchable, as the person chooses when signing in and can change later. The switcher SHALL list one entry for a pinned connection and one per membership for a switchable one.

#### Scenario: Pinned connection stays put

- **WHEN** a sign-in connection is pinned to `acme` and the person belongs to `acme` and `beta`
- **THEN** the switcher lists that connection under `acme` only

#### Scenario: Switchable connection lists every tenant

- **WHEN** a switchable sign-in connection belongs to `acme` and `beta`
- **THEN** the switcher lists both tenants under the instance

### Requirement: Switching tenant uses the server's switch

Picking another tenant of a switchable connection SHALL call `POST /api/v1/auth/switch` with the tenant's key, store the new session in place of the old one and update the connection's tenant. A code challenge SHALL be asked for and sent back with the tenant.

#### Scenario: Switch to another tenant

- **WHEN** a person picks `beta` on a switchable connection signed in to `acme`
- **THEN** the app calls the switch with `beta`, keeps the new session, and the lists show `beta`'s projects

### Requirement: Tenants at their own address become instances

A membership whose `host` is set SHALL NOT be switched to. The switcher and the sign-in tenant choice SHALL show its address and offer to add that address as its own remote instance, with a sign-in prefilled with the person's email.

#### Scenario: Own-host tenant

- **WHEN** a person's membership of `own` names the host `own.example`
- **THEN** the switcher shows `own.example` beside it and picking it opens the add-instance screen for `https://own.example`

### Requirement: Signing in chooses how to follow tenants

After a sign-in with more than one membership served at that address, the app SHALL ask which tenant to open and whether to stay switchable or pin the connection to it. With one membership it SHALL pin to that tenant without asking.

#### Scenario: Pin on sign-in

- **WHEN** a person in `acme` and `beta` signs in and chooses `beta`, pinned
- **THEN** the app switches to `beta`, saves a connection pinned to it and the switcher lists it under `beta` only

### Requirement: Switching drops the old context's screens

A move to another context SHALL take down every screen, tab stack, sheet and dialog of the old one before the new
one is active, so none asks the new context for an id of the old. Without a target the app SHALL land on the root
of the tab that was showing; the instances and about screens MAY stay. Every other tab SHALL open at its root.

#### Scenario: Switching tenant on a task

- **WHEN** a person on `/projects/infra/tasks/infra-1`, with a workflow open under Manage, switches to tenant Acme
- **THEN** the projects list of Acme shows and no request for `infra` reaches Acme
- **AND** opening Manage shows its root, not the workflow

#### Scenario: A switch closes the old sheets

- **WHEN** a sheet and a dialog are open over a task and the context changes
- **THEN** both are closed

### Requirement: A switch with a target lands on it

A switch made to open something, such as a `tix://` link naming a context, ADB `open` or a home screen widget, SHALL
land on that target in the new context, with every other tab at its root. Activating the active context again,
or the session reloading with the same context, SHALL keep the screen and every tab as they are.

#### Scenario: A link into another tenant

- **WHEN** `tix://projects/ops?context=s1.acme` opens while the person is on a task of tenant Default
- **THEN** the app switches to Acme and shows the tasks of `ops`

#### Scenario: The same context again

- **WHEN** the person activates the context they are in, or the session reloads
- **THEN** the task stays open and the other tabs keep their screens
