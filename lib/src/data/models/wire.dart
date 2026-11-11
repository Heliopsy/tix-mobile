// SPDX-License-Identifier: AGPL-3.0-or-later

/// The JSON objects tix sent, kept beside the records read from them.
library;

// Generated models fill defaults for fields tix left out and drop the ones
// they do not know, so their toJson is not what the server said. An expando
// keeps the object without a field on generated code.
final _wire = Expando<Map<String, Object?>>('wire');

/// Remembers [json] as what tix sent for [record], and returns [record].
T keepWire<T extends Object>(T record, Map<String, Object?> json) {
  _wire[record] = json;
  return record;
}

/// The JSON object tix sent for [record], or null when it was not read from
/// tix.
Map<String, Object?>? wireJson(Object record) => _wire[record];

/// Keeps each object of [json] as what tix sent for the record at the same
/// position of [records]. Lists that disagree in length are left alone.
void keepWireAll(List<Object> records, Object? json) {
  if (json is! List || json.length != records.length) return;
  for (var i = 0; i < records.length; i++) {
    if (json[i] case final Map<String, Object?> item) {
      keepWire(records[i], item);
    }
  }
}
