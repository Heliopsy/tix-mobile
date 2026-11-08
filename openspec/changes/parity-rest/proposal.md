# Proposal

## Why

After the wave 2 and 3 pull requests, `just parity` still lists a tail of operations no screen offers: accepting an
invite inside the app, a task's lease, single workflow transitions, a task's own tags, a saved filter by name, the
caller's date display, the status report, bundles, snapshot imports, token rotation and archived projects. A person
who receives an invite link has to open a browser to accept it and then type the server address into the app.
Notifications also show task titles on a locked screen, and lease lengths read as Go durations ("2h0m0s").

## What Changes

- Invite links: paste one, or share it to tix, and the app previews what it admits to, accepts it with a new or
  existing password (and a code when the account needs one), and adds the server and the sign-in itself.
- The task screen shows how long a claim on the task lasts and where that comes from; a move one transition away is
  a single transition; the tag picker reads the task's tags fresh.
- Saved filters open by name from `/tasks?filter=<name>`, and a tapped chip is checked against the server.
- Settings gain Date and time (format and timezone, kept with the account).
- Manage gains Server status, Bundles (export and import with a preview) and Import a snapshot (dry run first).
- The projects list can show archived projects, with a badge.
- Your own API tokens can be rotated, and the app swaps in the new secret when it rotates the one it uses.
- Notifications: a per-context switch hides task content; Android notifications are private with a public version.
- Lease lengths read as human durations wherever tix returns them.
- Every new string in English, Bulgarian, French and German.

## Impact

- Operations bound: `invite.preview`, `invite.accept`, `task.lease`, `task.tags`, `task.transition`, `filter.show`,
  `time.settings`, `time.prefs.set`, `status.read`, `bundle.export`, `bundle.import`, `snapshot.import`,
  `token.rotate`; `project.list` gains `include_archived`.
- `just parity` reports no pending operation.
- Android: `MainActivity` adds a `tix/notes` channel that gives a posted notification its public version, because
  `flutter_local_notifications` cannot.
- The transport's text reads keep a `+json` body as text (a bundle is `application/vnd.tix.bundle+json`).
- No new dependencies.
