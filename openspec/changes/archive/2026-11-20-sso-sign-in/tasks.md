# Tasks

## 1. Spec

- [x] 1.1 `sign-in` delta

## 2. Data

- [x] 2.1 `SignInOptions` and `SsoProviderOption`, tolerant of a missing `app_sign_in`
- [x] 2.2 Hand-written `SsoOps` (`options`, `exchange`) on `TixApi`
- [x] 2.3 `AuthRepository.signInOptions`, `startSso` (PKCE, state, address), `finishSso` (state, error, exchange)
- [x] 2.4 `ssoFailed`, `ssoStateMismatch`, `ssoRejected` error kinds and messages

## 3. Platform

- [x] 3.1 `SsoBrowser`: ASWebAuthenticationSession on iOS and macOS, Custom Tabs on Android, the browser on Linux
  and Windows
- [x] 3.2 Android `SsoCallbackActivity` and intent filter; `MainActivity` passes `red.tix.mobile` links on
- [x] 3.3 iOS and macOS `CFBundleURLTypes`, `tix/sso` channel
- [x] 3.4 Linux desktop entry and runner, Windows runner and per-user scheme registration

## 4. App

- [x] 4.1 `ConnectFlow.sso`, saving through the password path
- [x] 4.2 Provider buttons on the sign-in step and the reconnect screen, waiting and retry states
- [x] 4.3 Hide the password form when password sign-in is disabled
- [x] 4.4 Strings in en, bg, de, fr

## 5. Tests and docs

- [x] 5.1 Options parsing, PKCE test vector, repository redirect checks
- [x] 5.2 Widget tests: buttons, hidden form, success, mismatch, error, cancel, 401, reconnect clears `refusedAt`
- [x] 5.3 README and `docs/architecture.md`
