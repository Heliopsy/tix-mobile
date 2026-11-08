# Design

## Pinning the spec

`tix.lock` already pins the engine. `tool/openapi.dart sync` fetches `api/openapi.yaml` at that commit (from
GitHub, or `git show` in a checkout named by `TIX_SOURCE`) into `api/tix-openapi.yaml`, byte for byte. `check`
compares the two and fails, in CI's gate job. Upgrading is: bump `tix.lock`, `just openapi-sync gen`, fix what the
compiler and the parity guard name, commit.

## Generator choice

Evaluated against the real spec (OpenAPI 3.1, 178 operations, 187 schemas):

| | swagger_parser 1.46 | tonik 0.11 | openapi-generator dart-dio 7.27 |
| --- | --- | --- | --- |
| Builds unmodified | no: 33 errors (a field named `override`) | yes, 0 issues | no: 15 errors |
| Models | freezed | own classes | built_value |
| Listing | one class per operation | one class per operation | one class per operation |
| Errors | Dio interceptor | per-operation sealed result, every status "succeeds" | Dio interceptor |
| Other | multipart body dropped, image typed as String | 126k lines, `tonik_util` runtime | Java, multipart import broken |

None gives a generic `Page<T>`, all three need patching or wrapping, and two drag in a runtime or model style the
app does not use. tix writes its spec from one Go registry, so it uses a small, regular subset of OpenAPI: no
`required` lists, nullability as 3.1 type arrays, listings as `{items, next_cursor}`, one error envelope. A
generator of about 700 lines (`tool/openapi/generator.dart`) covers exactly that subset, fails loudly on anything
else, needs no Java or network, and emits what the app already writes by hand: freezed + json_serializable
models, and methods grouped by area (`api.task.list(...)`, from the operationId) over one transport.

- A schema reachable from a request body is an input: every field nullable, so a PATCH sends only what is set.
  Other schemas default strings, numbers and booleans to zero values and lists to empty, as the old models did.
- Enums carry their wire value and decode an unknown value to null, so a newer server cannot break decoding.
- Three schema names collide with app classes and are renamed: `Connection` to `LiveConnection`, `Membership` to
  `TenantMembership`, `Session` to `AuthSession`.
- Generated files are `*.gen.dart`, excluded from analysis, formatting checks and coverage like other generated
  code, and covered by `just gen-check`. `data/models/*.dart` re-export the generated classes the screens use.

## Transport and headers

`TixApi` extends the generated `TixClient` with the per-connection Dio: base URL, timeouts, `Accept`, the
credential (`Authorization: Bearer` for a token, `Cookie: tix_session=` for a sign-in), and `X-Tix-Tenant` only when
a sign-in names a tenant on a shared host. `X-Tix-Client` is not sent: tix defines only `cli` and `mcp`, it grants
nothing, and a session is recorded as `web` anyway. A `mobile` value would need tix to define it first.

## Live updates

`TixEventStream` (data/events) opens `/api/v1/events` with `dart:io`, subscribes, follows `seq`, de-duplicates,
and reconnects with doubling backoff and jitter, resuming with `since_seq`. A refused handshake (401, 403) or a
refused subscription makes it unavailable without retries; a cursor tix no longer keeps, or a reconnect with no
cursor, reports `EventsMissed`. The cursor lives as long as the stream: providers load current data when they
build, so persisting it across starts buys nothing. `tixEventStreamProvider` builds one per active context and
skips the backoff when the app resumes.

`refreshOn(ref, patterns, where:)` makes a provider invalidate itself on matching events (debounced, so a bulk
change refreshes once) and on a gap; `onEvents` hands the batch over for providers that patch state instead.
`EventTopics` is the table of which events touch which data.

## Cache

One JSON file per entry under the app support directory, `v1/<connection>/<tenant>/<key>.json`. Nothing is
queried, only read by key, so a database would add native code and codegen for nothing. Reads and writes are best
effort: any failure is a miss or a dropped write. A repository keeps first pages and single records with
`remember` and offers `cached…` twins; `cachedFirst` returns the cached value at once and sets the server's when it
arrives. Each key is served from the cache once per context, so a pull to refresh always asks the server. A
forgotten connection's files are deleted with it.

## Optimistic updates

The design system's `runOptimistic` owns the toast, haptics and undo flow but needs `apply` and `rollback`
callbacks over provider state, which a widget cannot touch. `OptimisticChange` is that half: a notifier builds it
from its state, the widget passes its members to `runOptimistic`.

## Parity

Modelled on tix's `internal/capability`. `registry.dart` maps operationId to feature, action and wave;
`exemptions.yaml` lists exempt operations with a reason (seeded from tix's own web exemptions: claims, SSH
sign-in, background loops, probes) and pending ones by wave. `test/core/capability/operations_test.dart` fails on
an operation classified nowhere, twice, or no longer in the spec.
