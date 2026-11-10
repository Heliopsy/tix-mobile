# Tasks

## 1. Build

- [x] 1.1 `scripts/build-ayatana.sh`: pinned 0.6.1 tarball and SHA-256, library-only cmake build, licence files
- [x] 1.2 `just linux-ayatana`; `libdbusmenu-gtk3-dev` and `curl` in `just setup-linux`
- [x] 1.3 CI and release Linux jobs restore the prefix, build on a miss; CI saves it on a push to main

## 2. Bundle

- [x] 2.1 `bundle-linux-libs.sh copy` takes libayatana-appindicator3 from the prefix and its licence files
- [x] 2.2 `bundle-linux-libs.sh check` fails without the tooltip symbols

## 3. Docs

- [x] 3.1 README, `docs/development.md`, `docs/releasing.md`
