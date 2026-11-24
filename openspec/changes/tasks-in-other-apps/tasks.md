# Tasks

Nothing below section 1 starts before heliopsy/tix has released phase 1 of its CalDAV change with `dav.info`,
the `dav.password.*` operations and the `caldav` scope in its OpenAPI document. Phase 2 starts after tix
releases CalDAV writes. Each task is one small PR or commit with its test.

## 1. Spec and contract

- [x] 1.1 Proposal, design, `dav-accounts`, `app-settings` and `calendar-feed` deltas; `just spec` passes
- [ ] 1.2 Compare with the tix plan; update `design.md` Server contract for every assumption it confirms or changes
- [ ] 1.3 **Blocked on heliopsy/tix phase 1 release:** move `tix.lock` to it, `just openapi-sync`, `just gen`, `just engine-notices`; `just gen-check` passes
- [ ] 1.4 Classify the new operations in `core/capability` (pending in `exemptions.yaml` until bound); `flutter test test/core/capability` passes

## 2. Phase 1: data layer

- [ ] 2.1 `DavRepository.info()` on `api.dav.info`, with 404/405 as "not offered"; tests against `FakeTix` for ready, off, 403, 404
- [ ] 2.2 `DavRepository.passwords()` and `revoke(id)`, no response cache; tests
- [ ] 2.3 `DavRepository.create(name)` returning the issued value only; `test/core/session/secrets_test.dart` covers it
- [ ] 2.4 Build the repository in `core/session/session.dart` from `sessionApiProvider`
- [ ] 2.5 If tix chose `token.create` instead: map onto `token.*` with the `caldav` filter; same tests pass

## 3. Phase 1: platform hand-off

- [ ] 3.1 Profile builder (pure Dart): plist XML, escaping, https/http, port, per-connection identifier; unit tests on the XML
- [ ] 3.2 One-shot loopback profile server: random path, one response, 2 minute close, closes on dispose, no logging; unit tests
- [ ] 3.3 DAVx5 URI builder: `caldavs://`/`caldav://`, port, path, never user info; unit tests
- [ ] 3.4 `DavHandoff` interface and fakes; platform choice by service, not width
- [ ] 3.5 Android: `<queries>` for `at.bitfire.davdroid`, `tix/dav` `davx5Installed` and `openDavx5` with extras, no logging
- [ ] 3.6 iOS: `tix/dav` `beginBackgroundTask`/`endBackgroundTask` around the loopback serve; share-sheet fallback
- [ ] 3.7 macOS: write to the temp directory, open with the system handler, delete on sheet close and on start
- [ ] 3.8 Sensitive clipboard: Android 13+ flag over `tix/dav`, iOS local-only expiring item; tests through a fake

## 4. Phase 1: application and screen

- [ ] 4.1 `davInfoProvider` mapping local, old server, off, not allowed, ready, error; tests in a `ProviderContainer`
- [ ] 4.2 `AppPasswords` notifier: list, create (value returned, never in state), revoke; tests
- [ ] 4.3 Route `/settings/other-apps`, settings catalogue item with search keywords, Calendar feed link
- [ ] 4.4 `OtherAppsScreen`: lead text and every state, at 400 and 1280, light and dark; widget tests
- [ ] 4.5 Setup sheet: name field, create, hand-off per platform fake, details with per-field copy, reveal toggle; widget tests
- [ ] 4.6 Password list rows and revoke with `confirmDestructive`; revoked row has no `RefusedMark`; widget tests
- [ ] 4.7 A `401` on `dav.*` reaches `RefusedCredentials` like any other call; test that an app password never enters a request
- [ ] 4.8 Context switch closes the sheet and drops the value; widget test
- [ ] 4.9 Strings in `app_en.arb`, `app_bg.arb`, `app_de.arb`, `app_fr.arb`; Apple step names checked per language
- [ ] 4.10 Screen help entry in `core/help/screen_help.dart` for tix's CalDAV docs page; anchors check passes
- [ ] 4.11 Semantics labels, 48 dp copy buttons, 200% text check; gallery entry for any new design component

## 5. Phase 1: docs and privacy

- [ ] 5.1 README feature list and `docs/architecture.md` (the hand-off, and that the app never sends an app password)
- [ ] 5.2 Store listing privacy paragraph in `fastlane/metadata/android/*/full_description.txt`
- [ ] 5.3 Issue or PR on tix.red-site for the matching line in `messages/*/privacy.json`, part `app`, with `lastUpdated` moved

## 6. Phase 1: device checks

- [ ] 6.1 iPhone: Safari download, Profile Downloaded, install, Reminders shows the projects; reinstall replaces the account
- [ ] 6.2 macOS: profile through System Settings, Reminders shows the projects
- [ ] 6.3 Android: DAVx5 from F-Droid and from Play opens filled in; tasks land in tasks.org and jtx Board
- [ ] 6.4 Android without DAVx5: details and store links per flavour
- [ ] 6.5 Linux: Thunderbird with the copied details shows the tasks
- [ ] 6.6 Revoke on the screen; the other app stops syncing and the tix app's own connection is unaffected

## 7. Phase 2: write-back

- [ ] 7.1 **Blocked on heliopsy/tix phase 2 release:** move `tix.lock`, `just gen`, classify any new operation
- [ ] 7.2 `davInfoProvider` reads `write`; lead text for write-back; widget test
- [ ] 7.3 Read only mark and Replace on passwords without the write scope, offering to revoke the old one; widget tests
- [ ] 7.4 Check that a change made in Reminders arrives as a live event and an offline edit to the same task merges; device test
- [ ] 7.5 Strings in all four languages; README and privacy lines updated if the wording changes
