// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ref_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductRefDto {

 int get id; String get sku; String get name; int get baseUomId; String get baseUomCode; bool? get requiresBatch; bool? get requiresExpiry;
/// Create a copy of ProductRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<ProductRefDto> get copyWith => _$ProductRefDtoCopyWithImpl<ProductRefDto>(this as ProductRefDto, _$identity);

  /// Serializes this ProductRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductRefDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductRefDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sku, _this.sku) || other.sku == _this.sku)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.baseUomId, _this.baseUomId) || other.baseUomId == _this.baseUomId)&&(identical(other.baseUomCode, _this.baseUomCode) || other.baseUomCode == _this.baseUomCode)&&(identical(other.requiresBatch, _this.requiresBatch) || other.requiresBatch == _this.requiresBatch)&&(identical(other.requiresExpiry, _this.requiresExpiry) || other.requiresExpiry == _this.requiresExpiry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductRefDto;
  return Object.hash(runtimeType,_this.id,_this.sku,_this.name,_this.baseUomId,_this.baseUomCode,_this.requiresBatch,_this.requiresExpiry);
}

@override
String toString() {
  final _this = this as ProductRefDto;
  return 'ProductRefDto(id: ${_this.id}, sku: ${_this.sku}, name: ${_this.name}, baseUomId: ${_this.baseUomId}, baseUomCode: ${_this.baseUomCode}, requiresBatch: ${_this.requiresBatch}, requiresExpiry: ${_this.requiresExpiry})';
}


}

/// @nodoc
abstract mixin class $ProductRefDtoCopyWith<$Res>  {
  factory $ProductRefDtoCopyWith(ProductRefDto value, $Res Function(ProductRefDto) _then) = _$ProductRefDtoCopyWithImpl;
@useResult
$Res call({
 int id, String sku, String name, int baseUomId, String baseUomCode, bool? requiresBatch, bool? requiresExpiry
});




}
/// @nodoc
class _$ProductRefDtoCopyWithImpl<$Res>
    implements $ProductRefDtoCopyWith<$Res> {
  _$ProductRefDtoCopyWithImpl(this._self, this._then);

  final ProductRefDto _self;
  final $Res Function(ProductRefDto) _then;

/// Create a copy of ProductRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sku = null,Object? name = null,Object? baseUomId = null,Object? baseUomCode = null,Object? requiresBatch = freezed,Object? requiresExpiry = freezed,}) {
  return _then(ProductRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUomId: null == baseUomId ? _self.baseUomId : baseUomId // ignore: cast_nullable_to_non_nullable
as int,baseUomCode: null == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String,requiresBatch: freezed == requiresBatch ? _self.requiresBatch : requiresBatch // ignore: cast_nullable_to_non_nullable
as bool?,requiresExpiry: freezed == requiresExpiry ? _self.requiresExpiry : requiresExpiry // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductRefDto].
extension ProductRefDtoPatterns on ProductRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductRefDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductRefDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String sku,  String name,  int baseUomId,  String baseUomCode,  bool? requiresBatch,  bool? requiresExpiry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductRefDto() when $default != null:
return $default(_that.id,_that.sku,_that.name,_that.baseUomId,_that.baseUomCode,_that.requiresBatch,_that.requiresExpiry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String sku,  String name,  int baseUomId,  String baseUomCode,  bool? requiresBatch,  bool? requiresExpiry)  $default,) {final _that = this;
switch (_that) {
case _ProductRefDto():
return $default(_that.id,_that.sku,_that.name,_that.baseUomId,_that.baseUomCode,_that.requiresBatch,_that.requiresExpiry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String sku,  String name,  int baseUomId,  String baseUomCode,  bool? requiresBatch,  bool? requiresExpiry)?  $default,) {final _that = this;
switch (_that) {
case _ProductRefDto() when $default != null:
return $default(_that.id,_that.sku,_that.name,_that.baseUomId,_that.baseUomCode,_that.requiresBatch,_that.requiresExpiry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductRefDto extends ProductRefDto {
  const _ProductRefDto({required this.id, required this.sku, required this.name, required this.baseUomId, required this.baseUomCode, this.requiresBatch, this.requiresExpiry}): super._();
  factory _ProductRefDto.fromJson(Map<String, dynamic> json) => _$ProductRefDtoFromJson(json);

@override final  int id;
@override final  String sku;
@override final  String name;
@override final  int baseUomId;
@override final  String baseUomCode;
@override final  bool? requiresBatch;
@override final  bool? requiresExpiry;

/// Create a copy of ProductRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductRefDtoCopyWith<_ProductRefDto> get copyWith => __$ProductRefDtoCopyWithImpl<_ProductRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUomId, baseUomId) || other.baseUomId == baseUomId)&&(identical(other.baseUomCode, baseUomCode) || other.baseUomCode == baseUomCode)&&(identical(other.requiresBatch, requiresBatch) || other.requiresBatch == requiresBatch)&&(identical(other.requiresExpiry, requiresExpiry) || other.requiresExpiry == requiresExpiry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,sku,name,baseUomId,baseUomCode,requiresBatch,requiresExpiry);
}

@override
String toString() {
    return 'ProductRefDto(id: $id, sku: $sku, name: $name, baseUomId: $baseUomId, baseUomCode: $baseUomCode, requiresBatch: $requiresBatch, requiresExpiry: $requiresExpiry)';
}


}

/// @nodoc
abstract mixin class _$ProductRefDtoCopyWith<$Res> implements $ProductRefDtoCopyWith<$Res> {
  factory _$ProductRefDtoCopyWith(_ProductRefDto value, $Res Function(_ProductRefDto) _then) = __$ProductRefDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String sku, String name, int baseUomId, String baseUomCode, bool? requiresBatch, bool? requiresExpiry
});




}
/// @nodoc
class __$ProductRefDtoCopyWithImpl<$Res>
    implements _$ProductRefDtoCopyWith<$Res> {
  __$ProductRefDtoCopyWithImpl(this._self, this._then);

  final _ProductRefDto _self;
  final $Res Function(_ProductRefDto) _then;

/// Create a copy of ProductRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sku = null,Object? name = null,Object? baseUomId = null,Object? baseUomCode = null,Object? requiresBatch = freezed,Object? requiresExpiry = freezed,}) {
  return _then(_ProductRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUomId: null == baseUomId ? _self.baseUomId : baseUomId // ignore: cast_nullable_to_non_nullable
as int,baseUomCode: null == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String,requiresBatch: freezed == requiresBatch ? _self.requiresBatch : requiresBatch // ignore: cast_nullable_to_non_nullable
as bool?,requiresExpiry: freezed == requiresExpiry ? _self.requiresExpiry : requiresExpiry // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$LocationRefDto {

 int get id; String get code; String get name; bool get isVirtual;
/// Create a copy of LocationRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<LocationRefDto> get copyWith => _$LocationRefDtoCopyWithImpl<LocationRefDto>(this as LocationRefDto, _$identity);

  /// Serializes this LocationRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LocationRefDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationRefDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isVirtual, _this.isVirtual) || other.isVirtual == _this.isVirtual));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LocationRefDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.isVirtual);
}

@override
String toString() {
  final _this = this as LocationRefDto;
  return 'LocationRefDto(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, isVirtual: ${_this.isVirtual})';
}


}

/// @nodoc
abstract mixin class $LocationRefDtoCopyWith<$Res>  {
  factory $LocationRefDtoCopyWith(LocationRefDto value, $Res Function(LocationRefDto) _then) = _$LocationRefDtoCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, bool isVirtual
});




}
/// @nodoc
class _$LocationRefDtoCopyWithImpl<$Res>
    implements $LocationRefDtoCopyWith<$Res> {
  _$LocationRefDtoCopyWithImpl(this._self, this._then);

  final LocationRefDto _self;
  final $Res Function(LocationRefDto) _then;

/// Create a copy of LocationRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? isVirtual = null,}) {
  return _then(LocationRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isVirtual: null == isVirtual ? _self.isVirtual : isVirtual // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationRefDto].
extension LocationRefDtoPatterns on LocationRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationRefDto value)  $default,){
final _that = this;
switch (_that) {
case _LocationRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _LocationRefDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  bool isVirtual)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationRefDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.isVirtual);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  bool isVirtual)  $default,) {final _that = this;
switch (_that) {
case _LocationRefDto():
return $default(_that.id,_that.code,_that.name,_that.isVirtual);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  bool isVirtual)?  $default,) {final _that = this;
switch (_that) {
case _LocationRefDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.isVirtual);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationRefDto extends LocationRefDto {
  const _LocationRefDto({required this.id, required this.code, required this.name, this.isVirtual = false}): super._();
  factory _LocationRefDto.fromJson(Map<String, dynamic> json) => _$LocationRefDtoFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override@JsonKey() final  bool isVirtual;

/// Create a copy of LocationRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationRefDtoCopyWith<_LocationRefDto> get copyWith => __$LocationRefDtoCopyWithImpl<_LocationRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.isVirtual, isVirtual) || other.isVirtual == isVirtual));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,isVirtual);
}

@override
String toString() {
    return 'LocationRefDto(id: $id, code: $code, name: $name, isVirtual: $isVirtual)';
}


}

/// @nodoc
abstract mixin class _$LocationRefDtoCopyWith<$Res> implements $LocationRefDtoCopyWith<$Res> {
  factory _$LocationRefDtoCopyWith(_LocationRefDto value, $Res Function(_LocationRefDto) _then) = __$LocationRefDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, bool isVirtual
});




}
/// @nodoc
class __$LocationRefDtoCopyWithImpl<$Res>
    implements _$LocationRefDtoCopyWith<$Res> {
  __$LocationRefDtoCopyWithImpl(this._self, this._then);

  final _LocationRefDto _self;
  final $Res Function(_LocationRefDto) _then;

/// Create a copy of LocationRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? isVirtual = null,}) {
  return _then(_LocationRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isVirtual: null == isVirtual ? _self.isVirtual : isVirtual // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$BatchRefDto {

 int get id; String get batchNo;@NullableDateOnlyConverter() DateTime? get expiryDate; String? get status;
/// Create a copy of BatchRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<BatchRefDto> get copyWith => _$BatchRefDtoCopyWithImpl<BatchRefDto>(this as BatchRefDto, _$identity);

  /// Serializes this BatchRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BatchRefDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchRefDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.batchNo, _this.batchNo) || other.batchNo == _this.batchNo)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BatchRefDto;
  return Object.hash(runtimeType,_this.id,_this.batchNo,_this.expiryDate,_this.status);
}

@override
String toString() {
  final _this = this as BatchRefDto;
  return 'BatchRefDto(id: ${_this.id}, batchNo: ${_this.batchNo}, expiryDate: ${_this.expiryDate}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $BatchRefDtoCopyWith<$Res>  {
  factory $BatchRefDtoCopyWith(BatchRefDto value, $Res Function(BatchRefDto) _then) = _$BatchRefDtoCopyWithImpl;
@useResult
$Res call({
 int id, String batchNo,@NullableDateOnlyConverter() DateTime? expiryDate, String? status
});




}
/// @nodoc
class _$BatchRefDtoCopyWithImpl<$Res>
    implements $BatchRefDtoCopyWith<$Res> {
  _$BatchRefDtoCopyWithImpl(this._self, this._then);

  final BatchRefDto _self;
  final $Res Function(BatchRefDto) _then;

/// Create a copy of BatchRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? batchNo = null,Object? expiryDate = freezed,Object? status = freezed,}) {
  return _then(BatchRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,batchNo: null == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchRefDto].
extension BatchRefDtoPatterns on BatchRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchRefDto value)  $default,){
final _that = this;
switch (_that) {
case _BatchRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _BatchRefDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String batchNo, @NullableDateOnlyConverter()  DateTime? expiryDate,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchRefDto() when $default != null:
return $default(_that.id,_that.batchNo,_that.expiryDate,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String batchNo, @NullableDateOnlyConverter()  DateTime? expiryDate,  String? status)  $default,) {final _that = this;
switch (_that) {
case _BatchRefDto():
return $default(_that.id,_that.batchNo,_that.expiryDate,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String batchNo, @NullableDateOnlyConverter()  DateTime? expiryDate,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _BatchRefDto() when $default != null:
return $default(_that.id,_that.batchNo,_that.expiryDate,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchRefDto extends BatchRefDto {
  const _BatchRefDto({required this.id, required this.batchNo, @NullableDateOnlyConverter() this.expiryDate, this.status}): super._();
  factory _BatchRefDto.fromJson(Map<String, dynamic> json) => _$BatchRefDtoFromJson(json);

@override final  int id;
@override final  String batchNo;
@override@NullableDateOnlyConverter() final  DateTime? expiryDate;
@override final  String? status;

/// Create a copy of BatchRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchRefDtoCopyWith<_BatchRefDto> get copyWith => __$BatchRefDtoCopyWithImpl<_BatchRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.batchNo, batchNo) || other.batchNo == batchNo)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,batchNo,expiryDate,status);
}

@override
String toString() {
    return 'BatchRefDto(id: $id, batchNo: $batchNo, expiryDate: $expiryDate, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BatchRefDtoCopyWith<$Res> implements $BatchRefDtoCopyWith<$Res> {
  factory _$BatchRefDtoCopyWith(_BatchRefDto value, $Res Function(_BatchRefDto) _then) = __$BatchRefDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String batchNo,@NullableDateOnlyConverter() DateTime? expiryDate, String? status
});




}
/// @nodoc
class __$BatchRefDtoCopyWithImpl<$Res>
    implements _$BatchRefDtoCopyWith<$Res> {
  __$BatchRefDtoCopyWithImpl(this._self, this._then);

  final _BatchRefDto _self;
  final $Res Function(_BatchRefDto) _then;

/// Create a copy of BatchRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? batchNo = null,Object? expiryDate = freezed,Object? status = freezed,}) {
  return _then(_BatchRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,batchNo: null == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserRefDto {

 int get id; String? get username; String? get fullName;
/// Create a copy of UserRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserRefDtoCopyWith<UserRefDto> get copyWith => _$UserRefDtoCopyWithImpl<UserRefDto>(this as UserRefDto, _$identity);

  /// Serializes this UserRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserRefDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserRefDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserRefDto;
  return Object.hash(runtimeType,_this.id,_this.username,_this.fullName);
}

@override
String toString() {
  final _this = this as UserRefDto;
  return 'UserRefDto(id: ${_this.id}, username: ${_this.username}, fullName: ${_this.fullName})';
}


}

/// @nodoc
abstract mixin class $UserRefDtoCopyWith<$Res>  {
  factory $UserRefDtoCopyWith(UserRefDto value, $Res Function(UserRefDto) _then) = _$UserRefDtoCopyWithImpl;
@useResult
$Res call({
 int id, String? username, String? fullName
});




}
/// @nodoc
class _$UserRefDtoCopyWithImpl<$Res>
    implements $UserRefDtoCopyWith<$Res> {
  _$UserRefDtoCopyWithImpl(this._self, this._then);

  final UserRefDto _self;
  final $Res Function(UserRefDto) _then;

/// Create a copy of UserRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = freezed,Object? fullName = freezed,}) {
  return _then(UserRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserRefDto].
extension UserRefDtoPatterns on UserRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserRefDto value)  $default,){
final _that = this;
switch (_that) {
case _UserRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserRefDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? username,  String? fullName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserRefDto() when $default != null:
return $default(_that.id,_that.username,_that.fullName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? username,  String? fullName)  $default,) {final _that = this;
switch (_that) {
case _UserRefDto():
return $default(_that.id,_that.username,_that.fullName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? username,  String? fullName)?  $default,) {final _that = this;
switch (_that) {
case _UserRefDto() when $default != null:
return $default(_that.id,_that.username,_that.fullName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserRefDto extends UserRefDto {
  const _UserRefDto({required this.id, this.username, this.fullName}): super._();
  factory _UserRefDto.fromJson(Map<String, dynamic> json) => _$UserRefDtoFromJson(json);

@override final  int id;
@override final  String? username;
@override final  String? fullName;

/// Create a copy of UserRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserRefDtoCopyWith<_UserRefDto> get copyWith => __$UserRefDtoCopyWithImpl<_UserRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.fullName, fullName) || other.fullName == fullName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,username,fullName);
}

@override
String toString() {
    return 'UserRefDto(id: $id, username: $username, fullName: $fullName)';
}


}

/// @nodoc
abstract mixin class _$UserRefDtoCopyWith<$Res> implements $UserRefDtoCopyWith<$Res> {
  factory _$UserRefDtoCopyWith(_UserRefDto value, $Res Function(_UserRefDto) _then) = __$UserRefDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String? username, String? fullName
});




}
/// @nodoc
class __$UserRefDtoCopyWithImpl<$Res>
    implements _$UserRefDtoCopyWith<$Res> {
  __$UserRefDtoCopyWithImpl(this._self, this._then);

  final _UserRefDto _self;
  final $Res Function(_UserRefDto) _then;

/// Create a copy of UserRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = freezed,Object? fullName = freezed,}) {
  return _then(_UserRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SupplierRefDto {

 int get id; String get code; String get name;
/// Create a copy of SupplierRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplierRefDtoCopyWith<SupplierRefDto> get copyWith => _$SupplierRefDtoCopyWithImpl<SupplierRefDto>(this as SupplierRefDto, _$identity);

  /// Serializes this SupplierRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SupplierRefDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupplierRefDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SupplierRefDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name);
}

@override
String toString() {
  final _this = this as SupplierRefDto;
  return 'SupplierRefDto(id: ${_this.id}, code: ${_this.code}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $SupplierRefDtoCopyWith<$Res>  {
  factory $SupplierRefDtoCopyWith(SupplierRefDto value, $Res Function(SupplierRefDto) _then) = _$SupplierRefDtoCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name
});




}
/// @nodoc
class _$SupplierRefDtoCopyWithImpl<$Res>
    implements $SupplierRefDtoCopyWith<$Res> {
  _$SupplierRefDtoCopyWithImpl(this._self, this._then);

  final SupplierRefDto _self;
  final $Res Function(SupplierRefDto) _then;

/// Create a copy of SupplierRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,}) {
  return _then(SupplierRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SupplierRefDto].
extension SupplierRefDtoPatterns on SupplierRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupplierRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupplierRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupplierRefDto value)  $default,){
final _that = this;
switch (_that) {
case _SupplierRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupplierRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _SupplierRefDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupplierRefDto() when $default != null:
return $default(_that.id,_that.code,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name)  $default,) {final _that = this;
switch (_that) {
case _SupplierRefDto():
return $default(_that.id,_that.code,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name)?  $default,) {final _that = this;
switch (_that) {
case _SupplierRefDto() when $default != null:
return $default(_that.id,_that.code,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupplierRefDto extends SupplierRefDto {
  const _SupplierRefDto({required this.id, required this.code, required this.name}): super._();
  factory _SupplierRefDto.fromJson(Map<String, dynamic> json) => _$SupplierRefDtoFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;

/// Create a copy of SupplierRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplierRefDtoCopyWith<_SupplierRefDto> get copyWith => __$SupplierRefDtoCopyWithImpl<_SupplierRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupplierRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupplierRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name);
}

@override
String toString() {
    return 'SupplierRefDto(id: $id, code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class _$SupplierRefDtoCopyWith<$Res> implements $SupplierRefDtoCopyWith<$Res> {
  factory _$SupplierRefDtoCopyWith(_SupplierRefDto value, $Res Function(_SupplierRefDto) _then) = __$SupplierRefDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name
});




}
/// @nodoc
class __$SupplierRefDtoCopyWithImpl<$Res>
    implements _$SupplierRefDtoCopyWith<$Res> {
  __$SupplierRefDtoCopyWithImpl(this._self, this._then);

  final _SupplierRefDto _self;
  final $Res Function(_SupplierRefDto) _then;

/// Create a copy of SupplierRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,}) {
  return _then(_SupplierRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
