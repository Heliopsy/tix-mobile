// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tix_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TixEvent {

/// The per-tenant sequence number, monotonic: the resume cursor.
 int get seq; String get type; String get id; String get tenantId; String get projectId; String get subjectType; String get subjectId; String get actorId; Map<String, Object?> get payload; Via? get via;@TixDateTime() DateTime? get occurredAt;
/// Create a copy of TixEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TixEventCopyWith<TixEvent> get copyWith => _$TixEventCopyWithImpl<TixEvent>(this as TixEvent, _$identity);

  /// Serializes this TixEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TixEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TixEvent&&(identical(other.seq, _this.seq) || other.seq == _this.seq)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.tenantId, _this.tenantId) || other.tenantId == _this.tenantId)&&(identical(other.projectId, _this.projectId) || other.projectId == _this.projectId)&&(identical(other.subjectType, _this.subjectType) || other.subjectType == _this.subjectType)&&(identical(other.subjectId, _this.subjectId) || other.subjectId == _this.subjectId)&&(identical(other.actorId, _this.actorId) || other.actorId == _this.actorId)&&const DeepCollectionEquality().equals(other.payload, _this.payload)&&(identical(other.via, _this.via) || other.via == _this.via)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TixEvent;
  return Object.hash(runtimeType,_this.seq,_this.type,_this.id,_this.tenantId,_this.projectId,_this.subjectType,_this.subjectId,_this.actorId,const DeepCollectionEquality().hash(_this.payload),_this.via,_this.occurredAt);
}

@override
String toString() {
  final _this = this as TixEvent;
  return 'TixEvent(seq: ${_this.seq}, type: ${_this.type}, id: ${_this.id}, tenantId: ${_this.tenantId}, projectId: ${_this.projectId}, subjectType: ${_this.subjectType}, subjectId: ${_this.subjectId}, actorId: ${_this.actorId}, payload: ${_this.payload}, via: ${_this.via}, occurredAt: ${_this.occurredAt})';
}


}

/// @nodoc
abstract mixin class $TixEventCopyWith<$Res>  {
  factory $TixEventCopyWith(TixEvent value, $Res Function(TixEvent) _then) = _$TixEventCopyWithImpl;
@useResult
$Res call({
 int seq, String type, String id, String tenantId, String projectId, String subjectType, String subjectId, String actorId, Map<String, Object?> payload, Via? via,@TixDateTime() DateTime? occurredAt
});


$ViaCopyWith<$Res>? get via;

}
/// @nodoc
class _$TixEventCopyWithImpl<$Res>
    implements $TixEventCopyWith<$Res> {
  _$TixEventCopyWithImpl(this._self, this._then);

  final TixEvent _self;
  final $Res Function(TixEvent) _then;

/// Create a copy of TixEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seq = null,Object? type = null,Object? id = null,Object? tenantId = null,Object? projectId = null,Object? subjectType = null,Object? subjectId = null,Object? actorId = null,Object? payload = null,Object? via = freezed,Object? occurredAt = freezed,}) {
  return _then(TixEvent(
seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,subjectType: null == subjectType ? _self.subjectType : subjectType // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,via: freezed == via ? _self.via : via // ignore: cast_nullable_to_non_nullable
as Via?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of TixEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViaCopyWith<$Res>? get via {
    if (_self.via == null) {
    return null;
  }

  return $ViaCopyWith<$Res>(_self.via!, (value) {
    return _then(_self.copyWith(via: value));
  });
}
}


/// Adds pattern-matching-related methods to [TixEvent].
extension TixEventPatterns on TixEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TixEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TixEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TixEvent value)  $default,){
final _that = this;
switch (_that) {
case _TixEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TixEvent value)?  $default,){
final _that = this;
switch (_that) {
case _TixEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int seq,  String type,  String id,  String tenantId,  String projectId,  String subjectType,  String subjectId,  String actorId,  Map<String, Object?> payload,  Via? via, @TixDateTime()  DateTime? occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TixEvent() when $default != null:
return $default(_that.seq,_that.type,_that.id,_that.tenantId,_that.projectId,_that.subjectType,_that.subjectId,_that.actorId,_that.payload,_that.via,_that.occurredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int seq,  String type,  String id,  String tenantId,  String projectId,  String subjectType,  String subjectId,  String actorId,  Map<String, Object?> payload,  Via? via, @TixDateTime()  DateTime? occurredAt)  $default,) {final _that = this;
switch (_that) {
case _TixEvent():
return $default(_that.seq,_that.type,_that.id,_that.tenantId,_that.projectId,_that.subjectType,_that.subjectId,_that.actorId,_that.payload,_that.via,_that.occurredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int seq,  String type,  String id,  String tenantId,  String projectId,  String subjectType,  String subjectId,  String actorId,  Map<String, Object?> payload,  Via? via, @TixDateTime()  DateTime? occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _TixEvent() when $default != null:
return $default(_that.seq,_that.type,_that.id,_that.tenantId,_that.projectId,_that.subjectType,_that.subjectId,_that.actorId,_that.payload,_that.via,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TixEvent implements TixEvent {
  const _TixEvent({required this.seq, required this.type, this.id = '', this.tenantId = '', this.projectId = '', this.subjectType = '', this.subjectId = '', this.actorId = '',  Map<String, Object?> payload = const <String, Object?>{}, this.via, @TixDateTime() this.occurredAt}): _payload = payload;
  factory _TixEvent.fromJson(Map<String, dynamic> json) => _$TixEventFromJson(json);

/// The per-tenant sequence number, monotonic: the resume cursor.
@override final  int seq;
@override final  String type;
@override@JsonKey() final  String id;
@override@JsonKey() final  String tenantId;
@override@JsonKey() final  String projectId;
@override@JsonKey() final  String subjectType;
@override@JsonKey() final  String subjectId;
@override@JsonKey() final  String actorId;
 final  Map<String, Object?> _payload;
@override@JsonKey() Map<String, Object?> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override final  Via? via;
@override@TixDateTime() final  DateTime? occurredAt;

/// Create a copy of TixEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TixEventCopyWith<_TixEvent> get copyWith => __$TixEventCopyWithImpl<_TixEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TixEventToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TixEvent&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.subjectType, subjectType) || other.subjectType == subjectType)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&const DeepCollectionEquality().equals(other.payload, _payload)&&(identical(other.via, via) || other.via == via)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,seq,type,id,tenantId,projectId,subjectType,subjectId,actorId,const DeepCollectionEquality().hash(_payload),via,occurredAt);
}

@override
String toString() {
    return 'TixEvent(seq: $seq, type: $type, id: $id, tenantId: $tenantId, projectId: $projectId, subjectType: $subjectType, subjectId: $subjectId, actorId: $actorId, payload: $payload, via: $via, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$TixEventCopyWith<$Res> implements $TixEventCopyWith<$Res> {
  factory _$TixEventCopyWith(_TixEvent value, $Res Function(_TixEvent) _then) = __$TixEventCopyWithImpl;
@override @useResult
$Res call({
 int seq, String type, String id, String tenantId, String projectId, String subjectType, String subjectId, String actorId, Map<String, Object?> payload, Via? via,@TixDateTime() DateTime? occurredAt
});


@override $ViaCopyWith<$Res>? get via;

}
/// @nodoc
class __$TixEventCopyWithImpl<$Res>
    implements _$TixEventCopyWith<$Res> {
  __$TixEventCopyWithImpl(this._self, this._then);

  final _TixEvent _self;
  final $Res Function(_TixEvent) _then;

/// Create a copy of TixEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seq = null,Object? type = null,Object? id = null,Object? tenantId = null,Object? projectId = null,Object? subjectType = null,Object? subjectId = null,Object? actorId = null,Object? payload = null,Object? via = freezed,Object? occurredAt = freezed,}) {
  return _then(_TixEvent(
seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,subjectType: null == subjectType ? _self.subjectType : subjectType // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,via: freezed == via ? _self.via : via // ignore: cast_nullable_to_non_nullable
as Via?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of TixEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViaCopyWith<$Res>? get via {
    if (_self.via == null) {
    return null;
  }

  return $ViaCopyWith<$Res>(_self.via!, (value) {
    return _then(_self.copyWith(via: value));
  });
}
}

// dart format on
