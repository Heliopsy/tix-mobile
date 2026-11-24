# Tasks

heliopsy/tix#380 settled the contract (design.md, Server contract). Phase 1 here talks to it through a
hand-written `DavOps` until `tix.lock` moves to the tix release that ships CalDAV (expected 0.69.0). Phase 2
wording and controls are gated on `dav.info`'s `write`, so they light up when tix releases write-back.

## 1. Spec and contract

- [x] 1.1 Proposal, design, `dav-accounts`, `app-settings` and `calendar-feed` deltas; `just spec` passes
- [x] 1.2 Compare with the tix plan; update `design.md` Server contract for every assumption it confirms or changes
- [ ] 1.3 **Blocked on the tix release with CalDAV (0.69.0):** move `tix.lock`, `just openapi-sync`, `just gen`, `just engine-notices`, `just doc-anchors-sync`; replace `DavOps` and `data/models/dav.dart` with the generated `api.dav.*`; `just gen-check` passes
- [ ] 1.4 **With 1.3:** bind `dav.info` and `dav.password.*` in `core/capability/registry.dart`; `flutter test test/core/capability` passes
- [ ] 1.5 **With 1.3:** point `/settings/other-apps` in `screenDocs` at `caldav.md#app-passwords`; the anchors check passes

## 2. Phase 1: data layer

- [ ] 2.1 Hand-written `DavOps` (`api.appDav`) and models for the four operations, marked for replacement by `just gen`
- [ ] 2.2 `DavRepository.info()` with 404/405 as "not offered"; tests against `FakeTix` for ready, off, 403, 404, 405
- [ ] 2.3 `DavRepository.passwords()` and `revoke(id)`, no response cache; tests
- [ ] 2.4 `DavRepository.create(...)` with name, collections, read_only and expires_at, returning the issued value only; `test/core/session/secrets_test.dart` covers it
- [ ] 2.5 Build the repository from `sessionApiProvider`

## 3. Phase 1: platform hand-off

- [ ] 3.1 Profile builder (pure Dart): plist XML, escaping, https/http, port, per-connection identifier; unit tests on the XML
- [ ] 3.2 One-shot loopback profile server: random path, one response, 2 minute close, closes on dispose, no logging; unit tests
- [ ] 3.3 DAVx5 address builder: `caldavs://`/`caldav://`, port, path, never user info; unit tests
- [ ] 3.4 `DavHandoff` interface and fakes; platform choice by service, not width
- [ ] 3.5 Android: `<queries>` for `at.bitfire.davdroid`, `tix/dav` `davx5Installed` and `openDavx5` with extras, no logging
- [ ] 3.6 iOS: `tix/dav` `beginBackgroundTask`/`endBackgroundTask` around the loopback serve; share-sheet fallback
- [ ] 3.7 macOS: write to the temp directory, open with the system handler, delete on sheet close and before the next profile
- [ ] 3.8 Sensitive clipboard: Android flag over `tix/dav`, iOS local-only expiring item; tests through a fake
- [ ] 3.9 Store links per flavour: F-Droid in oss, Google Play in play, for DAVx5, tasks.org and jtx Board

## 4. Phase 1: application and screen

- [ ] 4.1 `davStatusProvider` mapping local, old server, off, not allowed, ready, error; tests in a `ProviderContainer`
- [ ] 4.2 `AppPasswords` notifier: list, create (value returned, never in state), revoke; tests
- [ ] 4.3 Route `/settings/other-apps`, settings catalogue item with search keywords, Calendar feed link
- [ ] 4.4 `OtherAppsScreen`: lead text, details with copy, and every state, at 400 and 1280; widget tests
- [ ] 4.5 Setup sheet: name, collections, expiry, create, hand-off per platform fake, details with per-field copy, reveal toggle; widget tests
- [ ] 4.6 Password rows (lists, created, expiry, last use, state) and revoke with `confirmDestructive`; revoked row has no `RefusedMark`; widget tests
- [ ] 4.7 A `401` on `dav.*` reaches `RefusedCredentials` like any other call; test that an app password never enters a request
- [ ] 4.8 Context switch closes the sheet and drops the value; widget test
- [ ] 4.9 Strings in `app_en.arb`, `app_bg.arb`, `app_de.arb`, `app_fr.arb`
- [ ] 4.10 Apple step names checked per language on a device in that language
- [ ] 4.11 Links to tix's per-client guide through the server's docs redirect
- [ ] 4.12 Semantics labels, 48 dp copy buttons, reveal toggle with hidden semantics value; 200% text check in a widget test

## 5. Phase 1: docs and privacy

- [ ] 5.1 README feature list and `docs/architecture.md` (the hand-off, and that the app never sends an app password)
- [ ] 5.2 Store listing privacy paragraph in `fastlane/metadata/android/*/full_description.txt`
- [ ] 5.3 Privacy note on the screen itself, beside the setup action
- [ ] 5.4 Issue or PR on tix.red-site for the matching line in `messages/*/privacy.json`, part `app`, with `lastUpdated` moved

## 6. Phase 1: device checks

- [ ] 6.1 iPhone: Safari download, Profile Downloaded, install, Reminders shows the lists; reinstall replaces the account
- [ ] 6.2 macOS: profile through System Settings, Reminders shows the lists
- [ ] 6.3 Android: DAVx5 from F-Droid and from Play opens filled in; tasks land in tasks.org and jtx Board
- [ ] 6.4 Android without DAVx5: details and store links per flavour
- [ ] 6.5 Linux: Thunderbird with the copied details shows the tasks
- [ ] 6.6 Revoke on the screen; the other app stops syncing and the tix app's own connection is unaffected
- [ ] 6.7 Android 13+: the copied password is hidden in the clipboard preview; iOS: it is gone after 2 minutes

## 7. Phase 2: write-back

- [ ] 7.1 **Blocked on the tix release with CalDAV writes:** move `tix.lock`, `just gen`, classify any new operation
- [ ] 7.2 Lead text for write-back and the Read only choice, gated on `dav.info` `write`; widget test
- [ ] 7.3 Read only mark and Replace on `read_only` passwords while `write` is true, offering to revoke the old one; widget tests
- [ ] 7.4 Check that a change made in Reminders arrives as a live event and an offline edit to the same task merges; device test
- [ ] 7.5 Strings in all four languages
