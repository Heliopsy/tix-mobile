# Tasks

## 1. Spec

- [x] 1.1 `home-widgets` delta

## 2. Code

- [x] 2.1 `KeyValueStore.reload`, swapping in a fresh preferences cache
- [x] 2.2 `InstancesRepository` reloads before writing connections; `update` keeps a refusal
- [x] 2.3 `RefusedCredentials.record` reloads and answers true for a refusal already recorded or a deleted session
- [x] 2.4 `appResumedProvider` reloads settings before it fires

## 3. Tests

- [x] 3.1 A session the headless run refused signs out on the next sync, with one notification
- [x] 3.2 A token the headless run refused stays refused across `activate` and drops the session
- [x] 3.3 Repository keeps a refusal another cache wrote; `save` clears it
- [x] 3.4 `PrefsKeyValueStore.reload` and the resume reload
