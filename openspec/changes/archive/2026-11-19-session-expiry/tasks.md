# Tasks

## 1. Spec

- [x] 1.1 `sign-in` delta

## 2. Noticing a refusal

- [x] 2.1 `RefusalInterceptor` in `data/api`, reporting each `401` with the credential presented
- [x] 2.2 `tixClientFactoryProvider` for the bare client; `tixApiFactoryProvider` adds the interceptor and reports
  to `credentialRefusalsProvider`
- [x] 2.3 Test helper overrides the bare factory

## 3. Signing out

- [x] 3.1 `SessionController` listens, checks once with `whoami`, skips connections being removed
- [x] 3.2 `ConnectionJobs.cancel` and `InstancesRepository.deleteSecret`
- [x] 3.3 `awaitingSignIn` and the router's redirect to Sign in again
- [x] 3.4 Sign in again says the session ended; back goes to the connect screen

## 4. Notification

- [x] 4.1 `NoteChannel.account` and its Android channel
- [x] 4.2 Signed-out note, cancelled by signing in again; en, bg, de, fr

## 5. Tests

- [x] 5.1 Periodic sync `401`: signed out, timer cancelled, later ticks silent, notification shown
- [x] 5.2 Screen `401`: signed out, timer cancelled
- [x] 5.3 A `401` the session survives, several at once, a refused token
- [x] 5.4 App: started expired and expiring in use both reach Sign in again
- [x] 5.5 Router redirect with `awaitingSignIn`
