# Proposal

## Why

tix's web has a Release screen (`/release`): the version the server runs, whether it is up to date, the commands
that upgrade it and the release notes. The app only showed the server's version in About. The update-check state
was not in the API; Heliopsy/tix#328 adds `GET /api/v1/release` for any signed-in caller.

## What Changes

- A Server release screen under Settings, About, and in the palette, reading `GET /release`: a status card
  (update available, up to date, not comparable, check failed, not checked) with the running and newest version,
  the upgrade command per install method with Copy when a newer release is out, its notes, and the changelog the
  server carries with the running version marked.

## Impact

- Capabilities: `server-release` (new).
- Code: `data/models/release.dart` (the generated `ReleaseBody` and friends) and
  `data/repositories/release_repository.dart`, `features/release`, router, Settings, palette, screen help, l10n,
  README. `server.release` is bound in the capability registry.
- Needs tix v0.60.0, which ships Heliopsy/tix#328 and which `tix.lock` pins.
