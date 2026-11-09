# local-instances

## MODIFIED Requirements

### Requirement: An idle engine stops and comes back on demand

An engine that has served no request but live updates for the idle timeout SHALL stop, while the app is in the foreground too. The timeout SHALL default to 10 minutes and be a setting, with a choice that never stops. The next request SHALL start the engine again before it is sent, on the same address when that is free, without the person doing anything.

#### Scenario: Idle and back

- **WHEN** a local context has made no request but live updates for 10 minutes
- **THEN** the engine is stopped, and the next request starts it on the same address and succeeds

#### Scenario: Never

- **WHEN** the idle timeout is set to never
- **THEN** the engine keeps running however long no request comes

## ADDED Requirements

### Requirement: Live updates are not activity

Event polls and the reads a periodic live refresh triggers SHALL NOT restart a local engine's idle timer or hold it awake, and a poll SHALL NOT start an engine that is not running. Navigation, the app returning to the foreground and every other request SHALL count as activity and start a resting engine.

#### Scenario: Polling engine idles

- **WHEN** live updates of a local context are polling and the person does nothing for the idle timeout
- **THEN** the engine stops

#### Scenario: Back to the app

- **WHEN** the engine rested and the app returns to the foreground or the person navigates
- **THEN** the engine starts again
