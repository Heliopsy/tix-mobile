# Changelog

## [0.8.0](https://github.com/Heliopsy/tix-mobile/compare/v0.7.0...v0.8.0) (2026-11-09)


### Features

* show why live updates are offline, with connection details you can copy ([3186546](https://github.com/Heliopsy/tix-mobile/commit/3186546c11d254f66d89a8f33ca7e96f1c1a0d8b))

## [0.7.0](https://github.com/Heliopsy/tix-mobile/compare/v0.6.0...v0.7.0) (2026-11-09)


### Features

* purge trashed tasks, manage active sessions, and test webhooks ([1977009](https://github.com/Heliopsy/tix-mobile/commit/19770093025e1d1bf9a31c2ae92ffabb1dbae019))


### Bug Fixes

* **inbox:** keep summary tiles the same size whatever the count ([9527b9e](https://github.com/Heliopsy/tix-mobile/commit/9527b9ec707f65a145a7d9ea0efdf18e9d9e0991))
* **local:** let the engine sleep while live updates poll ([37951a6](https://github.com/Heliopsy/tix-mobile/commit/37951a6bad807f44117ed9fd18e477f9fb4dcc50))
* **maintenance:** read the kept trash page with stored, not peek ([fdd1fca](https://github.com/Heliopsy/tix-mobile/commit/fdd1fca6afe6e4fc4f08abab0495a7a198644e93))
* **shell:** list About under More, and at the foot of the rail ([53d5b0b](https://github.com/Heliopsy/tix-mobile/commit/53d5b0b81d3d92a57faa4da57ad39e10325f2659))
* **shell:** start the live status where the context name ends ([ec3a930](https://github.com/Heliopsy/tix-mobile/commit/ec3a930670e4eea80a9ac11eb353fea3e0a1bb3f))
* show project icons and colours in the project switcher ([a722e24](https://github.com/Heliopsy/tix-mobile/commit/a722e246b1236759c5a537d8ab17bee0c3541e75))

## [0.6.0](https://github.com/Heliopsy/tix-mobile/compare/v0.5.0...v0.6.0) (2026-11-09)


### Features

* accept invites, show leases, date settings, status, bundles and private notifications ([2fc9c94](https://github.com/Heliopsy/tix-mobile/commit/2fc9c948386ae4508f617c133f79676c076ffd86))
* archived projects, manage entries for status and bundles, readable lease lengths ([90f419a](https://github.com/Heliopsy/tix-mobile/commit/90f419a5e8ec0d54fc6096771213ef7c6f80f0eb))
* keep chosen projects available offline ([eeeaad5](https://github.com/Heliopsy/tix-mobile/commit/eeeaad55bc4582e76fa2f71d8352e7d606edccd1))
* link account, security, tokens, calendar and tenant settings from their Settings groups ([2342fe0](https://github.com/Heliopsy/tix-mobile/commit/2342fe0892b988ebee261f8f9c31f963e700dec0))
* queue changes made offline and sync them, asking about conflicts ([23ce41f](https://github.com/Heliopsy/tix-mobile/commit/23ce41f3a588e2feb23678de332974c641f8792e))
* rotate a token connection's API token from the instances screen ([bed725d](https://github.com/Heliopsy/tix-mobile/commit/bed725dea6ee6eb387a12a21d3640a0632e15e55))
* settings grouped by device, account and tenant, with dates that follow your tix preference ([1bcb192](https://github.com/Heliopsy/tix-mobile/commit/1bcb19213ba83c9c6390c42b9e41db9f03cc7d42))


### Bug Fixes

* date settings say why they're missing, and resets reach open views ([70c7f83](https://github.com/Heliopsy/tix-mobile/commit/70c7f83720fd61602c799d9131d06fd3f2867f74))
* keep rotated tokens, name the invite host, and reread the lease ([9390ef9](https://github.com/Heliopsy/tix-mobile/commit/9390ef98b5dd15d78343d5c295c958b8c6e475b6))
* **offline:** stop the prefetch before forgetting a connection ([f15190c](https://github.com/Heliopsy/tix-mobile/commit/f15190c21341527bf911d027e6dee3219309b87e))
* read bundles as bytes so an NDJSON bundle survives its +json type ([df488cc](https://github.com/Heliopsy/tix-mobile/commit/df488cc4331578c0e69a2fb80fe70c69ccf21492))
* **sync:** give the offline sync strings their own keys ([4d40519](https://github.com/Heliopsy/tix-mobile/commit/4d40519fe29f7891ad6ea0a6aa50d227d69d174c))
* **sync:** one outbox per context, and stricter lookups before a resend ([9d36d39](https://github.com/Heliopsy/tix-mobile/commit/9d36d39299af61be670d64615bd1f950145ce3af))
* **sync:** one replay per context, day-old keys, kept outbox, and a warning on sign-out ([0a0958c](https://github.com/Heliopsy/tix-mobile/commit/0a0958c5b424bba88bd44f32b9b9e9b92931d2c6))
* **webhooks:** read the endpoint from the new webhook.put answer ([8cee23b](https://github.com/Heliopsy/tix-mobile/commit/8cee23b806293d6bc1bcc9096c24239c22d5ee28))


### Dependencies

* pin tix with Idempotency-Key and generate header parameters ([80bfd21](https://github.com/Heliopsy/tix-mobile/commit/80bfd21d264cacd798b5cdfae20c56997db07b67))

## [0.5.0](https://github.com/Heliopsy/tix-mobile/compare/v0.4.0...v0.5.0) (2026-11-09)


### Features

* **api:** a bytes twin for operations that answer in a format the request picks ([2682418](https://github.com/Heliopsy/tix-mobile/commit/268241876526802b0919bb17ca5c17849261ecdb))
* **design:** a panel for values tix shows only once ([a1ac52e](https://github.com/Heliopsy/tix-mobile/commit/a1ac52ecab3ef9a6c074f77d227ac9cad9d76cf9))
* fall back to HTTP polling when the event WebSocket keeps failing ([e26f35c](https://github.com/Heliopsy/tix-mobile/commit/e26f35c005c37cdef4ba42ebde0712d03fc9db36))
* Glance home screen widgets on Android ([fb7ff58](https://github.com/Heliopsy/tix-mobile/commit/fb7ff58bdc4f744355770f1fae12d65b49ba517d))
* home screen widgets on iOS and macOS ([db5787f](https://github.com/Heliopsy/tix-mobile/commit/db5787f5216a6a80ab701ecf922fb27274143662))
* home widget snapshots, sync, queue and taps on the Dart side ([c63adfd](https://github.com/Heliopsy/tix-mobile/commit/c63adfd138e2f1530b1d8ba5698d58004c762526))
* keep Inbox's unread badge in sight with six destinations ([e90247d](https://github.com/Heliopsy/tix-mobile/commit/e90247d6adf1112414da077e16d9432282f08fea))
* list the tenant and server screens under Manage ([931aa3f](https://github.com/Heliopsy/tix-mobile/commit/931aa3f6fe478bd3594fa18a1de963f099e75881))
* list users, tokens and transfer in the Manage hub ([4c2c162](https://github.com/Heliopsy/tix-mobile/commit/4c2c1626994a1a4108366fb2f4c3e5d7b001cf1e))
* manage projects, workflows and custom fields from a Manage hub ([7d0e441](https://github.com/Heliopsy/tix-mobile/commit/7d0e441ab3e3ff60911053a356f1855cda73389c))
* poll events through the generated event.poll ([8e43223](https://github.com/Heliopsy/tix-mobile/commit/8e43223b73d5a49edcf8178250a2a0a6648fa19f))
* rest idle local engines and open databases in place ([107b1a6](https://github.com/Heliopsy/tix-mobile/commit/107b1a6c0b826a6d95cb6c56a2dfb02b0392ae64))
* show whether live updates are live, polling or refreshing ([54126f0](https://github.com/Heliopsy/tix-mobile/commit/54126f024f07227e6f3660897bf309fd945c5250))
* tenant and server administration, and your own second factor and SSH keys ([bcb2656](https://github.com/Heliopsy/tix-mobile/commit/bcb265670958ec8c629dd4c78392e8b88c4b75b8))
* users, invites, API tokens, account, calendar feed and export in the app ([c170cf9](https://github.com/Heliopsy/tix-mobile/commit/c170cf94e9ec3535940d3992e0755c4334bfcaa1))
* webhooks, external sync, retention, housekeeping, trash and the audit log ([2875a6d](https://github.com/Heliopsy/tix-mobile/commit/2875a6d085557a7d91995983dfd8a8de7246cd1b))


### Bug Fixes

* **api:** send an explicit null to clear a due date through the generated client ([5610371](https://github.com/Heliopsy/tix-mobile/commit/5610371d12eadda4e520b5caa15444c73e74a09b))
* hold a local engine awake while a request is in flight ([b8dd671](https://github.com/Heliopsy/tix-mobile/commit/b8dd67160171eed18779ad07c28cf65353f02b26))
* read the keyguard host category from AppWidgetProviderInfo ([690c7c9](https://github.com/Heliopsy/tix-mobile/commit/690c7c93be5b27fd6e8f549ddfe6c43df2f49da6))


### Dependencies

* leave All files access out of the Play bundle ([d0cbd14](https://github.com/Heliopsy/tix-mobile/commit/d0cbd14e5e44d534d6479090f343af36366c506b))
* pin tix with the event poll endpoint ([a37441a](https://github.com/Heliopsy/tix-mobile/commit/a37441ae696d43e93d80a14b8481bd08eb743f6b))
* regenerate the session provider hash ([024658d](https://github.com/Heliopsy/tix-mobile/commit/024658d67ee270c939560285ecac5a5de1776ecd))

## [0.4.0](https://github.com/Heliopsy/tix-mobile/compare/v0.3.0...v0.4.0) (2026-11-08)


### Features

* an About screen with versions, project links and a bug report ([1704a24](https://github.com/Heliopsy/tix-mobile/commit/1704a244f74d08df42aa915509e6c54ea0eac1b7))
* an OLED black theme, and the system theme can go black too ([a7692c8](https://github.com/Heliopsy/tix-mobile/commit/a7692c8a1af0e5339bb73daa43e8b0a700d706b6))
* board, lanes, filters, saved filters, My work and bulk actions ([b158bc6](https://github.com/Heliopsy/tix-mobile/commit/b158bc65fc128db40e15877c3290f738bce8ae02))
* edit every task attribute from the task screen ([36ae082](https://github.com/Heliopsy/tix-mobile/commit/36ae082396e452e12571425ac0aef5a7c2b580e5))
* French and German for quick actions, templates, the inbox and notifications ([2c70002](https://github.com/Heliopsy/tix-mobile/commit/2c7000215f1c815064ab9067a1a9689e8ffe5045))
* French and German for the board, filters and bulk actions ([436906b](https://github.com/Heliopsy/tix-mobile/commit/436906bb64d7569d3df298b40e96c2f43c1937e6))
* French and German, with a test that keeps every language complete ([bc0f024](https://github.com/Heliopsy/tix-mobile/commit/bc0f0246c9e1c9dd5a42ba0599e51e37257330c3))
* inbox with live updates, local notifications and personal channels ([4dafa22](https://github.com/Heliopsy/tix-mobile/commit/4dafa22ea64ada1f139d953488538e7a01b9d369))
* switch to OLED black from the command palette ([4df795c](https://github.com/Heliopsy/tix-mobile/commit/4df795cb07e38e4750c5d82152ff554aa7bba0f9))
* **tasks:** keep an edit when the task changes elsewhere and offer Reload ([e839186](https://github.com/Heliopsy/tix-mobile/commit/e8391864feea46e73d0100c155ac8224be7f8bca))
* templates, quick add from anywhere, share intake and a global command palette ([a70d331](https://github.com/Heliopsy/tix-mobile/commit/a70d331fe6f805b451159c79881054500b9f128a))
* the project list's New task opens the shared quick add ([1b17878](https://github.com/Heliopsy/tix-mobile/commit/1b178785317c4e946aa83fc038fc97bbf8474489))


### Bug Fixes

* **tasks:** refresh listings after a quick add from the shared sheet ([094c390](https://github.com/Heliopsy/tix-mobile/commit/094c390d3a4130303511cb5da56a6a6fe22be69e))
* **tasks:** resync the list when a bulk undo is refused ([4f79a07](https://github.com/Heliopsy/tix-mobile/commit/4f79a07a8b5d572cf983193b722beb2a4b478244))

## [0.3.0](https://github.com/Heliopsy/tix-mobile/compare/v0.2.0...v0.3.0) (2026-11-08)


### Features

* generate the tix API client from the spec tix.lock pins ([8e5dbcb](https://github.com/Heliopsy/tix-mobile/commit/8e5dbcb5934ddaea7f3c627b7215863468b85363))
* list only the licences of what ships ([4578a1a](https://github.com/Heliopsy/tix-mobile/commit/4578a1ab7babf8fa8b37f6d29a045e32aac903aa))
* restyle the screens with the design system ([725be29](https://github.com/Heliopsy/tix-mobile/commit/725be29d09b2824995f403b33cdd6d822496ac5d))
* run local databases on the embedded tix engine ([9fe15b0](https://github.com/Heliopsy/tix-mobile/commit/9fe15b0233d125dc1a6876bf27a94d1fdb84c198))
* tix design tokens, the tenant accent and a component library ([30e332e](https://github.com/Heliopsy/tix-mobile/commit/30e332e308dd3ac4b3be1367e2c468ea6adac918))


### Bug Fixes

* leave unconditional public domain dedications off the Licenses page ([ab3063c](https://github.com/Heliopsy/tix-mobile/commit/ab3063cfeb000a1af3d8c798f69787385bedf4bf))

## [0.2.0](https://github.com/Heliopsy/tix-mobile/compare/v0.1.0...v0.2.0) (2026-11-08)


### Features

* several instances, sign-in and switching between tenants ([b1725e1](https://github.com/Heliopsy/tix-mobile/commit/b1725e11dd1bb5f984c997f51d8fcff46ed29f51))
* show the tix mark on the connect screen and in About ([d0e712d](https://github.com/Heliopsy/tix-mobile/commit/d0e712d70c9adf3376ab1e37ed019dfa6e11d34b))
* tix icons, launch screens and name on every platform ([5ae9aeb](https://github.com/Heliopsy/tix-mobile/commit/5ae9aebfa140ac0d34394bcfd834f33659879b89))


### Dependencies

* **android:** ship one APK per ABI instead of a universal APK ([3a47f36](https://github.com/Heliopsy/tix-mobile/commit/3a47f36f8366565da3190a0b9252774bf70dbb9d))

## 0.1.0 (2026-11-08)


### Features

* connect, browse projects and tasks, quick add and settings ([4ec1d0a](https://github.com/Heliopsy/tix-mobile/commit/4ec1d0ab119c8f1538169a68a4c95253cb9e9fa4))
* **data:** tix API client, models and repositories ([9b7a768](https://github.com/Heliopsy/tix-mobile/commit/9b7a7688d1abd7df81671c0b64be5e4ed57f5bcf))


### Dependencies

* add the justfile and pin the gate tools ([657388d](https://github.com/Heliopsy/tix-mobile/commit/657388de74e5708b4838f052d0be6678d08b620a))
* **android:** sign release builds from env or key.properties ([873d7a1](https://github.com/Heliopsy/tix-mobile/commit/873d7a16b7c6070c00c0b81d6863489ddcba0759))
* pin the app stack, strict lints and codegen config ([fd3c94a](https://github.com/Heliopsy/tix-mobile/commit/fd3c94aea6a4c61ee86cf5bddf24b924e16b0aaf))
* run dart analyze for analyzer plugins, drop removed build_runner flag ([9f6ba61](https://github.com/Heliopsy/tix-mobile/commit/9f6ba6134284ecbb7f126ae5bb20521ad7996b0c))
