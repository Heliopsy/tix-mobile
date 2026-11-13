// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Connection {

 String get id; String get instanceId; ConnectionKind get kind; DateTime get createdAt; String get label; String get handle; String get email; String get tenantKey; String get tenantName; TenantIcon get tenantIcon; bool get pinned; List<Membership> get memberships; DateTime? get lastUsedAt;
/// Create a copy of Connection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionCopyWith<Connection> get copyWith => _$ConnectionCopyWithImpl<Connection>(this as Connection, _$identity);

  /// Serializes this Connection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Connection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Connection&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.instanceId, _this.instanceId) || other.instanceId == _this.instanceId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.handle, _this.handle) || other.handle == _this.handle)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.tenantKey, _this.tenantKey) || other.tenantKey == _this.tenantKey)&&(identical(other.tenantName, _this.tenantName) || other.tenantName == _this.tenantName)&&(identical(other.tenantIcon, _this.tenantIcon) || other.tenantIcon == _this.tenantIcon)&&(identical(other.pinned, _this.pinned) || other.pinned == _this.pinned)&&const DeepCollectionEquality().equals(other.memberships, _this.memberships)&&(identical(other.lastUsedAt, _this.lastUsedAt) || other.lastUsedAt == _this.lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Connection;
  return Object.hash(runtimeType,_this.id,_this.instanceId,_this.kind,_this.createdAt,_this.label,_this.handle,_this.email,_this.tenantKey,_this.tenantName,_this.tenantIcon,_this.pinned,const DeepCollectionEquality().hash(_this.memberships),_this.lastUsedAt);
}

@override
String toString() {
  final _this = this as Connection;
  return 'Connection(id: ${_this.id}, instanceId: ${_this.instanceId}, kind: ${_this.kind}, createdAt: ${_this.createdAt}, label: ${_this.label}, handle: ${_this.handle}, email: ${_this.email}, tenantKey: ${_this.tenantKey}, tenantName: ${_this.tenantName}, tenantIcon: ${_this.tenantIcon}, pinned: ${_this.pinned}, memberships: ${_this.memberships}, lastUsedAt: ${_this.lastUsedAt})';
}


}

/// @nodoc
abstract mixin class $ConnectionCopyWith<$Res>  {
  factory $ConnectionCopyWith(Connection value, $Res Function(Connection) _then) = _$ConnectionCopyWithImpl;
@useResult
$Res call({
 String id, String instanceId, ConnectionKind kind, DateTime createdAt, String label, String handle, String email, String tenantKey, String tenantName, TenantIcon tenantIcon, bool pinned, List<Membership> memberships, DateTime? lastUsedAt
});




}
/// @nodoc
class _$ConnectionCopyWithImpl<$Res>
    implements $ConnectionCopyWith<$Res> {
  _$ConnectionCopyWithImpl(this._self, this._then);

  final Connection _self;
  final $Res Function(Connection) _then;

/// Create a copy of Connection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? instanceId = null,Object? kind = null,Object? createdAt = null,Object? label = null,Object? handle = null,Object? email = null,Object? tenantKey = null,Object? tenantName = null,Object? tenantIcon = null,Object? pinned = null,Object? memberships = null,Object? lastUsedAt = freezed,}) {
  return _then(Connection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,instanceId: null == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConnectionKind,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,tenantKey: null == tenantKey ? _self.tenantKey : tenantKey // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,tenantIcon: null == tenantIcon ? _self.tenantIcon : tenantIcon // ignore: cast_nullable_to_non_nullable
as TenantIcon,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,memberships: null == memberships ? _self.memberships : memberships // ignore: cast_nullable_to_non_nullable
as List<Membership>,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Connection].
extension ConnectionPatterns on Connection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Connection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Connection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Connection value)  $default,){
final _that = this;
switch (_that) {
case _Connection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Connection value)?  $default,){
final _that = this;
switch (_that) {
case _Connection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String instanceId,  ConnectionKind kind,  DateTime createdAt,  String label,  String handle,  String email,  String tenantKey,  String tenantName,  TenantIcon tenantIcon,  bool pinned,  List<Membership> memberships,  DateTime? lastUsedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Connection() when $default != null:
return $default(_that.id,_that.instanceId,_that.kind,_that.createdAt,_that.label,_that.handle,_that.email,_that.tenantKey,_that.tenantName,_that.tenantIcon,_that.pinned,_that.memberships,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String instanceId,  ConnectionKind kind,  DateTime createdAt,  String label,  String handle,  String email,  String tenantKey,  String tenantName,  TenantIcon tenantIcon,  bool pinned,  List<Membership> memberships,  DateTime? lastUsedAt)  $default,) {final _that = this;
switch (_that) {
case _Connection():
return $default(_that.id,_that.instanceId,_that.kind,_that.createdAt,_that.label,_that.handle,_that.email,_that.tenantKey,_that.tenantName,_that.tenantIcon,_that.pinned,_that.memberships,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String instanceId,  ConnectionKind kind,  DateTime createdAt,  String label,  String handle,  String email,  String tenantKey,  String tenantName,  TenantIcon tenantIcon,  bool pinned,  List<Membership> memberships,  DateTime? lastUsedAt)?  $default,) {final _that = this;
switch (_that) {
case _Connection() when $default != null:
return $default(_that.id,_that.instanceId,_that.kind,_that.createdAt,_that.label,_that.handle,_that.email,_that.tenantKey,_that.tenantName,_that.tenantIcon,_that.pinned,_that.memberships,_that.lastUsedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Connection extends Connection {
  const _Connection({required this.id, required this.instanceId, required this.kind, required this.createdAt, this.label = '', this.handle = '', this.email = '', this.tenantKey = '', this.tenantName = '', this.tenantIcon = const TenantIcon(), this.pinned = true,  List<Membership> memberships = const <Membership>[], this.lastUsedAt}): _memberships = memberships,super._();
  factory _Connection.fromJson(Map<String, dynamic> json) => _$ConnectionFromJson(json);

@override final  String id;
@override final  String instanceId;
@override final  ConnectionKind kind;
@override final  DateTime createdAt;
@override@JsonKey() final  String label;
@override@JsonKey() final  String handle;
@override@JsonKey() final  String email;
@override@JsonKey() final  String tenantKey;
@override@JsonKey() final  String tenantName;
@override@JsonKey() final  TenantIcon tenantIcon;
@override@JsonKey() final  bool pinned;
 final  List<Membership> _memberships;
@override@JsonKey() List<Membership> get memberships {
  if (_memberships is EqualUnmodifiableListView) return _memberships;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberships);
}

@override final  DateTime? lastUsedAt;

/// Create a copy of Connection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionCopyWith<_Connection> get copyWith => __$ConnectionCopyWithImpl<_Connection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Connection&&(identical(other.id, id) || other.id == id)&&(identical(other.instanceId, instanceId) || other.instanceId == instanceId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.label, label) || other.label == label)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.email, email) || other.email == email)&&(identical(other.tenantKey, tenantKey) || other.tenantKey == tenantKey)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.tenantIcon, tenantIcon) || other.tenantIcon == tenantIcon)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&const DeepCollectionEquality().equals(other.memberships, _memberships)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,instanceId,kind,createdAt,label,handle,email,tenantKey,tenantName,tenantIcon,pinned,const DeepCollectionEquality().hash(_memberships),lastUsedAt);
}

@override
String toString() {
    return 'Connection(id: $id, instanceId: $instanceId, kind: $kind, createdAt: $createdAt, label: $label, handle: $handle, email: $email, tenantKey: $tenantKey, tenantName: $tenantName, tenantIcon: $tenantIcon, pinned: $pinned, memberships: $memberships, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class _$ConnectionCopyWith<$Res> implements $ConnectionCopyWith<$Res> {
  factory _$ConnectionCopyWith(_Connection value, $Res Function(_Connection) _then) = __$ConnectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String instanceId, ConnectionKind kind, DateTime createdAt, String label, String handle, String email, String tenantKey, String tenantName, TenantIcon tenantIcon, bool pinned, List<Membership> memberships, DateTime? lastUsedAt
});




}
/// @nodoc
class __$ConnectionCopyWithImpl<$Res>
    implements _$ConnectionCopyWith<$Res> {
  __$ConnectionCopyWithImpl(this._self, this._then);

  final _Connection _self;
  final $Res Function(_Connection) _then;

/// Create a copy of Connection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? instanceId = null,Object? kind = null,Object? createdAt = null,Object? label = null,Object? handle = null,Object? email = null,Object? tenantKey = null,Object? tenantName = null,Object? tenantIcon = null,Object? pinned = null,Object? memberships = null,Object? lastUsedAt = freezed,}) {
  return _then(_Connection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,instanceId: null == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConnectionKind,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,tenantKey: null == tenantKey ? _self.tenantKey : tenantKey // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,tenantIcon: null == tenantIcon ? _self.tenantIcon : tenantIcon // ignore: cast_nullable_to_non_nullable
as TenantIcon,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,memberships: null == memberships ? _self._memberships : memberships // ignore: cast_nullable_to_non_nullable
as List<Membership>,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ContextRef {

 String get connectionId; String get tenantKey;
/// Create a copy of ContextRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContextRefCopyWith<ContextRef> get copyWith => _$ContextRefCopyWithImpl<ContextRef>(this as ContextRef, _$identity);

  /// Serializes this ContextRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContextRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContextRef&&(identical(other.connectionId, _this.connectionId) || other.connectionId == _this.connectionId)&&(identical(other.tenantKey, _this.tenantKey) || other.tenantKey == _this.tenantKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContextRef;
  return Object.hash(runtimeType,_this.connectionId,_this.tenantKey);
}

@override
String toString() {
  final _this = this as ContextRef;
  return 'ContextRef(connectionId: ${_this.connectionId}, tenantKey: ${_this.tenantKey})';
}


}

/// @nodoc
abstract mixin class $ContextRefCopyWith<$Res>  {
  factory $ContextRefCopyWith(ContextRef value, $Res Function(ContextRef) _then) = _$ContextRefCopyWithImpl;
@useResult
$Res call({
 String connectionId, String tenantKey
});




}
/// @nodoc
class _$ContextRefCopyWithImpl<$Res>
    implements $ContextRefCopyWith<$Res> {
  _$ContextRefCopyWithImpl(this._self, this._then);

  final ContextRef _self;
  final $Res Function(ContextRef) _then;

/// Create a copy of ContextRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? connectionId = null,Object? tenantKey = null,}) {
  return _then(ContextRef(
connectionId: null == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as String,tenantKey: null == tenantKey ? _self.tenantKey : tenantKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ContextRef].
extension ContextRefPatterns on ContextRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContextRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContextRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContextRef value)  $default,){
final _that = this;
switch (_that) {
case _ContextRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContextRef value)?  $default,){
final _that = this;
switch (_that) {
case _ContextRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String connectionId,  String tenantKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContextRef() when $default != null:
return $default(_that.connectionId,_that.tenantKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String connectionId,  String tenantKey)  $default,) {final _that = this;
switch (_that) {
case _ContextRef():
return $default(_that.connectionId,_that.tenantKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String connectionId,  String tenantKey)?  $default,) {final _that = this;
switch (_that) {
case _ContextRef() when $default != null:
return $default(_that.connectionId,_that.tenantKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContextRef implements ContextRef {
  const _ContextRef({required this.connectionId, this.tenantKey = ''});
  factory _ContextRef.fromJson(Map<String, dynamic> json) => _$ContextRefFromJson(json);

@override final  String connectionId;
@override@JsonKey() final  String tenantKey;

/// Create a copy of ContextRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContextRefCopyWith<_ContextRef> get copyWith => __$ContextRefCopyWithImpl<_ContextRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContextRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContextRef&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId)&&(identical(other.tenantKey, tenantKey) || other.tenantKey == tenantKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,connectionId,tenantKey);
}

@override
String toString() {
    return 'ContextRef(connectionId: $connectionId, tenantKey: $tenantKey)';
}


}

/// @nodoc
abstract mixin class _$ContextRefCopyWith<$Res> implements $ContextRefCopyWith<$Res> {
  factory _$ContextRefCopyWith(_ContextRef value, $Res Function(_ContextRef) _then) = __$ContextRefCopyWithImpl;
@override @useResult
$Res call({
 String connectionId, String tenantKey
});




}
/// @nodoc
class __$ContextRefCopyWithImpl<$Res>
    implements _$ContextRefCopyWith<$Res> {
  __$ContextRefCopyWithImpl(this._self, this._then);

  final _ContextRef _self;
  final $Res Function(_ContextRef) _then;

/// Create a copy of ContextRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? connectionId = null,Object? tenantKey = null,}) {
  return _then(_ContextRef(
connectionId: null == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as String,tenantKey: null == tenantKey ? _self.tenantKey : tenantKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
