# Design

## Invites

An invite link is `https://<server>/invite/<tix_inv_…>`. `InviteLink.parse` (data/models) finds it anywhere in a
pasted or shared text and keeps a path prefix, so a server under `/tix` keeps it. The connect screen gains a third
method, Invite, chosen by `/connect?invite=<link>`, by a share that carries a link, or by hand. The flow checks the
server, calls `invite.preview` without a credential and shows the tenant, the address and the expiry. Accepting
calls `invite.accept` with the cli surface, as a sign-in does, and its `LoginResult` goes through the same steps as
a password sign-in: a code challenge, a choice of tenant, then a saved sign-in connection on a new or existing
instance. The link is a secret: it is never cached or logged.

Android cannot claim `https` links on servers nobody knows in advance, so links arrive by share or paste. A share
while signed out is taken by the connect screen: an invite opens the form, anything else becomes the quick-add
draft that waits for a sign-in, as before.

## Tasks

`task.lease` is read beside the task and drawn as a property row only when it answers, so a credential without
`task:read` on leases or an older server shows nothing. The move sheet already knows the workflow's routes; a route
with no state in between is sent as `task.transition`, anything longer stays `task.route`, which reports where it
stopped. The tag picker unions the task's tags with `task.tags`, read when it opens.

## Saved filters

A chip applies the cached filter at once, then reads it with `filter.show` and applies the server's copy if the
query, sort or view changed. A filter deleted elsewhere clears and drops out of the list. `/tasks?filter=<name>`
opens one by name; tix prefers the reader's own over a shared one of the same name.

## Status, bundles

Server status draws `status.read` as
sections, cached for a quick first draw. Bundles export the picked kinds through the share sheet or a save dialog
and import after a preview, asking first when collisions replace. A snapshot import always dry-runs first and
confirms; replace is the danger button. All three are Manage entries.

A bundle is NDJSON served as `application/vnd.tix.bundle+json`, and Dio decodes any `+json` body even when asked
for text, which fails on NDJSON. `TixTransport.text` therefore reads bytes and decodes UTF-8 itself; a refusal read as
bytes still yields the server's error envelope.

## Token rotation

A remote token connection offers Rotate token. The app asks `whoami` for the token's id, calls `token.rotate` with a
one minute grace so requests already in flight still land, writes the new value over the old one in secure storage
and rebuilds the session when the connection is the active one. The value never reaches a log or the cache.

## Notifications

`hideContent` is stored per notification context beside `enabled`. When on, the title and body are the generic
"New in your inbox" text; the tap still opens the item. Every note also carries a public version. The plugin posts
with `VISIBILITY_PRIVATE` but cannot set one, so `PublicNotes` in `MainActivity` recovers the posted notification's
builder, sets the public version and reposts it silently (API 24 and later; older Android redacts it).

## Durations

`parseGoDuration` reads tix's Go durations and `formatDuration` writes days, hours and minutes with localised
units ("1 d 12 h", "1 Std. 30 Min."). `humanDuration` passes anything that is not a duration through.

## Exemptions

None added: every remaining operation has a place in the app.
