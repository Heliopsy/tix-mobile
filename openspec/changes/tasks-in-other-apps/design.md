# Design

## Server contract

The tix side is being planned in heliopsy/tix at the same time. This is what the app is built against. Every
item marked **Assumption** has to be confirmed or changed by the tix plan before phase 1 code starts; a change
there changes this design first.

- **CalDAV endpoint.** RFC 4791 under `{server}/dav/`, with `/.well-known/caldav` redirecting there.
  `current-user-principal` and `calendar-home-set` are served, so iOS, macOS and DAVx5 find the collections from
  the base address alone. One collection per project the person can read, maybe one "Assigned to me". Each
  collection's `supported-calendar-component-set` names VTODO, which is what makes Reminders and tasks.org show
  it.
- **Assumption: `dav.info`.** `GET /api/v1/dav`, authenticated with the app's own credential (session cookie or
  bearer token), any scope. It answers:
  - `enabled` (bool): CalDAV is on for this tenant;
  - `url` (string): the absolute base address other apps should use, as the server sees itself behind its proxy
    (`https://tix.example.com/dav/`);
  - `username` (string): the exact user name to put in other apps for this caller and tenant. The app never
    derives it from `whoami`, because on a shared host the tix login alone may not name the tenant;
  - `write` (bool): whether the server accepts writes (false in phase 1);
  - `reason` (string, optional): why the caller cannot use it, such as an agent actor, in tix's words.

  A server without the route answers 404 or 405 and reads as "this server does not offer it yet". The proposal
  for tix is this operation rather than a flag on an unauthenticated endpoint, because the address and the user
  name are per caller.
- **Assumption: app passwords are their own operations,** `dav.password.list`, `dav.password.create` and
  `dav.password.revoke` (`GET`/`POST /api/v1/dav/passwords`, `DELETE /api/v1/dav/passwords/{id}`). Underneath
  each is an API token with only the `caldav` scope (phase 2: `caldav` plus `caldav:write`, or whatever tix
  names it), owned by the caller. They do not need `token:admin`, because a member who may read tasks may set up
  their own task app. They work with a session (SSO or password sign-in) and with a person's API token; tix
  refuses an agent actor with 403.
  - Create takes `name` (string) and answers `id`, `name`, `password` (shown once), `username`, `url`,
    `scopes`, `created_at`. The answer repeats `username` and `url` so the hand-off needs one call.
  - List answers metadata only: `id`, `name`, `scopes`, `created_at`, `last_used_at`, `revoked_at`.
  - A name already in use is a 409; the app shows tix's message.
  - **Fallback** if tix prefers `token.create` with `scopes: ["caldav"]`: `DavRepository` maps onto
    `token.create`, `token.list` filtered to tokens whose only scope is `caldav`, and `token.revoke`. Then tix has
    to let a caller without `token:admin` mint and list a token whose only scope is `caldav`, and the answer has no
    `username` or `url`, so they come from `dav.info`. Nothing above the repository changes.
- **Assumption: scope inheritance.** A caller can mint an app password only when it holds `task:read` (phase 2:
  writes need the scopes the change needs, such as `task:write` and `task:transition`). tix applies the caller's
  role at request time, so an app password never does more than its owner may today.
- **Assumption: app passwords authenticate CalDAV only.** The `caldav` scope is refused on `/api/v1/*`, and a
  normal API token or a session is refused on `/dav/`. So a leaked app password reads tasks over CalDAV and
  nothing else.
- **Assumption: Basic auth failures do not lock the person out.** A Reminders account with a revoked password
  retries for days. tix's refusal log and throttling for `/dav/` must not lock the person's sign-in, SSO or
  other tokens.
- **Assumption: revoking is immediate** and the next CalDAV request with that password is a 401. The list shows
  `revoked_at`.
- **Assumption: writes are ordinary task changes.** In phase 2 a change made over CalDAV goes through the same
  service as the API, bumps the task's version and emits the usual events, so the app's live updates, cache and
  outbox merge (`merge3`) handle it with no new code.
- **Assumption: the OpenAPI document carries the new operations** with operationIds as above, so `just gen`
  produces `api.dav.info()`, `api.dav.passwordList()`, `api.dav.passwordCreate(...)` and
  `api.dav.passwordRevoke(id)` once `tix.lock` moves to the release that has them. No request is hand-written,
  unlike `SsoOps`.
- **Assumption: docs.** tix's docs gain a CalDAV page (`caldav.md`) with a section per client, so the screen's
  (?) help has somewhere to land.

## Where it lives

- `data/repositories/dav_repository.dart`: `info()`, `passwords()`, `create(name)`, `revoke(id)`. No response
  cache for passwords, as `TokenRepository` does, so a field tix adds later cannot leak a value to disk. `info()`
  may be remembered like any read, since it carries no secret.
- `features/dav/application/`: `davInfoProvider` (per active context) and an `AppPasswords` notifier for the
  list. `create` returns the issued value straight to the widget, never into state, as the token screens do.
  `refreshOn` the token events tix emits for app passwords, if any; otherwise reload on return to the screen.
- `features/dav/presentation/`: `OtherAppsScreen` and the hand-off sheet.
- `core/platform/dav_handoff.dart`: the `DavHandoff` interface with one implementation per platform service,
  the profile builder and the loopback profile server. It never logs its arguments.
- `features/account` (the calendar feed) links to the route and does not import `features/dav`.

The screen is a `TixPage` titled "Tasks in other apps". Its primary action is **Set up on this device** (plus
icon), which opens the setup sheet with `showTixSheet`. Sections: what it does (visible text, not a tooltip),
the passwords list, and the details for other apps. Revoking is `TixButton.danger` then `confirmDestructive`.

## States the screen can be in

Decided once from the active context and `dav.info`, in this order:

1. **Local instance:** "Other apps cannot reach a database on this device. Use a tix server." No setup.
2. **Old server** (404/405 on `dav.info`): "This server does not offer CalDAV yet. It needs tix X or later." The
   version comes from the tix release that ships it.
3. **Turned off** (`enabled: false`): "CalDAV is turned off on this server," plus tix's `reason` when given.
4. **Not for this credential** (403, or `reason` set): tix's message, and for a token connection a hint that a
   sign-in works too.
5. **Ready:** setup, list and details.

A network failure is `ErrorState` with Retry. Loading is a skeleton.

## The app password

- **Name.** Default `tix app, <platform>, <yyyy-mm-dd>` (localised), editable in the sheet, so the list says
  which device it was. The server keeps names unique and the app shows its 409 message.
- **Lifetime of the value.** The create answer goes from the repository through the notifier method to the
  sheet. The sheet holds it in widget state until it closes, uses it for the hand-off and the copy buttons, and
  drops it. It is not written to secure storage: the app has no use for it after the hand-off, and keeping it
  would make the app a second place it can leak from. Lost means revoke and set up again.
- **Clipboard.** Copying the password marks the clip sensitive on Android 13+ (`ClipDescription.EXTRA_IS_SENSITIVE`,
  so it is hidden in the clipboard preview) and on iOS uses a local-only, 2-minute expiring pasteboard item.
  On iOS the copy toast says it clears in 2 minutes. Desktop clipboards have no such marker; the toast there
  says to clear it after pasting. Other values copy normally.
- **Logging.** Nothing in `dav_handoff`, the Android channel or the Swift code logs arguments, URLs with user
  info, or profile contents. `test/core/session/secrets_test.dart` gains the create answer: neither the cache, the
  log nor provider state may hold the value.
- **Refusals stay apart.** The app only calls `/api/v1/*` with its own credential. It never sends the app
  password to `/dav/` or anywhere, so `RefusalInterceptor` and `RefusedCredentials` cannot see a refused app
  password. A `401` on `dav.*` is the main credential and is handled like any other (reconnect, `RefusedMark`).
  A revoked or expired app password is a row state from `dav.password.list`, drawn with its own wording
  ("Revoked", "Not used since ..."), never with `RefusedMark`, so the two cannot be confused.
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

- Same profile. The app writes it to its temporary directory and opens it with the default handler
  (`url_launcher` on a file URL), which hands it to System Settings. The file is deleted when the sheet closes
  or on the next start.
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

When `dav.info` says `write: true`:

- The lead text says changes made in the other app (complete, rename, due date, priority, new tasks) come back
  to tix, and that tix's workflow decides whether a completion is allowed.
- New passwords are created with write access (the server chooses the scope from the caller; the app sends
  nothing extra unless tix asks for an explicit flag).
- A password whose `scopes` lack the write scope is marked "Read only" with **Replace**: create a new one,
  hand it off, then offer to revoke the old one.
- No app-side sync change: CalDAV writes arrive as ordinary events (contract above).

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

- Unit: `DavRepository` against `FakeTix` (info, list, create, revoke, 404, 403, 409); the profile builder
  (valid plist, escaping, https and http, port, identifier per connection); the loopback server (serves once,
  wrong path is 404 and does not close it early, closes after the timeout, never logs); the DAVx5 URI builder
  (scheme, port, path, no user info).
- Application: `davInfoProvider` state mapping (local, old server, off, refused, ready); the notifier never
  holds the value; `secrets_test.dart` covers the create answer.
- Widget: every state at 400 and 1280 wide, light and dark; setup sheet per `DavHandoff` fake (iOS, macOS,
  Android with and without DAVx5, desktop); revoke confirms; a `401` on `dav.password.list` leads to reconnect as
  elsewhere, and a revoked row shows no `RefusedMark`; phase 2 read-only row and Replace.
- Guards watched failing, as `docs/testing.md` asks.
- Device tests (by hand, before ticking the phase): iPhone, Safari download, Settings install, Reminders shows
  the projects; iPad split view; macOS install through System Settings; Android with DAVx5 from F-Droid and
  Play, collections land in tasks.org and jtx Board; Android without DAVx5; Thunderbird on Linux with the
  copied details. Run against a throwaway tix (`tix demo seed`), never a server holding real work.
