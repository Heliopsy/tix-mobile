# Proposal

## Why

Review of the parity and settings pull requests turned up gaps that can cost a person their token, their password
or a correct screen:

- Token rotation writes the new token after the server has rotated. A locked keyring or a killed app in between
  loses the new token, and the old one dies a minute later.
- The invite preview leads with the server-supplied tenant name and puts the real host in small print, so a
  phishing invite can look like a trusted tenant.
- The claim length on the task screen is read once and never again after the claim changes.

## What Changes

- Rotation checks that secure storage takes a write before asking the server. If the write still fails after the
  rotation, the new token is shown once with Copy and a warning instead of being dropped. It is never logged.
- The invite preview's headline names the host, emphasised: "Join Acme on tix.example.com".
- The claim length is read again when the task is claimed, released, reclaimed or its lease runs out.

## Impact

- `instances`, `invites` and `task-detail` specs.
- New strings in English, French, German and Bulgarian.
