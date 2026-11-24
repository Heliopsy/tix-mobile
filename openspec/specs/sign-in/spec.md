# sign-in Specification

## Purpose
Signing in to a server with an email and a password, the second factor, and how a session is sent.

## Requirements

### Requirement: Signing in with email and password

The app SHALL sign in to a remote instance with an email and a password through `POST /api/v1/auth/login`, after checking `GET /healthz`. It SHALL save nothing unless the sign-in yields a session and `whoami` accepts it. The password SHALL be sent once and never kept.

#### Scenario: A good password signs in

- **WHEN** a person signs in with an email and password the server accepts
- **THEN** a sign-in connection is saved, its session is in secure storage, and the projects are listed

#### Scenario: A wrong password saves nothing

- **WHEN** the server answers the login with `401`
- **THEN** the sign-in screen says the credentials were not accepted and nothing is stored

### Requirement: The second factor is asked for when required

When the login answers a challenge of kind `code`, the app SHALL ask for a code and send it with the challenge's ticket and no password. A refused code SHALL let the person try again. A challenge of kind `enrol` or `password_change` SHALL be explained as something to finish in the browser.

#### Scenario: A code completes the sign-in

- **WHEN** the login answers a code challenge and the person enters a code the server accepts
- **THEN** the sign-in completes as it would without a challenge

#### Scenario: Enrolment is needed

- **WHEN** the login answers a challenge of kind `enrol`
- **THEN** the screen says to set up the second factor in the browser first and nothing is stored

### Requirement: A session is presented as tix's session cookie

The app SHALL present a sign-in session as the `tix_session` cookie and SHALL NOT send an `Authorization` header with it, because tix accepts session tokens only as that cookie. An API token SHALL be sent as `Authorization: Bearer`.

#### Scenario: Session requests carry the cookie

- **WHEN** a sign-in connection is active and the projects load
- **THEN** the request carries `Cookie: tix_session=…` and no `Authorization` header

### Requirement: An expired session asks to sign in again

When the server refuses the active sign-in's session, the app SHALL open Sign in again for that connection, with its server and email filled in and a line saying the session ended, and a successful sign-in SHALL keep the same connection.

#### Scenario: Sign in again

- **WHEN** a session has expired and the person signs in again
- **THEN** the same connection holds the new session and the lists load

#### Scenario: Refused while in use

- **WHEN** a screen's request is answered `401` and `GET /whoami` with the same session is answered `401` too
- **THEN** the app shows Sign in again for that connection with the server address kept

#### Scenario: Started after the session ended

- **WHEN** the app starts with an active sign-in that holds no session
- **THEN** it opens Sign in again for that connection

### Requirement: A refused session is checked once before signing out

On a `401` answered to the active remote connection's session or API token, from any request, the app SHALL check the credential once with `GET /whoami`. Only a `401` there SHALL count as a refusal. One check SHALL run at a time. A refused API token SHALL NOT be deleted.

#### Scenario: Wrong code

- **WHEN** a request with a live session is answered `401` for another reason, such as a wrong code
- **THEN** `whoami` succeeds and the person stays signed in

#### Scenario: Several refusals at once

- **WHEN** a sync gets several `401`s for an expired session
- **THEN** the app sends one `whoami` and signs out once

#### Scenario: A token the server still accepts

- **WHEN** a request with an API token is answered `401` and `whoami` with that token succeeds
- **THEN** the token stays, the connection is not marked refused and sync goes on

### Requirement: A refused session stops background work

Signing out a refused session SHALL cancel the connection's running jobs and delete its stored session, keeping the connection, its instance, its cache and its outbox. No periodic sync, replay retry or live update SHALL send that session again.

#### Scenario: Periodic sync

- **WHEN** the 30-minute sync is answered `401` for an expired session
- **THEN** the session is deleted, the sync timer is cancelled and later ticks send nothing

### Requirement: Being signed out by the server notifies

When a refused session is signed out and notifications are allowed, the app SHALL show one notification on the Account channel saying it was signed out of the instance. Signing in again to that connection SHALL remove it.

#### Scenario: Signed out in the background

- **WHEN** the periodic sync signs out an expired session
- **THEN** a notification names the instance and asks to sign in again

### Requirement: A refused token stops background work

When an API token is confirmed refused, the app SHALL cancel the connection's running jobs, keep the token in secure storage and record the connection as refused with it. No periodic sync, replay retry or live update SHALL send that token again.

#### Scenario: Periodic sync

- **WHEN** the 30-minute sync is answered `401` for a revoked token and `whoami` is refused too
- **THEN** the connection is marked refused, the token is kept, the sync timer is cancelled and later ticks send nothing

### Requirement: A refusal survives a restart

The refused state SHALL be stored with the connection. Starting the app with an active refused connection, or a sign-in with no session, SHALL open the reconnect screen for it without sending its credential.

#### Scenario: Cold start after a refusal

- **WHEN** the app starts after a token or session was recorded refused, in the app or in the widgets' background run
- **THEN** it opens the reconnect screen for that connection and sends no request with the refused credential

### Requirement: A refused token asks for a new credential

The reconnect screen for a refused token SHALL say the token was refused and offer to paste a new token or sign in, with the server address kept. Saving a credential the server accepts SHALL keep the connection's id and cached data, clear the refused state and start syncing again.

#### Scenario: New token

- **WHEN** the person pastes a new token for a refused connection
- **THEN** the same connection holds the new token, it is no longer refused and the periodic sync runs again

### Requirement: A refused token notifies

When a token is confirmed refused and notifications are allowed, the app SHALL show one notification on the Account channel saying the token for the instance was refused. Saving a new credential for that connection SHALL remove it.

#### Scenario: Refused in the background

- **WHEN** the periodic sync records a refused token
- **THEN** a notification names the instance and says its token was refused

### Requirement: Single sign-on is offered when the server allows it

Once the server address is known, the sign-in step SHALL read `GET /api/v1/auth/sso/options` and show one "Sign in with" button per provider, named by its `display_name`, only when the answer has `app_sign_in` true and the platform has an external user agent that hands the redirect back. A missing `app_sign_in`, or a server without the route, SHALL show no buttons.

#### Scenario: A server that allows app sign-in

- **WHEN** the options answer `app_sign_in: true` with providers `Acme` and `GitHub`
- **THEN** the sign-in step shows "Sign in with Acme" and "Sign in with GitHub"

#### Scenario: An older server

- **WHEN** the options answer has no `app_sign_in` field, or the route is missing
- **THEN** no provider button is shown and the password form works as before

#### Scenario: Linux without a scheme handler

- **WHEN** the app runs on Linux outside a Flatpak and `xdg-mime query default x-scheme-handler/red.tix.mobile` names no application
- **THEN** no provider button is shown

### Requirement: Password sign-in follows the tenant

When the options say `password_login` is `disabled`, the sign-in step SHALL hide the email and password form and its button. The API token option SHALL stay.

#### Scenario: Passwords disabled

- **WHEN** the options answer `password_login: disabled`
- **THEN** there is no email or password field, the provider buttons and the token option remain

### Requirement: A provider sign-in runs in the system browser

The app SHALL open `<server>/login/sso/<key>` with `app_redirect=red.tix.mobile:/sso`, an S256 PKCE challenge of a 32-byte verifier and a random `app_state`, in an external user agent and never an embedded WebView. While it is open the step SHALL show that it is waiting, and SHALL ignore a redirect whose `state` is not this attempt's. A cancel SHALL return to the form quietly.

#### Scenario: Waiting

- **WHEN** the person taps a provider button
- **THEN** the browser opens and the screen shows a waiting state with a way to cancel

#### Scenario: Cancelled

- **WHEN** the person closes the browser without finishing
- **THEN** the form is shown again with no error

#### Scenario: A redirect from an older tab

- **WHEN** a redirect carrying the state of an earlier attempt arrives while a newer one waits
- **THEN** it is ignored and the newer attempt keeps waiting

#### Scenario: Cancelled during the exchange

- **WHEN** the person cancels after the redirect arrived and before the exchange answered
- **THEN** nothing is stored

### Requirement: The redirect is checked and exchanged

The app SHALL accept only a `red.tix.mobile:/sso` redirect whose `state` equals the one it sent. It SHALL send its `code` with the verifier to `POST /api/v1/auth/sso/exchange` and store the answer exactly as a password sign-in. A mismatch, an `error=` redirect or a `401` SHALL store nothing.

#### Scenario: Success

- **WHEN** the redirect carries a code and the matching state, and the exchange answers a session
- **THEN** a sign-in connection is saved with the session in secure storage and the home screen opens

#### Scenario: State mismatch

- **WHEN** the redirect handed to the exchange has a `state` other than the one sent
- **THEN** nothing is exchanged or stored and the screen says the sign-in could not be verified

#### Scenario: Provider error

- **WHEN** the redirect carries an `error=` other than `access_denied`
- **THEN** nothing is stored and the screen says the provider sign-in did not complete

#### Scenario: Exchange refused

- **WHEN** the exchange answers `401`
- **THEN** nothing is stored and the screen says the sign-in failed, with a button to try again

### Requirement: Reconnecting by single sign-on

The reconnect screen SHALL offer the same provider buttons for the connection's server. A provider sign-in there SHALL keep the connection's id and cached data and clear its refused state, as a saved password or token does.

#### Scenario: Refused session, signed in again by a provider

- **WHEN** a refused connection signs in again with a provider
- **THEN** the same connection holds the new session and `refusedAt` is cleared

### Requirement: Redirect reasons are explained

An `error=` redirect SHALL be read by its reason. `access_denied` SHALL return to the form quietly. `not_linked` SHALL say the provider account is not linked to anyone on the server, with no button to try again. `expired` SHALL say the sign-in took too long, with a button to try again. Any other reason SHALL say the sign-in did not finish, without the reason code, with a button to try again.

#### Scenario: Turned down at the provider

- **WHEN** the redirect carries `error=access_denied`
- **THEN** the form is shown again with no error and nothing is stored

#### Scenario: Not linked

- **WHEN** the redirect carries `error=not_linked`
- **THEN** the screen explains it and offers no retry

#### Scenario: Server reason without a message of its own

- **WHEN** the redirect carries `error=provider_error`
- **THEN** the screen says the sign-in did not finish, without `provider_error`, and offers to try again

### Requirement: A desktop sign-in gives up

On Linux and Windows, where the browser is not tied to the app, the wait for the redirect SHALL end after 5 minutes with the message that the sign-in took too long. On Windows, a `reg` write of the scheme handler that fails SHALL fail the sign-in before the browser opens.

#### Scenario: No redirect

- **WHEN** 5 minutes pass on the desktop with no redirect for the attempt
- **THEN** the waiting state ends and the screen says the sign-in took too long

### Requirement: A provider sign-in survives a restart

While the browser is open the app SHALL keep the attempt, verifier included, in secure storage, and SHALL clear it when the attempt ends. A redirect that arrives while nothing waits SHALL be held. When the connect screen opens it SHALL finish a kept attempt whose held redirect carries its state and is under 2 minutes old, and otherwise SHALL say the sign-in was interrupted.

#### Scenario: Ended while the Custom Tab was open

- **WHEN** Android ends the app during a provider sign-in and the redirect restarts it
- **THEN** the connect screen exchanges the code with the kept verifier and the sign-in is saved

#### Scenario: Nothing to finish it with

- **WHEN** the connect screen opens to a kept attempt and no redirect, or a held redirect with no matching attempt
- **THEN** the screen says the sign-in was interrupted, and the kept attempt is cleared

#### Scenario: Restarted beside a session

- **WHEN** the redirect restarts the app while another connection's session is open
- **THEN** the connect screen the attempt started from opens and finishes it
