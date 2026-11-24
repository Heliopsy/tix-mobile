# Design

## Reloading

`SharedPreferencesWithCache.reloadCache` empties the cache before it waits for the platform, so a read in that
gap finds nothing saved. `PrefsKeyValueStore.reload` builds a new `SharedPreferencesWithCache` and swaps it in
once it is loaded instead.

`InstancesRepository` reloads in `activate`, `removeConnection`, `update` and its connection upsert, the paths
that read the list and write it back. `RefusedCredentials.record` reloads before it reads the connection.
`appResumedProvider` reloads before it fires, so every resume listener, the widget sync among them, reads fresh
settings.

## What `record` returns

`record` now answers whether the connection stands refused, not whether this call wrote the mark. A connection
already refused, or a sign-in whose session another writer deleted, counts, and the caller drops its session.
Only a fresh mark notifies, so the person sees one notification whichever isolate got there first. A token whose
stored secret differs from the refused one was replaced meanwhile and still answers false.

## Keeping the mark

A connection object read before the refusal, such as the one the session holds, can still be passed to
`update`. `update` keeps the stored `refusedAt` when the object carries none. `save` is the one path that clears
a refusal, since it stores a new secret.
