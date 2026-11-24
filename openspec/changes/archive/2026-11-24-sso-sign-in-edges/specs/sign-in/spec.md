## MODIFIED Requirements

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

- **WHEN** the redirect carries an `error=` with no message of its own
- **THEN** nothing is stored and the screen says the provider sign-in did not complete

#### Scenario: Exchange refused

- **WHEN** the exchange answers `401`
- **THEN** nothing is stored and the screen says the sign-in failed, with a button to try again

## ADDED Requirements

### Requirement: Redirect reasons are explained

An `error=` redirect SHALL be read by its reason. `access_denied` SHALL say the sign-in was declined or refused and to ask the tenant's admin if the person did not cancel it, with no button to try again. `not_linked` SHALL say the provider account is not linked to anyone on the server, with no button to try again. `expired` SHALL say the sign-in took too long, with a button to try again. Any other reason SHALL say it did not finish, without the code, with a button to try again.

#### Scenario: Declined or refused

- **WHEN** the redirect carries `error=access_denied`, sent for a decline at the provider and for a disabled account, a disallowed domain or a refused role alike
- **THEN** the form stays, the screen says the sign-in was declined or refused, there is no retry and nothing is stored

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
