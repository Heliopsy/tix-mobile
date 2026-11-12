# Changelog

## [0.15.0](https://github.com/Heliopsy/tix-mobile/compare/v0.14.0...v0.15.0) (2026-11-12)


### Features

* **tasks:** move a task to another project ([c617aab](https://github.com/Heliopsy/tix-mobile/commit/c617aab28f5fe57adbbcf5f500678a65d6c7f684))
* **tasks:** show the token behind a change and react to comments ([20f61a6](https://github.com/Heliopsy/tix-mobile/commit/20f61a6f2dcae37ff427bf95aac40352cd4c8621))


### Bug Fixes

* **tasks:** keep reactions on after a deleted comment's 404, and toggle at once ([a1b73d4](https://github.com/Heliopsy/tix-mobile/commit/a1b73d48053c540f59c5b9fba619665b2a380c73))


### Dependencies

* go 1.27.4, which the pinned tix requires ([13f3a80](https://github.com/Heliopsy/tix-mobile/commit/13f3a801abf3f280dd0e4f8ed012ac1ac38b30e4))
* pin tix at the merged comment reactions commit ([050ca33](https://github.com/Heliopsy/tix-mobile/commit/050ca3330e51e4e38fec8e02409dd9c041773070))
* pin tix at v0.57.0 ([a2fe484](https://github.com/Heliopsy/tix-mobile/commit/a2fe484515fd24539ba40e4f12eadbaae80047b0))

## [0.14.0](https://github.com/Heliopsy/tix-mobile/compare/v0.13.2...v0.14.0) (2026-11-11)


### Features

* **audit:** copy an audit entry or a Watch event as the JSON tix sent ([08a145e](https://github.com/Heliopsy/tix-mobile/commit/08a145eeaf34907a37f07959687dcbe2aff97d52))
* **shell:** call Watch Activity, as the web does ([dde076b](https://github.com/Heliopsy/tix-mobile/commit/dde076bb0b17ff281e5844561700fefead0f2510))
* **tasks:** hand a task to a coding agent, as the web does ([366a66f](https://github.com/Heliopsy/tix-mobile/commit/366a66f36e609e3a3fa255734b93163869fc3a49))
* **tasks:** name the API token a change was made with in history and Watch ([894bd0a](https://github.com/Heliopsy/tix-mobile/commit/894bd0a3dc15811177571213e787760d79bc0b5c))
* **tasks:** say how many tasks an agent holds, as the web does ([bb4cc33](https://github.com/Heliopsy/tix-mobile/commit/bb4cc337510d32ba5a74501dce05e83fdf16c159))


### Bug Fixes

* **design:** draw the blocked state in red, as tix does everywhere else ([0c6ebbb](https://github.com/Heliopsy/tix-mobile/commit/0c6ebbb8f4026a1f02751107d74c1c480d784bca))
* **l10n:** keep the French held-by-agent string free of plurals like the template ([9be5ddd](https://github.com/Heliopsy/tix-mobile/commit/9be5ddddcaf8ea4228f78f5c3f65263815ebd090))
* **tasks:** stop rows and cards staying highlighted after they were opened ([2589114](https://github.com/Heliopsy/tix-mobile/commit/258911493aaefbd808527aab88508674115e7890))

## [0.13.2](https://github.com/Heliopsy/tix-mobile/compare/v0.13.1...v0.13.2) (2026-11-11)


### Bug Fixes

* **quick:** open quick add on the project on show ([88e2206](https://github.com/Heliopsy/tix-mobile/commit/88e22064fec4a96db6756f137cb154cc93b649a3))

## [0.13.1](https://github.com/Heliopsy/tix-mobile/compare/v0.13.0...v0.13.1) (2026-11-11)


### Bug Fixes

* **shell:** make Watch a normal destination instead of a bare icon ([87275db](https://github.com/Heliopsy/tix-mobile/commit/87275dbd737ca284e9c8e152212bd03e5fe56976))
* **tasks:** let the list take the whole window until a task opens ([266163f](https://github.com/Heliopsy/tix-mobile/commit/266163fe42687c8f8ca9f38b4d96050a9c68c18a))

## [0.13.0](https://github.com/Heliopsy/tix-mobile/compare/v0.12.0...v0.13.0) (2026-11-10)


### Features

* **design:** swipe toasts away to the left or right as well as down ([4f00fe0](https://github.com/Heliopsy/tix-mobile/commit/4f00fe09aa9e5ca2a29eebb57deee9f07700d8e1))
* **desktop:** show connection, sync and inbox status when hovering the tray icon ([84fcffb](https://github.com/Heliopsy/tix-mobile/commit/84fcffb6046c1992256b1226453016234ee5c43e))
* **keyboard:** keymap presets and keyboard-only navigation ([a5ba000](https://github.com/Heliopsy/tix-mobile/commit/a5ba0000e603cf21fccfd6342a6fc20f99ffda12))
* **shell:** resizable, collapsible rail and a closable task panel on wide windows ([aac1558](https://github.com/Heliopsy/tix-mobile/commit/aac155812c6b4ad86ff366fad22b0be01c782d5e))
* **tasks:** edit a task from its row and animate the tick ([5c325ee](https://github.com/Heliopsy/tix-mobile/commit/5c325eeac01a240295125fef0e632eca07f49ee0))
* **watch:** shortcuts, a live dot that moves, and rows that say who and what ([6ae2d3c](https://github.com/Heliopsy/tix-mobile/commit/6ae2d3cd8f3b41a95b539949744a122c45f205c9))


### Bug Fixes

* **desktop:** let letters typed into a field reach it ([2dfafb9](https://github.com/Heliopsy/tix-mobile/commit/2dfafb94bd82172cae8f91ba5d0fa0b4b5da1659))
* **linux:** bundle libayatana-appindicator 0.6.1 for the tray tooltip ([b65cd3a](https://github.com/Heliopsy/tix-mobile/commit/b65cd3af389800284ca09b2b18eaa69194f584b2))
* **linux:** ship the tray libraries in the tarball ([96a3130](https://github.com/Heliopsy/tix-mobile/commit/96a3130a3346591317a931b58789b4e375262b77))
* **tasks:** put the panel's close button in the task header ([e71f63f](https://github.com/Heliopsy/tix-mobile/commit/e71f63f51c75476f5e8c712e7315af6b54f0be84))

## [0.12.0](https://github.com/Heliopsy/tix-mobile/compare/v0.11.1...v0.12.0) (2026-11-10)


### Features

* **desktop:** check GitHub for updates and install them on restart ([8d12ac0](https://github.com/Heliopsy/tix-mobile/commit/8d12ac05a2522e2f5ee38d0af54ff9749be082b8))
* **desktop:** install updates checksum-only until a signing key is pinned ([4eea6ee](https://github.com/Heliopsy/tix-mobile/commit/4eea6eed3d906b5c2dee38182047cf7d8ffb464e))

## [0.11.1](https://github.com/Heliopsy/tix-mobile/compare/v0.11.0...v0.11.1) (2026-11-10)


### Features

* **watch:** follow the tenant's events live on a Watch screen ([a13569f](https://github.com/Heliopsy/tix-mobile/commit/a13569fdc812a34dd8f31592b8f42e907341b12a))


### Bug Fixes

* **shell:** open the context switcher as a dialog on wide screens ([262d808](https://github.com/Heliopsy/tix-mobile/commit/262d80834ccf6e6a8824d19c235e25583bc6b8de))


### Tests

* **events:** use a known task type in the poll test ([fd01404](https://github.com/Heliopsy/tix-mobile/commit/fd01404d29a6ac219e1e9e17ef29d8965c95a736))
* **watch:** match the unsubscribe frame by value; poll test fits the filtering fake ([27421f9](https://github.com/Heliopsy/tix-mobile/commit/27421f9f48ad8a1c83c9b8a52ddb94c306af60cb))

## [0.11.0](https://github.com/Heliopsy/tix-mobile/compare/v0.10.0...v0.11.0) (2026-11-10)


### Features

* **desktop:** tray icon, close to tray, start at login and one instance ([afa80d3](https://github.com/Heliopsy/tix-mobile/commit/afa80d3b7e99ec07a54338b88ead6b49cb88f225))


### Bug Fixes

* **desktop:** a login launch while tix runs leaves the window alone ([de7b769](https://github.com/Heliopsy/tix-mobile/commit/de7b76925c6fdad75c2713bab749d44e8ac1abe4))

## [0.10.0](https://github.com/Heliopsy/tix-mobile/compare/v0.9.0...v0.10.0) (2026-11-09)


### Features

* an explicit select mode for the list, board and lanes ([d603db2](https://github.com/Heliopsy/tix-mobile/commit/d603db2dde5ad288a55863875ec983245f49a698))
* offer the task:approve scope on new tokens ([21b24d1](https://github.com/Heliopsy/tix-mobile/commit/21b24d1aa1f5f9a435d4a657d6bf233caed0fef9))
* quick settings tiles, notification actions and pinned shortcuts on Android ([7d21d2c](https://github.com/Heliopsy/tix-mobile/commit/7d21d2cd74f9c40ecb63cb55b50760cbbdf42c8b))
* star projects and list them first ([0cbfec2](https://github.com/Heliopsy/tix-mobile/commit/0cbfec2312208f3d439e53e7904404f571285b79))


### Bug Fixes

* hand the outbox from the background engine to the app before it loads ([6367c18](https://github.com/Heliopsy/tix-mobile/commit/6367c1837024a89c812f78f13db682ed283fd2b1))
* leave sign-out out of the context move, init the test binding ([c50c537](https://github.com/Heliopsy/tix-mobile/commit/c50c5379046a4e79b0e3c6c4d47ad76d53e201cc))
* start a switched context fresh instead of refetching the old screen ([7e29a2a](https://github.com/Heliopsy/tix-mobile/commit/7e29a2adfe0459caa017ff6104f2ac29e7f8684d))
* wait for pin support before opening a saved filter's menu, snooze in UTC ([b8bacd8](https://github.com/Heliopsy/tix-mobile/commit/b8bacd8e95fca2354b6b8a37a2d45eb6e64ab52f))
* wait for the old shell to leave the tree before switching ([01249e9](https://github.com/Heliopsy/tix-mobile/commit/01249e99b3a1cb4342e6b242086f1f202e830304))
* watch pin support for every saved filter, not just shared ones ([921c397](https://github.com/Heliopsy/tix-mobile/commit/921c397018cfb39fc00a303989aa2fb08a00368e))


### Dependencies

* pin tix at the merged project stars commit ([05be264](https://github.com/Heliopsy/tix-mobile/commit/05be26421a652ffb25214af0087f1f99c0857f5f))
* pin tix at v0.53.0 ([cb66011](https://github.com/Heliopsy/tix-mobile/commit/cb66011003a7ca56588e3c0c6315c701d30ae917))

## [0.9.0](https://github.com/Heliopsy/tix-mobile/compare/v0.8.0...v0.9.0) (2026-11-09)


### Features

* control the app over adb with dumpsys, tix:// links and shell-only commands ([384abca](https://github.com/Heliopsy/tix-mobile/commit/384abca0c0bbcd8b865360df91515f6af60bb894))


### Bug Fixes

* **adb:** keep section headings clear of the credential redaction ([7c2e9db](https://github.com/Heliopsy/tix-mobile/commit/7c2e9dbadc53598a19d581959122281c0f0aa10f))


### Dependencies

* refresh the router's generated hash ([ea2b08a](https://github.com/Heliopsy/tix-mobile/commit/ea2b08a176e99d6efc515de5155b82344914d272))

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
