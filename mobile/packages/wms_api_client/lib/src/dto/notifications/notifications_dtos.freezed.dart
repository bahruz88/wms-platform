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

 int get id; String get eventType; String get severity; String get title; DateTime get createdAt; bool get isRead; String? get body; String? get link; String? get entityType; int? get entityId; int? get locationId; DateTime? get readAt; String? get eventId;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.eventType, _this.eventType) || other.eventType == _this.eventType)&&(identical(other.severity, _this.severity) || other.severity == _this.severity)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.isRead, _this.isRead) || other.isRead == _this.isRead)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.link, _this.link) || other.link == _this.link)&&(identical(other.entityType, _this.entityType) || other.entityType == _this.entityType)&&(identical(other.entityId, _this.entityId) || other.entityId == _this.entityId)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.readAt, _this.readAt) || other.readAt == _this.readAt)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationDto;
  return Object.hash(runtimeType,_this.id,_this.eventType,_this.severity,_this.title,_this.createdAt,_this.isRead,_this.body,_this.link,_this.entityType,_this.entityId,_this.locationId,_this.readAt,_this.eventId);
}

@override
String toString() {
  final _this = this as NotificationDto;
  return 'NotificationDto(id: ${_this.id}, eventType: ${_this.eventType}, severity: ${_this.severity}, title: ${_this.title}, createdAt: ${_this.createdAt}, isRead: ${_this.isRead}, body: ${_this.body}, link: ${_this.link}, entityType: ${_this.entityType}, entityId: ${_this.entityId}, locationId: ${_this.locationId}, readAt: ${_this.readAt}, eventId: ${_this.eventId})';
}


}

/// @nodoc
abstract mixin class $NotificationDtoCopyWith<$Res>  {
  factory $NotificationDtoCopyWith(NotificationDto value, $Res Function(NotificationDto) _then) = _$NotificationDtoCopyWithImpl;
@useResult
$Res call({
 int id, String eventType, String severity, String title, DateTime createdAt, bool isRead, String? body, String? link, String? entityType, int? entityId, int? locationId, DateTime? readAt, String? eventId
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventType = null,Object? severity = null,Object? title = null,Object? createdAt = null,Object? isRead = null,Object? body = freezed,Object? link = freezed,Object? entityType = freezed,Object? entityId = freezed,Object? locationId = freezed,Object? readAt = freezed,Object? eventId = freezed,}) {
  return _then(NotificationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,entityType: freezed == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String?,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as int?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String eventType,  String severity,  String title,  DateTime createdAt,  bool isRead,  String? body,  String? link,  String? entityType,  int? entityId,  int? locationId,  DateTime? readAt,  String? eventId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationDto() when $default != null:
return $default(_that.id,_that.eventType,_that.severity,_that.title,_that.createdAt,_that.isRead,_that.body,_that.link,_that.entityType,_that.entityId,_that.locationId,_that.readAt,_that.eventId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String eventType,  String severity,  String title,  DateTime createdAt,  bool isRead,  String? body,  String? link,  String? entityType,  int? entityId,  int? locationId,  DateTime? readAt,  String? eventId)  $default,) {final _that = this;
switch (_that) {
case _NotificationDto():
return $default(_that.id,_that.eventType,_that.severity,_that.title,_that.createdAt,_that.isRead,_that.body,_that.link,_that.entityType,_that.entityId,_that.locationId,_that.readAt,_that.eventId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String eventType,  String severity,  String title,  DateTime createdAt,  bool isRead,  String? body,  String? link,  String? entityType,  int? entityId,  int? locationId,  DateTime? readAt,  String? eventId)?  $default,) {final _that = this;
switch (_that) {
case _NotificationDto() when $default != null:
return $default(_that.id,_that.eventType,_that.severity,_that.title,_that.createdAt,_that.isRead,_that.body,_that.link,_that.entityType,_that.entityId,_that.locationId,_that.readAt,_that.eventId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationDto extends NotificationDto {
  const _NotificationDto({required this.id, required this.eventType, required this.severity, required this.title, required this.createdAt, this.isRead = false, this.body, this.link, this.entityType, this.entityId, this.locationId, this.readAt, this.eventId}): super._();
  factory _NotificationDto.fromJson(Map<String, dynamic> json) => _$NotificationDtoFromJson(json);

@override final  int id;
@override final  String eventType;
@override final  String severity;
@override final  String title;
@override final  DateTime createdAt;
@override@JsonKey() final  bool isRead;
@override final  String? body;
@override final  String? link;
@override final  String? entityType;
@override final  int? entityId;
@override final  int? locationId;
@override final  DateTime? readAt;
@override final  String? eventId;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.body, body) || other.body == body)&&(identical(other.link, link) || other.link == link)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.eventId, eventId) || other.eventId == eventId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,eventType,severity,title,createdAt,isRead,body,link,entityType,entityId,locationId,readAt,eventId);
}

@override
String toString() {
    return 'NotificationDto(id: $id, eventType: $eventType, severity: $severity, title: $title, createdAt: $createdAt, isRead: $isRead, body: $body, link: $link, entityType: $entityType, entityId: $entityId, locationId: $locationId, readAt: $readAt, eventId: $eventId)';
}


}

/// @nodoc
abstract mixin class _$NotificationDtoCopyWith<$Res> implements $NotificationDtoCopyWith<$Res> {
  factory _$NotificationDtoCopyWith(_NotificationDto value, $Res Function(_NotificationDto) _then) = __$NotificationDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String eventType, String severity, String title, DateTime createdAt, bool isRead, String? body, String? link, String? entityType, int? entityId, int? locationId, DateTime? readAt, String? eventId
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventType = null,Object? severity = null,Object? title = null,Object? createdAt = null,Object? isRead = null,Object? body = freezed,Object? link = freezed,Object? entityType = freezed,Object? entityId = freezed,Object? locationId = freezed,Object? readAt = freezed,Object? eventId = freezed,}) {
  return _then(_NotificationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,entityType: freezed == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String?,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as int?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UnreadCountDto {

 int get total; Map<String, int> get bySeverity; int get pendingApprovals;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnreadCountDto&&(identical(other.total, _this.total) || other.total == _this.total)&&const DeepCollectionEquality().equals(other.bySeverity, _this.bySeverity)&&(identical(other.pendingApprovals, _this.pendingApprovals) || other.pendingApprovals == _this.pendingApprovals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UnreadCountDto;
  return Object.hash(runtimeType,_this.total,const DeepCollectionEquality().hash(_this.bySeverity),_this.pendingApprovals);
}

@override
String toString() {
  final _this = this as UnreadCountDto;
  return 'UnreadCountDto(total: ${_this.total}, bySeverity: ${_this.bySeverity}, pendingApprovals: ${_this.pendingApprovals})';
}


}

/// @nodoc
abstract mixin class $UnreadCountDtoCopyWith<$Res>  {
  factory $UnreadCountDtoCopyWith(UnreadCountDto value, $Res Function(UnreadCountDto) _then) = _$UnreadCountDtoCopyWithImpl;
@useResult
$Res call({
 int total, Map<String, int> bySeverity, int pendingApprovals
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
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? bySeverity = null,Object? pendingApprovals = null,}) {
  return _then(UnreadCountDto(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,bySeverity: null == bySeverity ? _self.bySeverity : bySeverity // ignore: cast_nullable_to_non_nullable
as Map<String, int>,pendingApprovals: null == pendingApprovals ? _self.pendingApprovals : pendingApprovals // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  Map<String, int> bySeverity,  int pendingApprovals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnreadCountDto() when $default != null:
return $default(_that.total,_that.bySeverity,_that.pendingApprovals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  Map<String, int> bySeverity,  int pendingApprovals)  $default,) {final _that = this;
switch (_that) {
case _UnreadCountDto():
return $default(_that.total,_that.bySeverity,_that.pendingApprovals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  Map<String, int> bySeverity,  int pendingApprovals)?  $default,) {final _that = this;
switch (_that) {
case _UnreadCountDto() when $default != null:
return $default(_that.total,_that.bySeverity,_that.pendingApprovals);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnreadCountDto extends UnreadCountDto {
  const _UnreadCountDto({this.total = 0,  Map<String, int> bySeverity = const <String, int>{}, this.pendingApprovals = 0}): _bySeverity = bySeverity,super._();
  factory _UnreadCountDto.fromJson(Map<String, dynamic> json) => _$UnreadCountDtoFromJson(json);

@override@JsonKey() final  int total;
 final  Map<String, int> _bySeverity;
@override@JsonKey() Map<String, int> get bySeverity {
  if (_bySeverity is EqualUnmodifiableMapView) return _bySeverity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bySeverity);
}

@override@JsonKey() final  int pendingApprovals;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnreadCountDto&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.bySeverity, _bySeverity)&&(identical(other.pendingApprovals, pendingApprovals) || other.pendingApprovals == pendingApprovals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,total,const DeepCollectionEquality().hash(_bySeverity),pendingApprovals);
}

@override
String toString() {
    return 'UnreadCountDto(total: $total, bySeverity: $bySeverity, pendingApprovals: $pendingApprovals)';
}


}

/// @nodoc
abstract mixin class _$UnreadCountDtoCopyWith<$Res> implements $UnreadCountDtoCopyWith<$Res> {
  factory _$UnreadCountDtoCopyWith(_UnreadCountDto value, $Res Function(_UnreadCountDto) _then) = __$UnreadCountDtoCopyWithImpl;
@override @useResult
$Res call({
 int total, Map<String, int> bySeverity, int pendingApprovals
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
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? bySeverity = null,Object? pendingApprovals = null,}) {
  return _then(_UnreadCountDto(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,bySeverity: null == bySeverity ? _self._bySeverity : bySeverity // ignore: cast_nullable_to_non_nullable
as Map<String, int>,pendingApprovals: null == pendingApprovals ? _self.pendingApprovals : pendingApprovals // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
