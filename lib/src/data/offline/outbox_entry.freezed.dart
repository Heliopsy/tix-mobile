// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outbox_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OutboxEntry {

/// A client id, unique on this device.
 String get id;/// The order writes were made in; replay keeps it per task.
 int get seq; OutboxOp get op;/// The task written to: its reference, or a draft's `key-draftN`.
 String get target;/// Sent as `Idempotency-Key`, so a retry after a lost answer is not
/// applied twice.
 String get idempotencyKey; DateTime get createdAt;/// The task's version when the person made the change.
 int? get baseVersion;/// The task as the person saw it, as tix's JSON.
 Map<String, Object?> get base;/// What is sent: the changed attributes, a comment's body, a tag's name.
 Map<String, Object?> get values; OutboxState get state;/// The server's error code and message for a refused or conflicting
/// write.
 String get errorCode; String get errorMessage;/// For a create, the draft reference the app showed until it is sent.
 String get draftRef; int get attempts;/// When a send under [idempotencyKey] first may have reached the server
/// (it timed out or its answer was unreadable), null while none did.
/// tix forgets a key a day after it first sees it.
 DateTime? get firstSentAt;
/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutboxEntryCopyWith<OutboxEntry> get copyWith => _$OutboxEntryCopyWithImpl<OutboxEntry>(this as OutboxEntry, _$identity);

  /// Serializes this OutboxEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OutboxEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboxEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.seq, _this.seq) || other.seq == _this.seq)&&(identical(other.op, _this.op) || other.op == _this.op)&&(identical(other.target, _this.target) || other.target == _this.target)&&(identical(other.idempotencyKey, _this.idempotencyKey) || other.idempotencyKey == _this.idempotencyKey)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.baseVersion, _this.baseVersion) || other.baseVersion == _this.baseVersion)&&const DeepCollectionEquality().equals(other.base, _this.base)&&const DeepCollectionEquality().equals(other.values, _this.values)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.errorCode, _this.errorCode) || other.errorCode == _this.errorCode)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.draftRef, _this.draftRef) || other.draftRef == _this.draftRef)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.firstSentAt, _this.firstSentAt) || other.firstSentAt == _this.firstSentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OutboxEntry;
  return Object.hash(runtimeType,_this.id,_this.seq,_this.op,_this.target,_this.idempotencyKey,_this.createdAt,_this.baseVersion,const DeepCollectionEquality().hash(_this.base),const DeepCollectionEquality().hash(_this.values),_this.state,_this.errorCode,_this.errorMessage,_this.draftRef,_this.attempts,_this.firstSentAt);
}

@override
String toString() {
  final _this = this as OutboxEntry;
  return 'OutboxEntry(id: ${_this.id}, seq: ${_this.seq}, op: ${_this.op}, target: ${_this.target}, idempotencyKey: ${_this.idempotencyKey}, createdAt: ${_this.createdAt}, baseVersion: ${_this.baseVersion}, base: ${_this.base}, values: ${_this.values}, state: ${_this.state}, errorCode: ${_this.errorCode}, errorMessage: ${_this.errorMessage}, draftRef: ${_this.draftRef}, attempts: ${_this.attempts}, firstSentAt: ${_this.firstSentAt})';
}


}

/// @nodoc
abstract mixin class $OutboxEntryCopyWith<$Res>  {
  factory $OutboxEntryCopyWith(OutboxEntry value, $Res Function(OutboxEntry) _then) = _$OutboxEntryCopyWithImpl;
@useResult
$Res call({
 String id, int seq, OutboxOp op, String target, String idempotencyKey, DateTime createdAt, int? baseVersion, Map<String, Object?> base, Map<String, Object?> values, OutboxState state, String errorCode, String errorMessage, String draftRef, int attempts, DateTime? firstSentAt
});




}
/// @nodoc
class _$OutboxEntryCopyWithImpl<$Res>
    implements $OutboxEntryCopyWith<$Res> {
  _$OutboxEntryCopyWithImpl(this._self, this._then);

  final OutboxEntry _self;
  final $Res Function(OutboxEntry) _then;

/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? seq = null,Object? op = null,Object? target = null,Object? idempotencyKey = null,Object? createdAt = null,Object? baseVersion = freezed,Object? base = null,Object? values = null,Object? state = null,Object? errorCode = null,Object? errorMessage = null,Object? draftRef = null,Object? attempts = null,Object? firstSentAt = freezed,}) {
  return _then(OutboxEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,op: null == op ? _self.op : op // ignore: cast_nullable_to_non_nullable
as OutboxOp,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,baseVersion: freezed == baseVersion ? _self.baseVersion : baseVersion // ignore: cast_nullable_to_non_nullable
as int?,base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OutboxState,errorCode: null == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,draftRef: null == draftRef ? _self.draftRef : draftRef // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,firstSentAt: freezed == firstSentAt ? _self.firstSentAt : firstSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OutboxEntry].
extension OutboxEntryPatterns on OutboxEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutboxEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutboxEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutboxEntry value)  $default,){
final _that = this;
switch (_that) {
case _OutboxEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutboxEntry value)?  $default,){
final _that = this;
switch (_that) {
case _OutboxEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int seq,  OutboxOp op,  String target,  String idempotencyKey,  DateTime createdAt,  int? baseVersion,  Map<String, Object?> base,  Map<String, Object?> values,  OutboxState state,  String errorCode,  String errorMessage,  String draftRef,  int attempts,  DateTime? firstSentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutboxEntry() when $default != null:
return $default(_that.id,_that.seq,_that.op,_that.target,_that.idempotencyKey,_that.createdAt,_that.baseVersion,_that.base,_that.values,_that.state,_that.errorCode,_that.errorMessage,_that.draftRef,_that.attempts,_that.firstSentAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int seq,  OutboxOp op,  String target,  String idempotencyKey,  DateTime createdAt,  int? baseVersion,  Map<String, Object?> base,  Map<String, Object?> values,  OutboxState state,  String errorCode,  String errorMessage,  String draftRef,  int attempts,  DateTime? firstSentAt)  $default,) {final _that = this;
switch (_that) {
case _OutboxEntry():
return $default(_that.id,_that.seq,_that.op,_that.target,_that.idempotencyKey,_that.createdAt,_that.baseVersion,_that.base,_that.values,_that.state,_that.errorCode,_that.errorMessage,_that.draftRef,_that.attempts,_that.firstSentAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int seq,  OutboxOp op,  String target,  String idempotencyKey,  DateTime createdAt,  int? baseVersion,  Map<String, Object?> base,  Map<String, Object?> values,  OutboxState state,  String errorCode,  String errorMessage,  String draftRef,  int attempts,  DateTime? firstSentAt)?  $default,) {final _that = this;
switch (_that) {
case _OutboxEntry() when $default != null:
return $default(_that.id,_that.seq,_that.op,_that.target,_that.idempotencyKey,_that.createdAt,_that.baseVersion,_that.base,_that.values,_that.state,_that.errorCode,_that.errorMessage,_that.draftRef,_that.attempts,_that.firstSentAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutboxEntry implements OutboxEntry {
  const _OutboxEntry({required this.id, required this.seq, required this.op, required this.target, required this.idempotencyKey, required this.createdAt, this.baseVersion,  Map<String, Object?> base = const <String, Object?>{},  Map<String, Object?> values = const <String, Object?>{}, this.state = OutboxState.pending, this.errorCode = '', this.errorMessage = '', this.draftRef = '', this.attempts = 0, this.firstSentAt}): _base = base,_values = values;
  factory _OutboxEntry.fromJson(Map<String, dynamic> json) => _$OutboxEntryFromJson(json);

/// A client id, unique on this device.
@override final  String id;
/// The order writes were made in; replay keeps it per task.
@override final  int seq;
@override final  OutboxOp op;
/// The task written to: its reference, or a draft's `key-draftN`.
@override final  String target;
/// Sent as `Idempotency-Key`, so a retry after a lost answer is not
/// applied twice.
@override final  String idempotencyKey;
@override final  DateTime createdAt;
/// The task's version when the person made the change.
@override final  int? baseVersion;
/// The task as the person saw it, as tix's JSON.
 final  Map<String, Object?> _base;
/// The task as the person saw it, as tix's JSON.
@override@JsonKey() Map<String, Object?> get base {
  if (_base is EqualUnmodifiableMapView) return _base;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_base);
}

/// What is sent: the changed attributes, a comment's body, a tag's name.
 final  Map<String, Object?> _values;
/// What is sent: the changed attributes, a comment's body, a tag's name.
@override@JsonKey() Map<String, Object?> get values {
  if (_values is EqualUnmodifiableMapView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_values);
}

@override@JsonKey() final  OutboxState state;
/// The server's error code and message for a refused or conflicting
/// write.
@override@JsonKey() final  String errorCode;
@override@JsonKey() final  String errorMessage;
/// For a create, the draft reference the app showed until it is sent.
@override@JsonKey() final  String draftRef;
@override@JsonKey() final  int attempts;
/// When a send under [idempotencyKey] first may have reached the server
/// (it timed out or its answer was unreadable), null while none did.
/// tix forgets a key a day after it first sees it.
@override final  DateTime? firstSentAt;

/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutboxEntryCopyWith<_OutboxEntry> get copyWith => __$OutboxEntryCopyWithImpl<_OutboxEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutboxEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutboxEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.op, op) || other.op == op)&&(identical(other.target, target) || other.target == target)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.baseVersion, baseVersion) || other.baseVersion == baseVersion)&&const DeepCollectionEquality().equals(other.base, _base)&&const DeepCollectionEquality().equals(other.values, _values)&&(identical(other.state, state) || other.state == state)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.draftRef, draftRef) || other.draftRef == draftRef)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.firstSentAt, firstSentAt) || other.firstSentAt == firstSentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,seq,op,target,idempotencyKey,createdAt,baseVersion,const DeepCollectionEquality().hash(_base),const DeepCollectionEquality().hash(_values),state,errorCode,errorMessage,draftRef,attempts,firstSentAt);
}

@override
String toString() {
    return 'OutboxEntry(id: $id, seq: $seq, op: $op, target: $target, idempotencyKey: $idempotencyKey, createdAt: $createdAt, baseVersion: $baseVersion, base: $base, values: $values, state: $state, errorCode: $errorCode, errorMessage: $errorMessage, draftRef: $draftRef, attempts: $attempts, firstSentAt: $firstSentAt)';
}


}

/// @nodoc
abstract mixin class _$OutboxEntryCopyWith<$Res> implements $OutboxEntryCopyWith<$Res> {
  factory _$OutboxEntryCopyWith(_OutboxEntry value, $Res Function(_OutboxEntry) _then) = __$OutboxEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, int seq, OutboxOp op, String target, String idempotencyKey, DateTime createdAt, int? baseVersion, Map<String, Object?> base, Map<String, Object?> values, OutboxState state, String errorCode, String errorMessage, String draftRef, int attempts, DateTime? firstSentAt
});




}
/// @nodoc
class __$OutboxEntryCopyWithImpl<$Res>
    implements _$OutboxEntryCopyWith<$Res> {
  __$OutboxEntryCopyWithImpl(this._self, this._then);

  final _OutboxEntry _self;
  final $Res Function(_OutboxEntry) _then;

/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? seq = null,Object? op = null,Object? target = null,Object? idempotencyKey = null,Object? createdAt = null,Object? baseVersion = freezed,Object? base = null,Object? values = null,Object? state = null,Object? errorCode = null,Object? errorMessage = null,Object? draftRef = null,Object? attempts = null,Object? firstSentAt = freezed,}) {
  return _then(_OutboxEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,op: null == op ? _self.op : op // ignore: cast_nullable_to_non_nullable
as OutboxOp,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,baseVersion: freezed == baseVersion ? _self.baseVersion : baseVersion // ignore: cast_nullable_to_non_nullable
as int?,base: null == base ? _self._base : base // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OutboxState,errorCode: null == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,draftRef: null == draftRef ? _self.draftRef : draftRef // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,firstSentAt: freezed == firstSentAt ? _self.firstSentAt : firstSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$FieldConflict {

/// The attribute, as its JSON key; a custom field is `custom_fields.key`.
 String get field; Object? get base; Object? get mine; Object? get theirs;
/// Create a copy of FieldConflict
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldConflictCopyWith<FieldConflict> get copyWith => _$FieldConflictCopyWithImpl<FieldConflict>(this as FieldConflict, _$identity);

  /// Serializes this FieldConflict to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FieldConflict;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldConflict&&(identical(other.field, _this.field) || other.field == _this.field)&&const DeepCollectionEquality().equals(other.base, _this.base)&&const DeepCollectionEquality().equals(other.mine, _this.mine)&&const DeepCollectionEquality().equals(other.theirs, _this.theirs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FieldConflict;
  return Object.hash(runtimeType,_this.field,const DeepCollectionEquality().hash(_this.base),const DeepCollectionEquality().hash(_this.mine),const DeepCollectionEquality().hash(_this.theirs));
}

@override
String toString() {
  final _this = this as FieldConflict;
  return 'FieldConflict(field: ${_this.field}, base: ${_this.base}, mine: ${_this.mine}, theirs: ${_this.theirs})';
}


}

/// @nodoc
abstract mixin class $FieldConflictCopyWith<$Res>  {
  factory $FieldConflictCopyWith(FieldConflict value, $Res Function(FieldConflict) _then) = _$FieldConflictCopyWithImpl;
@useResult
$Res call({
 String field, Object? base, Object? mine, Object? theirs
});




}
/// @nodoc
class _$FieldConflictCopyWithImpl<$Res>
    implements $FieldConflictCopyWith<$Res> {
  _$FieldConflictCopyWithImpl(this._self, this._then);

  final FieldConflict _self;
  final $Res Function(FieldConflict) _then;

/// Create a copy of FieldConflict
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field = null,Object? base = freezed,Object? mine = freezed,Object? theirs = freezed,}) {
  return _then(FieldConflict(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,base: freezed == base ? _self.base : base ,mine: freezed == mine ? _self.mine : mine ,theirs: freezed == theirs ? _self.theirs : theirs ,
  ));
}

}


/// Adds pattern-matching-related methods to [FieldConflict].
extension FieldConflictPatterns on FieldConflict {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FieldConflict value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FieldConflict() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FieldConflict value)  $default,){
final _that = this;
switch (_that) {
case _FieldConflict():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FieldConflict value)?  $default,){
final _that = this;
switch (_that) {
case _FieldConflict() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String field,  Object? base,  Object? mine,  Object? theirs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FieldConflict() when $default != null:
return $default(_that.field,_that.base,_that.mine,_that.theirs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String field,  Object? base,  Object? mine,  Object? theirs)  $default,) {final _that = this;
switch (_that) {
case _FieldConflict():
return $default(_that.field,_that.base,_that.mine,_that.theirs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String field,  Object? base,  Object? mine,  Object? theirs)?  $default,) {final _that = this;
switch (_that) {
case _FieldConflict() when $default != null:
return $default(_that.field,_that.base,_that.mine,_that.theirs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FieldConflict implements FieldConflict {
  const _FieldConflict({required this.field, this.base, this.mine, this.theirs});
  factory _FieldConflict.fromJson(Map<String, dynamic> json) => _$FieldConflictFromJson(json);

/// The attribute, as its JSON key; a custom field is `custom_fields.key`.
@override final  String field;
@override final  Object? base;
@override final  Object? mine;
@override final  Object? theirs;

/// Create a copy of FieldConflict
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldConflictCopyWith<_FieldConflict> get copyWith => __$FieldConflictCopyWithImpl<_FieldConflict>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FieldConflictToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldConflict&&(identical(other.field, field) || other.field == field)&&const DeepCollectionEquality().equals(other.base, base)&&const DeepCollectionEquality().equals(other.mine, mine)&&const DeepCollectionEquality().equals(other.theirs, theirs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,field,const DeepCollectionEquality().hash(base),const DeepCollectionEquality().hash(mine),const DeepCollectionEquality().hash(theirs));
}

@override
String toString() {
    return 'FieldConflict(field: $field, base: $base, mine: $mine, theirs: $theirs)';
}


}

/// @nodoc
abstract mixin class _$FieldConflictCopyWith<$Res> implements $FieldConflictCopyWith<$Res> {
  factory _$FieldConflictCopyWith(_FieldConflict value, $Res Function(_FieldConflict) _then) = __$FieldConflictCopyWithImpl;
@override @useResult
$Res call({
 String field, Object? base, Object? mine, Object? theirs
});




}
/// @nodoc
class __$FieldConflictCopyWithImpl<$Res>
    implements _$FieldConflictCopyWith<$Res> {
  __$FieldConflictCopyWithImpl(this._self, this._then);

  final _FieldConflict _self;
  final $Res Function(_FieldConflict) _then;

/// Create a copy of FieldConflict
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field = null,Object? base = freezed,Object? mine = freezed,Object? theirs = freezed,}) {
  return _then(_FieldConflict(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,base: freezed == base ? _self.base : base ,mine: freezed == mine ? _self.mine : mine ,theirs: freezed == theirs ? _self.theirs : theirs ,
  ));
}


}


/// @nodoc
mixin _$ConflictRecord {

 String get id;/// The write it came from, while that write waits.
 String get entryId; String get taskRef; ConflictKind get kind; DateTime get createdAt; String get taskTitle; List<FieldConflict> get fields;/// The server's reason, for a refused move.
 String get reason;/// The status the person moved to, for a refused move.
 String get wanted;/// The task's version on the server when it was found.
 int? get theirsVersion; Resolution? get resolution;/// Whether the policy settled it rather than the person.
 bool get auto; DateTime? get resolvedAt;
/// Create a copy of ConflictRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConflictRecordCopyWith<ConflictRecord> get copyWith => _$ConflictRecordCopyWithImpl<ConflictRecord>(this as ConflictRecord, _$identity);

  /// Serializes this ConflictRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConflictRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConflictRecord&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.entryId, _this.entryId) || other.entryId == _this.entryId)&&(identical(other.taskRef, _this.taskRef) || other.taskRef == _this.taskRef)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.taskTitle, _this.taskTitle) || other.taskTitle == _this.taskTitle)&&const DeepCollectionEquality().equals(other.fields, _this.fields)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.wanted, _this.wanted) || other.wanted == _this.wanted)&&(identical(other.theirsVersion, _this.theirsVersion) || other.theirsVersion == _this.theirsVersion)&&(identical(other.resolution, _this.resolution) || other.resolution == _this.resolution)&&(identical(other.auto, _this.auto) || other.auto == _this.auto)&&(identical(other.resolvedAt, _this.resolvedAt) || other.resolvedAt == _this.resolvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConflictRecord;
  return Object.hash(runtimeType,_this.id,_this.entryId,_this.taskRef,_this.kind,_this.createdAt,_this.taskTitle,const DeepCollectionEquality().hash(_this.fields),_this.reason,_this.wanted,_this.theirsVersion,_this.resolution,_this.auto,_this.resolvedAt);
}

@override
String toString() {
  final _this = this as ConflictRecord;
  return 'ConflictRecord(id: ${_this.id}, entryId: ${_this.entryId}, taskRef: ${_this.taskRef}, kind: ${_this.kind}, createdAt: ${_this.createdAt}, taskTitle: ${_this.taskTitle}, fields: ${_this.fields}, reason: ${_this.reason}, wanted: ${_this.wanted}, theirsVersion: ${_this.theirsVersion}, resolution: ${_this.resolution}, auto: ${_this.auto}, resolvedAt: ${_this.resolvedAt})';
}


}

/// @nodoc
abstract mixin class $ConflictRecordCopyWith<$Res>  {
  factory $ConflictRecordCopyWith(ConflictRecord value, $Res Function(ConflictRecord) _then) = _$ConflictRecordCopyWithImpl;
@useResult
$Res call({
 String id, String entryId, String taskRef, ConflictKind kind, DateTime createdAt, String taskTitle, List<FieldConflict> fields, String reason, String wanted, int? theirsVersion, Resolution? resolution, bool auto, DateTime? resolvedAt
});




}
/// @nodoc
class _$ConflictRecordCopyWithImpl<$Res>
    implements $ConflictRecordCopyWith<$Res> {
  _$ConflictRecordCopyWithImpl(this._self, this._then);

  final ConflictRecord _self;
  final $Res Function(ConflictRecord) _then;

/// Create a copy of ConflictRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? entryId = null,Object? taskRef = null,Object? kind = null,Object? createdAt = null,Object? taskTitle = null,Object? fields = null,Object? reason = null,Object? wanted = null,Object? theirsVersion = freezed,Object? resolution = freezed,Object? auto = null,Object? resolvedAt = freezed,}) {
  return _then(ConflictRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String,taskRef: null == taskRef ? _self.taskRef : taskRef // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConflictKind,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,taskTitle: null == taskTitle ? _self.taskTitle : taskTitle // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<FieldConflict>,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,wanted: null == wanted ? _self.wanted : wanted // ignore: cast_nullable_to_non_nullable
as String,theirsVersion: freezed == theirsVersion ? _self.theirsVersion : theirsVersion // ignore: cast_nullable_to_non_nullable
as int?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as Resolution?,auto: null == auto ? _self.auto : auto // ignore: cast_nullable_to_non_nullable
as bool,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConflictRecord].
extension ConflictRecordPatterns on ConflictRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConflictRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConflictRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConflictRecord value)  $default,){
final _that = this;
switch (_that) {
case _ConflictRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConflictRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ConflictRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String entryId,  String taskRef,  ConflictKind kind,  DateTime createdAt,  String taskTitle,  List<FieldConflict> fields,  String reason,  String wanted,  int? theirsVersion,  Resolution? resolution,  bool auto,  DateTime? resolvedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConflictRecord() when $default != null:
return $default(_that.id,_that.entryId,_that.taskRef,_that.kind,_that.createdAt,_that.taskTitle,_that.fields,_that.reason,_that.wanted,_that.theirsVersion,_that.resolution,_that.auto,_that.resolvedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String entryId,  String taskRef,  ConflictKind kind,  DateTime createdAt,  String taskTitle,  List<FieldConflict> fields,  String reason,  String wanted,  int? theirsVersion,  Resolution? resolution,  bool auto,  DateTime? resolvedAt)  $default,) {final _that = this;
switch (_that) {
case _ConflictRecord():
return $default(_that.id,_that.entryId,_that.taskRef,_that.kind,_that.createdAt,_that.taskTitle,_that.fields,_that.reason,_that.wanted,_that.theirsVersion,_that.resolution,_that.auto,_that.resolvedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String entryId,  String taskRef,  ConflictKind kind,  DateTime createdAt,  String taskTitle,  List<FieldConflict> fields,  String reason,  String wanted,  int? theirsVersion,  Resolution? resolution,  bool auto,  DateTime? resolvedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConflictRecord() when $default != null:
return $default(_that.id,_that.entryId,_that.taskRef,_that.kind,_that.createdAt,_that.taskTitle,_that.fields,_that.reason,_that.wanted,_that.theirsVersion,_that.resolution,_that.auto,_that.resolvedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConflictRecord implements ConflictRecord {
  const _ConflictRecord({required this.id, required this.entryId, required this.taskRef, required this.kind, required this.createdAt, this.taskTitle = '',  List<FieldConflict> fields = const <FieldConflict>[], this.reason = '', this.wanted = '', this.theirsVersion, this.resolution, this.auto = false, this.resolvedAt}): _fields = fields;
  factory _ConflictRecord.fromJson(Map<String, dynamic> json) => _$ConflictRecordFromJson(json);

@override final  String id;
/// The write it came from, while that write waits.
@override final  String entryId;
@override final  String taskRef;
@override final  ConflictKind kind;
@override final  DateTime createdAt;
@override@JsonKey() final  String taskTitle;
 final  List<FieldConflict> _fields;
@override@JsonKey() List<FieldConflict> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}

/// The server's reason, for a refused move.
@override@JsonKey() final  String reason;
/// The status the person moved to, for a refused move.
@override@JsonKey() final  String wanted;
/// The task's version on the server when it was found.
@override final  int? theirsVersion;
@override final  Resolution? resolution;
/// Whether the policy settled it rather than the person.
@override@JsonKey() final  bool auto;
@override final  DateTime? resolvedAt;

/// Create a copy of ConflictRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConflictRecordCopyWith<_ConflictRecord> get copyWith => __$ConflictRecordCopyWithImpl<_ConflictRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConflictRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConflictRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.taskRef, taskRef) || other.taskRef == taskRef)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.taskTitle, taskTitle) || other.taskTitle == taskTitle)&&const DeepCollectionEquality().equals(other.fields, _fields)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.wanted, wanted) || other.wanted == wanted)&&(identical(other.theirsVersion, theirsVersion) || other.theirsVersion == theirsVersion)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.auto, auto) || other.auto == auto)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,entryId,taskRef,kind,createdAt,taskTitle,const DeepCollectionEquality().hash(_fields),reason,wanted,theirsVersion,resolution,auto,resolvedAt);
}

@override
String toString() {
    return 'ConflictRecord(id: $id, entryId: $entryId, taskRef: $taskRef, kind: $kind, createdAt: $createdAt, taskTitle: $taskTitle, fields: $fields, reason: $reason, wanted: $wanted, theirsVersion: $theirsVersion, resolution: $resolution, auto: $auto, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class _$ConflictRecordCopyWith<$Res> implements $ConflictRecordCopyWith<$Res> {
  factory _$ConflictRecordCopyWith(_ConflictRecord value, $Res Function(_ConflictRecord) _then) = __$ConflictRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String entryId, String taskRef, ConflictKind kind, DateTime createdAt, String taskTitle, List<FieldConflict> fields, String reason, String wanted, int? theirsVersion, Resolution? resolution, bool auto, DateTime? resolvedAt
});




}
/// @nodoc
class __$ConflictRecordCopyWithImpl<$Res>
    implements _$ConflictRecordCopyWith<$Res> {
  __$ConflictRecordCopyWithImpl(this._self, this._then);

  final _ConflictRecord _self;
  final $Res Function(_ConflictRecord) _then;

/// Create a copy of ConflictRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? entryId = null,Object? taskRef = null,Object? kind = null,Object? createdAt = null,Object? taskTitle = null,Object? fields = null,Object? reason = null,Object? wanted = null,Object? theirsVersion = freezed,Object? resolution = freezed,Object? auto = null,Object? resolvedAt = freezed,}) {
  return _then(_ConflictRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String,taskRef: null == taskRef ? _self.taskRef : taskRef // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConflictKind,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,taskTitle: null == taskTitle ? _self.taskTitle : taskTitle // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<FieldConflict>,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,wanted: null == wanted ? _self.wanted : wanted // ignore: cast_nullable_to_non_nullable
as String,theirsVersion: freezed == theirsVersion ? _self.theirsVersion : theirsVersion // ignore: cast_nullable_to_non_nullable
as int?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as Resolution?,auto: null == auto ? _self.auto : auto // ignore: cast_nullable_to_non_nullable
as bool,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SyncSnapshot {

 List<OutboxEntry> get entries; List<ConflictRecord> get conflicts;/// Each sent draft's real reference, so links to a draft still work.
 Map<String, String> get drafts;/// The next draft number.
 int get nextDraft;/// The next write's order.
 int get nextSeq;/// Whether the server honours `Idempotency-Key`, null until known.
 bool? get idempotency;
/// Create a copy of SyncSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncSnapshotCopyWith<SyncSnapshot> get copyWith => _$SyncSnapshotCopyWithImpl<SyncSnapshot>(this as SyncSnapshot, _$identity);

  /// Serializes this SyncSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SyncSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncSnapshot&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&const DeepCollectionEquality().equals(other.conflicts, _this.conflicts)&&const DeepCollectionEquality().equals(other.drafts, _this.drafts)&&(identical(other.nextDraft, _this.nextDraft) || other.nextDraft == _this.nextDraft)&&(identical(other.nextSeq, _this.nextSeq) || other.nextSeq == _this.nextSeq)&&(identical(other.idempotency, _this.idempotency) || other.idempotency == _this.idempotency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SyncSnapshot;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.entries),const DeepCollectionEquality().hash(_this.conflicts),const DeepCollectionEquality().hash(_this.drafts),_this.nextDraft,_this.nextSeq,_this.idempotency);
}

@override
String toString() {
  final _this = this as SyncSnapshot;
  return 'SyncSnapshot(entries: ${_this.entries}, conflicts: ${_this.conflicts}, drafts: ${_this.drafts}, nextDraft: ${_this.nextDraft}, nextSeq: ${_this.nextSeq}, idempotency: ${_this.idempotency})';
}


}

/// @nodoc
abstract mixin class $SyncSnapshotCopyWith<$Res>  {
  factory $SyncSnapshotCopyWith(SyncSnapshot value, $Res Function(SyncSnapshot) _then) = _$SyncSnapshotCopyWithImpl;
@useResult
$Res call({
 List<OutboxEntry> entries, List<ConflictRecord> conflicts, Map<String, String> drafts, int nextDraft, int nextSeq, bool? idempotency
});




}
/// @nodoc
class _$SyncSnapshotCopyWithImpl<$Res>
    implements $SyncSnapshotCopyWith<$Res> {
  _$SyncSnapshotCopyWithImpl(this._self, this._then);

  final SyncSnapshot _self;
  final $Res Function(SyncSnapshot) _then;

/// Create a copy of SyncSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? conflicts = null,Object? drafts = null,Object? nextDraft = null,Object? nextSeq = null,Object? idempotency = freezed,}) {
  return _then(SyncSnapshot(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<OutboxEntry>,conflicts: null == conflicts ? _self.conflicts : conflicts // ignore: cast_nullable_to_non_nullable
as List<ConflictRecord>,drafts: null == drafts ? _self.drafts : drafts // ignore: cast_nullable_to_non_nullable
as Map<String, String>,nextDraft: null == nextDraft ? _self.nextDraft : nextDraft // ignore: cast_nullable_to_non_nullable
as int,nextSeq: null == nextSeq ? _self.nextSeq : nextSeq // ignore: cast_nullable_to_non_nullable
as int,idempotency: freezed == idempotency ? _self.idempotency : idempotency // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncSnapshot].
extension SyncSnapshotPatterns on SyncSnapshot {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncSnapshot() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _SyncSnapshot():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _SyncSnapshot() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OutboxEntry> entries,  List<ConflictRecord> conflicts,  Map<String, String> drafts,  int nextDraft,  int nextSeq,  bool? idempotency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncSnapshot() when $default != null:
return $default(_that.entries,_that.conflicts,_that.drafts,_that.nextDraft,_that.nextSeq,_that.idempotency);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OutboxEntry> entries,  List<ConflictRecord> conflicts,  Map<String, String> drafts,  int nextDraft,  int nextSeq,  bool? idempotency)  $default,) {final _that = this;
switch (_that) {
case _SyncSnapshot():
return $default(_that.entries,_that.conflicts,_that.drafts,_that.nextDraft,_that.nextSeq,_that.idempotency);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OutboxEntry> entries,  List<ConflictRecord> conflicts,  Map<String, String> drafts,  int nextDraft,  int nextSeq,  bool? idempotency)?  $default,) {final _that = this;
switch (_that) {
case _SyncSnapshot() when $default != null:
return $default(_that.entries,_that.conflicts,_that.drafts,_that.nextDraft,_that.nextSeq,_that.idempotency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncSnapshot implements SyncSnapshot {
  const _SyncSnapshot({ List<OutboxEntry> entries = const <OutboxEntry>[],  List<ConflictRecord> conflicts = const <ConflictRecord>[],  Map<String, String> drafts = const <String, String>{}, this.nextDraft = 1, this.nextSeq = 1, this.idempotency}): _entries = entries,_conflicts = conflicts,_drafts = drafts;
  factory _SyncSnapshot.fromJson(Map<String, dynamic> json) => _$SyncSnapshotFromJson(json);

 final  List<OutboxEntry> _entries;
@override@JsonKey() List<OutboxEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

 final  List<ConflictRecord> _conflicts;
@override@JsonKey() List<ConflictRecord> get conflicts {
  if (_conflicts is EqualUnmodifiableListView) return _conflicts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conflicts);
}

/// Each sent draft's real reference, so links to a draft still work.
 final  Map<String, String> _drafts;
/// Each sent draft's real reference, so links to a draft still work.
@override@JsonKey() Map<String, String> get drafts {
  if (_drafts is EqualUnmodifiableMapView) return _drafts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_drafts);
}

/// The next draft number.
@override@JsonKey() final  int nextDraft;
/// The next write's order.
@override@JsonKey() final  int nextSeq;
/// Whether the server honours `Idempotency-Key`, null until known.
@override final  bool? idempotency;

/// Create a copy of SyncSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncSnapshotCopyWith<_SyncSnapshot> get copyWith => __$SyncSnapshotCopyWithImpl<_SyncSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncSnapshot&&const DeepCollectionEquality().equals(other.entries, _entries)&&const DeepCollectionEquality().equals(other.conflicts, _conflicts)&&const DeepCollectionEquality().equals(other.drafts, _drafts)&&(identical(other.nextDraft, nextDraft) || other.nextDraft == nextDraft)&&(identical(other.nextSeq, nextSeq) || other.nextSeq == nextSeq)&&(identical(other.idempotency, idempotency) || other.idempotency == idempotency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_conflicts),const DeepCollectionEquality().hash(_drafts),nextDraft,nextSeq,idempotency);
}

@override
String toString() {
    return 'SyncSnapshot(entries: $entries, conflicts: $conflicts, drafts: $drafts, nextDraft: $nextDraft, nextSeq: $nextSeq, idempotency: $idempotency)';
}


}

/// @nodoc
abstract mixin class _$SyncSnapshotCopyWith<$Res> implements $SyncSnapshotCopyWith<$Res> {
  factory _$SyncSnapshotCopyWith(_SyncSnapshot value, $Res Function(_SyncSnapshot) _then) = __$SyncSnapshotCopyWithImpl;
@override @useResult
$Res call({
 List<OutboxEntry> entries, List<ConflictRecord> conflicts, Map<String, String> drafts, int nextDraft, int nextSeq, bool? idempotency
});




}
/// @nodoc
class __$SyncSnapshotCopyWithImpl<$Res>
    implements _$SyncSnapshotCopyWith<$Res> {
  __$SyncSnapshotCopyWithImpl(this._self, this._then);

  final _SyncSnapshot _self;
  final $Res Function(_SyncSnapshot) _then;

/// Create a copy of SyncSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? conflicts = null,Object? drafts = null,Object? nextDraft = null,Object? nextSeq = null,Object? idempotency = freezed,}) {
  return _then(_SyncSnapshot(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<OutboxEntry>,conflicts: null == conflicts ? _self._conflicts : conflicts // ignore: cast_nullable_to_non_nullable
as List<ConflictRecord>,drafts: null == drafts ? _self._drafts : drafts // ignore: cast_nullable_to_non_nullable
as Map<String, String>,nextDraft: null == nextDraft ? _self.nextDraft : nextDraft // ignore: cast_nullable_to_non_nullable
as int,nextSeq: null == nextSeq ? _self.nextSeq : nextSeq // ignore: cast_nullable_to_non_nullable
as int,idempotency: freezed == idempotency ? _self.idempotency : idempotency // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
