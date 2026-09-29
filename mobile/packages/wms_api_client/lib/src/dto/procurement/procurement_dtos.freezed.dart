// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'procurement_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequisitionLineDto {

 int get id; int get lineNo; ProductRefDto get product; Quantity get qty; int get uomId; String get uomCode; Quantity get convertedQty; Quantity? get currentStockQty; String? get note;
/// Create a copy of RequisitionLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequisitionLineDtoCopyWith<RequisitionLineDto> get copyWith => _$RequisitionLineDtoCopyWithImpl<RequisitionLineDto>(this as RequisitionLineDto, _$identity);

  /// Serializes this RequisitionLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RequisitionLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequisitionLineDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.convertedQty, _this.convertedQty) || other.convertedQty == _this.convertedQty)&&(identical(other.currentStockQty, _this.currentStockQty) || other.currentStockQty == _this.currentStockQty)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RequisitionLineDto;
  return Object.hash(runtimeType,_this.id,_this.lineNo,_this.product,_this.qty,_this.uomId,_this.uomCode,_this.convertedQty,_this.currentStockQty,_this.note);
}

@override
String toString() {
  final _this = this as RequisitionLineDto;
  return 'RequisitionLineDto(id: ${_this.id}, lineNo: ${_this.lineNo}, product: ${_this.product}, qty: ${_this.qty}, uomId: ${_this.uomId}, uomCode: ${_this.uomCode}, convertedQty: ${_this.convertedQty}, currentStockQty: ${_this.currentStockQty}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $RequisitionLineDtoCopyWith<$Res>  {
  factory $RequisitionLineDtoCopyWith(RequisitionLineDto value, $Res Function(RequisitionLineDto) _then) = _$RequisitionLineDtoCopyWithImpl;
@useResult
$Res call({
 int id, int lineNo, ProductRefDto product, Quantity qty, int uomId, String uomCode, Quantity convertedQty, Quantity? currentStockQty, String? note
});


$ProductRefDtoCopyWith<$Res> get product;

}
/// @nodoc
class _$RequisitionLineDtoCopyWithImpl<$Res>
    implements $RequisitionLineDtoCopyWith<$Res> {
  _$RequisitionLineDtoCopyWithImpl(this._self, this._then);

  final RequisitionLineDto _self;
  final $Res Function(RequisitionLineDto) _then;

/// Create a copy of RequisitionLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? uomCode = null,Object? convertedQty = null,Object? currentStockQty = freezed,Object? note = freezed,}) {
  return _then(RequisitionLineDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,uomCode: null == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String,convertedQty: null == convertedQty ? _self.convertedQty : convertedQty // ignore: cast_nullable_to_non_nullable
as Quantity,currentStockQty: freezed == currentStockQty ? _self.currentStockQty : currentStockQty // ignore: cast_nullable_to_non_nullable
as Quantity?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RequisitionLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [RequisitionLineDto].
extension RequisitionLineDtoPatterns on RequisitionLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequisitionLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequisitionLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequisitionLineDto value)  $default,){
final _that = this;
switch (_that) {
case _RequisitionLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequisitionLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _RequisitionLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  String uomCode,  Quantity convertedQty,  Quantity? currentStockQty,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequisitionLineDto() when $default != null:
return $default(_that.id,_that.lineNo,_that.product,_that.qty,_that.uomId,_that.uomCode,_that.convertedQty,_that.currentStockQty,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  String uomCode,  Quantity convertedQty,  Quantity? currentStockQty,  String? note)  $default,) {final _that = this;
switch (_that) {
case _RequisitionLineDto():
return $default(_that.id,_that.lineNo,_that.product,_that.qty,_that.uomId,_that.uomCode,_that.convertedQty,_that.currentStockQty,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  String uomCode,  Quantity convertedQty,  Quantity? currentStockQty,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _RequisitionLineDto() when $default != null:
return $default(_that.id,_that.lineNo,_that.product,_that.qty,_that.uomId,_that.uomCode,_that.convertedQty,_that.currentStockQty,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequisitionLineDto extends RequisitionLineDto {
  const _RequisitionLineDto({required this.id, required this.lineNo, required this.product, required this.qty, required this.uomId, required this.uomCode, required this.convertedQty, this.currentStockQty, this.note}): super._();
  factory _RequisitionLineDto.fromJson(Map<String, dynamic> json) => _$RequisitionLineDtoFromJson(json);

@override final  int id;
@override final  int lineNo;
@override final  ProductRefDto product;
@override final  Quantity qty;
@override final  int uomId;
@override final  String uomCode;
@override final  Quantity convertedQty;
@override final  Quantity? currentStockQty;
@override final  String? note;

/// Create a copy of RequisitionLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequisitionLineDtoCopyWith<_RequisitionLineDto> get copyWith => __$RequisitionLineDtoCopyWithImpl<_RequisitionLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequisitionLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequisitionLineDto&&(identical(other.id, id) || other.id == id)&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.product, product) || other.product == product)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.convertedQty, convertedQty) || other.convertedQty == convertedQty)&&(identical(other.currentStockQty, currentStockQty) || other.currentStockQty == currentStockQty)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,lineNo,product,qty,uomId,uomCode,convertedQty,currentStockQty,note);
}

@override
String toString() {
    return 'RequisitionLineDto(id: $id, lineNo: $lineNo, product: $product, qty: $qty, uomId: $uomId, uomCode: $uomCode, convertedQty: $convertedQty, currentStockQty: $currentStockQty, note: $note)';
}


}

/// @nodoc
abstract mixin class _$RequisitionLineDtoCopyWith<$Res> implements $RequisitionLineDtoCopyWith<$Res> {
  factory _$RequisitionLineDtoCopyWith(_RequisitionLineDto value, $Res Function(_RequisitionLineDto) _then) = __$RequisitionLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int lineNo, ProductRefDto product, Quantity qty, int uomId, String uomCode, Quantity convertedQty, Quantity? currentStockQty, String? note
});


@override $ProductRefDtoCopyWith<$Res> get product;

}
/// @nodoc
class __$RequisitionLineDtoCopyWithImpl<$Res>
    implements _$RequisitionLineDtoCopyWith<$Res> {
  __$RequisitionLineDtoCopyWithImpl(this._self, this._then);

  final _RequisitionLineDto _self;
  final $Res Function(_RequisitionLineDto) _then;

/// Create a copy of RequisitionLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? uomCode = null,Object? convertedQty = null,Object? currentStockQty = freezed,Object? note = freezed,}) {
  return _then(_RequisitionLineDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,uomCode: null == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String,convertedQty: null == convertedQty ? _self.convertedQty : convertedQty // ignore: cast_nullable_to_non_nullable
as Quantity,currentStockQty: freezed == currentStockQty ? _self.currentStockQty : currentStockQty // ignore: cast_nullable_to_non_nullable
as Quantity?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RequisitionLineDto
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
mixin _$RequisitionDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; LocationRefDto get requesterLocation; ProductType get productType; RequisitionStatus get status; Priority get priority;@NullableDateOnlyConverter() DateTime? get requiredDate; String? get note; String? get rejectComment; int get lineCount; List<int> get rfqIds; List<int> get purchaseOrderIds; List<int> get attachmentIds; UserRefDto? get createdBy; int get rowVersion; List<RequisitionLineDto> get lines; AuditFieldsDto? get audit;
/// Create a copy of RequisitionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequisitionDtoCopyWith<RequisitionDto> get copyWith => _$RequisitionDtoCopyWithImpl<RequisitionDto>(this as RequisitionDto, _$identity);

  /// Serializes this RequisitionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RequisitionDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequisitionDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.requesterLocation, _this.requesterLocation) || other.requesterLocation == _this.requesterLocation)&&(identical(other.productType, _this.productType) || other.productType == _this.productType)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.requiredDate, _this.requiredDate) || other.requiredDate == _this.requiredDate)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.rejectComment, _this.rejectComment) || other.rejectComment == _this.rejectComment)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&const DeepCollectionEquality().equals(other.rfqIds, _this.rfqIds)&&const DeepCollectionEquality().equals(other.purchaseOrderIds, _this.purchaseOrderIds)&&const DeepCollectionEquality().equals(other.attachmentIds, _this.attachmentIds)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.audit, _this.audit) || other.audit == _this.audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RequisitionDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.docDate,_this.requesterLocation,_this.productType,_this.status,_this.priority,_this.requiredDate,_this.note,_this.rejectComment,_this.lineCount,const DeepCollectionEquality().hash(_this.rfqIds),const DeepCollectionEquality().hash(_this.purchaseOrderIds),const DeepCollectionEquality().hash(_this.attachmentIds),_this.createdBy,_this.rowVersion,const DeepCollectionEquality().hash(_this.lines),_this.audit);
}

@override
String toString() {
  final _this = this as RequisitionDto;
  return 'RequisitionDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, requesterLocation: ${_this.requesterLocation}, productType: ${_this.productType}, status: ${_this.status}, priority: ${_this.priority}, requiredDate: ${_this.requiredDate}, note: ${_this.note}, rejectComment: ${_this.rejectComment}, lineCount: ${_this.lineCount}, rfqIds: ${_this.rfqIds}, purchaseOrderIds: ${_this.purchaseOrderIds}, attachmentIds: ${_this.attachmentIds}, createdBy: ${_this.createdBy}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines}, audit: ${_this.audit})';
}


}

/// @nodoc
abstract mixin class $RequisitionDtoCopyWith<$Res>  {
  factory $RequisitionDtoCopyWith(RequisitionDto value, $Res Function(RequisitionDto) _then) = _$RequisitionDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, LocationRefDto requesterLocation, ProductType productType, RequisitionStatus status, Priority priority,@NullableDateOnlyConverter() DateTime? requiredDate, String? note, String? rejectComment, int lineCount, List<int> rfqIds, List<int> purchaseOrderIds, List<int> attachmentIds, UserRefDto? createdBy, int rowVersion, List<RequisitionLineDto> lines, AuditFieldsDto? audit
});


$LocationRefDtoCopyWith<$Res> get requesterLocation;$UserRefDtoCopyWith<$Res>? get createdBy;$AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class _$RequisitionDtoCopyWithImpl<$Res>
    implements $RequisitionDtoCopyWith<$Res> {
  _$RequisitionDtoCopyWithImpl(this._self, this._then);

  final RequisitionDto _self;
  final $Res Function(RequisitionDto) _then;

/// Create a copy of RequisitionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? requesterLocation = null,Object? productType = null,Object? status = null,Object? priority = null,Object? requiredDate = freezed,Object? note = freezed,Object? rejectComment = freezed,Object? lineCount = null,Object? rfqIds = null,Object? purchaseOrderIds = null,Object? attachmentIds = null,Object? createdBy = freezed,Object? rowVersion = null,Object? lines = null,Object? audit = freezed,}) {
  return _then(RequisitionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,requesterLocation: null == requesterLocation ? _self.requesterLocation : requesterLocation // ignore: cast_nullable_to_non_nullable
as LocationRefDto,productType: null == productType ? _self.productType : productType // ignore: cast_nullable_to_non_nullable
as ProductType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequisitionStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,requiredDate: freezed == requiredDate ? _self.requiredDate : requiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,rejectComment: freezed == rejectComment ? _self.rejectComment : rejectComment // ignore: cast_nullable_to_non_nullable
as String?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,rfqIds: null == rfqIds ? _self.rfqIds : rfqIds // ignore: cast_nullable_to_non_nullable
as List<int>,purchaseOrderIds: null == purchaseOrderIds ? _self.purchaseOrderIds : purchaseOrderIds // ignore: cast_nullable_to_non_nullable
as List<int>,attachmentIds: null == attachmentIds ? _self.attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as UserRefDto?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<RequisitionLineDto>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}
/// Create a copy of RequisitionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get requesterLocation {
  
  return $LocationRefDtoCopyWith<$Res>(_self.requesterLocation, (value) {
    return _then(_self.copyWith(requesterLocation: value));
  });
}/// Create a copy of RequisitionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserRefDtoCopyWith<$Res>? get createdBy {
    if (_self.createdBy == null) {
    return null;
  }

  return $UserRefDtoCopyWith<$Res>(_self.createdBy!, (value) {
    return _then(_self.copyWith(createdBy: value));
  });
}/// Create a copy of RequisitionDto
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


/// Adds pattern-matching-related methods to [RequisitionDto].
extension RequisitionDtoPatterns on RequisitionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequisitionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequisitionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequisitionDto value)  $default,){
final _that = this;
switch (_that) {
case _RequisitionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequisitionDto value)?  $default,){
final _that = this;
switch (_that) {
case _RequisitionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  LocationRefDto requesterLocation,  ProductType productType,  RequisitionStatus status,  Priority priority, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note,  String? rejectComment,  int lineCount,  List<int> rfqIds,  List<int> purchaseOrderIds,  List<int> attachmentIds,  UserRefDto? createdBy,  int rowVersion,  List<RequisitionLineDto> lines,  AuditFieldsDto? audit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequisitionDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.requesterLocation,_that.productType,_that.status,_that.priority,_that.requiredDate,_that.note,_that.rejectComment,_that.lineCount,_that.rfqIds,_that.purchaseOrderIds,_that.attachmentIds,_that.createdBy,_that.rowVersion,_that.lines,_that.audit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  LocationRefDto requesterLocation,  ProductType productType,  RequisitionStatus status,  Priority priority, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note,  String? rejectComment,  int lineCount,  List<int> rfqIds,  List<int> purchaseOrderIds,  List<int> attachmentIds,  UserRefDto? createdBy,  int rowVersion,  List<RequisitionLineDto> lines,  AuditFieldsDto? audit)  $default,) {final _that = this;
switch (_that) {
case _RequisitionDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.requesterLocation,_that.productType,_that.status,_that.priority,_that.requiredDate,_that.note,_that.rejectComment,_that.lineCount,_that.rfqIds,_that.purchaseOrderIds,_that.attachmentIds,_that.createdBy,_that.rowVersion,_that.lines,_that.audit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  LocationRefDto requesterLocation,  ProductType productType,  RequisitionStatus status,  Priority priority, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note,  String? rejectComment,  int lineCount,  List<int> rfqIds,  List<int> purchaseOrderIds,  List<int> attachmentIds,  UserRefDto? createdBy,  int rowVersion,  List<RequisitionLineDto> lines,  AuditFieldsDto? audit)?  $default,) {final _that = this;
switch (_that) {
case _RequisitionDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.requesterLocation,_that.productType,_that.status,_that.priority,_that.requiredDate,_that.note,_that.rejectComment,_that.lineCount,_that.rfqIds,_that.purchaseOrderIds,_that.attachmentIds,_that.createdBy,_that.rowVersion,_that.lines,_that.audit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequisitionDto implements RequisitionDto {
  const _RequisitionDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.requesterLocation, required this.productType, required this.status, this.priority = Priority.normal, @NullableDateOnlyConverter() this.requiredDate, this.note, this.rejectComment, this.lineCount = 0,  List<int> rfqIds = const <int>[],  List<int> purchaseOrderIds = const <int>[],  List<int> attachmentIds = const <int>[], this.createdBy, this.rowVersion = 1,  List<RequisitionLineDto> lines = const <RequisitionLineDto>[], this.audit}): _rfqIds = rfqIds,_purchaseOrderIds = purchaseOrderIds,_attachmentIds = attachmentIds,_lines = lines;
  factory _RequisitionDto.fromJson(Map<String, dynamic> json) => _$RequisitionDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override@DateOnlyConverter() final  DateTime docDate;
@override final  LocationRefDto requesterLocation;
@override final  ProductType productType;
@override final  RequisitionStatus status;
@override@JsonKey() final  Priority priority;
@override@NullableDateOnlyConverter() final  DateTime? requiredDate;
@override final  String? note;
@override final  String? rejectComment;
@override@JsonKey() final  int lineCount;
 final  List<int> _rfqIds;
@override@JsonKey() List<int> get rfqIds {
  if (_rfqIds is EqualUnmodifiableListView) return _rfqIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rfqIds);
}

 final  List<int> _purchaseOrderIds;
@override@JsonKey() List<int> get purchaseOrderIds {
  if (_purchaseOrderIds is EqualUnmodifiableListView) return _purchaseOrderIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_purchaseOrderIds);
}

 final  List<int> _attachmentIds;
@override@JsonKey() List<int> get attachmentIds {
  if (_attachmentIds is EqualUnmodifiableListView) return _attachmentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachmentIds);
}

@override final  UserRefDto? createdBy;
@override@JsonKey() final  int rowVersion;
 final  List<RequisitionLineDto> _lines;
@override@JsonKey() List<RequisitionLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  AuditFieldsDto? audit;

/// Create a copy of RequisitionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequisitionDtoCopyWith<_RequisitionDto> get copyWith => __$RequisitionDtoCopyWithImpl<_RequisitionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequisitionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequisitionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.requesterLocation, requesterLocation) || other.requesterLocation == requesterLocation)&&(identical(other.productType, productType) || other.productType == productType)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.requiredDate, requiredDate) || other.requiredDate == requiredDate)&&(identical(other.note, note) || other.note == note)&&(identical(other.rejectComment, rejectComment) || other.rejectComment == rejectComment)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&const DeepCollectionEquality().equals(other.rfqIds, _rfqIds)&&const DeepCollectionEquality().equals(other.purchaseOrderIds, _purchaseOrderIds)&&const DeepCollectionEquality().equals(other.attachmentIds, _attachmentIds)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.audit, audit) || other.audit == audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,docDate,requesterLocation,productType,status,priority,requiredDate,note,rejectComment,lineCount,const DeepCollectionEquality().hash(_rfqIds),const DeepCollectionEquality().hash(_purchaseOrderIds),const DeepCollectionEquality().hash(_attachmentIds),createdBy,rowVersion,const DeepCollectionEquality().hash(_lines),audit);
}

@override
String toString() {
    return 'RequisitionDto(id: $id, docNo: $docNo, docDate: $docDate, requesterLocation: $requesterLocation, productType: $productType, status: $status, priority: $priority, requiredDate: $requiredDate, note: $note, rejectComment: $rejectComment, lineCount: $lineCount, rfqIds: $rfqIds, purchaseOrderIds: $purchaseOrderIds, attachmentIds: $attachmentIds, createdBy: $createdBy, rowVersion: $rowVersion, lines: $lines, audit: $audit)';
}


}

/// @nodoc
abstract mixin class _$RequisitionDtoCopyWith<$Res> implements $RequisitionDtoCopyWith<$Res> {
  factory _$RequisitionDtoCopyWith(_RequisitionDto value, $Res Function(_RequisitionDto) _then) = __$RequisitionDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, LocationRefDto requesterLocation, ProductType productType, RequisitionStatus status, Priority priority,@NullableDateOnlyConverter() DateTime? requiredDate, String? note, String? rejectComment, int lineCount, List<int> rfqIds, List<int> purchaseOrderIds, List<int> attachmentIds, UserRefDto? createdBy, int rowVersion, List<RequisitionLineDto> lines, AuditFieldsDto? audit
});


@override $LocationRefDtoCopyWith<$Res> get requesterLocation;@override $UserRefDtoCopyWith<$Res>? get createdBy;@override $AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class __$RequisitionDtoCopyWithImpl<$Res>
    implements _$RequisitionDtoCopyWith<$Res> {
  __$RequisitionDtoCopyWithImpl(this._self, this._then);

  final _RequisitionDto _self;
  final $Res Function(_RequisitionDto) _then;

/// Create a copy of RequisitionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? requesterLocation = null,Object? productType = null,Object? status = null,Object? priority = null,Object? requiredDate = freezed,Object? note = freezed,Object? rejectComment = freezed,Object? lineCount = null,Object? rfqIds = null,Object? purchaseOrderIds = null,Object? attachmentIds = null,Object? createdBy = freezed,Object? rowVersion = null,Object? lines = null,Object? audit = freezed,}) {
  return _then(_RequisitionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,requesterLocation: null == requesterLocation ? _self.requesterLocation : requesterLocation // ignore: cast_nullable_to_non_nullable
as LocationRefDto,productType: null == productType ? _self.productType : productType // ignore: cast_nullable_to_non_nullable
as ProductType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequisitionStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,requiredDate: freezed == requiredDate ? _self.requiredDate : requiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,rejectComment: freezed == rejectComment ? _self.rejectComment : rejectComment // ignore: cast_nullable_to_non_nullable
as String?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,rfqIds: null == rfqIds ? _self._rfqIds : rfqIds // ignore: cast_nullable_to_non_nullable
as List<int>,purchaseOrderIds: null == purchaseOrderIds ? _self._purchaseOrderIds : purchaseOrderIds // ignore: cast_nullable_to_non_nullable
as List<int>,attachmentIds: null == attachmentIds ? _self._attachmentIds : attachmentIds // ignore: cast_nullable_to_non_nullable
as List<int>,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as UserRefDto?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<RequisitionLineDto>,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}

/// Create a copy of RequisitionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get requesterLocation {
  
  return $LocationRefDtoCopyWith<$Res>(_self.requesterLocation, (value) {
    return _then(_self.copyWith(requesterLocation: value));
  });
}/// Create a copy of RequisitionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserRefDtoCopyWith<$Res>? get createdBy {
    if (_self.createdBy == null) {
    return null;
  }

  return $UserRefDtoCopyWith<$Res>(_self.createdBy!, (value) {
    return _then(_self.copyWith(createdBy: value));
  });
}/// Create a copy of RequisitionDto
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
mixin _$CreateRequisitionLine {

 int get productId; Quantity get qty; int get uomId; String? get note;
/// Create a copy of CreateRequisitionLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateRequisitionLineCopyWith<CreateRequisitionLine> get copyWith => _$CreateRequisitionLineCopyWithImpl<CreateRequisitionLine>(this as CreateRequisitionLine, _$identity);

  /// Serializes this CreateRequisitionLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateRequisitionLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateRequisitionLine&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateRequisitionLine;
  return Object.hash(runtimeType,_this.productId,_this.qty,_this.uomId,_this.note);
}

@override
String toString() {
  final _this = this as CreateRequisitionLine;
  return 'CreateRequisitionLine(productId: ${_this.productId}, qty: ${_this.qty}, uomId: ${_this.uomId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $CreateRequisitionLineCopyWith<$Res>  {
  factory $CreateRequisitionLineCopyWith(CreateRequisitionLine value, $Res Function(CreateRequisitionLine) _then) = _$CreateRequisitionLineCopyWithImpl;
@useResult
$Res call({
 int productId, Quantity qty, int uomId, String? note
});




}
/// @nodoc
class _$CreateRequisitionLineCopyWithImpl<$Res>
    implements $CreateRequisitionLineCopyWith<$Res> {
  _$CreateRequisitionLineCopyWithImpl(this._self, this._then);

  final CreateRequisitionLine _self;
  final $Res Function(CreateRequisitionLine) _then;

/// Create a copy of CreateRequisitionLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? qty = null,Object? uomId = null,Object? note = freezed,}) {
  return _then(CreateRequisitionLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateRequisitionLine].
extension CreateRequisitionLinePatterns on CreateRequisitionLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateRequisitionLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateRequisitionLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateRequisitionLine value)  $default,){
final _that = this;
switch (_that) {
case _CreateRequisitionLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateRequisitionLine value)?  $default,){
final _that = this;
switch (_that) {
case _CreateRequisitionLine() when $default != null:
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
case _CreateRequisitionLine() when $default != null:
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
case _CreateRequisitionLine():
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
case _CreateRequisitionLine() when $default != null:
return $default(_that.productId,_that.qty,_that.uomId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateRequisitionLine implements CreateRequisitionLine {
  const _CreateRequisitionLine({required this.productId, required this.qty, required this.uomId, this.note});
  factory _CreateRequisitionLine.fromJson(Map<String, dynamic> json) => _$CreateRequisitionLineFromJson(json);

@override final  int productId;
@override final  Quantity qty;
@override final  int uomId;
@override final  String? note;

/// Create a copy of CreateRequisitionLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateRequisitionLineCopyWith<_CreateRequisitionLine> get copyWith => __$CreateRequisitionLineCopyWithImpl<_CreateRequisitionLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateRequisitionLineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateRequisitionLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,qty,uomId,note);
}

@override
String toString() {
    return 'CreateRequisitionLine(productId: $productId, qty: $qty, uomId: $uomId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateRequisitionLineCopyWith<$Res> implements $CreateRequisitionLineCopyWith<$Res> {
  factory _$CreateRequisitionLineCopyWith(_CreateRequisitionLine value, $Res Function(_CreateRequisitionLine) _then) = __$CreateRequisitionLineCopyWithImpl;
@override @useResult
$Res call({
 int productId, Quantity qty, int uomId, String? note
});




}
/// @nodoc
class __$CreateRequisitionLineCopyWithImpl<$Res>
    implements _$CreateRequisitionLineCopyWith<$Res> {
  __$CreateRequisitionLineCopyWithImpl(this._self, this._then);

  final _CreateRequisitionLine _self;
  final $Res Function(_CreateRequisitionLine) _then;

/// Create a copy of CreateRequisitionLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? qty = null,Object? uomId = null,Object? note = freezed,}) {
  return _then(_CreateRequisitionLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateRequisitionRequest {

@DateOnlyConverter() DateTime get docDate; int get requesterLocationId; ProductType get productType; List<CreateRequisitionLine> get lines; Priority get priority;@NullableDateOnlyConverter() DateTime? get requiredDate; String? get note;
/// Create a copy of CreateRequisitionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateRequisitionRequestCopyWith<CreateRequisitionRequest> get copyWith => _$CreateRequisitionRequestCopyWithImpl<CreateRequisitionRequest>(this as CreateRequisitionRequest, _$identity);

  /// Serializes this CreateRequisitionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateRequisitionRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateRequisitionRequest&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.requesterLocationId, _this.requesterLocationId) || other.requesterLocationId == _this.requesterLocationId)&&(identical(other.productType, _this.productType) || other.productType == _this.productType)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.requiredDate, _this.requiredDate) || other.requiredDate == _this.requiredDate)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateRequisitionRequest;
  return Object.hash(runtimeType,_this.docDate,_this.requesterLocationId,_this.productType,const DeepCollectionEquality().hash(_this.lines),_this.priority,_this.requiredDate,_this.note);
}

@override
String toString() {
  final _this = this as CreateRequisitionRequest;
  return 'CreateRequisitionRequest(docDate: ${_this.docDate}, requesterLocationId: ${_this.requesterLocationId}, productType: ${_this.productType}, lines: ${_this.lines}, priority: ${_this.priority}, requiredDate: ${_this.requiredDate}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $CreateRequisitionRequestCopyWith<$Res>  {
  factory $CreateRequisitionRequestCopyWith(CreateRequisitionRequest value, $Res Function(CreateRequisitionRequest) _then) = _$CreateRequisitionRequestCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime docDate, int requesterLocationId, ProductType productType, List<CreateRequisitionLine> lines, Priority priority,@NullableDateOnlyConverter() DateTime? requiredDate, String? note
});




}
/// @nodoc
class _$CreateRequisitionRequestCopyWithImpl<$Res>
    implements $CreateRequisitionRequestCopyWith<$Res> {
  _$CreateRequisitionRequestCopyWithImpl(this._self, this._then);

  final CreateRequisitionRequest _self;
  final $Res Function(CreateRequisitionRequest) _then;

/// Create a copy of CreateRequisitionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? docDate = null,Object? requesterLocationId = null,Object? productType = null,Object? lines = null,Object? priority = null,Object? requiredDate = freezed,Object? note = freezed,}) {
  return _then(CreateRequisitionRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,requesterLocationId: null == requesterLocationId ? _self.requesterLocationId : requesterLocationId // ignore: cast_nullable_to_non_nullable
as int,productType: null == productType ? _self.productType : productType // ignore: cast_nullable_to_non_nullable
as ProductType,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateRequisitionLine>,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,requiredDate: freezed == requiredDate ? _self.requiredDate : requiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateRequisitionRequest].
extension CreateRequisitionRequestPatterns on CreateRequisitionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateRequisitionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateRequisitionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateRequisitionRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateRequisitionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateRequisitionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateRequisitionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  int requesterLocationId,  ProductType productType,  List<CreateRequisitionLine> lines,  Priority priority, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateRequisitionRequest() when $default != null:
return $default(_that.docDate,_that.requesterLocationId,_that.productType,_that.lines,_that.priority,_that.requiredDate,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime docDate,  int requesterLocationId,  ProductType productType,  List<CreateRequisitionLine> lines,  Priority priority, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreateRequisitionRequest():
return $default(_that.docDate,_that.requesterLocationId,_that.productType,_that.lines,_that.priority,_that.requiredDate,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime docDate,  int requesterLocationId,  ProductType productType,  List<CreateRequisitionLine> lines,  Priority priority, @NullableDateOnlyConverter()  DateTime? requiredDate,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreateRequisitionRequest() when $default != null:
return $default(_that.docDate,_that.requesterLocationId,_that.productType,_that.lines,_that.priority,_that.requiredDate,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateRequisitionRequest implements CreateRequisitionRequest {
  const _CreateRequisitionRequest({@DateOnlyConverter() required this.docDate, required this.requesterLocationId, required this.productType, required  List<CreateRequisitionLine> lines, this.priority = Priority.normal, @NullableDateOnlyConverter() this.requiredDate, this.note}): _lines = lines;
  factory _CreateRequisitionRequest.fromJson(Map<String, dynamic> json) => _$CreateRequisitionRequestFromJson(json);

@override@DateOnlyConverter() final  DateTime docDate;
@override final  int requesterLocationId;
@override final  ProductType productType;
 final  List<CreateRequisitionLine> _lines;
@override List<CreateRequisitionLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override@JsonKey() final  Priority priority;
@override@NullableDateOnlyConverter() final  DateTime? requiredDate;
@override final  String? note;

/// Create a copy of CreateRequisitionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateRequisitionRequestCopyWith<_CreateRequisitionRequest> get copyWith => __$CreateRequisitionRequestCopyWithImpl<_CreateRequisitionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateRequisitionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateRequisitionRequest&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.requesterLocationId, requesterLocationId) || other.requesterLocationId == requesterLocationId)&&(identical(other.productType, productType) || other.productType == productType)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.requiredDate, requiredDate) || other.requiredDate == requiredDate)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,docDate,requesterLocationId,productType,const DeepCollectionEquality().hash(_lines),priority,requiredDate,note);
}

@override
String toString() {
    return 'CreateRequisitionRequest(docDate: $docDate, requesterLocationId: $requesterLocationId, productType: $productType, lines: $lines, priority: $priority, requiredDate: $requiredDate, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateRequisitionRequestCopyWith<$Res> implements $CreateRequisitionRequestCopyWith<$Res> {
  factory _$CreateRequisitionRequestCopyWith(_CreateRequisitionRequest value, $Res Function(_CreateRequisitionRequest) _then) = __$CreateRequisitionRequestCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime docDate, int requesterLocationId, ProductType productType, List<CreateRequisitionLine> lines, Priority priority,@NullableDateOnlyConverter() DateTime? requiredDate, String? note
});




}
/// @nodoc
class __$CreateRequisitionRequestCopyWithImpl<$Res>
    implements _$CreateRequisitionRequestCopyWith<$Res> {
  __$CreateRequisitionRequestCopyWithImpl(this._self, this._then);

  final _CreateRequisitionRequest _self;
  final $Res Function(_CreateRequisitionRequest) _then;

/// Create a copy of CreateRequisitionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? docDate = null,Object? requesterLocationId = null,Object? productType = null,Object? lines = null,Object? priority = null,Object? requiredDate = freezed,Object? note = freezed,}) {
  return _then(_CreateRequisitionRequest(
docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,requesterLocationId: null == requesterLocationId ? _self.requesterLocationId : requesterLocationId // ignore: cast_nullable_to_non_nullable
as int,productType: null == productType ? _self.productType : productType // ignore: cast_nullable_to_non_nullable
as ProductType,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CreateRequisitionLine>,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,requiredDate: freezed == requiredDate ? _self.requiredDate : requiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RfqLineDto {

 int get id; int get lineNo; ProductRefDto get product; Quantity get qty; int get uomId; String get uomCode; int? get requisitionLineId; String? get note;
/// Create a copy of RfqLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RfqLineDtoCopyWith<RfqLineDto> get copyWith => _$RfqLineDtoCopyWithImpl<RfqLineDto>(this as RfqLineDto, _$identity);

  /// Serializes this RfqLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RfqLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RfqLineDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.requisitionLineId, _this.requisitionLineId) || other.requisitionLineId == _this.requisitionLineId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RfqLineDto;
  return Object.hash(runtimeType,_this.id,_this.lineNo,_this.product,_this.qty,_this.uomId,_this.uomCode,_this.requisitionLineId,_this.note);
}

@override
String toString() {
  final _this = this as RfqLineDto;
  return 'RfqLineDto(id: ${_this.id}, lineNo: ${_this.lineNo}, product: ${_this.product}, qty: ${_this.qty}, uomId: ${_this.uomId}, uomCode: ${_this.uomCode}, requisitionLineId: ${_this.requisitionLineId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $RfqLineDtoCopyWith<$Res>  {
  factory $RfqLineDtoCopyWith(RfqLineDto value, $Res Function(RfqLineDto) _then) = _$RfqLineDtoCopyWithImpl;
@useResult
$Res call({
 int id, int lineNo, ProductRefDto product, Quantity qty, int uomId, String uomCode, int? requisitionLineId, String? note
});


$ProductRefDtoCopyWith<$Res> get product;

}
/// @nodoc
class _$RfqLineDtoCopyWithImpl<$Res>
    implements $RfqLineDtoCopyWith<$Res> {
  _$RfqLineDtoCopyWithImpl(this._self, this._then);

  final RfqLineDto _self;
  final $Res Function(RfqLineDto) _then;

/// Create a copy of RfqLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? uomCode = null,Object? requisitionLineId = freezed,Object? note = freezed,}) {
  return _then(RfqLineDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,uomCode: null == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String,requisitionLineId: freezed == requisitionLineId ? _self.requisitionLineId : requisitionLineId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RfqLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [RfqLineDto].
extension RfqLineDtoPatterns on RfqLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RfqLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RfqLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RfqLineDto value)  $default,){
final _that = this;
switch (_that) {
case _RfqLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RfqLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _RfqLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  String uomCode,  int? requisitionLineId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RfqLineDto() when $default != null:
return $default(_that.id,_that.lineNo,_that.product,_that.qty,_that.uomId,_that.uomCode,_that.requisitionLineId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  String uomCode,  int? requisitionLineId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _RfqLineDto():
return $default(_that.id,_that.lineNo,_that.product,_that.qty,_that.uomId,_that.uomCode,_that.requisitionLineId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  String uomCode,  int? requisitionLineId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _RfqLineDto() when $default != null:
return $default(_that.id,_that.lineNo,_that.product,_that.qty,_that.uomId,_that.uomCode,_that.requisitionLineId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RfqLineDto implements RfqLineDto {
  const _RfqLineDto({required this.id, required this.lineNo, required this.product, required this.qty, required this.uomId, required this.uomCode, this.requisitionLineId, this.note});
  factory _RfqLineDto.fromJson(Map<String, dynamic> json) => _$RfqLineDtoFromJson(json);

@override final  int id;
@override final  int lineNo;
@override final  ProductRefDto product;
@override final  Quantity qty;
@override final  int uomId;
@override final  String uomCode;
@override final  int? requisitionLineId;
@override final  String? note;

/// Create a copy of RfqLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RfqLineDtoCopyWith<_RfqLineDto> get copyWith => __$RfqLineDtoCopyWithImpl<_RfqLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RfqLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RfqLineDto&&(identical(other.id, id) || other.id == id)&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.product, product) || other.product == product)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.requisitionLineId, requisitionLineId) || other.requisitionLineId == requisitionLineId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,lineNo,product,qty,uomId,uomCode,requisitionLineId,note);
}

@override
String toString() {
    return 'RfqLineDto(id: $id, lineNo: $lineNo, product: $product, qty: $qty, uomId: $uomId, uomCode: $uomCode, requisitionLineId: $requisitionLineId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$RfqLineDtoCopyWith<$Res> implements $RfqLineDtoCopyWith<$Res> {
  factory _$RfqLineDtoCopyWith(_RfqLineDto value, $Res Function(_RfqLineDto) _then) = __$RfqLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int lineNo, ProductRefDto product, Quantity qty, int uomId, String uomCode, int? requisitionLineId, String? note
});


@override $ProductRefDtoCopyWith<$Res> get product;

}
/// @nodoc
class __$RfqLineDtoCopyWithImpl<$Res>
    implements _$RfqLineDtoCopyWith<$Res> {
  __$RfqLineDtoCopyWithImpl(this._self, this._then);

  final _RfqLineDto _self;
  final $Res Function(_RfqLineDto) _then;

/// Create a copy of RfqLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? uomCode = null,Object? requisitionLineId = freezed,Object? note = freezed,}) {
  return _then(_RfqLineDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,uomCode: null == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String,requisitionLineId: freezed == requisitionLineId ? _self.requisitionLineId : requisitionLineId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RfqLineDto
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
mixin _$RfqDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; RfqStatus get status;@NullableDateOnlyConverter() DateTime? get dueDate; List<int> get requisitionIds; List<SupplierRefDto> get suppliers; int get supplierCount; int get quotationCount; List<RfqLineDto> get lines; int? get selectedQuotationId; String? get note; int get rowVersion; AuditFieldsDto? get audit;
/// Create a copy of RfqDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RfqDtoCopyWith<RfqDto> get copyWith => _$RfqDtoCopyWithImpl<RfqDto>(this as RfqDto, _$identity);

  /// Serializes this RfqDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RfqDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RfqDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&const DeepCollectionEquality().equals(other.requisitionIds, _this.requisitionIds)&&const DeepCollectionEquality().equals(other.suppliers, _this.suppliers)&&(identical(other.supplierCount, _this.supplierCount) || other.supplierCount == _this.supplierCount)&&(identical(other.quotationCount, _this.quotationCount) || other.quotationCount == _this.quotationCount)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.selectedQuotationId, _this.selectedQuotationId) || other.selectedQuotationId == _this.selectedQuotationId)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&(identical(other.audit, _this.audit) || other.audit == _this.audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RfqDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.docDate,_this.status,_this.dueDate,const DeepCollectionEquality().hash(_this.requisitionIds),const DeepCollectionEquality().hash(_this.suppliers),_this.supplierCount,_this.quotationCount,const DeepCollectionEquality().hash(_this.lines),_this.selectedQuotationId,_this.note,_this.rowVersion,_this.audit);
}

@override
String toString() {
  final _this = this as RfqDto;
  return 'RfqDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, status: ${_this.status}, dueDate: ${_this.dueDate}, requisitionIds: ${_this.requisitionIds}, suppliers: ${_this.suppliers}, supplierCount: ${_this.supplierCount}, quotationCount: ${_this.quotationCount}, lines: ${_this.lines}, selectedQuotationId: ${_this.selectedQuotationId}, note: ${_this.note}, rowVersion: ${_this.rowVersion}, audit: ${_this.audit})';
}


}

/// @nodoc
abstract mixin class $RfqDtoCopyWith<$Res>  {
  factory $RfqDtoCopyWith(RfqDto value, $Res Function(RfqDto) _then) = _$RfqDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, RfqStatus status,@NullableDateOnlyConverter() DateTime? dueDate, List<int> requisitionIds, List<SupplierRefDto> suppliers, int supplierCount, int quotationCount, List<RfqLineDto> lines, int? selectedQuotationId, String? note, int rowVersion, AuditFieldsDto? audit
});


$AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class _$RfqDtoCopyWithImpl<$Res>
    implements $RfqDtoCopyWith<$Res> {
  _$RfqDtoCopyWithImpl(this._self, this._then);

  final RfqDto _self;
  final $Res Function(RfqDto) _then;

/// Create a copy of RfqDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? status = null,Object? dueDate = freezed,Object? requisitionIds = null,Object? suppliers = null,Object? supplierCount = null,Object? quotationCount = null,Object? lines = null,Object? selectedQuotationId = freezed,Object? note = freezed,Object? rowVersion = null,Object? audit = freezed,}) {
  return _then(RfqDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RfqStatus,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,requisitionIds: null == requisitionIds ? _self.requisitionIds : requisitionIds // ignore: cast_nullable_to_non_nullable
as List<int>,suppliers: null == suppliers ? _self.suppliers : suppliers // ignore: cast_nullable_to_non_nullable
as List<SupplierRefDto>,supplierCount: null == supplierCount ? _self.supplierCount : supplierCount // ignore: cast_nullable_to_non_nullable
as int,quotationCount: null == quotationCount ? _self.quotationCount : quotationCount // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<RfqLineDto>,selectedQuotationId: freezed == selectedQuotationId ? _self.selectedQuotationId : selectedQuotationId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}
/// Create a copy of RfqDto
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


/// Adds pattern-matching-related methods to [RfqDto].
extension RfqDtoPatterns on RfqDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RfqDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RfqDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RfqDto value)  $default,){
final _that = this;
switch (_that) {
case _RfqDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RfqDto value)?  $default,){
final _that = this;
switch (_that) {
case _RfqDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  RfqStatus status, @NullableDateOnlyConverter()  DateTime? dueDate,  List<int> requisitionIds,  List<SupplierRefDto> suppliers,  int supplierCount,  int quotationCount,  List<RfqLineDto> lines,  int? selectedQuotationId,  String? note,  int rowVersion,  AuditFieldsDto? audit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RfqDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.status,_that.dueDate,_that.requisitionIds,_that.suppliers,_that.supplierCount,_that.quotationCount,_that.lines,_that.selectedQuotationId,_that.note,_that.rowVersion,_that.audit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  RfqStatus status, @NullableDateOnlyConverter()  DateTime? dueDate,  List<int> requisitionIds,  List<SupplierRefDto> suppliers,  int supplierCount,  int quotationCount,  List<RfqLineDto> lines,  int? selectedQuotationId,  String? note,  int rowVersion,  AuditFieldsDto? audit)  $default,) {final _that = this;
switch (_that) {
case _RfqDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.status,_that.dueDate,_that.requisitionIds,_that.suppliers,_that.supplierCount,_that.quotationCount,_that.lines,_that.selectedQuotationId,_that.note,_that.rowVersion,_that.audit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  RfqStatus status, @NullableDateOnlyConverter()  DateTime? dueDate,  List<int> requisitionIds,  List<SupplierRefDto> suppliers,  int supplierCount,  int quotationCount,  List<RfqLineDto> lines,  int? selectedQuotationId,  String? note,  int rowVersion,  AuditFieldsDto? audit)?  $default,) {final _that = this;
switch (_that) {
case _RfqDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.status,_that.dueDate,_that.requisitionIds,_that.suppliers,_that.supplierCount,_that.quotationCount,_that.lines,_that.selectedQuotationId,_that.note,_that.rowVersion,_that.audit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RfqDto implements RfqDto {
  const _RfqDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.status, @NullableDateOnlyConverter() this.dueDate,  List<int> requisitionIds = const <int>[],  List<SupplierRefDto> suppliers = const <SupplierRefDto>[], this.supplierCount = 0, this.quotationCount = 0,  List<RfqLineDto> lines = const <RfqLineDto>[], this.selectedQuotationId, this.note, this.rowVersion = 1, this.audit}): _requisitionIds = requisitionIds,_suppliers = suppliers,_lines = lines;
  factory _RfqDto.fromJson(Map<String, dynamic> json) => _$RfqDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override@DateOnlyConverter() final  DateTime docDate;
@override final  RfqStatus status;
@override@NullableDateOnlyConverter() final  DateTime? dueDate;
 final  List<int> _requisitionIds;
@override@JsonKey() List<int> get requisitionIds {
  if (_requisitionIds is EqualUnmodifiableListView) return _requisitionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requisitionIds);
}

 final  List<SupplierRefDto> _suppliers;
@override@JsonKey() List<SupplierRefDto> get suppliers {
  if (_suppliers is EqualUnmodifiableListView) return _suppliers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suppliers);
}

@override@JsonKey() final  int supplierCount;
@override@JsonKey() final  int quotationCount;
 final  List<RfqLineDto> _lines;
@override@JsonKey() List<RfqLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  int? selectedQuotationId;
@override final  String? note;
@override@JsonKey() final  int rowVersion;
@override final  AuditFieldsDto? audit;

/// Create a copy of RfqDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RfqDtoCopyWith<_RfqDto> get copyWith => __$RfqDtoCopyWithImpl<_RfqDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RfqDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RfqDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&const DeepCollectionEquality().equals(other.requisitionIds, _requisitionIds)&&const DeepCollectionEquality().equals(other.suppliers, _suppliers)&&(identical(other.supplierCount, supplierCount) || other.supplierCount == supplierCount)&&(identical(other.quotationCount, quotationCount) || other.quotationCount == quotationCount)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.selectedQuotationId, selectedQuotationId) || other.selectedQuotationId == selectedQuotationId)&&(identical(other.note, note) || other.note == note)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&(identical(other.audit, audit) || other.audit == audit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,docDate,status,dueDate,const DeepCollectionEquality().hash(_requisitionIds),const DeepCollectionEquality().hash(_suppliers),supplierCount,quotationCount,const DeepCollectionEquality().hash(_lines),selectedQuotationId,note,rowVersion,audit);
}

@override
String toString() {
    return 'RfqDto(id: $id, docNo: $docNo, docDate: $docDate, status: $status, dueDate: $dueDate, requisitionIds: $requisitionIds, suppliers: $suppliers, supplierCount: $supplierCount, quotationCount: $quotationCount, lines: $lines, selectedQuotationId: $selectedQuotationId, note: $note, rowVersion: $rowVersion, audit: $audit)';
}


}

/// @nodoc
abstract mixin class _$RfqDtoCopyWith<$Res> implements $RfqDtoCopyWith<$Res> {
  factory _$RfqDtoCopyWith(_RfqDto value, $Res Function(_RfqDto) _then) = __$RfqDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, RfqStatus status,@NullableDateOnlyConverter() DateTime? dueDate, List<int> requisitionIds, List<SupplierRefDto> suppliers, int supplierCount, int quotationCount, List<RfqLineDto> lines, int? selectedQuotationId, String? note, int rowVersion, AuditFieldsDto? audit
});


@override $AuditFieldsDtoCopyWith<$Res>? get audit;

}
/// @nodoc
class __$RfqDtoCopyWithImpl<$Res>
    implements _$RfqDtoCopyWith<$Res> {
  __$RfqDtoCopyWithImpl(this._self, this._then);

  final _RfqDto _self;
  final $Res Function(_RfqDto) _then;

/// Create a copy of RfqDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? status = null,Object? dueDate = freezed,Object? requisitionIds = null,Object? suppliers = null,Object? supplierCount = null,Object? quotationCount = null,Object? lines = null,Object? selectedQuotationId = freezed,Object? note = freezed,Object? rowVersion = null,Object? audit = freezed,}) {
  return _then(_RfqDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RfqStatus,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,requisitionIds: null == requisitionIds ? _self._requisitionIds : requisitionIds // ignore: cast_nullable_to_non_nullable
as List<int>,suppliers: null == suppliers ? _self._suppliers : suppliers // ignore: cast_nullable_to_non_nullable
as List<SupplierRefDto>,supplierCount: null == supplierCount ? _self.supplierCount : supplierCount // ignore: cast_nullable_to_non_nullable
as int,quotationCount: null == quotationCount ? _self.quotationCount : quotationCount // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<RfqLineDto>,selectedQuotationId: freezed == selectedQuotationId ? _self.selectedQuotationId : selectedQuotationId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,audit: freezed == audit ? _self.audit : audit // ignore: cast_nullable_to_non_nullable
as AuditFieldsDto?,
  ));
}

/// Create a copy of RfqDto
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
mixin _$QuotationLineDto {

 int get id; int get lineNo; ProductRefDto get product; Quantity get qty; int get uomId; String get uomCode; Money get unitPrice; Money get lineTotal; Money? get unitPriceBase; int? get rfqLineId; String? get note;
/// Create a copy of QuotationLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuotationLineDtoCopyWith<QuotationLineDto> get copyWith => _$QuotationLineDtoCopyWithImpl<QuotationLineDto>(this as QuotationLineDto, _$identity);

  /// Serializes this QuotationLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QuotationLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuotationLineDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.lineTotal, _this.lineTotal) || other.lineTotal == _this.lineTotal)&&(identical(other.unitPriceBase, _this.unitPriceBase) || other.unitPriceBase == _this.unitPriceBase)&&(identical(other.rfqLineId, _this.rfqLineId) || other.rfqLineId == _this.rfqLineId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QuotationLineDto;
  return Object.hash(runtimeType,_this.id,_this.lineNo,_this.product,_this.qty,_this.uomId,_this.uomCode,_this.unitPrice,_this.lineTotal,_this.unitPriceBase,_this.rfqLineId,_this.note);
}

@override
String toString() {
  final _this = this as QuotationLineDto;
  return 'QuotationLineDto(id: ${_this.id}, lineNo: ${_this.lineNo}, product: ${_this.product}, qty: ${_this.qty}, uomId: ${_this.uomId}, uomCode: ${_this.uomCode}, unitPrice: ${_this.unitPrice}, lineTotal: ${_this.lineTotal}, unitPriceBase: ${_this.unitPriceBase}, rfqLineId: ${_this.rfqLineId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $QuotationLineDtoCopyWith<$Res>  {
  factory $QuotationLineDtoCopyWith(QuotationLineDto value, $Res Function(QuotationLineDto) _then) = _$QuotationLineDtoCopyWithImpl;
@useResult
$Res call({
 int id, int lineNo, ProductRefDto product, Quantity qty, int uomId, String uomCode, Money unitPrice, Money lineTotal, Money? unitPriceBase, int? rfqLineId, String? note
});


$ProductRefDtoCopyWith<$Res> get product;

}
/// @nodoc
class _$QuotationLineDtoCopyWithImpl<$Res>
    implements $QuotationLineDtoCopyWith<$Res> {
  _$QuotationLineDtoCopyWithImpl(this._self, this._then);

  final QuotationLineDto _self;
  final $Res Function(QuotationLineDto) _then;

/// Create a copy of QuotationLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? uomCode = null,Object? unitPrice = null,Object? lineTotal = null,Object? unitPriceBase = freezed,Object? rfqLineId = freezed,Object? note = freezed,}) {
  return _then(QuotationLineDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,uomCode: null == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as Money,unitPriceBase: freezed == unitPriceBase ? _self.unitPriceBase : unitPriceBase // ignore: cast_nullable_to_non_nullable
as Money?,rfqLineId: freezed == rfqLineId ? _self.rfqLineId : rfqLineId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of QuotationLineDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [QuotationLineDto].
extension QuotationLineDtoPatterns on QuotationLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuotationLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuotationLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuotationLineDto value)  $default,){
final _that = this;
switch (_that) {
case _QuotationLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuotationLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _QuotationLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  String uomCode,  Money unitPrice,  Money lineTotal,  Money? unitPriceBase,  int? rfqLineId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuotationLineDto() when $default != null:
return $default(_that.id,_that.lineNo,_that.product,_that.qty,_that.uomId,_that.uomCode,_that.unitPrice,_that.lineTotal,_that.unitPriceBase,_that.rfqLineId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  String uomCode,  Money unitPrice,  Money lineTotal,  Money? unitPriceBase,  int? rfqLineId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _QuotationLineDto():
return $default(_that.id,_that.lineNo,_that.product,_that.qty,_that.uomId,_that.uomCode,_that.unitPrice,_that.lineTotal,_that.unitPriceBase,_that.rfqLineId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int lineNo,  ProductRefDto product,  Quantity qty,  int uomId,  String uomCode,  Money unitPrice,  Money lineTotal,  Money? unitPriceBase,  int? rfqLineId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _QuotationLineDto() when $default != null:
return $default(_that.id,_that.lineNo,_that.product,_that.qty,_that.uomId,_that.uomCode,_that.unitPrice,_that.lineTotal,_that.unitPriceBase,_that.rfqLineId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuotationLineDto implements QuotationLineDto {
  const _QuotationLineDto({required this.id, required this.lineNo, required this.product, required this.qty, required this.uomId, required this.uomCode, required this.unitPrice, required this.lineTotal, this.unitPriceBase, this.rfqLineId, this.note});
  factory _QuotationLineDto.fromJson(Map<String, dynamic> json) => _$QuotationLineDtoFromJson(json);

@override final  int id;
@override final  int lineNo;
@override final  ProductRefDto product;
@override final  Quantity qty;
@override final  int uomId;
@override final  String uomCode;
@override final  Money unitPrice;
@override final  Money lineTotal;
@override final  Money? unitPriceBase;
@override final  int? rfqLineId;
@override final  String? note;

/// Create a copy of QuotationLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuotationLineDtoCopyWith<_QuotationLineDto> get copyWith => __$QuotationLineDtoCopyWithImpl<_QuotationLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuotationLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuotationLineDto&&(identical(other.id, id) || other.id == id)&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.product, product) || other.product == product)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal)&&(identical(other.unitPriceBase, unitPriceBase) || other.unitPriceBase == unitPriceBase)&&(identical(other.rfqLineId, rfqLineId) || other.rfqLineId == rfqLineId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,lineNo,product,qty,uomId,uomCode,unitPrice,lineTotal,unitPriceBase,rfqLineId,note);
}

@override
String toString() {
    return 'QuotationLineDto(id: $id, lineNo: $lineNo, product: $product, qty: $qty, uomId: $uomId, uomCode: $uomCode, unitPrice: $unitPrice, lineTotal: $lineTotal, unitPriceBase: $unitPriceBase, rfqLineId: $rfqLineId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$QuotationLineDtoCopyWith<$Res> implements $QuotationLineDtoCopyWith<$Res> {
  factory _$QuotationLineDtoCopyWith(_QuotationLineDto value, $Res Function(_QuotationLineDto) _then) = __$QuotationLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int lineNo, ProductRefDto product, Quantity qty, int uomId, String uomCode, Money unitPrice, Money lineTotal, Money? unitPriceBase, int? rfqLineId, String? note
});


@override $ProductRefDtoCopyWith<$Res> get product;

}
/// @nodoc
class __$QuotationLineDtoCopyWithImpl<$Res>
    implements _$QuotationLineDtoCopyWith<$Res> {
  __$QuotationLineDtoCopyWithImpl(this._self, this._then);

  final _QuotationLineDto _self;
  final $Res Function(_QuotationLineDto) _then;

/// Create a copy of QuotationLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lineNo = null,Object? product = null,Object? qty = null,Object? uomId = null,Object? uomCode = null,Object? unitPrice = null,Object? lineTotal = null,Object? unitPriceBase = freezed,Object? rfqLineId = freezed,Object? note = freezed,}) {
  return _then(_QuotationLineDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,uomCode: null == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as Money,unitPriceBase: freezed == unitPriceBase ? _self.unitPriceBase : unitPriceBase // ignore: cast_nullable_to_non_nullable
as Money?,rfqLineId: freezed == rfqLineId ? _self.rfqLineId : rfqLineId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of QuotationLineDto
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
mixin _$QuotationDto {

 int get id; SupplierRefDto get supplier;@DateOnlyConverter() DateTime get quoteDate; String get currency; int? get rfqId; String? get quoteNo;@NullableDateOnlyConverter() DateTime? get validUntil; int? get deliveryDays; String? get paymentTerms; Money? get totalAmount; Money? get totalAmountBase; bool get isSelected; String? get selectionNote; List<QuotationLineDto> get lines;
/// Create a copy of QuotationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuotationDtoCopyWith<QuotationDto> get copyWith => _$QuotationDtoCopyWithImpl<QuotationDto>(this as QuotationDto, _$identity);

  /// Serializes this QuotationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QuotationDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuotationDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.supplier, _this.supplier) || other.supplier == _this.supplier)&&(identical(other.quoteDate, _this.quoteDate) || other.quoteDate == _this.quoteDate)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.rfqId, _this.rfqId) || other.rfqId == _this.rfqId)&&(identical(other.quoteNo, _this.quoteNo) || other.quoteNo == _this.quoteNo)&&(identical(other.validUntil, _this.validUntil) || other.validUntil == _this.validUntil)&&(identical(other.deliveryDays, _this.deliveryDays) || other.deliveryDays == _this.deliveryDays)&&(identical(other.paymentTerms, _this.paymentTerms) || other.paymentTerms == _this.paymentTerms)&&(identical(other.totalAmount, _this.totalAmount) || other.totalAmount == _this.totalAmount)&&(identical(other.totalAmountBase, _this.totalAmountBase) || other.totalAmountBase == _this.totalAmountBase)&&(identical(other.isSelected, _this.isSelected) || other.isSelected == _this.isSelected)&&(identical(other.selectionNote, _this.selectionNote) || other.selectionNote == _this.selectionNote)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QuotationDto;
  return Object.hash(runtimeType,_this.id,_this.supplier,_this.quoteDate,_this.currency,_this.rfqId,_this.quoteNo,_this.validUntil,_this.deliveryDays,_this.paymentTerms,_this.totalAmount,_this.totalAmountBase,_this.isSelected,_this.selectionNote,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as QuotationDto;
  return 'QuotationDto(id: ${_this.id}, supplier: ${_this.supplier}, quoteDate: ${_this.quoteDate}, currency: ${_this.currency}, rfqId: ${_this.rfqId}, quoteNo: ${_this.quoteNo}, validUntil: ${_this.validUntil}, deliveryDays: ${_this.deliveryDays}, paymentTerms: ${_this.paymentTerms}, totalAmount: ${_this.totalAmount}, totalAmountBase: ${_this.totalAmountBase}, isSelected: ${_this.isSelected}, selectionNote: ${_this.selectionNote}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $QuotationDtoCopyWith<$Res>  {
  factory $QuotationDtoCopyWith(QuotationDto value, $Res Function(QuotationDto) _then) = _$QuotationDtoCopyWithImpl;
@useResult
$Res call({
 int id, SupplierRefDto supplier,@DateOnlyConverter() DateTime quoteDate, String currency, int? rfqId, String? quoteNo,@NullableDateOnlyConverter() DateTime? validUntil, int? deliveryDays, String? paymentTerms, Money? totalAmount, Money? totalAmountBase, bool isSelected, String? selectionNote, List<QuotationLineDto> lines
});


$SupplierRefDtoCopyWith<$Res> get supplier;

}
/// @nodoc
class _$QuotationDtoCopyWithImpl<$Res>
    implements $QuotationDtoCopyWith<$Res> {
  _$QuotationDtoCopyWithImpl(this._self, this._then);

  final QuotationDto _self;
  final $Res Function(QuotationDto) _then;

/// Create a copy of QuotationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? supplier = null,Object? quoteDate = null,Object? currency = null,Object? rfqId = freezed,Object? quoteNo = freezed,Object? validUntil = freezed,Object? deliveryDays = freezed,Object? paymentTerms = freezed,Object? totalAmount = freezed,Object? totalAmountBase = freezed,Object? isSelected = null,Object? selectionNote = freezed,Object? lines = null,}) {
  return _then(QuotationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,supplier: null == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as SupplierRefDto,quoteDate: null == quoteDate ? _self.quoteDate : quoteDate // ignore: cast_nullable_to_non_nullable
as DateTime,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,rfqId: freezed == rfqId ? _self.rfqId : rfqId // ignore: cast_nullable_to_non_nullable
as int?,quoteNo: freezed == quoteNo ? _self.quoteNo : quoteNo // ignore: cast_nullable_to_non_nullable
as String?,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveryDays: freezed == deliveryDays ? _self.deliveryDays : deliveryDays // ignore: cast_nullable_to_non_nullable
as int?,paymentTerms: freezed == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: freezed == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money?,totalAmountBase: freezed == totalAmountBase ? _self.totalAmountBase : totalAmountBase // ignore: cast_nullable_to_non_nullable
as Money?,isSelected: null == isSelected ? _self.isSelected : isSelected // ignore: cast_nullable_to_non_nullable
as bool,selectionNote: freezed == selectionNote ? _self.selectionNote : selectionNote // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<QuotationLineDto>,
  ));
}
/// Create a copy of QuotationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupplierRefDtoCopyWith<$Res> get supplier {
  
  return $SupplierRefDtoCopyWith<$Res>(_self.supplier, (value) {
    return _then(_self.copyWith(supplier: value));
  });
}
}


/// Adds pattern-matching-related methods to [QuotationDto].
extension QuotationDtoPatterns on QuotationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuotationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuotationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuotationDto value)  $default,){
final _that = this;
switch (_that) {
case _QuotationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuotationDto value)?  $default,){
final _that = this;
switch (_that) {
case _QuotationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  SupplierRefDto supplier, @DateOnlyConverter()  DateTime quoteDate,  String currency,  int? rfqId,  String? quoteNo, @NullableDateOnlyConverter()  DateTime? validUntil,  int? deliveryDays,  String? paymentTerms,  Money? totalAmount,  Money? totalAmountBase,  bool isSelected,  String? selectionNote,  List<QuotationLineDto> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuotationDto() when $default != null:
return $default(_that.id,_that.supplier,_that.quoteDate,_that.currency,_that.rfqId,_that.quoteNo,_that.validUntil,_that.deliveryDays,_that.paymentTerms,_that.totalAmount,_that.totalAmountBase,_that.isSelected,_that.selectionNote,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  SupplierRefDto supplier, @DateOnlyConverter()  DateTime quoteDate,  String currency,  int? rfqId,  String? quoteNo, @NullableDateOnlyConverter()  DateTime? validUntil,  int? deliveryDays,  String? paymentTerms,  Money? totalAmount,  Money? totalAmountBase,  bool isSelected,  String? selectionNote,  List<QuotationLineDto> lines)  $default,) {final _that = this;
switch (_that) {
case _QuotationDto():
return $default(_that.id,_that.supplier,_that.quoteDate,_that.currency,_that.rfqId,_that.quoteNo,_that.validUntil,_that.deliveryDays,_that.paymentTerms,_that.totalAmount,_that.totalAmountBase,_that.isSelected,_that.selectionNote,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  SupplierRefDto supplier, @DateOnlyConverter()  DateTime quoteDate,  String currency,  int? rfqId,  String? quoteNo, @NullableDateOnlyConverter()  DateTime? validUntil,  int? deliveryDays,  String? paymentTerms,  Money? totalAmount,  Money? totalAmountBase,  bool isSelected,  String? selectionNote,  List<QuotationLineDto> lines)?  $default,) {final _that = this;
switch (_that) {
case _QuotationDto() when $default != null:
return $default(_that.id,_that.supplier,_that.quoteDate,_that.currency,_that.rfqId,_that.quoteNo,_that.validUntil,_that.deliveryDays,_that.paymentTerms,_that.totalAmount,_that.totalAmountBase,_that.isSelected,_that.selectionNote,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuotationDto implements QuotationDto {
  const _QuotationDto({required this.id, required this.supplier, @DateOnlyConverter() required this.quoteDate, required this.currency, this.rfqId, this.quoteNo, @NullableDateOnlyConverter() this.validUntil, this.deliveryDays, this.paymentTerms, this.totalAmount, this.totalAmountBase, this.isSelected = false, this.selectionNote,  List<QuotationLineDto> lines = const <QuotationLineDto>[]}): _lines = lines;
  factory _QuotationDto.fromJson(Map<String, dynamic> json) => _$QuotationDtoFromJson(json);

@override final  int id;
@override final  SupplierRefDto supplier;
@override@DateOnlyConverter() final  DateTime quoteDate;
@override final  String currency;
@override final  int? rfqId;
@override final  String? quoteNo;
@override@NullableDateOnlyConverter() final  DateTime? validUntil;
@override final  int? deliveryDays;
@override final  String? paymentTerms;
@override final  Money? totalAmount;
@override final  Money? totalAmountBase;
@override@JsonKey() final  bool isSelected;
@override final  String? selectionNote;
 final  List<QuotationLineDto> _lines;
@override@JsonKey() List<QuotationLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of QuotationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuotationDtoCopyWith<_QuotationDto> get copyWith => __$QuotationDtoCopyWithImpl<_QuotationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuotationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuotationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&(identical(other.quoteDate, quoteDate) || other.quoteDate == quoteDate)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.rfqId, rfqId) || other.rfqId == rfqId)&&(identical(other.quoteNo, quoteNo) || other.quoteNo == quoteNo)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.deliveryDays, deliveryDays) || other.deliveryDays == deliveryDays)&&(identical(other.paymentTerms, paymentTerms) || other.paymentTerms == paymentTerms)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.totalAmountBase, totalAmountBase) || other.totalAmountBase == totalAmountBase)&&(identical(other.isSelected, isSelected) || other.isSelected == isSelected)&&(identical(other.selectionNote, selectionNote) || other.selectionNote == selectionNote)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,supplier,quoteDate,currency,rfqId,quoteNo,validUntil,deliveryDays,paymentTerms,totalAmount,totalAmountBase,isSelected,selectionNote,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'QuotationDto(id: $id, supplier: $supplier, quoteDate: $quoteDate, currency: $currency, rfqId: $rfqId, quoteNo: $quoteNo, validUntil: $validUntil, deliveryDays: $deliveryDays, paymentTerms: $paymentTerms, totalAmount: $totalAmount, totalAmountBase: $totalAmountBase, isSelected: $isSelected, selectionNote: $selectionNote, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$QuotationDtoCopyWith<$Res> implements $QuotationDtoCopyWith<$Res> {
  factory _$QuotationDtoCopyWith(_QuotationDto value, $Res Function(_QuotationDto) _then) = __$QuotationDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, SupplierRefDto supplier,@DateOnlyConverter() DateTime quoteDate, String currency, int? rfqId, String? quoteNo,@NullableDateOnlyConverter() DateTime? validUntil, int? deliveryDays, String? paymentTerms, Money? totalAmount, Money? totalAmountBase, bool isSelected, String? selectionNote, List<QuotationLineDto> lines
});


@override $SupplierRefDtoCopyWith<$Res> get supplier;

}
/// @nodoc
class __$QuotationDtoCopyWithImpl<$Res>
    implements _$QuotationDtoCopyWith<$Res> {
  __$QuotationDtoCopyWithImpl(this._self, this._then);

  final _QuotationDto _self;
  final $Res Function(_QuotationDto) _then;

/// Create a copy of QuotationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? supplier = null,Object? quoteDate = null,Object? currency = null,Object? rfqId = freezed,Object? quoteNo = freezed,Object? validUntil = freezed,Object? deliveryDays = freezed,Object? paymentTerms = freezed,Object? totalAmount = freezed,Object? totalAmountBase = freezed,Object? isSelected = null,Object? selectionNote = freezed,Object? lines = null,}) {
  return _then(_QuotationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,supplier: null == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as SupplierRefDto,quoteDate: null == quoteDate ? _self.quoteDate : quoteDate // ignore: cast_nullable_to_non_nullable
as DateTime,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,rfqId: freezed == rfqId ? _self.rfqId : rfqId // ignore: cast_nullable_to_non_nullable
as int?,quoteNo: freezed == quoteNo ? _self.quoteNo : quoteNo // ignore: cast_nullable_to_non_nullable
as String?,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveryDays: freezed == deliveryDays ? _self.deliveryDays : deliveryDays // ignore: cast_nullable_to_non_nullable
as int?,paymentTerms: freezed == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: freezed == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money?,totalAmountBase: freezed == totalAmountBase ? _self.totalAmountBase : totalAmountBase // ignore: cast_nullable_to_non_nullable
as Money?,isSelected: null == isSelected ? _self.isSelected : isSelected // ignore: cast_nullable_to_non_nullable
as bool,selectionNote: freezed == selectionNote ? _self.selectionNote : selectionNote // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<QuotationLineDto>,
  ));
}

/// Create a copy of QuotationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupplierRefDtoCopyWith<$Res> get supplier {
  
  return $SupplierRefDtoCopyWith<$Res>(_self.supplier, (value) {
    return _then(_self.copyWith(supplier: value));
  });
}
}


/// @nodoc
mixin _$SelectQuotationRequest {

 int get quotationId; String? get selectionNote;
/// Create a copy of SelectQuotationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectQuotationRequestCopyWith<SelectQuotationRequest> get copyWith => _$SelectQuotationRequestCopyWithImpl<SelectQuotationRequest>(this as SelectQuotationRequest, _$identity);

  /// Serializes this SelectQuotationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SelectQuotationRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectQuotationRequest&&(identical(other.quotationId, _this.quotationId) || other.quotationId == _this.quotationId)&&(identical(other.selectionNote, _this.selectionNote) || other.selectionNote == _this.selectionNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SelectQuotationRequest;
  return Object.hash(runtimeType,_this.quotationId,_this.selectionNote);
}

@override
String toString() {
  final _this = this as SelectQuotationRequest;
  return 'SelectQuotationRequest(quotationId: ${_this.quotationId}, selectionNote: ${_this.selectionNote})';
}


}

/// @nodoc
abstract mixin class $SelectQuotationRequestCopyWith<$Res>  {
  factory $SelectQuotationRequestCopyWith(SelectQuotationRequest value, $Res Function(SelectQuotationRequest) _then) = _$SelectQuotationRequestCopyWithImpl;
@useResult
$Res call({
 int quotationId, String? selectionNote
});




}
/// @nodoc
class _$SelectQuotationRequestCopyWithImpl<$Res>
    implements $SelectQuotationRequestCopyWith<$Res> {
  _$SelectQuotationRequestCopyWithImpl(this._self, this._then);

  final SelectQuotationRequest _self;
  final $Res Function(SelectQuotationRequest) _then;

/// Create a copy of SelectQuotationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quotationId = null,Object? selectionNote = freezed,}) {
  return _then(SelectQuotationRequest(
quotationId: null == quotationId ? _self.quotationId : quotationId // ignore: cast_nullable_to_non_nullable
as int,selectionNote: freezed == selectionNote ? _self.selectionNote : selectionNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectQuotationRequest].
extension SelectQuotationRequestPatterns on SelectQuotationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectQuotationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectQuotationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectQuotationRequest value)  $default,){
final _that = this;
switch (_that) {
case _SelectQuotationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectQuotationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SelectQuotationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int quotationId,  String? selectionNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectQuotationRequest() when $default != null:
return $default(_that.quotationId,_that.selectionNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int quotationId,  String? selectionNote)  $default,) {final _that = this;
switch (_that) {
case _SelectQuotationRequest():
return $default(_that.quotationId,_that.selectionNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int quotationId,  String? selectionNote)?  $default,) {final _that = this;
switch (_that) {
case _SelectQuotationRequest() when $default != null:
return $default(_that.quotationId,_that.selectionNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SelectQuotationRequest implements SelectQuotationRequest {
  const _SelectQuotationRequest({required this.quotationId, this.selectionNote});
  factory _SelectQuotationRequest.fromJson(Map<String, dynamic> json) => _$SelectQuotationRequestFromJson(json);

@override final  int quotationId;
@override final  String? selectionNote;

/// Create a copy of SelectQuotationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectQuotationRequestCopyWith<_SelectQuotationRequest> get copyWith => __$SelectQuotationRequestCopyWithImpl<_SelectQuotationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelectQuotationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectQuotationRequest&&(identical(other.quotationId, quotationId) || other.quotationId == quotationId)&&(identical(other.selectionNote, selectionNote) || other.selectionNote == selectionNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,quotationId,selectionNote);
}

@override
String toString() {
    return 'SelectQuotationRequest(quotationId: $quotationId, selectionNote: $selectionNote)';
}


}

/// @nodoc
abstract mixin class _$SelectQuotationRequestCopyWith<$Res> implements $SelectQuotationRequestCopyWith<$Res> {
  factory _$SelectQuotationRequestCopyWith(_SelectQuotationRequest value, $Res Function(_SelectQuotationRequest) _then) = __$SelectQuotationRequestCopyWithImpl;
@override @useResult
$Res call({
 int quotationId, String? selectionNote
});




}
/// @nodoc
class __$SelectQuotationRequestCopyWithImpl<$Res>
    implements _$SelectQuotationRequestCopyWith<$Res> {
  __$SelectQuotationRequestCopyWithImpl(this._self, this._then);

  final _SelectQuotationRequest _self;
  final $Res Function(_SelectQuotationRequest) _then;

/// Create a copy of SelectQuotationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quotationId = null,Object? selectionNote = freezed,}) {
  return _then(_SelectQuotationRequest(
quotationId: null == quotationId ? _self.quotationId : quotationId // ignore: cast_nullable_to_non_nullable
as int,selectionNote: freezed == selectionNote ? _self.selectionNote : selectionNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PurchaseOrderLineDto {

 int get lineNo; int get productId; Quantity get qty; int get uomId; Money get unitPrice; Decimal get vatRate; Money get lineTotal; Quantity get receivedQty; int? get requisitionLineId; String? get productName; String? get uomCode;
/// Create a copy of PurchaseOrderLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderLineDtoCopyWith<PurchaseOrderLineDto> get copyWith => _$PurchaseOrderLineDtoCopyWithImpl<PurchaseOrderLineDto>(this as PurchaseOrderLineDto, _$identity);

  /// Serializes this PurchaseOrderLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PurchaseOrderLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrderLineDto&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.vatRate, _this.vatRate) || other.vatRate == _this.vatRate)&&(identical(other.lineTotal, _this.lineTotal) || other.lineTotal == _this.lineTotal)&&(identical(other.receivedQty, _this.receivedQty) || other.receivedQty == _this.receivedQty)&&(identical(other.requisitionLineId, _this.requisitionLineId) || other.requisitionLineId == _this.requisitionLineId)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PurchaseOrderLineDto;
  return Object.hash(runtimeType,_this.lineNo,_this.productId,_this.qty,_this.uomId,_this.unitPrice,_this.vatRate,_this.lineTotal,_this.receivedQty,_this.requisitionLineId,_this.productName,_this.uomCode);
}

@override
String toString() {
  final _this = this as PurchaseOrderLineDto;
  return 'PurchaseOrderLineDto(lineNo: ${_this.lineNo}, productId: ${_this.productId}, qty: ${_this.qty}, uomId: ${_this.uomId}, unitPrice: ${_this.unitPrice}, vatRate: ${_this.vatRate}, lineTotal: ${_this.lineTotal}, receivedQty: ${_this.receivedQty}, requisitionLineId: ${_this.requisitionLineId}, productName: ${_this.productName}, uomCode: ${_this.uomCode})';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderLineDtoCopyWith<$Res>  {
  factory $PurchaseOrderLineDtoCopyWith(PurchaseOrderLineDto value, $Res Function(PurchaseOrderLineDto) _then) = _$PurchaseOrderLineDtoCopyWithImpl;
@useResult
$Res call({
 int lineNo, int productId, Quantity qty, int uomId, Money unitPrice, Decimal vatRate, Money lineTotal, Quantity receivedQty, int? requisitionLineId, String? productName, String? uomCode
});




}
/// @nodoc
class _$PurchaseOrderLineDtoCopyWithImpl<$Res>
    implements $PurchaseOrderLineDtoCopyWith<$Res> {
  _$PurchaseOrderLineDtoCopyWithImpl(this._self, this._then);

  final PurchaseOrderLineDto _self;
  final $Res Function(PurchaseOrderLineDto) _then;

/// Create a copy of PurchaseOrderLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? productId = null,Object? qty = null,Object? uomId = null,Object? unitPrice = null,Object? vatRate = null,Object? lineTotal = null,Object? receivedQty = null,Object? requisitionLineId = freezed,Object? productName = freezed,Object? uomCode = freezed,}) {
  return _then(PurchaseOrderLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money,vatRate: null == vatRate ? _self.vatRate : vatRate // ignore: cast_nullable_to_non_nullable
as Decimal,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as Money,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,requisitionLineId: freezed == requisitionLineId ? _self.requisitionLineId : requisitionLineId // ignore: cast_nullable_to_non_nullable
as int?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrderLineDto].
extension PurchaseOrderLineDtoPatterns on PurchaseOrderLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrderLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrderLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrderLineDto value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrderLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  int productId,  Quantity qty,  int uomId,  Money unitPrice,  Decimal vatRate,  Money lineTotal,  Quantity receivedQty,  int? requisitionLineId,  String? productName,  String? uomCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrderLineDto() when $default != null:
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.unitPrice,_that.vatRate,_that.lineTotal,_that.receivedQty,_that.requisitionLineId,_that.productName,_that.uomCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  int productId,  Quantity qty,  int uomId,  Money unitPrice,  Decimal vatRate,  Money lineTotal,  Quantity receivedQty,  int? requisitionLineId,  String? productName,  String? uomCode)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderLineDto():
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.unitPrice,_that.vatRate,_that.lineTotal,_that.receivedQty,_that.requisitionLineId,_that.productName,_that.uomCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  int productId,  Quantity qty,  int uomId,  Money unitPrice,  Decimal vatRate,  Money lineTotal,  Quantity receivedQty,  int? requisitionLineId,  String? productName,  String? uomCode)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderLineDto() when $default != null:
return $default(_that.lineNo,_that.productId,_that.qty,_that.uomId,_that.unitPrice,_that.vatRate,_that.lineTotal,_that.receivedQty,_that.requisitionLineId,_that.productName,_that.uomCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseOrderLineDto extends PurchaseOrderLineDto {
  const _PurchaseOrderLineDto({required this.lineNo, required this.productId, required this.qty, required this.uomId, required this.unitPrice, required this.vatRate, required this.lineTotal, required this.receivedQty, this.requisitionLineId, this.productName, this.uomCode}): super._();
  factory _PurchaseOrderLineDto.fromJson(Map<String, dynamic> json) => _$PurchaseOrderLineDtoFromJson(json);

@override final  int lineNo;
@override final  int productId;
@override final  Quantity qty;
@override final  int uomId;
@override final  Money unitPrice;
@override final  Decimal vatRate;
@override final  Money lineTotal;
@override final  Quantity receivedQty;
@override final  int? requisitionLineId;
@override final  String? productName;
@override final  String? uomCode;

/// Create a copy of PurchaseOrderLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderLineDtoCopyWith<_PurchaseOrderLineDto> get copyWith => __$PurchaseOrderLineDtoCopyWithImpl<_PurchaseOrderLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseOrderLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrderLineDto&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.vatRate, vatRate) || other.vatRate == vatRate)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal)&&(identical(other.receivedQty, receivedQty) || other.receivedQty == receivedQty)&&(identical(other.requisitionLineId, requisitionLineId) || other.requisitionLineId == requisitionLineId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,productId,qty,uomId,unitPrice,vatRate,lineTotal,receivedQty,requisitionLineId,productName,uomCode);
}

@override
String toString() {
    return 'PurchaseOrderLineDto(lineNo: $lineNo, productId: $productId, qty: $qty, uomId: $uomId, unitPrice: $unitPrice, vatRate: $vatRate, lineTotal: $lineTotal, receivedQty: $receivedQty, requisitionLineId: $requisitionLineId, productName: $productName, uomCode: $uomCode)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderLineDtoCopyWith<$Res> implements $PurchaseOrderLineDtoCopyWith<$Res> {
  factory _$PurchaseOrderLineDtoCopyWith(_PurchaseOrderLineDto value, $Res Function(_PurchaseOrderLineDto) _then) = __$PurchaseOrderLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, int productId, Quantity qty, int uomId, Money unitPrice, Decimal vatRate, Money lineTotal, Quantity receivedQty, int? requisitionLineId, String? productName, String? uomCode
});




}
/// @nodoc
class __$PurchaseOrderLineDtoCopyWithImpl<$Res>
    implements _$PurchaseOrderLineDtoCopyWith<$Res> {
  __$PurchaseOrderLineDtoCopyWithImpl(this._self, this._then);

  final _PurchaseOrderLineDto _self;
  final $Res Function(_PurchaseOrderLineDto) _then;

/// Create a copy of PurchaseOrderLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? productId = null,Object? qty = null,Object? uomId = null,Object? unitPrice = null,Object? vatRate = null,Object? lineTotal = null,Object? receivedQty = null,Object? requisitionLineId = freezed,Object? productName = freezed,Object? uomCode = freezed,}) {
  return _then(_PurchaseOrderLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money,vatRate: null == vatRate ? _self.vatRate : vatRate // ignore: cast_nullable_to_non_nullable
as Decimal,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as Money,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,requisitionLineId: freezed == requisitionLineId ? _self.requisitionLineId : requisitionLineId // ignore: cast_nullable_to_non_nullable
as int?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ApprovalStepDto {

 int get id; int get stepNo; String get approverRoleCode; ApprovalStatus get decision; UserRefDto? get approverUser; UserRefDto? get delegatedFromUser; DateTime? get decidedAt; String? get comment;
/// Create a copy of ApprovalStepDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApprovalStepDtoCopyWith<ApprovalStepDto> get copyWith => _$ApprovalStepDtoCopyWithImpl<ApprovalStepDto>(this as ApprovalStepDto, _$identity);

  /// Serializes this ApprovalStepDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ApprovalStepDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApprovalStepDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.stepNo, _this.stepNo) || other.stepNo == _this.stepNo)&&(identical(other.approverRoleCode, _this.approverRoleCode) || other.approverRoleCode == _this.approverRoleCode)&&(identical(other.decision, _this.decision) || other.decision == _this.decision)&&(identical(other.approverUser, _this.approverUser) || other.approverUser == _this.approverUser)&&(identical(other.delegatedFromUser, _this.delegatedFromUser) || other.delegatedFromUser == _this.delegatedFromUser)&&(identical(other.decidedAt, _this.decidedAt) || other.decidedAt == _this.decidedAt)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApprovalStepDto;
  return Object.hash(runtimeType,_this.id,_this.stepNo,_this.approverRoleCode,_this.decision,_this.approverUser,_this.delegatedFromUser,_this.decidedAt,_this.comment);
}

@override
String toString() {
  final _this = this as ApprovalStepDto;
  return 'ApprovalStepDto(id: ${_this.id}, stepNo: ${_this.stepNo}, approverRoleCode: ${_this.approverRoleCode}, decision: ${_this.decision}, approverUser: ${_this.approverUser}, delegatedFromUser: ${_this.delegatedFromUser}, decidedAt: ${_this.decidedAt}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $ApprovalStepDtoCopyWith<$Res>  {
  factory $ApprovalStepDtoCopyWith(ApprovalStepDto value, $Res Function(ApprovalStepDto) _then) = _$ApprovalStepDtoCopyWithImpl;
@useResult
$Res call({
 int id, int stepNo, String approverRoleCode, ApprovalStatus decision, UserRefDto? approverUser, UserRefDto? delegatedFromUser, DateTime? decidedAt, String? comment
});


$UserRefDtoCopyWith<$Res>? get approverUser;$UserRefDtoCopyWith<$Res>? get delegatedFromUser;

}
/// @nodoc
class _$ApprovalStepDtoCopyWithImpl<$Res>
    implements $ApprovalStepDtoCopyWith<$Res> {
  _$ApprovalStepDtoCopyWithImpl(this._self, this._then);

  final ApprovalStepDto _self;
  final $Res Function(ApprovalStepDto) _then;

/// Create a copy of ApprovalStepDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? stepNo = null,Object? approverRoleCode = null,Object? decision = null,Object? approverUser = freezed,Object? delegatedFromUser = freezed,Object? decidedAt = freezed,Object? comment = freezed,}) {
  return _then(ApprovalStepDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,stepNo: null == stepNo ? _self.stepNo : stepNo // ignore: cast_nullable_to_non_nullable
as int,approverRoleCode: null == approverRoleCode ? _self.approverRoleCode : approverRoleCode // ignore: cast_nullable_to_non_nullable
as String,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as ApprovalStatus,approverUser: freezed == approverUser ? _self.approverUser : approverUser // ignore: cast_nullable_to_non_nullable
as UserRefDto?,delegatedFromUser: freezed == delegatedFromUser ? _self.delegatedFromUser : delegatedFromUser // ignore: cast_nullable_to_non_nullable
as UserRefDto?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ApprovalStepDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserRefDtoCopyWith<$Res>? get approverUser {
    if (_self.approverUser == null) {
    return null;
  }

  return $UserRefDtoCopyWith<$Res>(_self.approverUser!, (value) {
    return _then(_self.copyWith(approverUser: value));
  });
}/// Create a copy of ApprovalStepDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserRefDtoCopyWith<$Res>? get delegatedFromUser {
    if (_self.delegatedFromUser == null) {
    return null;
  }

  return $UserRefDtoCopyWith<$Res>(_self.delegatedFromUser!, (value) {
    return _then(_self.copyWith(delegatedFromUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [ApprovalStepDto].
extension ApprovalStepDtoPatterns on ApprovalStepDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApprovalStepDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApprovalStepDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApprovalStepDto value)  $default,){
final _that = this;
switch (_that) {
case _ApprovalStepDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApprovalStepDto value)?  $default,){
final _that = this;
switch (_that) {
case _ApprovalStepDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int stepNo,  String approverRoleCode,  ApprovalStatus decision,  UserRefDto? approverUser,  UserRefDto? delegatedFromUser,  DateTime? decidedAt,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApprovalStepDto() when $default != null:
return $default(_that.id,_that.stepNo,_that.approverRoleCode,_that.decision,_that.approverUser,_that.delegatedFromUser,_that.decidedAt,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int stepNo,  String approverRoleCode,  ApprovalStatus decision,  UserRefDto? approverUser,  UserRefDto? delegatedFromUser,  DateTime? decidedAt,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _ApprovalStepDto():
return $default(_that.id,_that.stepNo,_that.approverRoleCode,_that.decision,_that.approverUser,_that.delegatedFromUser,_that.decidedAt,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int stepNo,  String approverRoleCode,  ApprovalStatus decision,  UserRefDto? approverUser,  UserRefDto? delegatedFromUser,  DateTime? decidedAt,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _ApprovalStepDto() when $default != null:
return $default(_that.id,_that.stepNo,_that.approverRoleCode,_that.decision,_that.approverUser,_that.delegatedFromUser,_that.decidedAt,_that.comment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApprovalStepDto implements ApprovalStepDto {
  const _ApprovalStepDto({required this.id, required this.stepNo, required this.approverRoleCode, required this.decision, this.approverUser, this.delegatedFromUser, this.decidedAt, this.comment});
  factory _ApprovalStepDto.fromJson(Map<String, dynamic> json) => _$ApprovalStepDtoFromJson(json);

@override final  int id;
@override final  int stepNo;
@override final  String approverRoleCode;
@override final  ApprovalStatus decision;
@override final  UserRefDto? approverUser;
@override final  UserRefDto? delegatedFromUser;
@override final  DateTime? decidedAt;
@override final  String? comment;

/// Create a copy of ApprovalStepDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApprovalStepDtoCopyWith<_ApprovalStepDto> get copyWith => __$ApprovalStepDtoCopyWithImpl<_ApprovalStepDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApprovalStepDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApprovalStepDto&&(identical(other.id, id) || other.id == id)&&(identical(other.stepNo, stepNo) || other.stepNo == stepNo)&&(identical(other.approverRoleCode, approverRoleCode) || other.approverRoleCode == approverRoleCode)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.approverUser, approverUser) || other.approverUser == approverUser)&&(identical(other.delegatedFromUser, delegatedFromUser) || other.delegatedFromUser == delegatedFromUser)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,stepNo,approverRoleCode,decision,approverUser,delegatedFromUser,decidedAt,comment);
}

@override
String toString() {
    return 'ApprovalStepDto(id: $id, stepNo: $stepNo, approverRoleCode: $approverRoleCode, decision: $decision, approverUser: $approverUser, delegatedFromUser: $delegatedFromUser, decidedAt: $decidedAt, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$ApprovalStepDtoCopyWith<$Res> implements $ApprovalStepDtoCopyWith<$Res> {
  factory _$ApprovalStepDtoCopyWith(_ApprovalStepDto value, $Res Function(_ApprovalStepDto) _then) = __$ApprovalStepDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int stepNo, String approverRoleCode, ApprovalStatus decision, UserRefDto? approverUser, UserRefDto? delegatedFromUser, DateTime? decidedAt, String? comment
});


@override $UserRefDtoCopyWith<$Res>? get approverUser;@override $UserRefDtoCopyWith<$Res>? get delegatedFromUser;

}
/// @nodoc
class __$ApprovalStepDtoCopyWithImpl<$Res>
    implements _$ApprovalStepDtoCopyWith<$Res> {
  __$ApprovalStepDtoCopyWithImpl(this._self, this._then);

  final _ApprovalStepDto _self;
  final $Res Function(_ApprovalStepDto) _then;

/// Create a copy of ApprovalStepDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? stepNo = null,Object? approverRoleCode = null,Object? decision = null,Object? approverUser = freezed,Object? delegatedFromUser = freezed,Object? decidedAt = freezed,Object? comment = freezed,}) {
  return _then(_ApprovalStepDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,stepNo: null == stepNo ? _self.stepNo : stepNo // ignore: cast_nullable_to_non_nullable
as int,approverRoleCode: null == approverRoleCode ? _self.approverRoleCode : approverRoleCode // ignore: cast_nullable_to_non_nullable
as String,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as ApprovalStatus,approverUser: freezed == approverUser ? _self.approverUser : approverUser // ignore: cast_nullable_to_non_nullable
as UserRefDto?,delegatedFromUser: freezed == delegatedFromUser ? _self.delegatedFromUser : delegatedFromUser // ignore: cast_nullable_to_non_nullable
as UserRefDto?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ApprovalStepDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserRefDtoCopyWith<$Res>? get approverUser {
    if (_self.approverUser == null) {
    return null;
  }

  return $UserRefDtoCopyWith<$Res>(_self.approverUser!, (value) {
    return _then(_self.copyWith(approverUser: value));
  });
}/// Create a copy of ApprovalStepDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserRefDtoCopyWith<$Res>? get delegatedFromUser {
    if (_self.delegatedFromUser == null) {
    return null;
  }

  return $UserRefDtoCopyWith<$Res>(_self.delegatedFromUser!, (value) {
    return _then(_self.copyWith(delegatedFromUser: value));
  });
}
}


/// @nodoc
mixin _$PurchaseOrderDto {

 int get id; String get docNo;@DateOnlyConverter() DateTime get docDate; SupplierRefDto get supplier; String get currency; Money get totalAmount; Money get totalAmountBase; Decimal? get fxRate; Money? get subtotal; Money? get vatAmount; LocationRefDto get deliveryLocation; PoStatus get status;@NullableDateOnlyConverter() DateTime? get expectedDate; String? get incoterms; DateTime? get sentAt; DateTime? get createdAt; UserRefDto? get createdBy; int get rowVersion; List<PurchaseOrderLineDto> get lines; List<ApprovalStepDto> get approvalSteps;
/// Create a copy of PurchaseOrderDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderDtoCopyWith<PurchaseOrderDto> get copyWith => _$PurchaseOrderDtoCopyWithImpl<PurchaseOrderDto>(this as PurchaseOrderDto, _$identity);

  /// Serializes this PurchaseOrderDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PurchaseOrderDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrderDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.docDate, _this.docDate) || other.docDate == _this.docDate)&&(identical(other.supplier, _this.supplier) || other.supplier == _this.supplier)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.totalAmount, _this.totalAmount) || other.totalAmount == _this.totalAmount)&&(identical(other.totalAmountBase, _this.totalAmountBase) || other.totalAmountBase == _this.totalAmountBase)&&(identical(other.fxRate, _this.fxRate) || other.fxRate == _this.fxRate)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.vatAmount, _this.vatAmount) || other.vatAmount == _this.vatAmount)&&(identical(other.deliveryLocation, _this.deliveryLocation) || other.deliveryLocation == _this.deliveryLocation)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.expectedDate, _this.expectedDate) || other.expectedDate == _this.expectedDate)&&(identical(other.incoterms, _this.incoterms) || other.incoterms == _this.incoterms)&&(identical(other.sentAt, _this.sentAt) || other.sentAt == _this.sentAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&const DeepCollectionEquality().equals(other.approvalSteps, _this.approvalSteps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PurchaseOrderDto;
  return Object.hashAll([runtimeType,_this.id,_this.docNo,_this.docDate,_this.supplier,_this.currency,_this.totalAmount,_this.totalAmountBase,_this.fxRate,_this.subtotal,_this.vatAmount,_this.deliveryLocation,_this.status,_this.expectedDate,_this.incoterms,_this.sentAt,_this.createdAt,_this.createdBy,_this.rowVersion,const DeepCollectionEquality().hash(_this.lines),const DeepCollectionEquality().hash(_this.approvalSteps)]);
}

@override
String toString() {
  final _this = this as PurchaseOrderDto;
  return 'PurchaseOrderDto(id: ${_this.id}, docNo: ${_this.docNo}, docDate: ${_this.docDate}, supplier: ${_this.supplier}, currency: ${_this.currency}, totalAmount: ${_this.totalAmount}, totalAmountBase: ${_this.totalAmountBase}, fxRate: ${_this.fxRate}, subtotal: ${_this.subtotal}, vatAmount: ${_this.vatAmount}, deliveryLocation: ${_this.deliveryLocation}, status: ${_this.status}, expectedDate: ${_this.expectedDate}, incoterms: ${_this.incoterms}, sentAt: ${_this.sentAt}, createdAt: ${_this.createdAt}, createdBy: ${_this.createdBy}, rowVersion: ${_this.rowVersion}, lines: ${_this.lines}, approvalSteps: ${_this.approvalSteps})';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderDtoCopyWith<$Res>  {
  factory $PurchaseOrderDtoCopyWith(PurchaseOrderDto value, $Res Function(PurchaseOrderDto) _then) = _$PurchaseOrderDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, SupplierRefDto supplier, String currency, Money totalAmount, Money totalAmountBase, Decimal? fxRate, Money? subtotal, Money? vatAmount, LocationRefDto deliveryLocation, PoStatus status,@NullableDateOnlyConverter() DateTime? expectedDate, String? incoterms, DateTime? sentAt, DateTime? createdAt, UserRefDto? createdBy, int rowVersion, List<PurchaseOrderLineDto> lines, List<ApprovalStepDto> approvalSteps
});


$SupplierRefDtoCopyWith<$Res> get supplier;$LocationRefDtoCopyWith<$Res> get deliveryLocation;$UserRefDtoCopyWith<$Res>? get createdBy;

}
/// @nodoc
class _$PurchaseOrderDtoCopyWithImpl<$Res>
    implements $PurchaseOrderDtoCopyWith<$Res> {
  _$PurchaseOrderDtoCopyWithImpl(this._self, this._then);

  final PurchaseOrderDto _self;
  final $Res Function(PurchaseOrderDto) _then;

/// Create a copy of PurchaseOrderDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? supplier = null,Object? currency = null,Object? totalAmount = null,Object? totalAmountBase = null,Object? fxRate = freezed,Object? subtotal = freezed,Object? vatAmount = freezed,Object? deliveryLocation = null,Object? status = null,Object? expectedDate = freezed,Object? incoterms = freezed,Object? sentAt = freezed,Object? createdAt = freezed,Object? createdBy = freezed,Object? rowVersion = null,Object? lines = null,Object? approvalSteps = null,}) {
  return _then(PurchaseOrderDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,supplier: null == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as SupplierRefDto,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,totalAmountBase: null == totalAmountBase ? _self.totalAmountBase : totalAmountBase // ignore: cast_nullable_to_non_nullable
as Money,fxRate: freezed == fxRate ? _self.fxRate : fxRate // ignore: cast_nullable_to_non_nullable
as Decimal?,subtotal: freezed == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as Money?,vatAmount: freezed == vatAmount ? _self.vatAmount : vatAmount // ignore: cast_nullable_to_non_nullable
as Money?,deliveryLocation: null == deliveryLocation ? _self.deliveryLocation : deliveryLocation // ignore: cast_nullable_to_non_nullable
as LocationRefDto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PoStatus,expectedDate: freezed == expectedDate ? _self.expectedDate : expectedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,incoterms: freezed == incoterms ? _self.incoterms : incoterms // ignore: cast_nullable_to_non_nullable
as String?,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as UserRefDto?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<PurchaseOrderLineDto>,approvalSteps: null == approvalSteps ? _self.approvalSteps : approvalSteps // ignore: cast_nullable_to_non_nullable
as List<ApprovalStepDto>,
  ));
}
/// Create a copy of PurchaseOrderDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupplierRefDtoCopyWith<$Res> get supplier {
  
  return $SupplierRefDtoCopyWith<$Res>(_self.supplier, (value) {
    return _then(_self.copyWith(supplier: value));
  });
}/// Create a copy of PurchaseOrderDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get deliveryLocation {
  
  return $LocationRefDtoCopyWith<$Res>(_self.deliveryLocation, (value) {
    return _then(_self.copyWith(deliveryLocation: value));
  });
}/// Create a copy of PurchaseOrderDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserRefDtoCopyWith<$Res>? get createdBy {
    if (_self.createdBy == null) {
    return null;
  }

  return $UserRefDtoCopyWith<$Res>(_self.createdBy!, (value) {
    return _then(_self.copyWith(createdBy: value));
  });
}
}


/// Adds pattern-matching-related methods to [PurchaseOrderDto].
extension PurchaseOrderDtoPatterns on PurchaseOrderDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrderDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrderDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrderDto value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrderDto value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  SupplierRefDto supplier,  String currency,  Money totalAmount,  Money totalAmountBase,  Decimal? fxRate,  Money? subtotal,  Money? vatAmount,  LocationRefDto deliveryLocation,  PoStatus status, @NullableDateOnlyConverter()  DateTime? expectedDate,  String? incoterms,  DateTime? sentAt,  DateTime? createdAt,  UserRefDto? createdBy,  int rowVersion,  List<PurchaseOrderLineDto> lines,  List<ApprovalStepDto> approvalSteps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrderDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.supplier,_that.currency,_that.totalAmount,_that.totalAmountBase,_that.fxRate,_that.subtotal,_that.vatAmount,_that.deliveryLocation,_that.status,_that.expectedDate,_that.incoterms,_that.sentAt,_that.createdAt,_that.createdBy,_that.rowVersion,_that.lines,_that.approvalSteps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  SupplierRefDto supplier,  String currency,  Money totalAmount,  Money totalAmountBase,  Decimal? fxRate,  Money? subtotal,  Money? vatAmount,  LocationRefDto deliveryLocation,  PoStatus status, @NullableDateOnlyConverter()  DateTime? expectedDate,  String? incoterms,  DateTime? sentAt,  DateTime? createdAt,  UserRefDto? createdBy,  int rowVersion,  List<PurchaseOrderLineDto> lines,  List<ApprovalStepDto> approvalSteps)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderDto():
return $default(_that.id,_that.docNo,_that.docDate,_that.supplier,_that.currency,_that.totalAmount,_that.totalAmountBase,_that.fxRate,_that.subtotal,_that.vatAmount,_that.deliveryLocation,_that.status,_that.expectedDate,_that.incoterms,_that.sentAt,_that.createdAt,_that.createdBy,_that.rowVersion,_that.lines,_that.approvalSteps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo, @DateOnlyConverter()  DateTime docDate,  SupplierRefDto supplier,  String currency,  Money totalAmount,  Money totalAmountBase,  Decimal? fxRate,  Money? subtotal,  Money? vatAmount,  LocationRefDto deliveryLocation,  PoStatus status, @NullableDateOnlyConverter()  DateTime? expectedDate,  String? incoterms,  DateTime? sentAt,  DateTime? createdAt,  UserRefDto? createdBy,  int rowVersion,  List<PurchaseOrderLineDto> lines,  List<ApprovalStepDto> approvalSteps)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderDto() when $default != null:
return $default(_that.id,_that.docNo,_that.docDate,_that.supplier,_that.currency,_that.totalAmount,_that.totalAmountBase,_that.fxRate,_that.subtotal,_that.vatAmount,_that.deliveryLocation,_that.status,_that.expectedDate,_that.incoterms,_that.sentAt,_that.createdAt,_that.createdBy,_that.rowVersion,_that.lines,_that.approvalSteps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseOrderDto implements PurchaseOrderDto {
  const _PurchaseOrderDto({required this.id, required this.docNo, @DateOnlyConverter() required this.docDate, required this.supplier, required this.currency, required this.totalAmount, required this.totalAmountBase, this.fxRate, this.subtotal, this.vatAmount, required this.deliveryLocation, required this.status, @NullableDateOnlyConverter() this.expectedDate, this.incoterms, this.sentAt, this.createdAt, this.createdBy, this.rowVersion = 1,  List<PurchaseOrderLineDto> lines = const <PurchaseOrderLineDto>[],  List<ApprovalStepDto> approvalSteps = const <ApprovalStepDto>[]}): _lines = lines,_approvalSteps = approvalSteps;
  factory _PurchaseOrderDto.fromJson(Map<String, dynamic> json) => _$PurchaseOrderDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override@DateOnlyConverter() final  DateTime docDate;
@override final  SupplierRefDto supplier;
@override final  String currency;
@override final  Money totalAmount;
@override final  Money totalAmountBase;
@override final  Decimal? fxRate;
@override final  Money? subtotal;
@override final  Money? vatAmount;
@override final  LocationRefDto deliveryLocation;
@override final  PoStatus status;
@override@NullableDateOnlyConverter() final  DateTime? expectedDate;
@override final  String? incoterms;
@override final  DateTime? sentAt;
@override final  DateTime? createdAt;
@override final  UserRefDto? createdBy;
@override@JsonKey() final  int rowVersion;
 final  List<PurchaseOrderLineDto> _lines;
@override@JsonKey() List<PurchaseOrderLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

 final  List<ApprovalStepDto> _approvalSteps;
@override@JsonKey() List<ApprovalStepDto> get approvalSteps {
  if (_approvalSteps is EqualUnmodifiableListView) return _approvalSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_approvalSteps);
}


/// Create a copy of PurchaseOrderDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderDtoCopyWith<_PurchaseOrderDto> get copyWith => __$PurchaseOrderDtoCopyWithImpl<_PurchaseOrderDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseOrderDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrderDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.docDate, docDate) || other.docDate == docDate)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.totalAmountBase, totalAmountBase) || other.totalAmountBase == totalAmountBase)&&(identical(other.fxRate, fxRate) || other.fxRate == fxRate)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.vatAmount, vatAmount) || other.vatAmount == vatAmount)&&(identical(other.deliveryLocation, deliveryLocation) || other.deliveryLocation == deliveryLocation)&&(identical(other.status, status) || other.status == status)&&(identical(other.expectedDate, expectedDate) || other.expectedDate == expectedDate)&&(identical(other.incoterms, incoterms) || other.incoterms == incoterms)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines)&&const DeepCollectionEquality().equals(other.approvalSteps, _approvalSteps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,docNo,docDate,supplier,currency,totalAmount,totalAmountBase,fxRate,subtotal,vatAmount,deliveryLocation,status,expectedDate,incoterms,sentAt,createdAt,createdBy,rowVersion,const DeepCollectionEquality().hash(_lines),const DeepCollectionEquality().hash(_approvalSteps)]);
}

@override
String toString() {
    return 'PurchaseOrderDto(id: $id, docNo: $docNo, docDate: $docDate, supplier: $supplier, currency: $currency, totalAmount: $totalAmount, totalAmountBase: $totalAmountBase, fxRate: $fxRate, subtotal: $subtotal, vatAmount: $vatAmount, deliveryLocation: $deliveryLocation, status: $status, expectedDate: $expectedDate, incoterms: $incoterms, sentAt: $sentAt, createdAt: $createdAt, createdBy: $createdBy, rowVersion: $rowVersion, lines: $lines, approvalSteps: $approvalSteps)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderDtoCopyWith<$Res> implements $PurchaseOrderDtoCopyWith<$Res> {
  factory _$PurchaseOrderDtoCopyWith(_PurchaseOrderDto value, $Res Function(_PurchaseOrderDto) _then) = __$PurchaseOrderDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo,@DateOnlyConverter() DateTime docDate, SupplierRefDto supplier, String currency, Money totalAmount, Money totalAmountBase, Decimal? fxRate, Money? subtotal, Money? vatAmount, LocationRefDto deliveryLocation, PoStatus status,@NullableDateOnlyConverter() DateTime? expectedDate, String? incoterms, DateTime? sentAt, DateTime? createdAt, UserRefDto? createdBy, int rowVersion, List<PurchaseOrderLineDto> lines, List<ApprovalStepDto> approvalSteps
});


@override $SupplierRefDtoCopyWith<$Res> get supplier;@override $LocationRefDtoCopyWith<$Res> get deliveryLocation;@override $UserRefDtoCopyWith<$Res>? get createdBy;

}
/// @nodoc
class __$PurchaseOrderDtoCopyWithImpl<$Res>
    implements _$PurchaseOrderDtoCopyWith<$Res> {
  __$PurchaseOrderDtoCopyWithImpl(this._self, this._then);

  final _PurchaseOrderDto _self;
  final $Res Function(_PurchaseOrderDto) _then;

/// Create a copy of PurchaseOrderDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? docDate = null,Object? supplier = null,Object? currency = null,Object? totalAmount = null,Object? totalAmountBase = null,Object? fxRate = freezed,Object? subtotal = freezed,Object? vatAmount = freezed,Object? deliveryLocation = null,Object? status = null,Object? expectedDate = freezed,Object? incoterms = freezed,Object? sentAt = freezed,Object? createdAt = freezed,Object? createdBy = freezed,Object? rowVersion = null,Object? lines = null,Object? approvalSteps = null,}) {
  return _then(_PurchaseOrderDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,docDate: null == docDate ? _self.docDate : docDate // ignore: cast_nullable_to_non_nullable
as DateTime,supplier: null == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as SupplierRefDto,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,totalAmountBase: null == totalAmountBase ? _self.totalAmountBase : totalAmountBase // ignore: cast_nullable_to_non_nullable
as Money,fxRate: freezed == fxRate ? _self.fxRate : fxRate // ignore: cast_nullable_to_non_nullable
as Decimal?,subtotal: freezed == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as Money?,vatAmount: freezed == vatAmount ? _self.vatAmount : vatAmount // ignore: cast_nullable_to_non_nullable
as Money?,deliveryLocation: null == deliveryLocation ? _self.deliveryLocation : deliveryLocation // ignore: cast_nullable_to_non_nullable
as LocationRefDto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PoStatus,expectedDate: freezed == expectedDate ? _self.expectedDate : expectedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,incoterms: freezed == incoterms ? _self.incoterms : incoterms // ignore: cast_nullable_to_non_nullable
as String?,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as UserRefDto?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<PurchaseOrderLineDto>,approvalSteps: null == approvalSteps ? _self._approvalSteps : approvalSteps // ignore: cast_nullable_to_non_nullable
as List<ApprovalStepDto>,
  ));
}

/// Create a copy of PurchaseOrderDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupplierRefDtoCopyWith<$Res> get supplier {
  
  return $SupplierRefDtoCopyWith<$Res>(_self.supplier, (value) {
    return _then(_self.copyWith(supplier: value));
  });
}/// Create a copy of PurchaseOrderDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationRefDtoCopyWith<$Res> get deliveryLocation {
  
  return $LocationRefDtoCopyWith<$Res>(_self.deliveryLocation, (value) {
    return _then(_self.copyWith(deliveryLocation: value));
  });
}/// Create a copy of PurchaseOrderDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserRefDtoCopyWith<$Res>? get createdBy {
    if (_self.createdBy == null) {
    return null;
  }

  return $UserRefDtoCopyWith<$Res>(_self.createdBy!, (value) {
    return _then(_self.copyWith(createdBy: value));
  });
}
}


/// @nodoc
mixin _$ApprovalDecisionRequest {

 int get rowVersion; String? get comment;
/// Create a copy of ApprovalDecisionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApprovalDecisionRequestCopyWith<ApprovalDecisionRequest> get copyWith => _$ApprovalDecisionRequestCopyWithImpl<ApprovalDecisionRequest>(this as ApprovalDecisionRequest, _$identity);

  /// Serializes this ApprovalDecisionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ApprovalDecisionRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApprovalDecisionRequest&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApprovalDecisionRequest;
  return Object.hash(runtimeType,_this.rowVersion,_this.comment);
}

@override
String toString() {
  final _this = this as ApprovalDecisionRequest;
  return 'ApprovalDecisionRequest(rowVersion: ${_this.rowVersion}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $ApprovalDecisionRequestCopyWith<$Res>  {
  factory $ApprovalDecisionRequestCopyWith(ApprovalDecisionRequest value, $Res Function(ApprovalDecisionRequest) _then) = _$ApprovalDecisionRequestCopyWithImpl;
@useResult
$Res call({
 int rowVersion, String? comment
});




}
/// @nodoc
class _$ApprovalDecisionRequestCopyWithImpl<$Res>
    implements $ApprovalDecisionRequestCopyWith<$Res> {
  _$ApprovalDecisionRequestCopyWithImpl(this._self, this._then);

  final ApprovalDecisionRequest _self;
  final $Res Function(ApprovalDecisionRequest) _then;

/// Create a copy of ApprovalDecisionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowVersion = null,Object? comment = freezed,}) {
  return _then(ApprovalDecisionRequest(
rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApprovalDecisionRequest].
extension ApprovalDecisionRequestPatterns on ApprovalDecisionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApprovalDecisionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApprovalDecisionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApprovalDecisionRequest value)  $default,){
final _that = this;
switch (_that) {
case _ApprovalDecisionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApprovalDecisionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ApprovalDecisionRequest() when $default != null:
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
case _ApprovalDecisionRequest() when $default != null:
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
case _ApprovalDecisionRequest():
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
case _ApprovalDecisionRequest() when $default != null:
return $default(_that.rowVersion,_that.comment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApprovalDecisionRequest implements ApprovalDecisionRequest {
  const _ApprovalDecisionRequest({required this.rowVersion, this.comment});
  factory _ApprovalDecisionRequest.fromJson(Map<String, dynamic> json) => _$ApprovalDecisionRequestFromJson(json);

@override final  int rowVersion;
@override final  String? comment;

/// Create a copy of ApprovalDecisionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApprovalDecisionRequestCopyWith<_ApprovalDecisionRequest> get copyWith => __$ApprovalDecisionRequestCopyWithImpl<_ApprovalDecisionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApprovalDecisionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApprovalDecisionRequest&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rowVersion,comment);
}

@override
String toString() {
    return 'ApprovalDecisionRequest(rowVersion: $rowVersion, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$ApprovalDecisionRequestCopyWith<$Res> implements $ApprovalDecisionRequestCopyWith<$Res> {
  factory _$ApprovalDecisionRequestCopyWith(_ApprovalDecisionRequest value, $Res Function(_ApprovalDecisionRequest) _then) = __$ApprovalDecisionRequestCopyWithImpl;
@override @useResult
$Res call({
 int rowVersion, String? comment
});




}
/// @nodoc
class __$ApprovalDecisionRequestCopyWithImpl<$Res>
    implements _$ApprovalDecisionRequestCopyWith<$Res> {
  __$ApprovalDecisionRequestCopyWithImpl(this._self, this._then);

  final _ApprovalDecisionRequest _self;
  final $Res Function(_ApprovalDecisionRequest) _then;

/// Create a copy of ApprovalDecisionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowVersion = null,Object? comment = freezed,}) {
  return _then(_ApprovalDecisionRequest(
rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PriceHistoryDto {

 int get id; ProductRefDto get product; SupplierRefDto get supplier;@DateOnlyConverter() DateTime get priceDate; Money get unitPrice; String get currency; Money get unitPriceBase; int? get poId; String? get poDocNo; Money? get prevPriceBase; Money? get diffAmount; Decimal? get diffPct;
/// Create a copy of PriceHistoryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceHistoryDtoCopyWith<PriceHistoryDto> get copyWith => _$PriceHistoryDtoCopyWithImpl<PriceHistoryDto>(this as PriceHistoryDto, _$identity);

  /// Serializes this PriceHistoryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PriceHistoryDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceHistoryDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.supplier, _this.supplier) || other.supplier == _this.supplier)&&(identical(other.priceDate, _this.priceDate) || other.priceDate == _this.priceDate)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.unitPriceBase, _this.unitPriceBase) || other.unitPriceBase == _this.unitPriceBase)&&(identical(other.poId, _this.poId) || other.poId == _this.poId)&&(identical(other.poDocNo, _this.poDocNo) || other.poDocNo == _this.poDocNo)&&(identical(other.prevPriceBase, _this.prevPriceBase) || other.prevPriceBase == _this.prevPriceBase)&&(identical(other.diffAmount, _this.diffAmount) || other.diffAmount == _this.diffAmount)&&(identical(other.diffPct, _this.diffPct) || other.diffPct == _this.diffPct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PriceHistoryDto;
  return Object.hash(runtimeType,_this.id,_this.product,_this.supplier,_this.priceDate,_this.unitPrice,_this.currency,_this.unitPriceBase,_this.poId,_this.poDocNo,_this.prevPriceBase,_this.diffAmount,_this.diffPct);
}

@override
String toString() {
  final _this = this as PriceHistoryDto;
  return 'PriceHistoryDto(id: ${_this.id}, product: ${_this.product}, supplier: ${_this.supplier}, priceDate: ${_this.priceDate}, unitPrice: ${_this.unitPrice}, currency: ${_this.currency}, unitPriceBase: ${_this.unitPriceBase}, poId: ${_this.poId}, poDocNo: ${_this.poDocNo}, prevPriceBase: ${_this.prevPriceBase}, diffAmount: ${_this.diffAmount}, diffPct: ${_this.diffPct})';
}


}

/// @nodoc
abstract mixin class $PriceHistoryDtoCopyWith<$Res>  {
  factory $PriceHistoryDtoCopyWith(PriceHistoryDto value, $Res Function(PriceHistoryDto) _then) = _$PriceHistoryDtoCopyWithImpl;
@useResult
$Res call({
 int id, ProductRefDto product, SupplierRefDto supplier,@DateOnlyConverter() DateTime priceDate, Money unitPrice, String currency, Money unitPriceBase, int? poId, String? poDocNo, Money? prevPriceBase, Money? diffAmount, Decimal? diffPct
});


$ProductRefDtoCopyWith<$Res> get product;$SupplierRefDtoCopyWith<$Res> get supplier;

}
/// @nodoc
class _$PriceHistoryDtoCopyWithImpl<$Res>
    implements $PriceHistoryDtoCopyWith<$Res> {
  _$PriceHistoryDtoCopyWithImpl(this._self, this._then);

  final PriceHistoryDto _self;
  final $Res Function(PriceHistoryDto) _then;

/// Create a copy of PriceHistoryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? product = null,Object? supplier = null,Object? priceDate = null,Object? unitPrice = null,Object? currency = null,Object? unitPriceBase = null,Object? poId = freezed,Object? poDocNo = freezed,Object? prevPriceBase = freezed,Object? diffAmount = freezed,Object? diffPct = freezed,}) {
  return _then(PriceHistoryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,supplier: null == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as SupplierRefDto,priceDate: null == priceDate ? _self.priceDate : priceDate // ignore: cast_nullable_to_non_nullable
as DateTime,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,unitPriceBase: null == unitPriceBase ? _self.unitPriceBase : unitPriceBase // ignore: cast_nullable_to_non_nullable
as Money,poId: freezed == poId ? _self.poId : poId // ignore: cast_nullable_to_non_nullable
as int?,poDocNo: freezed == poDocNo ? _self.poDocNo : poDocNo // ignore: cast_nullable_to_non_nullable
as String?,prevPriceBase: freezed == prevPriceBase ? _self.prevPriceBase : prevPriceBase // ignore: cast_nullable_to_non_nullable
as Money?,diffAmount: freezed == diffAmount ? _self.diffAmount : diffAmount // ignore: cast_nullable_to_non_nullable
as Money?,diffPct: freezed == diffPct ? _self.diffPct : diffPct // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}
/// Create a copy of PriceHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of PriceHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupplierRefDtoCopyWith<$Res> get supplier {
  
  return $SupplierRefDtoCopyWith<$Res>(_self.supplier, (value) {
    return _then(_self.copyWith(supplier: value));
  });
}
}


/// Adds pattern-matching-related methods to [PriceHistoryDto].
extension PriceHistoryDtoPatterns on PriceHistoryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceHistoryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceHistoryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceHistoryDto value)  $default,){
final _that = this;
switch (_that) {
case _PriceHistoryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceHistoryDto value)?  $default,){
final _that = this;
switch (_that) {
case _PriceHistoryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  ProductRefDto product,  SupplierRefDto supplier, @DateOnlyConverter()  DateTime priceDate,  Money unitPrice,  String currency,  Money unitPriceBase,  int? poId,  String? poDocNo,  Money? prevPriceBase,  Money? diffAmount,  Decimal? diffPct)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceHistoryDto() when $default != null:
return $default(_that.id,_that.product,_that.supplier,_that.priceDate,_that.unitPrice,_that.currency,_that.unitPriceBase,_that.poId,_that.poDocNo,_that.prevPriceBase,_that.diffAmount,_that.diffPct);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  ProductRefDto product,  SupplierRefDto supplier, @DateOnlyConverter()  DateTime priceDate,  Money unitPrice,  String currency,  Money unitPriceBase,  int? poId,  String? poDocNo,  Money? prevPriceBase,  Money? diffAmount,  Decimal? diffPct)  $default,) {final _that = this;
switch (_that) {
case _PriceHistoryDto():
return $default(_that.id,_that.product,_that.supplier,_that.priceDate,_that.unitPrice,_that.currency,_that.unitPriceBase,_that.poId,_that.poDocNo,_that.prevPriceBase,_that.diffAmount,_that.diffPct);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  ProductRefDto product,  SupplierRefDto supplier, @DateOnlyConverter()  DateTime priceDate,  Money unitPrice,  String currency,  Money unitPriceBase,  int? poId,  String? poDocNo,  Money? prevPriceBase,  Money? diffAmount,  Decimal? diffPct)?  $default,) {final _that = this;
switch (_that) {
case _PriceHistoryDto() when $default != null:
return $default(_that.id,_that.product,_that.supplier,_that.priceDate,_that.unitPrice,_that.currency,_that.unitPriceBase,_that.poId,_that.poDocNo,_that.prevPriceBase,_that.diffAmount,_that.diffPct);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceHistoryDto implements PriceHistoryDto {
  const _PriceHistoryDto({required this.id, required this.product, required this.supplier, @DateOnlyConverter() required this.priceDate, required this.unitPrice, required this.currency, required this.unitPriceBase, this.poId, this.poDocNo, this.prevPriceBase, this.diffAmount, this.diffPct});
  factory _PriceHistoryDto.fromJson(Map<String, dynamic> json) => _$PriceHistoryDtoFromJson(json);

@override final  int id;
@override final  ProductRefDto product;
@override final  SupplierRefDto supplier;
@override@DateOnlyConverter() final  DateTime priceDate;
@override final  Money unitPrice;
@override final  String currency;
@override final  Money unitPriceBase;
@override final  int? poId;
@override final  String? poDocNo;
@override final  Money? prevPriceBase;
@override final  Money? diffAmount;
@override final  Decimal? diffPct;

/// Create a copy of PriceHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceHistoryDtoCopyWith<_PriceHistoryDto> get copyWith => __$PriceHistoryDtoCopyWithImpl<_PriceHistoryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceHistoryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceHistoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&(identical(other.priceDate, priceDate) || other.priceDate == priceDate)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.unitPriceBase, unitPriceBase) || other.unitPriceBase == unitPriceBase)&&(identical(other.poId, poId) || other.poId == poId)&&(identical(other.poDocNo, poDocNo) || other.poDocNo == poDocNo)&&(identical(other.prevPriceBase, prevPriceBase) || other.prevPriceBase == prevPriceBase)&&(identical(other.diffAmount, diffAmount) || other.diffAmount == diffAmount)&&(identical(other.diffPct, diffPct) || other.diffPct == diffPct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,product,supplier,priceDate,unitPrice,currency,unitPriceBase,poId,poDocNo,prevPriceBase,diffAmount,diffPct);
}

@override
String toString() {
    return 'PriceHistoryDto(id: $id, product: $product, supplier: $supplier, priceDate: $priceDate, unitPrice: $unitPrice, currency: $currency, unitPriceBase: $unitPriceBase, poId: $poId, poDocNo: $poDocNo, prevPriceBase: $prevPriceBase, diffAmount: $diffAmount, diffPct: $diffPct)';
}


}

/// @nodoc
abstract mixin class _$PriceHistoryDtoCopyWith<$Res> implements $PriceHistoryDtoCopyWith<$Res> {
  factory _$PriceHistoryDtoCopyWith(_PriceHistoryDto value, $Res Function(_PriceHistoryDto) _then) = __$PriceHistoryDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, ProductRefDto product, SupplierRefDto supplier,@DateOnlyConverter() DateTime priceDate, Money unitPrice, String currency, Money unitPriceBase, int? poId, String? poDocNo, Money? prevPriceBase, Money? diffAmount, Decimal? diffPct
});


@override $ProductRefDtoCopyWith<$Res> get product;@override $SupplierRefDtoCopyWith<$Res> get supplier;

}
/// @nodoc
class __$PriceHistoryDtoCopyWithImpl<$Res>
    implements _$PriceHistoryDtoCopyWith<$Res> {
  __$PriceHistoryDtoCopyWithImpl(this._self, this._then);

  final _PriceHistoryDto _self;
  final $Res Function(_PriceHistoryDto) _then;

/// Create a copy of PriceHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? product = null,Object? supplier = null,Object? priceDate = null,Object? unitPrice = null,Object? currency = null,Object? unitPriceBase = null,Object? poId = freezed,Object? poDocNo = freezed,Object? prevPriceBase = freezed,Object? diffAmount = freezed,Object? diffPct = freezed,}) {
  return _then(_PriceHistoryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefDto,supplier: null == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as SupplierRefDto,priceDate: null == priceDate ? _self.priceDate : priceDate // ignore: cast_nullable_to_non_nullable
as DateTime,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,unitPriceBase: null == unitPriceBase ? _self.unitPriceBase : unitPriceBase // ignore: cast_nullable_to_non_nullable
as Money,poId: freezed == poId ? _self.poId : poId // ignore: cast_nullable_to_non_nullable
as int?,poDocNo: freezed == poDocNo ? _self.poDocNo : poDocNo // ignore: cast_nullable_to_non_nullable
as String?,prevPriceBase: freezed == prevPriceBase ? _self.prevPriceBase : prevPriceBase // ignore: cast_nullable_to_non_nullable
as Money?,diffAmount: freezed == diffAmount ? _self.diffAmount : diffAmount // ignore: cast_nullable_to_non_nullable
as Money?,diffPct: freezed == diffPct ? _self.diffPct : diffPct // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}

/// Create a copy of PriceHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRefDtoCopyWith<$Res> get product {
  
  return $ProductRefDtoCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of PriceHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupplierRefDtoCopyWith<$Res> get supplier {
  
  return $SupplierRefDtoCopyWith<$Res>(_self.supplier, (value) {
    return _then(_self.copyWith(supplier: value));
  });
}
}

// dart format on
