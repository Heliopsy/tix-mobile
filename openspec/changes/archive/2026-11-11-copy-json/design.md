# Design

## Keeping what tix sent

`AuditEntry` is generated from the OpenAPI document and `TixEvent` is read by json_serializable. Both fill
defaults for fields tix left out (`via.session: ""`) and drop fields the client does not know yet, so `toJson()` is
not what the server said.

The decoded object is kept beside the record instead, in an `Expando` keyed by the record (`wireJson`). A field on
the model would mean editing generated code or a wrapper type through every audit consumer; the expando costs
neither, and a record built on the device (a test, a fake) simply has nothing to copy, so the button is hidden.

The audit list and the event poll go through the generated operations unchanged. They run over a transport that
also keeps the JSON object it answered with, and the items of that object are paired with the parsed ones by
position. A WebSocket event keeps the `event` object of its message.

## Where the button goes

Phone: the entry's sheet carries Copy JSON beside Close. Wide window: the audit side pane carries it under the
action. Watch's details are a sheet at every width, so it sits beside Close and Open there. A long press on a row
copies too, for the phone where opening the sheet first is a detour.
