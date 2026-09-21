// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reporting_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardSummaryDto {

 DateTime get asOf; Money? get stockValue; int get expiringBatches; int get expiredBatches; int get lowStockProducts; int get pendingApprovals; int get openPurchaseOrders; int get inTransitIssues;
/// Create a copy of DashboardSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSummaryDtoCopyWith<DashboardSummaryDto> get copyWith => _$DashboardSummaryDtoCopyWithImpl<DashboardSummaryDto>(this as DashboardSummaryDto, _$identity);

  /// Serializes this DashboardSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DashboardSummaryDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSummaryDto&&(identical(other.asOf, _this.asOf) || other.asOf == _this.asOf)&&(identical(other.stockValue, _this.stockValue) || other.stockValue == _this.stockValue)&&(identical(other.expiringBatches, _this.expiringBatches) || other.expiringBatches == _this.expiringBatches)&&(identical(other.expiredBatches, _this.expiredBatches) || other.expiredBatches == _this.expiredBatches)&&(identical(other.lowStockProducts, _this.lowStockProducts) || other.lowStockProducts == _this.lowStockProducts)&&(identical(other.pendingApprovals, _this.pendingApprovals) || other.pendingApprovals == _this.pendingApprovals)&&(identical(other.openPurchaseOrders, _this.openPurchaseOrders) || other.openPurchaseOrders == _this.openPurchaseOrders)&&(identical(other.inTransitIssues, _this.inTransitIssues) || other.inTransitIssues == _this.inTransitIssues));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DashboardSummaryDto;
  return Object.hash(runtimeType,_this.asOf,_this.stockValue,_this.expiringBatches,_this.expiredBatches,_this.lowStockProducts,_this.pendingApprovals,_this.openPurchaseOrders,_this.inTransitIssues);
}

@override
String toString() {
  final _this = this as DashboardSummaryDto;
  return 'DashboardSummaryDto(asOf: ${_this.asOf}, stockValue: ${_this.stockValue}, expiringBatches: ${_this.expiringBatches}, expiredBatches: ${_this.expiredBatches}, lowStockProducts: ${_this.lowStockProducts}, pendingApprovals: ${_this.pendingApprovals}, openPurchaseOrders: ${_this.openPurchaseOrders}, inTransitIssues: ${_this.inTransitIssues})';
}


}

/// @nodoc
abstract mixin class $DashboardSummaryDtoCopyWith<$Res>  {
  factory $DashboardSummaryDtoCopyWith(DashboardSummaryDto value, $Res Function(DashboardSummaryDto) _then) = _$DashboardSummaryDtoCopyWithImpl;
@useResult
$Res call({
 DateTime asOf, Money? stockValue, int expiringBatches, int expiredBatches, int lowStockProducts, int pendingApprovals, int openPurchaseOrders, int inTransitIssues
});




}
/// @nodoc
class _$DashboardSummaryDtoCopyWithImpl<$Res>
    implements $DashboardSummaryDtoCopyWith<$Res> {
  _$DashboardSummaryDtoCopyWithImpl(this._self, this._then);

  final DashboardSummaryDto _self;
  final $Res Function(DashboardSummaryDto) _then;

/// Create a copy of DashboardSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? asOf = null,Object? stockValue = freezed,Object? expiringBatches = null,Object? expiredBatches = null,Object? lowStockProducts = null,Object? pendingApprovals = null,Object? openPurchaseOrders = null,Object? inTransitIssues = null,}) {
  return _then(DashboardSummaryDto(
asOf: null == asOf ? _self.asOf : asOf // ignore: cast_nullable_to_non_nullable
as DateTime,stockValue: freezed == stockValue ? _self.stockValue : stockValue // ignore: cast_nullable_to_non_nullable
as Money?,expiringBatches: null == expiringBatches ? _self.expiringBatches : expiringBatches // ignore: cast_nullable_to_non_nullable
as int,expiredBatches: null == expiredBatches ? _self.expiredBatches : expiredBatches // ignore: cast_nullable_to_non_nullable
as int,lowStockProducts: null == lowStockProducts ? _self.lowStockProducts : lowStockProducts // ignore: cast_nullable_to_non_nullable
as int,pendingApprovals: null == pendingApprovals ? _self.pendingApprovals : pendingApprovals // ignore: cast_nullable_to_non_nullable
as int,openPurchaseOrders: null == openPurchaseOrders ? _self.openPurchaseOrders : openPurchaseOrders // ignore: cast_nullable_to_non_nullable
as int,inTransitIssues: null == inTransitIssues ? _self.inTransitIssues : inTransitIssues // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardSummaryDto].
extension DashboardSummaryDtoPatterns on DashboardSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime asOf,  Money? stockValue,  int expiringBatches,  int expiredBatches,  int lowStockProducts,  int pendingApprovals,  int openPurchaseOrders,  int inTransitIssues)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSummaryDto() when $default != null:
return $default(_that.asOf,_that.stockValue,_that.expiringBatches,_that.expiredBatches,_that.lowStockProducts,_that.pendingApprovals,_that.openPurchaseOrders,_that.inTransitIssues);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime asOf,  Money? stockValue,  int expiringBatches,  int expiredBatches,  int lowStockProducts,  int pendingApprovals,  int openPurchaseOrders,  int inTransitIssues)  $default,) {final _that = this;
switch (_that) {
case _DashboardSummaryDto():
return $default(_that.asOf,_that.stockValue,_that.expiringBatches,_that.expiredBatches,_that.lowStockProducts,_that.pendingApprovals,_that.openPurchaseOrders,_that.inTransitIssues);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime asOf,  Money? stockValue,  int expiringBatches,  int expiredBatches,  int lowStockProducts,  int pendingApprovals,  int openPurchaseOrders,  int inTransitIssues)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSummaryDto() when $default != null:
return $default(_that.asOf,_that.stockValue,_that.expiringBatches,_that.expiredBatches,_that.lowStockProducts,_that.pendingApprovals,_that.openPurchaseOrders,_that.inTransitIssues);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardSummaryDto implements DashboardSummaryDto {
  const _DashboardSummaryDto({required this.asOf, this.stockValue, this.expiringBatches = 0, this.expiredBatches = 0, this.lowStockProducts = 0, this.pendingApprovals = 0, this.openPurchaseOrders = 0, this.inTransitIssues = 0});
  factory _DashboardSummaryDto.fromJson(Map<String, dynamic> json) => _$DashboardSummaryDtoFromJson(json);

@override final  DateTime asOf;
@override final  Money? stockValue;
@override@JsonKey() final  int expiringBatches;
@override@JsonKey() final  int expiredBatches;
@override@JsonKey() final  int lowStockProducts;
@override@JsonKey() final  int pendingApprovals;
@override@JsonKey() final  int openPurchaseOrders;
@override@JsonKey() final  int inTransitIssues;

/// Create a copy of DashboardSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSummaryDtoCopyWith<_DashboardSummaryDto> get copyWith => __$DashboardSummaryDtoCopyWithImpl<_DashboardSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSummaryDto&&(identical(other.asOf, asOf) || other.asOf == asOf)&&(identical(other.stockValue, stockValue) || other.stockValue == stockValue)&&(identical(other.expiringBatches, expiringBatches) || other.expiringBatches == expiringBatches)&&(identical(other.expiredBatches, expiredBatches) || other.expiredBatches == expiredBatches)&&(identical(other.lowStockProducts, lowStockProducts) || other.lowStockProducts == lowStockProducts)&&(identical(other.pendingApprovals, pendingApprovals) || other.pendingApprovals == pendingApprovals)&&(identical(other.openPurchaseOrders, openPurchaseOrders) || other.openPurchaseOrders == openPurchaseOrders)&&(identical(other.inTransitIssues, inTransitIssues) || other.inTransitIssues == inTransitIssues));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,asOf,stockValue,expiringBatches,expiredBatches,lowStockProducts,pendingApprovals,openPurchaseOrders,inTransitIssues);
}

@override
String toString() {
    return 'DashboardSummaryDto(asOf: $asOf, stockValue: $stockValue, expiringBatches: $expiringBatches, expiredBatches: $expiredBatches, lowStockProducts: $lowStockProducts, pendingApprovals: $pendingApprovals, openPurchaseOrders: $openPurchaseOrders, inTransitIssues: $inTransitIssues)';
}


}

/// @nodoc
abstract mixin class _$DashboardSummaryDtoCopyWith<$Res> implements $DashboardSummaryDtoCopyWith<$Res> {
  factory _$DashboardSummaryDtoCopyWith(_DashboardSummaryDto value, $Res Function(_DashboardSummaryDto) _then) = __$DashboardSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 DateTime asOf, Money? stockValue, int expiringBatches, int expiredBatches, int lowStockProducts, int pendingApprovals, int openPurchaseOrders, int inTransitIssues
});




}
/// @nodoc
class __$DashboardSummaryDtoCopyWithImpl<$Res>
    implements _$DashboardSummaryDtoCopyWith<$Res> {
  __$DashboardSummaryDtoCopyWithImpl(this._self, this._then);

  final _DashboardSummaryDto _self;
  final $Res Function(_DashboardSummaryDto) _then;

/// Create a copy of DashboardSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? asOf = null,Object? stockValue = freezed,Object? expiringBatches = null,Object? expiredBatches = null,Object? lowStockProducts = null,Object? pendingApprovals = null,Object? openPurchaseOrders = null,Object? inTransitIssues = null,}) {
  return _then(_DashboardSummaryDto(
asOf: null == asOf ? _self.asOf : asOf // ignore: cast_nullable_to_non_nullable
as DateTime,stockValue: freezed == stockValue ? _self.stockValue : stockValue // ignore: cast_nullable_to_non_nullable
as Money?,expiringBatches: null == expiringBatches ? _self.expiringBatches : expiringBatches // ignore: cast_nullable_to_non_nullable
as int,expiredBatches: null == expiredBatches ? _self.expiredBatches : expiredBatches // ignore: cast_nullable_to_non_nullable
as int,lowStockProducts: null == lowStockProducts ? _self.lowStockProducts : lowStockProducts // ignore: cast_nullable_to_non_nullable
as int,pendingApprovals: null == pendingApprovals ? _self.pendingApprovals : pendingApprovals // ignore: cast_nullable_to_non_nullable
as int,openPurchaseOrders: null == openPurchaseOrders ? _self.openPurchaseOrders : openPurchaseOrders // ignore: cast_nullable_to_non_nullable
as int,inTransitIssues: null == inTransitIssues ? _self.inTransitIssues : inTransitIssues // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ReportDefinitionDto {

 String get code; String get name; String get category; String? get description; List<String> get parameters; bool get supportsExport;
/// Create a copy of ReportDefinitionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportDefinitionDtoCopyWith<ReportDefinitionDto> get copyWith => _$ReportDefinitionDtoCopyWithImpl<ReportDefinitionDto>(this as ReportDefinitionDto, _$identity);

  /// Serializes this ReportDefinitionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportDefinitionDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportDefinitionDto&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.parameters, _this.parameters)&&(identical(other.supportsExport, _this.supportsExport) || other.supportsExport == _this.supportsExport));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportDefinitionDto;
  return Object.hash(runtimeType,_this.code,_this.name,_this.category,_this.description,const DeepCollectionEquality().hash(_this.parameters),_this.supportsExport);
}

@override
String toString() {
  final _this = this as ReportDefinitionDto;
  return 'ReportDefinitionDto(code: ${_this.code}, name: ${_this.name}, category: ${_this.category}, description: ${_this.description}, parameters: ${_this.parameters}, supportsExport: ${_this.supportsExport})';
}


}

/// @nodoc
abstract mixin class $ReportDefinitionDtoCopyWith<$Res>  {
  factory $ReportDefinitionDtoCopyWith(ReportDefinitionDto value, $Res Function(ReportDefinitionDto) _then) = _$ReportDefinitionDtoCopyWithImpl;
@useResult
$Res call({
 String code, String name, String category, String? description, List<String> parameters, bool supportsExport
});




}
/// @nodoc
class _$ReportDefinitionDtoCopyWithImpl<$Res>
    implements $ReportDefinitionDtoCopyWith<$Res> {
  _$ReportDefinitionDtoCopyWithImpl(this._self, this._then);

  final ReportDefinitionDto _self;
  final $Res Function(ReportDefinitionDto) _then;

/// Create a copy of ReportDefinitionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? category = null,Object? description = freezed,Object? parameters = null,Object? supportsExport = null,}) {
  return _then(ReportDefinitionDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,parameters: null == parameters ? _self.parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<String>,supportsExport: null == supportsExport ? _self.supportsExport : supportsExport // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportDefinitionDto].
extension ReportDefinitionDtoPatterns on ReportDefinitionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportDefinitionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportDefinitionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportDefinitionDto value)  $default,){
final _that = this;
switch (_that) {
case _ReportDefinitionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportDefinitionDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReportDefinitionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String category,  String? description,  List<String> parameters,  bool supportsExport)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportDefinitionDto() when $default != null:
return $default(_that.code,_that.name,_that.category,_that.description,_that.parameters,_that.supportsExport);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String category,  String? description,  List<String> parameters,  bool supportsExport)  $default,) {final _that = this;
switch (_that) {
case _ReportDefinitionDto():
return $default(_that.code,_that.name,_that.category,_that.description,_that.parameters,_that.supportsExport);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String category,  String? description,  List<String> parameters,  bool supportsExport)?  $default,) {final _that = this;
switch (_that) {
case _ReportDefinitionDto() when $default != null:
return $default(_that.code,_that.name,_that.category,_that.description,_that.parameters,_that.supportsExport);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportDefinitionDto implements ReportDefinitionDto {
  const _ReportDefinitionDto({required this.code, required this.name, required this.category, this.description,  List<String> parameters = const <String>[], this.supportsExport = true}): _parameters = parameters;
  factory _ReportDefinitionDto.fromJson(Map<String, dynamic> json) => _$ReportDefinitionDtoFromJson(json);

@override final  String code;
@override final  String name;
@override final  String category;
@override final  String? description;
 final  List<String> _parameters;
@override@JsonKey() List<String> get parameters {
  if (_parameters is EqualUnmodifiableListView) return _parameters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parameters);
}

@override@JsonKey() final  bool supportsExport;

/// Create a copy of ReportDefinitionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportDefinitionDtoCopyWith<_ReportDefinitionDto> get copyWith => __$ReportDefinitionDtoCopyWithImpl<_ReportDefinitionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportDefinitionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportDefinitionDto&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.parameters, _parameters)&&(identical(other.supportsExport, supportsExport) || other.supportsExport == supportsExport));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,name,category,description,const DeepCollectionEquality().hash(_parameters),supportsExport);
}

@override
String toString() {
    return 'ReportDefinitionDto(code: $code, name: $name, category: $category, description: $description, parameters: $parameters, supportsExport: $supportsExport)';
}


}

/// @nodoc
abstract mixin class _$ReportDefinitionDtoCopyWith<$Res> implements $ReportDefinitionDtoCopyWith<$Res> {
  factory _$ReportDefinitionDtoCopyWith(_ReportDefinitionDto value, $Res Function(_ReportDefinitionDto) _then) = __$ReportDefinitionDtoCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String category, String? description, List<String> parameters, bool supportsExport
});




}
/// @nodoc
class __$ReportDefinitionDtoCopyWithImpl<$Res>
    implements _$ReportDefinitionDtoCopyWith<$Res> {
  __$ReportDefinitionDtoCopyWithImpl(this._self, this._then);

  final _ReportDefinitionDto _self;
  final $Res Function(_ReportDefinitionDto) _then;

/// Create a copy of ReportDefinitionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? category = null,Object? description = freezed,Object? parameters = null,Object? supportsExport = null,}) {
  return _then(_ReportDefinitionDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,parameters: null == parameters ? _self._parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<String>,supportsExport: null == supportsExport ? _self.supportsExport : supportsExport // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ExportJobDto {

 String get id; String get reportCode; String get status; DateTime get createdAt; String? get downloadUrl; DateTime? get completedAt; String? get error;
/// Create a copy of ExportJobDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportJobDtoCopyWith<ExportJobDto> get copyWith => _$ExportJobDtoCopyWithImpl<ExportJobDto>(this as ExportJobDto, _$identity);

  /// Serializes this ExportJobDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExportJobDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportJobDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.reportCode, _this.reportCode) || other.reportCode == _this.reportCode)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.downloadUrl, _this.downloadUrl) || other.downloadUrl == _this.downloadUrl)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExportJobDto;
  return Object.hash(runtimeType,_this.id,_this.reportCode,_this.status,_this.createdAt,_this.downloadUrl,_this.completedAt,_this.error);
}

@override
String toString() {
  final _this = this as ExportJobDto;
  return 'ExportJobDto(id: ${_this.id}, reportCode: ${_this.reportCode}, status: ${_this.status}, createdAt: ${_this.createdAt}, downloadUrl: ${_this.downloadUrl}, completedAt: ${_this.completedAt}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ExportJobDtoCopyWith<$Res>  {
  factory $ExportJobDtoCopyWith(ExportJobDto value, $Res Function(ExportJobDto) _then) = _$ExportJobDtoCopyWithImpl;
@useResult
$Res call({
 String id, String reportCode, String status, DateTime createdAt, String? downloadUrl, DateTime? completedAt, String? error
});




}
/// @nodoc
class _$ExportJobDtoCopyWithImpl<$Res>
    implements $ExportJobDtoCopyWith<$Res> {
  _$ExportJobDtoCopyWithImpl(this._self, this._then);

  final ExportJobDto _self;
  final $Res Function(ExportJobDto) _then;

/// Create a copy of ExportJobDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reportCode = null,Object? status = null,Object? createdAt = null,Object? downloadUrl = freezed,Object? completedAt = freezed,Object? error = freezed,}) {
  return _then(ExportJobDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportCode: null == reportCode ? _self.reportCode : reportCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportJobDto].
extension ExportJobDtoPatterns on ExportJobDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportJobDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportJobDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportJobDto value)  $default,){
final _that = this;
switch (_that) {
case _ExportJobDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportJobDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExportJobDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reportCode,  String status,  DateTime createdAt,  String? downloadUrl,  DateTime? completedAt,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportJobDto() when $default != null:
return $default(_that.id,_that.reportCode,_that.status,_that.createdAt,_that.downloadUrl,_that.completedAt,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reportCode,  String status,  DateTime createdAt,  String? downloadUrl,  DateTime? completedAt,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ExportJobDto():
return $default(_that.id,_that.reportCode,_that.status,_that.createdAt,_that.downloadUrl,_that.completedAt,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reportCode,  String status,  DateTime createdAt,  String? downloadUrl,  DateTime? completedAt,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ExportJobDto() when $default != null:
return $default(_that.id,_that.reportCode,_that.status,_that.createdAt,_that.downloadUrl,_that.completedAt,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportJobDto extends ExportJobDto {
  const _ExportJobDto({required this.id, required this.reportCode, required this.status, required this.createdAt, this.downloadUrl, this.completedAt, this.error}): super._();
  factory _ExportJobDto.fromJson(Map<String, dynamic> json) => _$ExportJobDtoFromJson(json);

@override final  String id;
@override final  String reportCode;
@override final  String status;
@override final  DateTime createdAt;
@override final  String? downloadUrl;
@override final  DateTime? completedAt;
@override final  String? error;

/// Create a copy of ExportJobDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportJobDtoCopyWith<_ExportJobDto> get copyWith => __$ExportJobDtoCopyWithImpl<_ExportJobDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportJobDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportJobDto&&(identical(other.id, id) || other.id == id)&&(identical(other.reportCode, reportCode) || other.reportCode == reportCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,reportCode,status,createdAt,downloadUrl,completedAt,error);
}

@override
String toString() {
    return 'ExportJobDto(id: $id, reportCode: $reportCode, status: $status, createdAt: $createdAt, downloadUrl: $downloadUrl, completedAt: $completedAt, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ExportJobDtoCopyWith<$Res> implements $ExportJobDtoCopyWith<$Res> {
  factory _$ExportJobDtoCopyWith(_ExportJobDto value, $Res Function(_ExportJobDto) _then) = __$ExportJobDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String reportCode, String status, DateTime createdAt, String? downloadUrl, DateTime? completedAt, String? error
});




}
/// @nodoc
class __$ExportJobDtoCopyWithImpl<$Res>
    implements _$ExportJobDtoCopyWith<$Res> {
  __$ExportJobDtoCopyWithImpl(this._self, this._then);

  final _ExportJobDto _self;
  final $Res Function(_ExportJobDto) _then;

/// Create a copy of ExportJobDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportCode = null,Object? status = null,Object? createdAt = null,Object? downloadUrl = freezed,Object? completedAt = freezed,Object? error = freezed,}) {
  return _then(_ExportJobDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportCode: null == reportCode ? _self.reportCode : reportCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
