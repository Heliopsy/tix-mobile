# people-admin Specification

## Purpose
The tenant's people from the app: accounts with their roles and state, invite links, memberships, and the changes an administrator makes to them.

## Requirements

### Requirement: Users are listed with their role and state

The users screen SHALL list the tenant's accounts from `user.list`, a page at a time, each with its name, email,
role from `member.list` and whether it is disabled. An account without a membership SHALL say it has no role.
A caller without `user:admin` SHALL not be offered the screen.

#### Scenario: Roles beside users

- **WHEN** an admin opens Users and ana is a member and raj is disabled
- **THEN** ana shows the role member and raj shows disabled

#### Scenario: Hidden without the scope

- **WHEN** the credential lacks `user:admin`
- **THEN** the Manage hub shows no Users entry

### Requirement: Accounts are created with a password or an invite link

Creating a user SHALL offer two ways in: a password, optionally to be changed at first sign-in, through
`user.create`; or a single-use invite link with an expiry of 1, 3, 7, 14 or 30 days through `invite.create`. The
link SHALL be shown once with Copy and Share and a warning that it is not shown again.

#### Scenario: Invite link

- **WHEN** an admin creates an invite for `bo@example.com` expiring in 7 days
- **THEN** the app sends `expires_in: 7d` and shows the returned link once with Copy

### Requirement: An account is changed from its own sheet

Each account SHALL open a sheet to change its display name and role, disable or enable it, and ask for a
password change, sending only what changed to `user.update`. Deleting SHALL be a red button that confirms
first and calls `user.delete`. The caller's own account SHALL not offer delete or disable.

#### Scenario: Role change

- **WHEN** an admin changes raj's role to viewer and saves
- **THEN** the app sends `PATCH /users/{id}` with only `role: viewer`

#### Scenario: Delete asks first

- **WHEN** an admin presses Delete and confirms
- **THEN** the app calls `DELETE /users/{id}` and raj leaves the list

### Requirement: Pending invites can be re-issued and revoked

The users screen SHALL list pending invites from `invite.list` with email, role and expiry. Re-issuing SHALL
show the new link once; revoking SHALL confirm first.

#### Scenario: Re-issue

- **WHEN** an admin re-issues an expired invite
- **THEN** the new link is shown once and the invite reads as pending

### Requirement: Memberships can be granted and removed

A caller with `tenant:admin` SHALL be able to give an existing actor a role through `member.add` and remove a
membership through `member.remove` after confirming.

#### Scenario: Add an agent

- **WHEN** an admin adds the agent ci-bot as member
- **THEN** the app sends `POST /members` with its actor id and role member
