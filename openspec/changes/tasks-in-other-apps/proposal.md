# Proposal

## Why

People want their tix tasks next to everything else they track: Apple Reminders on an iPhone or a Mac, tasks.org
or jtx Board on Android through DAVx5, Thunderbird or Evolution on a desktop. tix is adding a CalDAV server
(heliopsy/tix#380, change `caldav-tasks`) that publishes tasks as VTODO, Assigned to me and one collection per
project, behind HTTP Basic with an app password: a tix API token whose only scope is `caldav`, which only CalDAV
accepts.

Setting up a CalDAV account by hand is the hard part. The person needs the right address, the right user name
(on a shared host that is not obvious), and a password, which an SSO-only account does not have. The app already
knows the server, holds a credential that can mint an app password, and runs on the device where the other app
lives, so it can do the setup in a couple of taps.

The app already surfaces tix's read-only iCalendar feed (`calendar-feed`, Settings, Calendar). That feed is a
VEVENT subscription of due dates for calendar apps; it does not reach task apps and cannot be written back. This
change sits beside it and does not replace it.

## What Changes

- A new screen, **Tasks in other apps** (`/settings/other-apps`), in the account group of Settings for the active
  context, reached from Settings, settings search and the Calendar feed screen.
- It explains what CalDAV does and what it does not, then asks the server whether it serves CalDAV
  (`dav.info`). An old server, a server with CalDAV turned off, a local instance and a credential that may not
  use it (an agent) each get their own explanation and no setup.
- It shows the address and the exact user name tix gives (the sign-in email), for setting up by hand.
- **Set up** mints a dedicated app password for this device and use (`dav.password.create`), named after the app
  and platform, editable, with the lists it shows (Assigned to me by default, one per project, or both) and an
  optional expiry (never by default). The value exists only in the answer, the hand-off and the one-time sheet.
  It is never cached, kept in provider state, written to storage or logged.
- The hand-off depends on the platform service, not the window width:
  - **iOS and macOS:** the app builds a CalDAV configuration profile (`com.apple.caldav.account`) and opens it,
    so Reminders gets the account after the system's install steps. The steps and the unsigned-profile warning
    are explained on screen.
  - **Android:** with DAVx5 (`at.bitfire.davdroid`) installed, the app opens its login screen filled in through
    DAVx5's documented intent extras. Without it, the details are shown with copy buttons and links to DAVx5,
    tasks.org and jtx Board.
  - **Linux and Windows:** the details for Thunderbird or Evolution with copy buttons.
  - The details with copy buttons are available on every platform as the fallback.
- The screen lists this person's app passwords (name, created, last used, state) and revokes any of them after
  confirming. Revoking is how a lost phone or a removed Reminders account is cleaned up.
- The app never authenticates with an app password itself, so a refused app password can never trip
  `RefusalInterceptor` or mark the app's own connection refused. A `401` on the app's own calls stays what it is
  today: the main credential was refused.
- Works for sign-in connections (SSO or password) and token connections, on every remote instance, each context
  with its own list.
- Phase 2, when `dav.info` says the caller may write over CalDAV, the screen says changes sync back and offers
  a Read only choice for new passwords. Existing passwords write without being replaced, since tix reads each
  request as the owner's current role; a password created read only is marked and can be replaced.

## Non-goals

- The app does not read or write the device's Reminders, Calendar, tasks.org or any other task store. tix stays
  the source of truth, the app keeps syncing over the tix API, and no calendar or reminders permission is asked.
- No CalDAV client inside the app, and no change to how the app itself syncs, caches or works offline.
- No signed configuration profiles: the app has no certificate to sign them with, so iOS and macOS show the
  profile as unverified.
- No setup for local instances: their engine runs on loopback and stops in the background, so no other app could
  reach it reliably.
- No CardDAV, no VEVENT over CalDAV, no per-project choice of collections: the app offers tix's choices
  (Assigned to me, projects, both) and nothing finer.
- No automatic setup of Thunderbird, Evolution or other desktop clients; they get copyable details only.

## Impact

- Capabilities: `dav-accounts` (new), `app-settings` and `calendar-feed` (added requirements).
- Code: `data/api/dav_ops.dart` and `data/models/dav.dart` (by hand until the generated client has them),
  `data/repositories/dav_repository.dart`, `features/dav/` (application and presentation),
  `core/platform/dav_handoff.dart`, `dav_profile.dart` and `profile_server.dart`, a `tix/dav` channel on Android
  (DAVx5, the sensitive clipboard) and iOS (background time while Safari fetches the profile, the expiring
  clipboard), `AndroidManifest.xml` `<queries>` for DAVx5, `core/router`, `core/help/screen_help.dart`,
  `lib/l10n/*.arb` (en, bg, de, fr), the README feature list, the store listing's privacy paragraph.
- **Depends on heliopsy/tix:** the CalDAV server, the `caldav` scope, `dav.info` and the `dav.password.*`
  operations, settled in heliopsy/tix#380 and expected in tix 0.69.0. The app asks `dav.info` rather than
  comparing versions, so phase 1 can ship before `tix.lock` moves; moving it replaces the hand-written client with
  the generated one and classifies the operations in `core/capability`. The contract is in `design.md`, Server
  contract.
- Privacy: the app password is handed to another app, which stores it. The privacy policy on tix.red (`app`
  part) needs a matching line.
- New dependencies: none planned. The profile is plain XML, the loopback server is `dart:io`, the hand-off uses
  `url_launcher`, `share_plus` and `path_provider`, all already in use.
