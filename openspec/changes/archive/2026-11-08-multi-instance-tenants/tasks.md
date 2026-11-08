# Tasks

## 1. Data

- [x] 1.1 Models: Instance, Connection, Membership, ContextRef, LoginResult, Actor memberships
- [x] 1.2 TixApi: Credential (bearer or session cookie), login, switch, logout
- [x] 1.3 InstancesRepository with the storage layout and the v0.1.0 migration
- [x] 1.4 AuthRepository: server check, token check, login, code, switch, logout
- [x] 1.5 LocalTixEngine interface, InMemoryLocalTixEngine, UnavailableLocalTixEngine

## 2. Session

- [x] 2.1 SessionController over instances and connections: active context, recents, activate, sign out
- [x] 2.2 Switch tenant through `/auth/switch`, code challenge included
- [x] 2.3 LocalEngines: lazy start, stop on switch away and on exit
- [x] 2.4 Tenant backfill from `whoami` for migrated connections

## 3. Screens

- [x] 3.1 Add instance: remote address or local file, then token or sign-in
- [x] 3.2 Sign-in with second factor, tenant choice with pin or switchable
- [x] 3.3 Local: open or create a database, pick or create a tenant
- [x] 3.4 Instances screen: list, add connection, remove connection or instance, pin toggle
- [x] 3.5 Context switcher in the shell, phone and rail; own-host tenants offered as instances
- [x] 3.6 English and Bulgarian strings for every new text
- [x] 3.7 File picking behind FilePicking; macOS user-selected file entitlement

## 4. Tests

- [x] 4.1 Repository, migration and auth flow unit tests; fake engine tests
- [x] 4.2 FakeTix: login, code challenge, switch, memberships, session cookie
- [x] 4.3 Widget tests: instances screen, add instance (remote, local), sign-in, switcher
- [x] 4.4 Coverage above the floor

## 5. Docs

- [x] 5.1 docs/architecture.md and the README feature list

## 6. Real server

- [x] 6.1 Login, memberships, switch and tokens against a throwaway `tix serve`; bearer versus cookie recorded in design.md
