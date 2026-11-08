// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'instance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Instance {

 String get id; String get name; InstanceKind get kind; DateTime get createdAt; String get baseUrl; String get dbPath; bool get inPlace; String get bookmark; DateTime? get lastUsedAt;
/// Create a copy of Instance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstanceCopyWith<Instance> get copyWith => _$InstanceCopyWithImpl<Instance>(this as Instance, _$identity);

  /// Serializes this Instance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Instance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Instance&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.baseUrl, _this.baseUrl) || other.baseUrl == _this.baseUrl)&&(identical(other.dbPath, _this.dbPath) || other.dbPath == _this.dbPath)&&(identical(other.inPlace, _this.inPlace) || other.inPlace == _this.inPlace)&&(identical(other.bookmark, _this.bookmark) || other.bookmark == _this.bookmark)&&(identical(other.lastUsedAt, _this.lastUsedAt) || other.lastUsedAt == _this.lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Instance;
  return Object.hash(runtimeType,_this.id,_this.name,_this.kind,_this.createdAt,_this.baseUrl,_this.dbPath,_this.inPlace,_this.bookmark,_this.lastUsedAt);
}

@override
String toString() {
  final _this = this as Instance;
  return 'Instance(id: ${_this.id}, name: ${_this.name}, kind: ${_this.kind}, createdAt: ${_this.createdAt}, baseUrl: ${_this.baseUrl}, dbPath: ${_this.dbPath}, inPlace: ${_this.inPlace}, bookmark: ${_this.bookmark}, lastUsedAt: ${_this.lastUsedAt})';
}


}

/// @nodoc
abstract mixin class $InstanceCopyWith<$Res>  {
  factory $InstanceCopyWith(Instance value, $Res Function(Instance) _then) = _$InstanceCopyWithImpl;
@useResult
$Res call({
 String id, String name, InstanceKind kind, DateTime createdAt, String baseUrl, String dbPath, bool inPlace, String bookmark, DateTime? lastUsedAt
});




}
/// @nodoc
class _$InstanceCopyWithImpl<$Res>
    implements $InstanceCopyWith<$Res> {
  _$InstanceCopyWithImpl(this._self, this._then);

  final Instance _self;
  final $Res Function(Instance) _then;

/// Create a copy of Instance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? createdAt = null,Object? baseUrl = null,Object? dbPath = null,Object? inPlace = null,Object? bookmark = null,Object? lastUsedAt = freezed,}) {
  return _then(Instance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as InstanceKind,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,dbPath: null == dbPath ? _self.dbPath : dbPath // ignore: cast_nullable_to_non_nullable
as String,inPlace: null == inPlace ? _self.inPlace : inPlace // ignore: cast_nullable_to_non_nullable
as bool,bookmark: null == bookmark ? _self.bookmark : bookmark // ignore: cast_nullable_to_non_nullable
as String,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Instance].
extension InstancePatterns on Instance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Instance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Instance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Instance value)  $default,){
final _that = this;
switch (_that) {
case _Instance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Instance value)?  $default,){
final _that = this;
switch (_that) {
case _Instance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  InstanceKind kind,  DateTime createdAt,  String baseUrl,  String dbPath,  bool inPlace,  String bookmark,  DateTime? lastUsedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Instance() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.createdAt,_that.baseUrl,_that.dbPath,_that.inPlace,_that.bookmark,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  InstanceKind kind,  DateTime createdAt,  String baseUrl,  String dbPath,  bool inPlace,  String bookmark,  DateTime? lastUsedAt)  $default,) {final _that = this;
switch (_that) {
case _Instance():
return $default(_that.id,_that.name,_that.kind,_that.createdAt,_that.baseUrl,_that.dbPath,_that.inPlace,_that.bookmark,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  InstanceKind kind,  DateTime createdAt,  String baseUrl,  String dbPath,  bool inPlace,  String bookmark,  DateTime? lastUsedAt)?  $default,) {final _that = this;
switch (_that) {
case _Instance() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.createdAt,_that.baseUrl,_that.dbPath,_that.inPlace,_that.bookmark,_that.lastUsedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Instance extends Instance {
  const _Instance({required this.id, required this.name, required this.kind, required this.createdAt, this.baseUrl = '', this.dbPath = '', this.inPlace = false, this.bookmark = '', this.lastUsedAt}): super._();
  factory _Instance.fromJson(Map<String, dynamic> json) => _$InstanceFromJson(json);

@override final  String id;
@override final  String name;
@override final  InstanceKind kind;
@override final  DateTime createdAt;
@override@JsonKey() final  String baseUrl;
@override@JsonKey() final  String dbPath;
@override@JsonKey() final  bool inPlace;
@override@JsonKey() final  String bookmark;
@override final  DateTime? lastUsedAt;

/// Create a copy of Instance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstanceCopyWith<_Instance> get copyWith => __$InstanceCopyWithImpl<_Instance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InstanceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Instance&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.dbPath, dbPath) || other.dbPath == dbPath)&&(identical(other.inPlace, inPlace) || other.inPlace == inPlace)&&(identical(other.bookmark, bookmark) || other.bookmark == bookmark)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,kind,createdAt,baseUrl,dbPath,inPlace,bookmark,lastUsedAt);
}

@override
String toString() {
    return 'Instance(id: $id, name: $name, kind: $kind, createdAt: $createdAt, baseUrl: $baseUrl, dbPath: $dbPath, inPlace: $inPlace, bookmark: $bookmark, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class _$InstanceCopyWith<$Res> implements $InstanceCopyWith<$Res> {
  factory _$InstanceCopyWith(_Instance value, $Res Function(_Instance) _then) = __$InstanceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, InstanceKind kind, DateTime createdAt, String baseUrl, String dbPath, bool inPlace, String bookmark, DateTime? lastUsedAt
});




}
/// @nodoc
class __$InstanceCopyWithImpl<$Res>
    implements _$InstanceCopyWith<$Res> {
  __$InstanceCopyWithImpl(this._self, this._then);

  final _Instance _self;
  final $Res Function(_Instance) _then;

/// Create a copy of Instance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? createdAt = null,Object? baseUrl = null,Object? dbPath = null,Object? inPlace = null,Object? bookmark = null,Object? lastUsedAt = freezed,}) {
  return _then(_Instance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as InstanceKind,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,dbPath: null == dbPath ? _self.dbPath : dbPath // ignore: cast_nullable_to_non_nullable
as String,inPlace: null == inPlace ? _self.inPlace : inPlace // ignore: cast_nullable_to_non_nullable
as bool,bookmark: null == bookmark ? _self.bookmark : bookmark // ignore: cast_nullable_to_non_nullable
as String,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
