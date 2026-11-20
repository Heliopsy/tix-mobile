# Design

## The external user agent

The sign-in runs in the platform's own browser, never in a WebView inside the app, so the provider's page, its
cookies and any second factor stay out of the app's reach (RFC 8252).

| Platform | Opens with | Redirect arrives through |
| --- | --- | --- |
| iOS, macOS | `ASWebAuthenticationSession` (channel `tix/sso`) | the session's own callback |
| Android | Custom Tabs (`url_launcher`, `inAppBrowserView`) | `SsoCallbackActivity`, then `tix/links` |
| Linux | the default browser (`url_launcher`) | `x-scheme-handler/red.tix.mobile`, then `tix/links` |
| Windows | the default browser (`url_launcher`) | `HKCU\Software\Classes\red.tix.mobile`, then `tix/links` |

`flutter_web_auth_2` was considered and left out. Every release depends on `desktop_webview_window`, an embedded
WebView plugin that would be compiled into the Linux, macOS and Windows builds (on Linux it needs webkit2gtk-4.1,
which the CI image and the Flatpak do not carry). The app already receives `tix://` links on every platform it
ships, with one running instance on the desktop, so the redirect reuses that path and no dependency is added.

On Android, `SsoCallbackActivity` takes the redirect, brings `MainActivity` back with `CLEAR_TOP | SINGLE_TOP`,
which closes the Custom Tab above it, and finishes. `MainActivity` hands the link to Dart like a `tix://` link.
Coming back to the app without a redirect, by closing the tab, counts as a cancel after a short grace period. On
the desktop the browser is a separate window, so the waiting state has a cancel button instead.

Windows has no installer that registers schemes, so the app writes the per-user `HKCU` class for `red.tix.mobile`
each time a provider sign-in starts. It needs no elevation and points at the running executable.

## PKCE and state

`AuthRepository.startSso` makes a verifier from 32 random bytes (base64url, no padding), its S256 challenge, and a
16-byte random state, and builds the address. `finishSso` refuses a redirect whose `state` differs, turns
`error=` into `TixErrorKind.ssoFailed` and exchanges the code. A `401` from the exchange becomes
`TixErrorKind.ssoRejected`. The verifier only lives in memory for one attempt.

## Options

`signInOptions` answers `SignInOptions.none` for a server without the route: tix answers an unknown public route
without a credential with `401`, older ones with `404`. Buttons show only when `app_sign_in` is true and the
platform has a user agent. Password sign-in is hidden only when `password_login` is `disabled`.

The connect screen fetches options when the server is known: at once for a saved instance, otherwise after the
address field has been still for a moment.

## Saving

The exchange answers a `LoginResult`, which goes through the same `_signedIn` path as a password: tenant choice,
`whoami`, `saveSignIn`. The email comes from `whoami`, since the app never saw one. `saveSignIn` with `replacing`
keeps the connection and clears `refusedAt`, so reconnecting by SSO behaves like reconnecting with a password.

## Generated client

The vendored OpenAPI document (pinned by `tix.lock`) has neither `app_sign_in` nor the exchange route yet, so
`SsoOps` and the two models are written by hand in `data/`. Once the server change is released and `tix.lock` moves
past it, `just gen` produces them and the hand-written ones go.
