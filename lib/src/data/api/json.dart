// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// An RFC 3339 instant: read as tix writes it, always sent in UTC so the
/// string carries its offset.
class TixDateTime implements JsonConverter<DateTime, String> {
  /// The converter.
  const TixDateTime();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}

/// A change to an input field whose JSON null means "clear it".
///
/// A field of type `Patch<T>?` that is null is left out of the body,
/// `Patch(value)` sends the value and `Patch.clear()` sends a JSON null.
@immutable
final class Patch<T extends Object> {
  /// Sets the field to [value].
  const Patch(T this.value);

  /// Clears the field.
  const Patch.clear() : value = null;

  /// The new value, null when the field is cleared.
  final T? value;

  /// The value on the wire: [encode] of [value], or null when cleared.
  Object? encode(Object? Function(T value) encode) {
    final v = value;
    return v == null ? null : encode(v);
  }

  @override
  bool operator ==(Object other) => other is Patch<T> && other.value == value;

  @override
  int get hashCode => Object.hash(Patch, value);

  @override
  String toString() => value == null ? 'Patch.clear()' : 'Patch($value)';
}
