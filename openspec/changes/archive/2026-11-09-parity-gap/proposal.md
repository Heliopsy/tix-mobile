# Proposal

## Why

The pinned tix exposes four operations the app still lists as pending in `exemptions.yaml`: purging a trashed
task, listing and revoking one's own sessions, and pinging a webhook. On top of that, `webhook.put` now answers
`IssuedWebhook` and returns the secret tix generated for an endpoint saved without one, while the app still makes
up its own secret and throws away what the server sends back.

## What Changes

- Trash: each trashed task gets **Delete for good** (`task.purge`), red and confirmed first. The list reloads
  afterwards. The explanation no longer claims only housekeeping deletes for good.
- Security: an **Active sessions** section (`session.list`, `session.revoke`) lists the person's sessions with
  the user agent, how it signed in, when it began and when it expires, and marks the one in use. Revoking
  confirms first; revoking the one in use signs this connection out. A token without `account:read` sees an
  explanation instead of an error, whether the app knows it up front or the server answers 403.
- Webhooks: **Send test** (`webhook.ping`) on an active endpoint, showing the delivery tix answered: its status,
  the HTTP status the endpoint returned, and the error if any. tix does not report latency, so none is shown.
- Webhook secrets: the app stops generating secrets. A blank secret on a new endpoint is left to tix, and the
  `secret` from `IssuedWebhook` is shown once with `OneTimeSecret`. It never reaches the cache, the log or state.

## Impact

- Capabilities: changed `maintenance`, `account-security`, `webhooks`.
- Operations bound: `task.purge`, `session.list`, `session.revoke`, `webhook.ping`. `exemptions.yaml` has no
  pending operations left.
- Strings in all four ARB files.
