# Design

## Data

Three repositories, built in `core/session/integrations.dart` from the session's client and cache:
`IntegrationsRepository` (webhooks, sync), `MaintenanceRepository` (retention, housekeeping, trash) and
`AuditRepository`. Every call is a generated method.

Caching follows what each read carries. The webhook endpoint list, the retention policy, the housekeeping view and
the first page of the trash are cached: none holds a secret. Sync sources are not, because they carry credential
hints and mapping documents. The audit log is not, because entries record changes to credential-bearing records
and almost every read is filtered. The delivery log changes too fast to be worth caching.

## Webhook secrets

tix's `PUT /webhooks` generates a secret when none is sent, but `WebhookEndpoint.Secret` is `json:"-"`, so the HTTP
answer never carries it and the person could not configure the receiver. For a new endpoint saved with the field
blank, the repository generates 32 bytes from `Random.secure()` as hex, sends it, and hands it back once. The
screen shows it in `OneTimeSecret` in a sheet that does not dismiss by tapping outside. The value lives only in that
sheet: never in the cache, a log line or a route. An update with a blank field sends no secret, which keeps the
stored one.

## Sync

The form is the web dialog: system (generic, jira, openproject; fixed once saved), name, the settings that system
takes, a mapping document or a mapping file on the server, and credentials that are written and never read back
(the stored ones are named with their last four characters). Check sends the same body with `check: true` and
shows `resolved`: where the mapping, credentials and each setting come from, what is missing, and the mapping
summary. The run history is `audit.list` for `sync_source` / `sync.run`, newest first, each entry's `after` read as
the run's result, as tix's own runs screen does. A refusal's message is always shown as tix wrote it.

## Maintenance

Retention windows are Go durations; the app shows whole days and sends days as hours. Housekeeping rules are typed
as tix takes them (`off` or days). Prune and run are destructive, so each offers a preview first and asks with a
red confirmation before the real thing.

## Audit log

`AuditQuery` is a value object and the family key of the paged log provider, so a filter change starts a new
keyset listing. Channel chips sit over the list; actor, action, token, surface and time are in a sheet. On a wide
window the selected entry's detail is the right pane; on a phone it opens in a sheet.

## Navigation

Each screen has a `/manage/...` route in the settings branch, until the Manage hub lists them.
