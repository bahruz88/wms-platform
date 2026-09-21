// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifications_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationDto {

 int get id; String get type; String get title; DateTime get createdAt; String? get body; bool get isRead; String? get docType; int? get docId; String? get deepLink;
/// Create a copy of NotificationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationDtoCopyWith<NotificationDto> get copyWith => _$NotificationDtoCopyWithImpl<NotificationDto>(this as NotificationDto, _$identity);

  /// Serializes this NotificationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.isRead, _this.isRead) || other.isRead == _this.isRead)&&(identical(other.docType, _this.docType) || other.docType == _this.docType)&&(identical(other.docId, _this.docId) || other.docId == _this.docId)&&(identical(other.deepLink, _this.deepLink) || other.deepLink == _this.deepLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationDto;
  return Object.hash(runtimeType,_this.id,_this.type,_this.title,_this.createdAt,_this.body,_this.isRead,_this.docType,_this.docId,_this.deepLink);
}

@override
String toString() {
  final _this = this as NotificationDto;
  return 'NotificationDto(id: ${_this.id}, type: ${_this.type}, title: ${_this.title}, createdAt: ${_this.createdAt}, body: ${_this.body}, isRead: ${_this.isRead}, docType: ${_this.docType}, docId: ${_this.docId}, deepLink: ${_this.deepLink})';
}


}

/// @nodoc
abstract mixin class $NotificationDtoCopyWith<$Res>  {
  factory $NotificationDtoCopyWith(NotificationDto value, $Res Function(NotificationDto) _then) = _$NotificationDtoCopyWithImpl;
@useResult
$Res call({
 int id, String type, String title, DateTime createdAt, String? body, bool isRead, String? docType, int? docId, String? deepLink
});




}
/// @nodoc
class _$NotificationDtoCopyWithImpl<$Res>
    implements $NotificationDtoCopyWith<$Res> {
  _$NotificationDtoCopyWithImpl(this._self, this._then);

  final NotificationDto _self;
  final $Res Function(NotificationDto) _then;

/// Create a copy of NotificationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = null,Object? createdAt = null,Object? body = freezed,Object? isRead = null,Object? docType = freezed,Object? docId = freezed,Object? deepLink = freezed,}) {
  return _then(NotificationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,docType: freezed == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as String?,docId: freezed == docId ? _self.docId : docId // ignore: cast_nullable_to_non_nullable
as int?,deepLink: freezed == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationDto].
extension NotificationDtoPatterns on NotificationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationDto value)  $default,){
final _that = this;
switch (_that) {
case _NotificationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationDto value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String type,  String title,  DateTime createdAt,  String? body,  bool isRead,  String? docType,  int? docId,  String? deepLink)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationDto() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.createdAt,_that.body,_that.isRead,_that.docType,_that.docId,_that.deepLink);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String type,  String title,  DateTime createdAt,  String? body,  bool isRead,  String? docType,  int? docId,  String? deepLink)  $default,) {final _that = this;
switch (_that) {
case _NotificationDto():
return $default(_that.id,_that.type,_that.title,_that.createdAt,_that.body,_that.isRead,_that.docType,_that.docId,_that.deepLink);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String type,  String title,  DateTime createdAt,  String? body,  bool isRead,  String? docType,  int? docId,  String? deepLink)?  $default,) {final _that = this;
switch (_that) {
case _NotificationDto() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.createdAt,_that.body,_that.isRead,_that.docType,_that.docId,_that.deepLink);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationDto implements NotificationDto {
  const _NotificationDto({required this.id, required this.type, required this.title, required this.createdAt, this.body, this.isRead = false, this.docType, this.docId, this.deepLink});
  factory _NotificationDto.fromJson(Map<String, dynamic> json) => _$NotificationDtoFromJson(json);

@override final  int id;
@override final  String type;
@override final  String title;
@override final  DateTime createdAt;
@override final  String? body;
@override@JsonKey() final  bool isRead;
@override final  String? docType;
@override final  int? docId;
@override final  String? deepLink;

/// Create a copy of NotificationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationDtoCopyWith<_NotificationDto> get copyWith => __$NotificationDtoCopyWithImpl<_NotificationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.body, body) || other.body == body)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.docType, docType) || other.docType == docType)&&(identical(other.docId, docId) || other.docId == docId)&&(identical(other.deepLink, deepLink) || other.deepLink == deepLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,title,createdAt,body,isRead,docType,docId,deepLink);
}

@override
String toString() {
    return 'NotificationDto(id: $id, type: $type, title: $title, createdAt: $createdAt, body: $body, isRead: $isRead, docType: $docType, docId: $docId, deepLink: $deepLink)';
}


}

/// @nodoc
abstract mixin class _$NotificationDtoCopyWith<$Res> implements $NotificationDtoCopyWith<$Res> {
  factory _$NotificationDtoCopyWith(_NotificationDto value, $Res Function(_NotificationDto) _then) = __$NotificationDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String type, String title, DateTime createdAt, String? body, bool isRead, String? docType, int? docId, String? deepLink
});




}
/// @nodoc
class __$NotificationDtoCopyWithImpl<$Res>
    implements _$NotificationDtoCopyWith<$Res> {
  __$NotificationDtoCopyWithImpl(this._self, this._then);

  final _NotificationDto _self;
  final $Res Function(_NotificationDto) _then;

/// Create a copy of NotificationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = null,Object? createdAt = null,Object? body = freezed,Object? isRead = null,Object? docType = freezed,Object? docId = freezed,Object? deepLink = freezed,}) {
  return _then(_NotificationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,docType: freezed == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as String?,docId: freezed == docId ? _self.docId : docId // ignore: cast_nullable_to_non_nullable
as int?,deepLink: freezed == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UnreadCountDto {

 int get count;
/// Create a copy of UnreadCountDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnreadCountDtoCopyWith<UnreadCountDto> get copyWith => _$UnreadCountDtoCopyWithImpl<UnreadCountDto>(this as UnreadCountDto, _$identity);

  /// Serializes this UnreadCountDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UnreadCountDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnreadCountDto&&(identical(other.count, _this.count) || other.count == _this.count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UnreadCountDto;
  return Object.hash(runtimeType,_this.count);
}

@override
String toString() {
  final _this = this as UnreadCountDto;
  return 'UnreadCountDto(count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $UnreadCountDtoCopyWith<$Res>  {
  factory $UnreadCountDtoCopyWith(UnreadCountDto value, $Res Function(UnreadCountDto) _then) = _$UnreadCountDtoCopyWithImpl;
@useResult
$Res call({
 int count
});




}
/// @nodoc
class _$UnreadCountDtoCopyWithImpl<$Res>
    implements $UnreadCountDtoCopyWith<$Res> {
  _$UnreadCountDtoCopyWithImpl(this._self, this._then);

  final UnreadCountDto _self;
  final $Res Function(UnreadCountDto) _then;

/// Create a copy of UnreadCountDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,}) {
  return _then(UnreadCountDto(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UnreadCountDto].
extension UnreadCountDtoPatterns on UnreadCountDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnreadCountDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnreadCountDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnreadCountDto value)  $default,){
final _that = this;
switch (_that) {
case _UnreadCountDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnreadCountDto value)?  $default,){
final _that = this;
switch (_that) {
case _UnreadCountDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnreadCountDto() when $default != null:
return $default(_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count)  $default,) {final _that = this;
switch (_that) {
case _UnreadCountDto():
return $default(_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count)?  $default,) {final _that = this;
switch (_that) {
case _UnreadCountDto() when $default != null:
return $default(_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnreadCountDto implements UnreadCountDto {
  const _UnreadCountDto({this.count = 0});
  factory _UnreadCountDto.fromJson(Map<String, dynamic> json) => _$UnreadCountDtoFromJson(json);

@override@JsonKey() final  int count;

/// Create a copy of UnreadCountDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnreadCountDtoCopyWith<_UnreadCountDto> get copyWith => __$UnreadCountDtoCopyWithImpl<_UnreadCountDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnreadCountDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnreadCountDto&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,count);
}

@override
String toString() {
    return 'UnreadCountDto(count: $count)';
}


}

/// @nodoc
abstract mixin class _$UnreadCountDtoCopyWith<$Res> implements $UnreadCountDtoCopyWith<$Res> {
  factory _$UnreadCountDtoCopyWith(_UnreadCountDto value, $Res Function(_UnreadCountDto) _then) = __$UnreadCountDtoCopyWithImpl;
@override @useResult
$Res call({
 int count
});




}
/// @nodoc
class __$UnreadCountDtoCopyWithImpl<$Res>
    implements _$UnreadCountDtoCopyWith<$Res> {
  __$UnreadCountDtoCopyWithImpl(this._self, this._then);

  final _UnreadCountDto _self;
  final $Res Function(_UnreadCountDto) _then;

/// Create a copy of UnreadCountDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,}) {
  return _then(_UnreadCountDto(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
