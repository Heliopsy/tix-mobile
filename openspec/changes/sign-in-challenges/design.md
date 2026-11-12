# Design

## Where the secrets live

The password stays in the sign-in form's field, where it already was, and is passed to the flow again for the
password change. The new password and its confirmation live in their own fields and are cleared once the step
is passed. Nothing is written to the draft, preferences or secure storage.

The enrolment secret and the recovery codes are on the flow's step, the same place the session token of the
tenant step lives: the flow belongs to one connect screen and goes with it. The codes leave the step as soon as
the person continues.

## Matching passwords

tix receives only `new_password`, so the confirmation is checked in the connect flow before anything is sent.
The length and "differs from the current one" are tix's rules, and its `invalid` answer is shown as it comes.
An empty new password is refused before sending, because tix reads an absent `new_password` as "no change" and
would answer the same challenge again.

## A chain of challenges

tix keeps the new password as soon as it accepts it, even when a second factor still stands between the person
and a session. The password field is cleared after the change, so starting over cannot resend the old one by
mistake.

## No QR code

The app has no QR component and the key plus Open in authenticator app covers both a phone (the otpauth link
opens the app) and a desktop (the key is typed or pasted). A QR code would need a new dependency for little gain.

## Switching tenants

A tenant switch that needs a factor the account lacks still says to set it up in the browser: tix's switch
answers with a `second_factor_required` error, not an enrol challenge.
