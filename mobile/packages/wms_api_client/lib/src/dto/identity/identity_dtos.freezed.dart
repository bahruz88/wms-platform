// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurrentUserDto {

 int get id; int get tenantId; String get username; String get fullName; String? get externalId; String? get email; String? get phone; List<String> get roles; List<String> get permissions; List<int> get locationIds;
/// Create a copy of CurrentUserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentUserDtoCopyWith<CurrentUserDto> get copyWith => _$CurrentUserDtoCopyWithImpl<CurrentUserDto>(this as CurrentUserDto, _$identity);

  /// Serializes this CurrentUserDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CurrentUserDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentUserDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.tenantId, _this.tenantId) || other.tenantId == _this.tenantId)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.externalId, _this.externalId) || other.externalId == _this.externalId)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&const DeepCollectionEquality().equals(other.roles, _this.roles)&&const DeepCollectionEquality().equals(other.permissions, _this.permissions)&&const DeepCollectionEquality().equals(other.locationIds, _this.locationIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CurrentUserDto;
  return Object.hash(runtimeType,_this.id,_this.tenantId,_this.username,_this.fullName,_this.externalId,_this.email,_this.phone,const DeepCollectionEquality().hash(_this.roles),const DeepCollectionEquality().hash(_this.permissions),const DeepCollectionEquality().hash(_this.locationIds));
}

@override
String toString() {
  final _this = this as CurrentUserDto;
  return 'CurrentUserDto(id: ${_this.id}, tenantId: ${_this.tenantId}, username: ${_this.username}, fullName: ${_this.fullName}, externalId: ${_this.externalId}, email: ${_this.email}, phone: ${_this.phone}, roles: ${_this.roles}, permissions: ${_this.permissions}, locationIds: ${_this.locationIds})';
}


}

/// @nodoc
abstract mixin class $CurrentUserDtoCopyWith<$Res>  {
  factory $CurrentUserDtoCopyWith(CurrentUserDto value, $Res Function(CurrentUserDto) _then) = _$CurrentUserDtoCopyWithImpl;
@useResult
$Res call({
 int id, int tenantId, String username, String fullName, String? externalId, String? email, String? phone, List<String> roles, List<String> permissions, List<int> locationIds
});




}
/// @nodoc
class _$CurrentUserDtoCopyWithImpl<$Res>
    implements $CurrentUserDtoCopyWith<$Res> {
  _$CurrentUserDtoCopyWithImpl(this._self, this._then);

  final CurrentUserDto _self;
  final $Res Function(CurrentUserDto) _then;

/// Create a copy of CurrentUserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? username = null,Object? fullName = null,Object? externalId = freezed,Object? email = freezed,Object? phone = freezed,Object? roles = null,Object? permissions = null,Object? locationIds = null,}) {
  return _then(CurrentUserDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,locationIds: null == locationIds ? _self.locationIds : locationIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrentUserDto].
extension CurrentUserDtoPatterns on CurrentUserDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentUserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentUserDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentUserDto value)  $default,){
final _that = this;
switch (_that) {
case _CurrentUserDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentUserDto value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentUserDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int tenantId,  String username,  String fullName,  String? externalId,  String? email,  String? phone,  List<String> roles,  List<String> permissions,  List<int> locationIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentUserDto() when $default != null:
return $default(_that.id,_that.tenantId,_that.username,_that.fullName,_that.externalId,_that.email,_that.phone,_that.roles,_that.permissions,_that.locationIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int tenantId,  String username,  String fullName,  String? externalId,  String? email,  String? phone,  List<String> roles,  List<String> permissions,  List<int> locationIds)  $default,) {final _that = this;
switch (_that) {
case _CurrentUserDto():
return $default(_that.id,_that.tenantId,_that.username,_that.fullName,_that.externalId,_that.email,_that.phone,_that.roles,_that.permissions,_that.locationIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int tenantId,  String username,  String fullName,  String? externalId,  String? email,  String? phone,  List<String> roles,  List<String> permissions,  List<int> locationIds)?  $default,) {final _that = this;
switch (_that) {
case _CurrentUserDto() when $default != null:
return $default(_that.id,_that.tenantId,_that.username,_that.fullName,_that.externalId,_that.email,_that.phone,_that.roles,_that.permissions,_that.locationIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurrentUserDto extends CurrentUserDto {
  const _CurrentUserDto({required this.id, required this.tenantId, required this.username, required this.fullName, this.externalId, this.email, this.phone,  List<String> roles = const <String>[],  List<String> permissions = const <String>[],  List<int> locationIds = const <int>[]}): _roles = roles,_permissions = permissions,_locationIds = locationIds,super._();
  factory _CurrentUserDto.fromJson(Map<String, dynamic> json) => _$CurrentUserDtoFromJson(json);

@override final  int id;
@override final  int tenantId;
@override final  String username;
@override final  String fullName;
@override final  String? externalId;
@override final  String? email;
@override final  String? phone;
 final  List<String> _roles;
@override@JsonKey() List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

 final  List<String> _permissions;
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}

 final  List<int> _locationIds;
@override@JsonKey() List<int> get locationIds {
  if (_locationIds is EqualUnmodifiableListView) return _locationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locationIds);
}


/// Create a copy of CurrentUserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentUserDtoCopyWith<_CurrentUserDto> get copyWith => __$CurrentUserDtoCopyWithImpl<_CurrentUserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentUserDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentUserDto&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.username, username) || other.username == username)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&const DeepCollectionEquality().equals(other.roles, _roles)&&const DeepCollectionEquality().equals(other.permissions, _permissions)&&const DeepCollectionEquality().equals(other.locationIds, _locationIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,tenantId,username,fullName,externalId,email,phone,const DeepCollectionEquality().hash(_roles),const DeepCollectionEquality().hash(_permissions),const DeepCollectionEquality().hash(_locationIds));
}

@override
String toString() {
    return 'CurrentUserDto(id: $id, tenantId: $tenantId, username: $username, fullName: $fullName, externalId: $externalId, email: $email, phone: $phone, roles: $roles, permissions: $permissions, locationIds: $locationIds)';
}


}

/// @nodoc
abstract mixin class _$CurrentUserDtoCopyWith<$Res> implements $CurrentUserDtoCopyWith<$Res> {
  factory _$CurrentUserDtoCopyWith(_CurrentUserDto value, $Res Function(_CurrentUserDto) _then) = __$CurrentUserDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int tenantId, String username, String fullName, String? externalId, String? email, String? phone, List<String> roles, List<String> permissions, List<int> locationIds
});




}
/// @nodoc
class __$CurrentUserDtoCopyWithImpl<$Res>
    implements _$CurrentUserDtoCopyWith<$Res> {
  __$CurrentUserDtoCopyWithImpl(this._self, this._then);

  final _CurrentUserDto _self;
  final $Res Function(_CurrentUserDto) _then;

/// Create a copy of CurrentUserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? username = null,Object? fullName = null,Object? externalId = freezed,Object? email = freezed,Object? phone = freezed,Object? roles = null,Object? permissions = null,Object? locationIds = null,}) {
  return _then(_CurrentUserDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,locationIds: null == locationIds ? _self._locationIds : locationIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$AuditFieldsDto {

 DateTime? get createdAt; int? get createdBy; DateTime? get updatedAt; int? get updatedBy; int get rowVersion;
/// Create a copy of AuditFieldsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditFieldsDtoCopyWith<AuditFieldsDto> get copyWith => _$AuditFieldsDtoCopyWithImpl<AuditFieldsDto>(this as AuditFieldsDto, _$identity);

  /// Serializes this AuditFieldsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuditFieldsDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditFieldsDto&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.updatedBy, _this.updatedBy) || other.updatedBy == _this.updatedBy)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuditFieldsDto;
  return Object.hash(runtimeType,_this.createdAt,_this.createdBy,_this.updatedAt,_this.updatedBy,_this.rowVersion);
}

@override
String toString() {
  final _this = this as AuditFieldsDto;
  return 'AuditFieldsDto(createdAt: ${_this.createdAt}, createdBy: ${_this.createdBy}, updatedAt: ${_this.updatedAt}, updatedBy: ${_this.updatedBy}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $AuditFieldsDtoCopyWith<$Res>  {
  factory $AuditFieldsDtoCopyWith(AuditFieldsDto value, $Res Function(AuditFieldsDto) _then) = _$AuditFieldsDtoCopyWithImpl;
@useResult
$Res call({
 DateTime? createdAt, int? createdBy, DateTime? updatedAt, int? updatedBy, int rowVersion
});




}
/// @nodoc
class _$AuditFieldsDtoCopyWithImpl<$Res>
    implements $AuditFieldsDtoCopyWith<$Res> {
  _$AuditFieldsDtoCopyWithImpl(this._self, this._then);

  final AuditFieldsDto _self;
  final $Res Function(AuditFieldsDto) _then;

/// Create a copy of AuditFieldsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = freezed,Object? createdBy = freezed,Object? updatedAt = freezed,Object? updatedBy = freezed,Object? rowVersion = null,}) {
  return _then(AuditFieldsDto(
createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as int?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditFieldsDto].
extension AuditFieldsDtoPatterns on AuditFieldsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditFieldsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditFieldsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditFieldsDto value)  $default,){
final _that = this;
switch (_that) {
case _AuditFieldsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditFieldsDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuditFieldsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? createdAt,  int? createdBy,  DateTime? updatedAt,  int? updatedBy,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditFieldsDto() when $default != null:
return $default(_that.createdAt,_that.createdBy,_that.updatedAt,_that.updatedBy,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? createdAt,  int? createdBy,  DateTime? updatedAt,  int? updatedBy,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _AuditFieldsDto():
return $default(_that.createdAt,_that.createdBy,_that.updatedAt,_that.updatedBy,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? createdAt,  int? createdBy,  DateTime? updatedAt,  int? updatedBy,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _AuditFieldsDto() when $default != null:
return $default(_that.createdAt,_that.createdBy,_that.updatedAt,_that.updatedBy,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditFieldsDto implements AuditFieldsDto {
  const _AuditFieldsDto({this.createdAt, this.createdBy, this.updatedAt, this.updatedBy, this.rowVersion = 1});
  factory _AuditFieldsDto.fromJson(Map<String, dynamic> json) => _$AuditFieldsDtoFromJson(json);

@override final  DateTime? createdAt;
@override final  int? createdBy;
@override final  DateTime? updatedAt;
@override final  int? updatedBy;
@override@JsonKey() final  int rowVersion;

/// Create a copy of AuditFieldsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditFieldsDtoCopyWith<_AuditFieldsDto> get copyWith => __$AuditFieldsDtoCopyWithImpl<_AuditFieldsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditFieldsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditFieldsDto&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,createdAt,createdBy,updatedAt,updatedBy,rowVersion);
}

@override
String toString() {
    return 'AuditFieldsDto(createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt, updatedBy: $updatedBy, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$AuditFieldsDtoCopyWith<$Res> implements $AuditFieldsDtoCopyWith<$Res> {
  factory _$AuditFieldsDtoCopyWith(_AuditFieldsDto value, $Res Function(_AuditFieldsDto) _then) = __$AuditFieldsDtoCopyWithImpl;
@override @useResult
$Res call({
 DateTime? createdAt, int? createdBy, DateTime? updatedAt, int? updatedBy, int rowVersion
});




}
/// @nodoc
class __$AuditFieldsDtoCopyWithImpl<$Res>
    implements _$AuditFieldsDtoCopyWith<$Res> {
  __$AuditFieldsDtoCopyWithImpl(this._self, this._then);

  final _AuditFieldsDto _self;
  final $Res Function(_AuditFieldsDto) _then;

/// Create a copy of AuditFieldsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = freezed,Object? createdBy = freezed,Object? updatedAt = freezed,Object? updatedBy = freezed,Object? rowVersion = null,}) {
  return _then(_AuditFieldsDto(
createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as int?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RoleSummaryDto {

 int get id; String get code; String get name; bool get isSystem;
/// Create a copy of RoleSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleSummaryDtoCopyWith<RoleSummaryDto> get copyWith => _$RoleSummaryDtoCopyWithImpl<RoleSummaryDto>(this as RoleSummaryDto, _$identity);

  /// Serializes this RoleSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RoleSummaryDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleSummaryDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isSystem, _this.isSystem) || other.isSystem == _this.isSystem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RoleSummaryDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.isSystem);
}

@override
String toString() {
  final _this = this as RoleSummaryDto;
  return 'RoleSummaryDto(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, isSystem: ${_this.isSystem})';
}


}

/// @nodoc
abstract mixin class $RoleSummaryDtoCopyWith<$Res>  {
  factory $RoleSummaryDtoCopyWith(RoleSummaryDto value, $Res Function(RoleSummaryDto) _then) = _$RoleSummaryDtoCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, bool isSystem
});




}
/// @nodoc
class _$RoleSummaryDtoCopyWithImpl<$Res>
    implements $RoleSummaryDtoCopyWith<$Res> {
  _$RoleSummaryDtoCopyWithImpl(this._self, this._then);

  final RoleSummaryDto _self;
  final $Res Function(RoleSummaryDto) _then;

/// Create a copy of RoleSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? isSystem = null,}) {
  return _then(RoleSummaryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RoleSummaryDto].
extension RoleSummaryDtoPatterns on RoleSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoleSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoleSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoleSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _RoleSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoleSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _RoleSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  bool isSystem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoleSummaryDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.isSystem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  bool isSystem)  $default,) {final _that = this;
switch (_that) {
case _RoleSummaryDto():
return $default(_that.id,_that.code,_that.name,_that.isSystem);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  bool isSystem)?  $default,) {final _that = this;
switch (_that) {
case _RoleSummaryDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.isSystem);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoleSummaryDto implements RoleSummaryDto {
  const _RoleSummaryDto({required this.id, required this.code, required this.name, this.isSystem = false});
  factory _RoleSummaryDto.fromJson(Map<String, dynamic> json) => _$RoleSummaryDtoFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override@JsonKey() final  bool isSystem;

/// Create a copy of RoleSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleSummaryDtoCopyWith<_RoleSummaryDto> get copyWith => __$RoleSummaryDtoCopyWithImpl<_RoleSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoleSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoleSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.isSystem, isSystem) || other.isSystem == isSystem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,isSystem);
}

@override
String toString() {
    return 'RoleSummaryDto(id: $id, code: $code, name: $name, isSystem: $isSystem)';
}


}

/// @nodoc
abstract mixin class _$RoleSummaryDtoCopyWith<$Res> implements $RoleSummaryDtoCopyWith<$Res> {
  factory _$RoleSummaryDtoCopyWith(_RoleSummaryDto value, $Res Function(_RoleSummaryDto) _then) = __$RoleSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, bool isSystem
});




}
/// @nodoc
class __$RoleSummaryDtoCopyWithImpl<$Res>
    implements _$RoleSummaryDtoCopyWith<$Res> {
  __$RoleSummaryDtoCopyWithImpl(this._self, this._then);

  final _RoleSummaryDto _self;
  final $Res Function(_RoleSummaryDto) _then;

/// Create a copy of RoleSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? isSystem = null,}) {
  return _then(_RoleSummaryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UserDto {

 int get id; String get username; String get fullName;/// Keycloak subject (`sub`); the link between the realm and the tenant.
 String? get externalId; String? get email; String? get phone; bool get isActive; List<RoleSummaryDto> get roles; List<int> get locationIds; AuditFieldsDto? get audit;
/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDtoCopyWith<UserDto> get copyWith => _$UserDtoCopyWithImpl<UserDto>(this as UserDto, _$identity);

  /// Serializes this UserDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.externalId, _this.externalId) || other.externalId == _this.externalId)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&const DeepCollectionEquality().equals(other.roles, _this.roles)&&const DeepCollectionEquality().equals(other.locationIds, _this.locationIds)&&(identical(other.audit, _this.audit) || other.audit == _this.audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserDto;
  return Object.hash(runtimeType,_this.id,_this.username,_this.fullName,_this.externalId,_this.email,_this.phone,_this.isActive,const DeepCollectionEquality().hash(_this.roles),const DeepCollectionEquality().hash(_this.locationIds),_this.audit);
}

@override
String toString() {
  final _this = this as UserDto;
  return 'UserDto(id: ${_this.id}, username: ${_this.username}, fullName: ${_this.fullName}, externalId: ${_this.externalId}, email: ${_this.email}, phone: ${_this.phone}, isActive: ${_this.isActive}, roles: ${_this.roles}, locationIds: ${_this.locationIds}, audit: ${_this.audit})';
}


}

/// @nodoc
abstract mixin class $UserDtoCopyWith<$Res>  {
  factory $UserDtoCopyWith(UserDto value, $Res Function(UserDto) _then) = _$UserDtoCopyWithImpl;
@useResult
$Res call({
 int id, String username, String fullName, String? externalId, String? email, String? phone, bool isActive, List<RoleSummaryDto> roles, List<int> locationIds, AuditFieldsDto? audit
});


$AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class _$UserDtoCopyWithImpl<$Res>
    implements $UserDtoCopyWith<$Res> {
  _$UserDtoCopyWithImpl(this._self, this._then);

  final UserDto _self;
  final $Res Function(UserDto) _then;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? fullName = null,Object? externalId = freezed,Object? email = freezed,Object? phone = freezed,Object? isActive = null,Object? roles = null,Object? locationIds = null,Object? audit = freezed,}) {
  return _then(UserDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<RoleSummaryDto>,locationIds: null == locationIds ? _self.locationIds : locationIds // ignore: cast_nullable_to_non_nullable
as List<int>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}
/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuditFieldsDtoCopyWith<$Res>? get audit {
    if (_self.audit == null) {
    return null;
  }

  return $AuditFieldsDtoCopyWith<$Res>(_self.audit!, (value) {
    return _then(_self.copyWith(audit: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserDto].
extension UserDtoPatterns on UserDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDto value)  $default,){
final _that = this;
switch (_that) {
case _UserDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String username,  String fullName,  String? externalId,  String? email,  String? phone,  bool isActive,  List<RoleSummaryDto> roles,  List<int> locationIds,  AuditFieldsDto? audit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that.id,_that.username,_that.fullName,_that.externalId,_that.email,_that.phone,_that.isActive,_that.roles,_that.locationIds,_that.audit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String username,  String fullName,  String? externalId,  String? email,  String? phone,  bool isActive,  List<RoleSummaryDto> roles,  List<int> locationIds,  AuditFieldsDto? audit)  $default,) {final _that = this;
switch (_that) {
case _UserDto():
return $default(_that.id,_that.username,_that.fullName,_that.externalId,_that.email,_that.phone,_that.isActive,_that.roles,_that.locationIds,_that.audit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String username,  String fullName,  String? externalId,  String? email,  String? phone,  bool isActive,  List<RoleSummaryDto> roles,  List<int> locationIds,  AuditFieldsDto? audit)?  $default,) {final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that.id,_that.username,_that.fullName,_that.externalId,_that.email,_that.phone,_that.isActive,_that.roles,_that.locationIds,_that.audit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDto extends UserDto {
  const _UserDto({required this.id, required this.username, required this.fullName, this.externalId, this.email, this.phone, this.isActive = true,  List<RoleSummaryDto> roles = const <RoleSummaryDto>[],  List<int> locationIds = const <int>[], this.audit}): _roles = roles,_locationIds = locationIds,super._();
  factory _UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

@override final  int id;
@override final  String username;
@override final  String fullName;
/// Keycloak subject (`sub`); the link between the realm and the tenant.
@override final  String? externalId;
@override final  String? email;
@override final  String? phone;
@override@JsonKey() final  bool isActive;
 final  List<RoleSummaryDto> _roles;
@override@JsonKey() List<RoleSummaryDto> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

 final  List<int> _locationIds;
@override@JsonKey() List<int> get locationIds {
  if (_locationIds is EqualUnmodifiableListView) return _locationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locationIds);
}

@override final  AuditFieldsDto? audit;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDtoCopyWith<_UserDto> get copyWith => __$UserDtoCopyWithImpl<_UserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDto&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.roles, _roles)&&const DeepCollectionEquality().equals(other.locationIds, _locationIds)&&(identical(other.audit, audit) || other.audit == audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,username,fullName,externalId,email,phone,isActive,const DeepCollectionEquality().hash(_roles),const DeepCollectionEquality().hash(_locationIds),audit);
}

@override
String toString() {
    return 'UserDto(id: $id, username: $username, fullName: $fullName, externalId: $externalId, email: $email, phone: $phone, isActive: $isActive, roles: $roles, locationIds: $locationIds, audit: $audit)';
}


}

/// @nodoc
abstract mixin class _$UserDtoCopyWith<$Res> implements $UserDtoCopyWith<$Res> {
  factory _$UserDtoCopyWith(_UserDto value, $Res Function(_UserDto) _then) = __$UserDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String username, String fullName, String? externalId, String? email, String? phone, bool isActive, List<RoleSummaryDto> roles, List<int> locationIds, AuditFieldsDto? audit
});


@override $AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class __$UserDtoCopyWithImpl<$Res>
    implements _$UserDtoCopyWith<$Res> {
  __$UserDtoCopyWithImpl(this._self, this._then);

  final _UserDto _self;
  final $Res Function(_UserDto) _then;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? fullName = null,Object? externalId = freezed,Object? email = freezed,Object? phone = freezed,Object? isActive = null,Object? roles = null,Object? locationIds = null,Object? audit = freezed,}) {
  return _then(_UserDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<RoleSummaryDto>,locationIds: null == locationIds ? _self._locationIds : locationIds // ignore: cast_nullable_to_non_nullable
as List<int>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuditFieldsDtoCopyWith<$Res>? get audit {
    if (_self.audit == null) {
    return null;
  }

  return $AuditFieldsDtoCopyWith<$Res>(_self.audit!, (value) {
    return _then(_self.copyWith(audit: value));
  });
}
}


/// @nodoc
mixin _$RoleDto {

 int get id; String get code; String get name; bool get isSystem; List<String> get permissions;
/// Create a copy of RoleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleDtoCopyWith<RoleDto> get copyWith => _$RoleDtoCopyWithImpl<RoleDto>(this as RoleDto, _$identity);

  /// Serializes this RoleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RoleDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isSystem, _this.isSystem) || other.isSystem == _this.isSystem)&&const DeepCollectionEquality().equals(other.permissions, _this.permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RoleDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.isSystem,const DeepCollectionEquality().hash(_this.permissions));
}

@override
String toString() {
  final _this = this as RoleDto;
  return 'RoleDto(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, isSystem: ${_this.isSystem}, permissions: ${_this.permissions})';
}


}

/// @nodoc
abstract mixin class $RoleDtoCopyWith<$Res>  {
  factory $RoleDtoCopyWith(RoleDto value, $Res Function(RoleDto) _then) = _$RoleDtoCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, bool isSystem, List<String> permissions
});




}
/// @nodoc
class _$RoleDtoCopyWithImpl<$Res>
    implements $RoleDtoCopyWith<$Res> {
  _$RoleDtoCopyWithImpl(this._self, this._then);

  final RoleDto _self;
  final $Res Function(RoleDto) _then;

/// Create a copy of RoleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? isSystem = null,Object? permissions = null,}) {
  return _then(RoleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RoleDto].
extension RoleDtoPatterns on RoleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoleDto value)  $default,){
final _that = this;
switch (_that) {
case _RoleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoleDto value)?  $default,){
final _that = this;
switch (_that) {
case _RoleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  bool isSystem,  List<String> permissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoleDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.isSystem,_that.permissions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  bool isSystem,  List<String> permissions)  $default,) {final _that = this;
switch (_that) {
case _RoleDto():
return $default(_that.id,_that.code,_that.name,_that.isSystem,_that.permissions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  bool isSystem,  List<String> permissions)?  $default,) {final _that = this;
switch (_that) {
case _RoleDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.isSystem,_that.permissions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoleDto implements RoleDto {
  const _RoleDto({required this.id, required this.code, required this.name, this.isSystem = false,  List<String> permissions = const <String>[]}): _permissions = permissions;
  factory _RoleDto.fromJson(Map<String, dynamic> json) => _$RoleDtoFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override@JsonKey() final  bool isSystem;
 final  List<String> _permissions;
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}


/// Create a copy of RoleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleDtoCopyWith<_RoleDto> get copyWith => __$RoleDtoCopyWithImpl<_RoleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.isSystem, isSystem) || other.isSystem == isSystem)&&const DeepCollectionEquality().equals(other.permissions, _permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,isSystem,const DeepCollectionEquality().hash(_permissions));
}

@override
String toString() {
    return 'RoleDto(id: $id, code: $code, name: $name, isSystem: $isSystem, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class _$RoleDtoCopyWith<$Res> implements $RoleDtoCopyWith<$Res> {
  factory _$RoleDtoCopyWith(_RoleDto value, $Res Function(_RoleDto) _then) = __$RoleDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, bool isSystem, List<String> permissions
});




}
/// @nodoc
class __$RoleDtoCopyWithImpl<$Res>
    implements _$RoleDtoCopyWith<$Res> {
  __$RoleDtoCopyWithImpl(this._self, this._then);

  final _RoleDto _self;
  final $Res Function(_RoleDto) _then;

/// Create a copy of RoleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? isSystem = null,Object? permissions = null,}) {
  return _then(_RoleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$PermissionDto {

 int get id; String get code; String get module; String? get description;
/// Create a copy of PermissionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PermissionDtoCopyWith<PermissionDto> get copyWith => _$PermissionDtoCopyWithImpl<PermissionDto>(this as PermissionDto, _$identity);

  /// Serializes this PermissionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PermissionDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.module, _this.module) || other.module == _this.module)&&(identical(other.description, _this.description) || other.description == _this.description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PermissionDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.module,_this.description);
}

@override
String toString() {
  final _this = this as PermissionDto;
  return 'PermissionDto(id: ${_this.id}, code: ${_this.code}, module: ${_this.module}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $PermissionDtoCopyWith<$Res>  {
  factory $PermissionDtoCopyWith(PermissionDto value, $Res Function(PermissionDto) _then) = _$PermissionDtoCopyWithImpl;
@useResult
$Res call({
 int id, String code, String module, String? description
});




}
/// @nodoc
class _$PermissionDtoCopyWithImpl<$Res>
    implements $PermissionDtoCopyWith<$Res> {
  _$PermissionDtoCopyWithImpl(this._self, this._then);

  final PermissionDto _self;
  final $Res Function(PermissionDto) _then;

/// Create a copy of PermissionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? module = null,Object? description = freezed,}) {
  return _then(PermissionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,module: null == module ? _self.module : module // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PermissionDto].
extension PermissionDtoPatterns on PermissionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PermissionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PermissionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PermissionDto value)  $default,){
final _that = this;
switch (_that) {
case _PermissionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PermissionDto value)?  $default,){
final _that = this;
switch (_that) {
case _PermissionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String module,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PermissionDto() when $default != null:
return $default(_that.id,_that.code,_that.module,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String module,  String? description)  $default,) {final _that = this;
switch (_that) {
case _PermissionDto():
return $default(_that.id,_that.code,_that.module,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String module,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _PermissionDto() when $default != null:
return $default(_that.id,_that.code,_that.module,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PermissionDto implements PermissionDto {
  const _PermissionDto({required this.id, required this.code, required this.module, this.description});
  factory _PermissionDto.fromJson(Map<String, dynamic> json) => _$PermissionDtoFromJson(json);

@override final  int id;
@override final  String code;
@override final  String module;
@override final  String? description;

/// Create a copy of PermissionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PermissionDtoCopyWith<_PermissionDto> get copyWith => __$PermissionDtoCopyWithImpl<_PermissionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PermissionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PermissionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.module, module) || other.module == module)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,module,description);
}

@override
String toString() {
    return 'PermissionDto(id: $id, code: $code, module: $module, description: $description)';
}


}

/// @nodoc
abstract mixin class _$PermissionDtoCopyWith<$Res> implements $PermissionDtoCopyWith<$Res> {
  factory _$PermissionDtoCopyWith(_PermissionDto value, $Res Function(_PermissionDto) _then) = __$PermissionDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String module, String? description
});




}
/// @nodoc
class __$PermissionDtoCopyWithImpl<$Res>
    implements _$PermissionDtoCopyWith<$Res> {
  __$PermissionDtoCopyWithImpl(this._self, this._then);

  final _PermissionDto _self;
  final $Res Function(_PermissionDto) _then;

/// Create a copy of PermissionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? module = null,Object? description = freezed,}) {
  return _then(_PermissionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,module: null == module ? _self.module : module // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
