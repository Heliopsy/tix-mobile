# Tasks

- [x] Hold a sign-in redirect that arrives while nothing listens, with its arrival time
- [x] Keep the attempt in secure storage while the browser is open; clear it on finish, cancel and failure
- [x] Finish or report a kept attempt when the connect screen opens; route a held redirect there beside a session
- [x] Map `access_denied`, `not_linked`, `expired` and other reasons; strings in en, bg, de and fr
- [x] Check the Linux scheme handler before offering provider sign-in; 5 minute desktop limit
- [x] Ignore redirects for another state while waiting
- [x] Check the attempt is still live after the exchange
- [x] Fail on a `reg` exit code other than 0
- [x] Android resume grace of 5 seconds
- [x] Tests for each of the above
