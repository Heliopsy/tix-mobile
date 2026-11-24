# Design

## Server contract

Settled in heliopsy/tix#380 (`openspec/changes/caldav-tasks/design.md`, "Contract with tix-mobile" and "Phase 1
as built", `api/openapi.yaml` and `docs/caldav.md` on `feat/caldav-read`). Phase 1 ships in the first tix minor
that contains it, expected 0.69.0; write-back is a later minor.

- **CalDAV endpoint.** RFC 4791 under `{server}/dav/`, with `/.well-known/caldav` answering 301 there.
  `current-user-principal` and `calendar-home-set` are served, so iOS, macOS and DAVx5 find the collections from
  the base address alone. Every collection's `supported-calendar-component-set` is exactly `VTODO`. In phase 1
  `current-user-privilege-set` is `DAV:read` alone, so the clients show the lists as read only.
- **Collections.** Each app password chooses which lists the other app sees, when it is created: `assigned`
  (Assigned to me, the default), `projects` (one per project the person can read) or `all` (both, so a task
  assigned to the person shows twice). Changing it means a new password, since clients cache the list of lists.
- **`dav.info`.** `GET /api/v1/dav`, with the app's own credential (session cookie or bearer token) holding
  `task:read`. It answers:
  - `enabled` (bool): the server answers CalDAV at all (`caldav.enabled`, a deployment setting);
  - `path` (`/dav/`) and `url`, the absolute address built from the server's public URL and trusted proxies.
    `url` is empty when the server does not know its own address; the app then uses `path` on the connection's
    base address, as it does for the calendar feed;
  - `username`: the exact Basic user name, the caller's sign-in email, or their handle when the account has no
    email. tix also accepts the handle typed by hand. The app shows tix's value and never derives it;
  - `write` (bool): whether the caller's CalDAV requests may change tasks. False in phase 1, and false for a viewer
    in phase 2;
  - `reason`: why CalDAV is off, when `enabled` is false;
  - `collections`: the choices a password can be created with.

  A server without the change answers 404 (or 405), which reads as "this server does not offer it yet". An agent
  actor, or a credential without `task:read`, is refused with 403.
- **App passwords** are `dav.password.list`, `dav.password.create` and `dav.password.revoke`
  (`GET`/`POST /api/v1/dav/passwords`, `DELETE /api/v1/dav/passwords/{id}`). Underneath each is an API token whose
  only scope is `caldav`, minted for the caller's own person actor. They need `task:read` and a person caller, not
  `token:admin`, and work from SSO and password sessions and from a person's API token; an agent is 403.
  - Create takes `name` (at most 64 characters, unique among the caller's live passwords, a duplicate is 409) and
    optionally `collections`, `read_only` and `expires_at` (omitted means never, unlike `token.create`). It answers
    201 with `id`, `name`, `password` (once), `username`, `url`, `path`, `scopes` (`["caldav"]`), `collections`,
    `read_only`, `created_at`, `expires_at`. The answer repeats `username` and `url`, so the hand-off needs one call.
  - List answers metadata only, revoked passwords included: `id`, `name`, `scopes`, `collections`, `read_only`,
    `created_at`, `expires_at`, `last_used_at`, `revoked_at`. The route takes no cursor; the app reads the one page.
  - Revoke is 204, also for one already revoked, and takes effect on the next CalDAV request.
  - `token.create` with `caldav` is refused, so there is no fallback onto the token operations.
- **Authority follows the owner.** A password does not carry its owner's scopes. On every CalDAV request tix
  reads as the owner's current role, cut to the phase's ceiling (phase 1: read tasks, projects and workflows;
  phase 2 adds writing and transitions unless the password was created `read_only`). A demotion lands on the next
  request, so a phase 1 password writes in phase 2 without being replaced. `read_only` is the only way to keep a
  password from writing.
- **App passwords authenticate CalDAV only.** `caldav` is refused on `/api/v1/*` (`caldav_only`), and a session,
  bearer token, account password or ordinary API token is refused on `/dav/` (`dav_password_required`).
- **No lockout.** Failed Basic authentication is logged and nothing else; a stale Reminders account retrying a
  revoked password never locks the person's sign-in, SSO, other tokens or second factor.
- **Writes are ordinary task changes.** In phase 2 a change made over CalDAV goes through `UpdateTask`,
  `CreateTask` and the move, bumps the version and writes the usual events, so the app's live updates, cache and
  outbox merge (`merge3`) handle it with no new code.
- **Events.** Creating and revoking an app password write `token.created` and `token.revoked` with `caldav` in
  the scopes, so the list refreshes on `EventTopics.tokens`.
- **OpenAPI.** The operations are in tix's `api/openapi.yaml` as `dav.info`, `dav.password.list`,
  `dav.password.create` and `dav.password.revoke` (schemas `DAVInfo`, `DAVPassword`, `IssuedDAVPassword`,
  `CreateDAVPasswordInput`). Until `tix.lock` moves to the release that ships them, `DavOps` and its models are
  written by hand, marked as such, as `SsoOps` was; `just gen` then produces `api.dav.*` and they go.
- **Docs.** tix's `docs/caldav.md` ships with phase 1, with the anchors `#apple-reminders`, `#davx5-and-tasksorg`,
  `#thunderbird`, `#evolution`, `#app-passwords` and `#troubleshooting`.

## Where it lives

- `data/api/dav_ops.dart` and `data/models/dav.dart`: the four operations and their models, written by hand
  until the generated client has them, reached as `api.appDav`.
- `data/repositories/dav_repository.dart`: `info()`, `passwords()`, `create(...)`, `revoke(id)`. Nothing goes
  through the response cache, as `TokenRepository` does, so a field tix adds later cannot leak a value to disk.
  `info()` answers null for a server without the route.
- `features/dav/application/`: `davStatusProvider` (per active context) maps the context and `dav.info` onto
  the screen's states, and the `AppPasswords` notifier holds the list. `create` returns the issued value straight
  to the widget, never into state, as the token screens do. The list refreshes on `EventTopics.tokens`, since tix
  writes `token.created` and `token.revoked` for app passwords.
- `features/dav/presentation/`: `OtherAppsScreen`, the setup sheet and the password rows.
- `core/platform/dav_profile.dart` (the profile builder and the DAVx5 address, pure Dart),
  `core/platform/profile_server.dart` (the loopback server) and `core/platform/dav_handoff.dart` (the `DavHandoff`
  interface, one implementation per platform service, and the sensitive clipboard over `tix/dav`). None of them
  logs its arguments.
- `features/account` (the calendar feed) links to the route and does not import `features/dav`.

The screen is a `TixPage` titled "Tasks in other apps". Its primary action is **Set up on this device** (plus
icon), which opens the setup sheet with `showTixSheet`. Sections: what it does (visible text, not a tooltip), the
connection details, the passwords list, and links to tix's per-client guide. Revoking is `TixButton.danger` then
`confirmDestructive`.

## States the screen can be in

Decided once from the active context and `dav.info`, in this order:

1. **Local instance:** "Other apps cannot reach a database on this device. Use a tix server." No request, no
   setup.
2. **Old server** (404/405 on `dav.info`): "This server does not offer CalDAV yet. It needs tix 0.69.0 or later."
3. **Turned off** (`enabled: false`): "CalDAV is turned off on this server," plus tix's `reason` when given.
   Passwords made before can still be listed and revoked, so the list stays, without setup.
4. **Not for this credential** (403): tix's message, and for a token connection a hint that signing in as the
   person works too (an agent's token is refused, a person's token with `task:read` is not).
5. **Ready:** setup, details, list.

A network failure is `ErrorState` with Retry. Loading is a skeleton. A `401` is the app's own credential and goes
the usual way (`RefusedCredentials`, reconnect).

## The app password

- **Name.** Default `tix app, <platform>, <yyyy-mm-dd>` (localised), editable in the sheet, so the list says
  which device it was. The server keeps names unique among live passwords and the app shows its 409 message
  under the field.
- **Collections.** The sheet offers the choices `dav.info` lists, Assigned to me first and preselected, as tix's
  default is, with a line saying what each shows and that changing it later means a new password. A choice the
  app has no wording for is shown by its value.
- **Expiry.** Never by default, as tix's default is, because an account that stops syncing one day with no
  prompt looks broken. The sheet offers 30 days, 90 days and a year beside it; the app sends `expires_at` only
  for those.
- **Read only.** Shown only when `dav.info` answers `write: true` (phase 2), off by default. In phase 1 every
  password reads only, so the app sends nothing.
- **Lifetime of the value.** The create answer goes from the repository through the notifier method to the
  sheet. The sheet holds it in widget state until it closes, uses it for the hand-off and the copy buttons, and
  drops it. It is not written to secure storage: the app has no use for it after the hand-off, and keeping it
  would make the app a second place it can leak from. Lost means revoke and set up again. The issued model's
  `toString` leaves the password out.
- **Clipboard.** Copying the password marks the clip sensitive on Android (`ClipDescription.EXTRA_IS_SENSITIVE`,
  so Android 13 and later hide it in the clipboard preview) and on iOS uses a local-only, 2-minute expiring
  pasteboard item, both over `tix/dav`. On iOS the copy toast says it clears in 2 minutes. Desktop clipboards
  have no such marker; the toast there says to clear it after pasting. Other values copy normally.
- **Logging.** Nothing in the hand-off, the Android channel or the Swift code logs arguments, URLs with user
  info, or profile contents. `test/core/session/secrets_test.dart` gains the create answer: neither the cache, the
  log nor provider state may hold the value.
- **Refusals stay apart.** The app only calls `/api/v1/*` with its own credential. It never sends the app
  password to `/dav/` or anywhere, so `RefusalInterceptor` and `RefusedCredentials` cannot see a refused app
  password. A `401` on `dav.*` is the main credential and is handled like any other (reconnect, `RefusedMark`).
  A revoked or expired app password is a row state from `dav.password.list`, drawn with its own wording
  ("Revoked", "Expired", "Not used yet"), never with `RefusedMark`, so the two cannot be confused.
- **No probe.** The app does not test the password against `/dav/`. `last_used_at` in the list tells the person
  whether the other app has connected. This keeps the app password out of the app's HTTP stack entirely.

## Hand-off per platform

`DavHandoff` is chosen by platform service, like `SsoBrowser`. Every path also offers **Show details**: the
address, the user name and the password, each with its own copy button and a semantics label naming the field.

### iOS: configuration profile

- **Profile.** A `Configuration` plist with one `com.apple.caldav.account` payload: `CalDAVAccountDescription`
  (`tix: <tenant name>`), `CalDAVHostName`, `CalDAVPort`, `CalDAVPrincipalURL` (the `url` from tix),
  `CalDAVUseSSL` (true for https), `CalDAVUsername`, `CalDAVPassword`. `PayloadIdentifier` is
  `red.tix.mobile.caldav.<connection id>` and `PayloadUUID` a fresh v4 UUID, so setting up again on the same
  connection replaces the profile instead of adding a second account. `PayloadDisplayName` and
  `PayloadDescription` are localised. `PayloadRemovalDisallowed` is false. Built by a pure Dart function and
  tested as XML.
- **Opening it.** iOS installs a profile that Safari downloads (or one opened from Files). The app starts a
  one-shot HTTP server on `127.0.0.1`, port chosen by the OS, path a random 32-byte token, and opens
  `http://127.0.0.1:<port>/<token>.mobileconfig` in Safari with `url_launcher` (external application). The
  server answers the first matching GET with `application/x-apple-aspen-config`, then closes. It also closes
  after 2 minutes, on any other path, and when the sheet closes. Before opening Safari the app asks iOS for
  background time over `tix/dav` (`beginBackgroundTask`), ended once the profile is served or the server closes,
  so the request is answered while Safari is in front.
- **Fallback.** If Safari never fetched it (the server closed unserved), the sheet offers **Save the profile**:
  `share_plus` with the file, so the person picks Save to Files and opens it from Files. The temporary file is
  deleted when the sheet closes.
- **Steps shown before opening:** "Safari asks to download a configuration profile: Allow. Then open Settings,
  tap Profile Downloaded near the top, Install, enter your passcode, Install again. The profile is marked Not
  Verified because it is not signed; that is expected. Reminders shows the account under tix." Plus: removing
  it later is Settings, General, VPN & Device Management.
- **Limitations stated on screen:** unsigned, so Not Verified; a profile not installed within 8 minutes is
  dropped by iOS and has to be opened again; managed devices may block profiles (then use the details in
  Settings, Calendar, Accounts, Add Account, Other, Add CalDAV Account).

### macOS: configuration profile

- Same profile. The app writes it to `tix-dav/` in its temporary directory and opens it with the default handler
  (`url_launcher` on a file URL), which hands it to System Settings. The file is deleted when the sheet closes,
  and anything left in `tix-dav/` (the app ended with the sheet open) is deleted before the next profile is
  written. macOS also empties the sandbox's temporary directory on its own.
- Steps: "System Settings shows Profile Downloaded (or open Privacy & Security, Profiles). Double-click the tix
  profile, Install, confirm with your password. It is marked Unverified because it is not signed." Fallback:
  the details, for System Settings, Internet Accounts, Add Other Account, CalDAV account.

### Android: DAVx5

- **Detect.** `<queries><package android:name="at.bitfire.davdroid"/></queries>` in the manifest, and a
  `tix/dav` method `davx5Installed` that asks the package manager. The same package id covers the F-Droid and
  Google Play builds of DAVx5.
- **Open.** `tix/dav` `openDavx5` starts `ACTION_VIEW` with data `caldavs://<host>[:port]<path>` (`caldav://`
  for http), `setPackage("at.bitfire.davdroid")`, and the extras `username` and `password`. These are DAVx5's
  `LoginActivity.EXTRA_USERNAME` and `EXTRA_PASSWORD`, read from the intent whatever the URI carries
  (checked against `davx5-ose` `core/.../ui/setup/LoginActivity.kt`, `loginInfoFromIntent`). The password goes
  as an extra, never as URI user info, so it is not in the intent's data string. DAVx5 then discovers the
  collections and the person picks which task app gets them.
- **Without DAVx5** the sheet shows the details with copy buttons and links: DAVx5 (F-Droid in the `oss`
  flavour, Google Play in the `play` flavour), and a task app, tasks.org or jtx Board, from the same store. Text
  says DAVx5 does the syncing and the task app shows the tasks.
- A failed `startActivity` (DAVx5 removed in between, an old DAVx5 without the extras) falls back to the details.

### Linux and Windows

- The details with copy buttons and short steps for Thunderbird (New Calendar, On the Network, the address and
  user name, then the password when asked; tasks show in the Tasks tab) and Evolution (New Task List, CalDAV).
  Windows has no built-in CalDAV task app; the text says so and names Thunderbird.

## Several connections and instances

The screen follows the active context, like Calendar and Tokens. Each context's list is that account's
passwords on that server. Switching context rebuilds the providers, so a sheet is never left holding another
connection's value. The profile identifier includes the connection id, so two tix accounts on one iPhone are two
Reminders accounts.

## Phase 2: write-back

When `dav.info` says `write: true` for the caller:

- The lead text says changes made in the other app (complete, rename, due date, priority, new tasks) come back
  to tix, and that tix's workflow decides whether a completion is allowed.
- The sheet offers **Read only**, off by default; the app sends `read_only` only when it is on.
- Passwords from phase 1 need nothing: their authority is the owner's role at request time, so they write once
  the server does. Only a password created `read_only` cannot; while `write` is true such a row is marked
  "Read only" and offers **Replace**: the setup sheet opens with that password's collections and Read only off,
  and after the hand-off the app offers to revoke the old one by name.
- While `write` is false the `read_only` flag is not shown: every password reads only then.
- No app-side sync change: CalDAV writes arrive as ordinary events (contract above).

## Help

The screen links to tix's guide for each client (`caldav.md`, `#apple-reminders`, `#davx5-and-tasksorg`,
`#thunderbird`, `#evolution`, `#troubleshooting`) through the server's docs redirect, so the guide matches the
release the server runs. Only a server that answered `dav.info` shows them, and that server has the page. The
(?) entry in `screenDocs` waits for `tix.lock` to reach that release, because the anchors check reads the
vendored headings of the pinned commit, which has no `caldav.md`; until then the route's entry is null.

## Accessibility and localisation

- Every string in `lib/l10n/` in English, Bulgarian, German and French in the same change. Platform step names
  (Settings, Profile Downloaded, VPN & Device Management) follow Apple's wording in each language, checked on a
  device in that language where possible.
- Copy buttons are 48 dp with a semantics label naming the field ("Copy password"). The password is shown in a
  monospace field with a reveal toggle, hidden by default, its semantics value hidden until revealed.
- The hand-off announces its outcome ("Opened Safari", "Opened DAVx5") through a live region toast.
- Nothing clipped at 200% text; the steps are a numbered list, not a picture.

## Privacy

- The app password leaves the app only by the hand-off the person chose: into the iOS or macOS profile store,
  into DAVx5's account store, or onto the clipboard. Those apps keep it under their own policies; the app keeps
  no copy.
- The loopback profile server listens on `127.0.0.1` only, for one request at a random path, at most 2 minutes.
- The store listing's privacy paragraph (`fastlane/metadata/android/*/full_description.txt`) and the tix.red
  privacy policy (`messages/*/privacy.json`, part `app`) gain a line: "When you set up Tasks in other apps, the
  app asks your server for an app password and hands it to the app you choose (Reminders through a configuration
  profile, DAVx5, or the clipboard). The app does not keep it." The App Store privacy answers do not change: no
  data is collected.

## Trade-offs

- **Loopback server over a server-hosted profile URL.** A tix route serving the profile would need tix to hold
  the plaintext password until Safari fetches it. The loopback server keeps tix's contract smaller and the
  password on the device. The cost is iOS background time, tested on a device.
- **Password in the profile.** Leaving `CalDAVPassword` out makes iOS ask for it while installing, which is more
  taps and a paste across apps. The password is narrow and revocable, so it goes in.
- **No secure storage of the value.** Re-sending the same password to a second app on the same device is not
  supported; a second password per app is the intended pattern and costs nothing.

## Tests

- Unit: `DavRepository` against `FakeTix` (info, list, create with and without the optional fields, revoke,
  404, 405, 403, 409); the profile builder
  (valid plist, escaping, https and http, port, identifier per connection); the loopback server (serves once,
  wrong path is 404 and does not close it early, closes after the timeout, never logs); the DAVx5 URI builder
  (scheme, port, path, no user info).
- Application: `davStatusProvider` state mapping (local, old server, off, not allowed, ready, error); the
  notifier never holds the value; `secrets_test.dart` covers the create answer.
- Widget: every state at 400 and 1280 wide, light and dark; setup sheet per `DavHandoff` fake (iOS, macOS,
  Android with and without DAVx5, desktop); revoke confirms; a `401` on `dav.password.list` leads to reconnect as
  elsewhere, and a revoked row shows no `RefusedMark`; no request ever carries the app password; phase 2
  wording, the Read only choice, the read-only row and Replace.
- Guards watched failing, as `docs/testing.md` asks.
- Device tests (by hand, before ticking the phase): iPhone, Safari download, Settings install, Reminders shows
  the projects; iPad split view; macOS install through System Settings; Android with DAVx5 from F-Droid and
  Play, collections land in tasks.org and jtx Board; Android without DAVx5; Thunderbird on Linux with the
  copied details. Run against a throwaway tix (`tix demo seed`), never a server holding real work.
