// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReactionSummary {

@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) Reaction? get reaction; String get emoji; int get count; bool get reacted; List<String> get actorIds;
/// Create a copy of ReactionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReactionSummaryCopyWith<ReactionSummary> get copyWith => _$ReactionSummaryCopyWithImpl<ReactionSummary>(this as ReactionSummary, _$identity);

  /// Serializes this ReactionSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReactionSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReactionSummary&&(identical(other.reaction, _this.reaction) || other.reaction == _this.reaction)&&(identical(other.emoji, _this.emoji) || other.emoji == _this.emoji)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.reacted, _this.reacted) || other.reacted == _this.reacted)&&const DeepCollectionEquality().equals(other.actorIds, _this.actorIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReactionSummary;
  return Object.hash(runtimeType,_this.reaction,_this.emoji,_this.count,_this.reacted,const DeepCollectionEquality().hash(_this.actorIds));
}

@override
String toString() {
  final _this = this as ReactionSummary;
  return 'ReactionSummary(reaction: ${_this.reaction}, emoji: ${_this.emoji}, count: ${_this.count}, reacted: ${_this.reacted}, actorIds: ${_this.actorIds})';
}


}

/// @nodoc
abstract mixin class $ReactionSummaryCopyWith<$Res>  {
  factory $ReactionSummaryCopyWith(ReactionSummary value, $Res Function(ReactionSummary) _then) = _$ReactionSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) Reaction? reaction, String emoji, int count, bool reacted, List<String> actorIds
});




}
/// @nodoc
class _$ReactionSummaryCopyWithImpl<$Res>
    implements $ReactionSummaryCopyWith<$Res> {
  _$ReactionSummaryCopyWithImpl(this._self, this._then);

  final ReactionSummary _self;
  final $Res Function(ReactionSummary) _then;

/// Create a copy of ReactionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reaction = freezed,Object? emoji = null,Object? count = null,Object? reacted = null,Object? actorIds = null,}) {
  return _then(ReactionSummary(
reaction: freezed == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as Reaction?,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,reacted: null == reacted ? _self.reacted : reacted // ignore: cast_nullable_to_non_nullable
as bool,actorIds: null == actorIds ? _self.actorIds : actorIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReactionSummary].
extension ReactionSummaryPatterns on ReactionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReactionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReactionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReactionSummary value)  $default,){
final _that = this;
switch (_that) {
case _ReactionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReactionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ReactionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  Reaction? reaction,  String emoji,  int count,  bool reacted,  List<String> actorIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReactionSummary() when $default != null:
return $default(_that.reaction,_that.emoji,_that.count,_that.reacted,_that.actorIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  Reaction? reaction,  String emoji,  int count,  bool reacted,  List<String> actorIds)  $default,) {final _that = this;
switch (_that) {
case _ReactionSummary():
return $default(_that.reaction,_that.emoji,_that.count,_that.reacted,_that.actorIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  Reaction? reaction,  String emoji,  int count,  bool reacted,  List<String> actorIds)?  $default,) {final _that = this;
switch (_that) {
case _ReactionSummary() when $default != null:
return $default(_that.reaction,_that.emoji,_that.count,_that.reacted,_that.actorIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReactionSummary implements ReactionSummary {
  const _ReactionSummary({@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.reaction, this.emoji = '', this.count = 0, this.reacted = false,  List<String> actorIds = const <String>[]}): _actorIds = actorIds;
  factory _ReactionSummary.fromJson(Map<String, dynamic> json) => _$ReactionSummaryFromJson(json);

@override@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) final  Reaction? reaction;
@override@JsonKey() final  String emoji;
@override@JsonKey() final  int count;
@override@JsonKey() final  bool reacted;
 final  List<String> _actorIds;
@override@JsonKey() List<String> get actorIds {
  if (_actorIds is EqualUnmodifiableListView) return _actorIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actorIds);
}


/// Create a copy of ReactionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReactionSummaryCopyWith<_ReactionSummary> get copyWith => __$ReactionSummaryCopyWithImpl<_ReactionSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReactionSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReactionSummary&&(identical(other.reaction, reaction) || other.reaction == reaction)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.count, count) || other.count == count)&&(identical(other.reacted, reacted) || other.reacted == reacted)&&const DeepCollectionEquality().equals(other.actorIds, _actorIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reaction,emoji,count,reacted,const DeepCollectionEquality().hash(_actorIds));
}

@override
String toString() {
    return 'ReactionSummary(reaction: $reaction, emoji: $emoji, count: $count, reacted: $reacted, actorIds: $actorIds)';
}


}

/// @nodoc
abstract mixin class _$ReactionSummaryCopyWith<$Res> implements $ReactionSummaryCopyWith<$Res> {
  factory _$ReactionSummaryCopyWith(_ReactionSummary value, $Res Function(_ReactionSummary) _then) = __$ReactionSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) Reaction? reaction, String emoji, int count, bool reacted, List<String> actorIds
});




}
/// @nodoc
class __$ReactionSummaryCopyWithImpl<$Res>
    implements _$ReactionSummaryCopyWith<$Res> {
  __$ReactionSummaryCopyWithImpl(this._self, this._then);

  final _ReactionSummary _self;
  final $Res Function(_ReactionSummary) _then;

/// Create a copy of ReactionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reaction = freezed,Object? emoji = null,Object? count = null,Object? reacted = null,Object? actorIds = null,}) {
  return _then(_ReactionSummary(
reaction: freezed == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as Reaction?,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,reacted: null == reacted ? _self.reacted : reacted // ignore: cast_nullable_to_non_nullable
as bool,actorIds: null == actorIds ? _self._actorIds : actorIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
