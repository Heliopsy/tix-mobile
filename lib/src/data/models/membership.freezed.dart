// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Membership {

 String get tenantKey; String get tenantName; String get tenantId; String get actorId; String get handle; String get role; String get host; TenantIcon get icon;
/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipCopyWith<Membership> get copyWith => _$MembershipCopyWithImpl<Membership>(this as Membership, _$identity);

  /// Serializes this Membership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Membership;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Membership&&(identical(other.tenantKey, _this.tenantKey) || other.tenantKey == _this.tenantKey)&&(identical(other.tenantName, _this.tenantName) || other.tenantName == _this.tenantName)&&(identical(other.tenantId, _this.tenantId) || other.tenantId == _this.tenantId)&&(identical(other.actorId, _this.actorId) || other.actorId == _this.actorId)&&(identical(other.handle, _this.handle) || other.handle == _this.handle)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.icon, _this.icon) || other.icon == _this.icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Membership;
  return Object.hash(runtimeType,_this.tenantKey,_this.tenantName,_this.tenantId,_this.actorId,_this.handle,_this.role,_this.host,_this.icon);
}

@override
String toString() {
  final _this = this as Membership;
  return 'Membership(tenantKey: ${_this.tenantKey}, tenantName: ${_this.tenantName}, tenantId: ${_this.tenantId}, actorId: ${_this.actorId}, handle: ${_this.handle}, role: ${_this.role}, host: ${_this.host}, icon: ${_this.icon})';
}


}

/// @nodoc
abstract mixin class $MembershipCopyWith<$Res>  {
  factory $MembershipCopyWith(Membership value, $Res Function(Membership) _then) = _$MembershipCopyWithImpl;
@useResult
$Res call({
 String tenantKey, String tenantName, String tenantId, String actorId, String handle, String role, String host, TenantIcon icon
});




}
/// @nodoc
class _$MembershipCopyWithImpl<$Res>
    implements $MembershipCopyWith<$Res> {
  _$MembershipCopyWithImpl(this._self, this._then);

  final Membership _self;
  final $Res Function(Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tenantKey = null,Object? tenantName = null,Object? tenantId = null,Object? actorId = null,Object? handle = null,Object? role = null,Object? host = null,Object? icon = null,}) {
  return _then(Membership(
tenantKey: null == tenantKey ? _self.tenantKey : tenantKey // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as TenantIcon,
  ));
}

}


/// Adds pattern-matching-related methods to [Membership].
extension MembershipPatterns on Membership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Membership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Membership value)  $default,){
final _that = this;
switch (_that) {
case _Membership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Membership value)?  $default,){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tenantKey,  String tenantName,  String tenantId,  String actorId,  String handle,  String role,  String host,  TenantIcon icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.tenantKey,_that.tenantName,_that.tenantId,_that.actorId,_that.handle,_that.role,_that.host,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tenantKey,  String tenantName,  String tenantId,  String actorId,  String handle,  String role,  String host,  TenantIcon icon)  $default,) {final _that = this;
switch (_that) {
case _Membership():
return $default(_that.tenantKey,_that.tenantName,_that.tenantId,_that.actorId,_that.handle,_that.role,_that.host,_that.icon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tenantKey,  String tenantName,  String tenantId,  String actorId,  String handle,  String role,  String host,  TenantIcon icon)?  $default,) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.tenantKey,_that.tenantName,_that.tenantId,_that.actorId,_that.handle,_that.role,_that.host,_that.icon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Membership extends Membership {
  const _Membership({required this.tenantKey, this.tenantName = '', this.tenantId = '', this.actorId = '', this.handle = '', this.role = '', this.host = '', this.icon = const TenantIcon()}): super._();
  factory _Membership.fromJson(Map<String, dynamic> json) => _$MembershipFromJson(json);

@override final  String tenantKey;
@override@JsonKey() final  String tenantName;
@override@JsonKey() final  String tenantId;
@override@JsonKey() final  String actorId;
@override@JsonKey() final  String handle;
@override@JsonKey() final  String role;
@override@JsonKey() final  String host;
@override@JsonKey() final  TenantIcon icon;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipCopyWith<_Membership> get copyWith => __$MembershipCopyWithImpl<_Membership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Membership&&(identical(other.tenantKey, tenantKey) || other.tenantKey == tenantKey)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.role, role) || other.role == role)&&(identical(other.host, host) || other.host == host)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tenantKey,tenantName,tenantId,actorId,handle,role,host,icon);
}

@override
String toString() {
    return 'Membership(tenantKey: $tenantKey, tenantName: $tenantName, tenantId: $tenantId, actorId: $actorId, handle: $handle, role: $role, host: $host, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$MembershipCopyWith<$Res> implements $MembershipCopyWith<$Res> {
  factory _$MembershipCopyWith(_Membership value, $Res Function(_Membership) _then) = __$MembershipCopyWithImpl;
@override @useResult
$Res call({
 String tenantKey, String tenantName, String tenantId, String actorId, String handle, String role, String host, TenantIcon icon
});




}
/// @nodoc
class __$MembershipCopyWithImpl<$Res>
    implements _$MembershipCopyWith<$Res> {
  __$MembershipCopyWithImpl(this._self, this._then);

  final _Membership _self;
  final $Res Function(_Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tenantKey = null,Object? tenantName = null,Object? tenantId = null,Object? actorId = null,Object? handle = null,Object? role = null,Object? host = null,Object? icon = null,}) {
  return _then(_Membership(
tenantKey: null == tenantKey ? _self.tenantKey : tenantKey // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as TenantIcon,
  ));
}


}

// dart format on
