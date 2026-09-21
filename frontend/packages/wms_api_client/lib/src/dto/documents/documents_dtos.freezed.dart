// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'documents_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttachmentDto {

 int get id; AttachmentEntityType get entityType; AttachmentType get attachmentType; String get fileName; String get contentType; int get sizeBytes; AttachmentStatus get status; int get uploadedBy; DateTime get uploadedAt;/// `null` until the document the file belongs to exists.
 int? get entityId; String? get checksumSha256;/// ClamAV outcome: `CLEAN`, `INFECTED:<signature>`, `SKIPPED`.
 String? get scanResult; bool get thumbnailAvailable;
/// Create a copy of AttachmentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentDtoCopyWith<AttachmentDto> get copyWith => _$AttachmentDtoCopyWithImpl<AttachmentDto>(this as AttachmentDto, _$identity);

  /// Serializes this AttachmentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttachmentDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachmentDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.entityType, _this.entityType) || other.entityType == _this.entityType)&&(identical(other.attachmentType, _this.attachmentType) || other.attachmentType == _this.attachmentType)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.contentType, _this.contentType) || other.contentType == _this.contentType)&&(identical(other.sizeBytes, _this.sizeBytes) || other.sizeBytes == _this.sizeBytes)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.uploadedBy, _this.uploadedBy) || other.uploadedBy == _this.uploadedBy)&&(identical(other.uploadedAt, _this.uploadedAt) || other.uploadedAt == _this.uploadedAt)&&(identical(other.entityId, _this.entityId) || other.entityId == _this.entityId)&&(identical(other.checksumSha256, _this.checksumSha256) || other.checksumSha256 == _this.checksumSha256)&&(identical(other.scanResult, _this.scanResult) || other.scanResult == _this.scanResult)&&(identical(other.thumbnailAvailable, _this.thumbnailAvailable) || other.thumbnailAvailable == _this.thumbnailAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttachmentDto;
  return Object.hash(runtimeType,_this.id,_this.entityType,_this.attachmentType,_this.fileName,_this.contentType,_this.sizeBytes,_this.status,_this.uploadedBy,_this.uploadedAt,_this.entityId,_this.checksumSha256,_this.scanResult,_this.thumbnailAvailable);
}

@override
String toString() {
  final _this = this as AttachmentDto;
  return 'AttachmentDto(id: ${_this.id}, entityType: ${_this.entityType}, attachmentType: ${_this.attachmentType}, fileName: ${_this.fileName}, contentType: ${_this.contentType}, sizeBytes: ${_this.sizeBytes}, status: ${_this.status}, uploadedBy: ${_this.uploadedBy}, uploadedAt: ${_this.uploadedAt}, entityId: ${_this.entityId}, checksumSha256: ${_this.checksumSha256}, scanResult: ${_this.scanResult}, thumbnailAvailable: ${_this.thumbnailAvailable})';
}


}

/// @nodoc
abstract mixin class $AttachmentDtoCopyWith<$Res>  {
  factory $AttachmentDtoCopyWith(AttachmentDto value, $Res Function(AttachmentDto) _then) = _$AttachmentDtoCopyWithImpl;
@useResult
$Res call({
 int id, AttachmentEntityType entityType, AttachmentType attachmentType, String fileName, String contentType, int sizeBytes, AttachmentStatus status, int uploadedBy, DateTime uploadedAt, int? entityId, String? checksumSha256, String? scanResult, bool thumbnailAvailable
});




}
/// @nodoc
class _$AttachmentDtoCopyWithImpl<$Res>
    implements $AttachmentDtoCopyWith<$Res> {
  _$AttachmentDtoCopyWithImpl(this._self, this._then);

  final AttachmentDto _self;
  final $Res Function(AttachmentDto) _then;

/// Create a copy of AttachmentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? entityType = null,Object? attachmentType = null,Object? fileName = null,Object? contentType = null,Object? sizeBytes = null,Object? status = null,Object? uploadedBy = null,Object? uploadedAt = null,Object? entityId = freezed,Object? checksumSha256 = freezed,Object? scanResult = freezed,Object? thumbnailAvailable = null,}) {
  return _then(AttachmentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as AttachmentEntityType,attachmentType: null == attachmentType ? _self.attachmentType : attachmentType // ignore: cast_nullable_to_non_nullable
as AttachmentType,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttachmentStatus,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as int,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as int?,checksumSha256: freezed == checksumSha256 ? _self.checksumSha256 : checksumSha256 // ignore: cast_nullable_to_non_nullable
as String?,scanResult: freezed == scanResult ? _self.scanResult : scanResult // ignore: cast_nullable_to_non_nullable
as String?,thumbnailAvailable: null == thumbnailAvailable ? _self.thumbnailAvailable : thumbnailAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AttachmentDto].
extension AttachmentDtoPatterns on AttachmentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttachmentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttachmentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttachmentDto value)  $default,){
final _that = this;
switch (_that) {
case _AttachmentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttachmentDto value)?  $default,){
final _that = this;
switch (_that) {
case _AttachmentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  AttachmentEntityType entityType,  AttachmentType attachmentType,  String fileName,  String contentType,  int sizeBytes,  AttachmentStatus status,  int uploadedBy,  DateTime uploadedAt,  int? entityId,  String? checksumSha256,  String? scanResult,  bool thumbnailAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttachmentDto() when $default != null:
return $default(_that.id,_that.entityType,_that.attachmentType,_that.fileName,_that.contentType,_that.sizeBytes,_that.status,_that.uploadedBy,_that.uploadedAt,_that.entityId,_that.checksumSha256,_that.scanResult,_that.thumbnailAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  AttachmentEntityType entityType,  AttachmentType attachmentType,  String fileName,  String contentType,  int sizeBytes,  AttachmentStatus status,  int uploadedBy,  DateTime uploadedAt,  int? entityId,  String? checksumSha256,  String? scanResult,  bool thumbnailAvailable)  $default,) {final _that = this;
switch (_that) {
case _AttachmentDto():
return $default(_that.id,_that.entityType,_that.attachmentType,_that.fileName,_that.contentType,_that.sizeBytes,_that.status,_that.uploadedBy,_that.uploadedAt,_that.entityId,_that.checksumSha256,_that.scanResult,_that.thumbnailAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  AttachmentEntityType entityType,  AttachmentType attachmentType,  String fileName,  String contentType,  int sizeBytes,  AttachmentStatus status,  int uploadedBy,  DateTime uploadedAt,  int? entityId,  String? checksumSha256,  String? scanResult,  bool thumbnailAvailable)?  $default,) {final _that = this;
switch (_that) {
case _AttachmentDto() when $default != null:
return $default(_that.id,_that.entityType,_that.attachmentType,_that.fileName,_that.contentType,_that.sizeBytes,_that.status,_that.uploadedBy,_that.uploadedAt,_that.entityId,_that.checksumSha256,_that.scanResult,_that.thumbnailAvailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttachmentDto extends AttachmentDto {
  const _AttachmentDto({required this.id, required this.entityType, required this.attachmentType, required this.fileName, required this.contentType, required this.sizeBytes, required this.status, required this.uploadedBy, required this.uploadedAt, this.entityId, this.checksumSha256, this.scanResult, this.thumbnailAvailable = false}): super._();
  factory _AttachmentDto.fromJson(Map<String, dynamic> json) => _$AttachmentDtoFromJson(json);

@override final  int id;
@override final  AttachmentEntityType entityType;
@override final  AttachmentType attachmentType;
@override final  String fileName;
@override final  String contentType;
@override final  int sizeBytes;
@override final  AttachmentStatus status;
@override final  int uploadedBy;
@override final  DateTime uploadedAt;
/// `null` until the document the file belongs to exists.
@override final  int? entityId;
@override final  String? checksumSha256;
/// ClamAV outcome: `CLEAN`, `INFECTED:<signature>`, `SKIPPED`.
@override final  String? scanResult;
@override@JsonKey() final  bool thumbnailAvailable;

/// Create a copy of AttachmentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentDtoCopyWith<_AttachmentDto> get copyWith => __$AttachmentDtoCopyWithImpl<_AttachmentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttachmentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttachmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.attachmentType, attachmentType) || other.attachmentType == attachmentType)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.status, status) || other.status == status)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.checksumSha256, checksumSha256) || other.checksumSha256 == checksumSha256)&&(identical(other.scanResult, scanResult) || other.scanResult == scanResult)&&(identical(other.thumbnailAvailable, thumbnailAvailable) || other.thumbnailAvailable == thumbnailAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,entityType,attachmentType,fileName,contentType,sizeBytes,status,uploadedBy,uploadedAt,entityId,checksumSha256,scanResult,thumbnailAvailable);
}

@override
String toString() {
    return 'AttachmentDto(id: $id, entityType: $entityType, attachmentType: $attachmentType, fileName: $fileName, contentType: $contentType, sizeBytes: $sizeBytes, status: $status, uploadedBy: $uploadedBy, uploadedAt: $uploadedAt, entityId: $entityId, checksumSha256: $checksumSha256, scanResult: $scanResult, thumbnailAvailable: $thumbnailAvailable)';
}


}

/// @nodoc
abstract mixin class _$AttachmentDtoCopyWith<$Res> implements $AttachmentDtoCopyWith<$Res> {
  factory _$AttachmentDtoCopyWith(_AttachmentDto value, $Res Function(_AttachmentDto) _then) = __$AttachmentDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, AttachmentEntityType entityType, AttachmentType attachmentType, String fileName, String contentType, int sizeBytes, AttachmentStatus status, int uploadedBy, DateTime uploadedAt, int? entityId, String? checksumSha256, String? scanResult, bool thumbnailAvailable
});




}
/// @nodoc
class __$AttachmentDtoCopyWithImpl<$Res>
    implements _$AttachmentDtoCopyWith<$Res> {
  __$AttachmentDtoCopyWithImpl(this._self, this._then);

  final _AttachmentDto _self;
  final $Res Function(_AttachmentDto) _then;

/// Create a copy of AttachmentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? entityType = null,Object? attachmentType = null,Object? fileName = null,Object? contentType = null,Object? sizeBytes = null,Object? status = null,Object? uploadedBy = null,Object? uploadedAt = null,Object? entityId = freezed,Object? checksumSha256 = freezed,Object? scanResult = freezed,Object? thumbnailAvailable = null,}) {
  return _then(_AttachmentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as AttachmentEntityType,attachmentType: null == attachmentType ? _self.attachmentType : attachmentType // ignore: cast_nullable_to_non_nullable
as AttachmentType,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttachmentStatus,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as int,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as int?,checksumSha256: freezed == checksumSha256 ? _self.checksumSha256 : checksumSha256 // ignore: cast_nullable_to_non_nullable
as String?,scanResult: freezed == scanResult ? _self.scanResult : scanResult // ignore: cast_nullable_to_non_nullable
as String?,thumbnailAvailable: null == thumbnailAvailable ? _self.thumbnailAvailable : thumbnailAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PresignAttachmentRequest {

 AttachmentEntityType get entityType; AttachmentType get attachmentType; String get fileName; String get contentType; int get sizeBytes; int? get entityId; String? get checksumSha256;
/// Create a copy of PresignAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresignAttachmentRequestCopyWith<PresignAttachmentRequest> get copyWith => _$PresignAttachmentRequestCopyWithImpl<PresignAttachmentRequest>(this as PresignAttachmentRequest, _$identity);

  /// Serializes this PresignAttachmentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PresignAttachmentRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresignAttachmentRequest&&(identical(other.entityType, _this.entityType) || other.entityType == _this.entityType)&&(identical(other.attachmentType, _this.attachmentType) || other.attachmentType == _this.attachmentType)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.contentType, _this.contentType) || other.contentType == _this.contentType)&&(identical(other.sizeBytes, _this.sizeBytes) || other.sizeBytes == _this.sizeBytes)&&(identical(other.entityId, _this.entityId) || other.entityId == _this.entityId)&&(identical(other.checksumSha256, _this.checksumSha256) || other.checksumSha256 == _this.checksumSha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PresignAttachmentRequest;
  return Object.hash(runtimeType,_this.entityType,_this.attachmentType,_this.fileName,_this.contentType,_this.sizeBytes,_this.entityId,_this.checksumSha256);
}

@override
String toString() {
  final _this = this as PresignAttachmentRequest;
  return 'PresignAttachmentRequest(entityType: ${_this.entityType}, attachmentType: ${_this.attachmentType}, fileName: ${_this.fileName}, contentType: ${_this.contentType}, sizeBytes: ${_this.sizeBytes}, entityId: ${_this.entityId}, checksumSha256: ${_this.checksumSha256})';
}


}

/// @nodoc
abstract mixin class $PresignAttachmentRequestCopyWith<$Res>  {
  factory $PresignAttachmentRequestCopyWith(PresignAttachmentRequest value, $Res Function(PresignAttachmentRequest) _then) = _$PresignAttachmentRequestCopyWithImpl;
@useResult
$Res call({
 AttachmentEntityType entityType, AttachmentType attachmentType, String fileName, String contentType, int sizeBytes, int? entityId, String? checksumSha256
});




}
/// @nodoc
class _$PresignAttachmentRequestCopyWithImpl<$Res>
    implements $PresignAttachmentRequestCopyWith<$Res> {
  _$PresignAttachmentRequestCopyWithImpl(this._self, this._then);

  final PresignAttachmentRequest _self;
  final $Res Function(PresignAttachmentRequest) _then;

/// Create a copy of PresignAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entityType = null,Object? attachmentType = null,Object? fileName = null,Object? contentType = null,Object? sizeBytes = null,Object? entityId = freezed,Object? checksumSha256 = freezed,}) {
  return _then(PresignAttachmentRequest(
entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as AttachmentEntityType,attachmentType: null == attachmentType ? _self.attachmentType : attachmentType // ignore: cast_nullable_to_non_nullable
as AttachmentType,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as int?,checksumSha256: freezed == checksumSha256 ? _self.checksumSha256 : checksumSha256 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PresignAttachmentRequest].
extension PresignAttachmentRequestPatterns on PresignAttachmentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresignAttachmentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresignAttachmentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresignAttachmentRequest value)  $default,){
final _that = this;
switch (_that) {
case _PresignAttachmentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresignAttachmentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PresignAttachmentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AttachmentEntityType entityType,  AttachmentType attachmentType,  String fileName,  String contentType,  int sizeBytes,  int? entityId,  String? checksumSha256)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresignAttachmentRequest() when $default != null:
return $default(_that.entityType,_that.attachmentType,_that.fileName,_that.contentType,_that.sizeBytes,_that.entityId,_that.checksumSha256);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AttachmentEntityType entityType,  AttachmentType attachmentType,  String fileName,  String contentType,  int sizeBytes,  int? entityId,  String? checksumSha256)  $default,) {final _that = this;
switch (_that) {
case _PresignAttachmentRequest():
return $default(_that.entityType,_that.attachmentType,_that.fileName,_that.contentType,_that.sizeBytes,_that.entityId,_that.checksumSha256);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AttachmentEntityType entityType,  AttachmentType attachmentType,  String fileName,  String contentType,  int sizeBytes,  int? entityId,  String? checksumSha256)?  $default,) {final _that = this;
switch (_that) {
case _PresignAttachmentRequest() when $default != null:
return $default(_that.entityType,_that.attachmentType,_that.fileName,_that.contentType,_that.sizeBytes,_that.entityId,_that.checksumSha256);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PresignAttachmentRequest implements PresignAttachmentRequest {
  const _PresignAttachmentRequest({required this.entityType, required this.attachmentType, required this.fileName, required this.contentType, required this.sizeBytes, this.entityId, this.checksumSha256});
  factory _PresignAttachmentRequest.fromJson(Map<String, dynamic> json) => _$PresignAttachmentRequestFromJson(json);

@override final  AttachmentEntityType entityType;
@override final  AttachmentType attachmentType;
@override final  String fileName;
@override final  String contentType;
@override final  int sizeBytes;
@override final  int? entityId;
@override final  String? checksumSha256;

/// Create a copy of PresignAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresignAttachmentRequestCopyWith<_PresignAttachmentRequest> get copyWith => __$PresignAttachmentRequestCopyWithImpl<_PresignAttachmentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresignAttachmentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresignAttachmentRequest&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.attachmentType, attachmentType) || other.attachmentType == attachmentType)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.checksumSha256, checksumSha256) || other.checksumSha256 == checksumSha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,entityType,attachmentType,fileName,contentType,sizeBytes,entityId,checksumSha256);
}

@override
String toString() {
    return 'PresignAttachmentRequest(entityType: $entityType, attachmentType: $attachmentType, fileName: $fileName, contentType: $contentType, sizeBytes: $sizeBytes, entityId: $entityId, checksumSha256: $checksumSha256)';
}


}

/// @nodoc
abstract mixin class _$PresignAttachmentRequestCopyWith<$Res> implements $PresignAttachmentRequestCopyWith<$Res> {
  factory _$PresignAttachmentRequestCopyWith(_PresignAttachmentRequest value, $Res Function(_PresignAttachmentRequest) _then) = __$PresignAttachmentRequestCopyWithImpl;
@override @useResult
$Res call({
 AttachmentEntityType entityType, AttachmentType attachmentType, String fileName, String contentType, int sizeBytes, int? entityId, String? checksumSha256
});




}
/// @nodoc
class __$PresignAttachmentRequestCopyWithImpl<$Res>
    implements _$PresignAttachmentRequestCopyWith<$Res> {
  __$PresignAttachmentRequestCopyWithImpl(this._self, this._then);

  final _PresignAttachmentRequest _self;
  final $Res Function(_PresignAttachmentRequest) _then;

/// Create a copy of PresignAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entityType = null,Object? attachmentType = null,Object? fileName = null,Object? contentType = null,Object? sizeBytes = null,Object? entityId = freezed,Object? checksumSha256 = freezed,}) {
  return _then(_PresignAttachmentRequest(
entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as AttachmentEntityType,attachmentType: null == attachmentType ? _self.attachmentType : attachmentType // ignore: cast_nullable_to_non_nullable
as AttachmentType,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as int?,checksumSha256: freezed == checksumSha256 ? _self.checksumSha256 : checksumSha256 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PresignAttachmentResponse {

 int get attachmentId; String get uploadUrl; DateTime get expiresAt; int get maxSizeBytes; String get method;/// Headers that must be sent **unchanged** with the `PUT`, otherwise the
/// presigned signature does not match.
 Map<String, String> get uploadHeaders;
/// Create a copy of PresignAttachmentResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresignAttachmentResponseCopyWith<PresignAttachmentResponse> get copyWith => _$PresignAttachmentResponseCopyWithImpl<PresignAttachmentResponse>(this as PresignAttachmentResponse, _$identity);

  /// Serializes this PresignAttachmentResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PresignAttachmentResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresignAttachmentResponse&&(identical(other.attachmentId, _this.attachmentId) || other.attachmentId == _this.attachmentId)&&(identical(other.uploadUrl, _this.uploadUrl) || other.uploadUrl == _this.uploadUrl)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.maxSizeBytes, _this.maxSizeBytes) || other.maxSizeBytes == _this.maxSizeBytes)&&(identical(other.method, _this.method) || other.method == _this.method)&&const DeepCollectionEquality().equals(other.uploadHeaders, _this.uploadHeaders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PresignAttachmentResponse;
  return Object.hash(runtimeType,_this.attachmentId,_this.uploadUrl,_this.expiresAt,_this.maxSizeBytes,_this.method,const DeepCollectionEquality().hash(_this.uploadHeaders));
}

@override
String toString() {
  final _this = this as PresignAttachmentResponse;
  return 'PresignAttachmentResponse(attachmentId: ${_this.attachmentId}, uploadUrl: ${_this.uploadUrl}, expiresAt: ${_this.expiresAt}, maxSizeBytes: ${_this.maxSizeBytes}, method: ${_this.method}, uploadHeaders: ${_this.uploadHeaders})';
}


}

/// @nodoc
abstract mixin class $PresignAttachmentResponseCopyWith<$Res>  {
  factory $PresignAttachmentResponseCopyWith(PresignAttachmentResponse value, $Res Function(PresignAttachmentResponse) _then) = _$PresignAttachmentResponseCopyWithImpl;
@useResult
$Res call({
 int attachmentId, String uploadUrl, DateTime expiresAt, int maxSizeBytes, String method, Map<String, String> uploadHeaders
});




}
/// @nodoc
class _$PresignAttachmentResponseCopyWithImpl<$Res>
    implements $PresignAttachmentResponseCopyWith<$Res> {
  _$PresignAttachmentResponseCopyWithImpl(this._self, this._then);

  final PresignAttachmentResponse _self;
  final $Res Function(PresignAttachmentResponse) _then;

/// Create a copy of PresignAttachmentResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? attachmentId = null,Object? uploadUrl = null,Object? expiresAt = null,Object? maxSizeBytes = null,Object? method = null,Object? uploadHeaders = null,}) {
  return _then(PresignAttachmentResponse(
attachmentId: null == attachmentId ? _self.attachmentId : attachmentId // ignore: cast_nullable_to_non_nullable
as int,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,maxSizeBytes: null == maxSizeBytes ? _self.maxSizeBytes : maxSizeBytes // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,uploadHeaders: null == uploadHeaders ? _self.uploadHeaders : uploadHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PresignAttachmentResponse].
extension PresignAttachmentResponsePatterns on PresignAttachmentResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresignAttachmentResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresignAttachmentResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresignAttachmentResponse value)  $default,){
final _that = this;
switch (_that) {
case _PresignAttachmentResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresignAttachmentResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PresignAttachmentResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int attachmentId,  String uploadUrl,  DateTime expiresAt,  int maxSizeBytes,  String method,  Map<String, String> uploadHeaders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresignAttachmentResponse() when $default != null:
return $default(_that.attachmentId,_that.uploadUrl,_that.expiresAt,_that.maxSizeBytes,_that.method,_that.uploadHeaders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int attachmentId,  String uploadUrl,  DateTime expiresAt,  int maxSizeBytes,  String method,  Map<String, String> uploadHeaders)  $default,) {final _that = this;
switch (_that) {
case _PresignAttachmentResponse():
return $default(_that.attachmentId,_that.uploadUrl,_that.expiresAt,_that.maxSizeBytes,_that.method,_that.uploadHeaders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int attachmentId,  String uploadUrl,  DateTime expiresAt,  int maxSizeBytes,  String method,  Map<String, String> uploadHeaders)?  $default,) {final _that = this;
switch (_that) {
case _PresignAttachmentResponse() when $default != null:
return $default(_that.attachmentId,_that.uploadUrl,_that.expiresAt,_that.maxSizeBytes,_that.method,_that.uploadHeaders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PresignAttachmentResponse extends PresignAttachmentResponse {
  const _PresignAttachmentResponse({required this.attachmentId, required this.uploadUrl, required this.expiresAt, required this.maxSizeBytes, this.method = 'PUT',  Map<String, String> uploadHeaders = const <String, String>{}}): _uploadHeaders = uploadHeaders,super._();
  factory _PresignAttachmentResponse.fromJson(Map<String, dynamic> json) => _$PresignAttachmentResponseFromJson(json);

@override final  int attachmentId;
@override final  String uploadUrl;
@override final  DateTime expiresAt;
@override final  int maxSizeBytes;
@override@JsonKey() final  String method;
/// Headers that must be sent **unchanged** with the `PUT`, otherwise the
/// presigned signature does not match.
 final  Map<String, String> _uploadHeaders;
/// Headers that must be sent **unchanged** with the `PUT`, otherwise the
/// presigned signature does not match.
@override@JsonKey() Map<String, String> get uploadHeaders {
  if (_uploadHeaders is EqualUnmodifiableMapView) return _uploadHeaders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_uploadHeaders);
}


/// Create a copy of PresignAttachmentResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresignAttachmentResponseCopyWith<_PresignAttachmentResponse> get copyWith => __$PresignAttachmentResponseCopyWithImpl<_PresignAttachmentResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresignAttachmentResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresignAttachmentResponse&&(identical(other.attachmentId, attachmentId) || other.attachmentId == attachmentId)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxSizeBytes, maxSizeBytes) || other.maxSizeBytes == maxSizeBytes)&&(identical(other.method, method) || other.method == method)&&const DeepCollectionEquality().equals(other.uploadHeaders, _uploadHeaders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,attachmentId,uploadUrl,expiresAt,maxSizeBytes,method,const DeepCollectionEquality().hash(_uploadHeaders));
}

@override
String toString() {
    return 'PresignAttachmentResponse(attachmentId: $attachmentId, uploadUrl: $uploadUrl, expiresAt: $expiresAt, maxSizeBytes: $maxSizeBytes, method: $method, uploadHeaders: $uploadHeaders)';
}


}

/// @nodoc
abstract mixin class _$PresignAttachmentResponseCopyWith<$Res> implements $PresignAttachmentResponseCopyWith<$Res> {
  factory _$PresignAttachmentResponseCopyWith(_PresignAttachmentResponse value, $Res Function(_PresignAttachmentResponse) _then) = __$PresignAttachmentResponseCopyWithImpl;
@override @useResult
$Res call({
 int attachmentId, String uploadUrl, DateTime expiresAt, int maxSizeBytes, String method, Map<String, String> uploadHeaders
});




}
/// @nodoc
class __$PresignAttachmentResponseCopyWithImpl<$Res>
    implements _$PresignAttachmentResponseCopyWith<$Res> {
  __$PresignAttachmentResponseCopyWithImpl(this._self, this._then);

  final _PresignAttachmentResponse _self;
  final $Res Function(_PresignAttachmentResponse) _then;

/// Create a copy of PresignAttachmentResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? attachmentId = null,Object? uploadUrl = null,Object? expiresAt = null,Object? maxSizeBytes = null,Object? method = null,Object? uploadHeaders = null,}) {
  return _then(_PresignAttachmentResponse(
attachmentId: null == attachmentId ? _self.attachmentId : attachmentId // ignore: cast_nullable_to_non_nullable
as int,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,maxSizeBytes: null == maxSizeBytes ? _self.maxSizeBytes : maxSizeBytes // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,uploadHeaders: null == uploadHeaders ? _self._uploadHeaders : uploadHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}


/// @nodoc
mixin _$CompleteAttachmentRequest {

 String get checksumSha256; String? get etag;
/// Create a copy of CompleteAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompleteAttachmentRequestCopyWith<CompleteAttachmentRequest> get copyWith => _$CompleteAttachmentRequestCopyWithImpl<CompleteAttachmentRequest>(this as CompleteAttachmentRequest, _$identity);

  /// Serializes this CompleteAttachmentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CompleteAttachmentRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompleteAttachmentRequest&&(identical(other.checksumSha256, _this.checksumSha256) || other.checksumSha256 == _this.checksumSha256)&&(identical(other.etag, _this.etag) || other.etag == _this.etag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CompleteAttachmentRequest;
  return Object.hash(runtimeType,_this.checksumSha256,_this.etag);
}

@override
String toString() {
  final _this = this as CompleteAttachmentRequest;
  return 'CompleteAttachmentRequest(checksumSha256: ${_this.checksumSha256}, etag: ${_this.etag})';
}


}

/// @nodoc
abstract mixin class $CompleteAttachmentRequestCopyWith<$Res>  {
  factory $CompleteAttachmentRequestCopyWith(CompleteAttachmentRequest value, $Res Function(CompleteAttachmentRequest) _then) = _$CompleteAttachmentRequestCopyWithImpl;
@useResult
$Res call({
 String checksumSha256, String? etag
});




}
/// @nodoc
class _$CompleteAttachmentRequestCopyWithImpl<$Res>
    implements $CompleteAttachmentRequestCopyWith<$Res> {
  _$CompleteAttachmentRequestCopyWithImpl(this._self, this._then);

  final CompleteAttachmentRequest _self;
  final $Res Function(CompleteAttachmentRequest) _then;

/// Create a copy of CompleteAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checksumSha256 = null,Object? etag = freezed,}) {
  return _then(CompleteAttachmentRequest(
checksumSha256: null == checksumSha256 ? _self.checksumSha256 : checksumSha256 // ignore: cast_nullable_to_non_nullable
as String,etag: freezed == etag ? _self.etag : etag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompleteAttachmentRequest].
extension CompleteAttachmentRequestPatterns on CompleteAttachmentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompleteAttachmentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompleteAttachmentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompleteAttachmentRequest value)  $default,){
final _that = this;
switch (_that) {
case _CompleteAttachmentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompleteAttachmentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CompleteAttachmentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String checksumSha256,  String? etag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompleteAttachmentRequest() when $default != null:
return $default(_that.checksumSha256,_that.etag);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String checksumSha256,  String? etag)  $default,) {final _that = this;
switch (_that) {
case _CompleteAttachmentRequest():
return $default(_that.checksumSha256,_that.etag);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String checksumSha256,  String? etag)?  $default,) {final _that = this;
switch (_that) {
case _CompleteAttachmentRequest() when $default != null:
return $default(_that.checksumSha256,_that.etag);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompleteAttachmentRequest implements CompleteAttachmentRequest {
  const _CompleteAttachmentRequest({required this.checksumSha256, this.etag});
  factory _CompleteAttachmentRequest.fromJson(Map<String, dynamic> json) => _$CompleteAttachmentRequestFromJson(json);

@override final  String checksumSha256;
@override final  String? etag;

/// Create a copy of CompleteAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompleteAttachmentRequestCopyWith<_CompleteAttachmentRequest> get copyWith => __$CompleteAttachmentRequestCopyWithImpl<_CompleteAttachmentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompleteAttachmentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompleteAttachmentRequest&&(identical(other.checksumSha256, checksumSha256) || other.checksumSha256 == checksumSha256)&&(identical(other.etag, etag) || other.etag == etag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,checksumSha256,etag);
}

@override
String toString() {
    return 'CompleteAttachmentRequest(checksumSha256: $checksumSha256, etag: $etag)';
}


}

/// @nodoc
abstract mixin class _$CompleteAttachmentRequestCopyWith<$Res> implements $CompleteAttachmentRequestCopyWith<$Res> {
  factory _$CompleteAttachmentRequestCopyWith(_CompleteAttachmentRequest value, $Res Function(_CompleteAttachmentRequest) _then) = __$CompleteAttachmentRequestCopyWithImpl;
@override @useResult
$Res call({
 String checksumSha256, String? etag
});




}
/// @nodoc
class __$CompleteAttachmentRequestCopyWithImpl<$Res>
    implements _$CompleteAttachmentRequestCopyWith<$Res> {
  __$CompleteAttachmentRequestCopyWithImpl(this._self, this._then);

  final _CompleteAttachmentRequest _self;
  final $Res Function(_CompleteAttachmentRequest) _then;

/// Create a copy of CompleteAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checksumSha256 = null,Object? etag = freezed,}) {
  return _then(_CompleteAttachmentRequest(
checksumSha256: null == checksumSha256 ? _self.checksumSha256 : checksumSha256 // ignore: cast_nullable_to_non_nullable
as String,etag: freezed == etag ? _self.etag : etag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AttachmentDownloadUrlDto {

 String get downloadUrl; DateTime get expiresAt; String get fileName; String get contentType; int get sizeBytes;
/// Create a copy of AttachmentDownloadUrlDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentDownloadUrlDtoCopyWith<AttachmentDownloadUrlDto> get copyWith => _$AttachmentDownloadUrlDtoCopyWithImpl<AttachmentDownloadUrlDto>(this as AttachmentDownloadUrlDto, _$identity);

  /// Serializes this AttachmentDownloadUrlDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttachmentDownloadUrlDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachmentDownloadUrlDto&&(identical(other.downloadUrl, _this.downloadUrl) || other.downloadUrl == _this.downloadUrl)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.contentType, _this.contentType) || other.contentType == _this.contentType)&&(identical(other.sizeBytes, _this.sizeBytes) || other.sizeBytes == _this.sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttachmentDownloadUrlDto;
  return Object.hash(runtimeType,_this.downloadUrl,_this.expiresAt,_this.fileName,_this.contentType,_this.sizeBytes);
}

@override
String toString() {
  final _this = this as AttachmentDownloadUrlDto;
  return 'AttachmentDownloadUrlDto(downloadUrl: ${_this.downloadUrl}, expiresAt: ${_this.expiresAt}, fileName: ${_this.fileName}, contentType: ${_this.contentType}, sizeBytes: ${_this.sizeBytes})';
}


}

/// @nodoc
abstract mixin class $AttachmentDownloadUrlDtoCopyWith<$Res>  {
  factory $AttachmentDownloadUrlDtoCopyWith(AttachmentDownloadUrlDto value, $Res Function(AttachmentDownloadUrlDto) _then) = _$AttachmentDownloadUrlDtoCopyWithImpl;
@useResult
$Res call({
 String downloadUrl, DateTime expiresAt, String fileName, String contentType, int sizeBytes
});




}
/// @nodoc
class _$AttachmentDownloadUrlDtoCopyWithImpl<$Res>
    implements $AttachmentDownloadUrlDtoCopyWith<$Res> {
  _$AttachmentDownloadUrlDtoCopyWithImpl(this._self, this._then);

  final AttachmentDownloadUrlDto _self;
  final $Res Function(AttachmentDownloadUrlDto) _then;

/// Create a copy of AttachmentDownloadUrlDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? downloadUrl = null,Object? expiresAt = null,Object? fileName = null,Object? contentType = null,Object? sizeBytes = null,}) {
  return _then(AttachmentDownloadUrlDto(
downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AttachmentDownloadUrlDto].
extension AttachmentDownloadUrlDtoPatterns on AttachmentDownloadUrlDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttachmentDownloadUrlDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttachmentDownloadUrlDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttachmentDownloadUrlDto value)  $default,){
final _that = this;
switch (_that) {
case _AttachmentDownloadUrlDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttachmentDownloadUrlDto value)?  $default,){
final _that = this;
switch (_that) {
case _AttachmentDownloadUrlDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String downloadUrl,  DateTime expiresAt,  String fileName,  String contentType,  int sizeBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttachmentDownloadUrlDto() when $default != null:
return $default(_that.downloadUrl,_that.expiresAt,_that.fileName,_that.contentType,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String downloadUrl,  DateTime expiresAt,  String fileName,  String contentType,  int sizeBytes)  $default,) {final _that = this;
switch (_that) {
case _AttachmentDownloadUrlDto():
return $default(_that.downloadUrl,_that.expiresAt,_that.fileName,_that.contentType,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String downloadUrl,  DateTime expiresAt,  String fileName,  String contentType,  int sizeBytes)?  $default,) {final _that = this;
switch (_that) {
case _AttachmentDownloadUrlDto() when $default != null:
return $default(_that.downloadUrl,_that.expiresAt,_that.fileName,_that.contentType,_that.sizeBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttachmentDownloadUrlDto implements AttachmentDownloadUrlDto {
  const _AttachmentDownloadUrlDto({required this.downloadUrl, required this.expiresAt, required this.fileName, required this.contentType, required this.sizeBytes});
  factory _AttachmentDownloadUrlDto.fromJson(Map<String, dynamic> json) => _$AttachmentDownloadUrlDtoFromJson(json);

@override final  String downloadUrl;
@override final  DateTime expiresAt;
@override final  String fileName;
@override final  String contentType;
@override final  int sizeBytes;

/// Create a copy of AttachmentDownloadUrlDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentDownloadUrlDtoCopyWith<_AttachmentDownloadUrlDto> get copyWith => __$AttachmentDownloadUrlDtoCopyWithImpl<_AttachmentDownloadUrlDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttachmentDownloadUrlDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttachmentDownloadUrlDto&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,downloadUrl,expiresAt,fileName,contentType,sizeBytes);
}

@override
String toString() {
    return 'AttachmentDownloadUrlDto(downloadUrl: $downloadUrl, expiresAt: $expiresAt, fileName: $fileName, contentType: $contentType, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class _$AttachmentDownloadUrlDtoCopyWith<$Res> implements $AttachmentDownloadUrlDtoCopyWith<$Res> {
  factory _$AttachmentDownloadUrlDtoCopyWith(_AttachmentDownloadUrlDto value, $Res Function(_AttachmentDownloadUrlDto) _then) = __$AttachmentDownloadUrlDtoCopyWithImpl;
@override @useResult
$Res call({
 String downloadUrl, DateTime expiresAt, String fileName, String contentType, int sizeBytes
});




}
/// @nodoc
class __$AttachmentDownloadUrlDtoCopyWithImpl<$Res>
    implements _$AttachmentDownloadUrlDtoCopyWith<$Res> {
  __$AttachmentDownloadUrlDtoCopyWithImpl(this._self, this._then);

  final _AttachmentDownloadUrlDto _self;
  final $Res Function(_AttachmentDownloadUrlDto) _then;

/// Create a copy of AttachmentDownloadUrlDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? downloadUrl = null,Object? expiresAt = null,Object? fileName = null,Object? contentType = null,Object? sizeBytes = null,}) {
  return _then(_AttachmentDownloadUrlDto(
downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
