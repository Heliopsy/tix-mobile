# Proposal

## Why

Administering a tix tenant or a whole installation still needs the browser: tenant settings and theme, domains,
the tenants of an installation and their users, global admins, live connections, and a person's own second factor
and SSH keys. The owner wants every admin view the web UI has in the app. Server-side integrations (webhooks,
external sync, retention, housekeeping, trash and the audit log) follow in their own change, `w3-integrations`.

## What Changes

- Tenant settings: name, date defaults, theme with a live preview in both schemes using the app's own accent
  derivation, second-factor requirements per surface, claim leases, the trash switch, and deleting the tenant.
- Domains of the active tenant: list, add with a certificate mode (`none` or `file` with server paths), remove.
- Server: the version, the tenant's live connections with their counts, ending one.
- For a global admin: every tenant (create one with its first admin, generated passwords shown once, open, switch
  into it, joining as admin when not a member, delete), its settings, users (create, add an existing account,
  edit, delete, clear a lost second factor in the active tenant), its domains (shared or not), the global admins
  (grant, revoke) and any account's log.
- Security for the signed-in person: second factor setup with the authenticator key and an `otpauth` link,
  confirmation, recovery codes shown once, new codes, removal; SSH keys listed (revoked ones too), added (to every
  tenant if asked) and revoked.
- Task detail: force-release another actor's claim (`claim.reclaim`).
- A `OneTimeSecret` design component for values tix shows once, and a `FormSheet` for admin forms.

## Impact

- New capabilities: `tenant-administration`, `server-administration`, `account-security`; `task-detail` gains a
  requirement.
- Operations bound in wave 3: `tenant.update|delete|list|create`, `tenant.user.list|create|update|delete`,
  `tenant.member.add`, `tenant.domain.list`, `domain.list|add|remove|update`, `global_admin.list|grant|revoke`,
  `account.log.any`, `connection.list|end`, `totp.status|enrol|confirm|codes|remove|clear`,
  `sshkey.list|enrol|revoke`, `claim.reclaim`.
- No new dependencies. The Manage hub gets one block of entries once it lands.
