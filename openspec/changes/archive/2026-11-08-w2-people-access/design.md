# Design

## Who may do what

`GET /api/v1/whoami` answers with the caller's role and, for a token, its scopes. `Access` (data layer) mirrors
tix's `Actor.HasScope`: a scope is held when the token carries it, carries `*`, or the role grants it, except
`account:read` and `global:admin`, which `*` never grants. A person's session reads its own account. The app
uses it only to hide what would be refused; the server still decides, and a refusal is shown as usual.

## Secrets

An invite link, a token value and a calendar address exist in exactly one response. They are held in the
widget state of the sheet that shows them and nowhere else: never in a provider, never in the response cache,
never in a log line. Token and invite listings are not cached at all, so a later change in tix that adds a
secret to a listing cannot land on disk. A test creates each secret through the repositories and screens and
then searches the cache store and the captured log for it.

## Users and roles

`user.list` does not carry roles; the role is the membership's. The users screen reads `member.list` beside
it, as the web's Users screen does, and draws "no role" for an account without a membership. Without
`tenant:admin` the member list is refused and the role column is left out rather than failing the screen.

## Export

`task.export` answers CSV, JSON, NDJSON or Markdown depending on the body's `format`. The generator types an
operation by its JSON response, so it gains a `…File` twin returning bytes for every operation that lists more
than one media type. The app writes those bytes untouched through the platform's save dialog or share sheet.

## Placement

Personal things (account, calendar feed, own tokens) are reached from Settings. Tenant administration (users,
all tokens, export and import) is reached from the Manage hub, each entry shown only when `Access` allows it.
