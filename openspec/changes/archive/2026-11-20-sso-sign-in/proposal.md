# Proposal

## Why

tix can sign people in through a tenant's identity providers (OIDC, GitHub and SAML), and a tenant can turn
password sign-in off. The app only knew email and password, so on such a tenant the only way in was to mint an API
token on the web first. The server now lets a native app finish a provider sign-in in the system browser and hand
the session back with a one-time code bound to a PKCE verifier.

## What Changes

- The sign-in step reads `GET /api/v1/auth/sso/options` once the server address is known and shows one "Sign in
  with …" button per provider, but only when the server says `app_sign_in` is true. An older server, which lacks
  the field, shows no buttons.
- A provider sign-in opens `<server>/login/sso/<key>` in an external user agent with a PKCE S256 challenge and a
  random state, waits for the `red.tix.mobile:/sso` redirect, checks the state and exchanges the code with
  `POST /api/v1/auth/sso/exchange`. The answer is stored exactly like a password sign-in.
- When the tenant has password sign-in disabled, the email and password form is hidden. The API token option
  stays.
- The reconnect screen offers the same buttons for the same server, and signing in again this way clears the
  refused state.
- The `red.tix.mobile` scheme is registered on Android, iOS, macOS, Linux and Windows.
- New strings in English, Bulgarian, German and French.

## Impact

- `data/`: sign-in options model, an SSO operations group on the API client (hand-written until the vendored
  OpenAPI document has the routes), PKCE and the redirect check in `AuthRepository`.
- `core/platform/sso_browser.dart`: the external user agent, per platform.
- `features/connect`: the flow step and the buttons.
- Platform runners: the scheme, ASWebAuthenticationSession on iOS and macOS, a callback activity on Android.
- Depends on the tix server change that adds `app_sign_in`, the app redirect on `/login/sso/<key>` and the exchange
  route.
