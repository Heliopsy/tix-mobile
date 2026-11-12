# Proposal

## Why

tix's web lets a person rotate any token they can see on the tokens screen, choosing how long the old value keeps
working, and marks a rotated token that still works as "retiring". The app could only rotate the token its own
connection signs in with, always with a one-minute grace, and drew a token inside its grace window as revoked.

## What Changes

- Each active row on the tokens screen gets Rotate, as the web draws it. The sheet names the token and, when it is
  somebody else's, says so; it asks how long the old token keeps working: now, 10 minutes, 1 hour or 24 hours,
  now proposed (`POST /tokens/{id}/rotate` with `{grace}`, at most tix's 24h).
- The new value is shown once in the same sheet an issued token uses.
- Rotating the token this app connects with goes through the connection's own rotation, so the stored credential
  is swapped for the new one; nothing changes on the connections screen, which keeps its one-minute grace.
- A token whose `revoked_at` is still to come reads "retiring" with when it stops, beside active, expired and
  revoked, and keeps Revoke so its window can be ended early.
- Who may rotate somebody else's token is the server's call; a refusal is shown in the sheet.
- No server change is needed: `token.rotate` with a grace has been in tix since the pinned engine.

## Impact

- Capabilities: `api-tokens`.
- Code: `data/models/people.dart` (token state), `data/models/scopes.dart` (graces), `TokenRepository.rotate`,
  `SessionController.rotateToken` (a grace argument, default unchanged), `features/tokens`, l10n.
