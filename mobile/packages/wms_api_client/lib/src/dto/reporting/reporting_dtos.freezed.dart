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
mixin _$KpiDto {

 String get key; String get label; String get value; String? get unit; String? get trend; String? get previousValue; bool get isCost;
/// Create a copy of KpiDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KpiDtoCopyWith<KpiDto> get copyWith => _$KpiDtoCopyWithImpl<KpiDto>(this as KpiDto, _$identity);

  /// Serializes this KpiDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as KpiDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KpiDto&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.trend, _this.trend) || other.trend == _this.trend)&&(identical(other.previousValue, _this.previousValue) || other.previousValue == _this.previousValue)&&(identical(other.isCost, _this.isCost) || other.isCost == _this.isCost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as KpiDto;
  return Object.hash(runtimeType,_this.key,_this.label,_this.value,_this.unit,_this.trend,_this.previousValue,_this.isCost);
}

@override
String toString() {
  final _this = this as KpiDto;
  return 'KpiDto(key: ${_this.key}, label: ${_this.label}, value: ${_this.value}, unit: ${_this.unit}, trend: ${_this.trend}, previousValue: ${_this.previousValue}, isCost: ${_this.isCost})';
}


}

/// @nodoc
abstract mixin class $KpiDtoCopyWith<$Res>  {
  factory $KpiDtoCopyWith(KpiDto value, $Res Function(KpiDto) _then) = _$KpiDtoCopyWithImpl;
@useResult
$Res call({
 String key, String label, String value, String? unit, String? trend, String? previousValue, bool isCost
});




}
/// @nodoc
class _$KpiDtoCopyWithImpl<$Res>
    implements $KpiDtoCopyWith<$Res> {
  _$KpiDtoCopyWithImpl(this._self, this._then);

  final KpiDto _self;
  final $Res Function(KpiDto) _then;

/// Create a copy of KpiDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? value = null,Object? unit = freezed,Object? trend = freezed,Object? previousValue = freezed,Object? isCost = null,}) {
  return _then(KpiDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,trend: freezed == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as String?,previousValue: freezed == previousValue ? _self.previousValue : previousValue // ignore: cast_nullable_to_non_nullable
as String?,isCost: null == isCost ? _self.isCost : isCost // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [KpiDto].
extension KpiDtoPatterns on KpiDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KpiDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KpiDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KpiDto value)  $default,){
final _that = this;
switch (_that) {
case _KpiDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KpiDto value)?  $default,){
final _that = this;
switch (_that) {
case _KpiDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  String value,  String? unit,  String? trend,  String? previousValue,  bool isCost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KpiDto() when $default != null:
return $default(_that.key,_that.label,_that.value,_that.unit,_that.trend,_that.previousValue,_that.isCost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  String value,  String? unit,  String? trend,  String? previousValue,  bool isCost)  $default,) {final _that = this;
switch (_that) {
case _KpiDto():
return $default(_that.key,_that.label,_that.value,_that.unit,_that.trend,_that.previousValue,_that.isCost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  String value,  String? unit,  String? trend,  String? previousValue,  bool isCost)?  $default,) {final _that = this;
switch (_that) {
case _KpiDto() when $default != null:
return $default(_that.key,_that.label,_that.value,_that.unit,_that.trend,_that.previousValue,_that.isCost);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KpiDto extends KpiDto {
  const _KpiDto({required this.key, required this.label, required this.value, this.unit, this.trend, this.previousValue, this.isCost = false}): super._();
  factory _KpiDto.fromJson(Map<String, dynamic> json) => _$KpiDtoFromJson(json);

@override final  String key;
@override final  String label;
@override final  String value;
@override final  String? unit;
@override final  String? trend;
@override final  String? previousValue;
@override@JsonKey() final  bool isCost;

/// Create a copy of KpiDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KpiDtoCopyWith<_KpiDto> get copyWith => __$KpiDtoCopyWithImpl<_KpiDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KpiDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KpiDto&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.trend, trend) || other.trend == trend)&&(identical(other.previousValue, previousValue) || other.previousValue == previousValue)&&(identical(other.isCost, isCost) || other.isCost == isCost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,label,value,unit,trend,previousValue,isCost);
}

@override
String toString() {
    return 'KpiDto(key: $key, label: $label, value: $value, unit: $unit, trend: $trend, previousValue: $previousValue, isCost: $isCost)';
}


}

/// @nodoc
abstract mixin class _$KpiDtoCopyWith<$Res> implements $KpiDtoCopyWith<$Res> {
  factory _$KpiDtoCopyWith(_KpiDto value, $Res Function(_KpiDto) _then) = __$KpiDtoCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, String value, String? unit, String? trend, String? previousValue, bool isCost
});




}
/// @nodoc
class __$KpiDtoCopyWithImpl<$Res>
    implements _$KpiDtoCopyWith<$Res> {
  __$KpiDtoCopyWithImpl(this._self, this._then);

  final _KpiDto _self;
  final $Res Function(_KpiDto) _then;

/// Create a copy of KpiDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? value = null,Object? unit = freezed,Object? trend = freezed,Object? previousValue = freezed,Object? isCost = null,}) {
  return _then(_KpiDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,trend: freezed == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as String?,previousValue: freezed == previousValue ? _self.previousValue : previousValue // ignore: cast_nullable_to_non_nullable
as String?,isCost: null == isCost ? _self.isCost : isCost // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DashboardAlertDto {

 String get type; String get severity; String get title; int get count; String? get link;
/// Create a copy of DashboardAlertDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardAlertDtoCopyWith<DashboardAlertDto> get copyWith => _$DashboardAlertDtoCopyWithImpl<DashboardAlertDto>(this as DashboardAlertDto, _$identity);

  /// Serializes this DashboardAlertDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DashboardAlertDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardAlertDto&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.severity, _this.severity) || other.severity == _this.severity)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.link, _this.link) || other.link == _this.link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DashboardAlertDto;
  return Object.hash(runtimeType,_this.type,_this.severity,_this.title,_this.count,_this.link);
}

@override
String toString() {
  final _this = this as DashboardAlertDto;
  return 'DashboardAlertDto(type: ${_this.type}, severity: ${_this.severity}, title: ${_this.title}, count: ${_this.count}, link: ${_this.link})';
}


}

/// @nodoc
abstract mixin class $DashboardAlertDtoCopyWith<$Res>  {
  factory $DashboardAlertDtoCopyWith(DashboardAlertDto value, $Res Function(DashboardAlertDto) _then) = _$DashboardAlertDtoCopyWithImpl;
@useResult
$Res call({
 String type, String severity, String title, int count, String? link
});




}
/// @nodoc
class _$DashboardAlertDtoCopyWithImpl<$Res>
    implements $DashboardAlertDtoCopyWith<$Res> {
  _$DashboardAlertDtoCopyWithImpl(this._self, this._then);

  final DashboardAlertDto _self;
  final $Res Function(DashboardAlertDto) _then;

/// Create a copy of DashboardAlertDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? severity = null,Object? title = null,Object? count = null,Object? link = freezed,}) {
  return _then(DashboardAlertDto(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardAlertDto].
extension DashboardAlertDtoPatterns on DashboardAlertDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardAlertDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardAlertDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardAlertDto value)  $default,){
final _that = this;
switch (_that) {
case _DashboardAlertDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardAlertDto value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardAlertDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String severity,  String title,  int count,  String? link)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardAlertDto() when $default != null:
return $default(_that.type,_that.severity,_that.title,_that.count,_that.link);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String severity,  String title,  int count,  String? link)  $default,) {final _that = this;
switch (_that) {
case _DashboardAlertDto():
return $default(_that.type,_that.severity,_that.title,_that.count,_that.link);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String severity,  String title,  int count,  String? link)?  $default,) {final _that = this;
switch (_that) {
case _DashboardAlertDto() when $default != null:
return $default(_that.type,_that.severity,_that.title,_that.count,_that.link);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardAlertDto extends DashboardAlertDto {
  const _DashboardAlertDto({required this.type, required this.severity, required this.title, this.count = 0, this.link}): super._();
  factory _DashboardAlertDto.fromJson(Map<String, dynamic> json) => _$DashboardAlertDtoFromJson(json);

@override final  String type;
@override final  String severity;
@override final  String title;
@override@JsonKey() final  int count;
@override final  String? link;

/// Create a copy of DashboardAlertDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardAlertDtoCopyWith<_DashboardAlertDto> get copyWith => __$DashboardAlertDtoCopyWithImpl<_DashboardAlertDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardAlertDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardAlertDto&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.title, title) || other.title == title)&&(identical(other.count, count) || other.count == count)&&(identical(other.link, link) || other.link == link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,severity,title,count,link);
}

@override
String toString() {
    return 'DashboardAlertDto(type: $type, severity: $severity, title: $title, count: $count, link: $link)';
}


}

/// @nodoc
abstract mixin class _$DashboardAlertDtoCopyWith<$Res> implements $DashboardAlertDtoCopyWith<$Res> {
  factory _$DashboardAlertDtoCopyWith(_DashboardAlertDto value, $Res Function(_DashboardAlertDto) _then) = __$DashboardAlertDtoCopyWithImpl;
@override @useResult
$Res call({
 String type, String severity, String title, int count, String? link
});




}
/// @nodoc
class __$DashboardAlertDtoCopyWithImpl<$Res>
    implements _$DashboardAlertDtoCopyWith<$Res> {
  __$DashboardAlertDtoCopyWithImpl(this._self, this._then);

  final _DashboardAlertDto _self;
  final $Res Function(_DashboardAlertDto) _then;

/// Create a copy of DashboardAlertDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? severity = null,Object? title = null,Object? count = null,Object? link = freezed,}) {
  return _then(_DashboardAlertDto(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SeriesPointDto {

@DateOnlyConverter() DateTime get date; Decimal get value;
/// Create a copy of SeriesPointDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesPointDtoCopyWith<SeriesPointDto> get copyWith => _$SeriesPointDtoCopyWithImpl<SeriesPointDto>(this as SeriesPointDto, _$identity);

  /// Serializes this SeriesPointDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SeriesPointDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeriesPointDto&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SeriesPointDto;
  return Object.hash(runtimeType,_this.date,_this.value);
}

@override
String toString() {
  final _this = this as SeriesPointDto;
  return 'SeriesPointDto(date: ${_this.date}, value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $SeriesPointDtoCopyWith<$Res>  {
  factory $SeriesPointDtoCopyWith(SeriesPointDto value, $Res Function(SeriesPointDto) _then) = _$SeriesPointDtoCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime date, Decimal value
});




}
/// @nodoc
class _$SeriesPointDtoCopyWithImpl<$Res>
    implements $SeriesPointDtoCopyWith<$Res> {
  _$SeriesPointDtoCopyWithImpl(this._self, this._then);

  final SeriesPointDto _self;
  final $Res Function(SeriesPointDto) _then;

/// Create a copy of SeriesPointDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? value = null,}) {
  return _then(SeriesPointDto(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [SeriesPointDto].
extension SeriesPointDtoPatterns on SeriesPointDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeriesPointDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeriesPointDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeriesPointDto value)  $default,){
final _that = this;
switch (_that) {
case _SeriesPointDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeriesPointDto value)?  $default,){
final _that = this;
switch (_that) {
case _SeriesPointDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime date,  Decimal value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeriesPointDto() when $default != null:
return $default(_that.date,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime date,  Decimal value)  $default,) {final _that = this;
switch (_that) {
case _SeriesPointDto():
return $default(_that.date,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime date,  Decimal value)?  $default,) {final _that = this;
switch (_that) {
case _SeriesPointDto() when $default != null:
return $default(_that.date,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeriesPointDto extends SeriesPointDto {
  const _SeriesPointDto({@DateOnlyConverter() required this.date, required this.value}): super._();
  factory _SeriesPointDto.fromJson(Map<String, dynamic> json) => _$SeriesPointDtoFromJson(json);

@override@DateOnlyConverter() final  DateTime date;
@override final  Decimal value;

/// Create a copy of SeriesPointDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeriesPointDtoCopyWith<_SeriesPointDto> get copyWith => __$SeriesPointDtoCopyWithImpl<_SeriesPointDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeriesPointDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeriesPointDto&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,value);
}

@override
String toString() {
    return 'SeriesPointDto(date: $date, value: $value)';
}


}

/// @nodoc
abstract mixin class _$SeriesPointDtoCopyWith<$Res> implements $SeriesPointDtoCopyWith<$Res> {
  factory _$SeriesPointDtoCopyWith(_SeriesPointDto value, $Res Function(_SeriesPointDto) _then) = __$SeriesPointDtoCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime date, Decimal value
});




}
/// @nodoc
class __$SeriesPointDtoCopyWithImpl<$Res>
    implements _$SeriesPointDtoCopyWith<$Res> {
  __$SeriesPointDtoCopyWithImpl(this._self, this._then);

  final _SeriesPointDto _self;
  final $Res Function(_SeriesPointDto) _then;

/// Create a copy of SeriesPointDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? value = null,}) {
  return _then(_SeriesPointDto(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$DashboardSeriesDto {

 String get key; String get label; bool get isCost; String? get unit; List<SeriesPointDto> get points;
/// Create a copy of DashboardSeriesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSeriesDtoCopyWith<DashboardSeriesDto> get copyWith => _$DashboardSeriesDtoCopyWithImpl<DashboardSeriesDto>(this as DashboardSeriesDto, _$identity);

  /// Serializes this DashboardSeriesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DashboardSeriesDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSeriesDto&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.isCost, _this.isCost) || other.isCost == _this.isCost)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&const DeepCollectionEquality().equals(other.points, _this.points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DashboardSeriesDto;
  return Object.hash(runtimeType,_this.key,_this.label,_this.isCost,_this.unit,const DeepCollectionEquality().hash(_this.points));
}

@override
String toString() {
  final _this = this as DashboardSeriesDto;
  return 'DashboardSeriesDto(key: ${_this.key}, label: ${_this.label}, isCost: ${_this.isCost}, unit: ${_this.unit}, points: ${_this.points})';
}


}

/// @nodoc
abstract mixin class $DashboardSeriesDtoCopyWith<$Res>  {
  factory $DashboardSeriesDtoCopyWith(DashboardSeriesDto value, $Res Function(DashboardSeriesDto) _then) = _$DashboardSeriesDtoCopyWithImpl;
@useResult
$Res call({
 String key, String label, bool isCost, String? unit, List<SeriesPointDto> points
});




}
/// @nodoc
class _$DashboardSeriesDtoCopyWithImpl<$Res>
    implements $DashboardSeriesDtoCopyWith<$Res> {
  _$DashboardSeriesDtoCopyWithImpl(this._self, this._then);

  final DashboardSeriesDto _self;
  final $Res Function(DashboardSeriesDto) _then;

/// Create a copy of DashboardSeriesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? isCost = null,Object? unit = freezed,Object? points = null,}) {
  return _then(DashboardSeriesDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isCost: null == isCost ? _self.isCost : isCost // ignore: cast_nullable_to_non_nullable
as bool,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<SeriesPointDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardSeriesDto].
extension DashboardSeriesDtoPatterns on DashboardSeriesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSeriesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSeriesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSeriesDto value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSeriesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSeriesDto value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSeriesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  bool isCost,  String? unit,  List<SeriesPointDto> points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSeriesDto() when $default != null:
return $default(_that.key,_that.label,_that.isCost,_that.unit,_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  bool isCost,  String? unit,  List<SeriesPointDto> points)  $default,) {final _that = this;
switch (_that) {
case _DashboardSeriesDto():
return $default(_that.key,_that.label,_that.isCost,_that.unit,_that.points);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  bool isCost,  String? unit,  List<SeriesPointDto> points)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSeriesDto() when $default != null:
return $default(_that.key,_that.label,_that.isCost,_that.unit,_that.points);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardSeriesDto extends DashboardSeriesDto {
  const _DashboardSeriesDto({required this.key, required this.label, this.isCost = false, this.unit,  List<SeriesPointDto> points = const <SeriesPointDto>[]}): _points = points,super._();
  factory _DashboardSeriesDto.fromJson(Map<String, dynamic> json) => _$DashboardSeriesDtoFromJson(json);

@override final  String key;
@override final  String label;
@override@JsonKey() final  bool isCost;
@override final  String? unit;
 final  List<SeriesPointDto> _points;
@override@JsonKey() List<SeriesPointDto> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


/// Create a copy of DashboardSeriesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSeriesDtoCopyWith<_DashboardSeriesDto> get copyWith => __$DashboardSeriesDtoCopyWithImpl<_DashboardSeriesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardSeriesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSeriesDto&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.isCost, isCost) || other.isCost == isCost)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other.points, _points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,label,isCost,unit,const DeepCollectionEquality().hash(_points));
}

@override
String toString() {
    return 'DashboardSeriesDto(key: $key, label: $label, isCost: $isCost, unit: $unit, points: $points)';
}


}

/// @nodoc
abstract mixin class _$DashboardSeriesDtoCopyWith<$Res> implements $DashboardSeriesDtoCopyWith<$Res> {
  factory _$DashboardSeriesDtoCopyWith(_DashboardSeriesDto value, $Res Function(_DashboardSeriesDto) _then) = __$DashboardSeriesDtoCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, bool isCost, String? unit, List<SeriesPointDto> points
});




}
/// @nodoc
class __$DashboardSeriesDtoCopyWithImpl<$Res>
    implements _$DashboardSeriesDtoCopyWith<$Res> {
  __$DashboardSeriesDtoCopyWithImpl(this._self, this._then);

  final _DashboardSeriesDto _self;
  final $Res Function(_DashboardSeriesDto) _then;

/// Create a copy of DashboardSeriesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? isCost = null,Object? unit = freezed,Object? points = null,}) {
  return _then(_DashboardSeriesDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isCost: null == isCost ? _self.isCost : isCost // ignore: cast_nullable_to_non_nullable
as bool,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<SeriesPointDto>,
  ));
}


}


/// @nodoc
mixin _$DashboardSummaryDto {

 DateTime get generatedAt; List<KpiDto> get kpis; List<DashboardAlertDto> get alerts; List<DashboardSeriesDto> get series; Map<String, Object?>? get systemHealth;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSummaryDto&&(identical(other.generatedAt, _this.generatedAt) || other.generatedAt == _this.generatedAt)&&const DeepCollectionEquality().equals(other.kpis, _this.kpis)&&const DeepCollectionEquality().equals(other.alerts, _this.alerts)&&const DeepCollectionEquality().equals(other.series, _this.series)&&const DeepCollectionEquality().equals(other.systemHealth, _this.systemHealth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DashboardSummaryDto;
  return Object.hash(runtimeType,_this.generatedAt,const DeepCollectionEquality().hash(_this.kpis),const DeepCollectionEquality().hash(_this.alerts),const DeepCollectionEquality().hash(_this.series),const DeepCollectionEquality().hash(_this.systemHealth));
}

@override
String toString() {
  final _this = this as DashboardSummaryDto;
  return 'DashboardSummaryDto(generatedAt: ${_this.generatedAt}, kpis: ${_this.kpis}, alerts: ${_this.alerts}, series: ${_this.series}, systemHealth: ${_this.systemHealth})';
}


}

/// @nodoc
abstract mixin class $DashboardSummaryDtoCopyWith<$Res>  {
  factory $DashboardSummaryDtoCopyWith(DashboardSummaryDto value, $Res Function(DashboardSummaryDto) _then) = _$DashboardSummaryDtoCopyWithImpl;
@useResult
$Res call({
 DateTime generatedAt, List<KpiDto> kpis, List<DashboardAlertDto> alerts, List<DashboardSeriesDto> series, Map<String, Object?>? systemHealth
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
@pragma('vm:prefer-inline') @override $Res call({Object? generatedAt = null,Object? kpis = null,Object? alerts = null,Object? series = null,Object? systemHealth = freezed,}) {
  return _then(DashboardSummaryDto(
generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,kpis: null == kpis ? _self.kpis : kpis // ignore: cast_nullable_to_non_nullable
as List<KpiDto>,alerts: null == alerts ? _self.alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<DashboardAlertDto>,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as List<DashboardSeriesDto>,systemHealth: freezed == systemHealth ? _self.systemHealth : systemHealth // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime generatedAt,  List<KpiDto> kpis,  List<DashboardAlertDto> alerts,  List<DashboardSeriesDto> series,  Map<String, Object?>? systemHealth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSummaryDto() when $default != null:
return $default(_that.generatedAt,_that.kpis,_that.alerts,_that.series,_that.systemHealth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime generatedAt,  List<KpiDto> kpis,  List<DashboardAlertDto> alerts,  List<DashboardSeriesDto> series,  Map<String, Object?>? systemHealth)  $default,) {final _that = this;
switch (_that) {
case _DashboardSummaryDto():
return $default(_that.generatedAt,_that.kpis,_that.alerts,_that.series,_that.systemHealth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime generatedAt,  List<KpiDto> kpis,  List<DashboardAlertDto> alerts,  List<DashboardSeriesDto> series,  Map<String, Object?>? systemHealth)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSummaryDto() when $default != null:
return $default(_that.generatedAt,_that.kpis,_that.alerts,_that.series,_that.systemHealth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardSummaryDto extends DashboardSummaryDto {
  const _DashboardSummaryDto({required this.generatedAt,  List<KpiDto> kpis = const <KpiDto>[],  List<DashboardAlertDto> alerts = const <DashboardAlertDto>[],  List<DashboardSeriesDto> series = const <DashboardSeriesDto>[],  Map<String, Object?>? systemHealth}): _kpis = kpis,_alerts = alerts,_series = series,_systemHealth = systemHealth,super._();
  factory _DashboardSummaryDto.fromJson(Map<String, dynamic> json) => _$DashboardSummaryDtoFromJson(json);

@override final  DateTime generatedAt;
 final  List<KpiDto> _kpis;
@override@JsonKey() List<KpiDto> get kpis {
  if (_kpis is EqualUnmodifiableListView) return _kpis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_kpis);
}

 final  List<DashboardAlertDto> _alerts;
@override@JsonKey() List<DashboardAlertDto> get alerts {
  if (_alerts is EqualUnmodifiableListView) return _alerts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alerts);
}

 final  List<DashboardSeriesDto> _series;
@override@JsonKey() List<DashboardSeriesDto> get series {
  if (_series is EqualUnmodifiableListView) return _series;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_series);
}

 final  Map<String, Object?>? _systemHealth;
@override Map<String, Object?>? get systemHealth {
  final value = _systemHealth;
  if (value == null) return null;
  if (_systemHealth is EqualUnmodifiableMapView) return _systemHealth;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSummaryDto&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other.kpis, _kpis)&&const DeepCollectionEquality().equals(other.alerts, _alerts)&&const DeepCollectionEquality().equals(other.series, _series)&&const DeepCollectionEquality().equals(other.systemHealth, _systemHealth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,generatedAt,const DeepCollectionEquality().hash(_kpis),const DeepCollectionEquality().hash(_alerts),const DeepCollectionEquality().hash(_series),const DeepCollectionEquality().hash(_systemHealth));
}

@override
String toString() {
    return 'DashboardSummaryDto(generatedAt: $generatedAt, kpis: $kpis, alerts: $alerts, series: $series, systemHealth: $systemHealth)';
}


}

/// @nodoc
abstract mixin class _$DashboardSummaryDtoCopyWith<$Res> implements $DashboardSummaryDtoCopyWith<$Res> {
  factory _$DashboardSummaryDtoCopyWith(_DashboardSummaryDto value, $Res Function(_DashboardSummaryDto) _then) = __$DashboardSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 DateTime generatedAt, List<KpiDto> kpis, List<DashboardAlertDto> alerts, List<DashboardSeriesDto> series, Map<String, Object?>? systemHealth
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
@override @pragma('vm:prefer-inline') $Res call({Object? generatedAt = null,Object? kpis = null,Object? alerts = null,Object? series = null,Object? systemHealth = freezed,}) {
  return _then(_DashboardSummaryDto(
generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,kpis: null == kpis ? _self._kpis : kpis // ignore: cast_nullable_to_non_nullable
as List<KpiDto>,alerts: null == alerts ? _self._alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<DashboardAlertDto>,series: null == series ? _self._series : series // ignore: cast_nullable_to_non_nullable
as List<DashboardSeriesDto>,systemHealth: freezed == systemHealth ? _self._systemHealth : systemHealth // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,
  ));
}


}


/// @nodoc
mixin _$ReportDefinitionDto {

 String get code; String get name; String get category; String? get description; List<Object?> get parameters; List<ReportColumnDto> get columns; List<String> get supportedFormats; bool get requiresCostPermission; int? get maxSyncRows;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportDefinitionDto&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.parameters, _this.parameters)&&const DeepCollectionEquality().equals(other.columns, _this.columns)&&const DeepCollectionEquality().equals(other.supportedFormats, _this.supportedFormats)&&(identical(other.requiresCostPermission, _this.requiresCostPermission) || other.requiresCostPermission == _this.requiresCostPermission)&&(identical(other.maxSyncRows, _this.maxSyncRows) || other.maxSyncRows == _this.maxSyncRows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportDefinitionDto;
  return Object.hash(runtimeType,_this.code,_this.name,_this.category,_this.description,const DeepCollectionEquality().hash(_this.parameters),const DeepCollectionEquality().hash(_this.columns),const DeepCollectionEquality().hash(_this.supportedFormats),_this.requiresCostPermission,_this.maxSyncRows);
}

@override
String toString() {
  final _this = this as ReportDefinitionDto;
  return 'ReportDefinitionDto(code: ${_this.code}, name: ${_this.name}, category: ${_this.category}, description: ${_this.description}, parameters: ${_this.parameters}, columns: ${_this.columns}, supportedFormats: ${_this.supportedFormats}, requiresCostPermission: ${_this.requiresCostPermission}, maxSyncRows: ${_this.maxSyncRows})';
}


}

/// @nodoc
abstract mixin class $ReportDefinitionDtoCopyWith<$Res>  {
  factory $ReportDefinitionDtoCopyWith(ReportDefinitionDto value, $Res Function(ReportDefinitionDto) _then) = _$ReportDefinitionDtoCopyWithImpl;
@useResult
$Res call({
 String code, String name, String category, String? description, List<Object?> parameters, List<ReportColumnDto> columns, List<String> supportedFormats, bool requiresCostPermission, int? maxSyncRows
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
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? category = null,Object? description = freezed,Object? parameters = null,Object? columns = null,Object? supportedFormats = null,Object? requiresCostPermission = null,Object? maxSyncRows = freezed,}) {
  return _then(ReportDefinitionDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,parameters: null == parameters ? _self.parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<Object?>,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as List<ReportColumnDto>,supportedFormats: null == supportedFormats ? _self.supportedFormats : supportedFormats // ignore: cast_nullable_to_non_nullable
as List<String>,requiresCostPermission: null == requiresCostPermission ? _self.requiresCostPermission : requiresCostPermission // ignore: cast_nullable_to_non_nullable
as bool,maxSyncRows: freezed == maxSyncRows ? _self.maxSyncRows : maxSyncRows // ignore: cast_nullable_to_non_nullable
as int?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String category,  String? description,  List<Object?> parameters,  List<ReportColumnDto> columns,  List<String> supportedFormats,  bool requiresCostPermission,  int? maxSyncRows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportDefinitionDto() when $default != null:
return $default(_that.code,_that.name,_that.category,_that.description,_that.parameters,_that.columns,_that.supportedFormats,_that.requiresCostPermission,_that.maxSyncRows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String category,  String? description,  List<Object?> parameters,  List<ReportColumnDto> columns,  List<String> supportedFormats,  bool requiresCostPermission,  int? maxSyncRows)  $default,) {final _that = this;
switch (_that) {
case _ReportDefinitionDto():
return $default(_that.code,_that.name,_that.category,_that.description,_that.parameters,_that.columns,_that.supportedFormats,_that.requiresCostPermission,_that.maxSyncRows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String category,  String? description,  List<Object?> parameters,  List<ReportColumnDto> columns,  List<String> supportedFormats,  bool requiresCostPermission,  int? maxSyncRows)?  $default,) {final _that = this;
switch (_that) {
case _ReportDefinitionDto() when $default != null:
return $default(_that.code,_that.name,_that.category,_that.description,_that.parameters,_that.columns,_that.supportedFormats,_that.requiresCostPermission,_that.maxSyncRows);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportDefinitionDto extends ReportDefinitionDto {
  const _ReportDefinitionDto({required this.code, required this.name, required this.category, this.description,  List<Object?> parameters = const <Object?>[],  List<ReportColumnDto> columns = const <ReportColumnDto>[],  List<String> supportedFormats = const <String>[], this.requiresCostPermission = false, this.maxSyncRows}): _parameters = parameters,_columns = columns,_supportedFormats = supportedFormats,super._();
  factory _ReportDefinitionDto.fromJson(Map<String, dynamic> json) => _$ReportDefinitionDtoFromJson(json);

@override final  String code;
@override final  String name;
@override final  String category;
@override final  String? description;
 final  List<Object?> _parameters;
@override@JsonKey() List<Object?> get parameters {
  if (_parameters is EqualUnmodifiableListView) return _parameters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parameters);
}

 final  List<ReportColumnDto> _columns;
@override@JsonKey() List<ReportColumnDto> get columns {
  if (_columns is EqualUnmodifiableListView) return _columns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_columns);
}

 final  List<String> _supportedFormats;
@override@JsonKey() List<String> get supportedFormats {
  if (_supportedFormats is EqualUnmodifiableListView) return _supportedFormats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_supportedFormats);
}

@override@JsonKey() final  bool requiresCostPermission;
@override final  int? maxSyncRows;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportDefinitionDto&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.parameters, _parameters)&&const DeepCollectionEquality().equals(other.columns, _columns)&&const DeepCollectionEquality().equals(other.supportedFormats, _supportedFormats)&&(identical(other.requiresCostPermission, requiresCostPermission) || other.requiresCostPermission == requiresCostPermission)&&(identical(other.maxSyncRows, maxSyncRows) || other.maxSyncRows == maxSyncRows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,name,category,description,const DeepCollectionEquality().hash(_parameters),const DeepCollectionEquality().hash(_columns),const DeepCollectionEquality().hash(_supportedFormats),requiresCostPermission,maxSyncRows);
}

@override
String toString() {
    return 'ReportDefinitionDto(code: $code, name: $name, category: $category, description: $description, parameters: $parameters, columns: $columns, supportedFormats: $supportedFormats, requiresCostPermission: $requiresCostPermission, maxSyncRows: $maxSyncRows)';
}


}

/// @nodoc
abstract mixin class _$ReportDefinitionDtoCopyWith<$Res> implements $ReportDefinitionDtoCopyWith<$Res> {
  factory _$ReportDefinitionDtoCopyWith(_ReportDefinitionDto value, $Res Function(_ReportDefinitionDto) _then) = __$ReportDefinitionDtoCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String category, String? description, List<Object?> parameters, List<ReportColumnDto> columns, List<String> supportedFormats, bool requiresCostPermission, int? maxSyncRows
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
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? category = null,Object? description = freezed,Object? parameters = null,Object? columns = null,Object? supportedFormats = null,Object? requiresCostPermission = null,Object? maxSyncRows = freezed,}) {
  return _then(_ReportDefinitionDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,parameters: null == parameters ? _self._parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<Object?>,columns: null == columns ? _self._columns : columns // ignore: cast_nullable_to_non_nullable
as List<ReportColumnDto>,supportedFormats: null == supportedFormats ? _self._supportedFormats : supportedFormats // ignore: cast_nullable_to_non_nullable
as List<String>,requiresCostPermission: null == requiresCostPermission ? _self.requiresCostPermission : requiresCostPermission // ignore: cast_nullable_to_non_nullable
as bool,maxSyncRows: freezed == maxSyncRows ? _self.maxSyncRows : maxSyncRows // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ExportJobDto {

 int get id; String get reportCode; String get status; String get format; DateTime get requestedAt; int get progressPct; int? get rowCount; String? get fileName; int? get sizeBytes; String? get downloadUrl; DateTime? get downloadUrlExpiresAt; DateTime? get completedAt; DateTime? get expiresAt; String? get statusUrl;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportJobDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.reportCode, _this.reportCode) || other.reportCode == _this.reportCode)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.format, _this.format) || other.format == _this.format)&&(identical(other.requestedAt, _this.requestedAt) || other.requestedAt == _this.requestedAt)&&(identical(other.progressPct, _this.progressPct) || other.progressPct == _this.progressPct)&&(identical(other.rowCount, _this.rowCount) || other.rowCount == _this.rowCount)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.sizeBytes, _this.sizeBytes) || other.sizeBytes == _this.sizeBytes)&&(identical(other.downloadUrl, _this.downloadUrl) || other.downloadUrl == _this.downloadUrl)&&(identical(other.downloadUrlExpiresAt, _this.downloadUrlExpiresAt) || other.downloadUrlExpiresAt == _this.downloadUrlExpiresAt)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.statusUrl, _this.statusUrl) || other.statusUrl == _this.statusUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExportJobDto;
  return Object.hash(runtimeType,_this.id,_this.reportCode,_this.status,_this.format,_this.requestedAt,_this.progressPct,_this.rowCount,_this.fileName,_this.sizeBytes,_this.downloadUrl,_this.downloadUrlExpiresAt,_this.completedAt,_this.expiresAt,_this.statusUrl);
}

@override
String toString() {
  final _this = this as ExportJobDto;
  return 'ExportJobDto(id: ${_this.id}, reportCode: ${_this.reportCode}, status: ${_this.status}, format: ${_this.format}, requestedAt: ${_this.requestedAt}, progressPct: ${_this.progressPct}, rowCount: ${_this.rowCount}, fileName: ${_this.fileName}, sizeBytes: ${_this.sizeBytes}, downloadUrl: ${_this.downloadUrl}, downloadUrlExpiresAt: ${_this.downloadUrlExpiresAt}, completedAt: ${_this.completedAt}, expiresAt: ${_this.expiresAt}, statusUrl: ${_this.statusUrl})';
}


}

/// @nodoc
abstract mixin class $ExportJobDtoCopyWith<$Res>  {
  factory $ExportJobDtoCopyWith(ExportJobDto value, $Res Function(ExportJobDto) _then) = _$ExportJobDtoCopyWithImpl;
@useResult
$Res call({
 int id, String reportCode, String status, String format, DateTime requestedAt, int progressPct, int? rowCount, String? fileName, int? sizeBytes, String? downloadUrl, DateTime? downloadUrlExpiresAt, DateTime? completedAt, DateTime? expiresAt, String? statusUrl
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reportCode = null,Object? status = null,Object? format = null,Object? requestedAt = null,Object? progressPct = null,Object? rowCount = freezed,Object? fileName = freezed,Object? sizeBytes = freezed,Object? downloadUrl = freezed,Object? downloadUrlExpiresAt = freezed,Object? completedAt = freezed,Object? expiresAt = freezed,Object? statusUrl = freezed,}) {
  return _then(ExportJobDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reportCode: null == reportCode ? _self.reportCode : reportCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,progressPct: null == progressPct ? _self.progressPct : progressPct // ignore: cast_nullable_to_non_nullable
as int,rowCount: freezed == rowCount ? _self.rowCount : rowCount // ignore: cast_nullable_to_non_nullable
as int?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,downloadUrlExpiresAt: freezed == downloadUrlExpiresAt ? _self.downloadUrlExpiresAt : downloadUrlExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,statusUrl: freezed == statusUrl ? _self.statusUrl : statusUrl // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String reportCode,  String status,  String format,  DateTime requestedAt,  int progressPct,  int? rowCount,  String? fileName,  int? sizeBytes,  String? downloadUrl,  DateTime? downloadUrlExpiresAt,  DateTime? completedAt,  DateTime? expiresAt,  String? statusUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportJobDto() when $default != null:
return $default(_that.id,_that.reportCode,_that.status,_that.format,_that.requestedAt,_that.progressPct,_that.rowCount,_that.fileName,_that.sizeBytes,_that.downloadUrl,_that.downloadUrlExpiresAt,_that.completedAt,_that.expiresAt,_that.statusUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String reportCode,  String status,  String format,  DateTime requestedAt,  int progressPct,  int? rowCount,  String? fileName,  int? sizeBytes,  String? downloadUrl,  DateTime? downloadUrlExpiresAt,  DateTime? completedAt,  DateTime? expiresAt,  String? statusUrl)  $default,) {final _that = this;
switch (_that) {
case _ExportJobDto():
return $default(_that.id,_that.reportCode,_that.status,_that.format,_that.requestedAt,_that.progressPct,_that.rowCount,_that.fileName,_that.sizeBytes,_that.downloadUrl,_that.downloadUrlExpiresAt,_that.completedAt,_that.expiresAt,_that.statusUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String reportCode,  String status,  String format,  DateTime requestedAt,  int progressPct,  int? rowCount,  String? fileName,  int? sizeBytes,  String? downloadUrl,  DateTime? downloadUrlExpiresAt,  DateTime? completedAt,  DateTime? expiresAt,  String? statusUrl)?  $default,) {final _that = this;
switch (_that) {
case _ExportJobDto() when $default != null:
return $default(_that.id,_that.reportCode,_that.status,_that.format,_that.requestedAt,_that.progressPct,_that.rowCount,_that.fileName,_that.sizeBytes,_that.downloadUrl,_that.downloadUrlExpiresAt,_that.completedAt,_that.expiresAt,_that.statusUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportJobDto extends ExportJobDto {
  const _ExportJobDto({required this.id, required this.reportCode, required this.status, required this.format, required this.requestedAt, this.progressPct = 0, this.rowCount, this.fileName, this.sizeBytes, this.downloadUrl, this.downloadUrlExpiresAt, this.completedAt, this.expiresAt, this.statusUrl}): super._();
  factory _ExportJobDto.fromJson(Map<String, dynamic> json) => _$ExportJobDtoFromJson(json);

@override final  int id;
@override final  String reportCode;
@override final  String status;
@override final  String format;
@override final  DateTime requestedAt;
@override@JsonKey() final  int progressPct;
@override final  int? rowCount;
@override final  String? fileName;
@override final  int? sizeBytes;
@override final  String? downloadUrl;
@override final  DateTime? downloadUrlExpiresAt;
@override final  DateTime? completedAt;
@override final  DateTime? expiresAt;
@override final  String? statusUrl;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportJobDto&&(identical(other.id, id) || other.id == id)&&(identical(other.reportCode, reportCode) || other.reportCode == reportCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.format, format) || other.format == format)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.progressPct, progressPct) || other.progressPct == progressPct)&&(identical(other.rowCount, rowCount) || other.rowCount == rowCount)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.downloadUrlExpiresAt, downloadUrlExpiresAt) || other.downloadUrlExpiresAt == downloadUrlExpiresAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.statusUrl, statusUrl) || other.statusUrl == statusUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,reportCode,status,format,requestedAt,progressPct,rowCount,fileName,sizeBytes,downloadUrl,downloadUrlExpiresAt,completedAt,expiresAt,statusUrl);
}

@override
String toString() {
    return 'ExportJobDto(id: $id, reportCode: $reportCode, status: $status, format: $format, requestedAt: $requestedAt, progressPct: $progressPct, rowCount: $rowCount, fileName: $fileName, sizeBytes: $sizeBytes, downloadUrl: $downloadUrl, downloadUrlExpiresAt: $downloadUrlExpiresAt, completedAt: $completedAt, expiresAt: $expiresAt, statusUrl: $statusUrl)';
}


}

/// @nodoc
abstract mixin class _$ExportJobDtoCopyWith<$Res> implements $ExportJobDtoCopyWith<$Res> {
  factory _$ExportJobDtoCopyWith(_ExportJobDto value, $Res Function(_ExportJobDto) _then) = __$ExportJobDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String reportCode, String status, String format, DateTime requestedAt, int progressPct, int? rowCount, String? fileName, int? sizeBytes, String? downloadUrl, DateTime? downloadUrlExpiresAt, DateTime? completedAt, DateTime? expiresAt, String? statusUrl
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportCode = null,Object? status = null,Object? format = null,Object? requestedAt = null,Object? progressPct = null,Object? rowCount = freezed,Object? fileName = freezed,Object? sizeBytes = freezed,Object? downloadUrl = freezed,Object? downloadUrlExpiresAt = freezed,Object? completedAt = freezed,Object? expiresAt = freezed,Object? statusUrl = freezed,}) {
  return _then(_ExportJobDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reportCode: null == reportCode ? _self.reportCode : reportCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,progressPct: null == progressPct ? _self.progressPct : progressPct // ignore: cast_nullable_to_non_nullable
as int,rowCount: freezed == rowCount ? _self.rowCount : rowCount // ignore: cast_nullable_to_non_nullable
as int?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,downloadUrlExpiresAt: freezed == downloadUrlExpiresAt ? _self.downloadUrlExpiresAt : downloadUrlExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,statusUrl: freezed == statusUrl ? _self.statusUrl : statusUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReportColumnDto {

 String get key; String get label; String get type; bool get isCost; String get align; int? get width;
/// Create a copy of ReportColumnDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportColumnDtoCopyWith<ReportColumnDto> get copyWith => _$ReportColumnDtoCopyWithImpl<ReportColumnDto>(this as ReportColumnDto, _$identity);

  /// Serializes this ReportColumnDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportColumnDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportColumnDto&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.isCost, _this.isCost) || other.isCost == _this.isCost)&&(identical(other.align, _this.align) || other.align == _this.align)&&(identical(other.width, _this.width) || other.width == _this.width));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportColumnDto;
  return Object.hash(runtimeType,_this.key,_this.label,_this.type,_this.isCost,_this.align,_this.width);
}

@override
String toString() {
  final _this = this as ReportColumnDto;
  return 'ReportColumnDto(key: ${_this.key}, label: ${_this.label}, type: ${_this.type}, isCost: ${_this.isCost}, align: ${_this.align}, width: ${_this.width})';
}


}

/// @nodoc
abstract mixin class $ReportColumnDtoCopyWith<$Res>  {
  factory $ReportColumnDtoCopyWith(ReportColumnDto value, $Res Function(ReportColumnDto) _then) = _$ReportColumnDtoCopyWithImpl;
@useResult
$Res call({
 String key, String label, String type, bool isCost, String align, int? width
});




}
/// @nodoc
class _$ReportColumnDtoCopyWithImpl<$Res>
    implements $ReportColumnDtoCopyWith<$Res> {
  _$ReportColumnDtoCopyWithImpl(this._self, this._then);

  final ReportColumnDto _self;
  final $Res Function(ReportColumnDto) _then;

/// Create a copy of ReportColumnDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? type = null,Object? isCost = null,Object? align = null,Object? width = freezed,}) {
  return _then(ReportColumnDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,isCost: null == isCost ? _self.isCost : isCost // ignore: cast_nullable_to_non_nullable
as bool,align: null == align ? _self.align : align // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportColumnDto].
extension ReportColumnDtoPatterns on ReportColumnDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportColumnDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportColumnDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportColumnDto value)  $default,){
final _that = this;
switch (_that) {
case _ReportColumnDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportColumnDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReportColumnDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  String type,  bool isCost,  String align,  int? width)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportColumnDto() when $default != null:
return $default(_that.key,_that.label,_that.type,_that.isCost,_that.align,_that.width);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  String type,  bool isCost,  String align,  int? width)  $default,) {final _that = this;
switch (_that) {
case _ReportColumnDto():
return $default(_that.key,_that.label,_that.type,_that.isCost,_that.align,_that.width);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  String type,  bool isCost,  String align,  int? width)?  $default,) {final _that = this;
switch (_that) {
case _ReportColumnDto() when $default != null:
return $default(_that.key,_that.label,_that.type,_that.isCost,_that.align,_that.width);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportColumnDto extends ReportColumnDto {
  const _ReportColumnDto({required this.key, required this.label, required this.type, this.isCost = false, this.align = 'LEFT', this.width}): super._();
  factory _ReportColumnDto.fromJson(Map<String, dynamic> json) => _$ReportColumnDtoFromJson(json);

@override final  String key;
@override final  String label;
@override final  String type;
@override@JsonKey() final  bool isCost;
@override@JsonKey() final  String align;
@override final  int? width;

/// Create a copy of ReportColumnDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportColumnDtoCopyWith<_ReportColumnDto> get copyWith => __$ReportColumnDtoCopyWithImpl<_ReportColumnDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportColumnDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportColumnDto&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.isCost, isCost) || other.isCost == isCost)&&(identical(other.align, align) || other.align == align)&&(identical(other.width, width) || other.width == width));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,label,type,isCost,align,width);
}

@override
String toString() {
    return 'ReportColumnDto(key: $key, label: $label, type: $type, isCost: $isCost, align: $align, width: $width)';
}


}

/// @nodoc
abstract mixin class _$ReportColumnDtoCopyWith<$Res> implements $ReportColumnDtoCopyWith<$Res> {
  factory _$ReportColumnDtoCopyWith(_ReportColumnDto value, $Res Function(_ReportColumnDto) _then) = __$ReportColumnDtoCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, String type, bool isCost, String align, int? width
});




}
/// @nodoc
class __$ReportColumnDtoCopyWithImpl<$Res>
    implements _$ReportColumnDtoCopyWith<$Res> {
  __$ReportColumnDtoCopyWithImpl(this._self, this._then);

  final _ReportColumnDto _self;
  final $Res Function(_ReportColumnDto) _then;

/// Create a copy of ReportColumnDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? type = null,Object? isCost = null,Object? align = null,Object? width = freezed,}) {
  return _then(_ReportColumnDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,isCost: null == isCost ? _self.isCost : isCost // ignore: cast_nullable_to_non_nullable
as bool,align: null == align ? _self.align : align // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ReportResultPageDto {

 String get code; DateTime get generatedAt; List<ReportColumnDto> get columns;@JsonKey(name: 'rows') List<List<Object?>>? get rawRows; Map<String, String>? get totals; DateTime? get dataAsOf; int get page; int get size; int get totalItems; int get totalPages;
/// Create a copy of ReportResultPageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportResultPageDtoCopyWith<ReportResultPageDto> get copyWith => _$ReportResultPageDtoCopyWithImpl<ReportResultPageDto>(this as ReportResultPageDto, _$identity);

  /// Serializes this ReportResultPageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportResultPageDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportResultPageDto&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.generatedAt, _this.generatedAt) || other.generatedAt == _this.generatedAt)&&const DeepCollectionEquality().equals(other.columns, _this.columns)&&const DeepCollectionEquality().equals(other.rawRows, _this.rawRows)&&const DeepCollectionEquality().equals(other.totals, _this.totals)&&(identical(other.dataAsOf, _this.dataAsOf) || other.dataAsOf == _this.dataAsOf)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.totalItems, _this.totalItems) || other.totalItems == _this.totalItems)&&(identical(other.totalPages, _this.totalPages) || other.totalPages == _this.totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportResultPageDto;
  return Object.hash(runtimeType,_this.code,_this.generatedAt,const DeepCollectionEquality().hash(_this.columns),const DeepCollectionEquality().hash(_this.rawRows),const DeepCollectionEquality().hash(_this.totals),_this.dataAsOf,_this.page,_this.size,_this.totalItems,_this.totalPages);
}

@override
String toString() {
  final _this = this as ReportResultPageDto;
  return 'ReportResultPageDto(code: ${_this.code}, generatedAt: ${_this.generatedAt}, columns: ${_this.columns}, rawRows: ${_this.rawRows}, totals: ${_this.totals}, dataAsOf: ${_this.dataAsOf}, page: ${_this.page}, size: ${_this.size}, totalItems: ${_this.totalItems}, totalPages: ${_this.totalPages})';
}


}

/// @nodoc
abstract mixin class $ReportResultPageDtoCopyWith<$Res>  {
  factory $ReportResultPageDtoCopyWith(ReportResultPageDto value, $Res Function(ReportResultPageDto) _then) = _$ReportResultPageDtoCopyWithImpl;
@useResult
$Res call({
 String code, DateTime generatedAt, List<ReportColumnDto> columns,@JsonKey(name: 'rows') List<List<Object?>>? rawRows, Map<String, String>? totals, DateTime? dataAsOf, int page, int size, int totalItems, int totalPages
});




}
/// @nodoc
class _$ReportResultPageDtoCopyWithImpl<$Res>
    implements $ReportResultPageDtoCopyWith<$Res> {
  _$ReportResultPageDtoCopyWithImpl(this._self, this._then);

  final ReportResultPageDto _self;
  final $Res Function(ReportResultPageDto) _then;

/// Create a copy of ReportResultPageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? generatedAt = null,Object? columns = null,Object? rawRows = freezed,Object? totals = freezed,Object? dataAsOf = freezed,Object? page = null,Object? size = null,Object? totalItems = null,Object? totalPages = null,}) {
  return _then(ReportResultPageDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as List<ReportColumnDto>,rawRows: freezed == rawRows ? _self.rawRows : rawRows // ignore: cast_nullable_to_non_nullable
as List<List<Object?>>?,totals: freezed == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,dataAsOf: freezed == dataAsOf ? _self.dataAsOf : dataAsOf // ignore: cast_nullable_to_non_nullable
as DateTime?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportResultPageDto].
extension ReportResultPageDtoPatterns on ReportResultPageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportResultPageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportResultPageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportResultPageDto value)  $default,){
final _that = this;
switch (_that) {
case _ReportResultPageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportResultPageDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReportResultPageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  DateTime generatedAt,  List<ReportColumnDto> columns, @JsonKey(name: 'rows')  List<List<Object?>>? rawRows,  Map<String, String>? totals,  DateTime? dataAsOf,  int page,  int size,  int totalItems,  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportResultPageDto() when $default != null:
return $default(_that.code,_that.generatedAt,_that.columns,_that.rawRows,_that.totals,_that.dataAsOf,_that.page,_that.size,_that.totalItems,_that.totalPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  DateTime generatedAt,  List<ReportColumnDto> columns, @JsonKey(name: 'rows')  List<List<Object?>>? rawRows,  Map<String, String>? totals,  DateTime? dataAsOf,  int page,  int size,  int totalItems,  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _ReportResultPageDto():
return $default(_that.code,_that.generatedAt,_that.columns,_that.rawRows,_that.totals,_that.dataAsOf,_that.page,_that.size,_that.totalItems,_that.totalPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  DateTime generatedAt,  List<ReportColumnDto> columns, @JsonKey(name: 'rows')  List<List<Object?>>? rawRows,  Map<String, String>? totals,  DateTime? dataAsOf,  int page,  int size,  int totalItems,  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _ReportResultPageDto() when $default != null:
return $default(_that.code,_that.generatedAt,_that.columns,_that.rawRows,_that.totals,_that.dataAsOf,_that.page,_that.size,_that.totalItems,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportResultPageDto extends ReportResultPageDto {
  const _ReportResultPageDto({required this.code, required this.generatedAt,  List<ReportColumnDto> columns = const <ReportColumnDto>[], @JsonKey(name: 'rows')  List<List<Object?>>? rawRows,  Map<String, String>? totals, this.dataAsOf, this.page = 0, this.size = 0, this.totalItems = 0, this.totalPages = 0}): _columns = columns,_rawRows = rawRows,_totals = totals,super._();
  factory _ReportResultPageDto.fromJson(Map<String, dynamic> json) => _$ReportResultPageDtoFromJson(json);

@override final  String code;
@override final  DateTime generatedAt;
 final  List<ReportColumnDto> _columns;
@override@JsonKey() List<ReportColumnDto> get columns {
  if (_columns is EqualUnmodifiableListView) return _columns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_columns);
}

 final  List<List<Object?>>? _rawRows;
@override@JsonKey(name: 'rows') List<List<Object?>>? get rawRows {
  final value = _rawRows;
  if (value == null) return null;
  if (_rawRows is EqualUnmodifiableListView) return _rawRows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, String>? _totals;
@override Map<String, String>? get totals {
  final value = _totals;
  if (value == null) return null;
  if (_totals is EqualUnmodifiableMapView) return _totals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? dataAsOf;
@override@JsonKey() final  int page;
@override@JsonKey() final  int size;
@override@JsonKey() final  int totalItems;
@override@JsonKey() final  int totalPages;

/// Create a copy of ReportResultPageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportResultPageDtoCopyWith<_ReportResultPageDto> get copyWith => __$ReportResultPageDtoCopyWithImpl<_ReportResultPageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportResultPageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportResultPageDto&&(identical(other.code, code) || other.code == code)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other.columns, _columns)&&const DeepCollectionEquality().equals(other.rawRows, _rawRows)&&const DeepCollectionEquality().equals(other.totals, _totals)&&(identical(other.dataAsOf, dataAsOf) || other.dataAsOf == dataAsOf)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,generatedAt,const DeepCollectionEquality().hash(_columns),const DeepCollectionEquality().hash(_rawRows),const DeepCollectionEquality().hash(_totals),dataAsOf,page,size,totalItems,totalPages);
}

@override
String toString() {
    return 'ReportResultPageDto(code: $code, generatedAt: $generatedAt, columns: $columns, rawRows: $rawRows, totals: $totals, dataAsOf: $dataAsOf, page: $page, size: $size, totalItems: $totalItems, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$ReportResultPageDtoCopyWith<$Res> implements $ReportResultPageDtoCopyWith<$Res> {
  factory _$ReportResultPageDtoCopyWith(_ReportResultPageDto value, $Res Function(_ReportResultPageDto) _then) = __$ReportResultPageDtoCopyWithImpl;
@override @useResult
$Res call({
 String code, DateTime generatedAt, List<ReportColumnDto> columns,@JsonKey(name: 'rows') List<List<Object?>>? rawRows, Map<String, String>? totals, DateTime? dataAsOf, int page, int size, int totalItems, int totalPages
});




}
/// @nodoc
class __$ReportResultPageDtoCopyWithImpl<$Res>
    implements _$ReportResultPageDtoCopyWith<$Res> {
  __$ReportResultPageDtoCopyWithImpl(this._self, this._then);

  final _ReportResultPageDto _self;
  final $Res Function(_ReportResultPageDto) _then;

/// Create a copy of ReportResultPageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? generatedAt = null,Object? columns = null,Object? rawRows = freezed,Object? totals = freezed,Object? dataAsOf = freezed,Object? page = null,Object? size = null,Object? totalItems = null,Object? totalPages = null,}) {
  return _then(_ReportResultPageDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,columns: null == columns ? _self._columns : columns // ignore: cast_nullable_to_non_nullable
as List<ReportColumnDto>,rawRows: freezed == rawRows ? _self._rawRows : rawRows // ignore: cast_nullable_to_non_nullable
as List<List<Object?>>?,totals: freezed == totals ? _self._totals : totals // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,dataAsOf: freezed == dataAsOf ? _self.dataAsOf : dataAsOf // ignore: cast_nullable_to_non_nullable
as DateTime?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
