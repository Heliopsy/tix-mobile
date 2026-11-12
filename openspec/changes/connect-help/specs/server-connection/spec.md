# server-connection

## ADDED Requirements

### Requirement: A server address is spelled one way

Wherever a server address enters the app, the connect form, a link to the connect screen, an invite link or a
saved instance, the app SHALL trim whitespace, drop trailing slashes and a trailing `/api/v1`, read an address
without a scheme as `https://`, and keep `http://` when it is typed. Paths SHALL be joined to it with one slash.

#### Scenario: A trailing slash is dropped

- **WHEN** a person enters ` https://tix.example.com/// ` and connects
- **THEN** the form shows `https://tix.example.com` and the instance is saved at that address

#### Scenario: http stays http

- **WHEN** a person enters `http://192.168.1.5:8080/`
- **THEN** the address used is `http://192.168.1.5:8080`

### Requirement: The connect screen explains each field

The server address, the server or this device choice, the way to connect, the API token, email, password, invite
link, name and tenant choice SHALL each have an (i) button. It SHALL be labelled for screen readers, reachable by
keyboard, at least 48 dp, and SHALL open a short plain explanation: a sheet on a phone, a dialog on a wider window.

#### Scenario: Where the address comes from

- **WHEN** a person taps the (i) beside Server address
- **THEN** a sheet says the address is the one they open tix with in a browser, such as `https://tix.example.com`, and to ask whoever runs tix for it

#### Scenario: Where a token comes from

- **WHEN** a person on a desktop window opens the (i) beside API token
- **THEN** a dialog says to create one on tix web's API tokens page or with `tix token create`
