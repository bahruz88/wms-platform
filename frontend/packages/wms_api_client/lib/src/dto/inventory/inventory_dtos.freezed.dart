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

 int get productId; int get locationId; Quantity get qtyOnHand; Quantity get qtyReserved; int get batchId; String? get productSku; String? get productName; String? get locationCode; String? get locationName; String? get batchNo;@NullableDateOnlyConverter() DateTime? get expiryDate; String? get baseUomCode; Money? get avgUnitCost; Money? get totalValue; DateTime? get updatedAt;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BalanceDto&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.qtyOnHand, _this.qtyOnHand) || other.qtyOnHand == _this.qtyOnHand)&&(identical(other.qtyReserved, _this.qtyReserved) || other.qtyReserved == _this.qtyReserved)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId)&&(identical(other.productSku, _this.productSku) || other.productSku == _this.productSku)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.locationCode, _this.locationCode) || other.locationCode == _this.locationCode)&&(identical(other.locationName, _this.locationName) || other.locationName == _this.locationName)&&(identical(other.batchNo, _this.batchNo) || other.batchNo == _this.batchNo)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&(identical(other.baseUomCode, _this.baseUomCode) || other.baseUomCode == _this.baseUomCode)&&(identical(other.avgUnitCost, _this.avgUnitCost) || other.avgUnitCost == _this.avgUnitCost)&&(identical(other.totalValue, _this.totalValue) || other.totalValue == _this.totalValue)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BalanceDto;
  return Object.hash(runtimeType,_this.productId,_this.locationId,_this.qtyOnHand,_this.qtyReserved,_this.batchId,_this.productSku,_this.productName,_this.locationCode,_this.locationName,_this.batchNo,_this.expiryDate,_this.baseUomCode,_this.avgUnitCost,_this.totalValue,_this.updatedAt);
}

@override
String toString() {
  final _this = this as BalanceDto;
  return 'BalanceDto(productId: ${_this.productId}, locationId: ${_this.locationId}, qtyOnHand: ${_this.qtyOnHand}, qtyReserved: ${_this.qtyReserved}, batchId: ${_this.batchId}, productSku: ${_this.productSku}, productName: ${_this.productName}, locationCode: ${_this.locationCode}, locationName: ${_this.locationName}, batchNo: ${_this.batchNo}, expiryDate: ${_this.expiryDate}, baseUomCode: ${_this.baseUomCode}, avgUnitCost: ${_this.avgUnitCost}, totalValue: ${_this.totalValue}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $BalanceDtoCopyWith<$Res>  {
  factory $BalanceDtoCopyWith(BalanceDto value, $Res Function(BalanceDto) _then) = _$BalanceDtoCopyWithImpl;
@useResult
$Res call({
 int productId, int locationId, Quantity qtyOnHand, Quantity qtyReserved, int batchId, String? productSku, String? productName, String? locationCode, String? locationName, String? batchNo,@NullableDateOnlyConverter() DateTime? expiryDate, String? baseUomCode, Money? avgUnitCost, Money? totalValue, DateTime? updatedAt
});




}
/// @nodoc
class _$BalanceDtoCopyWithImpl<$Res>
    implements $BalanceDtoCopyWith<$Res> {
  _$BalanceDtoCopyWithImpl(this._self, this._then);

  final BalanceDto _self;
  final $Res Function(BalanceDto) _then;

/// Create a copy of BalanceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? locationId = null,Object? qtyOnHand = null,Object? qtyReserved = null,Object? batchId = null,Object? productSku = freezed,Object? productName = freezed,Object? locationCode = freezed,Object? locationName = freezed,Object? batchNo = freezed,Object? expiryDate = freezed,Object? baseUomCode = freezed,Object? avgUnitCost = freezed,Object? totalValue = freezed,Object? updatedAt = freezed,}) {
  return _then(BalanceDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,qtyOnHand: null == qtyOnHand ? _self.qtyOnHand : qtyOnHand // ignore: cast_nullable_to_non_nullable
as Quantity,qtyReserved: null == qtyReserved ? _self.qtyReserved : qtyReserved // ignore: cast_nullable_to_non_nullable
as Quantity,batchId: null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int,productSku: freezed == productSku ? _self.productSku : productSku // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,locationCode: freezed == locationCode ? _self.locationCode : locationCode // ignore: cast_nullable_to_non_nullable
as String?,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,avgUnitCost: freezed == avgUnitCost ? _self.avgUnitCost : avgUnitCost // ignore: cast_nullable_to_non_nullable
as Money?,totalValue: freezed == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as Money?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  int locationId,  Quantity qtyOnHand,  Quantity qtyReserved,  int batchId,  String? productSku,  String? productName,  String? locationCode,  String? locationName,  String? batchNo, @NullableDateOnlyConverter()  DateTime? expiryDate,  String? baseUomCode,  Money? avgUnitCost,  Money? totalValue,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BalanceDto() when $default != null:
return $default(_that.productId,_that.locationId,_that.qtyOnHand,_that.qtyReserved,_that.batchId,_that.productSku,_that.productName,_that.locationCode,_that.locationName,_that.batchNo,_that.expiryDate,_that.baseUomCode,_that.avgUnitCost,_that.totalValue,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  int locationId,  Quantity qtyOnHand,  Quantity qtyReserved,  int batchId,  String? productSku,  String? productName,  String? locationCode,  String? locationName,  String? batchNo, @NullableDateOnlyConverter()  DateTime? expiryDate,  String? baseUomCode,  Money? avgUnitCost,  Money? totalValue,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BalanceDto():
return $default(_that.productId,_that.locationId,_that.qtyOnHand,_that.qtyReserved,_that.batchId,_that.productSku,_that.productName,_that.locationCode,_that.locationName,_that.batchNo,_that.expiryDate,_that.baseUomCode,_that.avgUnitCost,_that.totalValue,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  int locationId,  Quantity qtyOnHand,  Quantity qtyReserved,  int batchId,  String? productSku,  String? productName,  String? locationCode,  String? locationName,  String? batchNo, @NullableDateOnlyConverter()  DateTime? expiryDate,  String? baseUomCode,  Money? avgUnitCost,  Money? totalValue,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BalanceDto() when $default != null:
return $default(_that.productId,_that.locationId,_that.qtyOnHand,_that.qtyReserved,_that.batchId,_that.productSku,_that.productName,_that.locationCode,_that.locationName,_that.batchNo,_that.expiryDate,_that.baseUomCode,_that.avgUnitCost,_that.totalValue,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BalanceDto extends BalanceDto {
  const _BalanceDto({required this.productId, required this.locationId, required this.qtyOnHand, required this.qtyReserved, this.batchId = 0, this.productSku, this.productName, this.locationCode, this.locationName, this.batchNo, @NullableDateOnlyConverter() this.expiryDate, this.baseUomCode, this.avgUnitCost, this.totalValue, this.updatedAt}): super._();
  factory _BalanceDto.fromJson(Map<String, dynamic> json) => _$BalanceDtoFromJson(json);

@override final  int productId;
@override final  int locationId;
@override final  Quantity qtyOnHand;
@override final  Quantity qtyReserved;
@override@JsonKey() final  int batchId;
@override final  String? productSku;
@override final  String? productName;
@override final  String? locationCode;
@override final  String? locationName;
@override final  String? batchNo;
@override@NullableDateOnlyConverter() final  DateTime? expiryDate;
@override final  String? baseUomCode;
@override final  Money? avgUnitCost;
@override final  Money? totalValue;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BalanceDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.qtyOnHand, qtyOnHand) || other.qtyOnHand == qtyOnHand)&&(identical(other.qtyReserved, qtyReserved) || other.qtyReserved == qtyReserved)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.productSku, productSku) || other.productSku == productSku)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.locationCode, locationCode) || other.locationCode == locationCode)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.batchNo, batchNo) || other.batchNo == batchNo)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.baseUomCode, baseUomCode) || other.baseUomCode == baseUomCode)&&(identical(other.avgUnitCost, avgUnitCost) || other.avgUnitCost == avgUnitCost)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,locationId,qtyOnHand,qtyReserved,batchId,productSku,productName,locationCode,locationName,batchNo,expiryDate,baseUomCode,avgUnitCost,totalValue,updatedAt);
}

@override
String toString() {
    return 'BalanceDto(productId: $productId, locationId: $locationId, qtyOnHand: $qtyOnHand, qtyReserved: $qtyReserved, batchId: $batchId, productSku: $productSku, productName: $productName, locationCode: $locationCode, locationName: $locationName, batchNo: $batchNo, expiryDate: $expiryDate, baseUomCode: $baseUomCode, avgUnitCost: $avgUnitCost, totalValue: $totalValue, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BalanceDtoCopyWith<$Res> implements $BalanceDtoCopyWith<$Res> {
  factory _$BalanceDtoCopyWith(_BalanceDto value, $Res Function(_BalanceDto) _then) = __$BalanceDtoCopyWithImpl;
@override @useResult
$Res call({
 int productId, int locationId, Quantity qtyOnHand, Quantity qtyReserved, int batchId, String? productSku, String? productName, String? locationCode, String? locationName, String? batchNo,@NullableDateOnlyConverter() DateTime? expiryDate, String? baseUomCode, Money? avgUnitCost, Money? totalValue, DateTime? updatedAt
});




}
/// @nodoc
class __$BalanceDtoCopyWithImpl<$Res>
    implements _$BalanceDtoCopyWith<$Res> {
  __$BalanceDtoCopyWithImpl(this._self, this._then);

  final _BalanceDto _self;
  final $Res Function(_BalanceDto) _then;

/// Create a copy of BalanceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? locationId = null,Object? qtyOnHand = null,Object? qtyReserved = null,Object? batchId = null,Object? productSku = freezed,Object? productName = freezed,Object? locationCode = freezed,Object? locationName = freezed,Object? batchNo = freezed,Object? expiryDate = freezed,Object? baseUomCode = freezed,Object? avgUnitCost = freezed,Object? totalValue = freezed,Object? updatedAt = freezed,}) {
  return _then(_BalanceDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,qtyOnHand: null == qtyOnHand ? _self.qtyOnHand : qtyOnHand // ignore: cast_nullable_to_non_nullable
as Quantity,qtyReserved: null == qtyReserved ? _self.qtyReserved : qtyReserved // ignore: cast_nullable_to_non_nullable
as Quantity,batchId: null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int,productSku: freezed == productSku ? _self.productSku : productSku // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,locationCode: freezed == locationCode ? _self.locationCode : locationCode // ignore: cast_nullable_to_non_nullable
as String?,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,avgUnitCost: freezed == avgUnitCost ? _self.avgUnitCost : avgUnitCost // ignore: cast_nullable_to_non_nullable
as Money?,totalValue: freezed == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as Money?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$BatchDto {

 int get id; int get productId; String get batchNo; DateTime get receivedAt; BatchStatus get status;@NullableDateOnlyConverter() DateTime? get productionDate;@NullableDateOnlyConverter() DateTime? get expiryDate; int? get supplierId;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.batchNo, _this.batchNo) || other.batchNo == _this.batchNo)&&(identical(other.receivedAt, _this.receivedAt) || other.receivedAt == _this.receivedAt)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.productionDate, _this.productionDate) || other.productionDate == _this.productionDate)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BatchDto;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.batchNo,_this.receivedAt,_this.status,_this.productionDate,_this.expiryDate,_this.supplierId);
}

@override
String toString() {
  final _this = this as BatchDto;
  return 'BatchDto(id: ${_this.id}, productId: ${_this.productId}, batchNo: ${_this.batchNo}, receivedAt: ${_this.receivedAt}, status: ${_this.status}, productionDate: ${_this.productionDate}, expiryDate: ${_this.expiryDate}, supplierId: ${_this.supplierId})';
}


}

/// @nodoc
abstract mixin class $BatchDtoCopyWith<$Res>  {
  factory $BatchDtoCopyWith(BatchDto value, $Res Function(BatchDto) _then) = _$BatchDtoCopyWithImpl;
@useResult
$Res call({
 int id, int productId, String batchNo, DateTime receivedAt, BatchStatus status,@NullableDateOnlyConverter() DateTime? productionDate,@NullableDateOnlyConverter() DateTime? expiryDate, int? supplierId
});




}
/// @nodoc
class _$BatchDtoCopyWithImpl<$Res>
    implements $BatchDtoCopyWith<$Res> {
  _$BatchDtoCopyWithImpl(this._self, this._then);

  final BatchDto _self;
  final $Res Function(BatchDto) _then;

/// Create a copy of BatchDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? batchNo = null,Object? receivedAt = null,Object? status = null,Object? productionDate = freezed,Object? expiryDate = freezed,Object? supplierId = freezed,}) {
  return _then(BatchDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,batchNo: null == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchStatus,productionDate: freezed == productionDate ? _self.productionDate : productionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int productId,  String batchNo,  DateTime receivedAt,  BatchStatus status, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  int? supplierId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchDto() when $default != null:
return $default(_that.id,_that.productId,_that.batchNo,_that.receivedAt,_that.status,_that.productionDate,_that.expiryDate,_that.supplierId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int productId,  String batchNo,  DateTime receivedAt,  BatchStatus status, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  int? supplierId)  $default,) {final _that = this;
switch (_that) {
case _BatchDto():
return $default(_that.id,_that.productId,_that.batchNo,_that.receivedAt,_that.status,_that.productionDate,_that.expiryDate,_that.supplierId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int productId,  String batchNo,  DateTime receivedAt,  BatchStatus status, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  int? supplierId)?  $default,) {final _that = this;
switch (_that) {
case _BatchDto() when $default != null:
return $default(_that.id,_that.productId,_that.batchNo,_that.receivedAt,_that.status,_that.productionDate,_that.expiryDate,_that.supplierId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchDto implements BatchDto {
  const _BatchDto({required this.id, required this.productId, required this.batchNo, required this.receivedAt, required this.status, @NullableDateOnlyConverter() this.productionDate, @NullableDateOnlyConverter() this.expiryDate, this.supplierId});
  factory _BatchDto.fromJson(Map<String, dynamic> json) => _$BatchDtoFromJson(json);

@override final  int id;
@override final  int productId;
@override final  String batchNo;
@override final  DateTime receivedAt;
@override final  BatchStatus status;
@override@NullableDateOnlyConverter() final  DateTime? productionDate;
@override@NullableDateOnlyConverter() final  DateTime? expiryDate;
@override final  int? supplierId;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchDto&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.batchNo, batchNo) || other.batchNo == batchNo)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.productionDate, productionDate) || other.productionDate == productionDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,batchNo,receivedAt,status,productionDate,expiryDate,supplierId);
}

@override
String toString() {
    return 'BatchDto(id: $id, productId: $productId, batchNo: $batchNo, receivedAt: $receivedAt, status: $status, productionDate: $productionDate, expiryDate: $expiryDate, supplierId: $supplierId)';
}


}

/// @nodoc
abstract mixin class _$BatchDtoCopyWith<$Res> implements $BatchDtoCopyWith<$Res> {
  factory _$BatchDtoCopyWith(_BatchDto value, $Res Function(_BatchDto) _then) = __$BatchDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int productId, String batchNo, DateTime receivedAt, BatchStatus status,@NullableDateOnlyConverter() DateTime? productionDate,@NullableDateOnlyConverter() DateTime? expiryDate, int? supplierId
});




}
/// @nodoc
class __$BatchDtoCopyWithImpl<$Res>
    implements _$BatchDtoCopyWith<$Res> {
  __$BatchDtoCopyWithImpl(this._self, this._then);

  final _BatchDto _self;
  final $Res Function(_BatchDto) _then;

/// Create a copy of BatchDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? batchNo = null,Object? receivedAt = null,Object? status = null,Object? productionDate = freezed,Object? expiryDate = freezed,Object? supplierId = freezed,}) {
  return _then(_BatchDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,batchNo: null == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchStatus,productionDate: freezed == productionDate ? _self.productionDate : productionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$GoodsReceiptLineDto {

 int get lineNo; int get productId; Quantity get receivedQty; int get uomId; Quantity get rejectedQty; int? get id; String? get productName; int? get poLineId; Quantity? get orderedQty; String? get uomCode; String? get batchNo;@NullableDateOnlyConverter() DateTime? get productionDate;@NullableDateOnlyConverter() DateTime? get expiryDate; Money? get unitPrice; String? get currency; String? get varianceNote;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoodsReceiptLineDto&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.receivedQty, _this.receivedQty) || other.receivedQty == _this.receivedQty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.rejectedQty, _this.rejectedQty) || other.rejectedQty == _this.rejectedQty)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.poLineId, _this.poLineId) || other.poLineId == _this.poLineId)&&(identical(other.orderedQty, _this.orderedQty) || other.orderedQty == _this.orderedQty)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.batchNo, _this.batchNo) || other.batchNo == _this.batchNo)&&(identical(other.productionDate, _this.productionDate) || other.productionDate == _this.productionDate)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.varianceNote, _this.varianceNote) || other.varianceNote == _this.varianceNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoodsReceiptLineDto;
  return Object.hash(runtimeType,_this.lineNo,_this.productId,_this.receivedQty,_this.uomId,_this.rejectedQty,_this.id,_this.productName,_this.poLineId,_this.orderedQty,_this.uomCode,_this.batchNo,_this.productionDate,_this.expiryDate,_this.unitPrice,_this.currency,_this.varianceNote);
}

@override
String toString() {
  final _this = this as GoodsReceiptLineDto;
  return 'GoodsReceiptLineDto(lineNo: ${_this.lineNo}, productId: ${_this.productId}, receivedQty: ${_this.receivedQty}, uomId: ${_this.uomId}, rejectedQty: ${_this.rejectedQty}, id: ${_this.id}, productName: ${_this.productName}, poLineId: ${_this.poLineId}, orderedQty: ${_this.orderedQty}, uomCode: ${_this.uomCode}, batchNo: ${_this.batchNo}, productionDate: ${_this.productionDate}, expiryDate: ${_this.expiryDate}, unitPrice: ${_this.unitPrice}, currency: ${_this.currency}, varianceNote: ${_this.varianceNote})';
}


}

/// @nodoc
abstract mixin class $GoodsReceiptLineDtoCopyWith<$Res>  {
  factory $GoodsReceiptLineDtoCopyWith(GoodsReceiptLineDto value, $Res Function(GoodsReceiptLineDto) _then) = _$GoodsReceiptLineDtoCopyWithImpl;
@useResult
$Res call({
 int lineNo, int productId, Quantity receivedQty, int uomId, Quantity rejectedQty, int? id, String? productName, int? poLineId, Quantity? orderedQty, String? uomCode, String? batchNo,@NullableDateOnlyConverter() DateTime? productionDate,@NullableDateOnlyConverter() DateTime? expiryDate, Money? unitPrice, String? currency, String? varianceNote
});




}
/// @nodoc
class _$GoodsReceiptLineDtoCopyWithImpl<$Res>
    implements $GoodsReceiptLineDtoCopyWith<$Res> {
  _$GoodsReceiptLineDtoCopyWithImpl(this._self, this._then);

  final GoodsReceiptLineDto _self;
  final $Res Function(GoodsReceiptLineDto) _then;

/// Create a copy of GoodsReceiptLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? productId = null,Object? receivedQty = null,Object? uomId = null,Object? rejectedQty = null,Object? id = freezed,Object? productName = freezed,Object? poLineId = freezed,Object? orderedQty = freezed,Object? uomCode = freezed,Object? batchNo = freezed,Object? productionDate = freezed,Object? expiryDate = freezed,Object? unitPrice = freezed,Object? currency = freezed,Object? varianceNote = freezed,}) {
  return _then(GoodsReceiptLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,rejectedQty: null == rejectedQty ? _self.rejectedQty : rejectedQty // ignore: cast_nullable_to_non_nullable
as Quantity,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,poLineId: freezed == poLineId ? _self.poLineId : poLineId // ignore: cast_nullable_to_non_nullable
as int?,orderedQty: freezed == orderedQty ? _self.orderedQty : orderedQty // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  int productId,  Quantity receivedQty,  int uomId,  Quantity rejectedQty,  int? id,  String? productName,  int? poLineId,  Quantity? orderedQty,  String? uomCode,  String? batchNo, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  Money? unitPrice,  String? currency,  String? varianceNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoodsReceiptLineDto() when $default != null:
return $default(_that.lineNo,_that.productId,_that.receivedQty,_that.uomId,_that.rejectedQty,_that.id,_that.productName,_that.poLineId,_that.orderedQty,_that.uomCode,_that.batchNo,_that.productionDate,_that.expiryDate,_that.unitPrice,_that.currency,_that.varianceNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  int productId,  Quantity receivedQty,  int uomId,  Quantity rejectedQty,  int? id,  String? productName,  int? poLineId,  Quantity? orderedQty,  String? uomCode,  String? batchNo, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  Money? unitPrice,  String? currency,  String? varianceNote)  $default,) {final _that = this;
switch (_that) {
case _GoodsReceiptLineDto():
return $default(_that.lineNo,_that.productId,_that.receivedQty,_that.uomId,_that.rejectedQty,_that.id,_that.productName,_that.poLineId,_that.orderedQty,_that.uomCode,_that.batchNo,_that.productionDate,_that.expiryDate,_that.unitPrice,_that.currency,_that.varianceNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  int productId,  Quantity receivedQty,  int uomId,  Quantity rejectedQty,  int? id,  String? productName,  int? poLineId,  Quantity? orderedQty,  String? uomCode,  String? batchNo, @NullableDateOnlyConverter()  DateTime? productionDate, @NullableDateOnlyConverter()  DateTime? expiryDate,  Money? unitPrice,  String? currency,  String? varianceNote)?  $default,) {final _that = this;
switch (_that) {
case _GoodsReceiptLineDto() when $default != null:
return $default(_that.lineNo,_that.productId,_that.receivedQty,_that.uomId,_that.rejectedQty,_that.id,_that.productName,_that.poLineId,_that.orderedQty,_that.uomCode,_that.batchNo,_that.productionDate,_that.expiryDate,_that.unitPrice,_that.currency,_that.varianceNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoodsReceiptLineDto extends GoodsReceiptLineDto {
  const _GoodsReceiptLineDto({required this.lineNo, required this.productId, required this.receivedQty, required this.uomId, required this.rejectedQty, this.id, this.productName, this.poLineId, this.orderedQty, this.uomCode, this.batchNo, @NullableDateOnlyConverter() this.productionDate, @NullableDateOnlyConverter() this.expiryDate, this.unitPrice, this.currency, this.varianceNote}): super._();
  factory _GoodsReceiptLineDto.fromJson(Map<String, dynamic> json) => _$GoodsReceiptLineDtoFromJson(json);

@override final  int lineNo;
@override final  int productId;
@override final  Quantity receivedQty;
@override final  int uomId;
@override final  Quantity rejectedQty;
@override final  int? id;
@override final  String? productName;
@override final  int? poLineId;
@override final  Quantity? orderedQty;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoodsReceiptLineDto&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.receivedQty, receivedQty) || other.receivedQty == receivedQty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.rejectedQty, rejectedQty) || other.rejectedQty == rejectedQty)&&(identical(other.id, id) || other.id == id)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.poLineId, poLineId) || other.poLineId == poLineId)&&(identical(other.orderedQty, orderedQty) || other.orderedQty == orderedQty)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.batchNo, batchNo) || other.batchNo == batchNo)&&(identical(other.productionDate, productionDate) || other.productionDate == productionDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.varianceNote, varianceNote) || other.varianceNote == varianceNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,productId,receivedQty,uomId,rejectedQty,id,productName,poLineId,orderedQty,uomCode,batchNo,productionDate,expiryDate,unitPrice,currency,varianceNote);
}

@override
String toString() {
    return 'GoodsReceiptLineDto(lineNo: $lineNo, productId: $productId, receivedQty: $receivedQty, uomId: $uomId, rejectedQty: $rejectedQty, id: $id, productName: $productName, poLineId: $poLineId, orderedQty: $orderedQty, uomCode: $uomCode, batchNo: $batchNo, productionDate: $productionDate, expiryDate: $expiryDate, unitPrice: $unitPrice, currency: $currency, varianceNote: $varianceNote)';
}


}

/// @nodoc
abstract mixin class _$GoodsReceiptLineDtoCopyWith<$Res> implements $GoodsReceiptLineDtoCopyWith<$Res> {
  factory _$GoodsReceiptLineDtoCopyWith(_GoodsReceiptLineDto value, $Res Function(_GoodsReceiptLineDto) _then) = __$GoodsReceiptLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, int productId, Quantity receivedQty, int uomId, Quantity rejectedQty, int? id, String? productName, int? poLineId, Quantity? orderedQty, String? uomCode, String? batchNo,@NullableDateOnlyConverter() DateTime? productionDate,@NullableDateOnlyConverter() DateTime? expiryDate, Money? unitPrice, String? currency, String? varianceNote
});




}
/// @nodoc
class __$GoodsReceiptLineDtoCopyWithImpl<$Res>
    implements _$GoodsReceiptLineDtoCopyWith<$Res> {
  __$GoodsReceiptLineDtoCopyWithImpl(this._self, this._then);

  final _GoodsReceiptLineDto _self;
  final $Res Function(_GoodsReceiptLineDto) _then;

/// Create a copy of GoodsReceiptLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? productId = null,Object? receivedQty = null,Object? uomId = null,Object? rejectedQty = null,Object? id = freezed,Object? productName = freezed,Object? poLineId = freezed,Object? orderedQty = freezed,Object? uomCode = freezed,Object? batchNo = freezed,Object? productionDate = freezed,Object? expiryDate = freezed,Object? unitPrice = freezed,Object? currency = freezed,Object? varianceNote = freezed,}) {
  return _then(_GoodsReceiptLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,rejectedQty: null == rejectedQty ? _self.rejectedQty : rejectedQty // ignore: cast_nullable_to_non_nullable
as Quantity,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,poLineId: freezed == poLineId ? _self.poLineId : poLineId // ignore: cast_nullable_to_non_nullable
as int?,orderedQty: freezed == orderedQty ? _self.orderedQty : orderedQty // ignore: cast_nullable_to_non_nullable
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


}


/// @nodoc
mixin _$GoodsReceiptDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; int get supplierId; int get locationId; QualityStatus get qualityStatus; ReceiptStatus get status; int? get poId; String? get poDocNo; String? get supplierName; String? get locationName; Decimal? get temperatureC; String? get packagingNote; int? get movementGroupId; DateTime? get createdAt; int get rowVersion; List<GoodsReceiptLineDto> get lines;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoodsReceiptDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.qualityStatus, _this.qualityStatus) || other.qualityStatus == _this.qualityStatus)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.poId, _this.poId) || other.poId == _this.poId)&&(identical(other.poDocNo, _this.poDocNo) || other.poDocNo == _this.poDocNo)&&(identical(other.supplierName, _this.supplierName) || other.supplierName == _this.supplierName)&&(identical(other.locationName, _this.locationName) || other.locationName == _this.locationName)&&(identical(other.temperatureC, _this.temperatureC) || other.temperatureC == _this.temperatureC)&&(identical(other.packagingNote, _this.packagingNote) || other.packagingNote == _this.packagingNote)&&(identical(other.movementGroupId, _this.movementGroupId) || other.movementGroupId == _this.movementGroupId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoodsReceiptDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.docDate,_this.supplierId,_this.locationId,_this.qualityStatus,_this.status,_this.poId,_this.poDocNo,_this.supplierName,_this.locationName,_this.temperatureC,_this.packagingNote,_this.movementGroupId,_this.createdAt,_this.rowVersion,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as GoodsReceiptDto;
  return 'GoodsReceiptDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, supplierId: ${_this.supplierId}, locationId: ${_this.locationId}, qualityStatus: ${_this.qualityStatus}, status: ${_this.status}, poId: ${_this.poId}, poDocNo: ${_this.poDocNo}, supplierName: ${_this.supplierName}, locationName: ${_this.locationName}, temperatureC: ${_this.temperatureC}, packagingNote: ${_this.packagingNote}, movementGroupId: ${_this.movementGroupId}, createdAt: ${_this.createdAt}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $GoodsReceiptDtoCopyWith<$Res>  {
  factory $GoodsReceiptDtoCopyWith(GoodsReceiptDto value, $Res Function(GoodsReceiptDto) _then) = _$GoodsReceiptDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, int supplierId, int locationId, QualityStatus qualityStatus, ReceiptStatus status, int? poId, String? poDocNo, String? supplierName, String? locationName, Decimal? temperatureC, String? packagingNote, int? movementGroupId, DateTime? createdAt, int rowVersion, List<GoodsReceiptLineDto> lines
});




}
/// @nodoc
class _$GoodsReceiptDtoCopyWithImpl<$Res>
    implements $GoodsReceiptDtoCopyWith<$Res> {
  _$GoodsReceiptDtoCopyWithImpl(this._self, this._then);

  final GoodsReceiptDto _self;
  final $Res Function(GoodsReceiptDto) _then;

/// Create a copy of GoodsReceiptDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? supplierId = null,Object? locationId = null,Object? qualityStatus = null,Object? status = null,Object? poId = freezed,Object? poDocNo = freezed,Object? supplierName = freezed,Object? locationName = freezed,Object? temperatureC = freezed,Object? packagingNote = freezed,Object? movementGroupId = freezed,Object? createdAt = freezed,Object? rowVersion = null,Object? lines = null,}) {
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
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<GoodsReceiptLineDto>,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int supplierId,  int locationId,  QualityStatus qualityStatus,  ReceiptStatus status,  int? poId,  String? poDocNo,  String? supplierName,  String? locationName,  Decimal? temperatureC,  String? packagingNote,  int? movementGroupId,  DateTime? createdAt,  int rowVersion,  List<GoodsReceiptLineDto> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoodsReceiptDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.supplierId,_that.locationId,_that.qualityStatus,_that.status,_that.poId,_that.poDocNo,_that.supplierName,_that.locationName,_that.temperatureC,_that.packagingNote,_that.movementGroupId,_that.createdAt,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int supplierId,  int locationId,  QualityStatus qualityStatus,  ReceiptStatus status,  int? poId,  String? poDocNo,  String? supplierName,  String? locationName,  Decimal? temperatureC,  String? packagingNote,  int? movementGroupId,  DateTime? createdAt,  int rowVersion,  List<GoodsReceiptLineDto> lines)  $default,) {final _that = this;
switch (_that) {
case _GoodsReceiptDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.supplierId,_that.locationId,_that.qualityStatus,_that.status,_that.poId,_that.poDocNo,_that.supplierName,_that.locationName,_that.temperatureC,_that.packagingNote,_that.movementGroupId,_that.createdAt,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int supplierId,  int locationId,  QualityStatus qualityStatus,  ReceiptStatus status,  int? poId,  String? poDocNo,  String? supplierName,  String? locationName,  Decimal? temperatureC,  String? packagingNote,  int? movementGroupId,  DateTime? createdAt,  int rowVersion,  List<GoodsReceiptLineDto> lines)?  $default,) {final _that = this;
switch (_that) {
case _GoodsReceiptDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.supplierId,_that.locationId,_that.qualityStatus,_that.status,_that.poId,_that.poDocNo,_that.supplierName,_that.locationName,_that.temperatureC,_that.packagingNote,_that.movementGroupId,_that.createdAt,_that.rowVersion,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoodsReceiptDto implements GoodsReceiptDto {
  const _GoodsReceiptDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.supplierId, required this.locationId, required this.qualityStatus, required this.status, this.poId, this.poDocNo, this.supplierName, this.locationName, this.temperatureC, this.packagingNote, this.movementGroupId, this.createdAt, this.rowVersion = 1,  List<GoodsReceiptLineDto> lines = const <GoodsReceiptLineDto>[]}): _lines = lines;
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
@override final  DateTime? createdAt;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoodsReceiptDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.qualityStatus, qualityStatus) || other.qualityStatus == qualityStatus)&&(identical(other.status, status) || other.status == status)&&(identical(other.poId, poId) || other.poId == poId)&&(identical(other.poDocNo, poDocNo) || other.poDocNo == poDocNo)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.packagingNote, packagingNote) || other.packagingNote == packagingNote)&&(identical(other.movementGroupId, movementGroupId) || other.movementGroupId == movementGroupId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,docDate,supplierId,locationId,qualityStatus,status,poId,poDocNo,supplierName,locationName,temperatureC,packagingNote,movementGroupId,createdAt,rowVersion,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'GoodsReceiptDto(id: $id, docNo: $docNo, docDate: $docDate, supplierId: $supplierId, locationId: $locationId, qualityStatus: $qualityStatus, status: $status, poId: $poId, poDocNo: $poDocNo, supplierName: $supplierName, locationName: $locationName, temperatureC: $temperatureC, packagingNote: $packagingNote, movementGroupId: $movementGroupId, createdAt: $createdAt, rowVersion: $rowVersion, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$GoodsReceiptDtoCopyWith<$Res> implements $GoodsReceiptDtoCopyWith<$Res> {
  factory _$GoodsReceiptDtoCopyWith(_GoodsReceiptDto value, $Res Function(_GoodsReceiptDto) _then) = __$GoodsReceiptDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, int supplierId, int locationId, QualityStatus qualityStatus, ReceiptStatus status, int? poId, String? poDocNo, String? supplierName, String? locationName, Decimal? temperatureC, String? packagingNote, int? movementGroupId, DateTime? createdAt, int rowVersion, List<GoodsReceiptLineDto> lines
});




}
/// @nodoc
class __$GoodsReceiptDtoCopyWithImpl<$Res>
    implements _$GoodsReceiptDtoCopyWith<$Res> {
  __$GoodsReceiptDtoCopyWithImpl(this._self, this._then);

  final _GoodsReceiptDto _self;
  final $Res Function(_GoodsReceiptDto) _then;

/// Create a copy of GoodsReceiptDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? supplierId = null,Object? locationId = null,Object? qualityStatus = null,Object? status = null,Object? poId = freezed,Object? poDocNo = freezed,Object? supplierName = freezed,Object? locationName = freezed,Object? temperatureC = freezed,Object? packagingNote = freezed,Object? movementGroupId = freezed,Object? createdAt = freezed,Object? rowVersion = null,Object? lines = null,}) {
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
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<GoodsReceiptLineDto>,
  ));
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

 int get lineNo; int get productId; Quantity get qty; int get uomId; Quantity get issuedQty; String? get productName; String? get uomCode; String? get note;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockRequestLineDto&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.issuedQty, _this.issuedQty) || other.issuedQty == _this.issuedQty)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StockRequestLineDto;
  return Object.hash(runtimeType,_this.lineNo,_this.productId,_this.qty,_this.uomId,_this.issuedQty,_this.productName,_this.uomCode,_this.note);
}

@override
String toString() {
  final _this = this as StockRequestLineDto;
  return 'StockRequestLineDto(lineNo: ${_this.lineNo}, productId: ${_this.productId}, qty: ${_this.qty}, uomId: ${_this.uomId}, issuedQty: ${_this.issuedQty}, productName: ${_this.productName}, uomCode: ${_this.uomCode}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $StockRequestLineDtoCopyWith<$Res>  {
  factory $StockRequestLineDtoCopyWith(StockRequestLineDto value, $Res Function(StockRequestLineDto) _then) = _$StockRequestLineDtoCopyWithImpl;
@useResult
$Res call({
 int lineNo, int productId, Quantity qty, int uomId, Quantity issuedQty, String? productName, String? uomCode, String? note
});




}
/// @nodoc
class _$StockRequestLineDtoCopyWithImpl<$Res>
    implements $StockRequestLineDtoCopyWith<$Res> {
  _$StockRequestLineDtoCopyWithImpl(this._self, this._then);

  final StockRequestLineDto _self;
  final $Res Function(StockRequestLineDto) _then;

/// Create a copy of StockRequestLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? productId = null,Object? qty = null,Object? uomId = null,Object? issuedQty = null,Object? productName = freezed,Object? uomCode = freezed,Object? note = freezed,}) {
  return _then(StockRequestLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,issuedQty: null == issuedQty ? _self.issuedQty : issuedQty // ignore: cast_nullable_to_non_nullable
as Quantity,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  int productId,  Quantity qty,  int uomId,  Quantity issuedQty,  String? productName,  String? uomCode,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockRequestLineDto() when $default != null:
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.issuedQty,_that.productName,_that.uomCode,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  int productId,  Quantity qty,  int uomId,  Quantity issuedQty,  String? productName,  String? uomCode,  String? note)  $default,) {final _that = this;
switch (_that) {
case _StockRequestLineDto():
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.issuedQty,_that.productName,_that.uomCode,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  int productId,  Quantity qty,  int uomId,  Quantity issuedQty,  String? productName,  String? uomCode,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _StockRequestLineDto() when $default != null:
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.issuedQty,_that.productName,_that.uomCode,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockRequestLineDto implements StockRequestLineDto {
  const _StockRequestLineDto({required this.lineNo, required this.productId, required this.qty, required this.uomId, required this.issuedQty, this.productName, this.uomCode, this.note});
  factory _StockRequestLineDto.fromJson(Map<String, dynamic> json) => _$StockRequestLineDtoFromJson(json);

@override final  int lineNo;
@override final  int productId;
@override final  Quantity qty;
@override final  int uomId;
@override final  Quantity issuedQty;
@override final  String? productName;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockRequestLineDto&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.issuedQty, issuedQty) || other.issuedQty == issuedQty)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,productId,qty,uomId,issuedQty,productName,uomCode,note);
}

@override
String toString() {
    return 'StockRequestLineDto(lineNo: $lineNo, productId: $productId, qty: $qty, uomId: $uomId, issuedQty: $issuedQty, productName: $productName, uomCode: $uomCode, note: $note)';
}


}

/// @nodoc
abstract mixin class _$StockRequestLineDtoCopyWith<$Res> implements $StockRequestLineDtoCopyWith<$Res> {
  factory _$StockRequestLineDtoCopyWith(_StockRequestLineDto value, $Res Function(_StockRequestLineDto) _then) = __$StockRequestLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, int productId, Quantity qty, int uomId, Quantity issuedQty, String? productName, String? uomCode, String? note
});




}
/// @nodoc
class __$StockRequestLineDtoCopyWithImpl<$Res>
    implements _$StockRequestLineDtoCopyWith<$Res> {
  __$StockRequestLineDtoCopyWithImpl(this._self, this._then);

  final _StockRequestLineDto _self;
  final $Res Function(_StockRequestLineDto) _then;

/// Create a copy of StockRequestLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? productId = null,Object? qty = null,Object? uomId = null,Object? issuedQty = null,Object? productName = freezed,Object? uomCode = freezed,Object? note = freezed,}) {
  return _then(_StockRequestLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,issuedQty: null == issuedQty ? _self.issuedQty : issuedQty // ignore: cast_nullable_to_non_nullable
as Quantity,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StockRequestDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; int get fromLocationId; int get toLocationId; StockRequestStatus get status; String? get fromLocationName; String? get toLocationName;@NullableDateOnlyConverter() DateTime? get requiredDate; String? get note; DateTime? get createdAt; int get rowVersion; List<StockRequestLineDto> get lines;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockRequestDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.fromLocationId, _this.fromLocationId) || other.fromLocationId == _this.fromLocationId)&&(identical(other.toLocationId, _this.toLocationId) || other.toLocationId == _this.toLocationId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.fromLocationName, _this.fromLocationName) || other.fromLocationName == _this.fromLocationName)&&(identical(other.toLocationName, _this.toLocationName) || other.toLocationName == _this.toLocationName)&&(identical(other.requiredDate, _this.requiredDate) || other.requiredDate == _this.requiredDate)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StockRequestDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.docDate,_this.fromLocationId,_this.toLocationId,_this.status,_this.fromLocationName,_this.toLocationName,_this.requiredDate,_this.note,_this.createdAt,_this.rowVersion,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as StockRequestDto;
  return 'StockRequestDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, fromLocationId: ${_this.fromLocationId}, toLocationId: ${_this.toLocationId}, status: ${_this.status}, fromLocationName: ${_this.fromLocationName}, toLocationName: ${_this.toLocationName}, requiredDate: ${_this.requiredDate}, note: ${_this.note}, createdAt: ${_this.createdAt}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $StockRequestDtoCopyWith<$Res>  {
  factory $StockRequestDtoCopyWith(StockRequestDto value, $Res Function(StockRequestDto) _then) = _$StockRequestDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, int fromLocationId, int toLocationId, StockRequestStatus status, String? fromLocationName, String? toLocationName,@NullableDateOnlyConverter() DateTime? requiredDate, String? note, DateTime? createdAt, int rowVersion, List<StockRequestLineDto> lines
});




}
/// @nodoc
class _$StockRequestDtoCopyWithImpl<$Res>
    implements $StockRequestDtoCopyWith<$Res> {
  _$StockRequestDtoCopyWithImpl(this._self, this._then);

  final StockRequestDto _self;
  final $Res Function(StockRequestDto) _then;

/// Create a copy of StockRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? fromLocationId = null,Object? toLocationId = null,Object? status = null,Object? fromLocationName = freezed,Object? toLocationName = freezed,Object? requiredDate = freezed,Object? note = freezed,Object? createdAt = freezed,Object? rowVersion = null,Object? lines = null,}) {
  return _then(StockRequestDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,fromLocationId: null == fromLocationId ? _self.fromLocationId : fromLocationId // ignore: cast_nullable_to_non_nullable
as int,toLocationId: null == toLocationId ? _self.toLocationId : toLocationId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StockRequestStatus,fromLocationName: freezed == fromLocationName ? _self.fromLocationName : fromLocationName // ignore: cast_nullable_to_non_nullable
as String?,toLocationName: freezed == toLocationName ? _self.toLocationName : toLocationName // ignore: cast_nullable_to_non_nullable
as String?,requiredDate: freezed == requiredDate ? _self.requiredDate : requiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<StockRequestLineDto>,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int fromLocationId,  int toLocationId,  StockRequestStatus status,  String? fromLocationName,  String? toLocationName, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note,  DateTime? createdAt,  int rowVersion,  List<StockRequestLineDto> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockRequestDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.fromLocationId,_that.toLocationId,_that.status,_that.fromLocationName,_that.toLocationName,_that.requiredDate,_that.note,_that.createdAt,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int fromLocationId,  int toLocationId,  StockRequestStatus status,  String? fromLocationName,  String? toLocationName, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note,  DateTime? createdAt,  int rowVersion,  List<StockRequestLineDto> lines)  $default,) {final _that = this;
switch (_that) {
case _StockRequestDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.fromLocationId,_that.toLocationId,_that.status,_that.fromLocationName,_that.toLocationName,_that.requiredDate,_that.note,_that.createdAt,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int fromLocationId,  int toLocationId,  StockRequestStatus status,  String? fromLocationName,  String? toLocationName, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note,  DateTime? createdAt,  int rowVersion,  List<StockRequestLineDto> lines)?  $default,) {final _that = this;
switch (_that) {
case _StockRequestDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.fromLocationId,_that.toLocationId,_that.status,_that.fromLocationName,_that.toLocationName,_that.requiredDate,_that.note,_that.createdAt,_that.rowVersion,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockRequestDto implements StockRequestDto {
  const _StockRequestDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.fromLocationId, required this.toLocationId, required this.status, this.fromLocationName, this.toLocationName, @NullableDateOnlyConverter() this.requiredDate, this.note, this.createdAt, this.rowVersion = 1,  List<StockRequestLineDto> lines = const <StockRequestLineDto>[]}): _lines = lines;
  factory _StockRequestDto.fromJson(Map<String, dynamic> json) => _$StockRequestDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override@DateOnlyConverter() final  DateTime docDate;
@override final  int fromLocationId;
@override final  int toLocationId;
@override final  StockRequestStatus status;
@override final  String? fromLocationName;
@override final  String? toLocationName;
@override@NullableDateOnlyConverter() final  DateTime? requiredDate;
@override final  String? note;
@override final  DateTime? createdAt;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockRequestDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.fromLocationId, fromLocationId) || other.fromLocationId == fromLocationId)&&(identical(other.toLocationId, toLocationId) || other.toLocationId == toLocationId)&&(identical(other.status, status) || other.status == status)&&(identical(other.fromLocationName, fromLocationName) || other.fromLocationName == fromLocationName)&&(identical(other.toLocationName, toLocationName) || other.toLocationName == toLocationName)&&(identical(other.requiredDate, requiredDate) || other.requiredDate == requiredDate)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,docDate,fromLocationId,toLocationId,status,fromLocationName,toLocationName,requiredDate,note,createdAt,rowVersion,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'StockRequestDto(id: $id, docNo: $docNo, docDate: $docDate, fromLocationId: $fromLocationId, toLocationId: $toLocationId, status: $status, fromLocationName: $fromLocationName, toLocationName: $toLocationName, requiredDate: $requiredDate, note: $note, createdAt: $createdAt, rowVersion: $rowVersion, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$StockRequestDtoCopyWith<$Res> implements $StockRequestDtoCopyWith<$Res> {
  factory _$StockRequestDtoCopyWith(_StockRequestDto value, $Res Function(_StockRequestDto) _then) = __$StockRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, int fromLocationId, int toLocationId, StockRequestStatus status, String? fromLocationName, String? toLocationName,@NullableDateOnlyConverter() DateTime? requiredDate, String? note, DateTime? createdAt, int rowVersion, List<StockRequestLineDto> lines
});




}
/// @nodoc
class __$StockRequestDtoCopyWithImpl<$Res>
    implements _$StockRequestDtoCopyWith<$Res> {
  __$StockRequestDtoCopyWithImpl(this._self, this._then);

  final _StockRequestDto _self;
  final $Res Function(_StockRequestDto) _then;

/// Create a copy of StockRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? fromLocationId = null,Object? toLocationId = null,Object? status = null,Object? fromLocationName = freezed,Object? toLocationName = freezed,Object? requiredDate = freezed,Object? note = freezed,Object? createdAt = freezed,Object? rowVersion = null,Object? lines = null,}) {
  return _then(_StockRequestDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,fromLocationId: null == fromLocationId ? _self.fromLocationId : fromLocationId // ignore: cast_nullable_to_non_nullable
as int,toLocationId: null == toLocationId ? _self.toLocationId : toLocationId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StockRequestStatus,fromLocationName: freezed == fromLocationName ? _self.fromLocationName : fromLocationName // ignore: cast_nullable_to_non_nullable
as String?,toLocationName: freezed == toLocationName ? _self.toLocationName : toLocationName // ignore: cast_nullable_to_non_nullable
as String?,requiredDate: freezed == requiredDate ? _self.requiredDate : requiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<StockRequestLineDto>,
  ));
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

 int get lineNo; int get productId; Quantity get qty; int get uomId; String? get productName; int? get batchId; String? get batchNo; String? get uomCode; Quantity? get receivedQty; int? get reasonCodeId; String? get note;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueLineDto&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId)&&(identical(other.batchNo, _this.batchNo) || other.batchNo == _this.batchNo)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.receivedQty, _this.receivedQty) || other.receivedQty == _this.receivedQty)&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IssueLineDto;
  return Object.hash(runtimeType,_this.lineNo,_this.productId,_this.qty,_this.uomId,_this.productName,_this.batchId,_this.batchNo,_this.uomCode,_this.receivedQty,_this.reasonCodeId,_this.note);
}

@override
String toString() {
  final _this = this as IssueLineDto;
  return 'IssueLineDto(lineNo: ${_this.lineNo}, productId: ${_this.productId}, qty: ${_this.qty}, uomId: ${_this.uomId}, productName: ${_this.productName}, batchId: ${_this.batchId}, batchNo: ${_this.batchNo}, uomCode: ${_this.uomCode}, receivedQty: ${_this.receivedQty}, reasonCodeId: ${_this.reasonCodeId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $IssueLineDtoCopyWith<$Res>  {
  factory $IssueLineDtoCopyWith(IssueLineDto value, $Res Function(IssueLineDto) _then) = _$IssueLineDtoCopyWithImpl;
@useResult
$Res call({
 int lineNo, int productId, Quantity qty, int uomId, String? productName, int? batchId, String? batchNo, String? uomCode, Quantity? receivedQty, int? reasonCodeId, String? note
});




}
/// @nodoc
class _$IssueLineDtoCopyWithImpl<$Res>
    implements $IssueLineDtoCopyWith<$Res> {
  _$IssueLineDtoCopyWithImpl(this._self, this._then);

  final IssueLineDto _self;
  final $Res Function(IssueLineDto) _then;

/// Create a copy of IssueLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? productId = null,Object? qty = null,Object? uomId = null,Object? productName = freezed,Object? batchId = freezed,Object? batchNo = freezed,Object? uomCode = freezed,Object? receivedQty = freezed,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(IssueLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,receivedQty: freezed == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  int productId,  Quantity qty,  int uomId,  String? productName,  int? batchId,  String? batchNo,  String? uomCode,  Quantity? receivedQty,  int? reasonCodeId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueLineDto() when $default != null:
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.productName,_that.batchId,_that.batchNo,_that.uomCode,_that.receivedQty,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  int productId,  Quantity qty,  int uomId,  String? productName,  int? batchId,  String? batchNo,  String? uomCode,  Quantity? receivedQty,  int? reasonCodeId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _IssueLineDto():
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.productName,_that.batchId,_that.batchNo,_that.uomCode,_that.receivedQty,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  int productId,  Quantity qty,  int uomId,  String? productName,  int? batchId,  String? batchNo,  String? uomCode,  Quantity? receivedQty,  int? reasonCodeId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _IssueLineDto() when $default != null:
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.productName,_that.batchId,_that.batchNo,_that.uomCode,_that.receivedQty,_that.reasonCodeId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueLineDto extends IssueLineDto {
  const _IssueLineDto({required this.lineNo, required this.productId, required this.qty, required this.uomId, this.productName, this.batchId, this.batchNo, this.uomCode, this.receivedQty, this.reasonCodeId, this.note}): super._();
  factory _IssueLineDto.fromJson(Map<String, dynamic> json) => _$IssueLineDtoFromJson(json);

@override final  int lineNo;
@override final  int productId;
@override final  Quantity qty;
@override final  int uomId;
@override final  String? productName;
@override final  int? batchId;
@override final  String? batchNo;
@override final  String? uomCode;
@override final  Quantity? receivedQty;
@override final  int? reasonCodeId;
@override final  String? note;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueLineDto&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.batchNo, batchNo) || other.batchNo == batchNo)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.receivedQty, receivedQty) || other.receivedQty == receivedQty)&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,productId,qty,uomId,productName,batchId,batchNo,uomCode,receivedQty,reasonCodeId,note);
}

@override
String toString() {
    return 'IssueLineDto(lineNo: $lineNo, productId: $productId, qty: $qty, uomId: $uomId, productName: $productName, batchId: $batchId, batchNo: $batchNo, uomCode: $uomCode, receivedQty: $receivedQty, reasonCodeId: $reasonCodeId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$IssueLineDtoCopyWith<$Res> implements $IssueLineDtoCopyWith<$Res> {
  factory _$IssueLineDtoCopyWith(_IssueLineDto value, $Res Function(_IssueLineDto) _then) = __$IssueLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, int productId, Quantity qty, int uomId, String? productName, int? batchId, String? batchNo, String? uomCode, Quantity? receivedQty, int? reasonCodeId, String? note
});




}
/// @nodoc
class __$IssueLineDtoCopyWithImpl<$Res>
    implements _$IssueLineDtoCopyWith<$Res> {
  __$IssueLineDtoCopyWithImpl(this._self, this._then);

  final _IssueLineDto _self;
  final $Res Function(_IssueLineDto) _then;

/// Create a copy of IssueLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? productId = null,Object? qty = null,Object? uomId = null,Object? productName = freezed,Object? batchId = freezed,Object? batchNo = freezed,Object? uomCode = freezed,Object? receivedQty = freezed,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(_IssueLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,receivedQty: freezed == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$IssueDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; IssueType get issueType; int get fromLocationId; int get toLocationId; IssueStatus get status; String? get fromLocationName; String? get toLocationName; int? get requestId; int? get dispatchGroupId; int? get receiptGroupId; DateTime? get dispatchedAt; DateTime? get receivedAt; int? get receivedBy; int get rowVersion; List<IssueLineDto> get lines;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.issueType, _this.issueType) || other.issueType == _this.issueType)&&(identical(other.fromLocationId, _this.fromLocationId) || other.fromLocationId == _this.fromLocationId)&&(identical(other.toLocationId, _this.toLocationId) || other.toLocationId == _this.toLocationId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.fromLocationName, _this.fromLocationName) || other.fromLocationName == _this.fromLocationName)&&(identical(other.toLocationName, _this.toLocationName) || other.toLocationName == _this.toLocationName)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&(identical(other.dispatchGroupId, _this.dispatchGroupId) || other.dispatchGroupId == _this.dispatchGroupId)&&(identical(other.receiptGroupId, _this.receiptGroupId) || other.receiptGroupId == _this.receiptGroupId)&&(identical(other.dispatchedAt, _this.dispatchedAt) || other.dispatchedAt == _this.dispatchedAt)&&(identical(other.receivedAt, _this.receivedAt) || other.receivedAt == _this.receivedAt)&&(identical(other.receivedBy, _this.receivedBy) || other.receivedBy == _this.receivedBy)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IssueDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.docDate,_this.issueType,_this.fromLocationId,_this.toLocationId,_this.status,_this.fromLocationName,_this.toLocationName,_this.requestId,_this.dispatchGroupId,_this.receiptGroupId,_this.dispatchedAt,_this.receivedAt,_this.receivedBy,_this.rowVersion,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as IssueDto;
  return 'IssueDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, issueType: ${_this.issueType}, fromLocationId: ${_this.fromLocationId}, toLocationId: ${_this.toLocationId}, status: ${_this.status}, fromLocationName: ${_this.fromLocationName}, toLocationName: ${_this.toLocationName}, requestId: ${_this.requestId}, dispatchGroupId: ${_this.dispatchGroupId}, receiptGroupId: ${_this.receiptGroupId}, dispatchedAt: ${_this.dispatchedAt}, receivedAt: ${_this.receivedAt}, receivedBy: ${_this.receivedBy}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $IssueDtoCopyWith<$Res>  {
  factory $IssueDtoCopyWith(IssueDto value, $Res Function(IssueDto) _then) = _$IssueDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, IssueType issueType, int fromLocationId, int toLocationId, IssueStatus status, String? fromLocationName, String? toLocationName, int? requestId, int? dispatchGroupId, int? receiptGroupId, DateTime? dispatchedAt, DateTime? receivedAt, int? receivedBy, int rowVersion, List<IssueLineDto> lines
});




}
/// @nodoc
class _$IssueDtoCopyWithImpl<$Res>
    implements $IssueDtoCopyWith<$Res> {
  _$IssueDtoCopyWithImpl(this._self, this._then);

  final IssueDto _self;
  final $Res Function(IssueDto) _then;

/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? issueType = null,Object? fromLocationId = null,Object? toLocationId = null,Object? status = null,Object? fromLocationName = freezed,Object? toLocationName = freezed,Object? requestId = freezed,Object? dispatchGroupId = freezed,Object? receiptGroupId = freezed,Object? dispatchedAt = freezed,Object? receivedAt = freezed,Object? receivedBy = freezed,Object? rowVersion = null,Object? lines = null,}) {
  return _then(IssueDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,issueType: null == issueType ? _self.issueType : issueType // ignore: cast_nullable_to_non_nullable
as IssueType,fromLocationId: null == fromLocationId ? _self.fromLocationId : fromLocationId // ignore: cast_nullable_to_non_nullable
as int,toLocationId: null == toLocationId ? _self.toLocationId : toLocationId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IssueStatus,fromLocationName: freezed == fromLocationName ? _self.fromLocationName : fromLocationName // ignore: cast_nullable_to_non_nullable
as String?,toLocationName: freezed == toLocationName ? _self.toLocationName : toLocationName // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int?,dispatchGroupId: freezed == dispatchGroupId ? _self.dispatchGroupId : dispatchGroupId // ignore: cast_nullable_to_non_nullable
as int?,receiptGroupId: freezed == receiptGroupId ? _self.receiptGroupId : receiptGroupId // ignore: cast_nullable_to_non_nullable
as int?,dispatchedAt: freezed == dispatchedAt ? _self.dispatchedAt : dispatchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receivedAt: freezed == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receivedBy: freezed == receivedBy ? _self.receivedBy : receivedBy // ignore: cast_nullable_to_non_nullable
as int?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<IssueLineDto>,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  IssueType issueType,  int fromLocationId,  int toLocationId,  IssueStatus status,  String? fromLocationName,  String? toLocationName,  int? requestId,  int? dispatchGroupId,  int? receiptGroupId,  DateTime? dispatchedAt,  DateTime? receivedAt,  int? receivedBy,  int rowVersion,  List<IssueLineDto> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.issueType,_that.fromLocationId,_that.toLocationId,_that.status,_that.fromLocationName,_that.toLocationName,_that.requestId,_that.dispatchGroupId,_that.receiptGroupId,_that.dispatchedAt,_that.receivedAt,_that.receivedBy,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  IssueType issueType,  int fromLocationId,  int toLocationId,  IssueStatus status,  String? fromLocationName,  String? toLocationName,  int? requestId,  int? dispatchGroupId,  int? receiptGroupId,  DateTime? dispatchedAt,  DateTime? receivedAt,  int? receivedBy,  int rowVersion,  List<IssueLineDto> lines)  $default,) {final _that = this;
switch (_that) {
case _IssueDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.issueType,_that.fromLocationId,_that.toLocationId,_that.status,_that.fromLocationName,_that.toLocationName,_that.requestId,_that.dispatchGroupId,_that.receiptGroupId,_that.dispatchedAt,_that.receivedAt,_that.receivedBy,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  IssueType issueType,  int fromLocationId,  int toLocationId,  IssueStatus status,  String? fromLocationName,  String? toLocationName,  int? requestId,  int? dispatchGroupId,  int? receiptGroupId,  DateTime? dispatchedAt,  DateTime? receivedAt,  int? receivedBy,  int rowVersion,  List<IssueLineDto> lines)?  $default,) {final _that = this;
switch (_that) {
case _IssueDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.issueType,_that.fromLocationId,_that.toLocationId,_that.status,_that.fromLocationName,_that.toLocationName,_that.requestId,_that.dispatchGroupId,_that.receiptGroupId,_that.dispatchedAt,_that.receivedAt,_that.receivedBy,_that.rowVersion,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueDto implements IssueDto {
  const _IssueDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.issueType, required this.fromLocationId, required this.toLocationId, required this.status, this.fromLocationName, this.toLocationName, this.requestId, this.dispatchGroupId, this.receiptGroupId, this.dispatchedAt, this.receivedAt, this.receivedBy, this.rowVersion = 1,  List<IssueLineDto> lines = const <IssueLineDto>[]}): _lines = lines;
  factory _IssueDto.fromJson(Map<String, dynamic> json) => _$IssueDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override@DateOnlyConverter() final  DateTime docDate;
@override final  IssueType issueType;
@override final  int fromLocationId;
@override final  int toLocationId;
@override final  IssueStatus status;
@override final  String? fromLocationName;
@override final  String? toLocationName;
@override final  int? requestId;
@override final  int? dispatchGroupId;
@override final  int? receiptGroupId;
@override final  DateTime? dispatchedAt;
@override final  DateTime? receivedAt;
@override final  int? receivedBy;
@override@JsonKey() final  int rowVersion;
 final  List<IssueLineDto> _lines;
@override@JsonKey() List<IssueLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.issueType, issueType) || other.issueType == issueType)&&(identical(other.fromLocationId, fromLocationId) || other.fromLocationId == fromLocationId)&&(identical(other.toLocationId, toLocationId) || other.toLocationId == toLocationId)&&(identical(other.status, status) || other.status == status)&&(identical(other.fromLocationName, fromLocationName) || other.fromLocationName == fromLocationName)&&(identical(other.toLocationName, toLocationName) || other.toLocationName == toLocationName)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.dispatchGroupId, dispatchGroupId) || other.dispatchGroupId == dispatchGroupId)&&(identical(other.receiptGroupId, receiptGroupId) || other.receiptGroupId == receiptGroupId)&&(identical(other.dispatchedAt, dispatchedAt) || other.dispatchedAt == dispatchedAt)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.receivedBy, receivedBy) || other.receivedBy == receivedBy)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,docDate,issueType,fromLocationId,toLocationId,status,fromLocationName,toLocationName,requestId,dispatchGroupId,receiptGroupId,dispatchedAt,receivedAt,receivedBy,rowVersion,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'IssueDto(id: $id, docNo: $docNo, docDate: $docDate, issueType: $issueType, fromLocationId: $fromLocationId, toLocationId: $toLocationId, status: $status, fromLocationName: $fromLocationName, toLocationName: $toLocationName, requestId: $requestId, dispatchGroupId: $dispatchGroupId, receiptGroupId: $receiptGroupId, dispatchedAt: $dispatchedAt, receivedAt: $receivedAt, receivedBy: $receivedBy, rowVersion: $rowVersion, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$IssueDtoCopyWith<$Res> implements $IssueDtoCopyWith<$Res> {
  factory _$IssueDtoCopyWith(_IssueDto value, $Res Function(_IssueDto) _then) = __$IssueDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, IssueType issueType, int fromLocationId, int toLocationId, IssueStatus status, String? fromLocationName, String? toLocationName, int? requestId, int? dispatchGroupId, int? receiptGroupId, DateTime? dispatchedAt, DateTime? receivedAt, int? receivedBy, int rowVersion, List<IssueLineDto> lines
});




}
/// @nodoc
class __$IssueDtoCopyWithImpl<$Res>
    implements _$IssueDtoCopyWith<$Res> {
  __$IssueDtoCopyWithImpl(this._self, this._then);

  final _IssueDto _self;
  final $Res Function(_IssueDto) _then;

/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? issueType = null,Object? fromLocationId = null,Object? toLocationId = null,Object? status = null,Object? fromLocationName = freezed,Object? toLocationName = freezed,Object? requestId = freezed,Object? dispatchGroupId = freezed,Object? receiptGroupId = freezed,Object? dispatchedAt = freezed,Object? receivedAt = freezed,Object? receivedBy = freezed,Object? rowVersion = null,Object? lines = null,}) {
  return _then(_IssueDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,issueType: null == issueType ? _self.issueType : issueType // ignore: cast_nullable_to_non_nullable
as IssueType,fromLocationId: null == fromLocationId ? _self.fromLocationId : fromLocationId // ignore: cast_nullable_to_non_nullable
as int,toLocationId: null == toLocationId ? _self.toLocationId : toLocationId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IssueStatus,fromLocationName: freezed == fromLocationName ? _self.fromLocationName : fromLocationName // ignore: cast_nullable_to_non_nullable
as String?,toLocationName: freezed == toLocationName ? _self.toLocationName : toLocationName // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int?,dispatchGroupId: freezed == dispatchGroupId ? _self.dispatchGroupId : dispatchGroupId // ignore: cast_nullable_to_non_nullable
as int?,receiptGroupId: freezed == receiptGroupId ? _self.receiptGroupId : receiptGroupId // ignore: cast_nullable_to_non_nullable
as int?,dispatchedAt: freezed == dispatchedAt ? _self.dispatchedAt : dispatchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receivedAt: freezed == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receivedBy: freezed == receivedBy ? _self.receivedBy : receivedBy // ignore: cast_nullable_to_non_nullable
as int?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<IssueLineDto>,
  ));
}


}


/// @nodoc
mixin _$CreateIssueLine {

 int get productId; Quantity get qty; int get uomId; int? get batchId; int? get reasonCodeId; String? get note;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateIssueLine&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId)&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateIssueLine;
  return Object.hash(runtimeType,_this.productId,_this.qty,_this.uomId,_this.batchId,_this.reasonCodeId,_this.note);
}

@override
String toString() {
  final _this = this as CreateIssueLine;
  return 'CreateIssueLine(productId: ${_this.productId}, qty: ${_this.qty}, uomId: ${_this.uomId}, batchId: ${_this.batchId}, reasonCodeId: ${_this.reasonCodeId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $CreateIssueLineCopyWith<$Res>  {
  factory $CreateIssueLineCopyWith(CreateIssueLine value, $Res Function(CreateIssueLine) _then) = _$CreateIssueLineCopyWithImpl;
@useResult
$Res call({
 int productId, Quantity qty, int uomId, int? batchId, int? reasonCodeId, String? note
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
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? qty = null,Object? uomId = null,Object? batchId = freezed,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(CreateIssueLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  Quantity qty,  int uomId,  int? batchId,  int? reasonCodeId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateIssueLine() when $default != null:
return $default(_that.productId,_that.qty,_that.uomId,_that.batchId,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  Quantity qty,  int uomId,  int? batchId,  int? reasonCodeId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreateIssueLine():
return $default(_that.productId,_that.qty,_that.uomId,_that.batchId,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  Quantity qty,  int uomId,  int? batchId,  int? reasonCodeId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreateIssueLine() when $default != null:
return $default(_that.productId,_that.qty,_that.uomId,_that.batchId,_that.reasonCodeId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateIssueLine implements CreateIssueLine {
  const _CreateIssueLine({required this.productId, required this.qty, required this.uomId, this.batchId, this.reasonCodeId, this.note});
  factory _CreateIssueLine.fromJson(Map<String, dynamic> json) => _$CreateIssueLineFromJson(json);

@override final  int productId;
@override final  Quantity qty;
@override final  int uomId;
@override final  int? batchId;
@override final  int? reasonCodeId;
@override final  String? note;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateIssueLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,qty,uomId,batchId,reasonCodeId,note);
}

@override
String toString() {
    return 'CreateIssueLine(productId: $productId, qty: $qty, uomId: $uomId, batchId: $batchId, reasonCodeId: $reasonCodeId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateIssueLineCopyWith<$Res> implements $CreateIssueLineCopyWith<$Res> {
  factory _$CreateIssueLineCopyWith(_CreateIssueLine value, $Res Function(_CreateIssueLine) _then) = __$CreateIssueLineCopyWithImpl;
@override @useResult
$Res call({
 int productId, Quantity qty, int uomId, int? batchId, int? reasonCodeId, String? note
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
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? qty = null,Object? uomId = null,Object? batchId = freezed,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(_CreateIssueLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateIssueRequest {

@DateOnlyConverter() DateTime get docDate; IssueType get issueType; int get fromLocationId; int get toLocationId; List<CreateIssueLine> get lines; int? get requestId;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateIssueRequest&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.issueType, _this.issueType) || other.issueType == _this.issueType)&&(identical(other.fromLocationId, _this.fromLocationId) || other.fromLocationId == _this.fromLocationId)&&(identical(other.toLocationId, _this.toLocationId) || other.toLocationId == _this.toLocationId)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateIssueRequest;
  return Object.hash(runtimeType,_this.docDate,_this.issueType,_this.fromLocationId,_this.toLocationId,const DeepCollectionEquality().hash(_this.lines),_this.requestId);
}

@override
String toString() {
  final _this = this as CreateIssueRequest;
  return 'CreateIssueRequest(docDate: ${_this.docDate}, issueType: ${_this.issueType}, fromLocationId: ${_this.fromLocationId}, toLocationId: ${_this.toLocationId}, lines: ${_this.lines}, requestId: ${_this.requestId})';
}


}

/// @nodoc
abstract mixin class $CreateIssueRequestCopyWith<$Res>  {
  factory $CreateIssueRequestCopyWith(CreateIssueRequest value, $Res Function(CreateIssueRequest) _then) = _$CreateIssueRequestCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime docDate, IssueType issueType, int fromLocationId, int toLocationId, List<CreateIssueLine> lines, int? requestId
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
@pragma('vm:prefer-inline') @override $Res call({Object? docDate = null,Object? issueType = null,Object? fromLocationId = null,Object? toLocationId = null,Object? lines = null,Object? requestId = freezed,}) {
  return _then(CreateIssueRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,issueType: null == issueType ? _self.issueType : issueType // ignore: cast_nullable_to_non_nullable
as IssueType,fromLocationId: null == fromLocationId ? _self.fromLocationId : fromLocationId // ignore: cast_nullable_to_non_nullable
as int,toLocationId: null == toLocationId ? _self.toLocationId : toLocationId // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateIssueLine>,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  IssueType issueType,  int fromLocationId,  int toLocationId,  List<CreateIssueLine> lines,  int? requestId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateIssueRequest() when $default != null:
return $default(_that.docDate,_that.issueType,_that.fromLocationId,_that.toLocationId,_that.lines,_that.requestId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  IssueType issueType,  int fromLocationId,  int toLocationId,  List<CreateIssueLine> lines,  int? requestId)  $default,) {final _that = this;
switch (_that) {
case _CreateIssueRequest():
return $default(_that.docDate,_that.issueType,_that.fromLocationId,_that.toLocationId,_that.lines,_that.requestId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime docDate,  IssueType issueType,  int fromLocationId,  int toLocationId,  List<CreateIssueLine> lines,  int? requestId)?  $default,) {final _that = this;
switch (_that) {
case _CreateIssueRequest() when $default != null:
return $default(_that.docDate,_that.issueType,_that.fromLocationId,_that.toLocationId,_that.lines,_that.requestId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateIssueRequest implements CreateIssueRequest {
  const _CreateIssueRequest({@DateOnlyConverter() required this.docDate, required this.issueType, required this.fromLocationId, required this.toLocationId, required  List<CreateIssueLine> lines, this.requestId}): _lines = lines;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateIssueRequest&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.issueType, issueType) || other.issueType == issueType)&&(identical(other.fromLocationId, fromLocationId) || other.fromLocationId == fromLocationId)&&(identical(other.toLocationId, toLocationId) || other.toLocationId == toLocationId)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.requestId, requestId) || other.requestId == requestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,docDate,issueType,fromLocationId,toLocationId,const DeepCollectionEquality().hash(_lines),requestId);
}

@override
String toString() {
    return 'CreateIssueRequest(docDate: $docDate, issueType: $issueType, fromLocationId: $fromLocationId, toLocationId: $toLocationId, lines: $lines, requestId: $requestId)';
}


}

/// @nodoc
abstract mixin class _$CreateIssueRequestCopyWith<$Res> implements $CreateIssueRequestCopyWith<$Res> {
  factory _$CreateIssueRequestCopyWith(_CreateIssueRequest value, $Res Function(_CreateIssueRequest) _then) = __$CreateIssueRequestCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime docDate, IssueType issueType, int fromLocationId, int toLocationId, List<CreateIssueLine> lines, int? requestId
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
@override @pragma('vm:prefer-inline') $Res call({Object? docDate = null,Object? issueType = null,Object? fromLocationId = null,Object? toLocationId = null,Object? lines = null,Object? requestId = freezed,}) {
  return _then(_CreateIssueRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,issueType: null == issueType ? _self.issueType : issueType // ignore: cast_nullable_to_non_nullable
as IssueType,fromLocationId: null == fromLocationId ? _self.fromLocationId : fromLocationId // ignore: cast_nullable_to_non_nullable
as int,toLocationId: null == toLocationId ? _self.toLocationId : toLocationId // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateIssueLine>,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ConfirmIssueLine {

 int get lineNo; Quantity get receivedQty; String? get note;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmIssueLine&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.receivedQty, _this.receivedQty) || other.receivedQty == _this.receivedQty)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConfirmIssueLine;
  return Object.hash(runtimeType,_this.lineNo,_this.receivedQty,_this.note);
}

@override
String toString() {
  final _this = this as ConfirmIssueLine;
  return 'ConfirmIssueLine(lineNo: ${_this.lineNo}, receivedQty: ${_this.receivedQty}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $ConfirmIssueLineCopyWith<$Res>  {
  factory $ConfirmIssueLineCopyWith(ConfirmIssueLine value, $Res Function(ConfirmIssueLine) _then) = _$ConfirmIssueLineCopyWithImpl;
@useResult
$Res call({
 int lineNo, Quantity receivedQty, String? note
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
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? receivedQty = null,Object? note = freezed,}) {
  return _then(ConfirmIssueLine(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  Quantity receivedQty,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmIssueLine() when $default != null:
return $default(_that.lineNo,_that.receivedQty,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  Quantity receivedQty,  String? note)  $default,) {final _that = this;
switch (_that) {
case _ConfirmIssueLine():
return $default(_that.lineNo,_that.receivedQty,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  Quantity receivedQty,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmIssueLine() when $default != null:
return $default(_that.lineNo,_that.receivedQty,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfirmIssueLine implements ConfirmIssueLine {
  const _ConfirmIssueLine({required this.lineNo, required this.receivedQty, this.note});
  factory _ConfirmIssueLine.fromJson(Map<String, dynamic> json) => _$ConfirmIssueLineFromJson(json);

@override final  int lineNo;
@override final  Quantity receivedQty;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmIssueLine&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.receivedQty, receivedQty) || other.receivedQty == receivedQty)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,receivedQty,note);
}

@override
String toString() {
    return 'ConfirmIssueLine(lineNo: $lineNo, receivedQty: $receivedQty, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ConfirmIssueLineCopyWith<$Res> implements $ConfirmIssueLineCopyWith<$Res> {
  factory _$ConfirmIssueLineCopyWith(_ConfirmIssueLine value, $Res Function(_ConfirmIssueLine) _then) = __$ConfirmIssueLineCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, Quantity receivedQty, String? note
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
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? receivedQty = null,Object? note = freezed,}) {
  return _then(_ConfirmIssueLine(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ConfirmIssueRequest {

 List<ConfirmIssueLine> get lines; int get rowVersion; String? get note;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmIssueRequest&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConfirmIssueRequest;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.lines),_this.rowVersion,_this.note);
}

@override
String toString() {
  final _this = this as ConfirmIssueRequest;
  return 'ConfirmIssueRequest(lines: ${_this.lines}, rowVersion: ${_this.rowVersion}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $ConfirmIssueRequestCopyWith<$Res>  {
  factory $ConfirmIssueRequestCopyWith(ConfirmIssueRequest value, $Res Function(ConfirmIssueRequest) _then) = _$ConfirmIssueRequestCopyWithImpl;
@useResult
$Res call({
 List<ConfirmIssueLine> lines, int rowVersion, String? note
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
@pragma('vm:prefer-inline') @override $Res call({Object? lines = null,Object? rowVersion = null,Object? note = freezed,}) {
  return _then(ConfirmIssueRequest(
lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<ConfirmIssueLine>,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ConfirmIssueLine> lines,  int rowVersion,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmIssueRequest() when $default != null:
return $default(_that.lines,_that.rowVersion,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ConfirmIssueLine> lines,  int rowVersion,  String? note)  $default,) {final _that = this;
switch (_that) {
case _ConfirmIssueRequest():
return $default(_that.lines,_that.rowVersion,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ConfirmIssueLine> lines,  int rowVersion,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmIssueRequest() when $default != null:
return $default(_that.lines,_that.rowVersion,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfirmIssueRequest implements ConfirmIssueRequest {
  const _ConfirmIssueRequest({required  List<ConfirmIssueLine> lines, required this.rowVersion, this.note}): _lines = lines;
  factory _ConfirmIssueRequest.fromJson(Map<String, dynamic> json) => _$ConfirmIssueRequestFromJson(json);

 final  List<ConfirmIssueLine> _lines;
@override List<ConfirmIssueLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  int rowVersion;
@override final  String? note;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmIssueRequest&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_lines),rowVersion,note);
}

@override
String toString() {
    return 'ConfirmIssueRequest(lines: $lines, rowVersion: $rowVersion, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ConfirmIssueRequestCopyWith<$Res> implements $ConfirmIssueRequestCopyWith<$Res> {
  factory _$ConfirmIssueRequestCopyWith(_ConfirmIssueRequest value, $Res Function(_ConfirmIssueRequest) _then) = __$ConfirmIssueRequestCopyWithImpl;
@override @useResult
$Res call({
 List<ConfirmIssueLine> lines, int rowVersion, String? note
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
@override @pragma('vm:prefer-inline') $Res call({Object? lines = null,Object? rowVersion = null,Object? note = freezed,}) {
  return _then(_ConfirmIssueRequest(
lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<ConfirmIssueLine>,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CountLineDto {

 int get id; int get productId; Quantity get bookQty; String? get productName; String? get baseUomCode; int? get batchId; String? get batchNo; Quantity? get countedQty; Quantity? get varianceQty; Decimal? get variancePct; int? get reasonCodeId; String? get note;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountLineDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.bookQty, _this.bookQty) || other.bookQty == _this.bookQty)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.baseUomCode, _this.baseUomCode) || other.baseUomCode == _this.baseUomCode)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId)&&(identical(other.batchNo, _this.batchNo) || other.batchNo == _this.batchNo)&&(identical(other.countedQty, _this.countedQty) || other.countedQty == _this.countedQty)&&(identical(other.varianceQty, _this.varianceQty) || other.varianceQty == _this.varianceQty)&&(identical(other.variancePct, _this.variancePct) || other.variancePct == _this.variancePct)&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CountLineDto;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.bookQty,_this.productName,_this.baseUomCode,_this.batchId,_this.batchNo,_this.countedQty,_this.varianceQty,_this.variancePct,_this.reasonCodeId,_this.note);
}

@override
String toString() {
  final _this = this as CountLineDto;
  return 'CountLineDto(id: ${_this.id}, productId: ${_this.productId}, bookQty: ${_this.bookQty}, productName: ${_this.productName}, baseUomCode: ${_this.baseUomCode}, batchId: ${_this.batchId}, batchNo: ${_this.batchNo}, countedQty: ${_this.countedQty}, varianceQty: ${_this.varianceQty}, variancePct: ${_this.variancePct}, reasonCodeId: ${_this.reasonCodeId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $CountLineDtoCopyWith<$Res>  {
  factory $CountLineDtoCopyWith(CountLineDto value, $Res Function(CountLineDto) _then) = _$CountLineDtoCopyWithImpl;
@useResult
$Res call({
 int id, int productId, Quantity bookQty, String? productName, String? baseUomCode, int? batchId, String? batchNo, Quantity? countedQty, Quantity? varianceQty, Decimal? variancePct, int? reasonCodeId, String? note
});




}
/// @nodoc
class _$CountLineDtoCopyWithImpl<$Res>
    implements $CountLineDtoCopyWith<$Res> {
  _$CountLineDtoCopyWithImpl(this._self, this._then);

  final CountLineDto _self;
  final $Res Function(CountLineDto) _then;

/// Create a copy of CountLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? bookQty = null,Object? productName = freezed,Object? baseUomCode = freezed,Object? batchId = freezed,Object? batchNo = freezed,Object? countedQty = freezed,Object? varianceQty = freezed,Object? variancePct = freezed,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(CountLineDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,bookQty: null == bookQty ? _self.bookQty : bookQty // ignore: cast_nullable_to_non_nullable
as Quantity,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,countedQty: freezed == countedQty ? _self.countedQty : countedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,varianceQty: freezed == varianceQty ? _self.varianceQty : varianceQty // ignore: cast_nullable_to_non_nullable
as Quantity?,variancePct: freezed == variancePct ? _self.variancePct : variancePct // ignore: cast_nullable_to_non_nullable
as Decimal?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int productId,  Quantity bookQty,  String? productName,  String? baseUomCode,  int? batchId,  String? batchNo,  Quantity? countedQty,  Quantity? varianceQty,  Decimal? variancePct,  int? reasonCodeId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountLineDto() when $default != null:
return $default(_that.id,_that.productId,_that.bookQty,_that.productName,_that.baseUomCode,_that.batchId,_that.batchNo,_that.countedQty,_that.varianceQty,_that.variancePct,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int productId,  Quantity bookQty,  String? productName,  String? baseUomCode,  int? batchId,  String? batchNo,  Quantity? countedQty,  Quantity? varianceQty,  Decimal? variancePct,  int? reasonCodeId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CountLineDto():
return $default(_that.id,_that.productId,_that.bookQty,_that.productName,_that.baseUomCode,_that.batchId,_that.batchNo,_that.countedQty,_that.varianceQty,_that.variancePct,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int productId,  Quantity bookQty,  String? productName,  String? baseUomCode,  int? batchId,  String? batchNo,  Quantity? countedQty,  Quantity? varianceQty,  Decimal? variancePct,  int? reasonCodeId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CountLineDto() when $default != null:
return $default(_that.id,_that.productId,_that.bookQty,_that.productName,_that.baseUomCode,_that.batchId,_that.batchNo,_that.countedQty,_that.varianceQty,_that.variancePct,_that.reasonCodeId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CountLineDto extends CountLineDto {
  const _CountLineDto({required this.id, required this.productId, required this.bookQty, this.productName, this.baseUomCode, this.batchId, this.batchNo, this.countedQty, this.varianceQty, this.variancePct, this.reasonCodeId, this.note}): super._();
  factory _CountLineDto.fromJson(Map<String, dynamic> json) => _$CountLineDtoFromJson(json);

@override final  int id;
@override final  int productId;
@override final  Quantity bookQty;
@override final  String? productName;
@override final  String? baseUomCode;
@override final  int? batchId;
@override final  String? batchNo;
@override final  Quantity? countedQty;
@override final  Quantity? varianceQty;
@override final  Decimal? variancePct;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountLineDto&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.bookQty, bookQty) || other.bookQty == bookQty)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.baseUomCode, baseUomCode) || other.baseUomCode == baseUomCode)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.batchNo, batchNo) || other.batchNo == batchNo)&&(identical(other.countedQty, countedQty) || other.countedQty == countedQty)&&(identical(other.varianceQty, varianceQty) || other.varianceQty == varianceQty)&&(identical(other.variancePct, variancePct) || other.variancePct == variancePct)&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,bookQty,productName,baseUomCode,batchId,batchNo,countedQty,varianceQty,variancePct,reasonCodeId,note);
}

@override
String toString() {
    return 'CountLineDto(id: $id, productId: $productId, bookQty: $bookQty, productName: $productName, baseUomCode: $baseUomCode, batchId: $batchId, batchNo: $batchNo, countedQty: $countedQty, varianceQty: $varianceQty, variancePct: $variancePct, reasonCodeId: $reasonCodeId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CountLineDtoCopyWith<$Res> implements $CountLineDtoCopyWith<$Res> {
  factory _$CountLineDtoCopyWith(_CountLineDto value, $Res Function(_CountLineDto) _then) = __$CountLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int productId, Quantity bookQty, String? productName, String? baseUomCode, int? batchId, String? batchNo, Quantity? countedQty, Quantity? varianceQty, Decimal? variancePct, int? reasonCodeId, String? note
});




}
/// @nodoc
class __$CountLineDtoCopyWithImpl<$Res>
    implements _$CountLineDtoCopyWith<$Res> {
  __$CountLineDtoCopyWithImpl(this._self, this._then);

  final _CountLineDto _self;
  final $Res Function(_CountLineDto) _then;

/// Create a copy of CountLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? bookQty = null,Object? productName = freezed,Object? baseUomCode = freezed,Object? batchId = freezed,Object? batchNo = freezed,Object? countedQty = freezed,Object? varianceQty = freezed,Object? variancePct = freezed,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(_CountLineDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,bookQty: null == bookQty ? _self.bookQty : bookQty // ignore: cast_nullable_to_non_nullable
as Quantity,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,countedQty: freezed == countedQty ? _self.countedQty : countedQty // ignore: cast_nullable_to_non_nullable
as Quantity?,varianceQty: freezed == varianceQty ? _self.varianceQty : varianceQty // ignore: cast_nullable_to_non_nullable
as Quantity?,variancePct: freezed == variancePct ? _self.variancePct : variancePct // ignore: cast_nullable_to_non_nullable
as Decimal?,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CountDto {

 int get id; String get docNo; int get locationId; CountType get countType; CountStatus get status; String? get locationName; DateTime? get frozenAt; int? get approvedBy; DateTime? get approvedAt; int? get adjustGroupId; int get rowVersion; List<CountLineDto> get lines;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.countType, _this.countType) || other.countType == _this.countType)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.locationName, _this.locationName) || other.locationName == _this.locationName)&&(identical(other.frozenAt, _this.frozenAt) || other.frozenAt == _this.frozenAt)&&(identical(other.approvedBy, _this.approvedBy) || other.approvedBy == _this.approvedBy)&&(identical(other.approvedAt, _this.approvedAt) || other.approvedAt == _this.approvedAt)&&(identical(other.adjustGroupId, _this.adjustGroupId) || other.adjustGroupId == _this.adjustGroupId)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CountDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.locationId,_this.countType,_this.status,_this.locationName,_this.frozenAt,_this.approvedBy,_this.approvedAt,_this.adjustGroupId,_this.rowVersion,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as CountDto;
  return 'CountDto(id: ${_this.id}, docNo: ${_this.docNo}, locationId: ${_this.locationId}, countType: ${_this.countType}, status: ${_this.status}, locationName: ${_this.locationName}, frozenAt: ${_this.frozenAt}, approvedBy: ${_this.approvedBy}, approvedAt: ${_this.approvedAt}, adjustGroupId: ${_this.adjustGroupId}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $CountDtoCopyWith<$Res>  {
  factory $CountDtoCopyWith(CountDto value, $Res Function(CountDto) _then) = _$CountDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo, int locationId, CountType countType, CountStatus status, String? locationName, DateTime? frozenAt, int? approvedBy, DateTime? approvedAt, int? adjustGroupId, int rowVersion, List<CountLineDto> lines
});




}
/// @nodoc
class _$CountDtoCopyWithImpl<$Res>
    implements $CountDtoCopyWith<$Res> {
  _$CountDtoCopyWithImpl(this._self, this._then);

  final CountDto _self;
  final $Res Function(CountDto) _then;

/// Create a copy of CountDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? locationId = null,Object? countType = null,Object? status = null,Object? locationName = freezed,Object? frozenAt = freezed,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? adjustGroupId = freezed,Object? rowVersion = null,Object? lines = null,}) {
  return _then(CountDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,countType: null == countType ? _self.countType : countType // ignore: cast_nullable_to_non_nullable
as CountType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CountStatus,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,frozenAt: freezed == frozenAt ? _self.frozenAt : frozenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as int?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,adjustGroupId: freezed == adjustGroupId ? _self.adjustGroupId : adjustGroupId // ignore: cast_nullable_to_non_nullable
as int?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CountLineDto>,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo,  int locationId,  CountType countType,  CountStatus status,  String? locationName,  DateTime? frozenAt,  int? approvedBy,  DateTime? approvedAt,  int? adjustGroupId,  int rowVersion,  List<CountLineDto> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountDto() when $default != null:
return $default(_that.id,_that.docNo,_that.locationId,_that.countType,_that.status,_that.locationName,_that.frozenAt,_that.approvedBy,_that.approvedAt,_that.adjustGroupId,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo,  int locationId,  CountType countType,  CountStatus status,  String? locationName,  DateTime? frozenAt,  int? approvedBy,  DateTime? approvedAt,  int? adjustGroupId,  int rowVersion,  List<CountLineDto> lines)  $default,) {final _that = this;
switch (_that) {
case _CountDto():
return $default(_that.id,_that.docNo,_that.locationId,_that.countType,_that.status,_that.locationName,_that.frozenAt,_that.approvedBy,_that.approvedAt,_that.adjustGroupId,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo,  int locationId,  CountType countType,  CountStatus status,  String? locationName,  DateTime? frozenAt,  int? approvedBy,  DateTime? approvedAt,  int? adjustGroupId,  int rowVersion,  List<CountLineDto> lines)?  $default,) {final _that = this;
switch (_that) {
case _CountDto() when $default != null:
return $default(_that.id,_that.docNo,_that.locationId,_that.countType,_that.status,_that.locationName,_that.frozenAt,_that.approvedBy,_that.approvedAt,_that.adjustGroupId,_that.rowVersion,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CountDto implements CountDto {
  const _CountDto({required this.id, required this.docNo, required this.locationId, required this.countType, required this.status, this.locationName, this.frozenAt, this.approvedBy, this.approvedAt, this.adjustGroupId, this.rowVersion = 1,  List<CountLineDto> lines = const <CountLineDto>[]}): _lines = lines;
  factory _CountDto.fromJson(Map<String, dynamic> json) => _$CountDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override final  int locationId;
@override final  CountType countType;
@override final  CountStatus status;
@override final  String? locationName;
@override final  DateTime? frozenAt;
@override final  int? approvedBy;
@override final  DateTime? approvedAt;
@override final  int? adjustGroupId;
@override@JsonKey() final  int rowVersion;
 final  List<CountLineDto> _lines;
@override@JsonKey() List<CountLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.countType, countType) || other.countType == countType)&&(identical(other.status, status) || other.status == status)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.frozenAt, frozenAt) || other.frozenAt == frozenAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.adjustGroupId, adjustGroupId) || other.adjustGroupId == adjustGroupId)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,locationId,countType,status,locationName,frozenAt,approvedBy,approvedAt,adjustGroupId,rowVersion,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'CountDto(id: $id, docNo: $docNo, locationId: $locationId, countType: $countType, status: $status, locationName: $locationName, frozenAt: $frozenAt, approvedBy: $approvedBy, approvedAt: $approvedAt, adjustGroupId: $adjustGroupId, rowVersion: $rowVersion, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$CountDtoCopyWith<$Res> implements $CountDtoCopyWith<$Res> {
  factory _$CountDtoCopyWith(_CountDto value, $Res Function(_CountDto) _then) = __$CountDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo, int locationId, CountType countType, CountStatus status, String? locationName, DateTime? frozenAt, int? approvedBy, DateTime? approvedAt, int? adjustGroupId, int rowVersion, List<CountLineDto> lines
});




}
/// @nodoc
class __$CountDtoCopyWithImpl<$Res>
    implements _$CountDtoCopyWith<$Res> {
  __$CountDtoCopyWithImpl(this._self, this._then);

  final _CountDto _self;
  final $Res Function(_CountDto) _then;

/// Create a copy of CountDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? locationId = null,Object? countType = null,Object? status = null,Object? locationName = freezed,Object? frozenAt = freezed,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? adjustGroupId = freezed,Object? rowVersion = null,Object? lines = null,}) {
  return _then(_CountDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,countType: null == countType ? _self.countType : countType // ignore: cast_nullable_to_non_nullable
as CountType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CountStatus,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,frozenAt: freezed == frozenAt ? _self.frozenAt : frozenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as int?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,adjustGroupId: freezed == adjustGroupId ? _self.adjustGroupId : adjustGroupId // ignore: cast_nullable_to_non_nullable
as int?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CountLineDto>,
  ));
}


}


/// @nodoc
mixin _$CreateCountRequest {

 int get locationId; CountType get countType;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateCountRequest&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.countType, _this.countType) || other.countType == _this.countType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateCountRequest;
  return Object.hash(runtimeType,_this.locationId,_this.countType);
}

@override
String toString() {
  final _this = this as CreateCountRequest;
  return 'CreateCountRequest(locationId: ${_this.locationId}, countType: ${_this.countType})';
}


}

/// @nodoc
abstract mixin class $CreateCountRequestCopyWith<$Res>  {
  factory $CreateCountRequestCopyWith(CreateCountRequest value, $Res Function(CreateCountRequest) _then) = _$CreateCountRequestCopyWithImpl;
@useResult
$Res call({
 int locationId, CountType countType
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
@pragma('vm:prefer-inline') @override $Res call({Object? locationId = null,Object? countType = null,}) {
  return _then(CreateCountRequest(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,countType: null == countType ? _self.countType : countType // ignore: cast_nullable_to_non_nullable
as CountType,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int locationId,  CountType countType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateCountRequest() when $default != null:
return $default(_that.locationId,_that.countType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int locationId,  CountType countType)  $default,) {final _that = this;
switch (_that) {
case _CreateCountRequest():
return $default(_that.locationId,_that.countType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int locationId,  CountType countType)?  $default,) {final _that = this;
switch (_that) {
case _CreateCountRequest() when $default != null:
return $default(_that.locationId,_that.countType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateCountRequest implements CreateCountRequest {
  const _CreateCountRequest({required this.locationId, required this.countType});
  factory _CreateCountRequest.fromJson(Map<String, dynamic> json) => _$CreateCountRequestFromJson(json);

@override final  int locationId;
@override final  CountType countType;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateCountRequest&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.countType, countType) || other.countType == countType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,locationId,countType);
}

@override
String toString() {
    return 'CreateCountRequest(locationId: $locationId, countType: $countType)';
}


}

/// @nodoc
abstract mixin class _$CreateCountRequestCopyWith<$Res> implements $CreateCountRequestCopyWith<$Res> {
  factory _$CreateCountRequestCopyWith(_CreateCountRequest value, $Res Function(_CreateCountRequest) _then) = __$CreateCountRequestCopyWithImpl;
@override @useResult
$Res call({
 int locationId, CountType countType
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
@override @pragma('vm:prefer-inline') $Res call({Object? locationId = null,Object? countType = null,}) {
  return _then(_CreateCountRequest(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,countType: null == countType ? _self.countType : countType // ignore: cast_nullable_to_non_nullable
as CountType,
  ));
}


}


/// @nodoc
mixin _$EnterCountLine {

 int get lineId; Quantity get countedQty; int? get reasonCodeId; String? get note;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnterCountLine&&(identical(other.lineId, _this.lineId) || other.lineId == _this.lineId)&&(identical(other.countedQty, _this.countedQty) || other.countedQty == _this.countedQty)&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EnterCountLine;
  return Object.hash(runtimeType,_this.lineId,_this.countedQty,_this.reasonCodeId,_this.note);
}

@override
String toString() {
  final _this = this as EnterCountLine;
  return 'EnterCountLine(lineId: ${_this.lineId}, countedQty: ${_this.countedQty}, reasonCodeId: ${_this.reasonCodeId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $EnterCountLineCopyWith<$Res>  {
  factory $EnterCountLineCopyWith(EnterCountLine value, $Res Function(EnterCountLine) _then) = _$EnterCountLineCopyWithImpl;
@useResult
$Res call({
 int lineId, Quantity countedQty, int? reasonCodeId, String? note
});




}
/// @nodoc
class _$EnterCountLineCopyWithImpl<$Res>
    implements $EnterCountLineCopyWith<$Res> {
  _$EnterCountLineCopyWithImpl(this._self, this._then);

  final EnterCountLine _self;
  final $Res Function(EnterCountLine) _then;

/// Create a copy of EnterCountLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineId = null,Object? countedQty = null,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(EnterCountLine(
lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as int,countedQty: null == countedQty ? _self.countedQty : countedQty // ignore: cast_nullable_to_non_nullable
as Quantity,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineId,  Quantity countedQty,  int? reasonCodeId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnterCountLine() when $default != null:
return $default(_that.lineId,_that.countedQty,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineId,  Quantity countedQty,  int? reasonCodeId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _EnterCountLine():
return $default(_that.lineId,_that.countedQty,_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineId,  Quantity countedQty,  int? reasonCodeId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _EnterCountLine() when $default != null:
return $default(_that.lineId,_that.countedQty,_that.reasonCodeId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnterCountLine implements EnterCountLine {
  const _EnterCountLine({required this.lineId, required this.countedQty, this.reasonCodeId, this.note});
  factory _EnterCountLine.fromJson(Map<String, dynamic> json) => _$EnterCountLineFromJson(json);

@override final  int lineId;
@override final  Quantity countedQty;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnterCountLine&&(identical(other.lineId, lineId) || other.lineId == lineId)&&(identical(other.countedQty, countedQty) || other.countedQty == countedQty)&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineId,countedQty,reasonCodeId,note);
}

@override
String toString() {
    return 'EnterCountLine(lineId: $lineId, countedQty: $countedQty, reasonCodeId: $reasonCodeId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$EnterCountLineCopyWith<$Res> implements $EnterCountLineCopyWith<$Res> {
  factory _$EnterCountLineCopyWith(_EnterCountLine value, $Res Function(_EnterCountLine) _then) = __$EnterCountLineCopyWithImpl;
@override @useResult
$Res call({
 int lineId, Quantity countedQty, int? reasonCodeId, String? note
});




}
/// @nodoc
class __$EnterCountLineCopyWithImpl<$Res>
    implements _$EnterCountLineCopyWith<$Res> {
  __$EnterCountLineCopyWithImpl(this._self, this._then);

  final _EnterCountLine _self;
  final $Res Function(_EnterCountLine) _then;

/// Create a copy of EnterCountLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineId = null,Object? countedQty = null,Object? reasonCodeId = freezed,Object? note = freezed,}) {
  return _then(_EnterCountLine(
lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as int,countedQty: null == countedQty ? _self.countedQty : countedQty // ignore: cast_nullable_to_non_nullable
as Quantity,reasonCodeId: freezed == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
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

 int get lineNo; int get productId; Quantity get qty; int get uomId; String? get productName; int? get batchId; String? get batchNo; String? get uomCode; Money? get unitCost; Money? get lineValue;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WasteLineDto&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId)&&(identical(other.batchNo, _this.batchNo) || other.batchNo == _this.batchNo)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.unitCost, _this.unitCost) || other.unitCost == _this.unitCost)&&(identical(other.lineValue, _this.lineValue) || other.lineValue == _this.lineValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WasteLineDto;
  return Object.hash(runtimeType,_this.lineNo,_this.productId,_this.qty,_this.uomId,_this.productName,_this.batchId,_this.batchNo,_this.uomCode,_this.unitCost,_this.lineValue);
}

@override
String toString() {
  final _this = this as WasteLineDto;
  return 'WasteLineDto(lineNo: ${_this.lineNo}, productId: ${_this.productId}, qty: ${_this.qty}, uomId: ${_this.uomId}, productName: ${_this.productName}, batchId: ${_this.batchId}, batchNo: ${_this.batchNo}, uomCode: ${_this.uomCode}, unitCost: ${_this.unitCost}, lineValue: ${_this.lineValue})';
}


}

/// @nodoc
abstract mixin class $WasteLineDtoCopyWith<$Res>  {
  factory $WasteLineDtoCopyWith(WasteLineDto value, $Res Function(WasteLineDto) _then) = _$WasteLineDtoCopyWithImpl;
@useResult
$Res call({
 int lineNo, int productId, Quantity qty, int uomId, String? productName, int? batchId, String? batchNo, String? uomCode, Money? unitCost, Money? lineValue
});




}
/// @nodoc
class _$WasteLineDtoCopyWithImpl<$Res>
    implements $WasteLineDtoCopyWith<$Res> {
  _$WasteLineDtoCopyWithImpl(this._self, this._then);

  final WasteLineDto _self;
  final $Res Function(WasteLineDto) _then;

/// Create a copy of WasteLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? productId = null,Object? qty = null,Object? uomId = null,Object? productName = freezed,Object? batchId = freezed,Object? batchNo = freezed,Object? uomCode = freezed,Object? unitCost = freezed,Object? lineValue = freezed,}) {
  return _then(WasteLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,unitCost: freezed == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as Money?,lineValue: freezed == lineValue ? _self.lineValue : lineValue // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  int productId,  Quantity qty,  int uomId,  String? productName,  int? batchId,  String? batchNo,  String? uomCode,  Money? unitCost,  Money? lineValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WasteLineDto() when $default != null:
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.productName,_that.batchId,_that.batchNo,_that.uomCode,_that.unitCost,_that.lineValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  int productId,  Quantity qty,  int uomId,  String? productName,  int? batchId,  String? batchNo,  String? uomCode,  Money? unitCost,  Money? lineValue)  $default,) {final _that = this;
switch (_that) {
case _WasteLineDto():
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.productName,_that.batchId,_that.batchNo,_that.uomCode,_that.unitCost,_that.lineValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  int productId,  Quantity qty,  int uomId,  String? productName,  int? batchId,  String? batchNo,  String? uomCode,  Money? unitCost,  Money? lineValue)?  $default,) {final _that = this;
switch (_that) {
case _WasteLineDto() when $default != null:
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.productName,_that.batchId,_that.batchNo,_that.uomCode,_that.unitCost,_that.lineValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WasteLineDto implements WasteLineDto {
  const _WasteLineDto({required this.lineNo, required this.productId, required this.qty, required this.uomId, this.productName, this.batchId, this.batchNo, this.uomCode, this.unitCost, this.lineValue});
  factory _WasteLineDto.fromJson(Map<String, dynamic> json) => _$WasteLineDtoFromJson(json);

@override final  int lineNo;
@override final  int productId;
@override final  Quantity qty;
@override final  int uomId;
@override final  String? productName;
@override final  int? batchId;
@override final  String? batchNo;
@override final  String? uomCode;
@override final  Money? unitCost;
@override final  Money? lineValue;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WasteLineDto&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.batchNo, batchNo) || other.batchNo == batchNo)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.unitCost, unitCost) || other.unitCost == unitCost)&&(identical(other.lineValue, lineValue) || other.lineValue == lineValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,productId,qty,uomId,productName,batchId,batchNo,uomCode,unitCost,lineValue);
}

@override
String toString() {
    return 'WasteLineDto(lineNo: $lineNo, productId: $productId, qty: $qty, uomId: $uomId, productName: $productName, batchId: $batchId, batchNo: $batchNo, uomCode: $uomCode, unitCost: $unitCost, lineValue: $lineValue)';
}


}

/// @nodoc
abstract mixin class _$WasteLineDtoCopyWith<$Res> implements $WasteLineDtoCopyWith<$Res> {
  factory _$WasteLineDtoCopyWith(_WasteLineDto value, $Res Function(_WasteLineDto) _then) = __$WasteLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, int productId, Quantity qty, int uomId, String? productName, int? batchId, String? batchNo, String? uomCode, Money? unitCost, Money? lineValue
});




}
/// @nodoc
class __$WasteLineDtoCopyWithImpl<$Res>
    implements _$WasteLineDtoCopyWith<$Res> {
  __$WasteLineDtoCopyWithImpl(this._self, this._then);

  final _WasteLineDto _self;
  final $Res Function(_WasteLineDto) _then;

/// Create a copy of WasteLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? productId = null,Object? qty = null,Object? uomId = null,Object? productName = freezed,Object? batchId = freezed,Object? batchNo = freezed,Object? uomCode = freezed,Object? unitCost = freezed,Object? lineValue = freezed,}) {
  return _then(_WasteLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,unitCost: freezed == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as Money?,lineValue: freezed == lineValue ? _self.lineValue : lineValue // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}


}


/// @nodoc
mixin _$WasteDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; int get locationId; int get reasonCodeId; WasteStatus get status; String? get locationName; String? get reasonCodeName; String? get note; int? get approvedBy; DateTime? get approvedAt; int? get movementGroupId; List<int> get attachmentIds; int get rowVersion; List<WasteLineDto> get lines;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WasteDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.locationName, _this.locationName) || other.locationName == _this.locationName)&&(identical(other.reasonCodeName, _this.reasonCodeName) || other.reasonCodeName == _this.reasonCodeName)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.approvedBy, _this.approvedBy) || other.approvedBy == _this.approvedBy)&&(identical(other.approvedAt, _this.approvedAt) || other.approvedAt == _this.approvedAt)&&(identical(other.movementGroupId, _this.movementGroupId) || other.movementGroupId == _this.movementGroupId)&&const DeepCollectionEquality().equals(other.attachmentIds, _this.attachmentIds)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WasteDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.docDate,_this.locationId,_this.reasonCodeId,_this.status,_this.locationName,_this.reasonCodeName,_this.note,_this.approvedBy,_this.approvedAt,_this.movementGroupId,const DeepCollectionEquality().hash(_this.attachmentIds),_this.rowVersion,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as WasteDto;
  return 'WasteDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, locationId: ${_this.locationId}, reasonCodeId: ${_this.reasonCodeId}, status: ${_this.status}, locationName: ${_this.locationName}, reasonCodeName: ${_this.reasonCodeName}, note: ${_this.note}, approvedBy: ${_this.approvedBy}, approvedAt: ${_this.approvedAt}, movementGroupId: ${_this.movementGroupId}, attachmentIds: ${_this.attachmentIds}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $WasteDtoCopyWith<$Res>  {
  factory $WasteDtoCopyWith(WasteDto value, $Res Function(WasteDto) _then) = _$WasteDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, int locationId, int reasonCodeId, WasteStatus status, String? locationName, String? reasonCodeName, String? note, int? approvedBy, DateTime? approvedAt, int? movementGroupId, List<int> attachmentIds, int rowVersion, List<WasteLineDto> lines
});




}
/// @nodoc
class _$WasteDtoCopyWithImpl<$Res>
    implements $WasteDtoCopyWith<$Res> {
  _$WasteDtoCopyWithImpl(this._self, this._then);

  final WasteDto _self;
  final $Res Function(WasteDto) _then;

/// Create a copy of WasteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? locationId = null,Object? reasonCodeId = null,Object? status = null,Object? locationName = freezed,Object? reasonCodeName = freezed,Object? note = freezed,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? movementGroupId = freezed,Object? attachmentIds = null,Object? rowVersion = null,Object? lines = null,}) {
  return _then(WasteDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,reasonCodeId: null == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WasteStatus,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,reasonCodeName: freezed == reasonCodeName ? _self.reasonCodeName : reasonCodeName // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as int?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,attachmentIds: null == attachmentIds ? _self.attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<WasteLineDto>,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int locationId,  int reasonCodeId,  WasteStatus status,  String? locationName,  String? reasonCodeName,  String? note,  int? approvedBy,  DateTime? approvedAt,  int? movementGroupId,  List<int> attachmentIds,  int rowVersion,  List<WasteLineDto> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WasteDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.locationId,_that.reasonCodeId,_that.status,_that.locationName,_that.reasonCodeName,_that.note,_that.approvedBy,_that.approvedAt,_that.movementGroupId,_that.attachmentIds,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int locationId,  int reasonCodeId,  WasteStatus status,  String? locationName,  String? reasonCodeName,  String? note,  int? approvedBy,  DateTime? approvedAt,  int? movementGroupId,  List<int> attachmentIds,  int rowVersion,  List<WasteLineDto> lines)  $default,) {final _that = this;
switch (_that) {
case _WasteDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.locationId,_that.reasonCodeId,_that.status,_that.locationName,_that.reasonCodeName,_that.note,_that.approvedBy,_that.approvedAt,_that.movementGroupId,_that.attachmentIds,_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int locationId,  int reasonCodeId,  WasteStatus status,  String? locationName,  String? reasonCodeName,  String? note,  int? approvedBy,  DateTime? approvedAt,  int? movementGroupId,  List<int> attachmentIds,  int rowVersion,  List<WasteLineDto> lines)?  $default,) {final _that = this;
switch (_that) {
case _WasteDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.locationId,_that.reasonCodeId,_that.status,_that.locationName,_that.reasonCodeName,_that.note,_that.approvedBy,_that.approvedAt,_that.movementGroupId,_that.attachmentIds,_that.rowVersion,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WasteDto implements WasteDto {
  const _WasteDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.locationId, required this.reasonCodeId, required this.status, this.locationName, this.reasonCodeName, this.note, this.approvedBy, this.approvedAt, this.movementGroupId,  List<int> attachmentIds = const <int>[], this.rowVersion = 1,  List<WasteLineDto> lines = const <WasteLineDto>[]}): _attachmentIds = attachmentIds,_lines = lines;
  factory _WasteDto.fromJson(Map<String, dynamic> json) => _$WasteDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override@DateOnlyConverter() final  DateTime docDate;
@override final  int locationId;
@override final  int reasonCodeId;
@override final  WasteStatus status;
@override final  String? locationName;
@override final  String? reasonCodeName;
@override final  String? note;
@override final  int? approvedBy;
@override final  DateTime? approvedAt;
@override final  int? movementGroupId;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WasteDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&(identical(other.status, status) || other.status == status)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.reasonCodeName, reasonCodeName) || other.reasonCodeName == reasonCodeName)&&(identical(other.note, note) || other.note == note)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.movementGroupId, movementGroupId) || other.movementGroupId == movementGroupId)&&const DeepCollectionEquality().equals(other.attachmentIds, _attachmentIds)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,docDate,locationId,reasonCodeId,status,locationName,reasonCodeName,note,approvedBy,approvedAt,movementGroupId,const DeepCollectionEquality().hash(_attachmentIds),rowVersion,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'WasteDto(id: $id, docNo: $docNo, docDate: $docDate, locationId: $locationId, reasonCodeId: $reasonCodeId, status: $status, locationName: $locationName, reasonCodeName: $reasonCodeName, note: $note, approvedBy: $approvedBy, approvedAt: $approvedAt, movementGroupId: $movementGroupId, attachmentIds: $attachmentIds, rowVersion: $rowVersion, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$WasteDtoCopyWith<$Res> implements $WasteDtoCopyWith<$Res> {
  factory _$WasteDtoCopyWith(_WasteDto value, $Res Function(_WasteDto) _then) = __$WasteDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, int locationId, int reasonCodeId, WasteStatus status, String? locationName, String? reasonCodeName, String? note, int? approvedBy, DateTime? approvedAt, int? movementGroupId, List<int> attachmentIds, int rowVersion, List<WasteLineDto> lines
});




}
/// @nodoc
class __$WasteDtoCopyWithImpl<$Res>
    implements _$WasteDtoCopyWith<$Res> {
  __$WasteDtoCopyWithImpl(this._self, this._then);

  final _WasteDto _self;
  final $Res Function(_WasteDto) _then;

/// Create a copy of WasteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? locationId = null,Object? reasonCodeId = null,Object? status = null,Object? locationName = freezed,Object? reasonCodeName = freezed,Object? note = freezed,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? movementGroupId = freezed,Object? attachmentIds = null,Object? rowVersion = null,Object? lines = null,}) {
  return _then(_WasteDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,reasonCodeId: null == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WasteStatus,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,reasonCodeName: freezed == reasonCodeName ? _self.reasonCodeName : reasonCodeName // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as int?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,attachmentIds: null == attachmentIds ? _self._attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<WasteLineDto>,
  ));
}


}


/// @nodoc
mixin _$CreateWasteLine {

 int get productId; Quantity get qty; int get uomId; int? get batchId;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWasteLine&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateWasteLine;
  return Object.hash(runtimeType,_this.productId,_this.qty,_this.uomId,_this.batchId);
}

@override
String toString() {
  final _this = this as CreateWasteLine;
  return 'CreateWasteLine(productId: ${_this.productId}, qty: ${_this.qty}, uomId: ${_this.uomId}, batchId: ${_this.batchId})';
}


}

/// @nodoc
abstract mixin class $CreateWasteLineCopyWith<$Res>  {
  factory $CreateWasteLineCopyWith(CreateWasteLine value, $Res Function(CreateWasteLine) _then) = _$CreateWasteLineCopyWithImpl;
@useResult
$Res call({
 int productId, Quantity qty, int uomId, int? batchId
});




}
/// @nodoc
class _$CreateWasteLineCopyWithImpl<$Res>
    implements $CreateWasteLineCopyWith<$Res> {
  _$CreateWasteLineCopyWithImpl(this._self, this._then);

  final CreateWasteLine _self;
  final $Res Function(CreateWasteLine) _then;

/// Create a copy of CreateWasteLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? qty = null,Object? uomId = null,Object? batchId = freezed,}) {
  return _then(CreateWasteLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  Quantity qty,  int uomId,  int? batchId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWasteLine() when $default != null:
return $default(_that.productId,_that.qty,_that.uomId,_that.batchId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  Quantity qty,  int uomId,  int? batchId)  $default,) {final _that = this;
switch (_that) {
case _CreateWasteLine():
return $default(_that.productId,_that.qty,_that.uomId,_that.batchId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  Quantity qty,  int uomId,  int? batchId)?  $default,) {final _that = this;
switch (_that) {
case _CreateWasteLine() when $default != null:
return $default(_that.productId,_that.qty,_that.uomId,_that.batchId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWasteLine implements CreateWasteLine {
  const _CreateWasteLine({required this.productId, required this.qty, required this.uomId, this.batchId});
  factory _CreateWasteLine.fromJson(Map<String, dynamic> json) => _$CreateWasteLineFromJson(json);

@override final  int productId;
@override final  Quantity qty;
@override final  int uomId;
@override final  int? batchId;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWasteLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.batchId, batchId) || other.batchId == batchId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,qty,uomId,batchId);
}

@override
String toString() {
    return 'CreateWasteLine(productId: $productId, qty: $qty, uomId: $uomId, batchId: $batchId)';
}


}

/// @nodoc
abstract mixin class _$CreateWasteLineCopyWith<$Res> implements $CreateWasteLineCopyWith<$Res> {
  factory _$CreateWasteLineCopyWith(_CreateWasteLine value, $Res Function(_CreateWasteLine) _then) = __$CreateWasteLineCopyWithImpl;
@override @useResult
$Res call({
 int productId, Quantity qty, int uomId, int? batchId
});




}
/// @nodoc
class __$CreateWasteLineCopyWithImpl<$Res>
    implements _$CreateWasteLineCopyWith<$Res> {
  __$CreateWasteLineCopyWithImpl(this._self, this._then);

  final _CreateWasteLine _self;
  final $Res Function(_CreateWasteLine) _then;

/// Create a copy of CreateWasteLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? qty = null,Object? uomId = null,Object? batchId = freezed,}) {
  return _then(_CreateWasteLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
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

 int get lineNo; int get productId; Quantity get qty; int get uomId; String? get productName; int? get batchId; String? get batchNo; String? get uomCode;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SampleLineDto&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId)&&(identical(other.batchNo, _this.batchNo) || other.batchNo == _this.batchNo)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SampleLineDto;
  return Object.hash(runtimeType,_this.lineNo,_this.productId,_this.qty,_this.uomId,_this.productName,_this.batchId,_this.batchNo,_this.uomCode);
}

@override
String toString() {
  final _this = this as SampleLineDto;
  return 'SampleLineDto(lineNo: ${_this.lineNo}, productId: ${_this.productId}, qty: ${_this.qty}, uomId: ${_this.uomId}, productName: ${_this.productName}, batchId: ${_this.batchId}, batchNo: ${_this.batchNo}, uomCode: ${_this.uomCode})';
}


}

/// @nodoc
abstract mixin class $SampleLineDtoCopyWith<$Res>  {
  factory $SampleLineDtoCopyWith(SampleLineDto value, $Res Function(SampleLineDto) _then) = _$SampleLineDtoCopyWithImpl;
@useResult
$Res call({
 int lineNo, int productId, Quantity qty, int uomId, String? productName, int? batchId, String? batchNo, String? uomCode
});




}
/// @nodoc
class _$SampleLineDtoCopyWithImpl<$Res>
    implements $SampleLineDtoCopyWith<$Res> {
  _$SampleLineDtoCopyWithImpl(this._self, this._then);

  final SampleLineDto _self;
  final $Res Function(SampleLineDto) _then;

/// Create a copy of SampleLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? productId = null,Object? qty = null,Object? uomId = null,Object? productName = freezed,Object? batchId = freezed,Object? batchNo = freezed,Object? uomCode = freezed,}) {
  return _then(SampleLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  int productId,  Quantity qty,  int uomId,  String? productName,  int? batchId,  String? batchNo,  String? uomCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SampleLineDto() when $default != null:
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.productName,_that.batchId,_that.batchNo,_that.uomCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  int productId,  Quantity qty,  int uomId,  String? productName,  int? batchId,  String? batchNo,  String? uomCode)  $default,) {final _that = this;
switch (_that) {
case _SampleLineDto():
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.productName,_that.batchId,_that.batchNo,_that.uomCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  int productId,  Quantity qty,  int uomId,  String? productName,  int? batchId,  String? batchNo,  String? uomCode)?  $default,) {final _that = this;
switch (_that) {
case _SampleLineDto() when $default != null:
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.productName,_that.batchId,_that.batchNo,_that.uomCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SampleLineDto implements SampleLineDto {
  const _SampleLineDto({required this.lineNo, required this.productId, required this.qty, required this.uomId, this.productName, this.batchId, this.batchNo, this.uomCode});
  factory _SampleLineDto.fromJson(Map<String, dynamic> json) => _$SampleLineDtoFromJson(json);

@override final  int lineNo;
@override final  int productId;
@override final  Quantity qty;
@override final  int uomId;
@override final  String? productName;
@override final  int? batchId;
@override final  String? batchNo;
@override final  String? uomCode;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SampleLineDto&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.batchNo, batchNo) || other.batchNo == batchNo)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,productId,qty,uomId,productName,batchId,batchNo,uomCode);
}

@override
String toString() {
    return 'SampleLineDto(lineNo: $lineNo, productId: $productId, qty: $qty, uomId: $uomId, productName: $productName, batchId: $batchId, batchNo: $batchNo, uomCode: $uomCode)';
}


}

/// @nodoc
abstract mixin class _$SampleLineDtoCopyWith<$Res> implements $SampleLineDtoCopyWith<$Res> {
  factory _$SampleLineDtoCopyWith(_SampleLineDto value, $Res Function(_SampleLineDto) _then) = __$SampleLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, int productId, Quantity qty, int uomId, String? productName, int? batchId, String? batchNo, String? uomCode
});




}
/// @nodoc
class __$SampleLineDtoCopyWithImpl<$Res>
    implements _$SampleLineDtoCopyWith<$Res> {
  __$SampleLineDtoCopyWithImpl(this._self, this._then);

  final _SampleLineDto _self;
  final $Res Function(_SampleLineDto) _then;

/// Create a copy of SampleLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? productId = null,Object? qty = null,Object? uomId = null,Object? productName = freezed,Object? batchId = freezed,Object? batchNo = freezed,Object? uomCode = freezed,}) {
  return _then(_SampleLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,batchNo: freezed == batchNo ? _self.batchNo : batchNo // ignore: cast_nullable_to_non_nullable
as String?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SampleDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; int get locationId; String get authority; String? get locationName; String? get purpose; int? get movementGroupId; List<SampleLineDto> get lines;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SampleDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.authority, _this.authority) || other.authority == _this.authority)&&(identical(other.locationName, _this.locationName) || other.locationName == _this.locationName)&&(identical(other.purpose, _this.purpose) || other.purpose == _this.purpose)&&(identical(other.movementGroupId, _this.movementGroupId) || other.movementGroupId == _this.movementGroupId)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SampleDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.docDate,_this.locationId,_this.authority,_this.locationName,_this.purpose,_this.movementGroupId,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as SampleDto;
  return 'SampleDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, locationId: ${_this.locationId}, authority: ${_this.authority}, locationName: ${_this.locationName}, purpose: ${_this.purpose}, movementGroupId: ${_this.movementGroupId}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $SampleDtoCopyWith<$Res>  {
  factory $SampleDtoCopyWith(SampleDto value, $Res Function(SampleDto) _then) = _$SampleDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, int locationId, String authority, String? locationName, String? purpose, int? movementGroupId, List<SampleLineDto> lines
});




}
/// @nodoc
class _$SampleDtoCopyWithImpl<$Res>
    implements $SampleDtoCopyWith<$Res> {
  _$SampleDtoCopyWithImpl(this._self, this._then);

  final SampleDto _self;
  final $Res Function(SampleDto) _then;

/// Create a copy of SampleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? locationId = null,Object? authority = null,Object? locationName = freezed,Object? purpose = freezed,Object? movementGroupId = freezed,Object? lines = null,}) {
  return _then(SampleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,authority: null == authority ? _self.authority : authority // ignore: cast_nullable_to_non_nullable
as String,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<SampleLineDto>,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int locationId,  String authority,  String? locationName,  String? purpose,  int? movementGroupId,  List<SampleLineDto> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SampleDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.locationId,_that.authority,_that.locationName,_that.purpose,_that.movementGroupId,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int locationId,  String authority,  String? locationName,  String? purpose,  int? movementGroupId,  List<SampleLineDto> lines)  $default,) {final _that = this;
switch (_that) {
case _SampleDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.locationId,_that.authority,_that.locationName,_that.purpose,_that.movementGroupId,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  int locationId,  String authority,  String? locationName,  String? purpose,  int? movementGroupId,  List<SampleLineDto> lines)?  $default,) {final _that = this;
switch (_that) {
case _SampleDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.locationId,_that.authority,_that.locationName,_that.purpose,_that.movementGroupId,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SampleDto implements SampleDto {
  const _SampleDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.locationId, this.authority = 'AQTA', this.locationName, this.purpose, this.movementGroupId,  List<SampleLineDto> lines = const <SampleLineDto>[]}): _lines = lines;
  factory _SampleDto.fromJson(Map<String, dynamic> json) => _$SampleDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override@DateOnlyConverter() final  DateTime docDate;
@override final  int locationId;
@override@JsonKey() final  String authority;
@override final  String? locationName;
@override final  String? purpose;
@override final  int? movementGroupId;
 final  List<SampleLineDto> _lines;
@override@JsonKey() List<SampleLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SampleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.authority, authority) || other.authority == authority)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.movementGroupId, movementGroupId) || other.movementGroupId == movementGroupId)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,docDate,locationId,authority,locationName,purpose,movementGroupId,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'SampleDto(id: $id, docNo: $docNo, docDate: $docDate, locationId: $locationId, authority: $authority, locationName: $locationName, purpose: $purpose, movementGroupId: $movementGroupId, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$SampleDtoCopyWith<$Res> implements $SampleDtoCopyWith<$Res> {
  factory _$SampleDtoCopyWith(_SampleDto value, $Res Function(_SampleDto) _then) = __$SampleDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, int locationId, String authority, String? locationName, String? purpose, int? movementGroupId, List<SampleLineDto> lines
});




}
/// @nodoc
class __$SampleDtoCopyWithImpl<$Res>
    implements _$SampleDtoCopyWith<$Res> {
  __$SampleDtoCopyWithImpl(this._self, this._then);

  final _SampleDto _self;
  final $Res Function(_SampleDto) _then;

/// Create a copy of SampleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? locationId = null,Object? authority = null,Object? locationName = freezed,Object? purpose = freezed,Object? movementGroupId = freezed,Object? lines = null,}) {
  return _then(_SampleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,authority: null == authority ? _self.authority : authority // ignore: cast_nullable_to_non_nullable
as String,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<SampleLineDto>,
  ));
}


}


/// @nodoc
mixin _$CreateSampleLine {

 int get productId; Quantity get qty; int get uomId; int? get batchId;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateSampleLine&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateSampleLine;
  return Object.hash(runtimeType,_this.productId,_this.qty,_this.uomId,_this.batchId);
}

@override
String toString() {
  final _this = this as CreateSampleLine;
  return 'CreateSampleLine(productId: ${_this.productId}, qty: ${_this.qty}, uomId: ${_this.uomId}, batchId: ${_this.batchId})';
}


}

/// @nodoc
abstract mixin class $CreateSampleLineCopyWith<$Res>  {
  factory $CreateSampleLineCopyWith(CreateSampleLine value, $Res Function(CreateSampleLine) _then) = _$CreateSampleLineCopyWithImpl;
@useResult
$Res call({
 int productId, Quantity qty, int uomId, int? batchId
});




}
/// @nodoc
class _$CreateSampleLineCopyWithImpl<$Res>
    implements $CreateSampleLineCopyWith<$Res> {
  _$CreateSampleLineCopyWithImpl(this._self, this._then);

  final CreateSampleLine _self;
  final $Res Function(CreateSampleLine) _then;

/// Create a copy of CreateSampleLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? qty = null,Object? uomId = null,Object? batchId = freezed,}) {
  return _then(CreateSampleLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  Quantity qty,  int uomId,  int? batchId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateSampleLine() when $default != null:
return $default(_that.productId,_that.qty,_that.uomId,_that.batchId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  Quantity qty,  int uomId,  int? batchId)  $default,) {final _that = this;
switch (_that) {
case _CreateSampleLine():
return $default(_that.productId,_that.qty,_that.uomId,_that.batchId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  Quantity qty,  int uomId,  int? batchId)?  $default,) {final _that = this;
switch (_that) {
case _CreateSampleLine() when $default != null:
return $default(_that.productId,_that.qty,_that.uomId,_that.batchId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateSampleLine implements CreateSampleLine {
  const _CreateSampleLine({required this.productId, required this.qty, required this.uomId, this.batchId});
  factory _CreateSampleLine.fromJson(Map<String, dynamic> json) => _$CreateSampleLineFromJson(json);

@override final  int productId;
@override final  Quantity qty;
@override final  int uomId;
@override final  int? batchId;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateSampleLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.batchId, batchId) || other.batchId == batchId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,qty,uomId,batchId);
}

@override
String toString() {
    return 'CreateSampleLine(productId: $productId, qty: $qty, uomId: $uomId, batchId: $batchId)';
}


}

/// @nodoc
abstract mixin class _$CreateSampleLineCopyWith<$Res> implements $CreateSampleLineCopyWith<$Res> {
  factory _$CreateSampleLineCopyWith(_CreateSampleLine value, $Res Function(_CreateSampleLine) _then) = __$CreateSampleLineCopyWithImpl;
@override @useResult
$Res call({
 int productId, Quantity qty, int uomId, int? batchId
});




}
/// @nodoc
class __$CreateSampleLineCopyWithImpl<$Res>
    implements _$CreateSampleLineCopyWith<$Res> {
  __$CreateSampleLineCopyWithImpl(this._self, this._then);

  final _CreateSampleLine _self;
  final $Res Function(_CreateSampleLine) _then;

/// Create a copy of CreateSampleLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? qty = null,Object? uomId = null,Object? batchId = freezed,}) {
  return _then(_CreateSampleLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$CreateSampleRequest {

@DateOnlyConverter() DateTime get docDate; int get locationId; List<CreateSampleLine> get lines; String get authority; String? get purpose;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateSampleRequest&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.authority, _this.authority) || other.authority == _this.authority)&&(identical(other.purpose, _this.purpose) || other.purpose == _this.purpose));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateSampleRequest;
  return Object.hash(runtimeType,_this.docDate,_this.locationId,const DeepCollectionEquality().hash(_this.lines),_this.authority,_this.purpose);
}

@override
String toString() {
  final _this = this as CreateSampleRequest;
  return 'CreateSampleRequest(docDate: ${_this.docDate}, locationId: ${_this.locationId}, lines: ${_this.lines}, authority: ${_this.authority}, purpose: ${_this.purpose})';
}


}

/// @nodoc
abstract mixin class $CreateSampleRequestCopyWith<$Res>  {
  factory $CreateSampleRequestCopyWith(CreateSampleRequest value, $Res Function(CreateSampleRequest) _then) = _$CreateSampleRequestCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime docDate, int locationId, List<CreateSampleLine> lines, String authority, String? purpose
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
@pragma('vm:prefer-inline') @override $Res call({Object? docDate = null,Object? locationId = null,Object? lines = null,Object? authority = null,Object? purpose = freezed,}) {
  return _then(CreateSampleRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateSampleLine>,authority: null == authority ? _self.authority : authority // ignore: cast_nullable_to_non_nullable
as String,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  int locationId,  List<CreateSampleLine> lines,  String authority,  String? purpose)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateSampleRequest() when $default != null:
return $default(_that.docDate,_that.locationId,_that.lines,_that.authority,_that.purpose);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  int locationId,  List<CreateSampleLine> lines,  String authority,  String? purpose)  $default,) {final _that = this;
switch (_that) {
case _CreateSampleRequest():
return $default(_that.docDate,_that.locationId,_that.lines,_that.authority,_that.purpose);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime docDate,  int locationId,  List<CreateSampleLine> lines,  String authority,  String? purpose)?  $default,) {final _that = this;
switch (_that) {
case _CreateSampleRequest() when $default != null:
return $default(_that.docDate,_that.locationId,_that.lines,_that.authority,_that.purpose);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateSampleRequest implements CreateSampleRequest {
  const _CreateSampleRequest({@DateOnlyConverter() required this.docDate, required this.locationId, required  List<CreateSampleLine> lines, this.authority = 'AQTA', this.purpose}): _lines = lines;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateSampleRequest&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.authority, authority) || other.authority == authority)&&(identical(other.purpose, purpose) || other.purpose == purpose));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,docDate,locationId,const DeepCollectionEquality().hash(_lines),authority,purpose);
}

@override
String toString() {
    return 'CreateSampleRequest(docDate: $docDate, locationId: $locationId, lines: $lines, authority: $authority, purpose: $purpose)';
}


}

/// @nodoc
abstract mixin class _$CreateSampleRequestCopyWith<$Res> implements $CreateSampleRequestCopyWith<$Res> {
  factory _$CreateSampleRequestCopyWith(_CreateSampleRequest value, $Res Function(_CreateSampleRequest) _then) = __$CreateSampleRequestCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime docDate, int locationId, List<CreateSampleLine> lines, String authority, String? purpose
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
@override @pragma('vm:prefer-inline') $Res call({Object? docDate = null,Object? locationId = null,Object? lines = null,Object? authority = null,Object? purpose = freezed,}) {
  return _then(_CreateSampleRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateSampleLine>,authority: null == authority ? _self.authority : authority // ignore: cast_nullable_to_non_nullable
as String,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,
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
