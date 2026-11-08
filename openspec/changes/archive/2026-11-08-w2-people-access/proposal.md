# Proposal

## Why

Managing who can reach a tenant still needs the browser: users and their roles, invite links, API tokens, the
calendar feed and getting tasks out of tix as a file. The owner wants every admin view in the app, held to the
same rules as the web: hide what the caller cannot do, show a secret once, ask before anything that cannot be
undone.

## What Changes

- Users: list the tenant's accounts with their role and state, create one with a password or an invite link,
  change role and display name, disable and enable, ask for a password change, delete. Pending invites with
  re-issue and revoke. Members: add an existing actor with a role, remove a membership.
- API tokens: the caller's own tokens, and every token of the tenant for `tenant:admin` or any actor's for
  `token:admin`. Issue with scopes and an expiry, show the value once with Copy, revoke.
- Account: profile, memberships and, when the credential may read it, the account's history.
- Calendar feed: create, rotate, revoke and filter the private feed, with how to subscribe in Google, Apple and
  Outlook calendars.
- Export and import: a project's tasks, or a filtered part of them, as CSV, JSON, NDJSON or Markdown with a
  choice of columns, saved through the share sheet or a save dialog; a whole-tenant snapshot; importing a file of
  tasks with a dry run first.
- Each lives behind an entry in the Manage hub or Settings, shown only when the caller's scopes allow it.

## Impact

- New capabilities: `people-admin`, `api-tokens`, `account`, `calendar-feed`, `task-export`.
- Operations bound in the parity registry (wave 2): `user.list|create|update|delete`, `member.list|add|remove`,
  `invite.create|list|reissue|revoke`, `token.create|list|revoke`, `account.log`,
  `calendar.show|create|rotate|revoke|filter`, `task.export`, `task.import`, `snapshot.export`.
- The generated client gains a bytes twin for operations that answer in several media types, so an export
  arrives as the file the server wrote.
- No new dependencies.
