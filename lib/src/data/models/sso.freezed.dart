// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sso.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SsoProviderOption {

 String get key; String get displayName; String get kind;
/// Create a copy of SsoProviderOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SsoProviderOptionCopyWith<SsoProviderOption> get copyWith => _$SsoProviderOptionCopyWithImpl<SsoProviderOption>(this as SsoProviderOption, _$identity);

  /// Serializes this SsoProviderOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SsoProviderOption;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SsoProviderOption&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.kind, _this.kind) || other.kind == _this.kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SsoProviderOption;
  return Object.hash(runtimeType,_this.key,_this.displayName,_this.kind);
}

@override
String toString() {
  final _this = this as SsoProviderOption;
  return 'SsoProviderOption(key: ${_this.key}, displayName: ${_this.displayName}, kind: ${_this.kind})';
}


}

/// @nodoc
abstract mixin class $SsoProviderOptionCopyWith<$Res>  {
  factory $SsoProviderOptionCopyWith(SsoProviderOption value, $Res Function(SsoProviderOption) _then) = _$SsoProviderOptionCopyWithImpl;
@useResult
$Res call({
 String key, String displayName, String kind
});




}
/// @nodoc
class _$SsoProviderOptionCopyWithImpl<$Res>
    implements $SsoProviderOptionCopyWith<$Res> {
  _$SsoProviderOptionCopyWithImpl(this._self, this._then);

  final SsoProviderOption _self;
  final $Res Function(SsoProviderOption) _then;

/// Create a copy of SsoProviderOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? displayName = null,Object? kind = null,}) {
  return _then(SsoProviderOption(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SsoProviderOption].
extension SsoProviderOptionPatterns on SsoProviderOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SsoProviderOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SsoProviderOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SsoProviderOption value)  $default,){
final _that = this;
switch (_that) {
case _SsoProviderOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SsoProviderOption value)?  $default,){
final _that = this;
switch (_that) {
case _SsoProviderOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String displayName,  String kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SsoProviderOption() when $default != null:
return $default(_that.key,_that.displayName,_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String displayName,  String kind)  $default,) {final _that = this;
switch (_that) {
case _SsoProviderOption():
return $default(_that.key,_that.displayName,_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String displayName,  String kind)?  $default,) {final _that = this;
switch (_that) {
case _SsoProviderOption() when $default != null:
return $default(_that.key,_that.displayName,_that.kind);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SsoProviderOption extends SsoProviderOption {
  const _SsoProviderOption({required this.key, this.displayName = '', this.kind = ''}): super._();
  factory _SsoProviderOption.fromJson(Map<String, dynamic> json) => _$SsoProviderOptionFromJson(json);

@override final  String key;
@override@JsonKey() final  String displayName;
@override@JsonKey() final  String kind;

/// Create a copy of SsoProviderOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SsoProviderOptionCopyWith<_SsoProviderOption> get copyWith => __$SsoProviderOptionCopyWithImpl<_SsoProviderOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SsoProviderOptionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SsoProviderOption&&(identical(other.key, key) || other.key == key)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,displayName,kind);
}

@override
String toString() {
    return 'SsoProviderOption(key: $key, displayName: $displayName, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$SsoProviderOptionCopyWith<$Res> implements $SsoProviderOptionCopyWith<$Res> {
  factory _$SsoProviderOptionCopyWith(_SsoProviderOption value, $Res Function(_SsoProviderOption) _then) = __$SsoProviderOptionCopyWithImpl;
@override @useResult
$Res call({
 String key, String displayName, String kind
});




}
/// @nodoc
class __$SsoProviderOptionCopyWithImpl<$Res>
    implements _$SsoProviderOptionCopyWith<$Res> {
  __$SsoProviderOptionCopyWithImpl(this._self, this._then);

  final _SsoProviderOption _self;
  final $Res Function(_SsoProviderOption) _then;

/// Create a copy of SsoProviderOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? displayName = null,Object? kind = null,}) {
  return _then(_SsoProviderOption(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SignInOptions {

 String get passwordLogin; List<SsoProviderOption> get providers; bool get appSignIn;
/// Create a copy of SignInOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignInOptionsCopyWith<SignInOptions> get copyWith => _$SignInOptionsCopyWithImpl<SignInOptions>(this as SignInOptions, _$identity);

  /// Serializes this SignInOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SignInOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignInOptions&&(identical(other.passwordLogin, _this.passwordLogin) || other.passwordLogin == _this.passwordLogin)&&const DeepCollectionEquality().equals(other.providers, _this.providers)&&(identical(other.appSignIn, _this.appSignIn) || other.appSignIn == _this.appSignIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SignInOptions;
  return Object.hash(runtimeType,_this.passwordLogin,const DeepCollectionEquality().hash(_this.providers),_this.appSignIn);
}

@override
String toString() {
  final _this = this as SignInOptions;
  return 'SignInOptions(passwordLogin: ${_this.passwordLogin}, providers: ${_this.providers}, appSignIn: ${_this.appSignIn})';
}


}

/// @nodoc
abstract mixin class $SignInOptionsCopyWith<$Res>  {
  factory $SignInOptionsCopyWith(SignInOptions value, $Res Function(SignInOptions) _then) = _$SignInOptionsCopyWithImpl;
@useResult
$Res call({
 String passwordLogin, List<SsoProviderOption> providers, bool appSignIn
});




}
/// @nodoc
class _$SignInOptionsCopyWithImpl<$Res>
    implements $SignInOptionsCopyWith<$Res> {
  _$SignInOptionsCopyWithImpl(this._self, this._then);

  final SignInOptions _self;
  final $Res Function(SignInOptions) _then;

/// Create a copy of SignInOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? passwordLogin = null,Object? providers = null,Object? appSignIn = null,}) {
  return _then(SignInOptions(
passwordLogin: null == passwordLogin ? _self.passwordLogin : passwordLogin // ignore: cast_nullable_to_non_nullable
as String,providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as List<SsoProviderOption>,appSignIn: null == appSignIn ? _self.appSignIn : appSignIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SignInOptions].
extension SignInOptionsPatterns on SignInOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignInOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignInOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignInOptions value)  $default,){
final _that = this;
switch (_that) {
case _SignInOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignInOptions value)?  $default,){
final _that = this;
switch (_that) {
case _SignInOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String passwordLogin,  List<SsoProviderOption> providers,  bool appSignIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignInOptions() when $default != null:
return $default(_that.passwordLogin,_that.providers,_that.appSignIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String passwordLogin,  List<SsoProviderOption> providers,  bool appSignIn)  $default,) {final _that = this;
switch (_that) {
case _SignInOptions():
return $default(_that.passwordLogin,_that.providers,_that.appSignIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String passwordLogin,  List<SsoProviderOption> providers,  bool appSignIn)?  $default,) {final _that = this;
switch (_that) {
case _SignInOptions() when $default != null:
return $default(_that.passwordLogin,_that.providers,_that.appSignIn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SignInOptions extends SignInOptions {
  const _SignInOptions({this.passwordLogin = 'allowed',  List<SsoProviderOption> providers = const <SsoProviderOption>[], this.appSignIn = false}): _providers = providers,super._();
  factory _SignInOptions.fromJson(Map<String, dynamic> json) => _$SignInOptionsFromJson(json);

@override@JsonKey() final  String passwordLogin;
 final  List<SsoProviderOption> _providers;
@override@JsonKey() List<SsoProviderOption> get providers {
  if (_providers is EqualUnmodifiableListView) return _providers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providers);
}

@override@JsonKey() final  bool appSignIn;

/// Create a copy of SignInOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignInOptionsCopyWith<_SignInOptions> get copyWith => __$SignInOptionsCopyWithImpl<_SignInOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SignInOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignInOptions&&(identical(other.passwordLogin, passwordLogin) || other.passwordLogin == passwordLogin)&&const DeepCollectionEquality().equals(other.providers, _providers)&&(identical(other.appSignIn, appSignIn) || other.appSignIn == appSignIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,passwordLogin,const DeepCollectionEquality().hash(_providers),appSignIn);
}

@override
String toString() {
    return 'SignInOptions(passwordLogin: $passwordLogin, providers: $providers, appSignIn: $appSignIn)';
}


}

/// @nodoc
abstract mixin class _$SignInOptionsCopyWith<$Res> implements $SignInOptionsCopyWith<$Res> {
  factory _$SignInOptionsCopyWith(_SignInOptions value, $Res Function(_SignInOptions) _then) = __$SignInOptionsCopyWithImpl;
@override @useResult
$Res call({
 String passwordLogin, List<SsoProviderOption> providers, bool appSignIn
});




}
/// @nodoc
class __$SignInOptionsCopyWithImpl<$Res>
    implements _$SignInOptionsCopyWith<$Res> {
  __$SignInOptionsCopyWithImpl(this._self, this._then);

  final _SignInOptions _self;
  final $Res Function(_SignInOptions) _then;

/// Create a copy of SignInOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? passwordLogin = null,Object? providers = null,Object? appSignIn = null,}) {
  return _then(_SignInOptions(
passwordLogin: null == passwordLogin ? _self.passwordLogin : passwordLogin // ignore: cast_nullable_to_non_nullable
as String,providers: null == providers ? _self._providers : providers // ignore: cast_nullable_to_non_nullable
as List<SsoProviderOption>,appSignIn: null == appSignIn ? _self.appSignIn : appSignIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SsoExchangeInput {

 String get code; String get codeVerifier;
/// Create a copy of SsoExchangeInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SsoExchangeInputCopyWith<SsoExchangeInput> get copyWith => _$SsoExchangeInputCopyWithImpl<SsoExchangeInput>(this as SsoExchangeInput, _$identity);

  /// Serializes this SsoExchangeInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SsoExchangeInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SsoExchangeInput&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.codeVerifier, _this.codeVerifier) || other.codeVerifier == _this.codeVerifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SsoExchangeInput;
  return Object.hash(runtimeType,_this.code,_this.codeVerifier);
}

@override
String toString() {
  final _this = this as SsoExchangeInput;
  return 'SsoExchangeInput(code: ${_this.code}, codeVerifier: ${_this.codeVerifier})';
}


}

/// @nodoc
abstract mixin class $SsoExchangeInputCopyWith<$Res>  {
  factory $SsoExchangeInputCopyWith(SsoExchangeInput value, $Res Function(SsoExchangeInput) _then) = _$SsoExchangeInputCopyWithImpl;
@useResult
$Res call({
 String code, String codeVerifier
});




}
/// @nodoc
class _$SsoExchangeInputCopyWithImpl<$Res>
    implements $SsoExchangeInputCopyWith<$Res> {
  _$SsoExchangeInputCopyWithImpl(this._self, this._then);

  final SsoExchangeInput _self;
  final $Res Function(SsoExchangeInput) _then;

/// Create a copy of SsoExchangeInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? codeVerifier = null,}) {
  return _then(SsoExchangeInput(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,codeVerifier: null == codeVerifier ? _self.codeVerifier : codeVerifier // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SsoExchangeInput].
extension SsoExchangeInputPatterns on SsoExchangeInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SsoExchangeInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SsoExchangeInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SsoExchangeInput value)  $default,){
final _that = this;
switch (_that) {
case _SsoExchangeInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SsoExchangeInput value)?  $default,){
final _that = this;
switch (_that) {
case _SsoExchangeInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String codeVerifier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SsoExchangeInput() when $default != null:
return $default(_that.code,_that.codeVerifier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String codeVerifier)  $default,) {final _that = this;
switch (_that) {
case _SsoExchangeInput():
return $default(_that.code,_that.codeVerifier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String codeVerifier)?  $default,) {final _that = this;
switch (_that) {
case _SsoExchangeInput() when $default != null:
return $default(_that.code,_that.codeVerifier);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SsoExchangeInput implements SsoExchangeInput {
  const _SsoExchangeInput({required this.code, required this.codeVerifier});
  factory _SsoExchangeInput.fromJson(Map<String, dynamic> json) => _$SsoExchangeInputFromJson(json);

@override final  String code;
@override final  String codeVerifier;

/// Create a copy of SsoExchangeInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SsoExchangeInputCopyWith<_SsoExchangeInput> get copyWith => __$SsoExchangeInputCopyWithImpl<_SsoExchangeInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SsoExchangeInputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SsoExchangeInput&&(identical(other.code, code) || other.code == code)&&(identical(other.codeVerifier, codeVerifier) || other.codeVerifier == codeVerifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,codeVerifier);
}

@override
String toString() {
    return 'SsoExchangeInput(code: $code, codeVerifier: $codeVerifier)';
}


}

/// @nodoc
abstract mixin class _$SsoExchangeInputCopyWith<$Res> implements $SsoExchangeInputCopyWith<$Res> {
  factory _$SsoExchangeInputCopyWith(_SsoExchangeInput value, $Res Function(_SsoExchangeInput) _then) = __$SsoExchangeInputCopyWithImpl;
@override @useResult
$Res call({
 String code, String codeVerifier
});




}
/// @nodoc
class __$SsoExchangeInputCopyWithImpl<$Res>
    implements _$SsoExchangeInputCopyWith<$Res> {
  __$SsoExchangeInputCopyWithImpl(this._self, this._then);

  final _SsoExchangeInput _self;
  final $Res Function(_SsoExchangeInput) _then;

/// Create a copy of SsoExchangeInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? codeVerifier = null,}) {
  return _then(_SsoExchangeInput(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,codeVerifier: null == codeVerifier ? _self.codeVerifier : codeVerifier // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
