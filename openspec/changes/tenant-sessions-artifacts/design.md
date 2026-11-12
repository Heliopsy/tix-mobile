# Design

## The server's limits as hints

`session.policy` and `artifact.limits` report the server's own settings (`server_ttl`, `server_idle_timeout`,
`server_remember_ttl`, `server_max_bytes`, `server_allowed_types`) beside the effective ones. Those server figures
do not depend on the tenant, so the screen reads them once and shows them as each field's hint, the way the web
greys them in its placeholders. Both reads are optional: while they load or if they fail, the fields simply have
no hint and the settings still load and save.

## Durations and sizes as people write them

tix returns a duration as Go writes it (`8h0m0s`). The field shows it the way tix's `Human` does (`8h`, `7d`,
`1h30m`), which tix reads back. Sizes are typed as tix's `ParseByteSize` reads them (`512KiB`, `5 MiB`, `2M`, a
bare count) and shown in whole binary units. Parsing the size is input handling on the screen, not a rule: a
size the app cannot read is flagged under the field and not sent; the server still decides what is allowed.

## Clearing

As for leases, an emptied duration is sent as `0`, an emptied size as `0` and emptied types as `[]`, each of which
tix reads as "inherit". Keep me signed in is sent as typed: empty inherits, `off` stops offering it.
