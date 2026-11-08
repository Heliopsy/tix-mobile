# calendar-feed Specification

## Purpose
The private calendar feed from the app: creating, filtering, rotating and revoking it, and handing its address to a calendar app once.

## Requirements

### Requirement: The feed is managed from the app

The calendar feed screen SHALL show whether a feed is active from `calendar.show`, and offer to create one
with an optional filter, change the filter keeping the address, rotate it, and revoke it after confirming. A
credential without `task:read` SHALL be told there is nothing to manage.

#### Scenario: No feed yet

- **WHEN** `calendar.show` answers not_found
- **THEN** the screen says there is no feed and offers Create

#### Scenario: Revoke asks first

- **WHEN** a person presses Revoke and confirms
- **THEN** the app calls `DELETE /calendar` and the screen says there is no feed

### Requirement: The address is shown once with help

After create or rotate the address SHALL be shown once with Copy, Share, a link to subscribe on this device
(`webcal://`), and steps for Google Calendar, Apple Calendar and Outlook. It SHALL never be cached or logged.

#### Scenario: Rotate

- **WHEN** a person rotates the feed
- **THEN** the new address is shown with a note that the old one stopped
