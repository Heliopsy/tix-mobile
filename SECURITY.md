# Security Policy

## Reporting a vulnerability

Report security issues privately through
[GitHub Security Advisories](https://github.com/heliopsy/tix-mobile/security/advisories/new).

Please do not open a public issue for a vulnerability.

Include what you can: the app version or commit, the platform and OS version, a description of the issue,
reproduction steps, and the impact you believe it has. You will get an acknowledgement within a few days and an
assessment once the report has been reviewed.

A vulnerability in the tix server, its API or its web UI belongs in
[heliopsy/tix](https://github.com/heliopsy/tix/security/advisories/new). If you are not sure which side it is on,
report it here and it will be moved.

## Supported versions

Until v1.0.0, only the latest release receives security fixes.

## Scope

tix-mobile holds API tokens for one or more tix servers and talks to them over HTTP. Findings of particular
interest:

- **Token disclosure.** Any path where an API token leaves platform secure storage other than in the
  `Authorization` header of a request to the server it belongs to: logs, crash reports, preferences, backups,
  screenshots, the clipboard, or a request to a different server.
- A token for one saved server sent to another, including through a redirect.
- Accepting an invalid TLS certificate, or downgrading from `https` to `http` without the user choosing it.
- Rendering server-supplied content (task titles, descriptions, comments) in a way that runs code, opens an
  unexpected URL, or spoofs the app's own interface.
- Deep links or intents that make the app act on a server or task the user did not choose.
- Release artifacts whose checksum or provenance does not match what the release workflow built.

## Notes for users

- Use `https` for any server that is not on the same machine. tix refuses a non-loopback bind without TLS for the
  same reason: a bearer token does not survive a plaintext hop.
- Give the app a token with only the scopes it needs. `task:read`, `task:write` and `project:read` cover the current
  features. tix tokens expire after 90 days by default.
- If a device is lost, revoke its token on the server with `tix token rm ID`. Removing the app is not enough if the
  device is in someone else's hands.
- On Linux, the token store is the Secret Service (GNOME Keyring, KWallet). It is only as safe as that keyring's
  lock.
- Check a download against `SHA256SUMS` and its provenance attestation before installing it; see
  [docs/releasing.md](docs/releasing.md#artifacts).
