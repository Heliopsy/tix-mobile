# Proposal

## Why

Review of the parity and settings pull requests turned up gaps that can cost a person their token, their password
or a correct screen:

- Token rotation writes the new token after the server has rotated. A locked keyring or a killed app in between
  loses the new token, and the old one dies a minute later.
- The invite preview leads with the server-supplied tenant name and puts the real host in small print, so a
  phishing invite can look like a trusted tenant.
- The claim length on the task screen is read once and never again after the claim changes.
- Settings shows "unavailable" with Retry for every missing date answer, including a tix that will never have one.
- Resetting the arrangement in Settings leaves open board and My work views showing the old one.
- Date settings are read only when the session changes, so a change on the web shows up after a restart.

## What Changes

- Rotation checks that secure storage takes a write before asking the server. If the write still fails after the
  rotation, the new token is shown once with Copy and a warning instead of being dropped. It is never logged.
- The invite preview's headline names the host, emphasised: "Join Acme on tix.example.com".
- The claim length is read again when the task is claimed, released, reclaimed or its lease runs out.
- Date settings show a spinner while loading, explain an older tix without Retry, and offer Retry after a failure.
- A reset from Settings makes open views read their arrangement again, through a core signal so neither feature
  imports the other.
- Date settings are read again when the app resumes and when Settings opens. tix sends no event when a
  preference changes, so the live stream cannot trigger it.

## Impact

- `instances`, `invites`, `task-detail`, `app-settings` and `reader-time` specs.
- New strings in English, French, German and Bulgarian.
