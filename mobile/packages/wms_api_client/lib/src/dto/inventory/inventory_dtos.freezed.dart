// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BalanceDto {

 ProductRefDto get product; LocationRefDto get location; Quantity get qtyOnHand; Quantity get qtyReserved; BatchRefDto? get batch; int? get baseUomId; String? get baseUomCode; Money? get avgUnitCost; Money? get totalValue; Quantity? get minStock; bool get isBelowMin; int? get daysToExpiry; int? get lastMovementId; DateTime? get updatedAt;
/// Create a copy of BalanceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BalanceDtoCopyWith<BalanceDto> get copyWith => _$BalanceDtoCopyWithImpl<BalanceDto>(this as BalanceDto, _$identity);

  /// Serializes this BalanceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BalanceDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BalanceDto&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.qtyOnHand, _this.qtyOnHand) || other.qtyOnHand == _this.qtyOnHand)&&(identical(other.qtyReserved, _this.qtyReserved) || other.qtyReserved == _this.qtyReserved)&&(identical(other.batch, _this.batch) || other.batch == _this.batch)&&(identical(other.baseUomId, _this.baseUomId) || other.baseUomId == _this.baseUomId)&&(identical(other.baseUomCode, _this.baseUomCode) || other.baseUomCode == _this.baseUomCode)&&(identical(other.avgUnitCost, _this.avgUnitCost) || other.avgUnitCost == _this.avgUnitCost)&&(identical(other.totalValue, _this.totalValue) || other.totalValue == _this.totalValue)&&(identical(other.minStock, _this.minStock) || other.minStock == _this.minStock)&&(identical(other.isBelowMin, _this.isBelowMin) || other.isBelowMin == _this.isBelowMin)&&(identical(other.daysToExpiry, _this.daysToExpiry) || other.daysToExpiry == _this.daysToExpiry)&&(identical(other.lastMovementId, _this.lastMovementId) || other.lastMovementId == _this.lastMovementId)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BalanceDto;
  return Object.hash(runtimeType,_this.product,_this.location,_this.qtyOnHand,_this.qtyReserved,_this.batch,_this.baseUomId,_this.baseUomCode,_this.avgUnitCost,_this.totalValue,_this.minStock,_this.isBelowMin,_this.daysToExpiry,_this.lastMovementId,_this.updatedAt);
}

@override
String toString() {
  final _this = this as BalanceDto;
  return 'BalanceDto(product: ${_this.product}, location: ${_this.location}, qtyOnHand: ${_this.qtyOnHand}, qtyReserved: ${_this.qtyReserved}, batch: ${_this.batch}, baseUomId: ${_this.baseUomId}, baseUomCode: ${_this.baseUomCode}, avgUnitCost: ${_this.avgUnitCost}, totalValue: ${_this.totalValue}, minStock: ${_this.minStock}, isBelowMin: ${_this.isBelowMin}, daysToExpiry: ${_this.daysToExpiry}, lastMovementId: ${_this.lastMovementId}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $BalanceDtoCopyWith<$Res>  {
  factory $BalanceDtoCopyWith(BalanceDto value, $Res Function(BalanceDto) _then) = _$BalanceDtoCopyWithImpl;
@useResult
$Res call({
 ProductRefDto product, LocationRefDto location, Quantity qtyOnHand, Quantity qtyReserved, BatchRefDto? batch, int? baseUomId, String? baseUomCode, Money? avgUnitCost, Money? totalValue, Quantity? minStock, bool isBelowMin, int? daysToExpiry, int? lastMovementId, DateTime? updatedAt
});


$ProductRefDtoCopyWith<$Res> get product;$LocationRefDtoCopyWith<$Res> get location;$BatchRefDtoCopyWith<$Res>? get batch;

}
/// @nodoc
class _$BalanceDtoCopyWithImpl<$Res>
    implements $BalanceDtoCopyWith<$Res> {
  _$BalanceDtoCopyWithImpl(this._self, this._then);

  final BalanceDto _self;
  final $Res Function(BalanceDto) _then;

/// Create a copy of BalanceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = null,Object? location = null,Object? qtyOnHand = null,Object? qtyReserved = null,Object? batch = freezed,Object? baseUomId = freezed,Object? baseUomCode = freezed,Object? avgUnitCost = freezed,Object? totalValue = freezed,Object? minStock = freezed,Object? isBelowMin = null,Object? daysToExpiry = freezed,Object? lastMovementId = freezed,Object? updatedAt = freezed,}) {
  return _then(BalanceDto(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationRefDto,qtyOnHand: null == qtyOnHand ? _self.qtyOnHand : qtyOnHand // ignore: cast_nullable_to_non_nullable
as Quantity,qtyReserved: null == qtyReserved ? _self.qtyReserved : qtyReserved // ignore: cast_nullable_to_non_nullable
as Quantity,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as BatchRefDto?,baseUomId: freezed == baseUomId ? _self.baseUomId : baseUomId // ignore: cast_nullable_to_non_nullable
as int?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,avgUnitCost: freezed == avgUnitCost ? _self.avgUnitCost : avgUnitCost // ignore: cast_nullable_to_non_nullable
as Money?,totalValue: freezed == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as Money?,minStock: freezed == minStock ? _self.minStock : minStock // ignore: cast_nullable_to_non_nullable
as Quantity?,isBelowMin: null == isBelowMin ? _self.isBelowMin : isBelowMin // ignore: cast_nullable_to_non_nullable
as bool,daysToExpiry: freezed == daysToExpiry ? _self.daysToExpiry : daysToExpiry // ignore: cast_nullable_to_non_nullable
as int?,lastMovementId: freezed == lastMovementId ? _self.lastMovementId : lastMovementId // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of BalanceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of BalanceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get location {
  
  return $LocationRefDtoCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of BalanceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<$Res>? get batch {
    if (_self.batch == null) {
    return null;
  }

  return $BatchRefDtoCopyWith<$Res>(_self.batch!, (value) {
    return _then(_self.copyWith(batch: value));
  });
}
}


/// Adds pattern-matching-related methods to [BalanceDto].
extension BalanceDtoPatterns on BalanceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BalanceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BalanceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BalanceDto value)  $default,){
final _that = this;
switch (_that) {
case _BalanceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BalanceDto value)?  $default,){
final _that = this;
switch (_that) {
case _BalanceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProductRefDto product,  LocationRefDto location,  Quantity qtyOnHand,  Quantity qtyReserved,  BatchRefDto? batch,  int? baseUomId,  String? baseUomCode,  Money? avgUnitCost,  Money? totalValue,  Quantity? minStock,  bool isBelowMin,  int? daysToExpiry,  int? lastMovementId,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BalanceDto() when $default != null:
return $default(_that.product,_that.location,_that.qtyOnHand,_that.qtyReserved,_that.batch,_that.baseUomId,_that.baseUomCode,_that.avgUnitCost,_that.totalValue,_that.minStock,_that.isBelowMin,_that.daysToExpiry,_that.lastMovementId,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProductRefDto product,  LocationRefDto location,  Quantity qtyOnHand,  Quantity qtyReserved,  BatchRefDto? batch,  int? baseUomId,  String? baseUomCode,  Money? avgUnitCost,  Money? totalValue,  Quantity? minStock,  bool isBelowMin,  int? daysToExpiry,  int? lastMovementId,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BalanceDto():
return $default(_that.product,_that.location,_that.qtyOnHand,_that.qtyReserved,_that.batch,_that.baseUomId,_that.baseUomCode,_that.avgUnitCost,_that.totalValue,_that.minStock,_that.isBelowMin,_that.daysToExpiry,_that.lastMovementId,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProductRefDto product,  LocationRefDto location,  Quantity qtyOnHand,  Quantity qtyReserved,  BatchRefDto? batch,  int? baseUomId,  String? baseUomCode,  Money? avgUnitCost,  Money? totalValue,  Quantity? minStock,  bool isBelowMin,  int? daysToExpiry,  int? lastMovementId,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BalanceDto() when $default != null:
return $default(_that.product,_that.location,_that.qtyOnHand,_that.qtyReserved,_that.batch,_that.baseUomId,_that.baseUomCode,_that.avgUnitCost,_that.totalValue,_that.minStock,_that.isBelowMin,_that.daysToExpiry,_that.lastMovementId,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BalanceDto extends BalanceDto {
  const _BalanceDto({required this.product, required this.location, required this.qtyOnHand, required this.qtyReserved, this.batch, this.baseUomId, this.baseUomCode, this.avgUnitCost, this.totalValue, this.minStock, this.isBelowMin = false, this.daysToExpiry, this.lastMovementId, this.updatedAt}): super._();
  factory _BalanceDto.fromJson(Map<String, dynamic> json) => _$BalanceDtoFromJson(json);

@override final  ProductRefDto product;
@override final  LocationRefDto location;
@override final  Quantity qtyOnHand;
@override final  Quantity qtyReserved;
@override final  BatchRefDto? batch;
@override final  int? baseUomId;
@override final  String? baseUomCode;
@override final  Money? avgUnitCost;
@override final  Money? totalValue;
@override final  Quantity? minStock;
@override@JsonKey() final  bool isBelowMin;
@override final  int? daysToExpiry;
@override final  int? lastMovementId;
@override final  DateTime? updatedAt;

/// Create a copy of BalanceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BalanceDtoCopyWith<_BalanceDto> get copyWith => __$BalanceDtoCopyWithImpl<_BalanceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BalanceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BalanceDto&&(identical(other.product, product) || other.product == product)&&(identical(other.location, location) || other.location == location)&&(identical(other.qtyOnHand, qtyOnHand) || other.qtyOnHand == qtyOnHand)&&(identical(other.qtyReserved, qtyReserved) || other.qtyReserved == qtyReserved)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.baseUomId, baseUomId) || other.baseUomId == baseUomId)&&(identical(other.baseUomCode, baseUomCode) || other.baseUomCode == baseUomCode)&&(identical(other.avgUnitCost, avgUnitCost) || other.avgUnitCost == avgUnitCost)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&(identical(other.minStock, minStock) || other.minStock == minStock)&&(identical(other.isBelowMin, isBelowMin) || other.isBelowMin == isBelowMin)&&(identical(other.daysToExpiry, daysToExpiry) || other.daysToExpiry == daysToExpiry)&&(identical(other.lastMovementId, lastMovementId) || other.lastMovementId == lastMovementId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,product,location,qtyOnHand,qtyReserved,batch,baseUomId,baseUomCode,avgUnitCost,totalValue,minStock,isBelowMin,daysToExpiry,lastMovementId,updatedAt);
}

@override
String toString() {
    return 'BalanceDto(product: $product, location: $location, qtyOnHand: $qtyOnHand, qtyReserved: $qtyReserved, batch: $batch, baseUomId: $baseUomId, baseUomCode: $baseUomCode, avgUnitCost: $avgUnitCost, totalValue: $totalValue, minStock: $minStock, isBelowMin: $isBelowMin, daysToExpiry: $daysToExpiry, lastMovementId: $lastMovementId, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BalanceDtoCopyWith<$Res> implements $BalanceDtoCopyWith<$Res> {
  factory _$BalanceDtoCopyWith(_BalanceDto value, $Res Function(_BalanceDto) _then) = __$BalanceDtoCopyWithImpl;
@override @useResult
$Res call({
 ProductRefDto product, LocationRefDto location, Quantity qtyOnHand, Quantity qtyReserved, BatchRefDto? batch, int? baseUomId, String? baseUomCode, Money? avgUnitCost, Money? totalValue, Quantity? minStock, bool isBelowMin, int? daysToExpiry, int? lastMovementId, DateTime? updatedAt
});


@override $ProductRefDtoCopyWith<$Res> get product;@override $LocationRefDtoCopyWith<$Res> get location;@override $BatchRefDtoCopyWith<$Res>? get batch;

}
/// @nodoc
class __$BalanceDtoCopyWithImpl<$Res>
    implements _$BalanceDtoCopyWith<$Res> {
  __$BalanceDtoCopyWithImpl(this._self, this._then);

  final _BalanceDto _self;
  final $Res Function(_BalanceDto) _then;

/// Create a copy of BalanceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = null,Object? location = null,Object? qtyOnHand = null,Object? qtyReserved = null,Object? batch = freezed,Object? baseUomId = freezed,Object? baseUomCode = freezed,Object? avgUnitCost = freezed,Object? totalValue = freezed,Object? minStock = freezed,Object? isBelowMin = null,Object? daysToExpiry = freezed,Object? lastMovementId = freezed,Object? updatedAt = freezed,}) {
  return _then(_BalanceDto(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationRefDto,qtyOnHand: null == qtyOnHand ? _self.qtyOnHand : qtyOnHand // ignore: cast_nullable_to_non_nullable
as Quantity,qtyReserved: null == qtyReserved ? _self.qtyReserved : qtyReserved // ignore: cast_nullable_to_non_nullable
as Quantity,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as BatchRefDto?,baseUomId: freezed == baseUomId ? _self.baseUomId : baseUomId // ignore: cast_nullable_to_non_nullable
as int?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,avgUnitCost: freezed == avgUnitCost ? _self.avgUnitCost : avgUnitCost // ignore: cast_nullable_to_non_nullable
as Money?,totalValue: freezed == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as Money?,minStock: freezed == minStock ? _self.minStock : minStock // ignore: cast_nullable_to_non_nullable
as Quantity?,isBelowMin: null == isBelowMin ? _self.isBelowMin : isBelowMin // ignore: cast_nullable_to_non_nullable
as bool,daysToExpiry: freezed == daysToExpiry ? _self.daysToExpiry : daysToExpiry // ignore: cast_nullable_to_non_nullable
as int?,lastMovementId: freezed == lastMovementId ? _self.lastMovementId : lastMovementId // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of BalanceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of BalanceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get location {
  
  return $LocationRefDtoCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of BalanceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<$Res>? get batch {
    if (_self.batch == null) {
    return null;
  }

  return $BatchRefDtoCopyWith<$Res>(_self.batch!, (value) {
    return _then(_self.copyWith(batch: value));
  });
}
}


/// @nodoc
mixin _$BatchDto {

 int get id; ProductRefDto get product; String get batchNo; DateTime get receivedAt; BatchStatus get status; Quantity? get qtyOnHand; Quantity? get totalQtyOnHand; int get rowVersion;@NullableDateOnlyConverter() DateTime? get productionDate;@NullableDateOnlyConverter() DateTime? get expiryDate; int? get supplierId; String? get supplierName; int? get daysToExpiry; List<Object?> get byLocation;
/// Create a copy of BatchDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchDtoCopyWith<BatchDto> get copyWith => _$BatchDtoCopyWithImpl<BatchDto>(this as BatchDto, _$identity);

  /// Serializes this BatchDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BatchDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.batchNo, _this.batchNo) || other.batchNo == _this.batchNo)&&(identical(other.receivedAt, _this.receivedAt) || other.receivedAt == _this.receivedAt)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.qtyOnHand, _this.qtyOnHand) || other.qtyOnHand == _this.qtyOnHand)&&(identical(other.totalQtyOnHand, _this.totalQtyOnHand) || other.totalQtyOnHand == _this.totalQtyOnHand)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&(identical(other.productionDate, _this.productionDate) || other.productionDate == _this.productionDate)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.supplierName, _this.supplierName) || other.supplierName == _this.supplierName)&&(identical(other.daysToExpiry, _this.daysToExpiry) || other.daysToExpiry == _this.daysToExpiry)&&const DeepCollectionEquality().equals(other.byLocation, _this.byLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BatchDto;
  return Object.hash(runtimeType,_this.id,_this.product,_this.batchNo,_this.receivedAt,_this.status,_this.qtyOnHand,_this.totalQtyOnHand,_this.rowVersion,_this.productionDate,_this.expiryDate,_this.supplierId,_this.supplierName,_this.daysToExpiry,const DeepCollectionEquality().hash(_this.byLocation));
}

@override
String toString() {
  final _this = this as BatchDto;
  return 'BatchDto(id: ${_this.id}, product: ${_this.product}, batchNo: ${_this.batchNo}, receivedAt: ${_this.receivedAt}, status: ${_this.status}, qtyOnHand: ${_this.qtyOnHand}, totalQtyOnHand: ${_this.totalQtyOnHand}, rowVersion: ${_this.rowVersion}, productionDate: ${_this.productionDate}, expiryDate: ${_this.expiryDate}, supplierId: ${_this.supplierId}, supplierName: ${_this.supplierName}, daysToExpiry: ${_this.daysToExpiry}, byLocation: ${_this.byLocation})';
}


}

/// @nodoc
abstract mixin class $BatchDtoCopyWith<$Res>  {
  factory $BatchDtoCopyWith(BatchDto value, $Res Function(BatchDto) _then) = _$BatchDtoCopyWithImpl;
@useResult
$Res call({
 int id, ProductRefDto product, String batchNo, DateTime receivedAt, BatchStatus status, Quantity? qtyOnHand, Quantity? totalQtyOnHand, int rowVersion,@NullableDateOnlyConverter() DateTime? productionDate,@NullableDateOnlyConverter() DateTime? expiryDate, int? supplierId, String? supplierName, int? daysToExpiry, List<Object?> byLocation
});


$ProductRefDtoCopyWith<$Res> get product;

}
/// @nodoc
class _$BatchDtoCopyWithImpl<$Res>
    implements $BatchDtoCopyWith<$Res> {
  _$BatchDtoCopyWithImpl(this._self, this._then);

  final BatchDto _self;
  final $Res Function(BatchDto) _then;

/// Create a copy of BatchDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? product = null,Object? batchNo = null,Object? receivedAt = null,Object? status = null,Object? qtyOnHand = freezed,Object? totalQtyOnHand = freezed,Object? rowVersion = null,Object? productionDate = freezed,Object? expiryDate = freezed,Object? supplierId = freezed,Object? supplierName = freezed,Object? daysToExpiry = freezed,Object? byLocation = null,}) {
  return _then(BatchDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,batchNo: null == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchStatus,qtyOnHand: freezed == qtyOnHand ? _self.qtyOnHand : qtyOnHand // ignore: cast_nullable_to_non_nullable
as Quantity?,totalQtyOnHand: freezed == totalQtyOnHand ? _self.totalQtyOnHand : totalQtyOnHand // ignore: cast_nullable_to_non_nullable
as Quantity?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,productionDate: freezed == productionDate ? _self.productionDate : productionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,daysToExpiry: freezed == daysToExpiry ? _self.daysToExpiry : daysToExpiry // ignore: cast_nullable_to_non_nullable
as int?,byLocation: null == byLocation ? _self.byLocation : byLocation // ignore: cast_nullable_to_non_nullable
as List<Object?>,
  ));
}
/// Create a copy of BatchDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [BatchDto].
extension BatchDtoPatterns on BatchDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchDto value)  $default,){
final _that = this;
switch (_that) {
case _BatchDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchDto value)?  $default,){
final _that = this;
switch (_that) {
case _BatchDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  ProductRefDto product,  String batchNo,  DateTime receivedAt,  BatchStatus status,  Quantity? qtyOnHand,  Quantity? totalQtyOnHand,  int rowVersion, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  int? supplierId,  String? supplierName,  int? daysToExpiry,  List<Object?> byLocation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchDto() when $default != null:
return $default(_that.id,_that.product,_that.batchNo,_that.receivedAt,_that.status,_that.qtyOnHand,_that.totalQtyOnHand,_that.rowVersion,_that.productionDate,_that.expiryDate,_that.supplierId,_that.supplierName,_that.daysToExpiry,_that.byLocation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  ProductRefDto product,  String batchNo,  DateTime receivedAt,  BatchStatus status,  Quantity? qtyOnHand,  Quantity? totalQtyOnHand,  int rowVersion, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  int? supplierId,  String? supplierName,  int? daysToExpiry,  List<Object?> byLocation)  $default,) {final _that = this;
switch (_that) {
case _BatchDto():
return $default(_that.id,_that.product,_that.batchNo,_that.receivedAt,_that.status,_that.qtyOnHand,_that.totalQtyOnHand,_that.rowVersion,_that.productionDate,_that.expiryDate,_that.supplierId,_that.supplierName,_that.daysToExpiry,_that.byLocation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  ProductRefDto product,  String batchNo,  DateTime receivedAt,  BatchStatus status,  Quantity? qtyOnHand,  Quantity? totalQtyOnHand,  int rowVersion, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  int? supplierId,  String? supplierName,  int? daysToExpiry,  List<Object?> byLocation)?  $default,) {final _that = this;
switch (_that) {
case _BatchDto() when $default != null:
return $default(_that.id,_that.product,_that.batchNo,_that.receivedAt,_that.status,_that.qtyOnHand,_that.totalQtyOnHand,_that.rowVersion,_that.productionDate,_that.expiryDate,_that.supplierId,_that.supplierName,_that.daysToExpiry,_that.byLocation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchDto implements BatchDto {
  const _BatchDto({required this.id, required this.product, required this.batchNo, required this.receivedAt, required this.status, this.qtyOnHand, this.totalQtyOnHand, this.rowVersion = 1, @NullableDateOnlyConverter() this.productionDate, @NullableDateOnlyConverter() this.expiryDate, this.supplierId, this.supplierName, this.daysToExpiry,  List<Object?> byLocation = const <Object?>[]}): _byLocation = byLocation;
  factory _BatchDto.fromJson(Map<String, dynamic> json) => _$BatchDtoFromJson(json);

@override final  int id;
@override final  ProductRefDto product;
@override final  String batchNo;
@override final  DateTime receivedAt;
@override final  BatchStatus status;
@override final  Quantity? qtyOnHand;
@override final  Quantity? totalQtyOnHand;
@override@JsonKey() final  int rowVersion;
@override@NullableDateOnlyConverter() final  DateTime? productionDate;
@override@NullableDateOnlyConverter() final  DateTime? expiryDate;
@override final  int? supplierId;
@override final  String? supplierName;
@override final  int? daysToExpiry;
 final  List<Object?> _byLocation;
@override@JsonKey() List<Object?> get byLocation {
  if (_byLocation is EqualUnmodifiableListView) return _byLocation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byLocation);
}


/// Create a copy of BatchDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchDtoCopyWith<_BatchDto> get copyWith => __$BatchDtoCopyWithImpl<_BatchDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchDto&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.batchNo, batchNo) || other.batchNo == batchNo)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.qtyOnHand, qtyOnHand) || other.qtyOnHand == qtyOnHand)&&(identical(other.totalQtyOnHand, totalQtyOnHand) || other.totalQtyOnHand == totalQtyOnHand)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&(identical(other.productionDate, productionDate) || other.productionDate == productionDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.daysToExpiry, daysToExpiry) || other.daysToExpiry == daysToExpiry)&&const DeepCollectionEquality().equals(other.byLocation, _byLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,product,batchNo,receivedAt,status,qtyOnHand,totalQtyOnHand,rowVersion,productionDate,expiryDate,supplierId,supplierName,daysToExpiry,const DeepCollectionEquality().hash(_byLocation));
}

@override
String toString() {
    return 'BatchDto(id: $id, product: $product, batchNo: $batchNo, receivedAt: $receivedAt, status: $status, qtyOnHand: $qtyOnHand, totalQtyOnHand: $totalQtyOnHand, rowVersion: $rowVersion, productionDate: $productionDate, expiryDate: $expiryDate, supplierId: $supplierId, supplierName: $supplierName, daysToExpiry: $daysToExpiry, byLocation: $byLocation)';
}


}

/// @nodoc
abstract mixin class _$BatchDtoCopyWith<$Res> implements $BatchDtoCopyWith<$Res> {
  factory _$BatchDtoCopyWith(_BatchDto value, $Res Function(_BatchDto) _then) = __$BatchDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, ProductRefDto product, String batchNo, DateTime receivedAt, BatchStatus status, Quantity? qtyOnHand, Quantity? totalQtyOnHand, int rowVersion,@NullableDateOnlyConverter() DateTime? productionDate,@NullableDateOnlyConverter() DateTime? expiryDate, int? supplierId, String? supplierName, int? daysToExpiry, List<Object?> byLocation
});


@override $ProductRefDtoCopyWith<$Res> get product;

}
/// @nodoc
class __$BatchDtoCopyWithImpl<$Res>
    implements _$BatchDtoCopyWith<$Res> {
  __$BatchDtoCopyWithImpl(this._self, this._then);

  final _BatchDto _self;
  final $Res Function(_BatchDto) _then;

/// Create a copy of BatchDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? product = null,Object? batchNo = null,Object? receivedAt = null,Object? status = null,Object? qtyOnHand = freezed,Object? totalQtyOnHand = freezed,Object? rowVersion = null,Object? productionDate = freezed,Object? expiryDate = freezed,Object? supplierId = freezed,Object? supplierName = freezed,Object? daysToExpiry = freezed,Object? byLocation = null,}) {
  return _then(_BatchDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,batchNo: null == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchStatus,qtyOnHand: freezed == qtyOnHand ? _self.qtyOnHand : qtyOnHand // ignore: cast_nullable_to_non_nullable
as Quantity?,totalQtyOnHand: freezed == totalQtyOnHand ? _self.totalQtyOnHand : totalQtyOnHand // ignore: cast_nullable_to_non_nullable
as Quantity?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,productionDate: freezed == productionDate ? _self.productionDate : productionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,daysToExpiry: freezed == daysToExpiry ? _self.daysToExpiry : daysToExpiry // ignore: cast_nullable_to_non_nullable
as int?,byLocation: null == byLocation ? _self._byLocation : byLocation // ignore: cast_nullable_to_non_nullable
as List<Object?>,
  ));
}

/// Create a copy of BatchDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// @nodoc
mixin _$GoodsReceiptLineDto {

 int get lineNo; ProductRefDto get product; Quantity get receivedQty; int get uomId; Quantity get rejectedQty; int? get id; int? get poLineId; int? get batchId; Quantity? get orderedQty; Quantity? get acceptedQtyBase; Quantity? get varianceQty; String? get uomCode; String? get batchNo;@NullableDateOnlyConverter() DateTime? get productionDate;@NullableDateOnlyConverter() DateTime? get expiryDate; Money? get unitPrice; String? get currency; String? get varianceNote;
/// Create a copy of GoodsReceiptLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoodsReceiptLineDtoCopyWith<GoodsReceiptLineDto> get copyWith => _$GoodsReceiptLineDtoCopyWithImpl<GoodsReceiptLineDto>(this as GoodsReceiptLineDto, _$identity);

  /// Serializes this GoodsReceiptLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GoodsReceiptLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoodsReceiptLineDto&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.receivedQty, _this.receivedQty) || other.receivedQty == _this.receivedQty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.rejectedQty, _this.rejectedQty) || other.rejectedQty == _this.rejectedQty)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.poLineId, _this.poLineId) || other.poLineId == _this.poLineId)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId)&&(identical(other.orderedQty, _this.orderedQty) || other.orderedQty == _this.orderedQty)&&(identical(other.acceptedQtyBase, _this.acceptedQtyBase) || other.acceptedQtyBase == _this.acceptedQtyBase)&&(identical(other.varianceQty, _this.varianceQty) || other.varianceQty == _this.varianceQty)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.batchNo, _this.batchNo) || other.batchNo == _this.batchNo)&&(identical(other.productionDate, _this.productionDate) || other.productionDate == _this.productionDate)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.varianceNote, _this.varianceNote) || other.varianceNote == _this.varianceNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoodsReceiptLineDto;
  return Object.hash(runtimeType,_this.lineNo,_this.product,_this.receivedQty,_this.uomId,_this.rejectedQty,_this.id,_this.poLineId,_this.batchId,_this.orderedQty,_this.acceptedQtyBase,_this.varianceQty,_this.uomCode,_this.batchNo,_this.productionDate,_this.expiryDate,_this.unitPrice,_this.currency,_this.varianceNote);
}

@override
String toString() {
  final _this = this as GoodsReceiptLineDto;
  return 'GoodsReceiptLineDto(lineNo: ${_this.lineNo}, product: ${_this.product}, receivedQty: ${_this.receivedQty}, uomId: ${_this.uomId}, rejectedQty: ${_this.rejectedQty}, id: ${_this.id}, poLineId: ${_this.poLineId}, batchId: ${_this.batchId}, orderedQty: ${_this.orderedQty}, acceptedQtyBase: ${_this.acceptedQtyBase}, varianceQty: ${_this.varianceQty}, uomCode: ${_this.uomCode}, batchNo: ${_this.batchNo}, productionDate: ${_this.productionDate}, expiryDate: ${_this.expiryDate}, unitPrice: ${_this.unitPrice}, currency: ${_this.currency}, varianceNote: ${_this.varianceNote})';
}


}

/// @nodoc
abstract mixin class $GoodsReceiptLineDtoCopyWith<$Res>  {
  factory $GoodsReceiptLineDtoCopyWith(GoodsReceiptLineDto value, $Res Function(GoodsReceiptLineDto) _then) = _$GoodsReceiptLineDtoCopyWithImpl;
@useResult
$Res call({
 int lineNo, ProductRefDto product, Quantity receivedQty, int uomId, Quantity rejectedQty, int? id, int? poLineId, int? batchId, Quantity? orderedQty, Quantity? acceptedQtyBase, Quantity? varianceQty, String? uomCode, String? batchNo,@NullableDateOnlyConverter() DateTime? productionDate,@NullableDateOnlyConverter() DateTime? expiryDate, Money? unitPrice, String? currency, String? varianceNote
});


$ProductRefDtoCopyWith<$Res> get product;

}
/// @nodoc
class _$GoodsReceiptLineDtoCopyWithImpl<$Res>
    implements $GoodsReceiptLineDtoCopyWith<$Res> {
  _$GoodsReceiptLineDtoCopyWithImpl(this._self, this._then);

  final GoodsReceiptLineDto _self;
  final $Res Function(GoodsReceiptLineDto) _then;

/// Create a copy of GoodsReceiptLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? product = null,Object? receivedQty = null,Object? uomId = null,Object? rejectedQty = null,Object? id = freezed,Object? poLineId = freezed,Object? batchId = freezed,Object? orderedQty = freezed,Object? acceptedQtyBase = freezed,Object? varianceQty = freezed,Object? uomCode = freezed,Object? batchNo = freezed,Object? productionDate = freezed,Object? expiryDate = freezed,Object? unitPrice = freezed,Object? currency = freezed,Object? varianceNote = freezed,}) {
  return _then(GoodsReceiptLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,rejectedQty: null == rejectedQty ? _self.rejectedQty : rejectedQty // ignore: cast_nullable_to_non_nullable
as Quantity,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,poLineId: freezed == poLineId ? _self.poLineId : poLineId // ignore: cast_nullable_to_non_nullable
as int?,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,orderedQty: freezed == orderedQty ? _self.orderedQty : orderedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,acceptedQtyBase: freezed == acceptedQtyBase ? _self.acceptedQtyBase : acceptedQtyBase // ignore: cast_nullable_to_non_nullable
as Quantity?,varianceQty: freezed == varianceQty ? _self.varianceQty : varianceQty // ignore: cast_nullable_to_non_nullable
as Quantity?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,productionDate: freezed == productionDate ? _self.productionDate : productionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,varianceNote: freezed == varianceNote ? _self.varianceNote : varianceNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of GoodsReceiptLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [GoodsReceiptLineDto].
extension GoodsReceiptLineDtoPatterns on GoodsReceiptLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoodsReceiptLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoodsReceiptLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoodsReceiptLineDto value)  $default,){
final _that = this;
switch (_that) {
case _GoodsReceiptLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoodsReceiptLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _GoodsReceiptLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  ProductRefDto product,  Quantity receivedQty,  int uomId,  Quantity rejectedQty,  int? id,  int? poLineId,  int? batchId,  Quantity? orderedQty,  Quantity? acceptedQtyBase,  Quantity? varianceQty,  String? uomCode,  String? batchNo, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  Money? unitPrice,  String? currency,  String? varianceNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoodsReceiptLineDto() when $default != null:
return $default(_that.lineNo,_that.product,_that.receivedQty,_that.uomId,_that.rejectedQty,_that.id,_that.poLineId,_that.batchId,_that.orderedQty,_that.acceptedQtyBase,_that.varianceQty,_that.uomCode,_that.batchNo,_that.productionDate,_that.expiryDate,_that.unitPrice,_that.currency,_that.varianceNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  ProductRefDto product,  Quantity receivedQty,  int uomId,  Quantity rejectedQty,  int? id,  int? poLineId,  int? batchId,  Quantity? orderedQty,  Quantity? acceptedQtyBase,  Quantity? varianceQty,  String? uomCode,  String? batchNo, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  Money? unitPrice,  String? currency,  String? varianceNote)  $default,) {final _that = this;
switch (_that) {
case _GoodsReceiptLineDto():
return $default(_that.lineNo,_that.product,_that.receivedQty,_that.uomId,_that.rejectedQty,_that.id,_that.poLineId,_that.batchId,_that.orderedQty,_that.acceptedQtyBase,_that.varianceQty,_that.uomCode,_that.batchNo,_that.productionDate,_that.expiryDate,_that.unitPrice,_that.currency,_that.varianceNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  ProductRefDto product,  Quantity receivedQty,  int uomId,  Quantity rejectedQty,  int? id,  int? poLineId,  int? batchId,  Quantity? orderedQty,  Quantity? acceptedQtyBase,  Quantity? varianceQty,  String? uomCode,  String? batchNo, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  Money? unitPrice,  String? currency,  String? varianceNote)?  $default,) {final _that = this;
switch (_that) {
case _GoodsReceiptLineDto() when $default != null:
return $default(_that.lineNo,_that.product,_that.receivedQty,_that.uomId,_that.rejectedQty,_that.id,_that.poLineId,_that.batchId,_that.orderedQty,_that.acceptedQtyBase,_that.varianceQty,_that.uomCode,_that.batchNo,_that.productionDate,_that.expiryDate,_that.unitPrice,_that.currency,_that.varianceNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoodsReceiptLineDto extends GoodsReceiptLineDto {
  const _GoodsReceiptLineDto({required this.lineNo, required this.product, required this.receivedQty, required this.uomId, required this.rejectedQty, this.id, this.poLineId, this.batchId, this.orderedQty, this.acceptedQtyBase, this.varianceQty, this.uomCode, this.batchNo, @NullableDateOnlyConverter() this.productionDate, @NullableDateOnlyConverter() this.expiryDate, this.unitPrice, this.currency, this.varianceNote}): super._();
  factory _GoodsReceiptLineDto.fromJson(Map<String, dynamic> json) => _$GoodsReceiptLineDtoFromJson(json);

@override final  int lineNo;
@override final  ProductRefDto product;
@override final  Quantity receivedQty;
@override final  int uomId;
@override final  Quantity rejectedQty;
@override final  int? id;
@override final  int? poLineId;
@override final  int? batchId;
@override final  Quantity? orderedQty;
@override final  Quantity? acceptedQtyBase;
@override final  Quantity? varianceQty;
@override final  String? uomCode;
@override final  String? batchNo;
@override@NullableDateOnlyConverter() final  DateTime? productionDate;
@override@NullableDateOnlyConverter() final  DateTime? expiryDate;
@override final  Money? unitPrice;
@override final  String? currency;
@override final  String? varianceNote;

/// Create a copy of GoodsReceiptLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoodsReceiptLineDtoCopyWith<_GoodsReceiptLineDto> get copyWith => __$GoodsReceiptLineDtoCopyWithImpl<_GoodsReceiptLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoodsReceiptLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoodsReceiptLineDto&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.product, product) || other.product == product)&&(identical(other.receivedQty, receivedQty) || other.receivedQty == receivedQty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.rejectedQty, rejectedQty) || other.rejectedQty == rejectedQty)&&(identical(other.id, id) || other.id == id)&&(identical(other.poLineId, poLineId) || other.poLineId == poLineId)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.orderedQty, orderedQty) || other.orderedQty == orderedQty)&&(identical(other.acceptedQtyBase, acceptedQtyBase) || other.acceptedQtyBase == acceptedQtyBase)&&(identical(other.varianceQty, varianceQty) || other.varianceQty == varianceQty)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.batchNo, batchNo) || other.batchNo == batchNo)&&(identical(other.productionDate, productionDate) || other.productionDate == productionDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.varianceNote, varianceNote) || other.varianceNote == varianceNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,product,receivedQty,uomId,rejectedQty,id,poLineId,batchId,orderedQty,acceptedQtyBase,varianceQty,uomCode,batchNo,productionDate,expiryDate,unitPrice,currency,varianceNote);
}

@override
String toString() {
    return 'GoodsReceiptLineDto(lineNo: $lineNo, product: $product, receivedQty: $receivedQty, uomId: $uomId, rejectedQty: $rejectedQty, id: $id, poLineId: $poLineId, batchId: $batchId, orderedQty: $orderedQty, acceptedQtyBase: $acceptedQtyBase, varianceQty: $varianceQty, uomCode: $uomCode, batchNo: $batchNo, productionDate: $productionDate, expiryDate: $expiryDate, unitPrice: $unitPrice, currency: $currency, varianceNote: $varianceNote)';
}


}

/// @nodoc
abstract mixin class _$GoodsReceiptLineDtoCopyWith<$Res> implements $GoodsReceiptLineDtoCopyWith<$Res> {
  factory _$GoodsReceiptLineDtoCopyWith(_GoodsReceiptLineDto value, $Res Function(_GoodsReceiptLineDto) _then) = __$GoodsReceiptLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, ProductRefDto product, Quantity receivedQty, int uomId, Quantity rejectedQty, int? id, int? poLineId, int? batchId, Quantity? orderedQty, Quantity? acceptedQtyBase, Quantity? varianceQty, String? uomCode, String? batchNo,@NullableDateOnlyConverter() DateTime? productionDate,@NullableDateOnlyConverter() DateTime? expiryDate, Money? unitPrice, String? currency, String? varianceNote
});


@override $ProductRefDtoCopyWith<$Res> get product;

}
/// @nodoc
class __$GoodsReceiptLineDtoCopyWithImpl<$Res>
    implements _$GoodsReceiptLineDtoCopyWith<$Res> {
  __$GoodsReceiptLineDtoCopyWithImpl(this._self, this._then);

  final _GoodsReceiptLineDto _self;
  final $Res Function(_GoodsReceiptLineDto) _then;

/// Create a copy of GoodsReceiptLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? product = null,Object? receivedQty = null,Object? uomId = null,Object? rejectedQty = null,Object? id = freezed,Object? poLineId = freezed,Object? batchId = freezed,Object? orderedQty = freezed,Object? acceptedQtyBase = freezed,Object? varianceQty = freezed,Object? uomCode = freezed,Object? batchNo = freezed,Object? productionDate = freezed,Object? expiryDate = freezed,Object? unitPrice = freezed,Object? currency = freezed,Object? varianceNote = freezed,}) {
  return _then(_GoodsReceiptLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,rejectedQty: null == rejectedQty ? _self.rejectedQty : rejectedQty // ignore: cast_nullable_to_non_nullable
as Quantity,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,poLineId: freezed == poLineId ? _self.poLineId : poLineId // ignore: cast_nullable_to_non_nullable
as int?,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,orderedQty: freezed == orderedQty ? _self.orderedQty : orderedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,acceptedQtyBase: freezed == acceptedQtyBase ? _self.acceptedQtyBase : acceptedQtyBase // ignore: cast_nullable_to_non_nullable
as Quantity?,varianceQty: freezed == varianceQty ? _self.varianceQty : varianceQty // ignore: cast_nullable_to_non_nullable
as Quantity?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,productionDate: freezed == productionDate ? _self.productionDate : productionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,varianceNote: freezed == varianceNote ? _self.varianceNote : varianceNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of GoodsReceiptLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// @nodoc
mixin _$GoodsReceiptDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; int get supplierId; int get locationId; QualityStatus get qualityStatus; ReceiptStatus get status; int? get poId; String? get poDocNo; String? get supplierName; String? get locationName; Decimal? get temperatureC; String? get packagingNote; int? get movementGroupId; DateTime? get postedAt; bool get hasVariance; int get lineCount; List<int> get attachmentIds; AuditFieldsDto? get audit; int get rowVersion; List<GoodsReceiptLineDto> get lines;
/// Create a copy of GoodsReceiptDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoodsReceiptDtoCopyWith<GoodsReceiptDto> get copyWith => _$GoodsReceiptDtoCopyWithImpl<GoodsReceiptDto>(this as GoodsReceiptDto, _$identity);

  /// Serializes this GoodsReceiptDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GoodsReceiptDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoodsReceiptDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.qualityStatus, _this.qualityStatus) || other.qualityStatus == _this.qualityStatus)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.poId, _this.poId) || other.poId == _this.poId)&&(identical(other.poDocNo, _this.poDocNo) || other.poDocNo == _this.poDocNo)&&(identical(other.supplierName, _this.supplierName) || other.supplierName == _this.supplierName)&&(identical(other.locationName, _this.locationName) || other.locationName == _this.locationName)&&(identical(other.temperatureC, _this.temperatureC) || other.temperatureC == _this.temperatureC)&&(identical(other.packagingNote, _this.packagingNote) || other.packagingNote == _this.packagingNote)&&(identical(other.movementGroupId, _this.movementGroupId) || other.movementGroupId == _this.movementGroupId)&&(identical(other.postedAt, _this.postedAt) || other.postedAt == _this.postedAt)&&(identical(other.hasVariance, _this.hasVariance) || other.hasVariance == _this.hasVariance)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&const DeepCollectionEquality().equals(other.attachmentIds, _this.attachmentIds)&&(identical(other.audit, _this.audit) || other.audit == _this.audit)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoodsReceiptDto;
  return Object.hashAll([runtimeType,_this.id,_this.docNo,_this.docDate,_this.supplierId,_this.locationId,_this.qualityStatus,_this.status,_this.poId,_this.poDocNo,_this.supplierName,_this.locationName,_this.temperatureC,_this.packagingNote,_this.movementGroupId,_this.postedAt,_this.hasVariance,_this.lineCount,const DeepCollectionEquality().hash(_this.attachmentIds),_this.audit,_this.rowVersion,const DeepCollectionEquality().hash(_this.lines)]);
}

@override
String toString() {
  final _this = this as GoodsReceiptDto;
  return 'GoodsReceiptDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, supplierId: ${_this.supplierId}, locationId: ${_this.locationId}, qualityStatus: ${_this.qualityStatus}, status: ${_this.status}, poId: ${_this.poId}, poDocNo: ${_this.poDocNo}, supplierName: ${_this.supplierName}, locationName: ${_this.locationName}, temperatureC: ${_this.temperatureC}, packagingNote: ${_this.packagingNote}, movementGroupId: ${_this.movementGroupId}, postedAt: ${_this.postedAt}, hasVariance: ${_this.hasVariance}, lineCount: ${_this.lineCount}, attachmentIds: ${_this.attachmentIds}, audit: ${_this.audit}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $GoodsReceiptDtoCopyWith<$Res>  {
  factory $GoodsReceiptDtoCopyWith(GoodsReceiptDto value, $Res Function(GoodsReceiptDto) _then) = _$GoodsReceiptDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, int supplierId, int locationId, QualityStatus qualityStatus, ReceiptStatus status, int? poId, String? poDocNo, String? supplierName, String? locationName, Decimal? temperatureC, String? packagingNote, int? movementGroupId, DateTime? postedAt, bool hasVariance, int lineCount, List<int> attachmentIds, AuditFieldsDto? audit, int rowVersion, List<GoodsReceiptLineDto> lines
});


$AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class _$GoodsReceiptDtoCopyWithImpl<$Res>
    implements $GoodsReceiptDtoCopyWith<$Res> {
  _$GoodsReceiptDtoCopyWithImpl(this._self, this._then);

  final GoodsReceiptDto _self;
  final $Res Function(GoodsReceiptDto) _then;

/// Create a copy of GoodsReceiptDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? supplierId = null,Object? locationId = null,Object? qualityStatus = null,Object? status = null,Object? poId = freezed,Object? poDocNo = freezed,Object? supplierName = freezed,Object? locationName = freezed,Object? temperatureC = freezed,Object? packagingNote = freezed,Object? movementGroupId = freezed,Object? postedAt = freezed,Object? hasVariance = null,Object? lineCount = null,Object? attachmentIds = null,Object? audit = freezed,Object? rowVersion = null,Object? lines = null,}) {
  return _then(GoodsReceiptDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,qualityStatus: null == qualityStatus ? _self.qualityStatus : qualityStatus // ignore: cast_nullable_to_non_nullable
as QualityStatus,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReceiptStatus,poId: freezed == poId ? _self.poId : poId // ignore: cast_nullable_to_non_nullable
as int?,poDocNo: freezed == poDocNo ? _self.poDocNo : poDocNo // ignore: cast_nullable_to_non_nullable
as String?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as Decimal?,packagingNote: freezed == packagingNote ? _self.packagingNote : packagingNote // ignore: cast_nullable_to_non_nullable
as String?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,postedAt: freezed == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasVariance: null == hasVariance ? _self.hasVariance : hasVariance // ignore: cast_nullable_to_non_nullable
as bool,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,attachmentIds: null == attachmentIds ? _self.attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<GoodsReceiptLineDto>,
  ));
}
/// Create a copy of GoodsReceiptDto
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


/// Adds pattern-matching-related methods to [GoodsReceiptDto].
extension GoodsReceiptDtoPatterns on GoodsReceiptDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoodsReceiptDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoodsReceiptDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoodsReceiptDto value)  $default,){
final _that = this;
switch (_that) {
case _GoodsReceiptDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoodsReceiptDto value)?  $default,){
final _that = this;
switch (_that) {
case _GoodsReceiptDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int supplierId,  int locationId,  QualityStatus qualityStatus,  ReceiptStatus status,  int? poId,  String? poDocNo,  String? supplierName,  String? locationName,  Decimal? temperatureC,  String? packagingNote,  int? movementGroupId,  DateTime? postedAt,  bool hasVariance,  int lineCount,  List<int> attachmentIds,  AuditFieldsDto? audit,  int rowVersion,  List<GoodsReceiptLineDto> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoodsReceiptDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.supplierId,_that.locationId,_that.qualityStatus,_that.status,_that.poId,_that.poDocNo,_that.supplierName,_that.locationName,_that.temperatureC,_that.packagingNote,_that.movementGroupId,_that.postedAt,_that.hasVariance,_that.lineCount,_that.attachmentIds,_that.audit,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int supplierId,  int locationId,  QualityStatus qualityStatus,  ReceiptStatus status,  int? poId,  String? poDocNo,  String? supplierName,  String? locationName,  Decimal? temperatureC,  String? packagingNote,  int? movementGroupId,  DateTime? postedAt,  bool hasVariance,  int lineCount,  List<int> attachmentIds,  AuditFieldsDto? audit,  int rowVersion,  List<GoodsReceiptLineDto> lines)  $default,) {final _that = this;
switch (_that) {
case _GoodsReceiptDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.supplierId,_that.locationId,_that.qualityStatus,_that.status,_that.poId,_that.poDocNo,_that.supplierName,_that.locationName,_that.temperatureC,_that.packagingNote,_that.movementGroupId,_that.postedAt,_that.hasVariance,_that.lineCount,_that.attachmentIds,_that.audit,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int supplierId,  int locationId,  QualityStatus qualityStatus,  ReceiptStatus status,  int? poId,  String? poDocNo,  String? supplierName,  String? locationName,  Decimal? temperatureC,  String? packagingNote,  int? movementGroupId,  DateTime? postedAt,  bool hasVariance,  int lineCount,  List<int> attachmentIds,  AuditFieldsDto? audit,  int rowVersion,  List<GoodsReceiptLineDto> lines)?  $default,) {final _that = this;
switch (_that) {
case _GoodsReceiptDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.supplierId,_that.locationId,_that.qualityStatus,_that.status,_that.poId,_that.poDocNo,_that.supplierName,_that.locationName,_that.temperatureC,_that.packagingNote,_that.movementGroupId,_that.postedAt,_that.hasVariance,_that.lineCount,_that.attachmentIds,_that.audit,_that.rowVersion,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoodsReceiptDto implements GoodsReceiptDto {
  const _GoodsReceiptDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.supplierId, required this.locationId, required this.qualityStatus, required this.status, this.poId, this.poDocNo, this.supplierName, this.locationName, this.temperatureC, this.packagingNote, this.movementGroupId, this.postedAt, this.hasVariance = false, this.lineCount = 0,  List<int> attachmentIds = const <int>[], this.audit, this.rowVersion = 1,  List<GoodsReceiptLineDto> lines = const <GoodsReceiptLineDto>[]}): _attachmentIds = attachmentIds,_lines = lines;
  factory _GoodsReceiptDto.fromJson(Map<String, dynamic> json) => _$GoodsReceiptDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override@DateOnlyConverter() final  DateTime docDate;
@override final  int supplierId;
@override final  int locationId;
@override final  QualityStatus qualityStatus;
@override final  ReceiptStatus status;
@override final  int? poId;
@override final  String? poDocNo;
@override final  String? supplierName;
@override final  String? locationName;
@override final  Decimal? temperatureC;
@override final  String? packagingNote;
@override final  int? movementGroupId;
@override final  DateTime? postedAt;
@override@JsonKey() final  bool hasVariance;
@override@JsonKey() final  int lineCount;
 final  List<int> _attachmentIds;
@override@JsonKey() List<int> get attachmentIds {
  if (_attachmentIds is EqualUnmodifiableListView) return _attachmentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachmentIds);
}

@override final  AuditFieldsDto? audit;
@override@JsonKey() final  int rowVersion;
 final  List<GoodsReceiptLineDto> _lines;
@override@JsonKey() List<GoodsReceiptLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of GoodsReceiptDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoodsReceiptDtoCopyWith<_GoodsReceiptDto> get copyWith => __$GoodsReceiptDtoCopyWithImpl<_GoodsReceiptDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoodsReceiptDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoodsReceiptDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.qualityStatus, qualityStatus) || other.qualityStatus == qualityStatus)&&(identical(other.status, status) || other.status == status)&&(identical(other.poId, poId) || other.poId == poId)&&(identical(other.poDocNo, poDocNo) || other.poDocNo == poDocNo)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.packagingNote, packagingNote) || other.packagingNote == packagingNote)&&(identical(other.movementGroupId, movementGroupId) || other.movementGroupId == movementGroupId)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt)&&(identical(other.hasVariance, hasVariance) || other.hasVariance == hasVariance)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&const DeepCollectionEquality().equals(other.attachmentIds, _attachmentIds)&&(identical(other.audit, audit) || other.audit == audit)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,docNo,docDate,supplierId,locationId,qualityStatus,status,poId,poDocNo,supplierName,locationName,temperatureC,packagingNote,movementGroupId,postedAt,hasVariance,lineCount,const DeepCollectionEquality().hash(_attachmentIds),audit,rowVersion,const DeepCollectionEquality().hash(_lines)]);
}

@override
String toString() {
    return 'GoodsReceiptDto(id: $id, docNo: $docNo, docDate: $docDate, supplierId: $supplierId, locationId: $locationId, qualityStatus: $qualityStatus, status: $status, poId: $poId, poDocNo: $poDocNo, supplierName: $supplierName, locationName: $locationName, temperatureC: $temperatureC, packagingNote: $packagingNote, movementGroupId: $movementGroupId, postedAt: $postedAt, hasVariance: $hasVariance, lineCount: $lineCount, attachmentIds: $attachmentIds, audit: $audit, rowVersion: $rowVersion, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$GoodsReceiptDtoCopyWith<$Res> implements $GoodsReceiptDtoCopyWith<$Res> {
  factory _$GoodsReceiptDtoCopyWith(_GoodsReceiptDto value, $Res Function(_GoodsReceiptDto) _then) = __$GoodsReceiptDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, int supplierId, int locationId, QualityStatus qualityStatus, ReceiptStatus status, int? poId, String? poDocNo, String? supplierName, String? locationName, Decimal? temperatureC, String? packagingNote, int? movementGroupId, DateTime? postedAt, bool hasVariance, int lineCount, List<int> attachmentIds, AuditFieldsDto? audit, int rowVersion, List<GoodsReceiptLineDto> lines
});


@override $AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class __$GoodsReceiptDtoCopyWithImpl<$Res>
    implements _$GoodsReceiptDtoCopyWith<$Res> {
  __$GoodsReceiptDtoCopyWithImpl(this._self, this._then);

  final _GoodsReceiptDto _self;
  final $Res Function(_GoodsReceiptDto) _then;

/// Create a copy of GoodsReceiptDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? supplierId = null,Object? locationId = null,Object? qualityStatus = null,Object? status = null,Object? poId = freezed,Object? poDocNo = freezed,Object? supplierName = freezed,Object? locationName = freezed,Object? temperatureC = freezed,Object? packagingNote = freezed,Object? movementGroupId = freezed,Object? postedAt = freezed,Object? hasVariance = null,Object? lineCount = null,Object? attachmentIds = null,Object? audit = freezed,Object? rowVersion = null,Object? lines = null,}) {
  return _then(_GoodsReceiptDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,qualityStatus: null == qualityStatus ? _self.qualityStatus : qualityStatus // ignore: cast_nullable_to_non_nullable
as QualityStatus,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReceiptStatus,poId: freezed == poId ? _self.poId : poId // ignore: cast_nullable_to_non_nullable
as int?,poDocNo: freezed == poDocNo ? _self.poDocNo : poDocNo // ignore: cast_nullable_to_non_nullable
as String?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as Decimal?,packagingNote: freezed == packagingNote ? _self.packagingNote : packagingNote // ignore: cast_nullable_to_non_nullable
as String?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,postedAt: freezed == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasVariance: null == hasVariance ? _self.hasVariance : hasVariance // ignore: cast_nullable_to_non_nullable
as bool,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,attachmentIds: null == attachmentIds ? _self._attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<GoodsReceiptLineDto>,
  ));
}

/// Create a copy of GoodsReceiptDto
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
mixin _$CreateGoodsReceiptLine {

 int get productId; Quantity get receivedQty; int get uomId; int? get poLineId; Quantity? get orderedQty; Quantity? get rejectedQty; String? get batchNo;@NullableDateOnlyConverter() DateTime? get productionDate;@NullableDateOnlyConverter() DateTime? get expiryDate; Money? get unitPrice; String? get currency; String? get varianceNote;
/// Create a copy of CreateGoodsReceiptLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateGoodsReceiptLineCopyWith<CreateGoodsReceiptLine> get copyWith => _$CreateGoodsReceiptLineCopyWithImpl<CreateGoodsReceiptLine>(this as CreateGoodsReceiptLine, _$identity);

  /// Serializes this CreateGoodsReceiptLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateGoodsReceiptLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateGoodsReceiptLine&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.receivedQty, _this.receivedQty) || other.receivedQty == _this.receivedQty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.poLineId, _this.poLineId) || other.poLineId == _this.poLineId)&&(identical(other.orderedQty, _this.orderedQty) || other.orderedQty == _this.orderedQty)&&(identical(other.rejectedQty, _this.rejectedQty) || other.rejectedQty == _this.rejectedQty)&&(identical(other.batchNo, _this.batchNo) || other.batchNo == _this.batchNo)&&(identical(other.productionDate, _this.productionDate) || other.productionDate == _this.productionDate)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.varianceNote, _this.varianceNote) || other.varianceNote == _this.varianceNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateGoodsReceiptLine;
  return Object.hash(runtimeType,_this.productId,_this.receivedQty,_this.uomId,_this.poLineId,_this.orderedQty,_this.rejectedQty,_this.batchNo,_this.productionDate,_this.expiryDate,_this.unitPrice,_this.currency,_this.varianceNote);
}

@override
String toString() {
  final _this = this as CreateGoodsReceiptLine;
  return 'CreateGoodsReceiptLine(productId: ${_this.productId}, receivedQty: ${_this.receivedQty}, uomId: ${_this.uomId}, poLineId: ${_this.poLineId}, orderedQty: ${_this.orderedQty}, rejectedQty: ${_this.rejectedQty}, batchNo: ${_this.batchNo}, productionDate: ${_this.productionDate}, expiryDate: ${_this.expiryDate}, unitPrice: ${_this.unitPrice}, currency: ${_this.currency}, varianceNote: ${_this.varianceNote})';
}


}

/// @nodoc
abstract mixin class $CreateGoodsReceiptLineCopyWith<$Res>  {
  factory $CreateGoodsReceiptLineCopyWith(CreateGoodsReceiptLine value, $Res Function(CreateGoodsReceiptLine) _then) = _$CreateGoodsReceiptLineCopyWithImpl;
@useResult
$Res call({
 int productId, Quantity receivedQty, int uomId, int? poLineId, Quantity? orderedQty, Quantity? rejectedQty, String? batchNo,@NullableDateOnlyConverter() DateTime? productionDate,@NullableDateOnlyConverter() DateTime? expiryDate, Money? unitPrice, String? currency, String? varianceNote
});




}
/// @nodoc
class _$CreateGoodsReceiptLineCopyWithImpl<$Res>
    implements $CreateGoodsReceiptLineCopyWith<$Res> {
  _$CreateGoodsReceiptLineCopyWithImpl(this._self, this._then);

  final CreateGoodsReceiptLine _self;
  final $Res Function(CreateGoodsReceiptLine) _then;

/// Create a copy of CreateGoodsReceiptLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? receivedQty = null,Object? uomId = null,Object? poLineId = freezed,Object? orderedQty = freezed,Object? rejectedQty = freezed,Object? batchNo = freezed,Object? productionDate = freezed,Object? expiryDate = freezed,Object? unitPrice = freezed,Object? currency = freezed,Object? varianceNote = freezed,}) {
  return _then(CreateGoodsReceiptLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,poLineId: freezed == poLineId ? _self.poLineId : poLineId // ignore: cast_nullable_to_non_nullable
as int?,orderedQty: freezed == orderedQty ? _self.orderedQty : orderedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,rejectedQty: freezed == rejectedQty ? _self.rejectedQty : rejectedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,productionDate: freezed == productionDate ? _self.productionDate : productionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,varianceNote: freezed == varianceNote ? _self.varianceNote : varianceNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateGoodsReceiptLine].
extension CreateGoodsReceiptLinePatterns on CreateGoodsReceiptLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateGoodsReceiptLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateGoodsReceiptLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateGoodsReceiptLine value)  $default,){
final _that = this;
switch (_that) {
case _CreateGoodsReceiptLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateGoodsReceiptLine value)?  $default,){
final _that = this;
switch (_that) {
case _CreateGoodsReceiptLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  Quantity receivedQty,  int uomId,  int? poLineId,  Quantity? orderedQty,  Quantity? rejectedQty,  String? batchNo, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  Money? unitPrice,  String? currency,  String? varianceNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateGoodsReceiptLine() when $default != null:
return $default(_that.productId,_that.receivedQty,_that.uomId,_that.poLineId,_that.orderedQty,_that.rejectedQty,_that.batchNo,_that.productionDate,_that.expiryDate,_that.unitPrice,_that.currency,_that.varianceNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  Quantity receivedQty,  int uomId,  int? poLineId,  Quantity? orderedQty,  Quantity? rejectedQty,  String? batchNo, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  Money? unitPrice,  String? currency,  String? varianceNote)  $default,) {final _that = this;
switch (_that) {
case _CreateGoodsReceiptLine():
return $default(_that.productId,_that.receivedQty,_that.uomId,_that.poLineId,_that.orderedQty,_that.rejectedQty,_that.batchNo,_that.productionDate,_that.expiryDate,_that.unitPrice,_that.currency,_that.varianceNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  Quantity receivedQty,  int uomId,  int? poLineId,  Quantity? orderedQty,  Quantity? rejectedQty,  String? batchNo, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  Money? unitPrice,  String? currency,  String? varianceNote)?  $default,) {final _that = this;
switch (_that) {
case _CreateGoodsReceiptLine() when $default != null:
return $default(_that.productId,_that.receivedQty,_that.uomId,_that.poLineId,_that.orderedQty,_that.rejectedQty,_that.batchNo,_that.productionDate,_that.expiryDate,_that.unitPrice,_that.currency,_that.varianceNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateGoodsReceiptLine implements CreateGoodsReceiptLine {
  const _CreateGoodsReceiptLine({required this.productId, required this.receivedQty, required this.uomId, this.poLineId, this.orderedQty, this.rejectedQty, this.batchNo, @NullableDateOnlyConverter() this.productionDate, @NullableDateOnlyConverter() this.expiryDate, this.unitPrice, this.currency, this.varianceNote});
  factory _CreateGoodsReceiptLine.fromJson(Map<String, dynamic> json) => _$CreateGoodsReceiptLineFromJson(json);

@override final  int productId;
@override final  Quantity receivedQty;
@override final  int uomId;
@override final  int? poLineId;
@override final  Quantity? orderedQty;
@override final  Quantity? rejectedQty;
@override final  String? batchNo;
@override@NullableDateOnlyConverter() final  DateTime? productionDate;
@override@NullableDateOnlyConverter() final  DateTime? expiryDate;
@override final  Money? unitPrice;
@override final  String? currency;
@override final  String? varianceNote;

/// Create a copy of CreateGoodsReceiptLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateGoodsReceiptLineCopyWith<_CreateGoodsReceiptLine> get copyWith => __$CreateGoodsReceiptLineCopyWithImpl<_CreateGoodsReceiptLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateGoodsReceiptLineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateGoodsReceiptLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.receivedQty, receivedQty) || other.receivedQty == receivedQty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.poLineId, poLineId) || other.poLineId == poLineId)&&(identical(other.orderedQty, orderedQty) || other.orderedQty == orderedQty)&&(identical(other.rejectedQty, rejectedQty) || other.rejectedQty == rejectedQty)&&(identical(other.batchNo, batchNo) || other.batchNo == batchNo)&&(identical(other.productionDate, productionDate) || other.productionDate == productionDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.varianceNote, varianceNote) || other.varianceNote == varianceNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,receivedQty,uomId,poLineId,orderedQty,rejectedQty,batchNo,productionDate,expiryDate,unitPrice,currency,varianceNote);
}

@override
String toString() {
    return 'CreateGoodsReceiptLine(productId: $productId, receivedQty: $receivedQty, uomId: $uomId, poLineId: $poLineId, orderedQty: $orderedQty, rejectedQty: $rejectedQty, batchNo: $batchNo, productionDate: $productionDate, expiryDate: $expiryDate, unitPrice: $unitPrice, currency: $currency, varianceNote: $varianceNote)';
}


}

/// @nodoc
abstract mixin class _$CreateGoodsReceiptLineCopyWith<$Res> implements $CreateGoodsReceiptLineCopyWith<$Res> {
  factory _$CreateGoodsReceiptLineCopyWith(_CreateGoodsReceiptLine value, $Res Function(_CreateGoodsReceiptLine) _then) = __$CreateGoodsReceiptLineCopyWithImpl;
@override @useResult
$Res call({
 int productId, Quantity receivedQty, int uomId, int? poLineId, Quantity? orderedQty, Quantity? rejectedQty, String? batchNo,@NullableDateOnlyConverter() DateTime? productionDate,@NullableDateOnlyConverter() DateTime? expiryDate, Money? unitPrice, String? currency, String? varianceNote
});




}
/// @nodoc
class __$CreateGoodsReceiptLineCopyWithImpl<$Res>
    implements _$CreateGoodsReceiptLineCopyWith<$Res> {
  __$CreateGoodsReceiptLineCopyWithImpl(this._self, this._then);

  final _CreateGoodsReceiptLine _self;
  final $Res Function(_CreateGoodsReceiptLine) _then;

/// Create a copy of CreateGoodsReceiptLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? receivedQty = null,Object? uomId = null,Object? poLineId = freezed,Object? orderedQty = freezed,Object? rejectedQty = freezed,Object? batchNo = freezed,Object? productionDate = freezed,Object? expiryDate = freezed,Object? unitPrice = freezed,Object? currency = freezed,Object? varianceNote = freezed,}) {
  return _then(_CreateGoodsReceiptLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,poLineId: freezed == poLineId ? _self.poLineId : poLineId // ignore: cast_nullable_to_non_nullable
as int?,orderedQty: freezed == orderedQty ? _self.orderedQty : orderedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,rejectedQty: freezed == rejectedQty ? _self.rejectedQty : rejectedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,productionDate: freezed == productionDate ? _self.productionDate : productionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,varianceNote: freezed == varianceNote ? _self.varianceNote : varianceNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateGoodsReceiptRequest {

@DateOnlyConverter() DateTime get docDate; int get supplierId; int get locationId; QualityStatus get qualityStatus; List<CreateGoodsReceiptLine> get lines; int? get poId; Decimal? get temperatureC; String? get packagingNote;
/// Create a copy of CreateGoodsReceiptRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateGoodsReceiptRequestCopyWith<CreateGoodsReceiptRequest> get copyWith => _$CreateGoodsReceiptRequestCopyWithImpl<CreateGoodsReceiptRequest>(this as CreateGoodsReceiptRequest, _$identity);

  /// Serializes this CreateGoodsReceiptRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateGoodsReceiptRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateGoodsReceiptRequest&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.qualityStatus, _this.qualityStatus) || other.qualityStatus == _this.qualityStatus)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.poId, _this.poId) || other.poId == _this.poId)&&(identical(other.temperatureC, _this.temperatureC) || other.temperatureC == _this.temperatureC)&&(identical(other.packagingNote, _this.packagingNote) || other.packagingNote == _this.packagingNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateGoodsReceiptRequest;
  return Object.hash(runtimeType,_this.docDate,_this.supplierId,_this.locationId,_this.qualityStatus,const DeepCollectionEquality().hash(_this.lines),_this.poId,_this.temperatureC,_this.packagingNote);
}

@override
String toString() {
  final _this = this as CreateGoodsReceiptRequest;
  return 'CreateGoodsReceiptRequest(docDate: ${_this.docDate}, supplierId: ${_this.supplierId}, locationId: ${_this.locationId}, qualityStatus: ${_this.qualityStatus}, lines: ${_this.lines}, poId: ${_this.poId}, temperatureC: ${_this.temperatureC}, packagingNote: ${_this.packagingNote})';
}


}

/// @nodoc
abstract mixin class $CreateGoodsReceiptRequestCopyWith<$Res>  {
  factory $CreateGoodsReceiptRequestCopyWith(CreateGoodsReceiptRequest value, $Res Function(CreateGoodsReceiptRequest) _then) = _$CreateGoodsReceiptRequestCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime docDate, int supplierId, int locationId, QualityStatus qualityStatus, List<CreateGoodsReceiptLine> lines, int? poId, Decimal? temperatureC, String? packagingNote
});




}
/// @nodoc
class _$CreateGoodsReceiptRequestCopyWithImpl<$Res>
    implements $CreateGoodsReceiptRequestCopyWith<$Res> {
  _$CreateGoodsReceiptRequestCopyWithImpl(this._self, this._then);

  final CreateGoodsReceiptRequest _self;
  final $Res Function(CreateGoodsReceiptRequest) _then;

/// Create a copy of CreateGoodsReceiptRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? docDate = null,Object? supplierId = null,Object? locationId = null,Object? qualityStatus = null,Object? lines = null,Object? poId = freezed,Object? temperatureC = freezed,Object? packagingNote = freezed,}) {
  return _then(CreateGoodsReceiptRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,qualityStatus: null == qualityStatus ? _self.qualityStatus : qualityStatus // ignore: cast_nullable_to_non_nullable
as QualityStatus,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateGoodsReceiptLine>,poId: freezed == poId ? _self.poId : poId // ignore: cast_nullable_to_non_nullable
as int?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as Decimal?,packagingNote: freezed == packagingNote ? _self.packagingNote : packagingNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateGoodsReceiptRequest].
extension CreateGoodsReceiptRequestPatterns on CreateGoodsReceiptRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateGoodsReceiptRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateGoodsReceiptRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateGoodsReceiptRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateGoodsReceiptRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateGoodsReceiptRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateGoodsReceiptRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  int supplierId,  int locationId,  QualityStatus qualityStatus,  List<CreateGoodsReceiptLine> lines,  int? poId,  Decimal? temperatureC,  String? packagingNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateGoodsReceiptRequest() when $default != null:
return $default(_that.docDate,_that.supplierId,_that.locationId,_that.qualityStatus,_that.lines,_that.poId,_that.temperatureC,_that.packagingNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  int supplierId,  int locationId,  QualityStatus qualityStatus,  List<CreateGoodsReceiptLine> lines,  int? poId,  Decimal? temperatureC,  String? packagingNote)  $default,) {final _that = this;
switch (_that) {
case _CreateGoodsReceiptRequest():
return $default(_that.docDate,_that.supplierId,_that.locationId,_that.qualityStatus,_that.lines,_that.poId,_that.temperatureC,_that.packagingNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime docDate,  int supplierId,  int locationId,  QualityStatus qualityStatus,  List<CreateGoodsReceiptLine> lines,  int? poId,  Decimal? temperatureC,  String? packagingNote)?  $default,) {final _that = this;
switch (_that) {
case _CreateGoodsReceiptRequest() when $default != null:
return $default(_that.docDate,_that.supplierId,_that.locationId,_that.qualityStatus,_that.lines,_that.poId,_that.temperatureC,_that.packagingNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateGoodsReceiptRequest implements CreateGoodsReceiptRequest {
  const _CreateGoodsReceiptRequest({@DateOnlyConverter() required this.docDate, required this.supplierId, required this.locationId, required this.qualityStatus, required  List<CreateGoodsReceiptLine> lines, this.poId, this.temperatureC, this.packagingNote}): _lines = lines;
  factory _CreateGoodsReceiptRequest.fromJson(Map<String, dynamic> json) => _$CreateGoodsReceiptRequestFromJson(json);

@override@DateOnlyConverter() final  DateTime docDate;
@override final  int supplierId;
@override final  int locationId;
@override final  QualityStatus qualityStatus;
 final  List<CreateGoodsReceiptLine> _lines;
@override List<CreateGoodsReceiptLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  int? poId;
@override final  Decimal? temperatureC;
@override final  String? packagingNote;

/// Create a copy of CreateGoodsReceiptRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateGoodsReceiptRequestCopyWith<_CreateGoodsReceiptRequest> get copyWith => __$CreateGoodsReceiptRequestCopyWithImpl<_CreateGoodsReceiptRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateGoodsReceiptRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateGoodsReceiptRequest&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.qualityStatus, qualityStatus) || other.qualityStatus == qualityStatus)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.poId, poId) || other.poId == poId)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.packagingNote, packagingNote) || other.packagingNote == packagingNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,docDate,supplierId,locationId,qualityStatus,const DeepCollectionEquality().hash(_lines),poId,temperatureC,packagingNote);
}

@override
String toString() {
    return 'CreateGoodsReceiptRequest(docDate: $docDate, supplierId: $supplierId, locationId: $locationId, qualityStatus: $qualityStatus, lines: $lines, poId: $poId, temperatureC: $temperatureC, packagingNote: $packagingNote)';
}


}

/// @nodoc
abstract mixin class _$CreateGoodsReceiptRequestCopyWith<$Res> implements $CreateGoodsReceiptRequestCopyWith<$Res> {
  factory _$CreateGoodsReceiptRequestCopyWith(_CreateGoodsReceiptRequest value, $Res Function(_CreateGoodsReceiptRequest) _then) = __$CreateGoodsReceiptRequestCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime docDate, int supplierId, int locationId, QualityStatus qualityStatus, List<CreateGoodsReceiptLine> lines, int? poId, Decimal? temperatureC, String? packagingNote
});




}
/// @nodoc
class __$CreateGoodsReceiptRequestCopyWithImpl<$Res>
    implements _$CreateGoodsReceiptRequestCopyWith<$Res> {
  __$CreateGoodsReceiptRequestCopyWithImpl(this._self, this._then);

  final _CreateGoodsReceiptRequest _self;
  final $Res Function(_CreateGoodsReceiptRequest) _then;

/// Create a copy of CreateGoodsReceiptRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? docDate = null,Object? supplierId = null,Object? locationId = null,Object? qualityStatus = null,Object? lines = null,Object? poId = freezed,Object? temperatureC = freezed,Object? packagingNote = freezed,}) {
  return _then(_CreateGoodsReceiptRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,qualityStatus: null == qualityStatus ? _self.qualityStatus : qualityStatus // ignore: cast_nullable_to_non_nullable
as QualityStatus,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateGoodsReceiptLine>,poId: freezed == poId ? _self.poId : poId // ignore: cast_nullable_to_non_nullable
as int?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as Decimal?,packagingNote: freezed == packagingNote ? _self.packagingNote : packagingNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StockRequestLineDto {

 int get lineNo; ProductRefDto get product; Quantity get qty; int get uomId; Quantity get issuedQty; int? get id; String? get uomCode; String? get note;
/// Create a copy of StockRequestLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockRequestLineDtoCopyWith<StockRequestLineDto> get copyWith => _$StockRequestLineDtoCopyWithImpl<StockRequestLineDto>(this as StockRequestLineDto, _$identity);

  /// Serializes this StockRequestLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StockRequestLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockRequestLineDto&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.issuedQty, _this.issuedQty) || other.issuedQty == _this.issuedQty)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StockRequestLineDto;
  return Object.hash(runtimeType,_this.lineNo,_this.product,_this.qty,_this.uomId,_this.issuedQty,_this.id,_this.uomCode,_this.note);
}

@override
String toString() {
  final _this = this as StockRequestLineDto;
  return 'StockRequestLineDto(lineNo: ${_this.lineNo}, product: ${_this.product}, qty: ${_this.qty}, uomId: ${_this.uomId}, issuedQty: ${_this.issuedQty}, id: ${_this.id}, uomCode: ${_this.uomCode}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $StockRequestLineDtoCopyWith<$Res>  {
  factory $StockRequestLineDtoCopyWith(StockRequestLineDto value, $Res Function(StockRequestLineDto) _then) = _$StockRequestLineDtoCopyWithImpl;
@useResult
$Res call({
 int lineNo, ProductRefDto product, Quantity qty, int uomId, Quantity issuedQty, int? id, String? uomCode, String? note
});


$ProductRefDtoCopyWith<$Res> get product;

}
/// @nodoc
class _$StockRequestLineDtoCopyWithImpl<$Res>
    implements $StockRequestLineDtoCopyWith<$Res> {
  _$StockRequestLineDtoCopyWithImpl(this._self, this._then);

  final StockRequestLineDto _self;
  final $Res Function(StockRequestLineDto) _then;

/// Create a copy of StockRequestLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? issuedQty = null,Object? id = freezed,Object? uomCode = freezed,Object? note = freezed,}) {
  return _then(StockRequestLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,issuedQty: null == issuedQty ? _self.issuedQty : issuedQty // ignore: cast_nullable_to_non_nullable
as Quantity,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of StockRequestLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [StockRequestLineDto].
extension StockRequestLineDtoPatterns on StockRequestLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockRequestLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockRequestLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockRequestLineDto value)  $default,){
final _that = this;
switch (_that) {
case _StockRequestLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockRequestLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _StockRequestLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  Quantity issuedQty,  int? id,  String? uomCode,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockRequestLineDto() when $default != null:
return $default(_that.lineNo,_that.product,_that.qty,_that.uomId,_that.issuedQty,_that.id,_that.uomCode,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  Quantity issuedQty,  int? id,  String? uomCode,  String? note)  $default,) {final _that = this;
switch (_that) {
case _StockRequestLineDto():
return $default(_that.lineNo,_that.product,_that.qty,_that.uomId,_that.issuedQty,_that.id,_that.uomCode,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  Quantity issuedQty,  int? id,  String? uomCode,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _StockRequestLineDto() when $default != null:
return $default(_that.lineNo,_that.product,_that.qty,_that.uomId,_that.issuedQty,_that.id,_that.uomCode,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockRequestLineDto implements StockRequestLineDto {
  const _StockRequestLineDto({required this.lineNo, required this.product, required this.qty, required this.uomId, required this.issuedQty, this.id, this.uomCode, this.note});
  factory _StockRequestLineDto.fromJson(Map<String, dynamic> json) => _$StockRequestLineDtoFromJson(json);

@override final  int lineNo;
@override final  ProductRefDto product;
@override final  Quantity qty;
@override final  int uomId;
@override final  Quantity issuedQty;
@override final  int? id;
@override final  String? uomCode;
@override final  String? note;

/// Create a copy of StockRequestLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockRequestLineDtoCopyWith<_StockRequestLineDto> get copyWith => __$StockRequestLineDtoCopyWithImpl<_StockRequestLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockRequestLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockRequestLineDto&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.product, product) || other.product == product)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.issuedQty, issuedQty) || other.issuedQty == issuedQty)&&(identical(other.id, id) || other.id == id)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,product,qty,uomId,issuedQty,id,uomCode,note);
}

@override
String toString() {
    return 'StockRequestLineDto(lineNo: $lineNo, product: $product, qty: $qty, uomId: $uomId, issuedQty: $issuedQty, id: $id, uomCode: $uomCode, note: $note)';
}


}

/// @nodoc
abstract mixin class _$StockRequestLineDtoCopyWith<$Res> implements $StockRequestLineDtoCopyWith<$Res> {
  factory _$StockRequestLineDtoCopyWith(_StockRequestLineDto value, $Res Function(_StockRequestLineDto) _then) = __$StockRequestLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, ProductRefDto product, Quantity qty, int uomId, Quantity issuedQty, int? id, String? uomCode, String? note
});


@override $ProductRefDtoCopyWith<$Res> get product;

}
/// @nodoc
class __$StockRequestLineDtoCopyWithImpl<$Res>
    implements _$StockRequestLineDtoCopyWith<$Res> {
  __$StockRequestLineDtoCopyWithImpl(this._self, this._then);

  final _StockRequestLineDto _self;
  final $Res Function(_StockRequestLineDto) _then;

/// Create a copy of StockRequestLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? issuedQty = null,Object? id = freezed,Object? uomCode = freezed,Object? note = freezed,}) {
  return _then(_StockRequestLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,issuedQty: null == issuedQty ? _self.issuedQty : issuedQty // ignore: cast_nullable_to_non_nullable
as Quantity,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of StockRequestLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// @nodoc
mixin _$StockRequestDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; LocationRefDto get fromLocation; LocationRefDto get toLocation; StockRequestStatus get status;@NullableDateOnlyConverter() DateTime? get requiredDate; String? get note; int get lineCount; List<int> get issueIds; AuditFieldsDto? get audit; int get rowVersion; List<StockRequestLineDto> get lines;
/// Create a copy of StockRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockRequestDtoCopyWith<StockRequestDto> get copyWith => _$StockRequestDtoCopyWithImpl<StockRequestDto>(this as StockRequestDto, _$identity);

  /// Serializes this StockRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StockRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockRequestDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.fromLocation, _this.fromLocation) || other.fromLocation == _this.fromLocation)&&(identical(other.toLocation, _this.toLocation) || other.toLocation == _this.toLocation)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.requiredDate, _this.requiredDate) || other.requiredDate == _this.requiredDate)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&const DeepCollectionEquality().equals(other.issueIds, _this.issueIds)&&(identical(other.audit, _this.audit) || other.audit == _this.audit)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StockRequestDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.docDate,_this.fromLocation,_this.toLocation,_this.status,_this.requiredDate,_this.note,_this.lineCount,const DeepCollectionEquality().hash(_this.issueIds),_this.audit,_this.rowVersion,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as StockRequestDto;
  return 'StockRequestDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, fromLocation: ${_this.fromLocation}, toLocation: ${_this.toLocation}, status: ${_this.status}, requiredDate: ${_this.requiredDate}, note: ${_this.note}, lineCount: ${_this.lineCount}, issueIds: ${_this.issueIds}, audit: ${_this.audit}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $StockRequestDtoCopyWith<$Res>  {
  factory $StockRequestDtoCopyWith(StockRequestDto value, $Res Function(StockRequestDto) _then) = _$StockRequestDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, LocationRefDto fromLocation, LocationRefDto toLocation, StockRequestStatus status,@NullableDateOnlyConverter() DateTime? requiredDate, String? note, int lineCount, List<int> issueIds, AuditFieldsDto? audit, int rowVersion, List<StockRequestLineDto> lines
});


$LocationRefDtoCopyWith<$Res> get fromLocation;$LocationRefDtoCopyWith<$Res> get toLocation;$AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class _$StockRequestDtoCopyWithImpl<$Res>
    implements $StockRequestDtoCopyWith<$Res> {
  _$StockRequestDtoCopyWithImpl(this._self, this._then);

  final StockRequestDto _self;
  final $Res Function(StockRequestDto) _then;

/// Create a copy of StockRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? fromLocation = null,Object? toLocation = null,Object? status = null,Object? requiredDate = freezed,Object? note = freezed,Object? lineCount = null,Object? issueIds = null,Object? audit = freezed,Object? rowVersion = null,Object? lines = null,}) {
  return _then(StockRequestDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,fromLocation: null == fromLocation ? _self.fromLocation : fromLocation // ignore: cast_nullable_to_non_nullable
as LocationRefDto,toLocation: null == toLocation ? _self.toLocation : toLocation // ignore: cast_nullable_to_non_nullable
as LocationRefDto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StockRequestStatus,requiredDate: freezed == requiredDate ? _self.requiredDate : requiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,issueIds: null == issueIds ? _self.issueIds : issueIds // ignore: cast_nullable_to_non_nullable
as List<int>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<StockRequestLineDto>,
  ));
}
/// Create a copy of StockRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get fromLocation {
  
  return $LocationRefDtoCopyWith<$Res>(_self.fromLocation, (value) {
    return _then(_self.copyWith(fromLocation: value));
  });
}/// Create a copy of StockRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get toLocation {
  
  return $LocationRefDtoCopyWith<$Res>(_self.toLocation, (value) {
    return _then(_self.copyWith(toLocation: value));
  });
}/// Create a copy of StockRequestDto
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


/// Adds pattern-matching-related methods to [StockRequestDto].
extension StockRequestDtoPatterns on StockRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _StockRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _StockRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  LocationRefDto fromLocation,  LocationRefDto toLocation,  StockRequestStatus status, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note,  int lineCount,  List<int> issueIds,  AuditFieldsDto? audit,  int rowVersion,  List<StockRequestLineDto> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockRequestDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.fromLocation,_that.toLocation,_that.status,_that.requiredDate,_that.note,_that.lineCount,_that.issueIds,_that.audit,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  LocationRefDto fromLocation,  LocationRefDto toLocation,  StockRequestStatus status, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note,  int lineCount,  List<int> issueIds,  AuditFieldsDto? audit,  int rowVersion,  List<StockRequestLineDto> lines)  $default,) {final _that = this;
switch (_that) {
case _StockRequestDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.fromLocation,_that.toLocation,_that.status,_that.requiredDate,_that.note,_that.lineCount,_that.issueIds,_that.audit,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  LocationRefDto fromLocation,  LocationRefDto toLocation,  StockRequestStatus status, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note,  int lineCount,  List<int> issueIds,  AuditFieldsDto? audit,  int rowVersion,  List<StockRequestLineDto> lines)?  $default,) {final _that = this;
switch (_that) {
case _StockRequestDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.fromLocation,_that.toLocation,_that.status,_that.requiredDate,_that.note,_that.lineCount,_that.issueIds,_that.audit,_that.rowVersion,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockRequestDto implements StockRequestDto {
  const _StockRequestDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.fromLocation, required this.toLocation, required this.status, @NullableDateOnlyConverter() this.requiredDate, this.note, this.lineCount = 0,  List<int> issueIds = const <int>[], this.audit, this.rowVersion = 1,  List<StockRequestLineDto> lines = const <StockRequestLineDto>[]}): _issueIds = issueIds,_lines = lines;
  factory _StockRequestDto.fromJson(Map<String, dynamic> json) => _$StockRequestDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override@DateOnlyConverter() final  DateTime docDate;
@override final  LocationRefDto fromLocation;
@override final  LocationRefDto toLocation;
@override final  StockRequestStatus status;
@override@NullableDateOnlyConverter() final  DateTime? requiredDate;
@override final  String? note;
@override@JsonKey() final  int lineCount;
 final  List<int> _issueIds;
@override@JsonKey() List<int> get issueIds {
  if (_issueIds is EqualUnmodifiableListView) return _issueIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_issueIds);
}

@override final  AuditFieldsDto? audit;
@override@JsonKey() final  int rowVersion;
 final  List<StockRequestLineDto> _lines;
@override@JsonKey() List<StockRequestLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of StockRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockRequestDtoCopyWith<_StockRequestDto> get copyWith => __$StockRequestDtoCopyWithImpl<_StockRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockRequestDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.fromLocation, fromLocation) || other.fromLocation == fromLocation)&&(identical(other.toLocation, toLocation) || other.toLocation == toLocation)&&(identical(other.status, status) || other.status == status)&&(identical(other.requiredDate, requiredDate) || other.requiredDate == requiredDate)&&(identical(other.note, note) || other.note == note)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&const DeepCollectionEquality().equals(other.issueIds, _issueIds)&&(identical(other.audit, audit) || other.audit == audit)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,docDate,fromLocation,toLocation,status,requiredDate,note,lineCount,const DeepCollectionEquality().hash(_issueIds),audit,rowVersion,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'StockRequestDto(id: $id, docNo: $docNo, docDate: $docDate, fromLocation: $fromLocation, toLocation: $toLocation, status: $status, requiredDate: $requiredDate, note: $note, lineCount: $lineCount, issueIds: $issueIds, audit: $audit, rowVersion: $rowVersion, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$StockRequestDtoCopyWith<$Res> implements $StockRequestDtoCopyWith<$Res> {
  factory _$StockRequestDtoCopyWith(_StockRequestDto value, $Res Function(_StockRequestDto) _then) = __$StockRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, LocationRefDto fromLocation, LocationRefDto toLocation, StockRequestStatus status,@NullableDateOnlyConverter() DateTime? requiredDate, String? note, int lineCount, List<int> issueIds, AuditFieldsDto? audit, int rowVersion, List<StockRequestLineDto> lines
});


@override $LocationRefDtoCopyWith<$Res> get fromLocation;@override $LocationRefDtoCopyWith<$Res> get toLocation;@override $AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class __$StockRequestDtoCopyWithImpl<$Res>
    implements _$StockRequestDtoCopyWith<$Res> {
  __$StockRequestDtoCopyWithImpl(this._self, this._then);

  final _StockRequestDto _self;
  final $Res Function(_StockRequestDto) _then;

/// Create a copy of StockRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? fromLocation = null,Object? toLocation = null,Object? status = null,Object? requiredDate = freezed,Object? note = freezed,Object? lineCount = null,Object? issueIds = null,Object? audit = freezed,Object? rowVersion = null,Object? lines = null,}) {
  return _then(_StockRequestDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,fromLocation: null == fromLocation ? _self.fromLocation : fromLocation // ignore: cast_nullable_to_non_nullable
as LocationRefDto,toLocation: null == toLocation ? _self.toLocation : toLocation // ignore: cast_nullable_to_non_nullable
as LocationRefDto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StockRequestStatus,requiredDate: freezed == requiredDate ? _self.requiredDate : requiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,issueIds: null == issueIds ? _self._issueIds : issueIds // ignore: cast_nullable_to_non_nullable
as List<int>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<StockRequestLineDto>,
  ));
}

/// Create a copy of StockRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get fromLocation {
  
  return $LocationRefDtoCopyWith<$Res>(_self.fromLocation, (value) {
    return _then(_self.copyWith(fromLocation: value));
  });
}/// Create a copy of StockRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get toLocation {
  
  return $LocationRefDtoCopyWith<$Res>(_self.toLocation, (value) {
    return _then(_self.copyWith(toLocation: value));
  });
}/// Create a copy of StockRequestDto
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
mixin _$CreateStockRequestLine {

 int get productId; Quantity get qty; int get uomId; String? get note;
/// Create a copy of CreateStockRequestLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateStockRequestLineCopyWith<CreateStockRequestLine> get copyWith => _$CreateStockRequestLineCopyWithImpl<CreateStockRequestLine>(this as CreateStockRequestLine, _$identity);

  /// Serializes this CreateStockRequestLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateStockRequestLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateStockRequestLine&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateStockRequestLine;
  return Object.hash(runtimeType,_this.productId,_this.qty,_this.uomId,_this.note);
}

@override
String toString() {
  final _this = this as CreateStockRequestLine;
  return 'CreateStockRequestLine(productId: ${_this.productId}, qty: ${_this.qty}, uomId: ${_this.uomId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $CreateStockRequestLineCopyWith<$Res>  {
  factory $CreateStockRequestLineCopyWith(CreateStockRequestLine value, $Res Function(CreateStockRequestLine) _then) = _$CreateStockRequestLineCopyWithImpl;
@useResult
$Res call({
 int productId, Quantity qty, int uomId, String? note
});




}
/// @nodoc
class _$CreateStockRequestLineCopyWithImpl<$Res>
    implements $CreateStockRequestLineCopyWith<$Res> {
  _$CreateStockRequestLineCopyWithImpl(this._self, this._then);

  final CreateStockRequestLine _self;
  final $Res Function(CreateStockRequestLine) _then;

/// Create a copy of CreateStockRequestLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? qty = null,Object? uomId = null,Object? note = freezed,}) {
  return _then(CreateStockRequestLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateStockRequestLine].
extension CreateStockRequestLinePatterns on CreateStockRequestLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateStockRequestLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateStockRequestLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateStockRequestLine value)  $default,){
final _that = this;
switch (_that) {
case _CreateStockRequestLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateStockRequestLine value)?  $default,){
final _that = this;
switch (_that) {
case _CreateStockRequestLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  Quantity qty,  int uomId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateStockRequestLine() when $default != null:
return $default(_that.productId,_that.qty,_that.uomId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  Quantity qty,  int uomId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreateStockRequestLine():
return $default(_that.productId,_that.qty,_that.uomId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  Quantity qty,  int uomId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreateStockRequestLine() when $default != null:
return $default(_that.productId,_that.qty,_that.uomId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateStockRequestLine implements CreateStockRequestLine {
  const _CreateStockRequestLine({required this.productId, required this.qty, required this.uomId, this.note});
  factory _CreateStockRequestLine.fromJson(Map<String, dynamic> json) => _$CreateStockRequestLineFromJson(json);

@override final  int productId;
@override final  Quantity qty;
@override final  int uomId;
@override final  String? note;

/// Create a copy of CreateStockRequestLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateStockRequestLineCopyWith<_CreateStockRequestLine> get copyWith => __$CreateStockRequestLineCopyWithImpl<_CreateStockRequestLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateStockRequestLineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateStockRequestLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,qty,uomId,note);
}

@override
String toString() {
    return 'CreateStockRequestLine(productId: $productId, qty: $qty, uomId: $uomId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateStockRequestLineCopyWith<$Res> implements $CreateStockRequestLineCopyWith<$Res> {
  factory _$CreateStockRequestLineCopyWith(_CreateStockRequestLine value, $Res Function(_CreateStockRequestLine) _then) = __$CreateStockRequestLineCopyWithImpl;
@override @useResult
$Res call({
 int productId, Quantity qty, int uomId, String? note
});




}
/// @nodoc
class __$CreateStockRequestLineCopyWithImpl<$Res>
    implements _$CreateStockRequestLineCopyWith<$Res> {
  __$CreateStockRequestLineCopyWithImpl(this._self, this._then);

  final _CreateStockRequestLine _self;
  final $Res Function(_CreateStockRequestLine) _then;

/// Create a copy of CreateStockRequestLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? qty = null,Object? uomId = null,Object? note = freezed,}) {
  return _then(_CreateStockRequestLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateStockRequestRequest {

@DateOnlyConverter() DateTime get docDate; int get fromLocationId; int get toLocationId; List<CreateStockRequestLine> get lines;@NullableDateOnlyConverter() DateTime? get requiredDate; String? get note;
/// Create a copy of CreateStockRequestRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateStockRequestRequestCopyWith<CreateStockRequestRequest> get copyWith => _$CreateStockRequestRequestCopyWithImpl<CreateStockRequestRequest>(this as CreateStockRequestRequest, _$identity);

  /// Serializes this CreateStockRequestRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateStockRequestRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateStockRequestRequest&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.fromLocationId, _this.fromLocationId) || other.fromLocationId == _this.fromLocationId)&&(identical(other.toLocationId, _this.toLocationId) || other.toLocationId == _this.toLocationId)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.requiredDate, _this.requiredDate) || other.requiredDate == _this.requiredDate)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateStockRequestRequest;
  return Object.hash(runtimeType,_this.docDate,_this.fromLocationId,_this.toLocationId,const DeepCollectionEquality().hash(_this.lines),_this.requiredDate,_this.note);
}

@override
String toString() {
  final _this = this as CreateStockRequestRequest;
  return 'CreateStockRequestRequest(docDate: ${_this.docDate}, fromLocationId: ${_this.fromLocationId}, toLocationId: ${_this.toLocationId}, lines: ${_this.lines}, requiredDate: ${_this.requiredDate}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $CreateStockRequestRequestCopyWith<$Res>  {
  factory $CreateStockRequestRequestCopyWith(CreateStockRequestRequest value, $Res Function(CreateStockRequestRequest) _then) = _$CreateStockRequestRequestCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime docDate, int fromLocationId, int toLocationId, List<CreateStockRequestLine> lines,@NullableDateOnlyConverter() DateTime? requiredDate, String? note
});




}
/// @nodoc
class _$CreateStockRequestRequestCopyWithImpl<$Res>
    implements $CreateStockRequestRequestCopyWith<$Res> {
  _$CreateStockRequestRequestCopyWithImpl(this._self, this._then);

  final CreateStockRequestRequest _self;
  final $Res Function(CreateStockRequestRequest) _then;

/// Create a copy of CreateStockRequestRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? docDate = null,Object? fromLocationId = null,Object? toLocationId = null,Object? lines = null,Object? requiredDate = freezed,Object? note = freezed,}) {
  return _then(CreateStockRequestRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,fromLocationId: null == fromLocationId ? _self.fromLocationId : fromLocationId // ignore: cast_nullable_to_non_nullable
as int,toLocationId: null == toLocationId ? _self.toLocationId : toLocationId // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateStockRequestLine>,requiredDate: freezed == requiredDate ? _self.requiredDate : requiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateStockRequestRequest].
extension CreateStockRequestRequestPatterns on CreateStockRequestRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateStockRequestRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateStockRequestRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateStockRequestRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateStockRequestRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateStockRequestRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateStockRequestRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  int fromLocationId,  int toLocationId,  List<CreateStockRequestLine> lines, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateStockRequestRequest() when $default != null:
return $default(_that.docDate,_that.fromLocationId,_that.toLocationId,_that.lines,_that.requiredDate,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  int fromLocationId,  int toLocationId,  List<CreateStockRequestLine> lines, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreateStockRequestRequest():
return $default(_that.docDate,_that.fromLocationId,_that.toLocationId,_that.lines,_that.requiredDate,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime docDate,  int fromLocationId,  int toLocationId,  List<CreateStockRequestLine> lines, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreateStockRequestRequest() when $default != null:
return $default(_that.docDate,_that.fromLocationId,_that.toLocationId,_that.lines,_that.requiredDate,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateStockRequestRequest implements CreateStockRequestRequest {
  const _CreateStockRequestRequest({@DateOnlyConverter() required this.docDate, required this.fromLocationId, required this.toLocationId, required  List<CreateStockRequestLine> lines, @NullableDateOnlyConverter() this.requiredDate, this.note}): _lines = lines;
  factory _CreateStockRequestRequest.fromJson(Map<String, dynamic> json) => _$CreateStockRequestRequestFromJson(json);

@override@DateOnlyConverter() final  DateTime docDate;
@override final  int fromLocationId;
@override final  int toLocationId;
 final  List<CreateStockRequestLine> _lines;
@override List<CreateStockRequestLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override@NullableDateOnlyConverter() final  DateTime? requiredDate;
@override final  String? note;

/// Create a copy of CreateStockRequestRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateStockRequestRequestCopyWith<_CreateStockRequestRequest> get copyWith => __$CreateStockRequestRequestCopyWithImpl<_CreateStockRequestRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateStockRequestRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateStockRequestRequest&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.fromLocationId, fromLocationId) || other.fromLocationId == fromLocationId)&&(identical(other.toLocationId, toLocationId) || other.toLocationId == toLocationId)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.requiredDate, requiredDate) || other.requiredDate == requiredDate)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,docDate,fromLocationId,toLocationId,const DeepCollectionEquality().hash(_lines),requiredDate,note);
}

@override
String toString() {
    return 'CreateStockRequestRequest(docDate: $docDate, fromLocationId: $fromLocationId, toLocationId: $toLocationId, lines: $lines, requiredDate: $requiredDate, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateStockRequestRequestCopyWith<$Res> implements $CreateStockRequestRequestCopyWith<$Res> {
  factory _$CreateStockRequestRequestCopyWith(_CreateStockRequestRequest value, $Res Function(_CreateStockRequestRequest) _then) = __$CreateStockRequestRequestCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime docDate, int fromLocationId, int toLocationId, List<CreateStockRequestLine> lines,@NullableDateOnlyConverter() DateTime? requiredDate, String? note
});




}
/// @nodoc
class __$CreateStockRequestRequestCopyWithImpl<$Res>
    implements _$CreateStockRequestRequestCopyWith<$Res> {
  __$CreateStockRequestRequestCopyWithImpl(this._self, this._then);

  final _CreateStockRequestRequest _self;
  final $Res Function(_CreateStockRequestRequest) _then;

/// Create a copy of CreateStockRequestRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? docDate = null,Object? fromLocationId = null,Object? toLocationId = null,Object? lines = null,Object? requiredDate = freezed,Object? note = freezed,}) {
  return _then(_CreateStockRequestRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,fromLocationId: null == fromLocationId ? _self.fromLocationId : fromLocationId // ignore: cast_nullable_to_non_nullable
as int,toLocationId: null == toLocationId ? _self.toLocationId : toLocationId // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateStockRequestLine>,requiredDate: freezed == requiredDate ? _self.requiredDate : requiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$IssueLineDto {

 int get id; int get lineNo; ProductRefDto get product; Quantity get qty; int get uomId; BatchRefDto? get batch; BatchRefDto? get suggestedBatch; String? get uomCode; Quantity? get receivedQty; Quantity? get discrepancyQty; int? get batchOverrideReasonCodeId; int? get discrepancyReasonCodeId; String? get discrepancyNote;
/// Create a copy of IssueLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueLineDtoCopyWith<IssueLineDto> get copyWith => _$IssueLineDtoCopyWithImpl<IssueLineDto>(this as IssueLineDto, _$identity);

  /// Serializes this IssueLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IssueLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueLineDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.batch, _this.batch) || other.batch == _this.batch)&&(identical(other.suggestedBatch, _this.suggestedBatch) || other.suggestedBatch == _this.suggestedBatch)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.receivedQty, _this.receivedQty) || other.receivedQty == _this.receivedQty)&&(identical(other.discrepancyQty, _this.discrepancyQty) || other.discrepancyQty == _this.discrepancyQty)&&(identical(other.batchOverrideReasonCodeId, _this.batchOverrideReasonCodeId) || other.batchOverrideReasonCodeId == _this.batchOverrideReasonCodeId)&&(identical(other.discrepancyReasonCodeId, _this.discrepancyReasonCodeId) || other.discrepancyReasonCodeId == _this.discrepancyReasonCodeId)&&(identical(other.discrepancyNote, _this.discrepancyNote) || other.discrepancyNote == _this.discrepancyNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IssueLineDto;
  return Object.hash(runtimeType,_this.id,_this.lineNo,_this.product,_this.qty,_this.uomId,_this.batch,_this.suggestedBatch,_this.uomCode,_this.receivedQty,_this.discrepancyQty,_this.batchOverrideReasonCodeId,_this.discrepancyReasonCodeId,_this.discrepancyNote);
}

@override
String toString() {
  final _this = this as IssueLineDto;
  return 'IssueLineDto(id: ${_this.id}, lineNo: ${_this.lineNo}, product: ${_this.product}, qty: ${_this.qty}, uomId: ${_this.uomId}, batch: ${_this.batch}, suggestedBatch: ${_this.suggestedBatch}, uomCode: ${_this.uomCode}, receivedQty: ${_this.receivedQty}, discrepancyQty: ${_this.discrepancyQty}, batchOverrideReasonCodeId: ${_this.batchOverrideReasonCodeId}, discrepancyReasonCodeId: ${_this.discrepancyReasonCodeId}, discrepancyNote: ${_this.discrepancyNote})';
}


}

/// @nodoc
abstract mixin class $IssueLineDtoCopyWith<$Res>  {
  factory $IssueLineDtoCopyWith(IssueLineDto value, $Res Function(IssueLineDto) _then) = _$IssueLineDtoCopyWithImpl;
@useResult
$Res call({
 int id, int lineNo, ProductRefDto product, Quantity qty, int uomId, BatchRefDto? batch, BatchRefDto? suggestedBatch, String? uomCode, Quantity? receivedQty, Quantity? discrepancyQty, int? batchOverrideReasonCodeId, int? discrepancyReasonCodeId, String? discrepancyNote
});


$ProductRefDtoCopyWith<$Res> get product;$BatchRefDtoCopyWith<$Res>? get batch;$BatchRefDtoCopyWith<$Res>? get suggestedBatch;

}
/// @nodoc
class _$IssueLineDtoCopyWithImpl<$Res>
    implements $IssueLineDtoCopyWith<$Res> {
  _$IssueLineDtoCopyWithImpl(this._self, this._then);

  final IssueLineDto _self;
  final $Res Function(IssueLineDto) _then;

/// Create a copy of IssueLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? batch = freezed,Object? suggestedBatch = freezed,Object? uomCode = freezed,Object? receivedQty = freezed,Object? discrepancyQty = freezed,Object? batchOverrideReasonCodeId = freezed,Object? discrepancyReasonCodeId = freezed,Object? discrepancyNote = freezed,}) {
  return _then(IssueLineDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as BatchRefDto?,suggestedBatch: freezed == suggestedBatch ? _self.suggestedBatch : suggestedBatch // ignore: cast_nullable_to_non_nullable
as BatchRefDto?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,receivedQty: freezed == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,discrepancyQty: freezed == discrepancyQty ? _self.discrepancyQty : discrepancyQty // ignore: cast_nullable_to_non_nullable
as Quantity?,batchOverrideReasonCodeId: freezed == batchOverrideReasonCodeId ? _self.batchOverrideReasonCodeId : batchOverrideReasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,discrepancyReasonCodeId: freezed == discrepancyReasonCodeId ? _self.discrepancyReasonCodeId : discrepancyReasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,discrepancyNote: freezed == discrepancyNote ? _self.discrepancyNote : discrepancyNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of IssueLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of IssueLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<$Res>? get batch {
    if (_self.batch == null) {
    return null;
  }

  return $BatchRefDtoCopyWith<$Res>(_self.batch!, (value) {
    return _then(_self.copyWith(batch: value));
  });
}/// Create a copy of IssueLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<$Res>? get suggestedBatch {
    if (_self.suggestedBatch == null) {
    return null;
  }

  return $BatchRefDtoCopyWith<$Res>(_self.suggestedBatch!, (value) {
    return _then(_self.copyWith(suggestedBatch: value));
  });
}
}


/// Adds pattern-matching-related methods to [IssueLineDto].
extension IssueLineDtoPatterns on IssueLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueLineDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  BatchRefDto? batch,  BatchRefDto? suggestedBatch,  String? uomCode,  Quantity? receivedQty,  Quantity? discrepancyQty,  int? batchOverrideReasonCodeId,  int? discrepancyReasonCodeId,  String? discrepancyNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueLineDto() when $default != null:
return $default(_that.id,_that.lineNo,_that.product,_that.qty,_that.uomId,_that.batch,_that.suggestedBatch,_that.uomCode,_that.receivedQty,_that.discrepancyQty,_that.batchOverrideReasonCodeId,_that.discrepancyReasonCodeId,_that.discrepancyNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  BatchRefDto? batch,  BatchRefDto? suggestedBatch,  String? uomCode,  Quantity? receivedQty,  Quantity? discrepancyQty,  int? batchOverrideReasonCodeId,  int? discrepancyReasonCodeId,  String? discrepancyNote)  $default,) {final _that = this;
switch (_that) {
case _IssueLineDto():
return $default(_that.id,_that.lineNo,_that.product,_that.qty,_that.uomId,_that.batch,_that.suggestedBatch,_that.uomCode,_that.receivedQty,_that.discrepancyQty,_that.batchOverrideReasonCodeId,_that.discrepancyReasonCodeId,_that.discrepancyNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  BatchRefDto? batch,  BatchRefDto? suggestedBatch,  String? uomCode,  Quantity? receivedQty,  Quantity? discrepancyQty,  int? batchOverrideReasonCodeId,  int? discrepancyReasonCodeId,  String? discrepancyNote)?  $default,) {final _that = this;
switch (_that) {
case _IssueLineDto() when $default != null:
return $default(_that.id,_that.lineNo,_that.product,_that.qty,_that.uomId,_that.batch,_that.suggestedBatch,_that.uomCode,_that.receivedQty,_that.discrepancyQty,_that.batchOverrideReasonCodeId,_that.discrepancyReasonCodeId,_that.discrepancyNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueLineDto extends IssueLineDto {
  const _IssueLineDto({required this.id, required this.lineNo, required this.product, required this.qty, required this.uomId, this.batch, this.suggestedBatch, this.uomCode, this.receivedQty, this.discrepancyQty, this.batchOverrideReasonCodeId, this.discrepancyReasonCodeId, this.discrepancyNote}): super._();
  factory _IssueLineDto.fromJson(Map<String, dynamic> json) => _$IssueLineDtoFromJson(json);

@override final  int id;
@override final  int lineNo;
@override final  ProductRefDto product;
@override final  Quantity qty;
@override final  int uomId;
@override final  BatchRefDto? batch;
@override final  BatchRefDto? suggestedBatch;
@override final  String? uomCode;
@override final  Quantity? receivedQty;
@override final  Quantity? discrepancyQty;
@override final  int? batchOverrideReasonCodeId;
@override final  int? discrepancyReasonCodeId;
@override final  String? discrepancyNote;

/// Create a copy of IssueLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueLineDtoCopyWith<_IssueLineDto> get copyWith => __$IssueLineDtoCopyWithImpl<_IssueLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueLineDto&&(identical(other.id, id) || other.id == id)&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.product, product) || other.product == product)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.suggestedBatch, suggestedBatch) || other.suggestedBatch == suggestedBatch)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.receivedQty, receivedQty) || other.receivedQty == receivedQty)&&(identical(other.discrepancyQty, discrepancyQty) || other.discrepancyQty == discrepancyQty)&&(identical(other.batchOverrideReasonCodeId, batchOverrideReasonCodeId) || other.batchOverrideReasonCodeId == batchOverrideReasonCodeId)&&(identical(other.discrepancyReasonCodeId, discrepancyReasonCodeId) || other.discrepancyReasonCodeId == discrepancyReasonCodeId)&&(identical(other.discrepancyNote, discrepancyNote) || other.discrepancyNote == discrepancyNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,lineNo,product,qty,uomId,batch,suggestedBatch,uomCode,receivedQty,discrepancyQty,batchOverrideReasonCodeId,discrepancyReasonCodeId,discrepancyNote);
}

@override
String toString() {
    return 'IssueLineDto(id: $id, lineNo: $lineNo, product: $product, qty: $qty, uomId: $uomId, batch: $batch, suggestedBatch: $suggestedBatch, uomCode: $uomCode, receivedQty: $receivedQty, discrepancyQty: $discrepancyQty, batchOverrideReasonCodeId: $batchOverrideReasonCodeId, discrepancyReasonCodeId: $discrepancyReasonCodeId, discrepancyNote: $discrepancyNote)';
}


}

/// @nodoc
abstract mixin class _$IssueLineDtoCopyWith<$Res> implements $IssueLineDtoCopyWith<$Res> {
  factory _$IssueLineDtoCopyWith(_IssueLineDto value, $Res Function(_IssueLineDto) _then) = __$IssueLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int lineNo, ProductRefDto product, Quantity qty, int uomId, BatchRefDto? batch, BatchRefDto? suggestedBatch, String? uomCode, Quantity? receivedQty, Quantity? discrepancyQty, int? batchOverrideReasonCodeId, int? discrepancyReasonCodeId, String? discrepancyNote
});


@override $ProductRefDtoCopyWith<$Res> get product;@override $BatchRefDtoCopyWith<$Res>? get batch;@override $BatchRefDtoCopyWith<$Res>? get suggestedBatch;

}
/// @nodoc
class __$IssueLineDtoCopyWithImpl<$Res>
    implements _$IssueLineDtoCopyWith<$Res> {
  __$IssueLineDtoCopyWithImpl(this._self, this._then);

  final _IssueLineDto _self;
  final $Res Function(_IssueLineDto) _then;

/// Create a copy of IssueLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? batch = freezed,Object? suggestedBatch = freezed,Object? uomCode = freezed,Object? receivedQty = freezed,Object? discrepancyQty = freezed,Object? batchOverrideReasonCodeId = freezed,Object? discrepancyReasonCodeId = freezed,Object? discrepancyNote = freezed,}) {
  return _then(_IssueLineDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as BatchRefDto?,suggestedBatch: freezed == suggestedBatch ? _self.suggestedBatch : suggestedBatch // ignore: cast_nullable_to_non_nullable
as BatchRefDto?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,receivedQty: freezed == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,discrepancyQty: freezed == discrepancyQty ? _self.discrepancyQty : discrepancyQty // ignore: cast_nullable_to_non_nullable
as Quantity?,batchOverrideReasonCodeId: freezed == batchOverrideReasonCodeId ? _self.batchOverrideReasonCodeId : batchOverrideReasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,discrepancyReasonCodeId: freezed == discrepancyReasonCodeId ? _self.discrepancyReasonCodeId : discrepancyReasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,discrepancyNote: freezed == discrepancyNote ? _self.discrepancyNote : discrepancyNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of IssueLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of IssueLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<$Res>? get batch {
    if (_self.batch == null) {
    return null;
  }

  return $BatchRefDtoCopyWith<$Res>(_self.batch!, (value) {
    return _then(_self.copyWith(batch: value));
  });
}/// Create a copy of IssueLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<$Res>? get suggestedBatch {
    if (_self.suggestedBatch == null) {
    return null;
  }

  return $BatchRefDtoCopyWith<$Res>(_self.suggestedBatch!, (value) {
    return _then(_self.copyWith(suggestedBatch: value));
  });
}
}


/// @nodoc
mixin _$IssueDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; IssueType get issueType; LocationRefDto get fromLocation; LocationRefDto get toLocation; IssueStatus get status; int? get requestId; String? get requestDocNo; String? get note; int? get dispatchGroupId; int? get receiptGroupId; DateTime? get dispatchedAt; DateTime? get receivedAt; int? get receivedBy; int get lineCount; int get rowVersion; List<IssueLineDto> get lines; AuditFieldsDto? get audit;
/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDtoCopyWith<IssueDto> get copyWith => _$IssueDtoCopyWithImpl<IssueDto>(this as IssueDto, _$identity);

  /// Serializes this IssueDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IssueDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.issueType, _this.issueType) || other.issueType == _this.issueType)&&(identical(other.fromLocation, _this.fromLocation) || other.fromLocation == _this.fromLocation)&&(identical(other.toLocation, _this.toLocation) || other.toLocation == _this.toLocation)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&(identical(other.requestDocNo, _this.requestDocNo) || other.requestDocNo == _this.requestDocNo)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.dispatchGroupId, _this.dispatchGroupId) || other.dispatchGroupId == _this.dispatchGroupId)&&(identical(other.receiptGroupId, _this.receiptGroupId) || other.receiptGroupId == _this.receiptGroupId)&&(identical(other.dispatchedAt, _this.dispatchedAt) || other.dispatchedAt == _this.dispatchedAt)&&(identical(other.receivedAt, _this.receivedAt) || other.receivedAt == _this.receivedAt)&&(identical(other.receivedBy, _this.receivedBy) || other.receivedBy == _this.receivedBy)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.audit, _this.audit) || other.audit == _this.audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IssueDto;
  return Object.hashAll([runtimeType,_this.id,_this.docNo,_this.docDate,_this.issueType,_this.fromLocation,_this.toLocation,_this.status,_this.requestId,_this.requestDocNo,_this.note,_this.dispatchGroupId,_this.receiptGroupId,_this.dispatchedAt,_this.receivedAt,_this.receivedBy,_this.lineCount,_this.rowVersion,const DeepCollectionEquality().hash(_this.lines),_this.audit]);
}

@override
String toString() {
  final _this = this as IssueDto;
  return 'IssueDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, issueType: ${_this.issueType}, fromLocation: ${_this.fromLocation}, toLocation: ${_this.toLocation}, status: ${_this.status}, requestId: ${_this.requestId}, requestDocNo: ${_this.requestDocNo}, note: ${_this.note}, dispatchGroupId: ${_this.dispatchGroupId}, receiptGroupId: ${_this.receiptGroupId}, dispatchedAt: ${_this.dispatchedAt}, receivedAt: ${_this.receivedAt}, receivedBy: ${_this.receivedBy}, lineCount: ${_this.lineCount}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines}, audit: ${_this.audit})';
}


}

/// @nodoc
abstract mixin class $IssueDtoCopyWith<$Res>  {
  factory $IssueDtoCopyWith(IssueDto value, $Res Function(IssueDto) _then) = _$IssueDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, IssueType issueType, LocationRefDto fromLocation, LocationRefDto toLocation, IssueStatus status, int? requestId, String? requestDocNo, String? note, int? dispatchGroupId, int? receiptGroupId, DateTime? dispatchedAt, DateTime? receivedAt, int? receivedBy, int lineCount, int rowVersion, List<IssueLineDto> lines, AuditFieldsDto? audit
});


$LocationRefDtoCopyWith<$Res> get fromLocation;$LocationRefDtoCopyWith<$Res> get toLocation;$AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class _$IssueDtoCopyWithImpl<$Res>
    implements $IssueDtoCopyWith<$Res> {
  _$IssueDtoCopyWithImpl(this._self, this._then);

  final IssueDto _self;
  final $Res Function(IssueDto) _then;

/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? issueType = null,Object? fromLocation = null,Object? toLocation = null,Object? status = null,Object? requestId = freezed,Object? requestDocNo = freezed,Object? note = freezed,Object? dispatchGroupId = freezed,Object? receiptGroupId = freezed,Object? dispatchedAt = freezed,Object? receivedAt = freezed,Object? receivedBy = freezed,Object? lineCount = null,Object? rowVersion = null,Object? lines = null,Object? audit = freezed,}) {
  return _then(IssueDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,issueType: null == issueType ? _self.issueType : issueType // ignore: cast_nullable_to_non_nullable
as IssueType,fromLocation: null == fromLocation ? _self.fromLocation : fromLocation // ignore: cast_nullable_to_non_nullable
as LocationRefDto,toLocation: null == toLocation ? _self.toLocation : toLocation // ignore: cast_nullable_to_non_nullable
as LocationRefDto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IssueStatus,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int?,requestDocNo: freezed == requestDocNo ? _self.requestDocNo : requestDocNo // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,dispatchGroupId: freezed == dispatchGroupId ? _self.dispatchGroupId : dispatchGroupId // ignore: cast_nullable_to_non_nullable
as int?,receiptGroupId: freezed == receiptGroupId ? _self.receiptGroupId : receiptGroupId // ignore: cast_nullable_to_non_nullable
as int?,dispatchedAt: freezed == dispatchedAt ? _self.dispatchedAt : dispatchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receivedAt: freezed == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receivedBy: freezed == receivedBy ? _self.receivedBy : receivedBy // ignore: cast_nullable_to_non_nullable
as int?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<IssueLineDto>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}
/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get fromLocation {
  
  return $LocationRefDtoCopyWith<$Res>(_self.fromLocation, (value) {
    return _then(_self.copyWith(fromLocation: value));
  });
}/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get toLocation {
  
  return $LocationRefDtoCopyWith<$Res>(_self.toLocation, (value) {
    return _then(_self.copyWith(toLocation: value));
  });
}/// Create a copy of IssueDto
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


/// Adds pattern-matching-related methods to [IssueDto].
extension IssueDtoPatterns on IssueDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  IssueType issueType,  LocationRefDto fromLocation,  LocationRefDto toLocation,  IssueStatus status,  int? requestId,  String? requestDocNo,  String? note,  int? dispatchGroupId,  int? receiptGroupId,  DateTime? dispatchedAt,  DateTime? receivedAt,  int? receivedBy,  int lineCount,  int rowVersion,  List<IssueLineDto> lines,  AuditFieldsDto? audit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.issueType,_that.fromLocation,_that.toLocation,_that.status,_that.requestId,_that.requestDocNo,_that.note,_that.dispatchGroupId,_that.receiptGroupId,_that.dispatchedAt,_that.receivedAt,_that.receivedBy,_that.lineCount,_that.rowVersion,_that.lines,_that.audit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  IssueType issueType,  LocationRefDto fromLocation,  LocationRefDto toLocation,  IssueStatus status,  int? requestId,  String? requestDocNo,  String? note,  int? dispatchGroupId,  int? receiptGroupId,  DateTime? dispatchedAt,  DateTime? receivedAt,  int? receivedBy,  int lineCount,  int rowVersion,  List<IssueLineDto> lines,  AuditFieldsDto? audit)  $default,) {final _that = this;
switch (_that) {
case _IssueDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.issueType,_that.fromLocation,_that.toLocation,_that.status,_that.requestId,_that.requestDocNo,_that.note,_that.dispatchGroupId,_that.receiptGroupId,_that.dispatchedAt,_that.receivedAt,_that.receivedBy,_that.lineCount,_that.rowVersion,_that.lines,_that.audit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  IssueType issueType,  LocationRefDto fromLocation,  LocationRefDto toLocation,  IssueStatus status,  int? requestId,  String? requestDocNo,  String? note,  int? dispatchGroupId,  int? receiptGroupId,  DateTime? dispatchedAt,  DateTime? receivedAt,  int? receivedBy,  int lineCount,  int rowVersion,  List<IssueLineDto> lines,  AuditFieldsDto? audit)?  $default,) {final _that = this;
switch (_that) {
case _IssueDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.issueType,_that.fromLocation,_that.toLocation,_that.status,_that.requestId,_that.requestDocNo,_that.note,_that.dispatchGroupId,_that.receiptGroupId,_that.dispatchedAt,_that.receivedAt,_that.receivedBy,_that.lineCount,_that.rowVersion,_that.lines,_that.audit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueDto implements IssueDto {
  const _IssueDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.issueType, required this.fromLocation, required this.toLocation, required this.status, this.requestId, this.requestDocNo, this.note, this.dispatchGroupId, this.receiptGroupId, this.dispatchedAt, this.receivedAt, this.receivedBy, this.lineCount = 0, this.rowVersion = 1,  List<IssueLineDto> lines = const <IssueLineDto>[], this.audit}): _lines = lines;
  factory _IssueDto.fromJson(Map<String, dynamic> json) => _$IssueDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override@DateOnlyConverter() final  DateTime docDate;
@override final  IssueType issueType;
@override final  LocationRefDto fromLocation;
@override final  LocationRefDto toLocation;
@override final  IssueStatus status;
@override final  int? requestId;
@override final  String? requestDocNo;
@override final  String? note;
@override final  int? dispatchGroupId;
@override final  int? receiptGroupId;
@override final  DateTime? dispatchedAt;
@override final  DateTime? receivedAt;
@override final  int? receivedBy;
@override@JsonKey() final  int lineCount;
@override@JsonKey() final  int rowVersion;
 final  List<IssueLineDto> _lines;
@override@JsonKey() List<IssueLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  AuditFieldsDto? audit;

/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDtoCopyWith<_IssueDto> get copyWith => __$IssueDtoCopyWithImpl<_IssueDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.issueType, issueType) || other.issueType == issueType)&&(identical(other.fromLocation, fromLocation) || other.fromLocation == fromLocation)&&(identical(other.toLocation, toLocation) || other.toLocation == toLocation)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.requestDocNo, requestDocNo) || other.requestDocNo == requestDocNo)&&(identical(other.note, note) || other.note == note)&&(identical(other.dispatchGroupId, dispatchGroupId) || other.dispatchGroupId == dispatchGroupId)&&(identical(other.receiptGroupId, receiptGroupId) || other.receiptGroupId == receiptGroupId)&&(identical(other.dispatchedAt, dispatchedAt) || other.dispatchedAt == dispatchedAt)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.receivedBy, receivedBy) || other.receivedBy == receivedBy)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.audit, audit) || other.audit == audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,docNo,docDate,issueType,fromLocation,toLocation,status,requestId,requestDocNo,note,dispatchGroupId,receiptGroupId,dispatchedAt,receivedAt,receivedBy,lineCount,rowVersion,const DeepCollectionEquality().hash(_lines),audit]);
}

@override
String toString() {
    return 'IssueDto(id: $id, docNo: $docNo, docDate: $docDate, issueType: $issueType, fromLocation: $fromLocation, toLocation: $toLocation, status: $status, requestId: $requestId, requestDocNo: $requestDocNo, note: $note, dispatchGroupId: $dispatchGroupId, receiptGroupId: $receiptGroupId, dispatchedAt: $dispatchedAt, receivedAt: $receivedAt, receivedBy: $receivedBy, lineCount: $lineCount, rowVersion: $rowVersion, lines: $lines, audit: $audit)';
}


}

/// @nodoc
abstract mixin class _$IssueDtoCopyWith<$Res> implements $IssueDtoCopyWith<$Res> {
  factory _$IssueDtoCopyWith(_IssueDto value, $Res Function(_IssueDto) _then) = __$IssueDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, IssueType issueType, LocationRefDto fromLocation, LocationRefDto toLocation, IssueStatus status, int? requestId, String? requestDocNo, String? note, int? dispatchGroupId, int? receiptGroupId, DateTime? dispatchedAt, DateTime? receivedAt, int? receivedBy, int lineCount, int rowVersion, List<IssueLineDto> lines, AuditFieldsDto? audit
});


@override $LocationRefDtoCopyWith<$Res> get fromLocation;@override $LocationRefDtoCopyWith<$Res> get toLocation;@override $AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class __$IssueDtoCopyWithImpl<$Res>
    implements _$IssueDtoCopyWith<$Res> {
  __$IssueDtoCopyWithImpl(this._self, this._then);

  final _IssueDto _self;
  final $Res Function(_IssueDto) _then;

/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? issueType = null,Object? fromLocation = null,Object? toLocation = null,Object? status = null,Object? requestId = freezed,Object? requestDocNo = freezed,Object? note = freezed,Object? dispatchGroupId = freezed,Object? receiptGroupId = freezed,Object? dispatchedAt = freezed,Object? receivedAt = freezed,Object? receivedBy = freezed,Object? lineCount = null,Object? rowVersion = null,Object? lines = null,Object? audit = freezed,}) {
  return _then(_IssueDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,issueType: null == issueType ? _self.issueType : issueType // ignore: cast_nullable_to_non_nullable
as IssueType,fromLocation: null == fromLocation ? _self.fromLocation : fromLocation // ignore: cast_nullable_to_non_nullable
as LocationRefDto,toLocation: null == toLocation ? _self.toLocation : toLocation // ignore: cast_nullable_to_non_nullable
as LocationRefDto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IssueStatus,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int?,requestDocNo: freezed == requestDocNo ? _self.requestDocNo : requestDocNo // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,dispatchGroupId: freezed == dispatchGroupId ? _self.dispatchGroupId : dispatchGroupId // ignore: cast_nullable_to_non_nullable
as int?,receiptGroupId: freezed == receiptGroupId ? _self.receiptGroupId : receiptGroupId // ignore: cast_nullable_to_non_nullable
as int?,dispatchedAt: freezed == dispatchedAt ? _self.dispatchedAt : dispatchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receivedAt: freezed == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receivedBy: freezed == receivedBy ? _self.receivedBy : receivedBy // ignore: cast_nullable_to_non_nullable
as int?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<IssueLineDto>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}

/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get fromLocation {
  
  return $LocationRefDtoCopyWith<$Res>(_self.fromLocation, (value) {
    return _then(_self.copyWith(fromLocation: value));
  });
}/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get toLocation {
  
  return $LocationRefDtoCopyWith<$Res>(_self.toLocation, (value) {
    return _then(_self.copyWith(toLocation: value));
  });
}/// Create a copy of IssueDto
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
mixin _$QuantityInput {

 Quantity get value; int get uomId;
/// Create a copy of QuantityInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuantityInputCopyWith<QuantityInput> get copyWith => _$QuantityInputCopyWithImpl<QuantityInput>(this as QuantityInput, _$identity);

  /// Serializes this QuantityInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QuantityInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuantityInput&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QuantityInput;
  return Object.hash(runtimeType,_this.value,_this.uomId);
}

@override
String toString() {
  final _this = this as QuantityInput;
  return 'QuantityInput(value: ${_this.value}, uomId: ${_this.uomId})';
}


}

/// @nodoc
abstract mixin class $QuantityInputCopyWith<$Res>  {
  factory $QuantityInputCopyWith(QuantityInput value, $Res Function(QuantityInput) _then) = _$QuantityInputCopyWithImpl;
@useResult
$Res call({
 Quantity value, int uomId
});




}
/// @nodoc
class _$QuantityInputCopyWithImpl<$Res>
    implements $QuantityInputCopyWith<$Res> {
  _$QuantityInputCopyWithImpl(this._self, this._then);

  final QuantityInput _self;
  final $Res Function(QuantityInput) _then;

/// Create a copy of QuantityInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? uomId = null,}) {
  return _then(QuantityInput(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [QuantityInput].
extension QuantityInputPatterns on QuantityInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuantityInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuantityInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuantityInput value)  $default,){
final _that = this;
switch (_that) {
case _QuantityInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuantityInput value)?  $default,){
final _that = this;
switch (_that) {
case _QuantityInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Quantity value,  int uomId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuantityInput() when $default != null:
return $default(_that.value,_that.uomId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Quantity value,  int uomId)  $default,) {final _that = this;
switch (_that) {
case _QuantityInput():
return $default(_that.value,_that.uomId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Quantity value,  int uomId)?  $default,) {final _that = this;
switch (_that) {
case _QuantityInput() when $default != null:
return $default(_that.value,_that.uomId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuantityInput implements QuantityInput {
  const _QuantityInput({required this.value, required this.uomId});
  factory _QuantityInput.fromJson(Map<String, dynamic> json) => _$QuantityInputFromJson(json);

@override final  Quantity value;
@override final  int uomId;

/// Create a copy of QuantityInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuantityInputCopyWith<_QuantityInput> get copyWith => __$QuantityInputCopyWithImpl<_QuantityInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuantityInputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuantityInput&&(identical(other.value, value) || other.value == value)&&(identical(other.uomId, uomId) || other.uomId == uomId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,value,uomId);
}

@override
String toString() {
    return 'QuantityInput(value: $value, uomId: $uomId)';
}


}

/// @nodoc
abstract mixin class _$QuantityInputCopyWith<$Res> implements $QuantityInputCopyWith<$Res> {
  factory _$QuantityInputCopyWith(_QuantityInput value, $Res Function(_QuantityInput) _then) = __$QuantityInputCopyWithImpl;
@override @useResult
$Res call({
 Quantity value, int uomId
});




}
/// @nodoc
class __$QuantityInputCopyWithImpl<$Res>
    implements _$QuantityInputCopyWith<$Res> {
  __$QuantityInputCopyWithImpl(this._self, this._then);

  final _QuantityInput _self;
  final $Res Function(_QuantityInput) _then;

/// Create a copy of QuantityInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? uomId = null,}) {
  return _then(_QuantityInput(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CreateIssueLine {

 int get productId; Quantity get qty; int get uomId; int? get requestLineId; int? get batchId; int? get batchOverrideReasonCodeId; String? get batchOverrideNote;
/// Create a copy of CreateIssueLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateIssueLineCopyWith<CreateIssueLine> get copyWith => _$CreateIssueLineCopyWithImpl<CreateIssueLine>(this as CreateIssueLine, _$identity);

  /// Serializes this CreateIssueLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateIssueLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateIssueLine&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.requestLineId, _this.requestLineId) || other.requestLineId == _this.requestLineId)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId)&&(identical(other.batchOverrideReasonCodeId, _this.batchOverrideReasonCodeId) || other.batchOverrideReasonCodeId == _this.batchOverrideReasonCodeId)&&(identical(other.batchOverrideNote, _this.batchOverrideNote) || other.batchOverrideNote == _this.batchOverrideNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateIssueLine;
  return Object.hash(runtimeType,_this.productId,_this.qty,_this.uomId,_this.requestLineId,_this.batchId,_this.batchOverrideReasonCodeId,_this.batchOverrideNote);
}

@override
String toString() {
  final _this = this as CreateIssueLine;
  return 'CreateIssueLine(productId: ${_this.productId}, qty: ${_this.qty}, uomId: ${_this.uomId}, requestLineId: ${_this.requestLineId}, batchId: ${_this.batchId}, batchOverrideReasonCodeId: ${_this.batchOverrideReasonCodeId}, batchOverrideNote: ${_this.batchOverrideNote})';
}


}

/// @nodoc
abstract mixin class $CreateIssueLineCopyWith<$Res>  {
  factory $CreateIssueLineCopyWith(CreateIssueLine value, $Res Function(CreateIssueLine) _then) = _$CreateIssueLineCopyWithImpl;
@useResult
$Res call({
 int productId, Quantity qty, int uomId, int? requestLineId, int? batchId, int? batchOverrideReasonCodeId, String? batchOverrideNote
});




}
/// @nodoc
class _$CreateIssueLineCopyWithImpl<$Res>
    implements $CreateIssueLineCopyWith<$Res> {
  _$CreateIssueLineCopyWithImpl(this._self, this._then);

  final CreateIssueLine _self;
  final $Res Function(CreateIssueLine) _then;

/// Create a copy of CreateIssueLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? qty = null,Object? uomId = null,Object? requestLineId = freezed,Object? batchId = freezed,Object? batchOverrideReasonCodeId = freezed,Object? batchOverrideNote = freezed,}) {
  return _then(CreateIssueLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,requestLineId: freezed == requestLineId ? _self.requestLineId : requestLineId // ignore: cast_nullable_to_non_nullable
as int?,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,batchOverrideReasonCodeId: freezed == batchOverrideReasonCodeId ? _self.batchOverrideReasonCodeId : batchOverrideReasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,batchOverrideNote: freezed == batchOverrideNote ? _self.batchOverrideNote : batchOverrideNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateIssueLine].
extension CreateIssueLinePatterns on CreateIssueLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateIssueLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateIssueLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateIssueLine value)  $default,){
final _that = this;
switch (_that) {
case _CreateIssueLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateIssueLine value)?  $default,){
final _that = this;
switch (_that) {
case _CreateIssueLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  Quantity qty,  int uomId,  int? requestLineId,  int? batchId,  int? batchOverrideReasonCodeId,  String? batchOverrideNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateIssueLine() when $default != null:
return $default(_that.productId,_that.qty,_that.uomId,_that.requestLineId,_that.batchId,_that.batchOverrideReasonCodeId,_that.batchOverrideNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  Quantity qty,  int uomId,  int? requestLineId,  int? batchId,  int? batchOverrideReasonCodeId,  String? batchOverrideNote)  $default,) {final _that = this;
switch (_that) {
case _CreateIssueLine():
return $default(_that.productId,_that.qty,_that.uomId,_that.requestLineId,_that.batchId,_that.batchOverrideReasonCodeId,_that.batchOverrideNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  Quantity qty,  int uomId,  int? requestLineId,  int? batchId,  int? batchOverrideReasonCodeId,  String? batchOverrideNote)?  $default,) {final _that = this;
switch (_that) {
case _CreateIssueLine() when $default != null:
return $default(_that.productId,_that.qty,_that.uomId,_that.requestLineId,_that.batchId,_that.batchOverrideReasonCodeId,_that.batchOverrideNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateIssueLine implements CreateIssueLine {
  const _CreateIssueLine({required this.productId, required this.qty, required this.uomId, this.requestLineId, this.batchId, this.batchOverrideReasonCodeId, this.batchOverrideNote});
  factory _CreateIssueLine.fromJson(Map<String, dynamic> json) => _$CreateIssueLineFromJson(json);

@override final  int productId;
@override final  Quantity qty;
@override final  int uomId;
@override final  int? requestLineId;
@override final  int? batchId;
@override final  int? batchOverrideReasonCodeId;
@override final  String? batchOverrideNote;

/// Create a copy of CreateIssueLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateIssueLineCopyWith<_CreateIssueLine> get copyWith => __$CreateIssueLineCopyWithImpl<_CreateIssueLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateIssueLineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateIssueLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.requestLineId, requestLineId) || other.requestLineId == requestLineId)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.batchOverrideReasonCodeId, batchOverrideReasonCodeId) || other.batchOverrideReasonCodeId == batchOverrideReasonCodeId)&&(identical(other.batchOverrideNote, batchOverrideNote) || other.batchOverrideNote == batchOverrideNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,qty,uomId,requestLineId,batchId,batchOverrideReasonCodeId,batchOverrideNote);
}

@override
String toString() {
    return 'CreateIssueLine(productId: $productId, qty: $qty, uomId: $uomId, requestLineId: $requestLineId, batchId: $batchId, batchOverrideReasonCodeId: $batchOverrideReasonCodeId, batchOverrideNote: $batchOverrideNote)';
}


}

/// @nodoc
abstract mixin class _$CreateIssueLineCopyWith<$Res> implements $CreateIssueLineCopyWith<$Res> {
  factory _$CreateIssueLineCopyWith(_CreateIssueLine value, $Res Function(_CreateIssueLine) _then) = __$CreateIssueLineCopyWithImpl;
@override @useResult
$Res call({
 int productId, Quantity qty, int uomId, int? requestLineId, int? batchId, int? batchOverrideReasonCodeId, String? batchOverrideNote
});




}
/// @nodoc
class __$CreateIssueLineCopyWithImpl<$Res>
    implements _$CreateIssueLineCopyWith<$Res> {
  __$CreateIssueLineCopyWithImpl(this._self, this._then);

  final _CreateIssueLine _self;
  final $Res Function(_CreateIssueLine) _then;

/// Create a copy of CreateIssueLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? qty = null,Object? uomId = null,Object? requestLineId = freezed,Object? batchId = freezed,Object? batchOverrideReasonCodeId = freezed,Object? batchOverrideNote = freezed,}) {
  return _then(_CreateIssueLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,requestLineId: freezed == requestLineId ? _self.requestLineId : requestLineId // ignore: cast_nullable_to_non_nullable
as int?,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,batchOverrideReasonCodeId: freezed == batchOverrideReasonCodeId ? _self.batchOverrideReasonCodeId : batchOverrideReasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,batchOverrideNote: freezed == batchOverrideNote ? _self.batchOverrideNote : batchOverrideNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateIssueRequest {

@DateOnlyConverter() DateTime get docDate; IssueType get issueType; int get fromLocationId; int get toLocationId; List<CreateIssueLine> get lines; int? get requestId; String? get note;
/// Create a copy of CreateIssueRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateIssueRequestCopyWith<CreateIssueRequest> get copyWith => _$CreateIssueRequestCopyWithImpl<CreateIssueRequest>(this as CreateIssueRequest, _$identity);

  /// Serializes this CreateIssueRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateIssueRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateIssueRequest&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.issueType, _this.issueType) || other.issueType == _this.issueType)&&(identical(other.fromLocationId, _this.fromLocationId) || other.fromLocationId == _this.fromLocationId)&&(identical(other.toLocationId, _this.toLocationId) || other.toLocationId == _this.toLocationId)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateIssueRequest;
  return Object.hash(runtimeType,_this.docDate,_this.issueType,_this.fromLocationId,_this.toLocationId,const DeepCollectionEquality().hash(_this.lines),_this.requestId,_this.note);
}

@override
String toString() {
  final _this = this as CreateIssueRequest;
  return 'CreateIssueRequest(docDate: ${_this.docDate}, issueType: ${_this.issueType}, fromLocationId: ${_this.fromLocationId}, toLocationId: ${_this.toLocationId}, lines: ${_this.lines}, requestId: ${_this.requestId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $CreateIssueRequestCopyWith<$Res>  {
  factory $CreateIssueRequestCopyWith(CreateIssueRequest value, $Res Function(CreateIssueRequest) _then) = _$CreateIssueRequestCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime docDate, IssueType issueType, int fromLocationId, int toLocationId, List<CreateIssueLine> lines, int? requestId, String? note
});




}
/// @nodoc
class _$CreateIssueRequestCopyWithImpl<$Res>
    implements $CreateIssueRequestCopyWith<$Res> {
  _$CreateIssueRequestCopyWithImpl(this._self, this._then);

  final CreateIssueRequest _self;
  final $Res Function(CreateIssueRequest) _then;

/// Create a copy of CreateIssueRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? docDate = null,Object? issueType = null,Object? fromLocationId = null,Object? toLocationId = null,Object? lines = null,Object? requestId = freezed,Object? note = freezed,}) {
  return _then(CreateIssueRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,issueType: null == issueType ? _self.issueType : issueType // ignore: cast_nullable_to_non_nullable
as IssueType,fromLocationId: null == fromLocationId ? _self.fromLocationId : fromLocationId // ignore: cast_nullable_to_non_nullable
as int,toLocationId: null == toLocationId ? _self.toLocationId : toLocationId // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateIssueLine>,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateIssueRequest].
extension CreateIssueRequestPatterns on CreateIssueRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateIssueRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateIssueRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateIssueRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateIssueRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateIssueRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateIssueRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  IssueType issueType,  int fromLocationId,  int toLocationId,  List<CreateIssueLine> lines,  int? requestId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateIssueRequest() when $default != null:
return $default(_that.docDate,_that.issueType,_that.fromLocationId,_that.toLocationId,_that.lines,_that.requestId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  IssueType issueType,  int fromLocationId,  int toLocationId,  List<CreateIssueLine> lines,  int? requestId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreateIssueRequest():
return $default(_that.docDate,_that.issueType,_that.fromLocationId,_that.toLocationId,_that.lines,_that.requestId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime docDate,  IssueType issueType,  int fromLocationId,  int toLocationId,  List<CreateIssueLine> lines,  int? requestId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreateIssueRequest() when $default != null:
return $default(_that.docDate,_that.issueType,_that.fromLocationId,_that.toLocationId,_that.lines,_that.requestId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateIssueRequest implements CreateIssueRequest {
  const _CreateIssueRequest({@DateOnlyConverter() required this.docDate, required this.issueType, required this.fromLocationId, required this.toLocationId, required  List<CreateIssueLine> lines, this.requestId, this.note}): _lines = lines;
  factory _CreateIssueRequest.fromJson(Map<String, dynamic> json) => _$CreateIssueRequestFromJson(json);

@override@DateOnlyConverter() final  DateTime docDate;
@override final  IssueType issueType;
@override final  int fromLocationId;
@override final  int toLocationId;
 final  List<CreateIssueLine> _lines;
@override List<CreateIssueLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  int? requestId;
@override final  String? note;

/// Create a copy of CreateIssueRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateIssueRequestCopyWith<_CreateIssueRequest> get copyWith => __$CreateIssueRequestCopyWithImpl<_CreateIssueRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateIssueRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateIssueRequest&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.issueType, issueType) || other.issueType == issueType)&&(identical(other.fromLocationId, fromLocationId) || other.fromLocationId == fromLocationId)&&(identical(other.toLocationId, toLocationId) || other.toLocationId == toLocationId)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,docDate,issueType,fromLocationId,toLocationId,const DeepCollectionEquality().hash(_lines),requestId,note);
}

@override
String toString() {
    return 'CreateIssueRequest(docDate: $docDate, issueType: $issueType, fromLocationId: $fromLocationId, toLocationId: $toLocationId, lines: $lines, requestId: $requestId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateIssueRequestCopyWith<$Res> implements $CreateIssueRequestCopyWith<$Res> {
  factory _$CreateIssueRequestCopyWith(_CreateIssueRequest value, $Res Function(_CreateIssueRequest) _then) = __$CreateIssueRequestCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime docDate, IssueType issueType, int fromLocationId, int toLocationId, List<CreateIssueLine> lines, int? requestId, String? note
});




}
/// @nodoc
class __$CreateIssueRequestCopyWithImpl<$Res>
    implements _$CreateIssueRequestCopyWith<$Res> {
  __$CreateIssueRequestCopyWithImpl(this._self, this._then);

  final _CreateIssueRequest _self;
  final $Res Function(_CreateIssueRequest) _then;

/// Create a copy of CreateIssueRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? docDate = null,Object? issueType = null,Object? fromLocationId = null,Object? toLocationId = null,Object? lines = null,Object? requestId = freezed,Object? note = freezed,}) {
  return _then(_CreateIssueRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,issueType: null == issueType ? _self.issueType : issueType // ignore: cast_nullable_to_non_nullable
as IssueType,fromLocationId: null == fromLocationId ? _self.fromLocationId : fromLocationId // ignore: cast_nullable_to_non_nullable
as int,toLocationId: null == toLocationId ? _self.toLocationId : toLocationId // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateIssueLine>,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ConfirmIssueLine {

 int get lineId; Quantity get receivedQty; int? get reasonCodeId; String? get note;
/// Create a copy of ConfirmIssueLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmIssueLineCopyWith<ConfirmIssueLine> get copyWith => _$ConfirmIssueLineCopyWithImpl<ConfirmIssueLine>(this as ConfirmIssueLine, _$identity);

  /// Serializes this ConfirmIssueLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConfirmIssueLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmIssueLine&&(identical(other.lineId, _this.lineId) || other.lineId == _this.lineId)&&(identical(other.receivedQty, _this.receivedQty) || other.receivedQty == _this.receivedQty)&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConfirmIssueLine;
  return Object.hash(runtimeType,_this.lineId,_this.receivedQty,_this.reasonCodeId,_this.note);
}

@override
String toString() {
  final _this = this as ConfirmIssueLine;
  return 'ConfirmIssueLine(lineId: ${_this.lineId}, receivedQty: ${_this.receivedQty}, reasonCodeId: ${_this.reasonCodeId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $ConfirmIssueLineCopyWith<$Res>  {
  factory $ConfirmIssueLineCopyWith(ConfirmIssueLine value, $Res Function(ConfirmIssueLine) _then) = _$ConfirmIssueLineCopyWithImpl;
@useResult
$Res call({
 int lineId, Quantity receivedQty, int? reasonCodeId, String? note
});




}
/// @nodoc
class _$ConfirmIssueLineCopyWithImpl<$Res>
    implements $ConfirmIssueLineCopyWith<$Res> {
  _$ConfirmIssueLineCopyWithImpl(this._self, this._then);

  final ConfirmIssueLine _self;
  final $Res Function(ConfirmIssueLine) _then;

/// Create a copy of ConfirmIssueLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineId = null,Object? receivedQty = null,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(ConfirmIssueLine(
lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as int,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfirmIssueLine].
extension ConfirmIssueLinePatterns on ConfirmIssueLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmIssueLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmIssueLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmIssueLine value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmIssueLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmIssueLine value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmIssueLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineId,  Quantity receivedQty,  int? reasonCodeId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmIssueLine() when $default != null:
return $default(_that.lineId,_that.receivedQty,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineId,  Quantity receivedQty,  int? reasonCodeId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _ConfirmIssueLine():
return $default(_that.lineId,_that.receivedQty,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineId,  Quantity receivedQty,  int? reasonCodeId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmIssueLine() when $default != null:
return $default(_that.lineId,_that.receivedQty,_that.reasonCodeId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfirmIssueLine implements ConfirmIssueLine {
  const _ConfirmIssueLine({required this.lineId, required this.receivedQty, this.reasonCodeId, this.note});
  factory _ConfirmIssueLine.fromJson(Map<String, dynamic> json) => _$ConfirmIssueLineFromJson(json);

@override final  int lineId;
@override final  Quantity receivedQty;
@override final  int? reasonCodeId;
@override final  String? note;

/// Create a copy of ConfirmIssueLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmIssueLineCopyWith<_ConfirmIssueLine> get copyWith => __$ConfirmIssueLineCopyWithImpl<_ConfirmIssueLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmIssueLineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmIssueLine&&(identical(other.lineId, lineId) || other.lineId == lineId)&&(identical(other.receivedQty, receivedQty) || other.receivedQty == receivedQty)&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineId,receivedQty,reasonCodeId,note);
}

@override
String toString() {
    return 'ConfirmIssueLine(lineId: $lineId, receivedQty: $receivedQty, reasonCodeId: $reasonCodeId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ConfirmIssueLineCopyWith<$Res> implements $ConfirmIssueLineCopyWith<$Res> {
  factory _$ConfirmIssueLineCopyWith(_ConfirmIssueLine value, $Res Function(_ConfirmIssueLine) _then) = __$ConfirmIssueLineCopyWithImpl;
@override @useResult
$Res call({
 int lineId, Quantity receivedQty, int? reasonCodeId, String? note
});




}
/// @nodoc
class __$ConfirmIssueLineCopyWithImpl<$Res>
    implements _$ConfirmIssueLineCopyWith<$Res> {
  __$ConfirmIssueLineCopyWithImpl(this._self, this._then);

  final _ConfirmIssueLine _self;
  final $Res Function(_ConfirmIssueLine) _then;

/// Create a copy of ConfirmIssueLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineId = null,Object? receivedQty = null,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(_ConfirmIssueLine(
lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as int,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ConfirmIssueRequest {

 List<ConfirmIssueLine> get lines; int get rowVersion; List<int> get attachmentIds;
/// Create a copy of ConfirmIssueRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmIssueRequestCopyWith<ConfirmIssueRequest> get copyWith => _$ConfirmIssueRequestCopyWithImpl<ConfirmIssueRequest>(this as ConfirmIssueRequest, _$identity);

  /// Serializes this ConfirmIssueRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConfirmIssueRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmIssueRequest&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.attachmentIds, _this.attachmentIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConfirmIssueRequest;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.lines),_this.rowVersion,const DeepCollectionEquality().hash(_this.attachmentIds));
}

@override
String toString() {
  final _this = this as ConfirmIssueRequest;
  return 'ConfirmIssueRequest(lines: ${_this.lines}, rowVersion: ${_this.rowVersion}, attachmentIds: ${_this.attachmentIds})';
}


}

/// @nodoc
abstract mixin class $ConfirmIssueRequestCopyWith<$Res>  {
  factory $ConfirmIssueRequestCopyWith(ConfirmIssueRequest value, $Res Function(ConfirmIssueRequest) _then) = _$ConfirmIssueRequestCopyWithImpl;
@useResult
$Res call({
 List<ConfirmIssueLine> lines, int rowVersion, List<int> attachmentIds
});




}
/// @nodoc
class _$ConfirmIssueRequestCopyWithImpl<$Res>
    implements $ConfirmIssueRequestCopyWith<$Res> {
  _$ConfirmIssueRequestCopyWithImpl(this._self, this._then);

  final ConfirmIssueRequest _self;
  final $Res Function(ConfirmIssueRequest) _then;

/// Create a copy of ConfirmIssueRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lines = null,Object? rowVersion = null,Object? attachmentIds = null,}) {
  return _then(ConfirmIssueRequest(
lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<ConfirmIssueLine>,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,attachmentIds: null == attachmentIds ? _self.attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfirmIssueRequest].
extension ConfirmIssueRequestPatterns on ConfirmIssueRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmIssueRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmIssueRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmIssueRequest value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmIssueRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmIssueRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmIssueRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ConfirmIssueLine> lines,  int rowVersion,  List<int> attachmentIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmIssueRequest() when $default != null:
return $default(_that.lines,_that.rowVersion,_that.attachmentIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ConfirmIssueLine> lines,  int rowVersion,  List<int> attachmentIds)  $default,) {final _that = this;
switch (_that) {
case _ConfirmIssueRequest():
return $default(_that.lines,_that.rowVersion,_that.attachmentIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ConfirmIssueLine> lines,  int rowVersion,  List<int> attachmentIds)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmIssueRequest() when $default != null:
return $default(_that.lines,_that.rowVersion,_that.attachmentIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfirmIssueRequest implements ConfirmIssueRequest {
  const _ConfirmIssueRequest({required  List<ConfirmIssueLine> lines, required this.rowVersion,  List<int> attachmentIds = const <int>[]}): _lines = lines,_attachmentIds = attachmentIds;
  factory _ConfirmIssueRequest.fromJson(Map<String, dynamic> json) => _$ConfirmIssueRequestFromJson(json);

 final  List<ConfirmIssueLine> _lines;
@override List<ConfirmIssueLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  int rowVersion;
 final  List<int> _attachmentIds;
@override@JsonKey() List<int> get attachmentIds {
  if (_attachmentIds is EqualUnmodifiableListView) return _attachmentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachmentIds);
}


/// Create a copy of ConfirmIssueRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmIssueRequestCopyWith<_ConfirmIssueRequest> get copyWith => __$ConfirmIssueRequestCopyWithImpl<_ConfirmIssueRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmIssueRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmIssueRequest&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.attachmentIds, _attachmentIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_lines),rowVersion,const DeepCollectionEquality().hash(_attachmentIds));
}

@override
String toString() {
    return 'ConfirmIssueRequest(lines: $lines, rowVersion: $rowVersion, attachmentIds: $attachmentIds)';
}


}

/// @nodoc
abstract mixin class _$ConfirmIssueRequestCopyWith<$Res> implements $ConfirmIssueRequestCopyWith<$Res> {
  factory _$ConfirmIssueRequestCopyWith(_ConfirmIssueRequest value, $Res Function(_ConfirmIssueRequest) _then) = __$ConfirmIssueRequestCopyWithImpl;
@override @useResult
$Res call({
 List<ConfirmIssueLine> lines, int rowVersion, List<int> attachmentIds
});




}
/// @nodoc
class __$ConfirmIssueRequestCopyWithImpl<$Res>
    implements _$ConfirmIssueRequestCopyWith<$Res> {
  __$ConfirmIssueRequestCopyWithImpl(this._self, this._then);

  final _ConfirmIssueRequest _self;
  final $Res Function(_ConfirmIssueRequest) _then;

/// Create a copy of ConfirmIssueRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lines = null,Object? rowVersion = null,Object? attachmentIds = null,}) {
  return _then(_ConfirmIssueRequest(
lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<ConfirmIssueLine>,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,attachmentIds: null == attachmentIds ? _self._attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$CountLineDto {

 int get id; ProductRefDto get product; Quantity get bookQty; String? get baseUomCode; BatchRefDto? get batch; Quantity? get countedQty; Quantity? get varianceQty; Decimal? get variancePct; Money? get varianceValue; bool get exceedsThreshold; DateTime? get countedAt; int? get countedBy; int? get reasonCodeId; String? get note;
/// Create a copy of CountLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountLineDtoCopyWith<CountLineDto> get copyWith => _$CountLineDtoCopyWithImpl<CountLineDto>(this as CountLineDto, _$identity);

  /// Serializes this CountLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CountLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountLineDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.bookQty, _this.bookQty) || other.bookQty == _this.bookQty)&&(identical(other.baseUomCode, _this.baseUomCode) || other.baseUomCode == _this.baseUomCode)&&(identical(other.batch, _this.batch) || other.batch == _this.batch)&&(identical(other.countedQty, _this.countedQty) || other.countedQty == _this.countedQty)&&(identical(other.varianceQty, _this.varianceQty) || other.varianceQty == _this.varianceQty)&&(identical(other.variancePct, _this.variancePct) || other.variancePct == _this.variancePct)&&(identical(other.varianceValue, _this.varianceValue) || other.varianceValue == _this.varianceValue)&&(identical(other.exceedsThreshold, _this.exceedsThreshold) || other.exceedsThreshold == _this.exceedsThreshold)&&(identical(other.countedAt, _this.countedAt) || other.countedAt == _this.countedAt)&&(identical(other.countedBy, _this.countedBy) || other.countedBy == _this.countedBy)&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CountLineDto;
  return Object.hash(runtimeType,_this.id,_this.product,_this.bookQty,_this.baseUomCode,_this.batch,_this.countedQty,_this.varianceQty,_this.variancePct,_this.varianceValue,_this.exceedsThreshold,_this.countedAt,_this.countedBy,_this.reasonCodeId,_this.note);
}

@override
String toString() {
  final _this = this as CountLineDto;
  return 'CountLineDto(id: ${_this.id}, product: ${_this.product}, bookQty: ${_this.bookQty}, baseUomCode: ${_this.baseUomCode}, batch: ${_this.batch}, countedQty: ${_this.countedQty}, varianceQty: ${_this.varianceQty}, variancePct: ${_this.variancePct}, varianceValue: ${_this.varianceValue}, exceedsThreshold: ${_this.exceedsThreshold}, countedAt: ${_this.countedAt}, countedBy: ${_this.countedBy}, reasonCodeId: ${_this.reasonCodeId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $CountLineDtoCopyWith<$Res>  {
  factory $CountLineDtoCopyWith(CountLineDto value, $Res Function(CountLineDto) _then) = _$CountLineDtoCopyWithImpl;
@useResult
$Res call({
 int id, ProductRefDto product, Quantity bookQty, String? baseUomCode, BatchRefDto? batch, Quantity? countedQty, Quantity? varianceQty, Decimal? variancePct, Money? varianceValue, bool exceedsThreshold, DateTime? countedAt, int? countedBy, int? reasonCodeId, String? note
});


$ProductRefDtoCopyWith<$Res> get product;$BatchRefDtoCopyWith<$Res>? get batch;

}
/// @nodoc
class _$CountLineDtoCopyWithImpl<$Res>
    implements $CountLineDtoCopyWith<$Res> {
  _$CountLineDtoCopyWithImpl(this._self, this._then);

  final CountLineDto _self;
  final $Res Function(CountLineDto) _then;

/// Create a copy of CountLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? product = null,Object? bookQty = null,Object? baseUomCode = freezed,Object? batch = freezed,Object? countedQty = freezed,Object? varianceQty = freezed,Object? variancePct = freezed,Object? varianceValue = freezed,Object? exceedsThreshold = null,Object? countedAt = freezed,Object? countedBy = freezed,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(CountLineDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,bookQty: null == bookQty ? _self.bookQty : bookQty // ignore: cast_nullable_to_non_nullable
as Quantity,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as BatchRefDto?,countedQty: freezed == countedQty ? _self.countedQty : countedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,varianceQty: freezed == varianceQty ? _self.varianceQty : varianceQty // ignore: cast_nullable_to_non_nullable
as Quantity?,variancePct: freezed == variancePct ? _self.variancePct : variancePct // ignore: cast_nullable_to_non_nullable
as Decimal?,varianceValue: freezed == varianceValue ? _self.varianceValue : varianceValue // ignore: cast_nullable_to_non_nullable
as Money?,exceedsThreshold: null == exceedsThreshold ? _self.exceedsThreshold : exceedsThreshold // ignore: cast_nullable_to_non_nullable
as bool,countedAt: freezed == countedAt ? _self.countedAt : countedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,countedBy: freezed == countedBy ? _self.countedBy : countedBy // ignore: cast_nullable_to_non_nullable
as int?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CountLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of CountLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<$Res>? get batch {
    if (_self.batch == null) {
    return null;
  }

  return $BatchRefDtoCopyWith<$Res>(_self.batch!, (value) {
    return _then(_self.copyWith(batch: value));
  });
}
}


/// Adds pattern-matching-related methods to [CountLineDto].
extension CountLineDtoPatterns on CountLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountLineDto value)  $default,){
final _that = this;
switch (_that) {
case _CountLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _CountLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  ProductRefDto product,  Quantity bookQty,  String? baseUomCode,  BatchRefDto? batch,  Quantity? countedQty,  Quantity? varianceQty,  Decimal? variancePct,  Money? varianceValue,  bool exceedsThreshold,  DateTime? countedAt,  int? countedBy,  int? reasonCodeId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountLineDto() when $default != null:
return $default(_that.id,_that.product,_that.bookQty,_that.baseUomCode,_that.batch,_that.countedQty,_that.varianceQty,_that.variancePct,_that.varianceValue,_that.exceedsThreshold,_that.countedAt,_that.countedBy,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  ProductRefDto product,  Quantity bookQty,  String? baseUomCode,  BatchRefDto? batch,  Quantity? countedQty,  Quantity? varianceQty,  Decimal? variancePct,  Money? varianceValue,  bool exceedsThreshold,  DateTime? countedAt,  int? countedBy,  int? reasonCodeId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CountLineDto():
return $default(_that.id,_that.product,_that.bookQty,_that.baseUomCode,_that.batch,_that.countedQty,_that.varianceQty,_that.variancePct,_that.varianceValue,_that.exceedsThreshold,_that.countedAt,_that.countedBy,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  ProductRefDto product,  Quantity bookQty,  String? baseUomCode,  BatchRefDto? batch,  Quantity? countedQty,  Quantity? varianceQty,  Decimal? variancePct,  Money? varianceValue,  bool exceedsThreshold,  DateTime? countedAt,  int? countedBy,  int? reasonCodeId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CountLineDto() when $default != null:
return $default(_that.id,_that.product,_that.bookQty,_that.baseUomCode,_that.batch,_that.countedQty,_that.varianceQty,_that.variancePct,_that.varianceValue,_that.exceedsThreshold,_that.countedAt,_that.countedBy,_that.reasonCodeId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CountLineDto extends CountLineDto {
  const _CountLineDto({required this.id, required this.product, required this.bookQty, this.baseUomCode, this.batch, this.countedQty, this.varianceQty, this.variancePct, this.varianceValue, this.exceedsThreshold = false, this.countedAt, this.countedBy, this.reasonCodeId, this.note}): super._();
  factory _CountLineDto.fromJson(Map<String, dynamic> json) => _$CountLineDtoFromJson(json);

@override final  int id;
@override final  ProductRefDto product;
@override final  Quantity bookQty;
@override final  String? baseUomCode;
@override final  BatchRefDto? batch;
@override final  Quantity? countedQty;
@override final  Quantity? varianceQty;
@override final  Decimal? variancePct;
@override final  Money? varianceValue;
@override@JsonKey() final  bool exceedsThreshold;
@override final  DateTime? countedAt;
@override final  int? countedBy;
@override final  int? reasonCodeId;
@override final  String? note;

/// Create a copy of CountLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountLineDtoCopyWith<_CountLineDto> get copyWith => __$CountLineDtoCopyWithImpl<_CountLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CountLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountLineDto&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.bookQty, bookQty) || other.bookQty == bookQty)&&(identical(other.baseUomCode, baseUomCode) || other.baseUomCode == baseUomCode)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.countedQty, countedQty) || other.countedQty == countedQty)&&(identical(other.varianceQty, varianceQty) || other.varianceQty == varianceQty)&&(identical(other.variancePct, variancePct) || other.variancePct == variancePct)&&(identical(other.varianceValue, varianceValue) || other.varianceValue == varianceValue)&&(identical(other.exceedsThreshold, exceedsThreshold) || other.exceedsThreshold == exceedsThreshold)&&(identical(other.countedAt, countedAt) || other.countedAt == countedAt)&&(identical(other.countedBy, countedBy) || other.countedBy == countedBy)&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,product,bookQty,baseUomCode,batch,countedQty,varianceQty,variancePct,varianceValue,exceedsThreshold,countedAt,countedBy,reasonCodeId,note);
}

@override
String toString() {
    return 'CountLineDto(id: $id, product: $product, bookQty: $bookQty, baseUomCode: $baseUomCode, batch: $batch, countedQty: $countedQty, varianceQty: $varianceQty, variancePct: $variancePct, varianceValue: $varianceValue, exceedsThreshold: $exceedsThreshold, countedAt: $countedAt, countedBy: $countedBy, reasonCodeId: $reasonCodeId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CountLineDtoCopyWith<$Res> implements $CountLineDtoCopyWith<$Res> {
  factory _$CountLineDtoCopyWith(_CountLineDto value, $Res Function(_CountLineDto) _then) = __$CountLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, ProductRefDto product, Quantity bookQty, String? baseUomCode, BatchRefDto? batch, Quantity? countedQty, Quantity? varianceQty, Decimal? variancePct, Money? varianceValue, bool exceedsThreshold, DateTime? countedAt, int? countedBy, int? reasonCodeId, String? note
});


@override $ProductRefDtoCopyWith<$Res> get product;@override $BatchRefDtoCopyWith<$Res>? get batch;

}
/// @nodoc
class __$CountLineDtoCopyWithImpl<$Res>
    implements _$CountLineDtoCopyWith<$Res> {
  __$CountLineDtoCopyWithImpl(this._self, this._then);

  final _CountLineDto _self;
  final $Res Function(_CountLineDto) _then;

/// Create a copy of CountLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? product = null,Object? bookQty = null,Object? baseUomCode = freezed,Object? batch = freezed,Object? countedQty = freezed,Object? varianceQty = freezed,Object? variancePct = freezed,Object? varianceValue = freezed,Object? exceedsThreshold = null,Object? countedAt = freezed,Object? countedBy = freezed,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(_CountLineDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,bookQty: null == bookQty ? _self.bookQty : bookQty // ignore: cast_nullable_to_non_nullable
as Quantity,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as BatchRefDto?,countedQty: freezed == countedQty ? _self.countedQty : countedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,varianceQty: freezed == varianceQty ? _self.varianceQty : varianceQty // ignore: cast_nullable_to_non_nullable
as Quantity?,variancePct: freezed == variancePct ? _self.variancePct : variancePct // ignore: cast_nullable_to_non_nullable
as Decimal?,varianceValue: freezed == varianceValue ? _self.varianceValue : varianceValue // ignore: cast_nullable_to_non_nullable
as Money?,exceedsThreshold: null == exceedsThreshold ? _self.exceedsThreshold : exceedsThreshold // ignore: cast_nullable_to_non_nullable
as bool,countedAt: freezed == countedAt ? _self.countedAt : countedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,countedBy: freezed == countedBy ? _self.countedBy : countedBy // ignore: cast_nullable_to_non_nullable
as int?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CountLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of CountLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<$Res>? get batch {
    if (_self.batch == null) {
    return null;
  }

  return $BatchRefDtoCopyWith<$Res>(_self.batch!, (value) {
    return _then(_self.copyWith(batch: value));
  });
}
}


/// @nodoc
mixin _$CountDto {

 int get id; String get docNo; LocationRefDto get location; CountType get countType; CountStatus get status; DateTime? get frozenAt; int? get approvedBy; DateTime? get approvedAt; int? get adjustGroupId; bool get requiresApproval; int get lineCount; int get countedLineCount; int get varianceLineCount; Money? get totalVarianceValue; String? get note; int get rowVersion; List<CountLineDto> get lines; AuditFieldsDto? get audit;
/// Create a copy of CountDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountDtoCopyWith<CountDto> get copyWith => _$CountDtoCopyWithImpl<CountDto>(this as CountDto, _$identity);

  /// Serializes this CountDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CountDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.countType, _this.countType) || other.countType == _this.countType)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.frozenAt, _this.frozenAt) || other.frozenAt == _this.frozenAt)&&(identical(other.approvedBy, _this.approvedBy) || other.approvedBy == _this.approvedBy)&&(identical(other.approvedAt, _this.approvedAt) || other.approvedAt == _this.approvedAt)&&(identical(other.adjustGroupId, _this.adjustGroupId) || other.adjustGroupId == _this.adjustGroupId)&&(identical(other.requiresApproval, _this.requiresApproval) || other.requiresApproval == _this.requiresApproval)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&(identical(other.countedLineCount, _this.countedLineCount) || other.countedLineCount == _this.countedLineCount)&&(identical(other.varianceLineCount, _this.varianceLineCount) || other.varianceLineCount == _this.varianceLineCount)&&(identical(other.totalVarianceValue, _this.totalVarianceValue) || other.totalVarianceValue == _this.totalVarianceValue)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.audit, _this.audit) || other.audit == _this.audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CountDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.location,_this.countType,_this.status,_this.frozenAt,_this.approvedBy,_this.approvedAt,_this.adjustGroupId,_this.requiresApproval,_this.lineCount,_this.countedLineCount,_this.varianceLineCount,_this.totalVarianceValue,_this.note,_this.rowVersion,const DeepCollectionEquality().hash(_this.lines),_this.audit);
}

@override
String toString() {
  final _this = this as CountDto;
  return 'CountDto(id: ${_this.id}, docNo: ${_this.docNo}, location: ${_this.location}, countType: ${_this.countType}, status: ${_this.status}, frozenAt: ${_this.frozenAt}, approvedBy: ${_this.approvedBy}, approvedAt: ${_this.approvedAt}, adjustGroupId: ${_this.adjustGroupId}, requiresApproval: ${_this.requiresApproval}, lineCount: ${_this.lineCount}, countedLineCount: ${_this.countedLineCount}, varianceLineCount: ${_this.varianceLineCount}, totalVarianceValue: ${_this.totalVarianceValue}, note: ${_this.note}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines}, audit: ${_this.audit})';
}


}

/// @nodoc
abstract mixin class $CountDtoCopyWith<$Res>  {
  factory $CountDtoCopyWith(CountDto value, $Res Function(CountDto) _then) = _$CountDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo, LocationRefDto location, CountType countType, CountStatus status, DateTime? frozenAt, int? approvedBy, DateTime? approvedAt, int? adjustGroupId, bool requiresApproval, int lineCount, int countedLineCount, int varianceLineCount, Money? totalVarianceValue, String? note, int rowVersion, List<CountLineDto> lines, AuditFieldsDto? audit
});


$LocationRefDtoCopyWith<$Res> get location;$AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class _$CountDtoCopyWithImpl<$Res>
    implements $CountDtoCopyWith<$Res> {
  _$CountDtoCopyWithImpl(this._self, this._then);

  final CountDto _self;
  final $Res Function(CountDto) _then;

/// Create a copy of CountDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? location = null,Object? countType = null,Object? status = null,Object? frozenAt = freezed,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? adjustGroupId = freezed,Object? requiresApproval = null,Object? lineCount = null,Object? countedLineCount = null,Object? varianceLineCount = null,Object? totalVarianceValue = freezed,Object? note = freezed,Object? rowVersion = null,Object? lines = null,Object? audit = freezed,}) {
  return _then(CountDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationRefDto,countType: null == countType ? _self.countType : countType // ignore: cast_nullable_to_non_nullable
as CountType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CountStatus,frozenAt: freezed == frozenAt ? _self.frozenAt : frozenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as int?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,adjustGroupId: freezed == adjustGroupId ? _self.adjustGroupId : adjustGroupId // ignore: cast_nullable_to_non_nullable
as int?,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,countedLineCount: null == countedLineCount ? _self.countedLineCount : countedLineCount // ignore: cast_nullable_to_non_nullable
as int,varianceLineCount: null == varianceLineCount ? _self.varianceLineCount : varianceLineCount // ignore: cast_nullable_to_non_nullable
as int,totalVarianceValue: freezed == totalVarianceValue ? _self.totalVarianceValue : totalVarianceValue // ignore: cast_nullable_to_non_nullable
as Money?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CountLineDto>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}
/// Create a copy of CountDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get location {
  
  return $LocationRefDtoCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of CountDto
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


/// Adds pattern-matching-related methods to [CountDto].
extension CountDtoPatterns on CountDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountDto value)  $default,){
final _that = this;
switch (_that) {
case _CountDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountDto value)?  $default,){
final _that = this;
switch (_that) {
case _CountDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo,  LocationRefDto location,  CountType countType,  CountStatus status,  DateTime? frozenAt,  int? approvedBy,  DateTime? approvedAt,  int? adjustGroupId,  bool requiresApproval,  int lineCount,  int countedLineCount,  int varianceLineCount,  Money? totalVarianceValue,  String? note,  int rowVersion,  List<CountLineDto> lines,  AuditFieldsDto? audit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountDto() when $default != null:
return $default(_that.id,_that.docNo,_that.location,_that.countType,_that.status,_that.frozenAt,_that.approvedBy,_that.approvedAt,_that.adjustGroupId,_that.requiresApproval,_that.lineCount,_that.countedLineCount,_that.varianceLineCount,_that.totalVarianceValue,_that.note,_that.rowVersion,_that.lines,_that.audit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo,  LocationRefDto location,  CountType countType,  CountStatus status,  DateTime? frozenAt,  int? approvedBy,  DateTime? approvedAt,  int? adjustGroupId,  bool requiresApproval,  int lineCount,  int countedLineCount,  int varianceLineCount,  Money? totalVarianceValue,  String? note,  int rowVersion,  List<CountLineDto> lines,  AuditFieldsDto? audit)  $default,) {final _that = this;
switch (_that) {
case _CountDto():
return $default(_that.id,_that.docNo,_that.location,_that.countType,_that.status,_that.frozenAt,_that.approvedBy,_that.approvedAt,_that.adjustGroupId,_that.requiresApproval,_that.lineCount,_that.countedLineCount,_that.varianceLineCount,_that.totalVarianceValue,_that.note,_that.rowVersion,_that.lines,_that.audit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo,  LocationRefDto location,  CountType countType,  CountStatus status,  DateTime? frozenAt,  int? approvedBy,  DateTime? approvedAt,  int? adjustGroupId,  bool requiresApproval,  int lineCount,  int countedLineCount,  int varianceLineCount,  Money? totalVarianceValue,  String? note,  int rowVersion,  List<CountLineDto> lines,  AuditFieldsDto? audit)?  $default,) {final _that = this;
switch (_that) {
case _CountDto() when $default != null:
return $default(_that.id,_that.docNo,_that.location,_that.countType,_that.status,_that.frozenAt,_that.approvedBy,_that.approvedAt,_that.adjustGroupId,_that.requiresApproval,_that.lineCount,_that.countedLineCount,_that.varianceLineCount,_that.totalVarianceValue,_that.note,_that.rowVersion,_that.lines,_that.audit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CountDto implements CountDto {
  const _CountDto({required this.id, required this.docNo, required this.location, required this.countType, required this.status, this.frozenAt, this.approvedBy, this.approvedAt, this.adjustGroupId, this.requiresApproval = false, this.lineCount = 0, this.countedLineCount = 0, this.varianceLineCount = 0, this.totalVarianceValue, this.note, this.rowVersion = 1,  List<CountLineDto> lines = const <CountLineDto>[], this.audit}): _lines = lines;
  factory _CountDto.fromJson(Map<String, dynamic> json) => _$CountDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override final  LocationRefDto location;
@override final  CountType countType;
@override final  CountStatus status;
@override final  DateTime? frozenAt;
@override final  int? approvedBy;
@override final  DateTime? approvedAt;
@override final  int? adjustGroupId;
@override@JsonKey() final  bool requiresApproval;
@override@JsonKey() final  int lineCount;
@override@JsonKey() final  int countedLineCount;
@override@JsonKey() final  int varianceLineCount;
@override final  Money? totalVarianceValue;
@override final  String? note;
@override@JsonKey() final  int rowVersion;
 final  List<CountLineDto> _lines;
@override@JsonKey() List<CountLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  AuditFieldsDto? audit;

/// Create a copy of CountDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountDtoCopyWith<_CountDto> get copyWith => __$CountDtoCopyWithImpl<_CountDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CountDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.location, location) || other.location == location)&&(identical(other.countType, countType) || other.countType == countType)&&(identical(other.status, status) || other.status == status)&&(identical(other.frozenAt, frozenAt) || other.frozenAt == frozenAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.adjustGroupId, adjustGroupId) || other.adjustGroupId == adjustGroupId)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&(identical(other.countedLineCount, countedLineCount) || other.countedLineCount == countedLineCount)&&(identical(other.varianceLineCount, varianceLineCount) || other.varianceLineCount == varianceLineCount)&&(identical(other.totalVarianceValue, totalVarianceValue) || other.totalVarianceValue == totalVarianceValue)&&(identical(other.note, note) || other.note == note)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.audit, audit) || other.audit == audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,location,countType,status,frozenAt,approvedBy,approvedAt,adjustGroupId,requiresApproval,lineCount,countedLineCount,varianceLineCount,totalVarianceValue,note,rowVersion,const DeepCollectionEquality().hash(_lines),audit);
}

@override
String toString() {
    return 'CountDto(id: $id, docNo: $docNo, location: $location, countType: $countType, status: $status, frozenAt: $frozenAt, approvedBy: $approvedBy, approvedAt: $approvedAt, adjustGroupId: $adjustGroupId, requiresApproval: $requiresApproval, lineCount: $lineCount, countedLineCount: $countedLineCount, varianceLineCount: $varianceLineCount, totalVarianceValue: $totalVarianceValue, note: $note, rowVersion: $rowVersion, lines: $lines, audit: $audit)';
}


}

/// @nodoc
abstract mixin class _$CountDtoCopyWith<$Res> implements $CountDtoCopyWith<$Res> {
  factory _$CountDtoCopyWith(_CountDto value, $Res Function(_CountDto) _then) = __$CountDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo, LocationRefDto location, CountType countType, CountStatus status, DateTime? frozenAt, int? approvedBy, DateTime? approvedAt, int? adjustGroupId, bool requiresApproval, int lineCount, int countedLineCount, int varianceLineCount, Money? totalVarianceValue, String? note, int rowVersion, List<CountLineDto> lines, AuditFieldsDto? audit
});


@override $LocationRefDtoCopyWith<$Res> get location;@override $AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class __$CountDtoCopyWithImpl<$Res>
    implements _$CountDtoCopyWith<$Res> {
  __$CountDtoCopyWithImpl(this._self, this._then);

  final _CountDto _self;
  final $Res Function(_CountDto) _then;

/// Create a copy of CountDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? location = null,Object? countType = null,Object? status = null,Object? frozenAt = freezed,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? adjustGroupId = freezed,Object? requiresApproval = null,Object? lineCount = null,Object? countedLineCount = null,Object? varianceLineCount = null,Object? totalVarianceValue = freezed,Object? note = freezed,Object? rowVersion = null,Object? lines = null,Object? audit = freezed,}) {
  return _then(_CountDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationRefDto,countType: null == countType ? _self.countType : countType // ignore: cast_nullable_to_non_nullable
as CountType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CountStatus,frozenAt: freezed == frozenAt ? _self.frozenAt : frozenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as int?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,adjustGroupId: freezed == adjustGroupId ? _self.adjustGroupId : adjustGroupId // ignore: cast_nullable_to_non_nullable
as int?,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,countedLineCount: null == countedLineCount ? _self.countedLineCount : countedLineCount // ignore: cast_nullable_to_non_nullable
as int,varianceLineCount: null == varianceLineCount ? _self.varianceLineCount : varianceLineCount // ignore: cast_nullable_to_non_nullable
as int,totalVarianceValue: freezed == totalVarianceValue ? _self.totalVarianceValue : totalVarianceValue // ignore: cast_nullable_to_non_nullable
as Money?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CountLineDto>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}

/// Create a copy of CountDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get location {
  
  return $LocationRefDtoCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of CountDto
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
mixin _$CreateCountRequest {

 int get locationId; CountType get countType; List<int> get categoryIds; List<int> get productIds; String? get note;
/// Create a copy of CreateCountRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateCountRequestCopyWith<CreateCountRequest> get copyWith => _$CreateCountRequestCopyWithImpl<CreateCountRequest>(this as CreateCountRequest, _$identity);

  /// Serializes this CreateCountRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateCountRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateCountRequest&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.countType, _this.countType) || other.countType == _this.countType)&&const DeepCollectionEquality().equals(other.categoryIds, _this.categoryIds)&&const DeepCollectionEquality().equals(other.productIds, _this.productIds)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateCountRequest;
  return Object.hash(runtimeType,_this.locationId,_this.countType,const DeepCollectionEquality().hash(_this.categoryIds),const DeepCollectionEquality().hash(_this.productIds),_this.note);
}

@override
String toString() {
  final _this = this as CreateCountRequest;
  return 'CreateCountRequest(locationId: ${_this.locationId}, countType: ${_this.countType}, categoryIds: ${_this.categoryIds}, productIds: ${_this.productIds}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $CreateCountRequestCopyWith<$Res>  {
  factory $CreateCountRequestCopyWith(CreateCountRequest value, $Res Function(CreateCountRequest) _then) = _$CreateCountRequestCopyWithImpl;
@useResult
$Res call({
 int locationId, CountType countType, List<int> categoryIds, List<int> productIds, String? note
});




}
/// @nodoc
class _$CreateCountRequestCopyWithImpl<$Res>
    implements $CreateCountRequestCopyWith<$Res> {
  _$CreateCountRequestCopyWithImpl(this._self, this._then);

  final CreateCountRequest _self;
  final $Res Function(CreateCountRequest) _then;

/// Create a copy of CreateCountRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locationId = null,Object? countType = null,Object? categoryIds = null,Object? productIds = null,Object? note = freezed,}) {
  return _then(CreateCountRequest(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,countType: null == countType ? _self.countType : countType // ignore: cast_nullable_to_non_nullable
as CountType,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<int>,productIds: null == productIds ? _self.productIds : productIds // ignore: cast_nullable_to_non_nullable
as List<int>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateCountRequest].
extension CreateCountRequestPatterns on CreateCountRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateCountRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateCountRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateCountRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateCountRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateCountRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateCountRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int locationId,  CountType countType,  List<int> categoryIds,  List<int> productIds,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateCountRequest() when $default != null:
return $default(_that.locationId,_that.countType,_that.categoryIds,_that.productIds,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int locationId,  CountType countType,  List<int> categoryIds,  List<int> productIds,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreateCountRequest():
return $default(_that.locationId,_that.countType,_that.categoryIds,_that.productIds,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int locationId,  CountType countType,  List<int> categoryIds,  List<int> productIds,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreateCountRequest() when $default != null:
return $default(_that.locationId,_that.countType,_that.categoryIds,_that.productIds,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateCountRequest implements CreateCountRequest {
  const _CreateCountRequest({required this.locationId, required this.countType,  List<int> categoryIds = const <int>[],  List<int> productIds = const <int>[], this.note}): _categoryIds = categoryIds,_productIds = productIds;
  factory _CreateCountRequest.fromJson(Map<String, dynamic> json) => _$CreateCountRequestFromJson(json);

@override final  int locationId;
@override final  CountType countType;
 final  List<int> _categoryIds;
@override@JsonKey() List<int> get categoryIds {
  if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryIds);
}

 final  List<int> _productIds;
@override@JsonKey() List<int> get productIds {
  if (_productIds is EqualUnmodifiableListView) return _productIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_productIds);
}

@override final  String? note;

/// Create a copy of CreateCountRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateCountRequestCopyWith<_CreateCountRequest> get copyWith => __$CreateCountRequestCopyWithImpl<_CreateCountRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateCountRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateCountRequest&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.countType, countType) || other.countType == countType)&&const DeepCollectionEquality().equals(other.categoryIds, _categoryIds)&&const DeepCollectionEquality().equals(other.productIds, _productIds)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,locationId,countType,const DeepCollectionEquality().hash(_categoryIds),const DeepCollectionEquality().hash(_productIds),note);
}

@override
String toString() {
    return 'CreateCountRequest(locationId: $locationId, countType: $countType, categoryIds: $categoryIds, productIds: $productIds, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateCountRequestCopyWith<$Res> implements $CreateCountRequestCopyWith<$Res> {
  factory _$CreateCountRequestCopyWith(_CreateCountRequest value, $Res Function(_CreateCountRequest) _then) = __$CreateCountRequestCopyWithImpl;
@override @useResult
$Res call({
 int locationId, CountType countType, List<int> categoryIds, List<int> productIds, String? note
});




}
/// @nodoc
class __$CreateCountRequestCopyWithImpl<$Res>
    implements _$CreateCountRequestCopyWith<$Res> {
  __$CreateCountRequestCopyWithImpl(this._self, this._then);

  final _CreateCountRequest _self;
  final $Res Function(_CreateCountRequest) _then;

/// Create a copy of CreateCountRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locationId = null,Object? countType = null,Object? categoryIds = null,Object? productIds = null,Object? note = freezed,}) {
  return _then(_CreateCountRequest(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,countType: null == countType ? _self.countType : countType // ignore: cast_nullable_to_non_nullable
as CountType,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<int>,productIds: null == productIds ? _self._productIds : productIds // ignore: cast_nullable_to_non_nullable
as List<int>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EnterCountLine {

 int get productId; QuantityInput get countedQuantity; int? get batchId; int? get reasonCodeId; String? get note;
/// Create a copy of EnterCountLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnterCountLineCopyWith<EnterCountLine> get copyWith => _$EnterCountLineCopyWithImpl<EnterCountLine>(this as EnterCountLine, _$identity);

  /// Serializes this EnterCountLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EnterCountLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnterCountLine&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.countedQuantity, _this.countedQuantity) || other.countedQuantity == _this.countedQuantity)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId)&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EnterCountLine;
  return Object.hash(runtimeType,_this.productId,_this.countedQuantity,_this.batchId,_this.reasonCodeId,_this.note);
}

@override
String toString() {
  final _this = this as EnterCountLine;
  return 'EnterCountLine(productId: ${_this.productId}, countedQuantity: ${_this.countedQuantity}, batchId: ${_this.batchId}, reasonCodeId: ${_this.reasonCodeId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $EnterCountLineCopyWith<$Res>  {
  factory $EnterCountLineCopyWith(EnterCountLine value, $Res Function(EnterCountLine) _then) = _$EnterCountLineCopyWithImpl;
@useResult
$Res call({
 int productId, QuantityInput countedQuantity, int? batchId, int? reasonCodeId, String? note
});


$QuantityInputCopyWith<$Res> get countedQuantity;

}
/// @nodoc
class _$EnterCountLineCopyWithImpl<$Res>
    implements $EnterCountLineCopyWith<$Res> {
  _$EnterCountLineCopyWithImpl(this._self, this._then);

  final EnterCountLine _self;
  final $Res Function(EnterCountLine) _then;

/// Create a copy of EnterCountLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? countedQuantity = null,Object? batchId = freezed,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(EnterCountLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,countedQuantity: null == countedQuantity ? _self.countedQuantity : countedQuantity // ignore: cast_nullable_to_non_nullable
as QuantityInput,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of EnterCountLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityInputCopyWith<$Res> get countedQuantity {
  
  return $QuantityInputCopyWith<$Res>(_self.countedQuantity, (value) {
    return _then(_self.copyWith(countedQuantity: value));
  });
}
}


/// Adds pattern-matching-related methods to [EnterCountLine].
extension EnterCountLinePatterns on EnterCountLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnterCountLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnterCountLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnterCountLine value)  $default,){
final _that = this;
switch (_that) {
case _EnterCountLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnterCountLine value)?  $default,){
final _that = this;
switch (_that) {
case _EnterCountLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  QuantityInput countedQuantity,  int? batchId,  int? reasonCodeId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnterCountLine() when $default != null:
return $default(_that.productId,_that.countedQuantity,_that.batchId,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  QuantityInput countedQuantity,  int? batchId,  int? reasonCodeId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _EnterCountLine():
return $default(_that.productId,_that.countedQuantity,_that.batchId,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  QuantityInput countedQuantity,  int? batchId,  int? reasonCodeId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _EnterCountLine() when $default != null:
return $default(_that.productId,_that.countedQuantity,_that.batchId,_that.reasonCodeId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnterCountLine implements EnterCountLine {
  const _EnterCountLine({required this.productId, required this.countedQuantity, this.batchId, this.reasonCodeId, this.note});
  factory _EnterCountLine.fromJson(Map<String, dynamic> json) => _$EnterCountLineFromJson(json);

@override final  int productId;
@override final  QuantityInput countedQuantity;
@override final  int? batchId;
@override final  int? reasonCodeId;
@override final  String? note;

/// Create a copy of EnterCountLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnterCountLineCopyWith<_EnterCountLine> get copyWith => __$EnterCountLineCopyWithImpl<_EnterCountLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnterCountLineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnterCountLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.countedQuantity, countedQuantity) || other.countedQuantity == countedQuantity)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,countedQuantity,batchId,reasonCodeId,note);
}

@override
String toString() {
    return 'EnterCountLine(productId: $productId, countedQuantity: $countedQuantity, batchId: $batchId, reasonCodeId: $reasonCodeId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$EnterCountLineCopyWith<$Res> implements $EnterCountLineCopyWith<$Res> {
  factory _$EnterCountLineCopyWith(_EnterCountLine value, $Res Function(_EnterCountLine) _then) = __$EnterCountLineCopyWithImpl;
@override @useResult
$Res call({
 int productId, QuantityInput countedQuantity, int? batchId, int? reasonCodeId, String? note
});


@override $QuantityInputCopyWith<$Res> get countedQuantity;

}
/// @nodoc
class __$EnterCountLineCopyWithImpl<$Res>
    implements _$EnterCountLineCopyWith<$Res> {
  __$EnterCountLineCopyWithImpl(this._self, this._then);

  final _EnterCountLine _self;
  final $Res Function(_EnterCountLine) _then;

/// Create a copy of EnterCountLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? countedQuantity = null,Object? batchId = freezed,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(_EnterCountLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,countedQuantity: null == countedQuantity ? _self.countedQuantity : countedQuantity // ignore: cast_nullable_to_non_nullable
as QuantityInput,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of EnterCountLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityInputCopyWith<$Res> get countedQuantity {
  
  return $QuantityInputCopyWith<$Res>(_self.countedQuantity, (value) {
    return _then(_self.copyWith(countedQuantity: value));
  });
}
}


/// @nodoc
mixin _$EnterCountRequest {

 List<EnterCountLine> get lines; int get rowVersion;
/// Create a copy of EnterCountRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnterCountRequestCopyWith<EnterCountRequest> get copyWith => _$EnterCountRequestCopyWithImpl<EnterCountRequest>(this as EnterCountRequest, _$identity);

  /// Serializes this EnterCountRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EnterCountRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnterCountRequest&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EnterCountRequest;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.lines),_this.rowVersion);
}

@override
String toString() {
  final _this = this as EnterCountRequest;
  return 'EnterCountRequest(lines: ${_this.lines}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $EnterCountRequestCopyWith<$Res>  {
  factory $EnterCountRequestCopyWith(EnterCountRequest value, $Res Function(EnterCountRequest) _then) = _$EnterCountRequestCopyWithImpl;
@useResult
$Res call({
 List<EnterCountLine> lines, int rowVersion
});




}
/// @nodoc
class _$EnterCountRequestCopyWithImpl<$Res>
    implements $EnterCountRequestCopyWith<$Res> {
  _$EnterCountRequestCopyWithImpl(this._self, this._then);

  final EnterCountRequest _self;
  final $Res Function(EnterCountRequest) _then;

/// Create a copy of EnterCountRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lines = null,Object? rowVersion = null,}) {
  return _then(EnterCountRequest(
lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<EnterCountLine>,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EnterCountRequest].
extension EnterCountRequestPatterns on EnterCountRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnterCountRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnterCountRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnterCountRequest value)  $default,){
final _that = this;
switch (_that) {
case _EnterCountRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnterCountRequest value)?  $default,){
final _that = this;
switch (_that) {
case _EnterCountRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<EnterCountLine> lines,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnterCountRequest() when $default != null:
return $default(_that.lines,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<EnterCountLine> lines,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _EnterCountRequest():
return $default(_that.lines,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<EnterCountLine> lines,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _EnterCountRequest() when $default != null:
return $default(_that.lines,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnterCountRequest implements EnterCountRequest {
  const _EnterCountRequest({required  List<EnterCountLine> lines, required this.rowVersion}): _lines = lines;
  factory _EnterCountRequest.fromJson(Map<String, dynamic> json) => _$EnterCountRequestFromJson(json);

 final  List<EnterCountLine> _lines;
@override List<EnterCountLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  int rowVersion;

/// Create a copy of EnterCountRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnterCountRequestCopyWith<_EnterCountRequest> get copyWith => __$EnterCountRequestCopyWithImpl<_EnterCountRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnterCountRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnterCountRequest&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_lines),rowVersion);
}

@override
String toString() {
    return 'EnterCountRequest(lines: $lines, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$EnterCountRequestCopyWith<$Res> implements $EnterCountRequestCopyWith<$Res> {
  factory _$EnterCountRequestCopyWith(_EnterCountRequest value, $Res Function(_EnterCountRequest) _then) = __$EnterCountRequestCopyWithImpl;
@override @useResult
$Res call({
 List<EnterCountLine> lines, int rowVersion
});




}
/// @nodoc
class __$EnterCountRequestCopyWithImpl<$Res>
    implements _$EnterCountRequestCopyWith<$Res> {
  __$EnterCountRequestCopyWithImpl(this._self, this._then);

  final _EnterCountRequest _self;
  final $Res Function(_EnterCountRequest) _then;

/// Create a copy of EnterCountRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lines = null,Object? rowVersion = null,}) {
  return _then(_EnterCountRequest(
lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<EnterCountLine>,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$WasteLineDto {

 int get lineNo; ProductRefDto get product; Quantity get qty; int get uomId; BatchRefDto? get batch; String? get uomCode; int? get id; Quantity? get qtyBase; String? get note; Money? get unitCost; Money? get totalValue;
/// Create a copy of WasteLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WasteLineDtoCopyWith<WasteLineDto> get copyWith => _$WasteLineDtoCopyWithImpl<WasteLineDto>(this as WasteLineDto, _$identity);

  /// Serializes this WasteLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WasteLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WasteLineDto&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.batch, _this.batch) || other.batch == _this.batch)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.qtyBase, _this.qtyBase) || other.qtyBase == _this.qtyBase)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.unitCost, _this.unitCost) || other.unitCost == _this.unitCost)&&(identical(other.totalValue, _this.totalValue) || other.totalValue == _this.totalValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WasteLineDto;
  return Object.hash(runtimeType,_this.lineNo,_this.product,_this.qty,_this.uomId,_this.batch,_this.uomCode,_this.id,_this.qtyBase,_this.note,_this.unitCost,_this.totalValue);
}

@override
String toString() {
  final _this = this as WasteLineDto;
  return 'WasteLineDto(lineNo: ${_this.lineNo}, product: ${_this.product}, qty: ${_this.qty}, uomId: ${_this.uomId}, batch: ${_this.batch}, uomCode: ${_this.uomCode}, id: ${_this.id}, qtyBase: ${_this.qtyBase}, note: ${_this.note}, unitCost: ${_this.unitCost}, totalValue: ${_this.totalValue})';
}


}

/// @nodoc
abstract mixin class $WasteLineDtoCopyWith<$Res>  {
  factory $WasteLineDtoCopyWith(WasteLineDto value, $Res Function(WasteLineDto) _then) = _$WasteLineDtoCopyWithImpl;
@useResult
$Res call({
 int lineNo, ProductRefDto product, Quantity qty, int uomId, BatchRefDto? batch, String? uomCode, int? id, Quantity? qtyBase, String? note, Money? unitCost, Money? totalValue
});


$ProductRefDtoCopyWith<$Res> get product;$BatchRefDtoCopyWith<$Res>? get batch;

}
/// @nodoc
class _$WasteLineDtoCopyWithImpl<$Res>
    implements $WasteLineDtoCopyWith<$Res> {
  _$WasteLineDtoCopyWithImpl(this._self, this._then);

  final WasteLineDto _self;
  final $Res Function(WasteLineDto) _then;

/// Create a copy of WasteLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? batch = freezed,Object? uomCode = freezed,Object? id = freezed,Object? qtyBase = freezed,Object? note = freezed,Object? unitCost = freezed,Object? totalValue = freezed,}) {
  return _then(WasteLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as BatchRefDto?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,qtyBase: freezed == qtyBase ? _self.qtyBase : qtyBase // ignore: cast_nullable_to_non_nullable
as Quantity?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,unitCost: freezed == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as Money?,totalValue: freezed == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}
/// Create a copy of WasteLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of WasteLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<$Res>? get batch {
    if (_self.batch == null) {
    return null;
  }

  return $BatchRefDtoCopyWith<$Res>(_self.batch!, (value) {
    return _then(_self.copyWith(batch: value));
  });
}
}


/// Adds pattern-matching-related methods to [WasteLineDto].
extension WasteLineDtoPatterns on WasteLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WasteLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WasteLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WasteLineDto value)  $default,){
final _that = this;
switch (_that) {
case _WasteLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WasteLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _WasteLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  BatchRefDto? batch,  String? uomCode,  int? id,  Quantity? qtyBase,  String? note,  Money? unitCost,  Money? totalValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WasteLineDto() when $default != null:
return $default(_that.lineNo,_that.product,_that.qty,_that.uomId,_that.batch,_that.uomCode,_that.id,_that.qtyBase,_that.note,_that.unitCost,_that.totalValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  BatchRefDto? batch,  String? uomCode,  int? id,  Quantity? qtyBase,  String? note,  Money? unitCost,  Money? totalValue)  $default,) {final _that = this;
switch (_that) {
case _WasteLineDto():
return $default(_that.lineNo,_that.product,_that.qty,_that.uomId,_that.batch,_that.uomCode,_that.id,_that.qtyBase,_that.note,_that.unitCost,_that.totalValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  BatchRefDto? batch,  String? uomCode,  int? id,  Quantity? qtyBase,  String? note,  Money? unitCost,  Money? totalValue)?  $default,) {final _that = this;
switch (_that) {
case _WasteLineDto() when $default != null:
return $default(_that.lineNo,_that.product,_that.qty,_that.uomId,_that.batch,_that.uomCode,_that.id,_that.qtyBase,_that.note,_that.unitCost,_that.totalValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WasteLineDto implements WasteLineDto {
  const _WasteLineDto({required this.lineNo, required this.product, required this.qty, required this.uomId, this.batch, this.uomCode, this.id, this.qtyBase, this.note, this.unitCost, this.totalValue});
  factory _WasteLineDto.fromJson(Map<String, dynamic> json) => _$WasteLineDtoFromJson(json);

@override final  int lineNo;
@override final  ProductRefDto product;
@override final  Quantity qty;
@override final  int uomId;
@override final  BatchRefDto? batch;
@override final  String? uomCode;
@override final  int? id;
@override final  Quantity? qtyBase;
@override final  String? note;
@override final  Money? unitCost;
@override final  Money? totalValue;

/// Create a copy of WasteLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WasteLineDtoCopyWith<_WasteLineDto> get copyWith => __$WasteLineDtoCopyWithImpl<_WasteLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WasteLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WasteLineDto&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.product, product) || other.product == product)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.id, id) || other.id == id)&&(identical(other.qtyBase, qtyBase) || other.qtyBase == qtyBase)&&(identical(other.note, note) || other.note == note)&&(identical(other.unitCost, unitCost) || other.unitCost == unitCost)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,product,qty,uomId,batch,uomCode,id,qtyBase,note,unitCost,totalValue);
}

@override
String toString() {
    return 'WasteLineDto(lineNo: $lineNo, product: $product, qty: $qty, uomId: $uomId, batch: $batch, uomCode: $uomCode, id: $id, qtyBase: $qtyBase, note: $note, unitCost: $unitCost, totalValue: $totalValue)';
}


}

/// @nodoc
abstract mixin class _$WasteLineDtoCopyWith<$Res> implements $WasteLineDtoCopyWith<$Res> {
  factory _$WasteLineDtoCopyWith(_WasteLineDto value, $Res Function(_WasteLineDto) _then) = __$WasteLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, ProductRefDto product, Quantity qty, int uomId, BatchRefDto? batch, String? uomCode, int? id, Quantity? qtyBase, String? note, Money? unitCost, Money? totalValue
});


@override $ProductRefDtoCopyWith<$Res> get product;@override $BatchRefDtoCopyWith<$Res>? get batch;

}
/// @nodoc
class __$WasteLineDtoCopyWithImpl<$Res>
    implements _$WasteLineDtoCopyWith<$Res> {
  __$WasteLineDtoCopyWithImpl(this._self, this._then);

  final _WasteLineDto _self;
  final $Res Function(_WasteLineDto) _then;

/// Create a copy of WasteLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? batch = freezed,Object? uomCode = freezed,Object? id = freezed,Object? qtyBase = freezed,Object? note = freezed,Object? unitCost = freezed,Object? totalValue = freezed,}) {
  return _then(_WasteLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as BatchRefDto?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,qtyBase: freezed == qtyBase ? _self.qtyBase : qtyBase // ignore: cast_nullable_to_non_nullable
as Quantity?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,unitCost: freezed == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as Money?,totalValue: freezed == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}

/// Create a copy of WasteLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of WasteLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<$Res>? get batch {
    if (_self.batch == null) {
    return null;
  }

  return $BatchRefDtoCopyWith<$Res>(_self.batch!, (value) {
    return _then(_self.copyWith(batch: value));
  });
}
}


/// @nodoc
mixin _$WasteDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; LocationRefDto get location; int get reasonCodeId; WasteStatus get status; String? get reasonCodeName; String? get note; int? get approvedBy; DateTime? get approvedAt; String? get approvalComment; int? get movementGroupId; int get lineCount; Money? get totalValue; List<int> get attachmentIds; int get rowVersion; List<WasteLineDto> get lines; AuditFieldsDto? get audit;
/// Create a copy of WasteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WasteDtoCopyWith<WasteDto> get copyWith => _$WasteDtoCopyWithImpl<WasteDto>(this as WasteDto, _$identity);

  /// Serializes this WasteDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WasteDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WasteDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.reasonCodeName, _this.reasonCodeName) || other.reasonCodeName == _this.reasonCodeName)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.approvedBy, _this.approvedBy) || other.approvedBy == _this.approvedBy)&&(identical(other.approvedAt, _this.approvedAt) || other.approvedAt == _this.approvedAt)&&(identical(other.approvalComment, _this.approvalComment) || other.approvalComment == _this.approvalComment)&&(identical(other.movementGroupId, _this.movementGroupId) || other.movementGroupId == _this.movementGroupId)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&(identical(other.totalValue, _this.totalValue) || other.totalValue == _this.totalValue)&&const DeepCollectionEquality().equals(other.attachmentIds, _this.attachmentIds)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.audit, _this.audit) || other.audit == _this.audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WasteDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.docDate,_this.location,_this.reasonCodeId,_this.status,_this.reasonCodeName,_this.note,_this.approvedBy,_this.approvedAt,_this.approvalComment,_this.movementGroupId,_this.lineCount,_this.totalValue,const DeepCollectionEquality().hash(_this.attachmentIds),_this.rowVersion,const DeepCollectionEquality().hash(_this.lines),_this.audit);
}

@override
String toString() {
  final _this = this as WasteDto;
  return 'WasteDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, location: ${_this.location}, reasonCodeId: ${_this.reasonCodeId}, status: ${_this.status}, reasonCodeName: ${_this.reasonCodeName}, note: ${_this.note}, approvedBy: ${_this.approvedBy}, approvedAt: ${_this.approvedAt}, approvalComment: ${_this.approvalComment}, movementGroupId: ${_this.movementGroupId}, lineCount: ${_this.lineCount}, totalValue: ${_this.totalValue}, attachmentIds: ${_this.attachmentIds}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines}, audit: ${_this.audit})';
}


}

/// @nodoc
abstract mixin class $WasteDtoCopyWith<$Res>  {
  factory $WasteDtoCopyWith(WasteDto value, $Res Function(WasteDto) _then) = _$WasteDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, LocationRefDto location, int reasonCodeId, WasteStatus status, String? reasonCodeName, String? note, int? approvedBy, DateTime? approvedAt, String? approvalComment, int? movementGroupId, int lineCount, Money? totalValue, List<int> attachmentIds, int rowVersion, List<WasteLineDto> lines, AuditFieldsDto? audit
});


$LocationRefDtoCopyWith<$Res> get location;$AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class _$WasteDtoCopyWithImpl<$Res>
    implements $WasteDtoCopyWith<$Res> {
  _$WasteDtoCopyWithImpl(this._self, this._then);

  final WasteDto _self;
  final $Res Function(WasteDto) _then;

/// Create a copy of WasteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? location = null,Object? reasonCodeId = null,Object? status = null,Object? reasonCodeName = freezed,Object? note = freezed,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? approvalComment = freezed,Object? movementGroupId = freezed,Object? lineCount = null,Object? totalValue = freezed,Object? attachmentIds = null,Object? rowVersion = null,Object? lines = null,Object? audit = freezed,}) {
  return _then(WasteDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationRefDto,reasonCodeId: null == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WasteStatus,reasonCodeName: freezed == reasonCodeName ? _self.reasonCodeName : reasonCodeName // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as int?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvalComment: freezed == approvalComment ? _self.approvalComment : approvalComment // ignore: cast_nullable_to_non_nullable
as String?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,totalValue: freezed == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as Money?,attachmentIds: null == attachmentIds ? _self.attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<WasteLineDto>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}
/// Create a copy of WasteDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get location {
  
  return $LocationRefDtoCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of WasteDto
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


/// Adds pattern-matching-related methods to [WasteDto].
extension WasteDtoPatterns on WasteDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WasteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WasteDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WasteDto value)  $default,){
final _that = this;
switch (_that) {
case _WasteDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WasteDto value)?  $default,){
final _that = this;
switch (_that) {
case _WasteDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  LocationRefDto location,  int reasonCodeId,  WasteStatus status,  String? reasonCodeName,  String? note,  int? approvedBy,  DateTime? approvedAt,  String? approvalComment,  int? movementGroupId,  int lineCount,  Money? totalValue,  List<int> attachmentIds,  int rowVersion,  List<WasteLineDto> lines,  AuditFieldsDto? audit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WasteDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.location,_that.reasonCodeId,_that.status,_that.reasonCodeName,_that.note,_that.approvedBy,_that.approvedAt,_that.approvalComment,_that.movementGroupId,_that.lineCount,_that.totalValue,_that.attachmentIds,_that.rowVersion,_that.lines,_that.audit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  LocationRefDto location,  int reasonCodeId,  WasteStatus status,  String? reasonCodeName,  String? note,  int? approvedBy,  DateTime? approvedAt,  String? approvalComment,  int? movementGroupId,  int lineCount,  Money? totalValue,  List<int> attachmentIds,  int rowVersion,  List<WasteLineDto> lines,  AuditFieldsDto? audit)  $default,) {final _that = this;
switch (_that) {
case _WasteDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.location,_that.reasonCodeId,_that.status,_that.reasonCodeName,_that.note,_that.approvedBy,_that.approvedAt,_that.approvalComment,_that.movementGroupId,_that.lineCount,_that.totalValue,_that.attachmentIds,_that.rowVersion,_that.lines,_that.audit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  LocationRefDto location,  int reasonCodeId,  WasteStatus status,  String? reasonCodeName,  String? note,  int? approvedBy,  DateTime? approvedAt,  String? approvalComment,  int? movementGroupId,  int lineCount,  Money? totalValue,  List<int> attachmentIds,  int rowVersion,  List<WasteLineDto> lines,  AuditFieldsDto? audit)?  $default,) {final _that = this;
switch (_that) {
case _WasteDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.location,_that.reasonCodeId,_that.status,_that.reasonCodeName,_that.note,_that.approvedBy,_that.approvedAt,_that.approvalComment,_that.movementGroupId,_that.lineCount,_that.totalValue,_that.attachmentIds,_that.rowVersion,_that.lines,_that.audit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WasteDto implements WasteDto {
  const _WasteDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.location, required this.reasonCodeId, required this.status, this.reasonCodeName, this.note, this.approvedBy, this.approvedAt, this.approvalComment, this.movementGroupId, this.lineCount = 0, this.totalValue,  List<int> attachmentIds = const <int>[], this.rowVersion = 1,  List<WasteLineDto> lines = const <WasteLineDto>[], this.audit}): _attachmentIds = attachmentIds,_lines = lines;
  factory _WasteDto.fromJson(Map<String, dynamic> json) => _$WasteDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override@DateOnlyConverter() final  DateTime docDate;
@override final  LocationRefDto location;
@override final  int reasonCodeId;
@override final  WasteStatus status;
@override final  String? reasonCodeName;
@override final  String? note;
@override final  int? approvedBy;
@override final  DateTime? approvedAt;
@override final  String? approvalComment;
@override final  int? movementGroupId;
@override@JsonKey() final  int lineCount;
@override final  Money? totalValue;
 final  List<int> _attachmentIds;
@override@JsonKey() List<int> get attachmentIds {
  if (_attachmentIds is EqualUnmodifiableListView) return _attachmentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachmentIds);
}

@override@JsonKey() final  int rowVersion;
 final  List<WasteLineDto> _lines;
@override@JsonKey() List<WasteLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  AuditFieldsDto? audit;

/// Create a copy of WasteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WasteDtoCopyWith<_WasteDto> get copyWith => __$WasteDtoCopyWithImpl<_WasteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WasteDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WasteDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&(identical(other.status, status) || other.status == status)&&(identical(other.reasonCodeName, reasonCodeName) || other.reasonCodeName == reasonCodeName)&&(identical(other.note, note) || other.note == note)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvalComment, approvalComment) || other.approvalComment == approvalComment)&&(identical(other.movementGroupId, movementGroupId) || other.movementGroupId == movementGroupId)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&const DeepCollectionEquality().equals(other.attachmentIds, _attachmentIds)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.audit, audit) || other.audit == audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,docDate,location,reasonCodeId,status,reasonCodeName,note,approvedBy,approvedAt,approvalComment,movementGroupId,lineCount,totalValue,const DeepCollectionEquality().hash(_attachmentIds),rowVersion,const DeepCollectionEquality().hash(_lines),audit);
}

@override
String toString() {
    return 'WasteDto(id: $id, docNo: $docNo, docDate: $docDate, location: $location, reasonCodeId: $reasonCodeId, status: $status, reasonCodeName: $reasonCodeName, note: $note, approvedBy: $approvedBy, approvedAt: $approvedAt, approvalComment: $approvalComment, movementGroupId: $movementGroupId, lineCount: $lineCount, totalValue: $totalValue, attachmentIds: $attachmentIds, rowVersion: $rowVersion, lines: $lines, audit: $audit)';
}


}

/// @nodoc
abstract mixin class _$WasteDtoCopyWith<$Res> implements $WasteDtoCopyWith<$Res> {
  factory _$WasteDtoCopyWith(_WasteDto value, $Res Function(_WasteDto) _then) = __$WasteDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, LocationRefDto location, int reasonCodeId, WasteStatus status, String? reasonCodeName, String? note, int? approvedBy, DateTime? approvedAt, String? approvalComment, int? movementGroupId, int lineCount, Money? totalValue, List<int> attachmentIds, int rowVersion, List<WasteLineDto> lines, AuditFieldsDto? audit
});


@override $LocationRefDtoCopyWith<$Res> get location;@override $AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class __$WasteDtoCopyWithImpl<$Res>
    implements _$WasteDtoCopyWith<$Res> {
  __$WasteDtoCopyWithImpl(this._self, this._then);

  final _WasteDto _self;
  final $Res Function(_WasteDto) _then;

/// Create a copy of WasteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? location = null,Object? reasonCodeId = null,Object? status = null,Object? reasonCodeName = freezed,Object? note = freezed,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? approvalComment = freezed,Object? movementGroupId = freezed,Object? lineCount = null,Object? totalValue = freezed,Object? attachmentIds = null,Object? rowVersion = null,Object? lines = null,Object? audit = freezed,}) {
  return _then(_WasteDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationRefDto,reasonCodeId: null == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WasteStatus,reasonCodeName: freezed == reasonCodeName ? _self.reasonCodeName : reasonCodeName // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as int?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvalComment: freezed == approvalComment ? _self.approvalComment : approvalComment // ignore: cast_nullable_to_non_nullable
as String?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,totalValue: freezed == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as Money?,attachmentIds: null == attachmentIds ? _self._attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<WasteLineDto>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}

/// Create a copy of WasteDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get location {
  
  return $LocationRefDtoCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of WasteDto
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
mixin _$CreateWasteLine {

 int get productId; QuantityInput get quantity; int? get batchId; String? get note;
/// Create a copy of CreateWasteLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWasteLineCopyWith<CreateWasteLine> get copyWith => _$CreateWasteLineCopyWithImpl<CreateWasteLine>(this as CreateWasteLine, _$identity);

  /// Serializes this CreateWasteLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateWasteLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWasteLine&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateWasteLine;
  return Object.hash(runtimeType,_this.productId,_this.quantity,_this.batchId,_this.note);
}

@override
String toString() {
  final _this = this as CreateWasteLine;
  return 'CreateWasteLine(productId: ${_this.productId}, quantity: ${_this.quantity}, batchId: ${_this.batchId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $CreateWasteLineCopyWith<$Res>  {
  factory $CreateWasteLineCopyWith(CreateWasteLine value, $Res Function(CreateWasteLine) _then) = _$CreateWasteLineCopyWithImpl;
@useResult
$Res call({
 int productId, QuantityInput quantity, int? batchId, String? note
});


$QuantityInputCopyWith<$Res> get quantity;

}
/// @nodoc
class _$CreateWasteLineCopyWithImpl<$Res>
    implements $CreateWasteLineCopyWith<$Res> {
  _$CreateWasteLineCopyWithImpl(this._self, this._then);

  final CreateWasteLine _self;
  final $Res Function(CreateWasteLine) _then;

/// Create a copy of CreateWasteLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? quantity = null,Object? batchId = freezed,Object? note = freezed,}) {
  return _then(CreateWasteLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityInput,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CreateWasteLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityInputCopyWith<$Res> get quantity {
  
  return $QuantityInputCopyWith<$Res>(_self.quantity, (value) {
    return _then(_self.copyWith(quantity: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateWasteLine].
extension CreateWasteLinePatterns on CreateWasteLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWasteLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWasteLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWasteLine value)  $default,){
final _that = this;
switch (_that) {
case _CreateWasteLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWasteLine value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWasteLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  QuantityInput quantity,  int? batchId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWasteLine() when $default != null:
return $default(_that.productId,_that.quantity,_that.batchId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  QuantityInput quantity,  int? batchId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreateWasteLine():
return $default(_that.productId,_that.quantity,_that.batchId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  QuantityInput quantity,  int? batchId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreateWasteLine() when $default != null:
return $default(_that.productId,_that.quantity,_that.batchId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWasteLine implements CreateWasteLine {
  const _CreateWasteLine({required this.productId, required this.quantity, this.batchId, this.note});
  factory _CreateWasteLine.fromJson(Map<String, dynamic> json) => _$CreateWasteLineFromJson(json);

@override final  int productId;
@override final  QuantityInput quantity;
@override final  int? batchId;
@override final  String? note;

/// Create a copy of CreateWasteLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWasteLineCopyWith<_CreateWasteLine> get copyWith => __$CreateWasteLineCopyWithImpl<_CreateWasteLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWasteLineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWasteLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,quantity,batchId,note);
}

@override
String toString() {
    return 'CreateWasteLine(productId: $productId, quantity: $quantity, batchId: $batchId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateWasteLineCopyWith<$Res> implements $CreateWasteLineCopyWith<$Res> {
  factory _$CreateWasteLineCopyWith(_CreateWasteLine value, $Res Function(_CreateWasteLine) _then) = __$CreateWasteLineCopyWithImpl;
@override @useResult
$Res call({
 int productId, QuantityInput quantity, int? batchId, String? note
});


@override $QuantityInputCopyWith<$Res> get quantity;

}
/// @nodoc
class __$CreateWasteLineCopyWithImpl<$Res>
    implements _$CreateWasteLineCopyWith<$Res> {
  __$CreateWasteLineCopyWithImpl(this._self, this._then);

  final _CreateWasteLine _self;
  final $Res Function(_CreateWasteLine) _then;

/// Create a copy of CreateWasteLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? quantity = null,Object? batchId = freezed,Object? note = freezed,}) {
  return _then(_CreateWasteLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityInput,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CreateWasteLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityInputCopyWith<$Res> get quantity {
  
  return $QuantityInputCopyWith<$Res>(_self.quantity, (value) {
    return _then(_self.copyWith(quantity: value));
  });
}
}


/// @nodoc
mixin _$CreateWasteRequest {

@DateOnlyConverter() DateTime get docDate; int get locationId; int get reasonCodeId; List<CreateWasteLine> get lines; String? get note; List<int> get attachmentIds;
/// Create a copy of CreateWasteRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWasteRequestCopyWith<CreateWasteRequest> get copyWith => _$CreateWasteRequestCopyWithImpl<CreateWasteRequest>(this as CreateWasteRequest, _$identity);

  /// Serializes this CreateWasteRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateWasteRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWasteRequest&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.note, _this.note) || other.note == _this.note)&&const DeepCollectionEquality().equals(other.attachmentIds, _this.attachmentIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateWasteRequest;
  return Object.hash(runtimeType,_this.docDate,_this.locationId,_this.reasonCodeId,const DeepCollectionEquality().hash(_this.lines),_this.note,const DeepCollectionEquality().hash(_this.attachmentIds));
}

@override
String toString() {
  final _this = this as CreateWasteRequest;
  return 'CreateWasteRequest(docDate: ${_this.docDate}, locationId: ${_this.locationId}, reasonCodeId: ${_this.reasonCodeId}, lines: ${_this.lines}, note: ${_this.note}, attachmentIds: ${_this.attachmentIds})';
}


}

/// @nodoc
abstract mixin class $CreateWasteRequestCopyWith<$Res>  {
  factory $CreateWasteRequestCopyWith(CreateWasteRequest value, $Res Function(CreateWasteRequest) _then) = _$CreateWasteRequestCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime docDate, int locationId, int reasonCodeId, List<CreateWasteLine> lines, String? note, List<int> attachmentIds
});




}
/// @nodoc
class _$CreateWasteRequestCopyWithImpl<$Res>
    implements $CreateWasteRequestCopyWith<$Res> {
  _$CreateWasteRequestCopyWithImpl(this._self, this._then);

  final CreateWasteRequest _self;
  final $Res Function(CreateWasteRequest) _then;

/// Create a copy of CreateWasteRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? docDate = null,Object? locationId = null,Object? reasonCodeId = null,Object? lines = null,Object? note = freezed,Object? attachmentIds = null,}) {
  return _then(CreateWasteRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,reasonCodeId: null == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateWasteLine>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,attachmentIds: null == attachmentIds ? _self.attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWasteRequest].
extension CreateWasteRequestPatterns on CreateWasteRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWasteRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWasteRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWasteRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateWasteRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWasteRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWasteRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  int locationId,  int reasonCodeId,  List<CreateWasteLine> lines,  String? note,  List<int> attachmentIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWasteRequest() when $default != null:
return $default(_that.docDate,_that.locationId,_that.reasonCodeId,_that.lines,_that.note,_that.attachmentIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  int locationId,  int reasonCodeId,  List<CreateWasteLine> lines,  String? note,  List<int> attachmentIds)  $default,) {final _that = this;
switch (_that) {
case _CreateWasteRequest():
return $default(_that.docDate,_that.locationId,_that.reasonCodeId,_that.lines,_that.note,_that.attachmentIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime docDate,  int locationId,  int reasonCodeId,  List<CreateWasteLine> lines,  String? note,  List<int> attachmentIds)?  $default,) {final _that = this;
switch (_that) {
case _CreateWasteRequest() when $default != null:
return $default(_that.docDate,_that.locationId,_that.reasonCodeId,_that.lines,_that.note,_that.attachmentIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWasteRequest implements CreateWasteRequest {
  const _CreateWasteRequest({@DateOnlyConverter() required this.docDate, required this.locationId, required this.reasonCodeId, required  List<CreateWasteLine> lines, this.note,  List<int> attachmentIds = const <int>[]}): _lines = lines,_attachmentIds = attachmentIds;
  factory _CreateWasteRequest.fromJson(Map<String, dynamic> json) => _$CreateWasteRequestFromJson(json);

@override@DateOnlyConverter() final  DateTime docDate;
@override final  int locationId;
@override final  int reasonCodeId;
 final  List<CreateWasteLine> _lines;
@override List<CreateWasteLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  String? note;
 final  List<int> _attachmentIds;
@override@JsonKey() List<int> get attachmentIds {
  if (_attachmentIds is EqualUnmodifiableListView) return _attachmentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachmentIds);
}


/// Create a copy of CreateWasteRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWasteRequestCopyWith<_CreateWasteRequest> get copyWith => __$CreateWasteRequestCopyWithImpl<_CreateWasteRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWasteRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWasteRequest&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.attachmentIds, _attachmentIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,docDate,locationId,reasonCodeId,const DeepCollectionEquality().hash(_lines),note,const DeepCollectionEquality().hash(_attachmentIds));
}

@override
String toString() {
    return 'CreateWasteRequest(docDate: $docDate, locationId: $locationId, reasonCodeId: $reasonCodeId, lines: $lines, note: $note, attachmentIds: $attachmentIds)';
}


}

/// @nodoc
abstract mixin class _$CreateWasteRequestCopyWith<$Res> implements $CreateWasteRequestCopyWith<$Res> {
  factory _$CreateWasteRequestCopyWith(_CreateWasteRequest value, $Res Function(_CreateWasteRequest) _then) = __$CreateWasteRequestCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime docDate, int locationId, int reasonCodeId, List<CreateWasteLine> lines, String? note, List<int> attachmentIds
});




}
/// @nodoc
class __$CreateWasteRequestCopyWithImpl<$Res>
    implements _$CreateWasteRequestCopyWith<$Res> {
  __$CreateWasteRequestCopyWithImpl(this._self, this._then);

  final _CreateWasteRequest _self;
  final $Res Function(_CreateWasteRequest) _then;

/// Create a copy of CreateWasteRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? docDate = null,Object? locationId = null,Object? reasonCodeId = null,Object? lines = null,Object? note = freezed,Object? attachmentIds = null,}) {
  return _then(_CreateWasteRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,reasonCodeId: null == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateWasteLine>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,attachmentIds: null == attachmentIds ? _self._attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$SampleLineDto {

 int get lineNo; ProductRefDto get product; Quantity get qty; int get uomId; BatchRefDto? get batch; String? get uomCode; int? get id; Quantity? get qtyBase; String? get note; Money? get unitCost; Money? get totalValue;
/// Create a copy of SampleLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SampleLineDtoCopyWith<SampleLineDto> get copyWith => _$SampleLineDtoCopyWithImpl<SampleLineDto>(this as SampleLineDto, _$identity);

  /// Serializes this SampleLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SampleLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SampleLineDto&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.batch, _this.batch) || other.batch == _this.batch)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.qtyBase, _this.qtyBase) || other.qtyBase == _this.qtyBase)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.unitCost, _this.unitCost) || other.unitCost == _this.unitCost)&&(identical(other.totalValue, _this.totalValue) || other.totalValue == _this.totalValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SampleLineDto;
  return Object.hash(runtimeType,_this.lineNo,_this.product,_this.qty,_this.uomId,_this.batch,_this.uomCode,_this.id,_this.qtyBase,_this.note,_this.unitCost,_this.totalValue);
}

@override
String toString() {
  final _this = this as SampleLineDto;
  return 'SampleLineDto(lineNo: ${_this.lineNo}, product: ${_this.product}, qty: ${_this.qty}, uomId: ${_this.uomId}, batch: ${_this.batch}, uomCode: ${_this.uomCode}, id: ${_this.id}, qtyBase: ${_this.qtyBase}, note: ${_this.note}, unitCost: ${_this.unitCost}, totalValue: ${_this.totalValue})';
}


}

/// @nodoc
abstract mixin class $SampleLineDtoCopyWith<$Res>  {
  factory $SampleLineDtoCopyWith(SampleLineDto value, $Res Function(SampleLineDto) _then) = _$SampleLineDtoCopyWithImpl;
@useResult
$Res call({
 int lineNo, ProductRefDto product, Quantity qty, int uomId, BatchRefDto? batch, String? uomCode, int? id, Quantity? qtyBase, String? note, Money? unitCost, Money? totalValue
});


$ProductRefDtoCopyWith<$Res> get product;$BatchRefDtoCopyWith<$Res>? get batch;

}
/// @nodoc
class _$SampleLineDtoCopyWithImpl<$Res>
    implements $SampleLineDtoCopyWith<$Res> {
  _$SampleLineDtoCopyWithImpl(this._self, this._then);

  final SampleLineDto _self;
  final $Res Function(SampleLineDto) _then;

/// Create a copy of SampleLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? batch = freezed,Object? uomCode = freezed,Object? id = freezed,Object? qtyBase = freezed,Object? note = freezed,Object? unitCost = freezed,Object? totalValue = freezed,}) {
  return _then(SampleLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as BatchRefDto?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,qtyBase: freezed == qtyBase ? _self.qtyBase : qtyBase // ignore: cast_nullable_to_non_nullable
as Quantity?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,unitCost: freezed == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as Money?,totalValue: freezed == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}
/// Create a copy of SampleLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of SampleLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<$Res>? get batch {
    if (_self.batch == null) {
    return null;
  }

  return $BatchRefDtoCopyWith<$Res>(_self.batch!, (value) {
    return _then(_self.copyWith(batch: value));
  });
}
}


/// Adds pattern-matching-related methods to [SampleLineDto].
extension SampleLineDtoPatterns on SampleLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SampleLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SampleLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SampleLineDto value)  $default,){
final _that = this;
switch (_that) {
case _SampleLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SampleLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _SampleLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  BatchRefDto? batch,  String? uomCode,  int? id,  Quantity? qtyBase,  String? note,  Money? unitCost,  Money? totalValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SampleLineDto() when $default != null:
return $default(_that.lineNo,_that.product,_that.qty,_that.uomId,_that.batch,_that.uomCode,_that.id,_that.qtyBase,_that.note,_that.unitCost,_that.totalValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  BatchRefDto? batch,  String? uomCode,  int? id,  Quantity? qtyBase,  String? note,  Money? unitCost,  Money? totalValue)  $default,) {final _that = this;
switch (_that) {
case _SampleLineDto():
return $default(_that.lineNo,_that.product,_that.qty,_that.uomId,_that.batch,_that.uomCode,_that.id,_that.qtyBase,_that.note,_that.unitCost,_that.totalValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  BatchRefDto? batch,  String? uomCode,  int? id,  Quantity? qtyBase,  String? note,  Money? unitCost,  Money? totalValue)?  $default,) {final _that = this;
switch (_that) {
case _SampleLineDto() when $default != null:
return $default(_that.lineNo,_that.product,_that.qty,_that.uomId,_that.batch,_that.uomCode,_that.id,_that.qtyBase,_that.note,_that.unitCost,_that.totalValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SampleLineDto implements SampleLineDto {
  const _SampleLineDto({required this.lineNo, required this.product, required this.qty, required this.uomId, this.batch, this.uomCode, this.id, this.qtyBase, this.note, this.unitCost, this.totalValue});
  factory _SampleLineDto.fromJson(Map<String, dynamic> json) => _$SampleLineDtoFromJson(json);

@override final  int lineNo;
@override final  ProductRefDto product;
@override final  Quantity qty;
@override final  int uomId;
@override final  BatchRefDto? batch;
@override final  String? uomCode;
@override final  int? id;
@override final  Quantity? qtyBase;
@override final  String? note;
@override final  Money? unitCost;
@override final  Money? totalValue;

/// Create a copy of SampleLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SampleLineDtoCopyWith<_SampleLineDto> get copyWith => __$SampleLineDtoCopyWithImpl<_SampleLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SampleLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SampleLineDto&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.product, product) || other.product == product)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.id, id) || other.id == id)&&(identical(other.qtyBase, qtyBase) || other.qtyBase == qtyBase)&&(identical(other.note, note) || other.note == note)&&(identical(other.unitCost, unitCost) || other.unitCost == unitCost)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,product,qty,uomId,batch,uomCode,id,qtyBase,note,unitCost,totalValue);
}

@override
String toString() {
    return 'SampleLineDto(lineNo: $lineNo, product: $product, qty: $qty, uomId: $uomId, batch: $batch, uomCode: $uomCode, id: $id, qtyBase: $qtyBase, note: $note, unitCost: $unitCost, totalValue: $totalValue)';
}


}

/// @nodoc
abstract mixin class _$SampleLineDtoCopyWith<$Res> implements $SampleLineDtoCopyWith<$Res> {
  factory _$SampleLineDtoCopyWith(_SampleLineDto value, $Res Function(_SampleLineDto) _then) = __$SampleLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, ProductRefDto product, Quantity qty, int uomId, BatchRefDto? batch, String? uomCode, int? id, Quantity? qtyBase, String? note, Money? unitCost, Money? totalValue
});


@override $ProductRefDtoCopyWith<$Res> get product;@override $BatchRefDtoCopyWith<$Res>? get batch;

}
/// @nodoc
class __$SampleLineDtoCopyWithImpl<$Res>
    implements _$SampleLineDtoCopyWith<$Res> {
  __$SampleLineDtoCopyWithImpl(this._self, this._then);

  final _SampleLineDto _self;
  final $Res Function(_SampleLineDto) _then;

/// Create a copy of SampleLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? batch = freezed,Object? uomCode = freezed,Object? id = freezed,Object? qtyBase = freezed,Object? note = freezed,Object? unitCost = freezed,Object? totalValue = freezed,}) {
  return _then(_SampleLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as BatchRefDto?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,qtyBase: freezed == qtyBase ? _self.qtyBase : qtyBase // ignore: cast_nullable_to_non_nullable
as Quantity?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,unitCost: freezed == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as Money?,totalValue: freezed == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}

/// Create a copy of SampleLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of SampleLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchRefDtoCopyWith<$Res>? get batch {
    if (_self.batch == null) {
    return null;
  }

  return $BatchRefDtoCopyWith<$Res>(_self.batch!, (value) {
    return _then(_self.copyWith(batch: value));
  });
}
}


/// @nodoc
mixin _$SampleDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; LocationRefDto get location; SimpleDocStatus get status; String get authority; String? get purpose; int? get reasonCodeId; int? get movementGroupId; int get lineCount; List<int> get attachmentIds; int get rowVersion; List<SampleLineDto> get lines; AuditFieldsDto? get audit;
/// Create a copy of SampleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SampleDtoCopyWith<SampleDto> get copyWith => _$SampleDtoCopyWithImpl<SampleDto>(this as SampleDto, _$identity);

  /// Serializes this SampleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SampleDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SampleDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.authority, _this.authority) || other.authority == _this.authority)&&(identical(other.purpose, _this.purpose) || other.purpose == _this.purpose)&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&(identical(other.movementGroupId, _this.movementGroupId) || other.movementGroupId == _this.movementGroupId)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&const DeepCollectionEquality().equals(other.attachmentIds, _this.attachmentIds)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.audit, _this.audit) || other.audit == _this.audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SampleDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.docDate,_this.location,_this.status,_this.authority,_this.purpose,_this.reasonCodeId,_this.movementGroupId,_this.lineCount,const DeepCollectionEquality().hash(_this.attachmentIds),_this.rowVersion,const DeepCollectionEquality().hash(_this.lines),_this.audit);
}

@override
String toString() {
  final _this = this as SampleDto;
  return 'SampleDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, location: ${_this.location}, status: ${_this.status}, authority: ${_this.authority}, purpose: ${_this.purpose}, reasonCodeId: ${_this.reasonCodeId}, movementGroupId: ${_this.movementGroupId}, lineCount: ${_this.lineCount}, attachmentIds: ${_this.attachmentIds}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines}, audit: ${_this.audit})';
}


}

/// @nodoc
abstract mixin class $SampleDtoCopyWith<$Res>  {
  factory $SampleDtoCopyWith(SampleDto value, $Res Function(SampleDto) _then) = _$SampleDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, LocationRefDto location, SimpleDocStatus status, String authority, String? purpose, int? reasonCodeId, int? movementGroupId, int lineCount, List<int> attachmentIds, int rowVersion, List<SampleLineDto> lines, AuditFieldsDto? audit
});


$LocationRefDtoCopyWith<$Res> get location;$AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class _$SampleDtoCopyWithImpl<$Res>
    implements $SampleDtoCopyWith<$Res> {
  _$SampleDtoCopyWithImpl(this._self, this._then);

  final SampleDto _self;
  final $Res Function(SampleDto) _then;

/// Create a copy of SampleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? location = null,Object? status = null,Object? authority = null,Object? purpose = freezed,Object? reasonCodeId = freezed,Object? movementGroupId = freezed,Object? lineCount = null,Object? attachmentIds = null,Object? rowVersion = null,Object? lines = null,Object? audit = freezed,}) {
  return _then(SampleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationRefDto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SimpleDocStatus,authority: null == authority ? _self.authority : authority // ignore: cast_nullable_to_non_nullable
as String,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,attachmentIds: null == attachmentIds ? _self.attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<SampleLineDto>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}
/// Create a copy of SampleDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get location {
  
  return $LocationRefDtoCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of SampleDto
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


/// Adds pattern-matching-related methods to [SampleDto].
extension SampleDtoPatterns on SampleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SampleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SampleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SampleDto value)  $default,){
final _that = this;
switch (_that) {
case _SampleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SampleDto value)?  $default,){
final _that = this;
switch (_that) {
case _SampleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  LocationRefDto location,  SimpleDocStatus status,  String authority,  String? purpose,  int? reasonCodeId,  int? movementGroupId,  int lineCount,  List<int> attachmentIds,  int rowVersion,  List<SampleLineDto> lines,  AuditFieldsDto? audit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SampleDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.location,_that.status,_that.authority,_that.purpose,_that.reasonCodeId,_that.movementGroupId,_that.lineCount,_that.attachmentIds,_that.rowVersion,_that.lines,_that.audit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  LocationRefDto location,  SimpleDocStatus status,  String authority,  String? purpose,  int? reasonCodeId,  int? movementGroupId,  int lineCount,  List<int> attachmentIds,  int rowVersion,  List<SampleLineDto> lines,  AuditFieldsDto? audit)  $default,) {final _that = this;
switch (_that) {
case _SampleDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.location,_that.status,_that.authority,_that.purpose,_that.reasonCodeId,_that.movementGroupId,_that.lineCount,_that.attachmentIds,_that.rowVersion,_that.lines,_that.audit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  LocationRefDto location,  SimpleDocStatus status,  String authority,  String? purpose,  int? reasonCodeId,  int? movementGroupId,  int lineCount,  List<int> attachmentIds,  int rowVersion,  List<SampleLineDto> lines,  AuditFieldsDto? audit)?  $default,) {final _that = this;
switch (_that) {
case _SampleDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.location,_that.status,_that.authority,_that.purpose,_that.reasonCodeId,_that.movementGroupId,_that.lineCount,_that.attachmentIds,_that.rowVersion,_that.lines,_that.audit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SampleDto implements SampleDto {
  const _SampleDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.location, required this.status, this.authority = 'AQTA', this.purpose, this.reasonCodeId, this.movementGroupId, this.lineCount = 0,  List<int> attachmentIds = const <int>[], this.rowVersion = 1,  List<SampleLineDto> lines = const <SampleLineDto>[], this.audit}): _attachmentIds = attachmentIds,_lines = lines;
  factory _SampleDto.fromJson(Map<String, dynamic> json) => _$SampleDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override@DateOnlyConverter() final  DateTime docDate;
@override final  LocationRefDto location;
@override final  SimpleDocStatus status;
@override@JsonKey() final  String authority;
@override final  String? purpose;
@override final  int? reasonCodeId;
@override final  int? movementGroupId;
@override@JsonKey() final  int lineCount;
 final  List<int> _attachmentIds;
@override@JsonKey() List<int> get attachmentIds {
  if (_attachmentIds is EqualUnmodifiableListView) return _attachmentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachmentIds);
}

@override@JsonKey() final  int rowVersion;
 final  List<SampleLineDto> _lines;
@override@JsonKey() List<SampleLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  AuditFieldsDto? audit;

/// Create a copy of SampleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SampleDtoCopyWith<_SampleDto> get copyWith => __$SampleDtoCopyWithImpl<_SampleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SampleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SampleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.status, status) || other.status == status)&&(identical(other.authority, authority) || other.authority == authority)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&(identical(other.movementGroupId, movementGroupId) || other.movementGroupId == movementGroupId)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&const DeepCollectionEquality().equals(other.attachmentIds, _attachmentIds)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.audit, audit) || other.audit == audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,docDate,location,status,authority,purpose,reasonCodeId,movementGroupId,lineCount,const DeepCollectionEquality().hash(_attachmentIds),rowVersion,const DeepCollectionEquality().hash(_lines),audit);
}

@override
String toString() {
    return 'SampleDto(id: $id, docNo: $docNo, docDate: $docDate, location: $location, status: $status, authority: $authority, purpose: $purpose, reasonCodeId: $reasonCodeId, movementGroupId: $movementGroupId, lineCount: $lineCount, attachmentIds: $attachmentIds, rowVersion: $rowVersion, lines: $lines, audit: $audit)';
}


}

/// @nodoc
abstract mixin class _$SampleDtoCopyWith<$Res> implements $SampleDtoCopyWith<$Res> {
  factory _$SampleDtoCopyWith(_SampleDto value, $Res Function(_SampleDto) _then) = __$SampleDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, LocationRefDto location, SimpleDocStatus status, String authority, String? purpose, int? reasonCodeId, int? movementGroupId, int lineCount, List<int> attachmentIds, int rowVersion, List<SampleLineDto> lines, AuditFieldsDto? audit
});


@override $LocationRefDtoCopyWith<$Res> get location;@override $AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class __$SampleDtoCopyWithImpl<$Res>
    implements _$SampleDtoCopyWith<$Res> {
  __$SampleDtoCopyWithImpl(this._self, this._then);

  final _SampleDto _self;
  final $Res Function(_SampleDto) _then;

/// Create a copy of SampleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? location = null,Object? status = null,Object? authority = null,Object? purpose = freezed,Object? reasonCodeId = freezed,Object? movementGroupId = freezed,Object? lineCount = null,Object? attachmentIds = null,Object? rowVersion = null,Object? lines = null,Object? audit = freezed,}) {
  return _then(_SampleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationRefDto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SimpleDocStatus,authority: null == authority ? _self.authority : authority // ignore: cast_nullable_to_non_nullable
as String,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,attachmentIds: null == attachmentIds ? _self._attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<SampleLineDto>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}

/// Create a copy of SampleDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get location {
  
  return $LocationRefDtoCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of SampleDto
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
mixin _$CreateSampleLine {

 int get productId; QuantityInput get quantity; int? get batchId; String? get note;
/// Create a copy of CreateSampleLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateSampleLineCopyWith<CreateSampleLine> get copyWith => _$CreateSampleLineCopyWithImpl<CreateSampleLine>(this as CreateSampleLine, _$identity);

  /// Serializes this CreateSampleLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateSampleLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateSampleLine&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateSampleLine;
  return Object.hash(runtimeType,_this.productId,_this.quantity,_this.batchId,_this.note);
}

@override
String toString() {
  final _this = this as CreateSampleLine;
  return 'CreateSampleLine(productId: ${_this.productId}, quantity: ${_this.quantity}, batchId: ${_this.batchId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $CreateSampleLineCopyWith<$Res>  {
  factory $CreateSampleLineCopyWith(CreateSampleLine value, $Res Function(CreateSampleLine) _then) = _$CreateSampleLineCopyWithImpl;
@useResult
$Res call({
 int productId, QuantityInput quantity, int? batchId, String? note
});


$QuantityInputCopyWith<$Res> get quantity;

}
/// @nodoc
class _$CreateSampleLineCopyWithImpl<$Res>
    implements $CreateSampleLineCopyWith<$Res> {
  _$CreateSampleLineCopyWithImpl(this._self, this._then);

  final CreateSampleLine _self;
  final $Res Function(CreateSampleLine) _then;

/// Create a copy of CreateSampleLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? quantity = null,Object? batchId = freezed,Object? note = freezed,}) {
  return _then(CreateSampleLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityInput,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CreateSampleLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityInputCopyWith<$Res> get quantity {
  
  return $QuantityInputCopyWith<$Res>(_self.quantity, (value) {
    return _then(_self.copyWith(quantity: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateSampleLine].
extension CreateSampleLinePatterns on CreateSampleLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateSampleLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateSampleLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateSampleLine value)  $default,){
final _that = this;
switch (_that) {
case _CreateSampleLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateSampleLine value)?  $default,){
final _that = this;
switch (_that) {
case _CreateSampleLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  QuantityInput quantity,  int? batchId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateSampleLine() when $default != null:
return $default(_that.productId,_that.quantity,_that.batchId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  QuantityInput quantity,  int? batchId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreateSampleLine():
return $default(_that.productId,_that.quantity,_that.batchId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  QuantityInput quantity,  int? batchId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreateSampleLine() when $default != null:
return $default(_that.productId,_that.quantity,_that.batchId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateSampleLine implements CreateSampleLine {
  const _CreateSampleLine({required this.productId, required this.quantity, this.batchId, this.note});
  factory _CreateSampleLine.fromJson(Map<String, dynamic> json) => _$CreateSampleLineFromJson(json);

@override final  int productId;
@override final  QuantityInput quantity;
@override final  int? batchId;
@override final  String? note;

/// Create a copy of CreateSampleLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateSampleLineCopyWith<_CreateSampleLine> get copyWith => __$CreateSampleLineCopyWithImpl<_CreateSampleLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateSampleLineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateSampleLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,quantity,batchId,note);
}

@override
String toString() {
    return 'CreateSampleLine(productId: $productId, quantity: $quantity, batchId: $batchId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateSampleLineCopyWith<$Res> implements $CreateSampleLineCopyWith<$Res> {
  factory _$CreateSampleLineCopyWith(_CreateSampleLine value, $Res Function(_CreateSampleLine) _then) = __$CreateSampleLineCopyWithImpl;
@override @useResult
$Res call({
 int productId, QuantityInput quantity, int? batchId, String? note
});


@override $QuantityInputCopyWith<$Res> get quantity;

}
/// @nodoc
class __$CreateSampleLineCopyWithImpl<$Res>
    implements _$CreateSampleLineCopyWith<$Res> {
  __$CreateSampleLineCopyWithImpl(this._self, this._then);

  final _CreateSampleLine _self;
  final $Res Function(_CreateSampleLine) _then;

/// Create a copy of CreateSampleLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? quantity = null,Object? batchId = freezed,Object? note = freezed,}) {
  return _then(_CreateSampleLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityInput,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CreateSampleLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityInputCopyWith<$Res> get quantity {
  
  return $QuantityInputCopyWith<$Res>(_self.quantity, (value) {
    return _then(_self.copyWith(quantity: value));
  });
}
}


/// @nodoc
mixin _$CreateSampleRequest {

@DateOnlyConverter() DateTime get docDate; int get locationId; List<CreateSampleLine> get lines; String get authority; String? get purpose; int? get reasonCodeId; List<int> get attachmentIds;
/// Create a copy of CreateSampleRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateSampleRequestCopyWith<CreateSampleRequest> get copyWith => _$CreateSampleRequestCopyWithImpl<CreateSampleRequest>(this as CreateSampleRequest, _$identity);

  /// Serializes this CreateSampleRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateSampleRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateSampleRequest&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.authority, _this.authority) || other.authority == _this.authority)&&(identical(other.purpose, _this.purpose) || other.purpose == _this.purpose)&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&const DeepCollectionEquality().equals(other.attachmentIds, _this.attachmentIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateSampleRequest;
  return Object.hash(runtimeType,_this.docDate,_this.locationId,const DeepCollectionEquality().hash(_this.lines),_this.authority,_this.purpose,_this.reasonCodeId,const DeepCollectionEquality().hash(_this.attachmentIds));
}

@override
String toString() {
  final _this = this as CreateSampleRequest;
  return 'CreateSampleRequest(docDate: ${_this.docDate}, locationId: ${_this.locationId}, lines: ${_this.lines}, authority: ${_this.authority}, purpose: ${_this.purpose}, reasonCodeId: ${_this.reasonCodeId}, attachmentIds: ${_this.attachmentIds})';
}


}

/// @nodoc
abstract mixin class $CreateSampleRequestCopyWith<$Res>  {
  factory $CreateSampleRequestCopyWith(CreateSampleRequest value, $Res Function(CreateSampleRequest) _then) = _$CreateSampleRequestCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime docDate, int locationId, List<CreateSampleLine> lines, String authority, String? purpose, int? reasonCodeId, List<int> attachmentIds
});




}
/// @nodoc
class _$CreateSampleRequestCopyWithImpl<$Res>
    implements $CreateSampleRequestCopyWith<$Res> {
  _$CreateSampleRequestCopyWithImpl(this._self, this._then);

  final CreateSampleRequest _self;
  final $Res Function(CreateSampleRequest) _then;

/// Create a copy of CreateSampleRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? docDate = null,Object? locationId = null,Object? lines = null,Object? authority = null,Object? purpose = freezed,Object? reasonCodeId = freezed,Object? attachmentIds = null,}) {
  return _then(CreateSampleRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateSampleLine>,authority: null == authority ? _self.authority : authority // ignore: cast_nullable_to_non_nullable
as String,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,attachmentIds: null == attachmentIds ? _self.attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateSampleRequest].
extension CreateSampleRequestPatterns on CreateSampleRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateSampleRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateSampleRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateSampleRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateSampleRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateSampleRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateSampleRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  int locationId,  List<CreateSampleLine> lines,  String authority,  String? purpose,  int? reasonCodeId,  List<int> attachmentIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateSampleRequest() when $default != null:
return $default(_that.docDate,_that.locationId,_that.lines,_that.authority,_that.purpose,_that.reasonCodeId,_that.attachmentIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  int locationId,  List<CreateSampleLine> lines,  String authority,  String? purpose,  int? reasonCodeId,  List<int> attachmentIds)  $default,) {final _that = this;
switch (_that) {
case _CreateSampleRequest():
return $default(_that.docDate,_that.locationId,_that.lines,_that.authority,_that.purpose,_that.reasonCodeId,_that.attachmentIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime docDate,  int locationId,  List<CreateSampleLine> lines,  String authority,  String? purpose,  int? reasonCodeId,  List<int> attachmentIds)?  $default,) {final _that = this;
switch (_that) {
case _CreateSampleRequest() when $default != null:
return $default(_that.docDate,_that.locationId,_that.lines,_that.authority,_that.purpose,_that.reasonCodeId,_that.attachmentIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateSampleRequest implements CreateSampleRequest {
  const _CreateSampleRequest({@DateOnlyConverter() required this.docDate, required this.locationId, required  List<CreateSampleLine> lines, this.authority = 'AQTA', this.purpose, this.reasonCodeId,  List<int> attachmentIds = const <int>[]}): _lines = lines,_attachmentIds = attachmentIds;
  factory _CreateSampleRequest.fromJson(Map<String, dynamic> json) => _$CreateSampleRequestFromJson(json);

@override@DateOnlyConverter() final  DateTime docDate;
@override final  int locationId;
 final  List<CreateSampleLine> _lines;
@override List<CreateSampleLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override@JsonKey() final  String authority;
@override final  String? purpose;
@override final  int? reasonCodeId;
 final  List<int> _attachmentIds;
@override@JsonKey() List<int> get attachmentIds {
  if (_attachmentIds is EqualUnmodifiableListView) return _attachmentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachmentIds);
}


/// Create a copy of CreateSampleRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateSampleRequestCopyWith<_CreateSampleRequest> get copyWith => __$CreateSampleRequestCopyWithImpl<_CreateSampleRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateSampleRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateSampleRequest&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.authority, authority) || other.authority == authority)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&const DeepCollectionEquality().equals(other.attachmentIds, _attachmentIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,docDate,locationId,const DeepCollectionEquality().hash(_lines),authority,purpose,reasonCodeId,const DeepCollectionEquality().hash(_attachmentIds));
}

@override
String toString() {
    return 'CreateSampleRequest(docDate: $docDate, locationId: $locationId, lines: $lines, authority: $authority, purpose: $purpose, reasonCodeId: $reasonCodeId, attachmentIds: $attachmentIds)';
}


}

/// @nodoc
abstract mixin class _$CreateSampleRequestCopyWith<$Res> implements $CreateSampleRequestCopyWith<$Res> {
  factory _$CreateSampleRequestCopyWith(_CreateSampleRequest value, $Res Function(_CreateSampleRequest) _then) = __$CreateSampleRequestCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime docDate, int locationId, List<CreateSampleLine> lines, String authority, String? purpose, int? reasonCodeId, List<int> attachmentIds
});




}
/// @nodoc
class __$CreateSampleRequestCopyWithImpl<$Res>
    implements _$CreateSampleRequestCopyWith<$Res> {
  __$CreateSampleRequestCopyWithImpl(this._self, this._then);

  final _CreateSampleRequest _self;
  final $Res Function(_CreateSampleRequest) _then;

/// Create a copy of CreateSampleRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? docDate = null,Object? locationId = null,Object? lines = null,Object? authority = null,Object? purpose = freezed,Object? reasonCodeId = freezed,Object? attachmentIds = null,}) {
  return _then(_CreateSampleRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateSampleLine>,authority: null == authority ? _self.authority : authority // ignore: cast_nullable_to_non_nullable
as String,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,attachmentIds: null == attachmentIds ? _self._attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$VersionedActionRequest {

 int get rowVersion; String? get comment;
/// Create a copy of VersionedActionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VersionedActionRequestCopyWith<VersionedActionRequest> get copyWith => _$VersionedActionRequestCopyWithImpl<VersionedActionRequest>(this as VersionedActionRequest, _$identity);

  /// Serializes this VersionedActionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VersionedActionRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VersionedActionRequest&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VersionedActionRequest;
  return Object.hash(runtimeType,_this.rowVersion,_this.comment);
}

@override
String toString() {
  final _this = this as VersionedActionRequest;
  return 'VersionedActionRequest(rowVersion: ${_this.rowVersion}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $VersionedActionRequestCopyWith<$Res>  {
  factory $VersionedActionRequestCopyWith(VersionedActionRequest value, $Res Function(VersionedActionRequest) _then) = _$VersionedActionRequestCopyWithImpl;
@useResult
$Res call({
 int rowVersion, String? comment
});




}
/// @nodoc
class _$VersionedActionRequestCopyWithImpl<$Res>
    implements $VersionedActionRequestCopyWith<$Res> {
  _$VersionedActionRequestCopyWithImpl(this._self, this._then);

  final VersionedActionRequest _self;
  final $Res Function(VersionedActionRequest) _then;

/// Create a copy of VersionedActionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowVersion = null,Object? comment = freezed,}) {
  return _then(VersionedActionRequest(
rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VersionedActionRequest].
extension VersionedActionRequestPatterns on VersionedActionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VersionedActionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VersionedActionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VersionedActionRequest value)  $default,){
final _that = this;
switch (_that) {
case _VersionedActionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VersionedActionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _VersionedActionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rowVersion,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VersionedActionRequest() when $default != null:
return $default(_that.rowVersion,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rowVersion,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _VersionedActionRequest():
return $default(_that.rowVersion,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rowVersion,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _VersionedActionRequest() when $default != null:
return $default(_that.rowVersion,_that.comment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VersionedActionRequest implements VersionedActionRequest {
  const _VersionedActionRequest({required this.rowVersion, this.comment});
  factory _VersionedActionRequest.fromJson(Map<String, dynamic> json) => _$VersionedActionRequestFromJson(json);

@override final  int rowVersion;
@override final  String? comment;

/// Create a copy of VersionedActionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VersionedActionRequestCopyWith<_VersionedActionRequest> get copyWith => __$VersionedActionRequestCopyWithImpl<_VersionedActionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VersionedActionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VersionedActionRequest&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rowVersion,comment);
}

@override
String toString() {
    return 'VersionedActionRequest(rowVersion: $rowVersion, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$VersionedActionRequestCopyWith<$Res> implements $VersionedActionRequestCopyWith<$Res> {
  factory _$VersionedActionRequestCopyWith(_VersionedActionRequest value, $Res Function(_VersionedActionRequest) _then) = __$VersionedActionRequestCopyWithImpl;
@override @useResult
$Res call({
 int rowVersion, String? comment
});




}
/// @nodoc
class __$VersionedActionRequestCopyWithImpl<$Res>
    implements _$VersionedActionRequestCopyWith<$Res> {
  __$VersionedActionRequestCopyWithImpl(this._self, this._then);

  final _VersionedActionRequest _self;
  final $Res Function(_VersionedActionRequest) _then;

/// Create a copy of VersionedActionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowVersion = null,Object? comment = freezed,}) {
  return _then(_VersionedActionRequest(
rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$InventorySettingDto {

 String get key; String get value; SettingValueType get valueType; List<String> get allowedValues; String? get description;
/// Create a copy of InventorySettingDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventorySettingDtoCopyWith<InventorySettingDto> get copyWith => _$InventorySettingDtoCopyWithImpl<InventorySettingDto>(this as InventorySettingDto, _$identity);

  /// Serializes this InventorySettingDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InventorySettingDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventorySettingDto&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.valueType, _this.valueType) || other.valueType == _this.valueType)&&const DeepCollectionEquality().equals(other.allowedValues, _this.allowedValues)&&(identical(other.description, _this.description) || other.description == _this.description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InventorySettingDto;
  return Object.hash(runtimeType,_this.key,_this.value,_this.valueType,const DeepCollectionEquality().hash(_this.allowedValues),_this.description);
}

@override
String toString() {
  final _this = this as InventorySettingDto;
  return 'InventorySettingDto(key: ${_this.key}, value: ${_this.value}, valueType: ${_this.valueType}, allowedValues: ${_this.allowedValues}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $InventorySettingDtoCopyWith<$Res>  {
  factory $InventorySettingDtoCopyWith(InventorySettingDto value, $Res Function(InventorySettingDto) _then) = _$InventorySettingDtoCopyWithImpl;
@useResult
$Res call({
 String key, String value, SettingValueType valueType, List<String> allowedValues, String? description
});




}
/// @nodoc
class _$InventorySettingDtoCopyWithImpl<$Res>
    implements $InventorySettingDtoCopyWith<$Res> {
  _$InventorySettingDtoCopyWithImpl(this._self, this._then);

  final InventorySettingDto _self;
  final $Res Function(InventorySettingDto) _then;

/// Create a copy of InventorySettingDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? value = null,Object? valueType = null,Object? allowedValues = null,Object? description = freezed,}) {
  return _then(InventorySettingDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,valueType: null == valueType ? _self.valueType : valueType // ignore: cast_nullable_to_non_nullable
as SettingValueType,allowedValues: null == allowedValues ? _self.allowedValues : allowedValues // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InventorySettingDto].
extension InventorySettingDtoPatterns on InventorySettingDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventorySettingDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventorySettingDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventorySettingDto value)  $default,){
final _that = this;
switch (_that) {
case _InventorySettingDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventorySettingDto value)?  $default,){
final _that = this;
switch (_that) {
case _InventorySettingDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String value,  SettingValueType valueType,  List<String> allowedValues,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventorySettingDto() when $default != null:
return $default(_that.key,_that.value,_that.valueType,_that.allowedValues,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String value,  SettingValueType valueType,  List<String> allowedValues,  String? description)  $default,) {final _that = this;
switch (_that) {
case _InventorySettingDto():
return $default(_that.key,_that.value,_that.valueType,_that.allowedValues,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String value,  SettingValueType valueType,  List<String> allowedValues,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _InventorySettingDto() when $default != null:
return $default(_that.key,_that.value,_that.valueType,_that.allowedValues,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventorySettingDto extends InventorySettingDto {
  const _InventorySettingDto({required this.key, required this.value, required this.valueType,  List<String> allowedValues = const <String>[], this.description}): _allowedValues = allowedValues,super._();
  factory _InventorySettingDto.fromJson(Map<String, dynamic> json) => _$InventorySettingDtoFromJson(json);

@override final  String key;
@override final  String value;
@override final  SettingValueType valueType;
 final  List<String> _allowedValues;
@override@JsonKey() List<String> get allowedValues {
  if (_allowedValues is EqualUnmodifiableListView) return _allowedValues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedValues);
}

@override final  String? description;

/// Create a copy of InventorySettingDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventorySettingDtoCopyWith<_InventorySettingDto> get copyWith => __$InventorySettingDtoCopyWithImpl<_InventorySettingDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventorySettingDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventorySettingDto&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.valueType, valueType) || other.valueType == valueType)&&const DeepCollectionEquality().equals(other.allowedValues, _allowedValues)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,value,valueType,const DeepCollectionEquality().hash(_allowedValues),description);
}

@override
String toString() {
    return 'InventorySettingDto(key: $key, value: $value, valueType: $valueType, allowedValues: $allowedValues, description: $description)';
}


}

/// @nodoc
abstract mixin class _$InventorySettingDtoCopyWith<$Res> implements $InventorySettingDtoCopyWith<$Res> {
  factory _$InventorySettingDtoCopyWith(_InventorySettingDto value, $Res Function(_InventorySettingDto) _then) = __$InventorySettingDtoCopyWithImpl;
@override @useResult
$Res call({
 String key, String value, SettingValueType valueType, List<String> allowedValues, String? description
});




}
/// @nodoc
class __$InventorySettingDtoCopyWithImpl<$Res>
    implements _$InventorySettingDtoCopyWith<$Res> {
  __$InventorySettingDtoCopyWithImpl(this._self, this._then);

  final _InventorySettingDto _self;
  final $Res Function(_InventorySettingDto) _then;

/// Create a copy of InventorySettingDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? value = null,Object? valueType = null,Object? allowedValues = null,Object? description = freezed,}) {
  return _then(_InventorySettingDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,valueType: null == valueType ? _self.valueType : valueType // ignore: cast_nullable_to_non_nullable
as SettingValueType,allowedValues: null == allowedValues ? _self._allowedValues : allowedValues // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateInventorySettingRequest {

 String get value;
/// Create a copy of UpdateInventorySettingRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateInventorySettingRequestCopyWith<UpdateInventorySettingRequest> get copyWith => _$UpdateInventorySettingRequestCopyWithImpl<UpdateInventorySettingRequest>(this as UpdateInventorySettingRequest, _$identity);

  /// Serializes this UpdateInventorySettingRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateInventorySettingRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateInventorySettingRequest&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateInventorySettingRequest;
  return Object.hash(runtimeType,_this.value);
}

@override
String toString() {
  final _this = this as UpdateInventorySettingRequest;
  return 'UpdateInventorySettingRequest(value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $UpdateInventorySettingRequestCopyWith<$Res>  {
  factory $UpdateInventorySettingRequestCopyWith(UpdateInventorySettingRequest value, $Res Function(UpdateInventorySettingRequest) _then) = _$UpdateInventorySettingRequestCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$UpdateInventorySettingRequestCopyWithImpl<$Res>
    implements $UpdateInventorySettingRequestCopyWith<$Res> {
  _$UpdateInventorySettingRequestCopyWithImpl(this._self, this._then);

  final UpdateInventorySettingRequest _self;
  final $Res Function(UpdateInventorySettingRequest) _then;

/// Create a copy of UpdateInventorySettingRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(UpdateInventorySettingRequest(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateInventorySettingRequest].
extension UpdateInventorySettingRequestPatterns on UpdateInventorySettingRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateInventorySettingRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateInventorySettingRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateInventorySettingRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateInventorySettingRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateInventorySettingRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateInventorySettingRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateInventorySettingRequest() when $default != null:
return $default(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value)  $default,) {final _that = this;
switch (_that) {
case _UpdateInventorySettingRequest():
return $default(_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value)?  $default,) {final _that = this;
switch (_that) {
case _UpdateInventorySettingRequest() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateInventorySettingRequest implements UpdateInventorySettingRequest {
  const _UpdateInventorySettingRequest({required this.value});
  factory _UpdateInventorySettingRequest.fromJson(Map<String, dynamic> json) => _$UpdateInventorySettingRequestFromJson(json);

@override final  String value;

/// Create a copy of UpdateInventorySettingRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateInventorySettingRequestCopyWith<_UpdateInventorySettingRequest> get copyWith => __$UpdateInventorySettingRequestCopyWithImpl<_UpdateInventorySettingRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateInventorySettingRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateInventorySettingRequest&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,value);
}

@override
String toString() {
    return 'UpdateInventorySettingRequest(value: $value)';
}


}

/// @nodoc
abstract mixin class _$UpdateInventorySettingRequestCopyWith<$Res> implements $UpdateInventorySettingRequestCopyWith<$Res> {
  factory _$UpdateInventorySettingRequestCopyWith(_UpdateInventorySettingRequest value, $Res Function(_UpdateInventorySettingRequest) _then) = __$UpdateInventorySettingRequestCopyWithImpl;
@override @useResult
$Res call({
 String value
});




}
/// @nodoc
class __$UpdateInventorySettingRequestCopyWithImpl<$Res>
    implements _$UpdateInventorySettingRequestCopyWith<$Res> {
  __$UpdateInventorySettingRequestCopyWithImpl(this._self, this._then);

  final _UpdateInventorySettingRequest _self;
  final $Res Function(_UpdateInventorySettingRequest) _then;

/// Create a copy of UpdateInventorySettingRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_UpdateInventorySettingRequest(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
