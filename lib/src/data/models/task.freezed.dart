// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Task {

 String get id; String get ref; String get title; String get status; String get body; int get priority; String get projectId; String get assigneeActorId; List<String> get tags; bool get blocked; bool get starred; int get version; DateTime? get dueAt; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get completedAt;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Task;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.ref, _this.ref) || other.ref == _this.ref)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.projectId, _this.projectId) || other.projectId == _this.projectId)&&(identical(other.assigneeActorId, _this.assigneeActorId) || other.assigneeActorId == _this.assigneeActorId)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&(identical(other.blocked, _this.blocked) || other.blocked == _this.blocked)&&(identical(other.starred, _this.starred) || other.starred == _this.starred)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.dueAt, _this.dueAt) || other.dueAt == _this.dueAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Task;
  return Object.hash(runtimeType,_this.id,_this.ref,_this.title,_this.status,_this.body,_this.priority,_this.projectId,_this.assigneeActorId,const DeepCollectionEquality().hash(_this.tags),_this.blocked,_this.starred,_this.version,_this.dueAt,_this.createdAt,_this.updatedAt,_this.completedAt);
}

@override
String toString() {
  final _this = this as Task;
  return 'Task(id: ${_this.id}, ref: ${_this.ref}, title: ${_this.title}, status: ${_this.status}, body: ${_this.body}, priority: ${_this.priority}, projectId: ${_this.projectId}, assigneeActorId: ${_this.assigneeActorId}, tags: ${_this.tags}, blocked: ${_this.blocked}, starred: ${_this.starred}, version: ${_this.version}, dueAt: ${_this.dueAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, completedAt: ${_this.completedAt})';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 String id, String ref, String title, String status, String body, int priority, String projectId, String assigneeActorId, List<String> tags, bool blocked, bool starred, int version, DateTime? dueAt, DateTime? createdAt, DateTime? updatedAt, DateTime? completedAt
});




}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ref = null,Object? title = null,Object? status = null,Object? body = null,Object? priority = null,Object? projectId = null,Object? assigneeActorId = null,Object? tags = null,Object? blocked = null,Object? starred = null,Object? version = null,Object? dueAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? completedAt = freezed,}) {
  return _then(Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,assigneeActorId: null == assigneeActorId ? _self.assigneeActorId : assigneeActorId // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,blocked: null == blocked ? _self.blocked : blocked // ignore: cast_nullable_to_non_nullable
as bool,starred: null == starred ? _self.starred : starred // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ref,  String title,  String status,  String body,  int priority,  String projectId,  String assigneeActorId,  List<String> tags,  bool blocked,  bool starred,  int version,  DateTime? dueAt,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.ref,_that.title,_that.status,_that.body,_that.priority,_that.projectId,_that.assigneeActorId,_that.tags,_that.blocked,_that.starred,_that.version,_that.dueAt,_that.createdAt,_that.updatedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ref,  String title,  String status,  String body,  int priority,  String projectId,  String assigneeActorId,  List<String> tags,  bool blocked,  bool starred,  int version,  DateTime? dueAt,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.id,_that.ref,_that.title,_that.status,_that.body,_that.priority,_that.projectId,_that.assigneeActorId,_that.tags,_that.blocked,_that.starred,_that.version,_that.dueAt,_that.createdAt,_that.updatedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ref,  String title,  String status,  String body,  int priority,  String projectId,  String assigneeActorId,  List<String> tags,  bool blocked,  bool starred,  int version,  DateTime? dueAt,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.ref,_that.title,_that.status,_that.body,_that.priority,_that.projectId,_that.assigneeActorId,_that.tags,_that.blocked,_that.starred,_that.version,_that.dueAt,_that.createdAt,_that.updatedAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Task implements Task {
  const _Task({required this.id, required this.ref, required this.title, this.status = '', this.body = '', this.priority = 0, this.projectId = '', this.assigneeActorId = '',  List<String> tags = const <String>[], this.blocked = false, this.starred = false, this.version = 0, this.dueAt, this.createdAt, this.updatedAt, this.completedAt}): _tags = tags;
  factory _Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

@override final  String id;
@override final  String ref;
@override final  String title;
@override@JsonKey() final  String status;
@override@JsonKey() final  String body;
@override@JsonKey() final  int priority;
@override@JsonKey() final  String projectId;
@override@JsonKey() final  String assigneeActorId;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  bool blocked;
@override@JsonKey() final  bool starred;
@override@JsonKey() final  int version;
@override final  DateTime? dueAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? completedAt;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.body, body) || other.body == body)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.assigneeActorId, assigneeActorId) || other.assigneeActorId == assigneeActorId)&&const DeepCollectionEquality().equals(other.tags, _tags)&&(identical(other.blocked, blocked) || other.blocked == blocked)&&(identical(other.starred, starred) || other.starred == starred)&&(identical(other.version, version) || other.version == version)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,ref,title,status,body,priority,projectId,assigneeActorId,const DeepCollectionEquality().hash(_tags),blocked,starred,version,dueAt,createdAt,updatedAt,completedAt);
}

@override
String toString() {
    return 'Task(id: $id, ref: $ref, title: $title, status: $status, body: $body, priority: $priority, projectId: $projectId, assigneeActorId: $assigneeActorId, tags: $tags, blocked: $blocked, starred: $starred, version: $version, dueAt: $dueAt, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String ref, String title, String status, String body, int priority, String projectId, String assigneeActorId, List<String> tags, bool blocked, bool starred, int version, DateTime? dueAt, DateTime? createdAt, DateTime? updatedAt, DateTime? completedAt
});




}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ref = null,Object? title = null,Object? status = null,Object? body = null,Object? priority = null,Object? projectId = null,Object? assigneeActorId = null,Object? tags = null,Object? blocked = null,Object? starred = null,Object? version = null,Object? dueAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,assigneeActorId: null == assigneeActorId ? _self.assigneeActorId : assigneeActorId // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,blocked: null == blocked ? _self.blocked : blocked // ignore: cast_nullable_to_non_nullable
as bool,starred: null == starred ? _self.starred : starred // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CreateTaskRequest {

 String get title; String? get projectRef; bool get parse;
/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTaskRequestCopyWith<CreateTaskRequest> get copyWith => _$CreateTaskRequestCopyWithImpl<CreateTaskRequest>(this as CreateTaskRequest, _$identity);

  /// Serializes this CreateTaskRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateTaskRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTaskRequest&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.projectRef, _this.projectRef) || other.projectRef == _this.projectRef)&&(identical(other.parse, _this.parse) || other.parse == _this.parse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateTaskRequest;
  return Object.hash(runtimeType,_this.title,_this.projectRef,_this.parse);
}

@override
String toString() {
  final _this = this as CreateTaskRequest;
  return 'CreateTaskRequest(title: ${_this.title}, projectRef: ${_this.projectRef}, parse: ${_this.parse})';
}


}

/// @nodoc
abstract mixin class $CreateTaskRequestCopyWith<$Res>  {
  factory $CreateTaskRequestCopyWith(CreateTaskRequest value, $Res Function(CreateTaskRequest) _then) = _$CreateTaskRequestCopyWithImpl;
@useResult
$Res call({
 String title, String? projectRef, bool parse
});




}
/// @nodoc
class _$CreateTaskRequestCopyWithImpl<$Res>
    implements $CreateTaskRequestCopyWith<$Res> {
  _$CreateTaskRequestCopyWithImpl(this._self, this._then);

  final CreateTaskRequest _self;
  final $Res Function(CreateTaskRequest) _then;

/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? projectRef = freezed,Object? parse = null,}) {
  return _then(CreateTaskRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,projectRef: freezed == projectRef ? _self.projectRef : projectRef // ignore: cast_nullable_to_non_nullable
as String?,parse: null == parse ? _self.parse : parse // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateTaskRequest].
extension CreateTaskRequestPatterns on CreateTaskRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateTaskRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateTaskRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateTaskRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateTaskRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? projectRef,  bool parse)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
return $default(_that.title,_that.projectRef,_that.parse);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? projectRef,  bool parse)  $default,) {final _that = this;
switch (_that) {
case _CreateTaskRequest():
return $default(_that.title,_that.projectRef,_that.parse);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? projectRef,  bool parse)?  $default,) {final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
return $default(_that.title,_that.projectRef,_that.parse);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateTaskRequest implements CreateTaskRequest {
  const _CreateTaskRequest({required this.title, this.projectRef, this.parse = false});
  factory _CreateTaskRequest.fromJson(Map<String, dynamic> json) => _$CreateTaskRequestFromJson(json);

@override final  String title;
@override final  String? projectRef;
@override@JsonKey() final  bool parse;

/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateTaskRequestCopyWith<_CreateTaskRequest> get copyWith => __$CreateTaskRequestCopyWithImpl<_CreateTaskRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateTaskRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateTaskRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.projectRef, projectRef) || other.projectRef == projectRef)&&(identical(other.parse, parse) || other.parse == parse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,projectRef,parse);
}

@override
String toString() {
    return 'CreateTaskRequest(title: $title, projectRef: $projectRef, parse: $parse)';
}


}

/// @nodoc
abstract mixin class _$CreateTaskRequestCopyWith<$Res> implements $CreateTaskRequestCopyWith<$Res> {
  factory _$CreateTaskRequestCopyWith(_CreateTaskRequest value, $Res Function(_CreateTaskRequest) _then) = __$CreateTaskRequestCopyWithImpl;
@override @useResult
$Res call({
 String title, String? projectRef, bool parse
});




}
/// @nodoc
class __$CreateTaskRequestCopyWithImpl<$Res>
    implements _$CreateTaskRequestCopyWith<$Res> {
  __$CreateTaskRequestCopyWithImpl(this._self, this._then);

  final _CreateTaskRequest _self;
  final $Res Function(_CreateTaskRequest) _then;

/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? projectRef = freezed,Object? parse = null,}) {
  return _then(_CreateTaskRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,projectRef: freezed == projectRef ? _self.projectRef : projectRef // ignore: cast_nullable_to_non_nullable
as String?,parse: null == parse ? _self.parse : parse // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
