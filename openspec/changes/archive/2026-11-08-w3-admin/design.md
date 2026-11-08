# Design

## Features and data

Two features: `admin` (tenant settings, domains, server, the tenant tree, users, global admins, account logs) and
`security` (the person's own second factor and SSH keys). They share nothing, so they are separate; everything in
`admin` reads one `AdminRepository`, everything in `security` one `SecurityRepository`, both built in
`core/session/admin.dart` from the session's client and cache. `claim.reclaim` lives on the task screen, through
`TaskDetailRepository` and the task controller, beside the other task actions.

Only a tenant's settings are cached (`admin/tenant/<ref>`): they open the settings screen and the tenant detail.
Nothing carrying a secret is cached or kept in provider state: `CreatedTenant` (generated passwords), the TOTP
enrolment (the authenticator key) and recovery codes pass through as return values to the widget that shows them
in a `OneTimeSecret`, and are gone when it closes. The API client already logs only method, path and status; a
test listener on `log` holds that to account.

## The active tenant

A sign-in names its tenant key; a token knows only the tenant id `whoami` reports, which `GET /tenants/{ref}`
accepts too, so `currentTenantRef` falls back to it.

## Theme preview

The preview draws a small page with `buildTixTheme(brightness, accent: TixAccent.resolve(draft))` for light and
dark, the same derivation the app applies after saving, so what is previewed is exactly what the app turns into.
Saving a theme on the active tenant invalidates `tenantAccentProvider`, which reads the tenant again and recolours
the app.

## Switching into a tenant

`POST /auth/switch` refuses a tenant the person is not a member of (`not_found`), even for a global admin. The
tenant detail therefore offers "Join and switch" in that case: `tenant.member.add` with the person's own email as
admin, after a confirmation that says it lands in their account log, then the usual `SessionController.activate`.
A token or a pinned sign-in cannot switch, and says why.

## Clearing a second factor

`totp.clear` acts on a user of the caller's tenant, so the tenant users screen offers it only while that tenant is
the active one.

## Layout

The tenant list keeps the chosen tenant beside it from 840 wide (`/manage/tenants/:key` is the list with a
selection there, and the detail on its own below). Settings are always-visible `TixSection`s, each form section
with its own Save that lights up once something changed; switches save at once. Destructive actions are red and
confirm.

## Routes

`/settings/security`, `/manage/tenant`, `/manage/domains`, `/manage/server`, `/manage/tenants[/:key[/settings|
/users]]`, `/manage/global-admins`, `/manage/accounts/:email/log`. They sit in the settings branch until the Manage
hub lands and lists them.

## What tix does not offer

No endpoint lists a person's own browser sessions, so the security screen has none; the server screen lists the
tenant's live connections instead. Server status and statistics (`status.read`, `stats.read`) stay in wave 2.
