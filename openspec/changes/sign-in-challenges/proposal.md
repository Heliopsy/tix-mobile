# Proposal

## Why

When tix answers a sign-in with a `password_change` or an `enrol` challenge, the app stops with "Sign in once in
the browser to do that". An administrator who creates an account with Require password change, or a tenant that
requires a second factor, sends every new app user to the browser first. tix's login API already carries both
steps: `new_password` on the password step, and on an enrol challenge the secret, a ticket and, once the code is
taken, `recovery_codes` on the result.

## What Changes

- A `password_change` challenge opens a Choose a new password step: new password and the same again. The app
  sends the email, the password already typed and `new_password` on `POST /api/v1/auth/login` (with `remember`
  as before). tix checks the length and that it differs; the app only checks that the two fields match, because
  tix never sees the second one. The answer may be a session or another challenge.
- An `enrol` challenge opens a Set up a second factor step: the key to add to an authenticator app, with Copy and
  Open in authenticator app, then the code. The code goes with the ticket as on the code step.
- When the result carries `recovery_codes`, they are shown once, with Copy, and the sign-in continues only after
  the person confirms they saved them.
- Each new field has an (i) like the other connect fields.
- The "Sign in once in the browser" message for a password change goes; the second factor one stays for a tenant
  switch, where tix still asks for a factor the account lacks.
