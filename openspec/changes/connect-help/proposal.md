# Proposal

## Why

People who have never run a server open the app and meet "Server address", "API token" and "This device" with
nothing to say what goes where. And an address typed or pasted with a trailing slash, such as
`https://tix.example.com/`, was kept as typed when it reached the app another way than the connect form, so the same
server could be saved twice.

## What Changes

- An (i) button beside the server address, the server or this device choice, the way to connect, the token, email,
  password, invite link, name and tenant choice opens a short plain explanation: a sheet on a phone, a dialog wider.
  It is a labelled 48 dp button the keyboard reaches. The texts follow tix web's sign-in wording.
- A new design component, `HelpButton`, with a gallery entry.
- Server addresses are spelled one way everywhere: whitespace trimmed, trailing slashes dropped, `https://` assumed
  when no scheme is given, `http://` kept when typed. The connect form shows the address as it will be used. The
  add-instance link and the connect screen's `url` parameter are normalised too.
- Saved remote instances are tidied on start: an address saved with a trailing slash is rewritten, and two
  instances that then share an address become one, keeping every connection.
- Paths are joined to a server address without doubling the slash.

## Impact

- Capabilities: `server-connection`, `instances`.
- Code: `core/config/server_url.dart`, `core/design` (`HelpButton`), `core/router/routes.dart`,
  `data/repositories/instances_repository.dart`, `data/api/tix_api.dart`, `data/events/event_stream.dart`,
  `features/connect`, two link helpers in `features/account` and `features/people`, l10n (16 strings).
