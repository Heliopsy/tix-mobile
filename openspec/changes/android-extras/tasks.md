# Tasks

## 1. Links

- [ ] 1.1 `tix://quick-add` and `tix://tasks?filter=`, link builders with the context, `DeepLinkHost` opens quick add; tests

## 2. Quick Settings tiles

- [ ] 2.1 `QuickAddTileService` and `InboxTileService`, manifest entries with `BIND_QUICK_SETTINGS_TILE`, icons
- [ ] 2.2 Tile strings in English, Bulgarian, French and German, checked by the native strings test

## 3. Notification actions

- [ ] 3.1 Actions chosen per notification (Done, Snooze, Reply; no Reply and unlock required when content is hidden); tests
- [ ] 3.2 `PublicNotes` adds them with `PendingIntent`s to `NoteActionReceiver`; `NoteActionHub` with the headless entry
- [ ] 3.3 The runner writes through the context's outbox with idempotency keys, dismisses or follows up; tests

## 4. Pinned shortcuts

- [ ] 4.1 `tix/pins` channel, `PinnedShortcuts` and the shortcut model; tests
- [ ] 4.2 Add to home screen on a project and a saved filter, hidden where unsupported; widget tests

## 5. Docs

- [ ] 5.1 `docs/adb.md` lists the new links, README feature list
