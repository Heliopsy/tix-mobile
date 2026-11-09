# reader-time

## MODIFIED Requirements

### Requirement: The preference is remembered per context

The app SHALL remember the last settings it read for each context and use them at start, then refresh them from
the server, so dates do not change format after the first frame. It SHALL read them again when the context
changes, when the app comes back to the foreground and when Settings opens.

#### Scenario: Start offline

- **WHEN** the app starts without a network after reading `dotted` before
- **THEN** dates are written in `dotted`

#### Scenario: Changed on the web

- **WHEN** the person picks `us` on the web and returns to the app
- **THEN** the app reads `/me/time` again and dates are written in `us`
