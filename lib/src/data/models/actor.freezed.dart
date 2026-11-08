// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'actor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Actor {

 String get id; String get handle; String get kind; String get displayName; String get email; String get tenantId; String get tenantKey; String get tenantName; String get accountId; List<Membership> get memberships;
/// Create a copy of Actor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActorCopyWith<Actor> get copyWith => _$ActorCopyWithImpl<Actor>(this as Actor, _$identity);

  /// Serializes this Actor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Actor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Actor&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.handle, _this.handle) || other.handle == _this.handle)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.tenantId, _this.tenantId) || other.tenantId == _this.tenantId)&&(identical(other.tenantKey, _this.tenantKey) || other.tenantKey == _this.tenantKey)&&(identical(other.tenantName, _this.tenantName) || other.tenantName == _this.tenantName)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&const DeepCollectionEquality().equals(other.memberships, _this.memberships));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Actor;
  return Object.hash(runtimeType,_this.id,_this.handle,_this.kind,_this.displayName,_this.email,_this.tenantId,_this.tenantKey,_this.tenantName,_this.accountId,const DeepCollectionEquality().hash(_this.memberships));
}

@override
String toString() {
  final _this = this as Actor;
  return 'Actor(id: ${_this.id}, handle: ${_this.handle}, kind: ${_this.kind}, displayName: ${_this.displayName}, email: ${_this.email}, tenantId: ${_this.tenantId}, tenantKey: ${_this.tenantKey}, tenantName: ${_this.tenantName}, accountId: ${_this.accountId}, memberships: ${_this.memberships})';
}


}

/// @nodoc
abstract mixin class $ActorCopyWith<$Res>  {
  factory $ActorCopyWith(Actor value, $Res Function(Actor) _then) = _$ActorCopyWithImpl;
@useResult
$Res call({
 String id, String handle, String kind, String displayName, String email, String tenantId, String tenantKey, String tenantName, String accountId, List<Membership> memberships
});




}
/// @nodoc
class _$ActorCopyWithImpl<$Res>
    implements $ActorCopyWith<$Res> {
  _$ActorCopyWithImpl(this._self, this._then);

  final Actor _self;
  final $Res Function(Actor) _then;

/// Create a copy of Actor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? handle = null,Object? kind = null,Object? displayName = null,Object? email = null,Object? tenantId = null,Object? tenantKey = null,Object? tenantName = null,Object? accountId = null,Object? memberships = null,}) {
  return _then(Actor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,tenantKey: null == tenantKey ? _self.tenantKey : tenantKey // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,memberships: null == memberships ? _self.memberships : memberships // ignore: cast_nullable_to_non_nullable
as List<Membership>,
  ));
}

}


/// Adds pattern-matching-related methods to [Actor].
extension ActorPatterns on Actor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Actor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Actor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Actor value)  $default,){
final _that = this;
switch (_that) {
case _Actor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Actor value)?  $default,){
final _that = this;
switch (_that) {
case _Actor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String handle,  String kind,  String displayName,  String email,  String tenantId,  String tenantKey,  String tenantName,  String accountId,  List<Membership> memberships)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Actor() when $default != null:
return $default(_that.id,_that.handle,_that.kind,_that.displayName,_that.email,_that.tenantId,_that.tenantKey,_that.tenantName,_that.accountId,_that.memberships);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String handle,  String kind,  String displayName,  String email,  String tenantId,  String tenantKey,  String tenantName,  String accountId,  List<Membership> memberships)  $default,) {final _that = this;
switch (_that) {
case _Actor():
return $default(_that.id,_that.handle,_that.kind,_that.displayName,_that.email,_that.tenantId,_that.tenantKey,_that.tenantName,_that.accountId,_that.memberships);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String handle,  String kind,  String displayName,  String email,  String tenantId,  String tenantKey,  String tenantName,  String accountId,  List<Membership> memberships)?  $default,) {final _that = this;
switch (_that) {
case _Actor() when $default != null:
return $default(_that.id,_that.handle,_that.kind,_that.displayName,_that.email,_that.tenantId,_that.tenantKey,_that.tenantName,_that.accountId,_that.memberships);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Actor extends Actor {
  const _Actor({required this.id, this.handle = '', this.kind = '', this.displayName = '', this.email = '', this.tenantId = '', this.tenantKey = '', this.tenantName = '', this.accountId = '',  List<Membership> memberships = const <Membership>[]}): _memberships = memberships,super._();
  factory _Actor.fromJson(Map<String, dynamic> json) => _$ActorFromJson(json);

@override final  String id;
@override@JsonKey() final  String handle;
@override@JsonKey() final  String kind;
@override@JsonKey() final  String displayName;
@override@JsonKey() final  String email;
@override@JsonKey() final  String tenantId;
@override@JsonKey() final  String tenantKey;
@override@JsonKey() final  String tenantName;
@override@JsonKey() final  String accountId;
 final  List<Membership> _memberships;
@override@JsonKey() List<Membership> get memberships {
  if (_memberships is EqualUnmodifiableListView) return _memberships;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberships);
}


/// Create a copy of Actor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActorCopyWith<_Actor> get copyWith => __$ActorCopyWithImpl<_Actor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Actor&&(identical(other.id, id) || other.id == id)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.tenantKey, tenantKey) || other.tenantKey == tenantKey)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&const DeepCollectionEquality().equals(other.memberships, _memberships));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,handle,kind,displayName,email,tenantId,tenantKey,tenantName,accountId,const DeepCollectionEquality().hash(_memberships));
}

@override
String toString() {
    return 'Actor(id: $id, handle: $handle, kind: $kind, displayName: $displayName, email: $email, tenantId: $tenantId, tenantKey: $tenantKey, tenantName: $tenantName, accountId: $accountId, memberships: $memberships)';
}


}

/// @nodoc
abstract mixin class _$ActorCopyWith<$Res> implements $ActorCopyWith<$Res> {
  factory _$ActorCopyWith(_Actor value, $Res Function(_Actor) _then) = __$ActorCopyWithImpl;
@override @useResult
$Res call({
 String id, String handle, String kind, String displayName, String email, String tenantId, String tenantKey, String tenantName, String accountId, List<Membership> memberships
});




}
/// @nodoc
class __$ActorCopyWithImpl<$Res>
    implements _$ActorCopyWith<$Res> {
  __$ActorCopyWithImpl(this._self, this._then);

  final _Actor _self;
  final $Res Function(_Actor) _then;

/// Create a copy of Actor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? handle = null,Object? kind = null,Object? displayName = null,Object? email = null,Object? tenantId = null,Object? tenantKey = null,Object? tenantName = null,Object? accountId = null,Object? memberships = null,}) {
  return _then(_Actor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,tenantKey: null == tenantKey ? _self.tenantKey : tenantKey // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,memberships: null == memberships ? _self._memberships : memberships // ignore: cast_nullable_to_non_nullable
as List<Membership>,
  ));
}


}

// dart format on
