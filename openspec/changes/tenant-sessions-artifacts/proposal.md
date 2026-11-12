# Proposal

## Why

tix v0.58.0 lets a tenant admin shorten how long a sign-in lasts, sign idle sessions out, set or turn off Keep me
signed in, and narrow the size and media types an artifact file may have. The web's tenant page edits all five;
the app's tenant settings had no way to see or change them.

## What Changes

- A **Sessions** section on the tenant settings screen: sign-in lasts (`session_ttl`), sign out when idle for
  (`session_idle_timeout`) and Keep me signed in lasts (`session_remember_ttl`, a duration, `off`, or empty).
- An **Artifacts** section: largest artifact file (`artifact_max_bytes`, written as 512KiB or 5MiB) and accepted
  types (`artifact_types`, comma separated).
- An empty field inherits the server's setting, which the field shows greyed as its hint, read from
  `GET /api/v1/auth/session-policy` and `GET /api/v1/artifact-limits`. A value above the server's is refused by
  the server and its message is shown.
- Each section sends only the fields that changed, like Claims.

## Depends on

The stay-signed-in change, which pins tix v0.58.0 and generates `session_ttl`, `session_idle_timeout`,
`session_remember_ttl`, `SessionPolicy` and `ArtifactLimits`.
