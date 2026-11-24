// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dav.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DavInfo {

 bool get enabled; String get path; String get url; String get username; bool get write; String get reason; List<String> get collections;
/// Create a copy of DavInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DavInfoCopyWith<DavInfo> get copyWith => _$DavInfoCopyWithImpl<DavInfo>(this as DavInfo, _$identity);

  /// Serializes this DavInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DavInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DavInfo&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.write, _this.write) || other.write == _this.write)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&const DeepCollectionEquality().equals(other.collections, _this.collections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DavInfo;
  return Object.hash(runtimeType,_this.enabled,_this.path,_this.url,_this.username,_this.write,_this.reason,const DeepCollectionEquality().hash(_this.collections));
}

@override
String toString() {
  final _this = this as DavInfo;
  return 'DavInfo(enabled: ${_this.enabled}, path: ${_this.path}, url: ${_this.url}, username: ${_this.username}, write: ${_this.write}, reason: ${_this.reason}, collections: ${_this.collections})';
}


}

/// @nodoc
abstract mixin class $DavInfoCopyWith<$Res>  {
  factory $DavInfoCopyWith(DavInfo value, $Res Function(DavInfo) _then) = _$DavInfoCopyWithImpl;
@useResult
$Res call({
 bool enabled, String path, String url, String username, bool write, String reason, List<String> collections
});




}
/// @nodoc
class _$DavInfoCopyWithImpl<$Res>
    implements $DavInfoCopyWith<$Res> {
  _$DavInfoCopyWithImpl(this._self, this._then);

  final DavInfo _self;
  final $Res Function(DavInfo) _then;

/// Create a copy of DavInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? path = null,Object? url = null,Object? username = null,Object? write = null,Object? reason = null,Object? collections = null,}) {
  return _then(DavInfo(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,write: null == write ? _self.write : write // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DavInfo].
extension DavInfoPatterns on DavInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DavInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DavInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DavInfo value)  $default,){
final _that = this;
switch (_that) {
case _DavInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DavInfo value)?  $default,){
final _that = this;
switch (_that) {
case _DavInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  String path,  String url,  String username,  bool write,  String reason,  List<String> collections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DavInfo() when $default != null:
return $default(_that.enabled,_that.path,_that.url,_that.username,_that.write,_that.reason,_that.collections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  String path,  String url,  String username,  bool write,  String reason,  List<String> collections)  $default,) {final _that = this;
switch (_that) {
case _DavInfo():
return $default(_that.enabled,_that.path,_that.url,_that.username,_that.write,_that.reason,_that.collections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  String path,  String url,  String username,  bool write,  String reason,  List<String> collections)?  $default,) {final _that = this;
switch (_that) {
case _DavInfo() when $default != null:
return $default(_that.enabled,_that.path,_that.url,_that.username,_that.write,_that.reason,_that.collections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DavInfo extends DavInfo {
  const _DavInfo({this.enabled = false, this.path = '', this.url = '', this.username = '', this.write = false, this.reason = '',  List<String> collections = const <String>[]}): _collections = collections,super._();
  factory _DavInfo.fromJson(Map<String, dynamic> json) => _$DavInfoFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  String path;
@override@JsonKey() final  String url;
@override@JsonKey() final  String username;
@override@JsonKey() final  bool write;
@override@JsonKey() final  String reason;
 final  List<String> _collections;
@override@JsonKey() List<String> get collections {
  if (_collections is EqualUnmodifiableListView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collections);
}


/// Create a copy of DavInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DavInfoCopyWith<_DavInfo> get copyWith => __$DavInfoCopyWithImpl<_DavInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DavInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DavInfo&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.path, path) || other.path == path)&&(identical(other.url, url) || other.url == url)&&(identical(other.username, username) || other.username == username)&&(identical(other.write, write) || other.write == write)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other.collections, _collections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,path,url,username,write,reason,const DeepCollectionEquality().hash(_collections));
}

@override
String toString() {
    return 'DavInfo(enabled: $enabled, path: $path, url: $url, username: $username, write: $write, reason: $reason, collections: $collections)';
}


}

/// @nodoc
abstract mixin class _$DavInfoCopyWith<$Res> implements $DavInfoCopyWith<$Res> {
  factory _$DavInfoCopyWith(_DavInfo value, $Res Function(_DavInfo) _then) = __$DavInfoCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, String path, String url, String username, bool write, String reason, List<String> collections
});




}
/// @nodoc
class __$DavInfoCopyWithImpl<$Res>
    implements _$DavInfoCopyWith<$Res> {
  __$DavInfoCopyWithImpl(this._self, this._then);

  final _DavInfo _self;
  final $Res Function(_DavInfo) _then;

/// Create a copy of DavInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? path = null,Object? url = null,Object? username = null,Object? write = null,Object? reason = null,Object? collections = null,}) {
  return _then(_DavInfo(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,write: null == write ? _self.write : write // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$DavPassword {

 String get id; String get name; String get actorId; String get collections; bool get readOnly; List<String> get scopes; DateTime? get createdAt; DateTime? get expiresAt; DateTime? get lastUsedAt; DateTime? get revokedAt;
/// Create a copy of DavPassword
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DavPasswordCopyWith<DavPassword> get copyWith => _$DavPasswordCopyWithImpl<DavPassword>(this as DavPassword, _$identity);

  /// Serializes this DavPassword to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DavPassword;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DavPassword&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.actorId, _this.actorId) || other.actorId == _this.actorId)&&(identical(other.collections, _this.collections) || other.collections == _this.collections)&&(identical(other.readOnly, _this.readOnly) || other.readOnly == _this.readOnly)&&const DeepCollectionEquality().equals(other.scopes, _this.scopes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.lastUsedAt, _this.lastUsedAt) || other.lastUsedAt == _this.lastUsedAt)&&(identical(other.revokedAt, _this.revokedAt) || other.revokedAt == _this.revokedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DavPassword;
  return Object.hash(runtimeType,_this.id,_this.name,_this.actorId,_this.collections,_this.readOnly,const DeepCollectionEquality().hash(_this.scopes),_this.createdAt,_this.expiresAt,_this.lastUsedAt,_this.revokedAt);
}

@override
String toString() {
  final _this = this as DavPassword;
  return 'DavPassword(id: ${_this.id}, name: ${_this.name}, actorId: ${_this.actorId}, collections: ${_this.collections}, readOnly: ${_this.readOnly}, scopes: ${_this.scopes}, createdAt: ${_this.createdAt}, expiresAt: ${_this.expiresAt}, lastUsedAt: ${_this.lastUsedAt}, revokedAt: ${_this.revokedAt})';
}


}

/// @nodoc
abstract mixin class $DavPasswordCopyWith<$Res>  {
  factory $DavPasswordCopyWith(DavPassword value, $Res Function(DavPassword) _then) = _$DavPasswordCopyWithImpl;
@useResult
$Res call({
 String id, String name, String actorId, String collections, bool readOnly, List<String> scopes, DateTime? createdAt, DateTime? expiresAt, DateTime? lastUsedAt, DateTime? revokedAt
});




}
/// @nodoc
class _$DavPasswordCopyWithImpl<$Res>
    implements $DavPasswordCopyWith<$Res> {
  _$DavPasswordCopyWithImpl(this._self, this._then);

  final DavPassword _self;
  final $Res Function(DavPassword) _then;

/// Create a copy of DavPassword
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? actorId = null,Object? collections = null,Object? readOnly = null,Object? scopes = null,Object? createdAt = freezed,Object? expiresAt = freezed,Object? lastUsedAt = freezed,Object? revokedAt = freezed,}) {
  return _then(DavPassword(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as String,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,scopes: null == scopes ? _self.scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DavPassword].
extension DavPasswordPatterns on DavPassword {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DavPassword value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DavPassword() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DavPassword value)  $default,){
final _that = this;
switch (_that) {
case _DavPassword():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DavPassword value)?  $default,){
final _that = this;
switch (_that) {
case _DavPassword() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String actorId,  String collections,  bool readOnly,  List<String> scopes,  DateTime? createdAt,  DateTime? expiresAt,  DateTime? lastUsedAt,  DateTime? revokedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DavPassword() when $default != null:
return $default(_that.id,_that.name,_that.actorId,_that.collections,_that.readOnly,_that.scopes,_that.createdAt,_that.expiresAt,_that.lastUsedAt,_that.revokedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String actorId,  String collections,  bool readOnly,  List<String> scopes,  DateTime? createdAt,  DateTime? expiresAt,  DateTime? lastUsedAt,  DateTime? revokedAt)  $default,) {final _that = this;
switch (_that) {
case _DavPassword():
return $default(_that.id,_that.name,_that.actorId,_that.collections,_that.readOnly,_that.scopes,_that.createdAt,_that.expiresAt,_that.lastUsedAt,_that.revokedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String actorId,  String collections,  bool readOnly,  List<String> scopes,  DateTime? createdAt,  DateTime? expiresAt,  DateTime? lastUsedAt,  DateTime? revokedAt)?  $default,) {final _that = this;
switch (_that) {
case _DavPassword() when $default != null:
return $default(_that.id,_that.name,_that.actorId,_that.collections,_that.readOnly,_that.scopes,_that.createdAt,_that.expiresAt,_that.lastUsedAt,_that.revokedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DavPassword implements DavPassword {
  const _DavPassword({required this.id, this.name = '', this.actorId = '', this.collections = DavCollections.assigned, this.readOnly = false,  List<String> scopes = const <String>[], this.createdAt, this.expiresAt, this.lastUsedAt, this.revokedAt}): _scopes = scopes;
  factory _DavPassword.fromJson(Map<String, dynamic> json) => _$DavPasswordFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String actorId;
@override@JsonKey() final  String collections;
@override@JsonKey() final  bool readOnly;
 final  List<String> _scopes;
@override@JsonKey() List<String> get scopes {
  if (_scopes is EqualUnmodifiableListView) return _scopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scopes);
}

@override final  DateTime? createdAt;
@override final  DateTime? expiresAt;
@override final  DateTime? lastUsedAt;
@override final  DateTime? revokedAt;

/// Create a copy of DavPassword
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DavPasswordCopyWith<_DavPassword> get copyWith => __$DavPasswordCopyWithImpl<_DavPassword>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DavPasswordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DavPassword&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.collections, collections) || other.collections == collections)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&const DeepCollectionEquality().equals(other.scopes, _scopes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,actorId,collections,readOnly,const DeepCollectionEquality().hash(_scopes),createdAt,expiresAt,lastUsedAt,revokedAt);
}

@override
String toString() {
    return 'DavPassword(id: $id, name: $name, actorId: $actorId, collections: $collections, readOnly: $readOnly, scopes: $scopes, createdAt: $createdAt, expiresAt: $expiresAt, lastUsedAt: $lastUsedAt, revokedAt: $revokedAt)';
}


}

/// @nodoc
abstract mixin class _$DavPasswordCopyWith<$Res> implements $DavPasswordCopyWith<$Res> {
  factory _$DavPasswordCopyWith(_DavPassword value, $Res Function(_DavPassword) _then) = __$DavPasswordCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String actorId, String collections, bool readOnly, List<String> scopes, DateTime? createdAt, DateTime? expiresAt, DateTime? lastUsedAt, DateTime? revokedAt
});




}
/// @nodoc
class __$DavPasswordCopyWithImpl<$Res>
    implements _$DavPasswordCopyWith<$Res> {
  __$DavPasswordCopyWithImpl(this._self, this._then);

  final _DavPassword _self;
  final $Res Function(_DavPassword) _then;

/// Create a copy of DavPassword
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? actorId = null,Object? collections = null,Object? readOnly = null,Object? scopes = null,Object? createdAt = freezed,Object? expiresAt = freezed,Object? lastUsedAt = freezed,Object? revokedAt = freezed,}) {
  return _then(_DavPassword(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as String,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,scopes: null == scopes ? _self._scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$IssuedDavPassword {

 String get id; String get password; String get name; String get username; String get url; String get path; String get collections; bool get readOnly; DateTime? get createdAt; DateTime? get expiresAt;
/// Create a copy of IssuedDavPassword
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssuedDavPasswordCopyWith<IssuedDavPassword> get copyWith => _$IssuedDavPasswordCopyWithImpl<IssuedDavPassword>(this as IssuedDavPassword, _$identity);

  /// Serializes this IssuedDavPassword to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IssuedDavPassword;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssuedDavPassword&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.collections, _this.collections) || other.collections == _this.collections)&&(identical(other.readOnly, _this.readOnly) || other.readOnly == _this.readOnly)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IssuedDavPassword;
  return Object.hash(runtimeType,_this.id,_this.password,_this.name,_this.username,_this.url,_this.path,_this.collections,_this.readOnly,_this.createdAt,_this.expiresAt);
}



}

/// @nodoc
abstract mixin class $IssuedDavPasswordCopyWith<$Res>  {
  factory $IssuedDavPasswordCopyWith(IssuedDavPassword value, $Res Function(IssuedDavPassword) _then) = _$IssuedDavPasswordCopyWithImpl;
@useResult
$Res call({
 String id, String password, String name, String username, String url, String path, String collections, bool readOnly, DateTime? createdAt, DateTime? expiresAt
});




}
/// @nodoc
class _$IssuedDavPasswordCopyWithImpl<$Res>
    implements $IssuedDavPasswordCopyWith<$Res> {
  _$IssuedDavPasswordCopyWithImpl(this._self, this._then);

  final IssuedDavPassword _self;
  final $Res Function(IssuedDavPassword) _then;

/// Create a copy of IssuedDavPassword
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? password = null,Object? name = null,Object? username = null,Object? url = null,Object? path = null,Object? collections = null,Object? readOnly = null,Object? createdAt = freezed,Object? expiresAt = freezed,}) {
  return _then(IssuedDavPassword(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as String,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [IssuedDavPassword].
extension IssuedDavPasswordPatterns on IssuedDavPassword {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssuedDavPassword value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssuedDavPassword() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssuedDavPassword value)  $default,){
final _that = this;
switch (_that) {
case _IssuedDavPassword():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssuedDavPassword value)?  $default,){
final _that = this;
switch (_that) {
case _IssuedDavPassword() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String password,  String name,  String username,  String url,  String path,  String collections,  bool readOnly,  DateTime? createdAt,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssuedDavPassword() when $default != null:
return $default(_that.id,_that.password,_that.name,_that.username,_that.url,_that.path,_that.collections,_that.readOnly,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String password,  String name,  String username,  String url,  String path,  String collections,  bool readOnly,  DateTime? createdAt,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _IssuedDavPassword():
return $default(_that.id,_that.password,_that.name,_that.username,_that.url,_that.path,_that.collections,_that.readOnly,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String password,  String name,  String username,  String url,  String path,  String collections,  bool readOnly,  DateTime? createdAt,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _IssuedDavPassword() when $default != null:
return $default(_that.id,_that.password,_that.name,_that.username,_that.url,_that.path,_that.collections,_that.readOnly,_that.createdAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssuedDavPassword extends IssuedDavPassword {
  const _IssuedDavPassword({required this.id, required this.password, this.name = '', this.username = '', this.url = '', this.path = '', this.collections = DavCollections.assigned, this.readOnly = false, this.createdAt, this.expiresAt}): super._();
  factory _IssuedDavPassword.fromJson(Map<String, dynamic> json) => _$IssuedDavPasswordFromJson(json);

@override final  String id;
@override final  String password;
@override@JsonKey() final  String name;
@override@JsonKey() final  String username;
@override@JsonKey() final  String url;
@override@JsonKey() final  String path;
@override@JsonKey() final  String collections;
@override@JsonKey() final  bool readOnly;
@override final  DateTime? createdAt;
@override final  DateTime? expiresAt;

/// Create a copy of IssuedDavPassword
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssuedDavPasswordCopyWith<_IssuedDavPassword> get copyWith => __$IssuedDavPasswordCopyWithImpl<_IssuedDavPassword>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssuedDavPasswordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssuedDavPassword&&(identical(other.id, id) || other.id == id)&&(identical(other.password, password) || other.password == password)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.url, url) || other.url == url)&&(identical(other.path, path) || other.path == path)&&(identical(other.collections, collections) || other.collections == collections)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,password,name,username,url,path,collections,readOnly,createdAt,expiresAt);
}



}

/// @nodoc
abstract mixin class _$IssuedDavPasswordCopyWith<$Res> implements $IssuedDavPasswordCopyWith<$Res> {
  factory _$IssuedDavPasswordCopyWith(_IssuedDavPassword value, $Res Function(_IssuedDavPassword) _then) = __$IssuedDavPasswordCopyWithImpl;
@override @useResult
$Res call({
 String id, String password, String name, String username, String url, String path, String collections, bool readOnly, DateTime? createdAt, DateTime? expiresAt
});




}
/// @nodoc
class __$IssuedDavPasswordCopyWithImpl<$Res>
    implements _$IssuedDavPasswordCopyWith<$Res> {
  __$IssuedDavPasswordCopyWithImpl(this._self, this._then);

  final _IssuedDavPassword _self;
  final $Res Function(_IssuedDavPassword) _then;

/// Create a copy of IssuedDavPassword
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? password = null,Object? name = null,Object? username = null,Object? url = null,Object? path = null,Object? collections = null,Object? readOnly = null,Object? createdAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_IssuedDavPassword(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as String,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CreateDavPasswordInput {

 String get name; String? get collections; bool? get readOnly; DateTime? get expiresAt;
/// Create a copy of CreateDavPasswordInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateDavPasswordInputCopyWith<CreateDavPasswordInput> get copyWith => _$CreateDavPasswordInputCopyWithImpl<CreateDavPasswordInput>(this as CreateDavPasswordInput, _$identity);

  /// Serializes this CreateDavPasswordInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateDavPasswordInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateDavPasswordInput&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.collections, _this.collections) || other.collections == _this.collections)&&(identical(other.readOnly, _this.readOnly) || other.readOnly == _this.readOnly)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateDavPasswordInput;
  return Object.hash(runtimeType,_this.name,_this.collections,_this.readOnly,_this.expiresAt);
}

@override
String toString() {
  final _this = this as CreateDavPasswordInput;
  return 'CreateDavPasswordInput(name: ${_this.name}, collections: ${_this.collections}, readOnly: ${_this.readOnly}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $CreateDavPasswordInputCopyWith<$Res>  {
  factory $CreateDavPasswordInputCopyWith(CreateDavPasswordInput value, $Res Function(CreateDavPasswordInput) _then) = _$CreateDavPasswordInputCopyWithImpl;
@useResult
$Res call({
 String name, String? collections, bool? readOnly, DateTime? expiresAt
});




}
/// @nodoc
class _$CreateDavPasswordInputCopyWithImpl<$Res>
    implements $CreateDavPasswordInputCopyWith<$Res> {
  _$CreateDavPasswordInputCopyWithImpl(this._self, this._then);

  final CreateDavPasswordInput _self;
  final $Res Function(CreateDavPasswordInput) _then;

/// Create a copy of CreateDavPasswordInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? collections = freezed,Object? readOnly = freezed,Object? expiresAt = freezed,}) {
  return _then(CreateDavPasswordInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,collections: freezed == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as String?,readOnly: freezed == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateDavPasswordInput].
extension CreateDavPasswordInputPatterns on CreateDavPasswordInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateDavPasswordInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateDavPasswordInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateDavPasswordInput value)  $default,){
final _that = this;
switch (_that) {
case _CreateDavPasswordInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateDavPasswordInput value)?  $default,){
final _that = this;
switch (_that) {
case _CreateDavPasswordInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? collections,  bool? readOnly,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateDavPasswordInput() when $default != null:
return $default(_that.name,_that.collections,_that.readOnly,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? collections,  bool? readOnly,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _CreateDavPasswordInput():
return $default(_that.name,_that.collections,_that.readOnly,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? collections,  bool? readOnly,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _CreateDavPasswordInput() when $default != null:
return $default(_that.name,_that.collections,_that.readOnly,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateDavPasswordInput implements CreateDavPasswordInput {
  const _CreateDavPasswordInput({required this.name, this.collections, this.readOnly, this.expiresAt});
  factory _CreateDavPasswordInput.fromJson(Map<String, dynamic> json) => _$CreateDavPasswordInputFromJson(json);

@override final  String name;
@override final  String? collections;
@override final  bool? readOnly;
@override final  DateTime? expiresAt;

/// Create a copy of CreateDavPasswordInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateDavPasswordInputCopyWith<_CreateDavPasswordInput> get copyWith => __$CreateDavPasswordInputCopyWithImpl<_CreateDavPasswordInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateDavPasswordInputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateDavPasswordInput&&(identical(other.name, name) || other.name == name)&&(identical(other.collections, collections) || other.collections == collections)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,collections,readOnly,expiresAt);
}

@override
String toString() {
    return 'CreateDavPasswordInput(name: $name, collections: $collections, readOnly: $readOnly, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$CreateDavPasswordInputCopyWith<$Res> implements $CreateDavPasswordInputCopyWith<$Res> {
  factory _$CreateDavPasswordInputCopyWith(_CreateDavPasswordInput value, $Res Function(_CreateDavPasswordInput) _then) = __$CreateDavPasswordInputCopyWithImpl;
@override @useResult
$Res call({
 String name, String? collections, bool? readOnly, DateTime? expiresAt
});




}
/// @nodoc
class __$CreateDavPasswordInputCopyWithImpl<$Res>
    implements _$CreateDavPasswordInputCopyWith<$Res> {
  __$CreateDavPasswordInputCopyWithImpl(this._self, this._then);

  final _CreateDavPasswordInput _self;
  final $Res Function(_CreateDavPasswordInput) _then;

/// Create a copy of CreateDavPasswordInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? collections = freezed,Object? readOnly = freezed,Object? expiresAt = freezed,}) {
  return _then(_CreateDavPasswordInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,collections: freezed == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as String?,readOnly: freezed == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
