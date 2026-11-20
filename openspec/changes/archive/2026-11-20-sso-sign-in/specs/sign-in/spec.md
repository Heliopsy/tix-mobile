## ADDED Requirements

### Requirement: Single sign-on is offered when the server allows it

Once the server address is known, the sign-in step SHALL read `GET /api/v1/auth/sso/options` and show one "Sign in with" button per provider, named by its `display_name`, only when the answer has `app_sign_in` true and the platform has an external user agent. A missing `app_sign_in`, or a server without the route, SHALL show no buttons.

#### Scenario: A server that allows app sign-in

- **WHEN** the options answer `app_sign_in: true` with providers `Acme` and `GitHub`
- **THEN** the sign-in step shows "Sign in with Acme" and "Sign in with GitHub"

#### Scenario: An older server

- **WHEN** the options answer has no `app_sign_in` field, or the route is missing
- **THEN** no provider button is shown and the password form works as before

### Requirement: Password sign-in follows the tenant

When the options say `password_login` is `disabled`, the sign-in step SHALL hide the email and password form and its button. The API token option SHALL stay.

#### Scenario: Passwords disabled

- **WHEN** the options answer `password_login: disabled`
- **THEN** there is no email or password field, the provider buttons and the token option remain

### Requirement: A provider sign-in runs in the system browser

The app SHALL open `<server>/login/sso/<key>` with `app_redirect=red.tix.mobile:/sso`, an S256 PKCE challenge of a 32-byte verifier and a random `app_state`, in an external user agent and never an embedded WebView. While it is open the step SHALL show that it is waiting. A cancel SHALL return to the form quietly.

#### Scenario: Waiting

- **WHEN** the person taps a provider button
- **THEN** the browser opens and the screen shows a waiting state with a way to cancel

#### Scenario: Cancelled

- **WHEN** the person closes the browser without finishing
- **THEN** the form is shown again with no error

### Requirement: The redirect is checked and exchanged

The app SHALL accept only a `red.tix.mobile:/sso` redirect whose `state` equals the one it sent. It SHALL send its `code` with the verifier to `POST /api/v1/auth/sso/exchange` and store the answer exactly as a password sign-in. A mismatch, an `error=` redirect or a `401` SHALL store nothing and offer to try again.

#### Scenario: Success

- **WHEN** the redirect carries a code and the matching state, and the exchange answers a session
- **THEN** a sign-in connection is saved with the session in secure storage and the home screen opens

#### Scenario: State mismatch

- **WHEN** the redirect's `state` differs from the one sent
- **THEN** nothing is exchanged or stored and the screen says the sign-in could not be verified

#### Scenario: Provider error

- **WHEN** the redirect carries `error=access_denied`
- **THEN** nothing is stored and the screen says the provider sign-in did not complete

#### Scenario: Exchange refused

- **WHEN** the exchange answers `401`
- **THEN** nothing is stored and the screen says the sign-in failed, with a button to try again

### Requirement: Reconnecting by single sign-on

The reconnect screen SHALL offer the same provider buttons for the connection's server. A provider sign-in there SHALL keep the connection's id and cached data and clear its refused state, as a saved password or token does.

#### Scenario: Refused session, signed in again by a provider

- **WHEN** a refused connection signs in again with a provider
- **THEN** the same connection holds the new session and `refusedAt` is cleared
