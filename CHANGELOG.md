# Changelog

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
