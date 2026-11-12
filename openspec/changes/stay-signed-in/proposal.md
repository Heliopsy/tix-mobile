# Proposal

## Why

A password sign-in lasted a fixed 12 hours, and then every screen answered with a sign-in error. tix v0.58.0
(heliopsy/tix#321) adds Keep me signed in: `"remember": true` on the step of `POST /api/v1/auth/login` that
completes the sign-in mints a session that lasts the tenant's `remember_ttl` (30 days by default), and
`GET /api/v1/auth/session-policy`, readable without a credential, says whether the tenant offers it. The app
never sent the flag, so its sessions were always the short kind.

## What Changes

- tix.lock moves to v0.58.0; the vendored OpenAPI document and the generated client gain `remember`,
  `SessionPolicy` and `session.policy`.
- The sign-in form, and Sign in again, carry a **Stay signed in** switch, on by default.
- With it on, the app reads the session policy first and sends `"remember": true` only where it is offered, on
  the password step and again on the second factor step. A tix without the policy route, which answers it as
  `401` or `404`, is never sent the field, so signing in to an older server is unchanged.
- The sign-in help and the README stop promising "about 12 hours".
- Sign in again already keeps the instance and the email; nothing changes there.

## Why on by default

The app runs on a personal phone or a personal desktop, where signing in again every morning is the problem the
person reported, and where an API token, the alternative the form suggests, never expires at all. The switch is
visible on the form with a line saying to turn it off on a shared device, and the tenant's own setting still wins:
a tenant that turned Keep me signed in off gets an ordinary session.
