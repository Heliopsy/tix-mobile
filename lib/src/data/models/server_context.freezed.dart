// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServerContext {

 String get id; String get name; String get baseUrl; String get handle;
/// Create a copy of ServerContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerContextCopyWith<ServerContext> get copyWith => _$ServerContextCopyWithImpl<ServerContext>(this as ServerContext, _$identity);

  /// Serializes this ServerContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ServerContext;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerContext&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.baseUrl, _this.baseUrl) || other.baseUrl == _this.baseUrl)&&(identical(other.handle, _this.handle) || other.handle == _this.handle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ServerContext;
  return Object.hash(runtimeType,_this.id,_this.name,_this.baseUrl,_this.handle);
}

@override
String toString() {
  final _this = this as ServerContext;
  return 'ServerContext(id: ${_this.id}, name: ${_this.name}, baseUrl: ${_this.baseUrl}, handle: ${_this.handle})';
}


}

/// @nodoc
abstract mixin class $ServerContextCopyWith<$Res>  {
  factory $ServerContextCopyWith(ServerContext value, $Res Function(ServerContext) _then) = _$ServerContextCopyWithImpl;
@useResult
$Res call({
 String id, String name, String baseUrl, String handle
});




}
/// @nodoc
class _$ServerContextCopyWithImpl<$Res>
    implements $ServerContextCopyWith<$Res> {
  _$ServerContextCopyWithImpl(this._self, this._then);

  final ServerContext _self;
  final $Res Function(ServerContext) _then;

/// Create a copy of ServerContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? baseUrl = null,Object? handle = null,}) {
  return _then(ServerContext(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerContext].
extension ServerContextPatterns on ServerContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerContext value)  $default,){
final _that = this;
switch (_that) {
case _ServerContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerContext value)?  $default,){
final _that = this;
switch (_that) {
case _ServerContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String baseUrl,  String handle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerContext() when $default != null:
return $default(_that.id,_that.name,_that.baseUrl,_that.handle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String baseUrl,  String handle)  $default,) {final _that = this;
switch (_that) {
case _ServerContext():
return $default(_that.id,_that.name,_that.baseUrl,_that.handle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String baseUrl,  String handle)?  $default,) {final _that = this;
switch (_that) {
case _ServerContext() when $default != null:
return $default(_that.id,_that.name,_that.baseUrl,_that.handle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServerContext implements ServerContext {
  const _ServerContext({required this.id, required this.name, required this.baseUrl, this.handle = ''});
  factory _ServerContext.fromJson(Map<String, dynamic> json) => _$ServerContextFromJson(json);

@override final  String id;
@override final  String name;
@override final  String baseUrl;
@override@JsonKey() final  String handle;

/// Create a copy of ServerContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerContextCopyWith<_ServerContext> get copyWith => __$ServerContextCopyWithImpl<_ServerContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServerContextToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerContext&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.handle, handle) || other.handle == handle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,baseUrl,handle);
}

@override
String toString() {
    return 'ServerContext(id: $id, name: $name, baseUrl: $baseUrl, handle: $handle)';
}


}

/// @nodoc
abstract mixin class _$ServerContextCopyWith<$Res> implements $ServerContextCopyWith<$Res> {
  factory _$ServerContextCopyWith(_ServerContext value, $Res Function(_ServerContext) _then) = __$ServerContextCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String baseUrl, String handle
});




}
/// @nodoc
class __$ServerContextCopyWithImpl<$Res>
    implements _$ServerContextCopyWith<$Res> {
  __$ServerContextCopyWithImpl(this._self, this._then);

  final _ServerContext _self;
  final $Res Function(_ServerContext) _then;

/// Create a copy of ServerContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? baseUrl = null,Object? handle = null,}) {
  return _then(_ServerContext(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
