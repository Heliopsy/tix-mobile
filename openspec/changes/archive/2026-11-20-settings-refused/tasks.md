# Tasks

## 1. Spec

- [x] 1.1 `instances` delta

## 2. State

- [x] 2.1 `InstancesRepository.markSignedOut`, run once per start from `migrate`

## 3. Lists

- [x] 3.1 `RefusedMark` with its semantics label; en, bg, de, fr
- [x] 3.2 Instances screen: mark, tap and Sign in again open reconnect
- [x] 3.3 Context switcher: mark; `activateEntry` opens reconnect for a refused connection

## 4. Tests

- [x] 4.1 Refused token row, signed-out sign-in row, healthy row, tap to reconnect, mark gone after a new token
- [x] 4.2 Switcher row marked and opening reconnect
- [x] 4.3 Repository marks a sign-in without its session, once
