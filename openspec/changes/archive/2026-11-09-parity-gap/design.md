# Design

## Purge

`MaintenanceRepository.purge(ref)` calls `task.purge` and drops the task from the kept first page (read with
`stored`, not `peek`, which serves a key once per cache). `Trash.purge(task)` then invalidates `trashProvider` and
`housekeepingProvider`, so the list and the counts come from the server. The trash screen shows the
button only when the credential `can(Scopes.taskDelete)`, the scope tix asks for, and confirms with
`confirmDestructive` before anything is sent.

## Sessions

`SecurityRepository.sessions({cursor})` and `revokeSession(id)` wrap `session.list` and `session.revoke`. The
`ActiveSessions` notifier pages with tix's cursor like every other listing. `revoke(session)` calls the server,
then, when `session.current` is set, calls `SessionController.signOut()`: that forgets the connection and its
secret. The logout it attempts on the way out fails against a revoked session, and `signOut` already ignores that.
Keeping the sign-out in the notifier means the widget never decides what revoking implies.

tix gives no IP address, location or last-seen time for a session; the section shows what `SessionInfo` carries:
user agent, method, second factor, created and expiry. If tix adds the others later they slot into the same row.

Gating: `Access.can(Scopes.accountRead)` is already true for a person's own session and only true for a token
that names `account:read`. When it is false the section explains why and sends nothing. When the server still
answers 403 (a token whose scopes the app read wrong, or a narrower server rule) the section shows the same
explanation instead of `ErrorState`.

## Ping

`IntegrationsRepository.ping(id)` returns the `WebhookDelivery` tix answers. `WebhookDeliveries` is family-keyed
by filters, so the notifier that pings is `WebhookEndpoints.ping(id)`; it invalidates the delivery log family so
the new delivery shows up. The screen shows the answer in a small sheet: status badge, HTTP status if any,
attempts and the last error. "Send test" appears in the row's action sheet only for an active endpoint, since tix
refuses an inactive one.

## Webhook secret

`saveWebhook` sends the secret only when the person typed one, and returns `issued.secret` (empty means none) as
`generatedSecret`. The secret is a return value only: it is not in `WebhookEndpoints` state, not in the endpoint
written to the cache (`WebhookEndpoint` has no secret field), and the transport's log lines name the method and
path, never the body. The UI path that shows it with `OneTimeSecret` already exists.

## Alternatives

- Keeping client-side generation as a fallback for older servers: the pin is `tix.lock`, and the pinned server
  generates. Two sources of secrets would only make the "shown once" rule harder to reason about.
