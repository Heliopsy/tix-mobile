# Tasks

## 1. Trash

- [x] 1.1 `MaintenanceRepository.purge` and `Trash.purge`, invalidating the trash list
- [x] 1.2 Delete for good on the trash screen, gated on `task:delete`, confirmed first

## 2. Sessions

- [x] 2.1 `SecurityRepository.sessions` / `revokeSession`, `ActiveSessions` notifier with keyset paging
- [x] 2.2 Revoking the current session signs out
- [x] 2.3 Active sessions section, current marked, explanation for a token without `account:read` or a 403

## 3. Webhooks

- [x] 3.1 `IntegrationsRepository.ping` and `WebhookEndpoints.ping`, reloading the delivery log
- [x] 3.2 Send test on an active endpoint, with the delivery result
- [x] 3.3 Use the secret `webhook.put` returns; stop generating one in the app

## 4. Parity and checks

- [x] 4.1 Bind `task.purge`, `session.list`, `session.revoke`, `webhook.ping`; drop them from `exemptions.yaml`
- [x] 4.2 Strings in en, fr, de and bg
- [x] 4.3 Unit and widget tests
