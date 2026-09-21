// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'master_data_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UomDto {

 int get id; String get code; String get name; UomClass get uomClass; int get decimals;
/// Create a copy of UomDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UomDtoCopyWith<UomDto> get copyWith => _$UomDtoCopyWithImpl<UomDto>(this as UomDto, _$identity);

  /// Serializes this UomDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UomDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UomDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.uomClass, _this.uomClass) || other.uomClass == _this.uomClass)&&(identical(other.decimals, _this.decimals) || other.decimals == _this.decimals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UomDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.uomClass,_this.decimals);
}

@override
String toString() {
  final _this = this as UomDto;
  return 'UomDto(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, uomClass: ${_this.uomClass}, decimals: ${_this.decimals})';
}


}

/// @nodoc
abstract mixin class $UomDtoCopyWith<$Res>  {
  factory $UomDtoCopyWith(UomDto value, $Res Function(UomDto) _then) = _$UomDtoCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, UomClass uomClass, int decimals
});




}
/// @nodoc
class _$UomDtoCopyWithImpl<$Res>
    implements $UomDtoCopyWith<$Res> {
  _$UomDtoCopyWithImpl(this._self, this._then);

  final UomDto _self;
  final $Res Function(UomDto) _then;

/// Create a copy of UomDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? uomClass = null,Object? decimals = null,}) {
  return _then(UomDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,uomClass: null == uomClass ? _self.uomClass : uomClass // ignore: cast_nullable_to_non_nullable
as UomClass,decimals: null == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UomDto].
extension UomDtoPatterns on UomDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UomDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UomDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UomDto value)  $default,){
final _that = this;
switch (_that) {
case _UomDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UomDto value)?  $default,){
final _that = this;
switch (_that) {
case _UomDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  UomClass uomClass,  int decimals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UomDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.uomClass,_that.decimals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  UomClass uomClass,  int decimals)  $default,) {final _that = this;
switch (_that) {
case _UomDto():
return $default(_that.id,_that.code,_that.name,_that.uomClass,_that.decimals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  UomClass uomClass,  int decimals)?  $default,) {final _that = this;
switch (_that) {
case _UomDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.uomClass,_that.decimals);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UomDto implements UomDto {
  const _UomDto({required this.id, required this.code, required this.name, required this.uomClass, this.decimals = 3});
  factory _UomDto.fromJson(Map<String, dynamic> json) => _$UomDtoFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override final  UomClass uomClass;
@override@JsonKey() final  int decimals;

/// Create a copy of UomDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UomDtoCopyWith<_UomDto> get copyWith => __$UomDtoCopyWithImpl<_UomDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UomDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UomDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.uomClass, uomClass) || other.uomClass == uomClass)&&(identical(other.decimals, decimals) || other.decimals == decimals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,uomClass,decimals);
}

@override
String toString() {
    return 'UomDto(id: $id, code: $code, name: $name, uomClass: $uomClass, decimals: $decimals)';
}


}

/// @nodoc
abstract mixin class _$UomDtoCopyWith<$Res> implements $UomDtoCopyWith<$Res> {
  factory _$UomDtoCopyWith(_UomDto value, $Res Function(_UomDto) _then) = __$UomDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, UomClass uomClass, int decimals
});




}
/// @nodoc
class __$UomDtoCopyWithImpl<$Res>
    implements _$UomDtoCopyWith<$Res> {
  __$UomDtoCopyWithImpl(this._self, this._then);

  final _UomDto _self;
  final $Res Function(_UomDto) _then;

/// Create a copy of UomDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? uomClass = null,Object? decimals = null,}) {
  return _then(_UomDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,uomClass: null == uomClass ? _self.uomClass : uomClass // ignore: cast_nullable_to_non_nullable
as UomClass,decimals: null == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ProductCategoryDto {

 int get id; String get code; String get name; ProductType get productType; String get path; int? get parentId;
/// Create a copy of ProductCategoryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCategoryDtoCopyWith<ProductCategoryDto> get copyWith => _$ProductCategoryDtoCopyWithImpl<ProductCategoryDto>(this as ProductCategoryDto, _$identity);

  /// Serializes this ProductCategoryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductCategoryDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductCategoryDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.productType, _this.productType) || other.productType == _this.productType)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductCategoryDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.productType,_this.path,_this.parentId);
}

@override
String toString() {
  final _this = this as ProductCategoryDto;
  return 'ProductCategoryDto(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, productType: ${_this.productType}, path: ${_this.path}, parentId: ${_this.parentId})';
}


}

/// @nodoc
abstract mixin class $ProductCategoryDtoCopyWith<$Res>  {
  factory $ProductCategoryDtoCopyWith(ProductCategoryDto value, $Res Function(ProductCategoryDto) _then) = _$ProductCategoryDtoCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, ProductType productType, String path, int? parentId
});




}
/// @nodoc
class _$ProductCategoryDtoCopyWithImpl<$Res>
    implements $ProductCategoryDtoCopyWith<$Res> {
  _$ProductCategoryDtoCopyWithImpl(this._self, this._then);

  final ProductCategoryDto _self;
  final $Res Function(ProductCategoryDto) _then;

/// Create a copy of ProductCategoryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? productType = null,Object? path = null,Object? parentId = freezed,}) {
  return _then(ProductCategoryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,productType: null == productType ? _self.productType : productType // ignore: cast_nullable_to_non_nullable
as ProductType,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductCategoryDto].
extension ProductCategoryDtoPatterns on ProductCategoryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductCategoryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductCategoryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductCategoryDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductCategoryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductCategoryDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductCategoryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  ProductType productType,  String path,  int? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductCategoryDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.productType,_that.path,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  ProductType productType,  String path,  int? parentId)  $default,) {final _that = this;
switch (_that) {
case _ProductCategoryDto():
return $default(_that.id,_that.code,_that.name,_that.productType,_that.path,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  ProductType productType,  String path,  int? parentId)?  $default,) {final _that = this;
switch (_that) {
case _ProductCategoryDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.productType,_that.path,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductCategoryDto implements ProductCategoryDto {
  const _ProductCategoryDto({required this.id, required this.code, required this.name, required this.productType, required this.path, this.parentId});
  factory _ProductCategoryDto.fromJson(Map<String, dynamic> json) => _$ProductCategoryDtoFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override final  ProductType productType;
@override final  String path;
@override final  int? parentId;

/// Create a copy of ProductCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCategoryDtoCopyWith<_ProductCategoryDto> get copyWith => __$ProductCategoryDtoCopyWithImpl<_ProductCategoryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductCategoryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductCategoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.productType, productType) || other.productType == productType)&&(identical(other.path, path) || other.path == path)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,productType,path,parentId);
}

@override
String toString() {
    return 'ProductCategoryDto(id: $id, code: $code, name: $name, productType: $productType, path: $path, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$ProductCategoryDtoCopyWith<$Res> implements $ProductCategoryDtoCopyWith<$Res> {
  factory _$ProductCategoryDtoCopyWith(_ProductCategoryDto value, $Res Function(_ProductCategoryDto) _then) = __$ProductCategoryDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, ProductType productType, String path, int? parentId
});




}
/// @nodoc
class __$ProductCategoryDtoCopyWithImpl<$Res>
    implements _$ProductCategoryDtoCopyWith<$Res> {
  __$ProductCategoryDtoCopyWithImpl(this._self, this._then);

  final _ProductCategoryDto _self;
  final $Res Function(_ProductCategoryDto) _then;

/// Create a copy of ProductCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? productType = null,Object? path = null,Object? parentId = freezed,}) {
  return _then(_ProductCategoryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,productType: null == productType ? _self.productType : productType // ignore: cast_nullable_to_non_nullable
as ProductType,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ProductUomDto {

 int get id; int get uomId; Decimal get factorToBase;@DateOnlyConverter() DateTime get validFrom; String? get uomCode; bool get isPurchaseDefault; bool get isIssueDefault;@NullableDateOnlyConverter() DateTime? get validTo;
/// Create a copy of ProductUomDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductUomDtoCopyWith<ProductUomDto> get copyWith => _$ProductUomDtoCopyWithImpl<ProductUomDto>(this as ProductUomDto, _$identity);

  /// Serializes this ProductUomDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductUomDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductUomDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.factorToBase, _this.factorToBase) || other.factorToBase == _this.factorToBase)&&(identical(other.validFrom, _this.validFrom) || other.validFrom == _this.validFrom)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.isPurchaseDefault, _this.isPurchaseDefault) || other.isPurchaseDefault == _this.isPurchaseDefault)&&(identical(other.isIssueDefault, _this.isIssueDefault) || other.isIssueDefault == _this.isIssueDefault)&&(identical(other.validTo, _this.validTo) || other.validTo == _this.validTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductUomDto;
  return Object.hash(runtimeType,_this.id,_this.uomId,_this.factorToBase,_this.validFrom,_this.uomCode,_this.isPurchaseDefault,_this.isIssueDefault,_this.validTo);
}

@override
String toString() {
  final _this = this as ProductUomDto;
  return 'ProductUomDto(id: ${_this.id}, uomId: ${_this.uomId}, factorToBase: ${_this.factorToBase}, validFrom: ${_this.validFrom}, uomCode: ${_this.uomCode}, isPurchaseDefault: ${_this.isPurchaseDefault}, isIssueDefault: ${_this.isIssueDefault}, validTo: ${_this.validTo})';
}


}

/// @nodoc
abstract mixin class $ProductUomDtoCopyWith<$Res>  {
  factory $ProductUomDtoCopyWith(ProductUomDto value, $Res Function(ProductUomDto) _then) = _$ProductUomDtoCopyWithImpl;
@useResult
$Res call({
 int id, int uomId, Decimal factorToBase,@DateOnlyConverter() DateTime validFrom, String? uomCode, bool isPurchaseDefault, bool isIssueDefault,@NullableDateOnlyConverter() DateTime? validTo
});




}
/// @nodoc
class _$ProductUomDtoCopyWithImpl<$Res>
    implements $ProductUomDtoCopyWith<$Res> {
  _$ProductUomDtoCopyWithImpl(this._self, this._then);

  final ProductUomDto _self;
  final $Res Function(ProductUomDto) _then;

/// Create a copy of ProductUomDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uomId = null,Object? factorToBase = null,Object? validFrom = null,Object? uomCode = freezed,Object? isPurchaseDefault = null,Object? isIssueDefault = null,Object? validTo = freezed,}) {
  return _then(ProductUomDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,factorToBase: null == factorToBase ? _self.factorToBase : factorToBase // ignore: cast_nullable_to_non_nullable
as Decimal,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,isPurchaseDefault: null == isPurchaseDefault ? _self.isPurchaseDefault : isPurchaseDefault // ignore: cast_nullable_to_non_nullable
as bool,isIssueDefault: null == isIssueDefault ? _self.isIssueDefault : isIssueDefault // ignore: cast_nullable_to_non_nullable
as bool,validTo: freezed == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductUomDto].
extension ProductUomDtoPatterns on ProductUomDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductUomDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductUomDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductUomDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductUomDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductUomDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductUomDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int uomId,  Decimal factorToBase, @DateOnlyConverter()  DateTime validFrom,  String? uomCode,  bool isPurchaseDefault,  bool isIssueDefault, @NullableDateOnlyConverter()  DateTime? validTo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductUomDto() when $default != null:
return $default(_that.id,_that.uomId,_that.factorToBase,_that.validFrom,_that.uomCode,_that.isPurchaseDefault,_that.isIssueDefault,_that.validTo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int uomId,  Decimal factorToBase, @DateOnlyConverter()  DateTime validFrom,  String? uomCode,  bool isPurchaseDefault,  bool isIssueDefault, @NullableDateOnlyConverter()  DateTime? validTo)  $default,) {final _that = this;
switch (_that) {
case _ProductUomDto():
return $default(_that.id,_that.uomId,_that.factorToBase,_that.validFrom,_that.uomCode,_that.isPurchaseDefault,_that.isIssueDefault,_that.validTo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int uomId,  Decimal factorToBase, @DateOnlyConverter()  DateTime validFrom,  String? uomCode,  bool isPurchaseDefault,  bool isIssueDefault, @NullableDateOnlyConverter()  DateTime? validTo)?  $default,) {final _that = this;
switch (_that) {
case _ProductUomDto() when $default != null:
return $default(_that.id,_that.uomId,_that.factorToBase,_that.validFrom,_that.uomCode,_that.isPurchaseDefault,_that.isIssueDefault,_that.validTo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductUomDto implements ProductUomDto {
  const _ProductUomDto({required this.id, required this.uomId, required this.factorToBase, @DateOnlyConverter() required this.validFrom, this.uomCode, this.isPurchaseDefault = false, this.isIssueDefault = false, @NullableDateOnlyConverter() this.validTo});
  factory _ProductUomDto.fromJson(Map<String, dynamic> json) => _$ProductUomDtoFromJson(json);

@override final  int id;
@override final  int uomId;
@override final  Decimal factorToBase;
@override@DateOnlyConverter() final  DateTime validFrom;
@override final  String? uomCode;
@override@JsonKey() final  bool isPurchaseDefault;
@override@JsonKey() final  bool isIssueDefault;
@override@NullableDateOnlyConverter() final  DateTime? validTo;

/// Create a copy of ProductUomDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductUomDtoCopyWith<_ProductUomDto> get copyWith => __$ProductUomDtoCopyWithImpl<_ProductUomDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductUomDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductUomDto&&(identical(other.id, id) || other.id == id)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.factorToBase, factorToBase) || other.factorToBase == factorToBase)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.isPurchaseDefault, isPurchaseDefault) || other.isPurchaseDefault == isPurchaseDefault)&&(identical(other.isIssueDefault, isIssueDefault) || other.isIssueDefault == isIssueDefault)&&(identical(other.validTo, validTo) || other.validTo == validTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,uomId,factorToBase,validFrom,uomCode,isPurchaseDefault,isIssueDefault,validTo);
}

@override
String toString() {
    return 'ProductUomDto(id: $id, uomId: $uomId, factorToBase: $factorToBase, validFrom: $validFrom, uomCode: $uomCode, isPurchaseDefault: $isPurchaseDefault, isIssueDefault: $isIssueDefault, validTo: $validTo)';
}


}

/// @nodoc
abstract mixin class _$ProductUomDtoCopyWith<$Res> implements $ProductUomDtoCopyWith<$Res> {
  factory _$ProductUomDtoCopyWith(_ProductUomDto value, $Res Function(_ProductUomDto) _then) = __$ProductUomDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int uomId, Decimal factorToBase,@DateOnlyConverter() DateTime validFrom, String? uomCode, bool isPurchaseDefault, bool isIssueDefault,@NullableDateOnlyConverter() DateTime? validTo
});




}
/// @nodoc
class __$ProductUomDtoCopyWithImpl<$Res>
    implements _$ProductUomDtoCopyWith<$Res> {
  __$ProductUomDtoCopyWithImpl(this._self, this._then);

  final _ProductUomDto _self;
  final $Res Function(_ProductUomDto) _then;

/// Create a copy of ProductUomDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uomId = null,Object? factorToBase = null,Object? validFrom = null,Object? uomCode = freezed,Object? isPurchaseDefault = null,Object? isIssueDefault = null,Object? validTo = freezed,}) {
  return _then(_ProductUomDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,factorToBase: null == factorToBase ? _self.factorToBase : factorToBase // ignore: cast_nullable_to_non_nullable
as Decimal,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,isPurchaseDefault: null == isPurchaseDefault ? _self.isPurchaseDefault : isPurchaseDefault // ignore: cast_nullable_to_non_nullable
as bool,isIssueDefault: null == isIssueDefault ? _self.isIssueDefault : isIssueDefault // ignore: cast_nullable_to_non_nullable
as bool,validTo: freezed == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ProductDto {

 int get id; String get sku; String get name; int get categoryId; int get baseUomId; Decimal get vatRate; String? get barcode; String? get categoryName; String? get brand; String? get baseUomCode; int? get defaultSupplierId; Quantity? get minStock; Quantity? get maxStock; Quantity? get reorderPoint; bool get requiresBatch; bool get requiresExpiry; IssueStrategy get issueStrategy; int? get shelfLifeDays; String? get imageKey; bool get isActive; int get rowVersion; List<ProductUomDto> get uoms; Money? get avgUnitCost; Money? get lastPurchasePrice; String? get currency;
/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductDtoCopyWith<ProductDto> get copyWith => _$ProductDtoCopyWithImpl<ProductDto>(this as ProductDto, _$identity);

  /// Serializes this ProductDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sku, _this.sku) || other.sku == _this.sku)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.baseUomId, _this.baseUomId) || other.baseUomId == _this.baseUomId)&&(identical(other.vatRate, _this.vatRate) || other.vatRate == _this.vatRate)&&(identical(other.barcode, _this.barcode) || other.barcode == _this.barcode)&&(identical(other.categoryName, _this.categoryName) || other.categoryName == _this.categoryName)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.baseUomCode, _this.baseUomCode) || other.baseUomCode == _this.baseUomCode)&&(identical(other.defaultSupplierId, _this.defaultSupplierId) || other.defaultSupplierId == _this.defaultSupplierId)&&(identical(other.minStock, _this.minStock) || other.minStock == _this.minStock)&&(identical(other.maxStock, _this.maxStock) || other.maxStock == _this.maxStock)&&(identical(other.reorderPoint, _this.reorderPoint) || other.reorderPoint == _this.reorderPoint)&&(identical(other.requiresBatch, _this.requiresBatch) || other.requiresBatch == _this.requiresBatch)&&(identical(other.requiresExpiry, _this.requiresExpiry) || other.requiresExpiry == _this.requiresExpiry)&&(identical(other.issueStrategy, _this.issueStrategy) || other.issueStrategy == _this.issueStrategy)&&(identical(other.shelfLifeDays, _this.shelfLifeDays) || other.shelfLifeDays == _this.shelfLifeDays)&&(identical(other.imageKey, _this.imageKey) || other.imageKey == _this.imageKey)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.uoms, _this.uoms)&&(identical(other.avgUnitCost, _this.avgUnitCost) || other.avgUnitCost == _this.avgUnitCost)&&(identical(other.lastPurchasePrice, _this.lastPurchasePrice) || other.lastPurchasePrice == _this.lastPurchasePrice)&&(identical(other.currency, _this.currency) || other.currency == _this.currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductDto;
  return Object.hashAll([runtimeType,_this.id,_this.sku,_this.name,_this.categoryId,_this.baseUomId,_this.vatRate,_this.barcode,_this.categoryName,_this.brand,_this.baseUomCode,_this.defaultSupplierId,_this.minStock,_this.maxStock,_this.reorderPoint,_this.requiresBatch,_this.requiresExpiry,_this.issueStrategy,_this.shelfLifeDays,_this.imageKey,_this.isActive,_this.rowVersion,const DeepCollectionEquality().hash(_this.uoms),_this.avgUnitCost,_this.lastPurchasePrice,_this.currency]);
}

@override
String toString() {
  final _this = this as ProductDto;
  return 'ProductDto(id: ${_this.id}, sku: ${_this.sku}, name: ${_this.name}, categoryId: ${_this.categoryId}, baseUomId: ${_this.baseUomId}, vatRate: ${_this.vatRate}, barcode: ${_this.barcode}, categoryName: ${_this.categoryName}, brand: ${_this.brand}, baseUomCode: ${_this.baseUomCode}, defaultSupplierId: ${_this.defaultSupplierId}, minStock: ${_this.minStock}, maxStock: ${_this.maxStock}, reorderPoint: ${_this.reorderPoint}, requiresBatch: ${_this.requiresBatch}, requiresExpiry: ${_this.requiresExpiry}, issueStrategy: ${_this.issueStrategy}, shelfLifeDays: ${_this.shelfLifeDays}, imageKey: ${_this.imageKey}, isActive: ${_this.isActive}, rowVersion: ${_this.rowVersion}, uoms: ${_this.uoms}, avgUnitCost: ${_this.avgUnitCost}, lastPurchasePrice: ${_this.lastPurchasePrice}, currency: ${_this.currency})';
}


}

/// @nodoc
abstract mixin class $ProductDtoCopyWith<$Res>  {
  factory $ProductDtoCopyWith(ProductDto value, $Res Function(ProductDto) _then) = _$ProductDtoCopyWithImpl;
@useResult
$Res call({
 int id, String sku, String name, int categoryId, int baseUomId, Decimal vatRate, String? barcode, String? categoryName, String? brand, String? baseUomCode, int? defaultSupplierId, Quantity? minStock, Quantity? maxStock, Quantity? reorderPoint, bool requiresBatch, bool requiresExpiry, IssueStrategy issueStrategy, int? shelfLifeDays, String? imageKey, bool isActive, int rowVersion, List<ProductUomDto> uoms, Money? avgUnitCost, Money? lastPurchasePrice, String? currency
});




}
/// @nodoc
class _$ProductDtoCopyWithImpl<$Res>
    implements $ProductDtoCopyWith<$Res> {
  _$ProductDtoCopyWithImpl(this._self, this._then);

  final ProductDto _self;
  final $Res Function(ProductDto) _then;

/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sku = null,Object? name = null,Object? categoryId = null,Object? baseUomId = null,Object? vatRate = null,Object? barcode = freezed,Object? categoryName = freezed,Object? brand = freezed,Object? baseUomCode = freezed,Object? defaultSupplierId = freezed,Object? minStock = freezed,Object? maxStock = freezed,Object? reorderPoint = freezed,Object? requiresBatch = null,Object? requiresExpiry = null,Object? issueStrategy = null,Object? shelfLifeDays = freezed,Object? imageKey = freezed,Object? isActive = null,Object? rowVersion = null,Object? uoms = null,Object? avgUnitCost = freezed,Object? lastPurchasePrice = freezed,Object? currency = freezed,}) {
  return _then(ProductDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,baseUomId: null == baseUomId ? _self.baseUomId : baseUomId // ignore: cast_nullable_to_non_nullable
as int,vatRate: null == vatRate ? _self.vatRate : vatRate // ignore: cast_nullable_to_non_nullable
as Decimal,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,defaultSupplierId: freezed == defaultSupplierId ? _self.defaultSupplierId : defaultSupplierId // ignore: cast_nullable_to_non_nullable
as int?,minStock: freezed == minStock ? _self.minStock : minStock // ignore: cast_nullable_to_non_nullable
as Quantity?,maxStock: freezed == maxStock ? _self.maxStock : maxStock // ignore: cast_nullable_to_non_nullable
as Quantity?,reorderPoint: freezed == reorderPoint ? _self.reorderPoint : reorderPoint // ignore: cast_nullable_to_non_nullable
as Quantity?,requiresBatch: null == requiresBatch ? _self.requiresBatch : requiresBatch // ignore: cast_nullable_to_non_nullable
as bool,requiresExpiry: null == requiresExpiry ? _self.requiresExpiry : requiresExpiry // ignore: cast_nullable_to_non_nullable
as bool,issueStrategy: null == issueStrategy ? _self.issueStrategy : issueStrategy // ignore: cast_nullable_to_non_nullable
as IssueStrategy,shelfLifeDays: freezed == shelfLifeDays ? _self.shelfLifeDays : shelfLifeDays // ignore: cast_nullable_to_non_nullable
as int?,imageKey: freezed == imageKey ? _self.imageKey : imageKey // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,uoms: null == uoms ? _self.uoms : uoms // ignore: cast_nullable_to_non_nullable
as List<ProductUomDto>,avgUnitCost: freezed == avgUnitCost ? _self.avgUnitCost : avgUnitCost // ignore: cast_nullable_to_non_nullable
as Money?,lastPurchasePrice: freezed == lastPurchasePrice ? _self.lastPurchasePrice : lastPurchasePrice // ignore: cast_nullable_to_non_nullable
as Money?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductDto].
extension ProductDtoPatterns on ProductDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String sku,  String name,  int categoryId,  int baseUomId,  Decimal vatRate,  String? barcode,  String? categoryName,  String? brand,  String? baseUomCode,  int? defaultSupplierId,  Quantity? minStock,  Quantity? maxStock,  Quantity? reorderPoint,  bool requiresBatch,  bool requiresExpiry,  IssueStrategy issueStrategy,  int? shelfLifeDays,  String? imageKey,  bool isActive,  int rowVersion,  List<ProductUomDto> uoms,  Money? avgUnitCost,  Money? lastPurchasePrice,  String? currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductDto() when $default != null:
return $default(_that.id,_that.sku,_that.name,_that.categoryId,_that.baseUomId,_that.vatRate,_that.barcode,_that.categoryName,_that.brand,_that.baseUomCode,_that.defaultSupplierId,_that.minStock,_that.maxStock,_that.reorderPoint,_that.requiresBatch,_that.requiresExpiry,_that.issueStrategy,_that.shelfLifeDays,_that.imageKey,_that.isActive,_that.rowVersion,_that.uoms,_that.avgUnitCost,_that.lastPurchasePrice,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String sku,  String name,  int categoryId,  int baseUomId,  Decimal vatRate,  String? barcode,  String? categoryName,  String? brand,  String? baseUomCode,  int? defaultSupplierId,  Quantity? minStock,  Quantity? maxStock,  Quantity? reorderPoint,  bool requiresBatch,  bool requiresExpiry,  IssueStrategy issueStrategy,  int? shelfLifeDays,  String? imageKey,  bool isActive,  int rowVersion,  List<ProductUomDto> uoms,  Money? avgUnitCost,  Money? lastPurchasePrice,  String? currency)  $default,) {final _that = this;
switch (_that) {
case _ProductDto():
return $default(_that.id,_that.sku,_that.name,_that.categoryId,_that.baseUomId,_that.vatRate,_that.barcode,_that.categoryName,_that.brand,_that.baseUomCode,_that.defaultSupplierId,_that.minStock,_that.maxStock,_that.reorderPoint,_that.requiresBatch,_that.requiresExpiry,_that.issueStrategy,_that.shelfLifeDays,_that.imageKey,_that.isActive,_that.rowVersion,_that.uoms,_that.avgUnitCost,_that.lastPurchasePrice,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String sku,  String name,  int categoryId,  int baseUomId,  Decimal vatRate,  String? barcode,  String? categoryName,  String? brand,  String? baseUomCode,  int? defaultSupplierId,  Quantity? minStock,  Quantity? maxStock,  Quantity? reorderPoint,  bool requiresBatch,  bool requiresExpiry,  IssueStrategy issueStrategy,  int? shelfLifeDays,  String? imageKey,  bool isActive,  int rowVersion,  List<ProductUomDto> uoms,  Money? avgUnitCost,  Money? lastPurchasePrice,  String? currency)?  $default,) {final _that = this;
switch (_that) {
case _ProductDto() when $default != null:
return $default(_that.id,_that.sku,_that.name,_that.categoryId,_that.baseUomId,_that.vatRate,_that.barcode,_that.categoryName,_that.brand,_that.baseUomCode,_that.defaultSupplierId,_that.minStock,_that.maxStock,_that.reorderPoint,_that.requiresBatch,_that.requiresExpiry,_that.issueStrategy,_that.shelfLifeDays,_that.imageKey,_that.isActive,_that.rowVersion,_that.uoms,_that.avgUnitCost,_that.lastPurchasePrice,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductDto extends ProductDto {
  const _ProductDto({required this.id, required this.sku, required this.name, required this.categoryId, required this.baseUomId, required this.vatRate, this.barcode, this.categoryName, this.brand, this.baseUomCode, this.defaultSupplierId, this.minStock, this.maxStock, this.reorderPoint, this.requiresBatch = false, this.requiresExpiry = false, this.issueStrategy = IssueStrategy.fefo, this.shelfLifeDays, this.imageKey, this.isActive = true, this.rowVersion = 1,  List<ProductUomDto> uoms = const <ProductUomDto>[], this.avgUnitCost, this.lastPurchasePrice, this.currency}): _uoms = uoms,super._();
  factory _ProductDto.fromJson(Map<String, dynamic> json) => _$ProductDtoFromJson(json);

@override final  int id;
@override final  String sku;
@override final  String name;
@override final  int categoryId;
@override final  int baseUomId;
@override final  Decimal vatRate;
@override final  String? barcode;
@override final  String? categoryName;
@override final  String? brand;
@override final  String? baseUomCode;
@override final  int? defaultSupplierId;
@override final  Quantity? minStock;
@override final  Quantity? maxStock;
@override final  Quantity? reorderPoint;
@override@JsonKey() final  bool requiresBatch;
@override@JsonKey() final  bool requiresExpiry;
@override@JsonKey() final  IssueStrategy issueStrategy;
@override final  int? shelfLifeDays;
@override final  String? imageKey;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  int rowVersion;
 final  List<ProductUomDto> _uoms;
@override@JsonKey() List<ProductUomDto> get uoms {
  if (_uoms is EqualUnmodifiableListView) return _uoms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uoms);
}

@override final  Money? avgUnitCost;
@override final  Money? lastPurchasePrice;
@override final  String? currency;

/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductDtoCopyWith<_ProductDto> get copyWith => __$ProductDtoCopyWithImpl<_ProductDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.name, name) || other.name == name)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.baseUomId, baseUomId) || other.baseUomId == baseUomId)&&(identical(other.vatRate, vatRate) || other.vatRate == vatRate)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.baseUomCode, baseUomCode) || other.baseUomCode == baseUomCode)&&(identical(other.defaultSupplierId, defaultSupplierId) || other.defaultSupplierId == defaultSupplierId)&&(identical(other.minStock, minStock) || other.minStock == minStock)&&(identical(other.maxStock, maxStock) || other.maxStock == maxStock)&&(identical(other.reorderPoint, reorderPoint) || other.reorderPoint == reorderPoint)&&(identical(other.requiresBatch, requiresBatch) || other.requiresBatch == requiresBatch)&&(identical(other.requiresExpiry, requiresExpiry) || other.requiresExpiry == requiresExpiry)&&(identical(other.issueStrategy, issueStrategy) || other.issueStrategy == issueStrategy)&&(identical(other.shelfLifeDays, shelfLifeDays) || other.shelfLifeDays == shelfLifeDays)&&(identical(other.imageKey, imageKey) || other.imageKey == imageKey)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.uoms, _uoms)&&(identical(other.avgUnitCost, avgUnitCost) || other.avgUnitCost == avgUnitCost)&&(identical(other.lastPurchasePrice, lastPurchasePrice) || other.lastPurchasePrice == lastPurchasePrice)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,sku,name,categoryId,baseUomId,vatRate,barcode,categoryName,brand,baseUomCode,defaultSupplierId,minStock,maxStock,reorderPoint,requiresBatch,requiresExpiry,issueStrategy,shelfLifeDays,imageKey,isActive,rowVersion,const DeepCollectionEquality().hash(_uoms),avgUnitCost,lastPurchasePrice,currency]);
}

@override
String toString() {
    return 'ProductDto(id: $id, sku: $sku, name: $name, categoryId: $categoryId, baseUomId: $baseUomId, vatRate: $vatRate, barcode: $barcode, categoryName: $categoryName, brand: $brand, baseUomCode: $baseUomCode, defaultSupplierId: $defaultSupplierId, minStock: $minStock, maxStock: $maxStock, reorderPoint: $reorderPoint, requiresBatch: $requiresBatch, requiresExpiry: $requiresExpiry, issueStrategy: $issueStrategy, shelfLifeDays: $shelfLifeDays, imageKey: $imageKey, isActive: $isActive, rowVersion: $rowVersion, uoms: $uoms, avgUnitCost: $avgUnitCost, lastPurchasePrice: $lastPurchasePrice, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$ProductDtoCopyWith<$Res> implements $ProductDtoCopyWith<$Res> {
  factory _$ProductDtoCopyWith(_ProductDto value, $Res Function(_ProductDto) _then) = __$ProductDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String sku, String name, int categoryId, int baseUomId, Decimal vatRate, String? barcode, String? categoryName, String? brand, String? baseUomCode, int? defaultSupplierId, Quantity? minStock, Quantity? maxStock, Quantity? reorderPoint, bool requiresBatch, bool requiresExpiry, IssueStrategy issueStrategy, int? shelfLifeDays, String? imageKey, bool isActive, int rowVersion, List<ProductUomDto> uoms, Money? avgUnitCost, Money? lastPurchasePrice, String? currency
});




}
/// @nodoc
class __$ProductDtoCopyWithImpl<$Res>
    implements _$ProductDtoCopyWith<$Res> {
  __$ProductDtoCopyWithImpl(this._self, this._then);

  final _ProductDto _self;
  final $Res Function(_ProductDto) _then;

/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sku = null,Object? name = null,Object? categoryId = null,Object? baseUomId = null,Object? vatRate = null,Object? barcode = freezed,Object? categoryName = freezed,Object? brand = freezed,Object? baseUomCode = freezed,Object? defaultSupplierId = freezed,Object? minStock = freezed,Object? maxStock = freezed,Object? reorderPoint = freezed,Object? requiresBatch = null,Object? requiresExpiry = null,Object? issueStrategy = null,Object? shelfLifeDays = freezed,Object? imageKey = freezed,Object? isActive = null,Object? rowVersion = null,Object? uoms = null,Object? avgUnitCost = freezed,Object? lastPurchasePrice = freezed,Object? currency = freezed,}) {
  return _then(_ProductDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,baseUomId: null == baseUomId ? _self.baseUomId : baseUomId // ignore: cast_nullable_to_non_nullable
as int,vatRate: null == vatRate ? _self.vatRate : vatRate // ignore: cast_nullable_to_non_nullable
as Decimal,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,defaultSupplierId: freezed == defaultSupplierId ? _self.defaultSupplierId : defaultSupplierId // ignore: cast_nullable_to_non_nullable
as int?,minStock: freezed == minStock ? _self.minStock : minStock // ignore: cast_nullable_to_non_nullable
as Quantity?,maxStock: freezed == maxStock ? _self.maxStock : maxStock // ignore: cast_nullable_to_non_nullable
as Quantity?,reorderPoint: freezed == reorderPoint ? _self.reorderPoint : reorderPoint // ignore: cast_nullable_to_non_nullable
as Quantity?,requiresBatch: null == requiresBatch ? _self.requiresBatch : requiresBatch // ignore: cast_nullable_to_non_nullable
as bool,requiresExpiry: null == requiresExpiry ? _self.requiresExpiry : requiresExpiry // ignore: cast_nullable_to_non_nullable
as bool,issueStrategy: null == issueStrategy ? _self.issueStrategy : issueStrategy // ignore: cast_nullable_to_non_nullable
as IssueStrategy,shelfLifeDays: freezed == shelfLifeDays ? _self.shelfLifeDays : shelfLifeDays // ignore: cast_nullable_to_non_nullable
as int?,imageKey: freezed == imageKey ? _self.imageKey : imageKey // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,uoms: null == uoms ? _self._uoms : uoms // ignore: cast_nullable_to_non_nullable
as List<ProductUomDto>,avgUnitCost: freezed == avgUnitCost ? _self.avgUnitCost : avgUnitCost // ignore: cast_nullable_to_non_nullable
as Money?,lastPurchasePrice: freezed == lastPurchasePrice ? _self.lastPurchasePrice : lastPurchasePrice // ignore: cast_nullable_to_non_nullable
as Money?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SupplierDto {

 int get id; String get code; String get name; String get currency; String? get taxId; String? get contactPerson; String? get phone; String? get email; String? get address; String? get paymentTerms; String? get deliveryTerms; String? get incoterms; bool get isApprovedFoodSupplier; bool get isActive; int get rowVersion;
/// Create a copy of SupplierDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplierDtoCopyWith<SupplierDto> get copyWith => _$SupplierDtoCopyWithImpl<SupplierDto>(this as SupplierDto, _$identity);

  /// Serializes this SupplierDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SupplierDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupplierDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.taxId, _this.taxId) || other.taxId == _this.taxId)&&(identical(other.contactPerson, _this.contactPerson) || other.contactPerson == _this.contactPerson)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.paymentTerms, _this.paymentTerms) || other.paymentTerms == _this.paymentTerms)&&(identical(other.deliveryTerms, _this.deliveryTerms) || other.deliveryTerms == _this.deliveryTerms)&&(identical(other.incoterms, _this.incoterms) || other.incoterms == _this.incoterms)&&(identical(other.isApprovedFoodSupplier, _this.isApprovedFoodSupplier) || other.isApprovedFoodSupplier == _this.isApprovedFoodSupplier)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SupplierDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.currency,_this.taxId,_this.contactPerson,_this.phone,_this.email,_this.address,_this.paymentTerms,_this.deliveryTerms,_this.incoterms,_this.isApprovedFoodSupplier,_this.isActive,_this.rowVersion);
}

@override
String toString() {
  final _this = this as SupplierDto;
  return 'SupplierDto(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, currency: ${_this.currency}, taxId: ${_this.taxId}, contactPerson: ${_this.contactPerson}, phone: ${_this.phone}, email: ${_this.email}, address: ${_this.address}, paymentTerms: ${_this.paymentTerms}, deliveryTerms: ${_this.deliveryTerms}, incoterms: ${_this.incoterms}, isApprovedFoodSupplier: ${_this.isApprovedFoodSupplier}, isActive: ${_this.isActive}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $SupplierDtoCopyWith<$Res>  {
  factory $SupplierDtoCopyWith(SupplierDto value, $Res Function(SupplierDto) _then) = _$SupplierDtoCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, String currency, String? taxId, String? contactPerson, String? phone, String? email, String? address, String? paymentTerms, String? deliveryTerms, String? incoterms, bool isApprovedFoodSupplier, bool isActive, int rowVersion
});




}
/// @nodoc
class _$SupplierDtoCopyWithImpl<$Res>
    implements $SupplierDtoCopyWith<$Res> {
  _$SupplierDtoCopyWithImpl(this._self, this._then);

  final SupplierDto _self;
  final $Res Function(SupplierDto) _then;

/// Create a copy of SupplierDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? currency = null,Object? taxId = freezed,Object? contactPerson = freezed,Object? phone = freezed,Object? email = freezed,Object? address = freezed,Object? paymentTerms = freezed,Object? deliveryTerms = freezed,Object? incoterms = freezed,Object? isApprovedFoodSupplier = null,Object? isActive = null,Object? rowVersion = null,}) {
  return _then(SupplierDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,contactPerson: freezed == contactPerson ? _self.contactPerson : contactPerson // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,paymentTerms: freezed == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as String?,deliveryTerms: freezed == deliveryTerms ? _self.deliveryTerms : deliveryTerms // ignore: cast_nullable_to_non_nullable
as String?,incoterms: freezed == incoterms ? _self.incoterms : incoterms // ignore: cast_nullable_to_non_nullable
as String?,isApprovedFoodSupplier: null == isApprovedFoodSupplier ? _self.isApprovedFoodSupplier : isApprovedFoodSupplier // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SupplierDto].
extension SupplierDtoPatterns on SupplierDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupplierDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupplierDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupplierDto value)  $default,){
final _that = this;
switch (_that) {
case _SupplierDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupplierDto value)?  $default,){
final _that = this;
switch (_that) {
case _SupplierDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  String currency,  String? taxId,  String? contactPerson,  String? phone,  String? email,  String? address,  String? paymentTerms,  String? deliveryTerms,  String? incoterms,  bool isApprovedFoodSupplier,  bool isActive,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupplierDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.currency,_that.taxId,_that.contactPerson,_that.phone,_that.email,_that.address,_that.paymentTerms,_that.deliveryTerms,_that.incoterms,_that.isApprovedFoodSupplier,_that.isActive,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  String currency,  String? taxId,  String? contactPerson,  String? phone,  String? email,  String? address,  String? paymentTerms,  String? deliveryTerms,  String? incoterms,  bool isApprovedFoodSupplier,  bool isActive,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _SupplierDto():
return $default(_that.id,_that.code,_that.name,_that.currency,_that.taxId,_that.contactPerson,_that.phone,_that.email,_that.address,_that.paymentTerms,_that.deliveryTerms,_that.incoterms,_that.isApprovedFoodSupplier,_that.isActive,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  String currency,  String? taxId,  String? contactPerson,  String? phone,  String? email,  String? address,  String? paymentTerms,  String? deliveryTerms,  String? incoterms,  bool isApprovedFoodSupplier,  bool isActive,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _SupplierDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.currency,_that.taxId,_that.contactPerson,_that.phone,_that.email,_that.address,_that.paymentTerms,_that.deliveryTerms,_that.incoterms,_that.isApprovedFoodSupplier,_that.isActive,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupplierDto implements SupplierDto {
  const _SupplierDto({required this.id, required this.code, required this.name, this.currency = 'AZN', this.taxId, this.contactPerson, this.phone, this.email, this.address, this.paymentTerms, this.deliveryTerms, this.incoterms, this.isApprovedFoodSupplier = false, this.isActive = true, this.rowVersion = 1});
  factory _SupplierDto.fromJson(Map<String, dynamic> json) => _$SupplierDtoFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override@JsonKey() final  String currency;
@override final  String? taxId;
@override final  String? contactPerson;
@override final  String? phone;
@override final  String? email;
@override final  String? address;
@override final  String? paymentTerms;
@override final  String? deliveryTerms;
@override final  String? incoterms;
@override@JsonKey() final  bool isApprovedFoodSupplier;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  int rowVersion;

/// Create a copy of SupplierDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplierDtoCopyWith<_SupplierDto> get copyWith => __$SupplierDtoCopyWithImpl<_SupplierDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupplierDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupplierDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.contactPerson, contactPerson) || other.contactPerson == contactPerson)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.paymentTerms, paymentTerms) || other.paymentTerms == paymentTerms)&&(identical(other.deliveryTerms, deliveryTerms) || other.deliveryTerms == deliveryTerms)&&(identical(other.incoterms, incoterms) || other.incoterms == incoterms)&&(identical(other.isApprovedFoodSupplier, isApprovedFoodSupplier) || other.isApprovedFoodSupplier == isApprovedFoodSupplier)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,currency,taxId,contactPerson,phone,email,address,paymentTerms,deliveryTerms,incoterms,isApprovedFoodSupplier,isActive,rowVersion);
}

@override
String toString() {
    return 'SupplierDto(id: $id, code: $code, name: $name, currency: $currency, taxId: $taxId, contactPerson: $contactPerson, phone: $phone, email: $email, address: $address, paymentTerms: $paymentTerms, deliveryTerms: $deliveryTerms, incoterms: $incoterms, isApprovedFoodSupplier: $isApprovedFoodSupplier, isActive: $isActive, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$SupplierDtoCopyWith<$Res> implements $SupplierDtoCopyWith<$Res> {
  factory _$SupplierDtoCopyWith(_SupplierDto value, $Res Function(_SupplierDto) _then) = __$SupplierDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, String currency, String? taxId, String? contactPerson, String? phone, String? email, String? address, String? paymentTerms, String? deliveryTerms, String? incoterms, bool isApprovedFoodSupplier, bool isActive, int rowVersion
});




}
/// @nodoc
class __$SupplierDtoCopyWithImpl<$Res>
    implements _$SupplierDtoCopyWith<$Res> {
  __$SupplierDtoCopyWithImpl(this._self, this._then);

  final _SupplierDto _self;
  final $Res Function(_SupplierDto) _then;

/// Create a copy of SupplierDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? currency = null,Object? taxId = freezed,Object? contactPerson = freezed,Object? phone = freezed,Object? email = freezed,Object? address = freezed,Object? paymentTerms = freezed,Object? deliveryTerms = freezed,Object? incoterms = freezed,Object? isApprovedFoodSupplier = null,Object? isActive = null,Object? rowVersion = null,}) {
  return _then(_SupplierDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,contactPerson: freezed == contactPerson ? _self.contactPerson : contactPerson // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,paymentTerms: freezed == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as String?,deliveryTerms: freezed == deliveryTerms ? _self.deliveryTerms : deliveryTerms // ignore: cast_nullable_to_non_nullable
as String?,incoterms: freezed == incoterms ? _self.incoterms : incoterms // ignore: cast_nullable_to_non_nullable
as String?,isApprovedFoodSupplier: null == isApprovedFoodSupplier ? _self.isApprovedFoodSupplier : isApprovedFoodSupplier // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LocationDto {

 int get id; String get code; String get name; LocationType get locationType; bool get isVirtual; int? get parentId; bool get allowsFood; bool get allowsNonFood; bool get isActive;
/// Create a copy of LocationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationDtoCopyWith<LocationDto> get copyWith => _$LocationDtoCopyWithImpl<LocationDto>(this as LocationDto, _$identity);

  /// Serializes this LocationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LocationDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.locationType, _this.locationType) || other.locationType == _this.locationType)&&(identical(other.isVirtual, _this.isVirtual) || other.isVirtual == _this.isVirtual)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.allowsFood, _this.allowsFood) || other.allowsFood == _this.allowsFood)&&(identical(other.allowsNonFood, _this.allowsNonFood) || other.allowsNonFood == _this.allowsNonFood)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LocationDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.locationType,_this.isVirtual,_this.parentId,_this.allowsFood,_this.allowsNonFood,_this.isActive);
}

@override
String toString() {
  final _this = this as LocationDto;
  return 'LocationDto(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, locationType: ${_this.locationType}, isVirtual: ${_this.isVirtual}, parentId: ${_this.parentId}, allowsFood: ${_this.allowsFood}, allowsNonFood: ${_this.allowsNonFood}, isActive: ${_this.isActive})';
}


}

/// @nodoc
abstract mixin class $LocationDtoCopyWith<$Res>  {
  factory $LocationDtoCopyWith(LocationDto value, $Res Function(LocationDto) _then) = _$LocationDtoCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, LocationType locationType, bool isVirtual, int? parentId, bool allowsFood, bool allowsNonFood, bool isActive
});




}
/// @nodoc
class _$LocationDtoCopyWithImpl<$Res>
    implements $LocationDtoCopyWith<$Res> {
  _$LocationDtoCopyWithImpl(this._self, this._then);

  final LocationDto _self;
  final $Res Function(LocationDto) _then;

/// Create a copy of LocationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? locationType = null,Object? isVirtual = null,Object? parentId = freezed,Object? allowsFood = null,Object? allowsNonFood = null,Object? isActive = null,}) {
  return _then(LocationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,locationType: null == locationType ? _self.locationType : locationType // ignore: cast_nullable_to_non_nullable
as LocationType,isVirtual: null == isVirtual ? _self.isVirtual : isVirtual // ignore: cast_nullable_to_non_nullable
as bool,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,allowsFood: null == allowsFood ? _self.allowsFood : allowsFood // ignore: cast_nullable_to_non_nullable
as bool,allowsNonFood: null == allowsNonFood ? _self.allowsNonFood : allowsNonFood // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationDto].
extension LocationDtoPatterns on LocationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationDto value)  $default,){
final _that = this;
switch (_that) {
case _LocationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationDto value)?  $default,){
final _that = this;
switch (_that) {
case _LocationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  LocationType locationType,  bool isVirtual,  int? parentId,  bool allowsFood,  bool allowsNonFood,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.locationType,_that.isVirtual,_that.parentId,_that.allowsFood,_that.allowsNonFood,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  LocationType locationType,  bool isVirtual,  int? parentId,  bool allowsFood,  bool allowsNonFood,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _LocationDto():
return $default(_that.id,_that.code,_that.name,_that.locationType,_that.isVirtual,_that.parentId,_that.allowsFood,_that.allowsNonFood,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  LocationType locationType,  bool isVirtual,  int? parentId,  bool allowsFood,  bool allowsNonFood,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _LocationDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.locationType,_that.isVirtual,_that.parentId,_that.allowsFood,_that.allowsNonFood,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationDto implements LocationDto {
  const _LocationDto({required this.id, required this.code, required this.name, required this.locationType, required this.isVirtual, this.parentId, this.allowsFood = true, this.allowsNonFood = true, this.isActive = true});
  factory _LocationDto.fromJson(Map<String, dynamic> json) => _$LocationDtoFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override final  LocationType locationType;
@override final  bool isVirtual;
@override final  int? parentId;
@override@JsonKey() final  bool allowsFood;
@override@JsonKey() final  bool allowsNonFood;
@override@JsonKey() final  bool isActive;

/// Create a copy of LocationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationDtoCopyWith<_LocationDto> get copyWith => __$LocationDtoCopyWithImpl<_LocationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.locationType, locationType) || other.locationType == locationType)&&(identical(other.isVirtual, isVirtual) || other.isVirtual == isVirtual)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.allowsFood, allowsFood) || other.allowsFood == allowsFood)&&(identical(other.allowsNonFood, allowsNonFood) || other.allowsNonFood == allowsNonFood)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,locationType,isVirtual,parentId,allowsFood,allowsNonFood,isActive);
}

@override
String toString() {
    return 'LocationDto(id: $id, code: $code, name: $name, locationType: $locationType, isVirtual: $isVirtual, parentId: $parentId, allowsFood: $allowsFood, allowsNonFood: $allowsNonFood, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$LocationDtoCopyWith<$Res> implements $LocationDtoCopyWith<$Res> {
  factory _$LocationDtoCopyWith(_LocationDto value, $Res Function(_LocationDto) _then) = __$LocationDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, LocationType locationType, bool isVirtual, int? parentId, bool allowsFood, bool allowsNonFood, bool isActive
});




}
/// @nodoc
class __$LocationDtoCopyWithImpl<$Res>
    implements _$LocationDtoCopyWith<$Res> {
  __$LocationDtoCopyWithImpl(this._self, this._then);

  final _LocationDto _self;
  final $Res Function(_LocationDto) _then;

/// Create a copy of LocationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? locationType = null,Object? isVirtual = null,Object? parentId = freezed,Object? allowsFood = null,Object? allowsNonFood = null,Object? isActive = null,}) {
  return _then(_LocationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,locationType: null == locationType ? _self.locationType : locationType // ignore: cast_nullable_to_non_nullable
as LocationType,isVirtual: null == isVirtual ? _self.isVirtual : isVirtual // ignore: cast_nullable_to_non_nullable
as bool,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,allowsFood: null == allowsFood ? _self.allowsFood : allowsFood // ignore: cast_nullable_to_non_nullable
as bool,allowsNonFood: null == allowsNonFood ? _self.allowsNonFood : allowsNonFood // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ReasonCodeDto {

 int get id; String get code; String get name; ReasonGroup get reasonGroup; bool get requiresApproval; bool get requiresPhoto; bool get isActive;
/// Create a copy of ReasonCodeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReasonCodeDtoCopyWith<ReasonCodeDto> get copyWith => _$ReasonCodeDtoCopyWithImpl<ReasonCodeDto>(this as ReasonCodeDto, _$identity);

  /// Serializes this ReasonCodeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReasonCodeDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReasonCodeDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.reasonGroup, _this.reasonGroup) || other.reasonGroup == _this.reasonGroup)&&(identical(other.requiresApproval, _this.requiresApproval) || other.requiresApproval == _this.requiresApproval)&&(identical(other.requiresPhoto, _this.requiresPhoto) || other.requiresPhoto == _this.requiresPhoto)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReasonCodeDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.reasonGroup,_this.requiresApproval,_this.requiresPhoto,_this.isActive);
}

@override
String toString() {
  final _this = this as ReasonCodeDto;
  return 'ReasonCodeDto(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, reasonGroup: ${_this.reasonGroup}, requiresApproval: ${_this.requiresApproval}, requiresPhoto: ${_this.requiresPhoto}, isActive: ${_this.isActive})';
}


}

/// @nodoc
abstract mixin class $ReasonCodeDtoCopyWith<$Res>  {
  factory $ReasonCodeDtoCopyWith(ReasonCodeDto value, $Res Function(ReasonCodeDto) _then) = _$ReasonCodeDtoCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, ReasonGroup reasonGroup, bool requiresApproval, bool requiresPhoto, bool isActive
});




}
/// @nodoc
class _$ReasonCodeDtoCopyWithImpl<$Res>
    implements $ReasonCodeDtoCopyWith<$Res> {
  _$ReasonCodeDtoCopyWithImpl(this._self, this._then);

  final ReasonCodeDto _self;
  final $Res Function(ReasonCodeDto) _then;

/// Create a copy of ReasonCodeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? reasonGroup = null,Object? requiresApproval = null,Object? requiresPhoto = null,Object? isActive = null,}) {
  return _then(ReasonCodeDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,reasonGroup: null == reasonGroup ? _self.reasonGroup : reasonGroup // ignore: cast_nullable_to_non_nullable
as ReasonGroup,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,requiresPhoto: null == requiresPhoto ? _self.requiresPhoto : requiresPhoto // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReasonCodeDto].
extension ReasonCodeDtoPatterns on ReasonCodeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReasonCodeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReasonCodeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReasonCodeDto value)  $default,){
final _that = this;
switch (_that) {
case _ReasonCodeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReasonCodeDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReasonCodeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  ReasonGroup reasonGroup,  bool requiresApproval,  bool requiresPhoto,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReasonCodeDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.reasonGroup,_that.requiresApproval,_that.requiresPhoto,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  ReasonGroup reasonGroup,  bool requiresApproval,  bool requiresPhoto,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _ReasonCodeDto():
return $default(_that.id,_that.code,_that.name,_that.reasonGroup,_that.requiresApproval,_that.requiresPhoto,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  ReasonGroup reasonGroup,  bool requiresApproval,  bool requiresPhoto,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _ReasonCodeDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.reasonGroup,_that.requiresApproval,_that.requiresPhoto,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReasonCodeDto implements ReasonCodeDto {
  const _ReasonCodeDto({required this.id, required this.code, required this.name, required this.reasonGroup, this.requiresApproval = true, this.requiresPhoto = false, this.isActive = true});
  factory _ReasonCodeDto.fromJson(Map<String, dynamic> json) => _$ReasonCodeDtoFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override final  ReasonGroup reasonGroup;
@override@JsonKey() final  bool requiresApproval;
@override@JsonKey() final  bool requiresPhoto;
@override@JsonKey() final  bool isActive;

/// Create a copy of ReasonCodeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReasonCodeDtoCopyWith<_ReasonCodeDto> get copyWith => __$ReasonCodeDtoCopyWithImpl<_ReasonCodeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReasonCodeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReasonCodeDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.reasonGroup, reasonGroup) || other.reasonGroup == reasonGroup)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&(identical(other.requiresPhoto, requiresPhoto) || other.requiresPhoto == requiresPhoto)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,reasonGroup,requiresApproval,requiresPhoto,isActive);
}

@override
String toString() {
    return 'ReasonCodeDto(id: $id, code: $code, name: $name, reasonGroup: $reasonGroup, requiresApproval: $requiresApproval, requiresPhoto: $requiresPhoto, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$ReasonCodeDtoCopyWith<$Res> implements $ReasonCodeDtoCopyWith<$Res> {
  factory _$ReasonCodeDtoCopyWith(_ReasonCodeDto value, $Res Function(_ReasonCodeDto) _then) = __$ReasonCodeDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, ReasonGroup reasonGroup, bool requiresApproval, bool requiresPhoto, bool isActive
});




}
/// @nodoc
class __$ReasonCodeDtoCopyWithImpl<$Res>
    implements _$ReasonCodeDtoCopyWith<$Res> {
  __$ReasonCodeDtoCopyWithImpl(this._self, this._then);

  final _ReasonCodeDto _self;
  final $Res Function(_ReasonCodeDto) _then;

/// Create a copy of ReasonCodeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? reasonGroup = null,Object? requiresApproval = null,Object? requiresPhoto = null,Object? isActive = null,}) {
  return _then(_ReasonCodeDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,reasonGroup: null == reasonGroup ? _self.reasonGroup : reasonGroup // ignore: cast_nullable_to_non_nullable
as ReasonGroup,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,requiresPhoto: null == requiresPhoto ? _self.requiresPhoto : requiresPhoto // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
