# Design

## Asking the policy rather than the version

Whether to send `remember` is decided by `GET /auth/session-policy`, not by the version `/healthz` reports.
The route is what the field came with, a development build's version says nothing reliable, and the policy is
also what tells the app the tenant turned the choice off. An older tix has no public route there, so its
authentication middleware answers `401`; that and `404` both read as "no policy".

`rememberOffered` mirrors tix's own rule (`remember_ttl` longer than `ttl`) and lives in the connect flow, the
application layer, because the duration parser is in `core/l10n`, which the data layer may not import.

## The choice rides on the draft

`SignInDraft.remember` holds the decision made at the password step, so the code step sends the same thing
without asking the policy again.

## Invites

Accepting an invite signs in without the switch. tix's invite accept input has no `remember` field.
