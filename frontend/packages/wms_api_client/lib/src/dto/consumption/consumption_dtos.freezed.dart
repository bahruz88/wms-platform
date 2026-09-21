// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consumption_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MenuItemDto {

 int get id; String get code; String get name; bool get isSubRecipe; bool get isActive; String? get posCode; String? get category;/// Recipe version valid today. `null` — no recipe, so a sale of this item
/// produces no depletion and lands in `unmappedCount`.
 int? get activeRecipeId; int get rowVersion;
/// Create a copy of MenuItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuItemDtoCopyWith<MenuItemDto> get copyWith => _$MenuItemDtoCopyWithImpl<MenuItemDto>(this as MenuItemDto, _$identity);

  /// Serializes this MenuItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MenuItemDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuItemDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isSubRecipe, _this.isSubRecipe) || other.isSubRecipe == _this.isSubRecipe)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.posCode, _this.posCode) || other.posCode == _this.posCode)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.activeRecipeId, _this.activeRecipeId) || other.activeRecipeId == _this.activeRecipeId)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MenuItemDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.isSubRecipe,_this.isActive,_this.posCode,_this.category,_this.activeRecipeId,_this.rowVersion);
}

@override
String toString() {
  final _this = this as MenuItemDto;
  return 'MenuItemDto(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, isSubRecipe: ${_this.isSubRecipe}, isActive: ${_this.isActive}, posCode: ${_this.posCode}, category: ${_this.category}, activeRecipeId: ${_this.activeRecipeId}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $MenuItemDtoCopyWith<$Res>  {
  factory $MenuItemDtoCopyWith(MenuItemDto value, $Res Function(MenuItemDto) _then) = _$MenuItemDtoCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, bool isSubRecipe, bool isActive, String? posCode, String? category, int? activeRecipeId, int rowVersion
});




}
/// @nodoc
class _$MenuItemDtoCopyWithImpl<$Res>
    implements $MenuItemDtoCopyWith<$Res> {
  _$MenuItemDtoCopyWithImpl(this._self, this._then);

  final MenuItemDto _self;
  final $Res Function(MenuItemDto) _then;

/// Create a copy of MenuItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? isSubRecipe = null,Object? isActive = null,Object? posCode = freezed,Object? category = freezed,Object? activeRecipeId = freezed,Object? rowVersion = null,}) {
  return _then(MenuItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isSubRecipe: null == isSubRecipe ? _self.isSubRecipe : isSubRecipe // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,posCode: freezed == posCode ? _self.posCode : posCode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,activeRecipeId: freezed == activeRecipeId ? _self.activeRecipeId : activeRecipeId // ignore: cast_nullable_to_non_nullable
as int?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuItemDto].
extension MenuItemDtoPatterns on MenuItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuItemDto value)  $default,){
final _that = this;
switch (_that) {
case _MenuItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _MenuItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  bool isSubRecipe,  bool isActive,  String? posCode,  String? category,  int? activeRecipeId,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuItemDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.isSubRecipe,_that.isActive,_that.posCode,_that.category,_that.activeRecipeId,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  bool isSubRecipe,  bool isActive,  String? posCode,  String? category,  int? activeRecipeId,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _MenuItemDto():
return $default(_that.id,_that.code,_that.name,_that.isSubRecipe,_that.isActive,_that.posCode,_that.category,_that.activeRecipeId,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  bool isSubRecipe,  bool isActive,  String? posCode,  String? category,  int? activeRecipeId,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _MenuItemDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.isSubRecipe,_that.isActive,_that.posCode,_that.category,_that.activeRecipeId,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuItemDto extends MenuItemDto {
  const _MenuItemDto({required this.id, required this.code, required this.name, this.isSubRecipe = false, this.isActive = true, this.posCode, this.category, this.activeRecipeId, this.rowVersion = 1}): super._();
  factory _MenuItemDto.fromJson(Map<String, dynamic> json) => _$MenuItemDtoFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override@JsonKey() final  bool isSubRecipe;
@override@JsonKey() final  bool isActive;
@override final  String? posCode;
@override final  String? category;
/// Recipe version valid today. `null` — no recipe, so a sale of this item
/// produces no depletion and lands in `unmappedCount`.
@override final  int? activeRecipeId;
@override@JsonKey() final  int rowVersion;

/// Create a copy of MenuItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuItemDtoCopyWith<_MenuItemDto> get copyWith => __$MenuItemDtoCopyWithImpl<_MenuItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.isSubRecipe, isSubRecipe) || other.isSubRecipe == isSubRecipe)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.posCode, posCode) || other.posCode == posCode)&&(identical(other.category, category) || other.category == category)&&(identical(other.activeRecipeId, activeRecipeId) || other.activeRecipeId == activeRecipeId)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,isSubRecipe,isActive,posCode,category,activeRecipeId,rowVersion);
}

@override
String toString() {
    return 'MenuItemDto(id: $id, code: $code, name: $name, isSubRecipe: $isSubRecipe, isActive: $isActive, posCode: $posCode, category: $category, activeRecipeId: $activeRecipeId, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$MenuItemDtoCopyWith<$Res> implements $MenuItemDtoCopyWith<$Res> {
  factory _$MenuItemDtoCopyWith(_MenuItemDto value, $Res Function(_MenuItemDto) _then) = __$MenuItemDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, bool isSubRecipe, bool isActive, String? posCode, String? category, int? activeRecipeId, int rowVersion
});




}
/// @nodoc
class __$MenuItemDtoCopyWithImpl<$Res>
    implements _$MenuItemDtoCopyWith<$Res> {
  __$MenuItemDtoCopyWithImpl(this._self, this._then);

  final _MenuItemDto _self;
  final $Res Function(_MenuItemDto) _then;

/// Create a copy of MenuItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? isSubRecipe = null,Object? isActive = null,Object? posCode = freezed,Object? category = freezed,Object? activeRecipeId = freezed,Object? rowVersion = null,}) {
  return _then(_MenuItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isSubRecipe: null == isSubRecipe ? _self.isSubRecipe : isSubRecipe // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,posCode: freezed == posCode ? _self.posCode : posCode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,activeRecipeId: freezed == activeRecipeId ? _self.activeRecipeId : activeRecipeId // ignore: cast_nullable_to_non_nullable
as int?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MenuItemDetailDto {

 int get id; String get code; String get name; bool get isSubRecipe; bool get isActive; String? get posCode; String? get category; int? get activeRecipeId; int get rowVersion; int get recipeVersionCount;/// Recipes this sub-recipe is a component of.
 List<RecipeSummaryDto> get usedInRecipes;
/// Create a copy of MenuItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuItemDetailDtoCopyWith<MenuItemDetailDto> get copyWith => _$MenuItemDetailDtoCopyWithImpl<MenuItemDetailDto>(this as MenuItemDetailDto, _$identity);

  /// Serializes this MenuItemDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MenuItemDetailDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuItemDetailDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isSubRecipe, _this.isSubRecipe) || other.isSubRecipe == _this.isSubRecipe)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.posCode, _this.posCode) || other.posCode == _this.posCode)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.activeRecipeId, _this.activeRecipeId) || other.activeRecipeId == _this.activeRecipeId)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&(identical(other.recipeVersionCount, _this.recipeVersionCount) || other.recipeVersionCount == _this.recipeVersionCount)&&const DeepCollectionEquality().equals(other.usedInRecipes, _this.usedInRecipes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MenuItemDetailDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.isSubRecipe,_this.isActive,_this.posCode,_this.category,_this.activeRecipeId,_this.rowVersion,_this.recipeVersionCount,const DeepCollectionEquality().hash(_this.usedInRecipes));
}

@override
String toString() {
  final _this = this as MenuItemDetailDto;
  return 'MenuItemDetailDto(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, isSubRecipe: ${_this.isSubRecipe}, isActive: ${_this.isActive}, posCode: ${_this.posCode}, category: ${_this.category}, activeRecipeId: ${_this.activeRecipeId}, rowVersion: ${_this.rowVersion}, recipeVersionCount: ${_this.recipeVersionCount}, usedInRecipes: ${_this.usedInRecipes})';
}


}

/// @nodoc
abstract mixin class $MenuItemDetailDtoCopyWith<$Res>  {
  factory $MenuItemDetailDtoCopyWith(MenuItemDetailDto value, $Res Function(MenuItemDetailDto) _then) = _$MenuItemDetailDtoCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, bool isSubRecipe, bool isActive, String? posCode, String? category, int? activeRecipeId, int rowVersion, int recipeVersionCount, List<RecipeSummaryDto> usedInRecipes
});




}
/// @nodoc
class _$MenuItemDetailDtoCopyWithImpl<$Res>
    implements $MenuItemDetailDtoCopyWith<$Res> {
  _$MenuItemDetailDtoCopyWithImpl(this._self, this._then);

  final MenuItemDetailDto _self;
  final $Res Function(MenuItemDetailDto) _then;

/// Create a copy of MenuItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? isSubRecipe = null,Object? isActive = null,Object? posCode = freezed,Object? category = freezed,Object? activeRecipeId = freezed,Object? rowVersion = null,Object? recipeVersionCount = null,Object? usedInRecipes = null,}) {
  return _then(MenuItemDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isSubRecipe: null == isSubRecipe ? _self.isSubRecipe : isSubRecipe // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,posCode: freezed == posCode ? _self.posCode : posCode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,activeRecipeId: freezed == activeRecipeId ? _self.activeRecipeId : activeRecipeId // ignore: cast_nullable_to_non_nullable
as int?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,recipeVersionCount: null == recipeVersionCount ? _self.recipeVersionCount : recipeVersionCount // ignore: cast_nullable_to_non_nullable
as int,usedInRecipes: null == usedInRecipes ? _self.usedInRecipes : usedInRecipes // ignore: cast_nullable_to_non_nullable
as List<RecipeSummaryDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuItemDetailDto].
extension MenuItemDetailDtoPatterns on MenuItemDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuItemDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuItemDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuItemDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _MenuItemDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuItemDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _MenuItemDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  bool isSubRecipe,  bool isActive,  String? posCode,  String? category,  int? activeRecipeId,  int rowVersion,  int recipeVersionCount,  List<RecipeSummaryDto> usedInRecipes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuItemDetailDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.isSubRecipe,_that.isActive,_that.posCode,_that.category,_that.activeRecipeId,_that.rowVersion,_that.recipeVersionCount,_that.usedInRecipes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  bool isSubRecipe,  bool isActive,  String? posCode,  String? category,  int? activeRecipeId,  int rowVersion,  int recipeVersionCount,  List<RecipeSummaryDto> usedInRecipes)  $default,) {final _that = this;
switch (_that) {
case _MenuItemDetailDto():
return $default(_that.id,_that.code,_that.name,_that.isSubRecipe,_that.isActive,_that.posCode,_that.category,_that.activeRecipeId,_that.rowVersion,_that.recipeVersionCount,_that.usedInRecipes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  bool isSubRecipe,  bool isActive,  String? posCode,  String? category,  int? activeRecipeId,  int rowVersion,  int recipeVersionCount,  List<RecipeSummaryDto> usedInRecipes)?  $default,) {final _that = this;
switch (_that) {
case _MenuItemDetailDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.isSubRecipe,_that.isActive,_that.posCode,_that.category,_that.activeRecipeId,_that.rowVersion,_that.recipeVersionCount,_that.usedInRecipes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuItemDetailDto extends MenuItemDetailDto {
  const _MenuItemDetailDto({required this.id, required this.code, required this.name, this.isSubRecipe = false, this.isActive = true, this.posCode, this.category, this.activeRecipeId, this.rowVersion = 1, this.recipeVersionCount = 0,  List<RecipeSummaryDto> usedInRecipes = const <RecipeSummaryDto>[]}): _usedInRecipes = usedInRecipes,super._();
  factory _MenuItemDetailDto.fromJson(Map<String, dynamic> json) => _$MenuItemDetailDtoFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override@JsonKey() final  bool isSubRecipe;
@override@JsonKey() final  bool isActive;
@override final  String? posCode;
@override final  String? category;
@override final  int? activeRecipeId;
@override@JsonKey() final  int rowVersion;
@override@JsonKey() final  int recipeVersionCount;
/// Recipes this sub-recipe is a component of.
 final  List<RecipeSummaryDto> _usedInRecipes;
/// Recipes this sub-recipe is a component of.
@override@JsonKey() List<RecipeSummaryDto> get usedInRecipes {
  if (_usedInRecipes is EqualUnmodifiableListView) return _usedInRecipes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usedInRecipes);
}


/// Create a copy of MenuItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuItemDetailDtoCopyWith<_MenuItemDetailDto> get copyWith => __$MenuItemDetailDtoCopyWithImpl<_MenuItemDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuItemDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuItemDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.isSubRecipe, isSubRecipe) || other.isSubRecipe == isSubRecipe)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.posCode, posCode) || other.posCode == posCode)&&(identical(other.category, category) || other.category == category)&&(identical(other.activeRecipeId, activeRecipeId) || other.activeRecipeId == activeRecipeId)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&(identical(other.recipeVersionCount, recipeVersionCount) || other.recipeVersionCount == recipeVersionCount)&&const DeepCollectionEquality().equals(other.usedInRecipes, _usedInRecipes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,isSubRecipe,isActive,posCode,category,activeRecipeId,rowVersion,recipeVersionCount,const DeepCollectionEquality().hash(_usedInRecipes));
}

@override
String toString() {
    return 'MenuItemDetailDto(id: $id, code: $code, name: $name, isSubRecipe: $isSubRecipe, isActive: $isActive, posCode: $posCode, category: $category, activeRecipeId: $activeRecipeId, rowVersion: $rowVersion, recipeVersionCount: $recipeVersionCount, usedInRecipes: $usedInRecipes)';
}


}

/// @nodoc
abstract mixin class _$MenuItemDetailDtoCopyWith<$Res> implements $MenuItemDetailDtoCopyWith<$Res> {
  factory _$MenuItemDetailDtoCopyWith(_MenuItemDetailDto value, $Res Function(_MenuItemDetailDto) _then) = __$MenuItemDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, bool isSubRecipe, bool isActive, String? posCode, String? category, int? activeRecipeId, int rowVersion, int recipeVersionCount, List<RecipeSummaryDto> usedInRecipes
});




}
/// @nodoc
class __$MenuItemDetailDtoCopyWithImpl<$Res>
    implements _$MenuItemDetailDtoCopyWith<$Res> {
  __$MenuItemDetailDtoCopyWithImpl(this._self, this._then);

  final _MenuItemDetailDto _self;
  final $Res Function(_MenuItemDetailDto) _then;

/// Create a copy of MenuItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? isSubRecipe = null,Object? isActive = null,Object? posCode = freezed,Object? category = freezed,Object? activeRecipeId = freezed,Object? rowVersion = null,Object? recipeVersionCount = null,Object? usedInRecipes = null,}) {
  return _then(_MenuItemDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isSubRecipe: null == isSubRecipe ? _self.isSubRecipe : isSubRecipe // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,posCode: freezed == posCode ? _self.posCode : posCode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,activeRecipeId: freezed == activeRecipeId ? _self.activeRecipeId : activeRecipeId // ignore: cast_nullable_to_non_nullable
as int?,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,recipeVersionCount: null == recipeVersionCount ? _self.recipeVersionCount : recipeVersionCount // ignore: cast_nullable_to_non_nullable
as int,usedInRecipes: null == usedInRecipes ? _self._usedInRecipes : usedInRecipes // ignore: cast_nullable_to_non_nullable
as List<RecipeSummaryDto>,
  ));
}


}


/// @nodoc
mixin _$CreateMenuItemRequest {

 String get code; String get name; String? get posCode; String? get category; bool get isSubRecipe;
/// Create a copy of CreateMenuItemRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateMenuItemRequestCopyWith<CreateMenuItemRequest> get copyWith => _$CreateMenuItemRequestCopyWithImpl<CreateMenuItemRequest>(this as CreateMenuItemRequest, _$identity);

  /// Serializes this CreateMenuItemRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateMenuItemRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateMenuItemRequest&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.posCode, _this.posCode) || other.posCode == _this.posCode)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.isSubRecipe, _this.isSubRecipe) || other.isSubRecipe == _this.isSubRecipe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateMenuItemRequest;
  return Object.hash(runtimeType,_this.code,_this.name,_this.posCode,_this.category,_this.isSubRecipe);
}

@override
String toString() {
  final _this = this as CreateMenuItemRequest;
  return 'CreateMenuItemRequest(code: ${_this.code}, name: ${_this.name}, posCode: ${_this.posCode}, category: ${_this.category}, isSubRecipe: ${_this.isSubRecipe})';
}


}

/// @nodoc
abstract mixin class $CreateMenuItemRequestCopyWith<$Res>  {
  factory $CreateMenuItemRequestCopyWith(CreateMenuItemRequest value, $Res Function(CreateMenuItemRequest) _then) = _$CreateMenuItemRequestCopyWithImpl;
@useResult
$Res call({
 String code, String name, String? posCode, String? category, bool isSubRecipe
});




}
/// @nodoc
class _$CreateMenuItemRequestCopyWithImpl<$Res>
    implements $CreateMenuItemRequestCopyWith<$Res> {
  _$CreateMenuItemRequestCopyWithImpl(this._self, this._then);

  final CreateMenuItemRequest _self;
  final $Res Function(CreateMenuItemRequest) _then;

/// Create a copy of CreateMenuItemRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? posCode = freezed,Object? category = freezed,Object? isSubRecipe = null,}) {
  return _then(CreateMenuItemRequest(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,posCode: freezed == posCode ? _self.posCode : posCode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isSubRecipe: null == isSubRecipe ? _self.isSubRecipe : isSubRecipe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateMenuItemRequest].
extension CreateMenuItemRequestPatterns on CreateMenuItemRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateMenuItemRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateMenuItemRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateMenuItemRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateMenuItemRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateMenuItemRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateMenuItemRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String? posCode,  String? category,  bool isSubRecipe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateMenuItemRequest() when $default != null:
return $default(_that.code,_that.name,_that.posCode,_that.category,_that.isSubRecipe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String? posCode,  String? category,  bool isSubRecipe)  $default,) {final _that = this;
switch (_that) {
case _CreateMenuItemRequest():
return $default(_that.code,_that.name,_that.posCode,_that.category,_that.isSubRecipe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String? posCode,  String? category,  bool isSubRecipe)?  $default,) {final _that = this;
switch (_that) {
case _CreateMenuItemRequest() when $default != null:
return $default(_that.code,_that.name,_that.posCode,_that.category,_that.isSubRecipe);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateMenuItemRequest implements CreateMenuItemRequest {
  const _CreateMenuItemRequest({required this.code, required this.name, this.posCode, this.category, this.isSubRecipe = false});
  factory _CreateMenuItemRequest.fromJson(Map<String, dynamic> json) => _$CreateMenuItemRequestFromJson(json);

@override final  String code;
@override final  String name;
@override final  String? posCode;
@override final  String? category;
@override@JsonKey() final  bool isSubRecipe;

/// Create a copy of CreateMenuItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateMenuItemRequestCopyWith<_CreateMenuItemRequest> get copyWith => __$CreateMenuItemRequestCopyWithImpl<_CreateMenuItemRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateMenuItemRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateMenuItemRequest&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.posCode, posCode) || other.posCode == posCode)&&(identical(other.category, category) || other.category == category)&&(identical(other.isSubRecipe, isSubRecipe) || other.isSubRecipe == isSubRecipe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,name,posCode,category,isSubRecipe);
}

@override
String toString() {
    return 'CreateMenuItemRequest(code: $code, name: $name, posCode: $posCode, category: $category, isSubRecipe: $isSubRecipe)';
}


}

/// @nodoc
abstract mixin class _$CreateMenuItemRequestCopyWith<$Res> implements $CreateMenuItemRequestCopyWith<$Res> {
  factory _$CreateMenuItemRequestCopyWith(_CreateMenuItemRequest value, $Res Function(_CreateMenuItemRequest) _then) = __$CreateMenuItemRequestCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String? posCode, String? category, bool isSubRecipe
});




}
/// @nodoc
class __$CreateMenuItemRequestCopyWithImpl<$Res>
    implements _$CreateMenuItemRequestCopyWith<$Res> {
  __$CreateMenuItemRequestCopyWithImpl(this._self, this._then);

  final _CreateMenuItemRequest _self;
  final $Res Function(_CreateMenuItemRequest) _then;

/// Create a copy of CreateMenuItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? posCode = freezed,Object? category = freezed,Object? isSubRecipe = null,}) {
  return _then(_CreateMenuItemRequest(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,posCode: freezed == posCode ? _self.posCode : posCode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isSubRecipe: null == isSubRecipe ? _self.isSubRecipe : isSubRecipe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UpdateMenuItemRequest {

 String get code; String get name; int get rowVersion; String? get posCode; String? get category; bool get isSubRecipe; bool get isActive;
/// Create a copy of UpdateMenuItemRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateMenuItemRequestCopyWith<UpdateMenuItemRequest> get copyWith => _$UpdateMenuItemRequestCopyWithImpl<UpdateMenuItemRequest>(this as UpdateMenuItemRequest, _$identity);

  /// Serializes this UpdateMenuItemRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateMenuItemRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateMenuItemRequest&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&(identical(other.posCode, _this.posCode) || other.posCode == _this.posCode)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.isSubRecipe, _this.isSubRecipe) || other.isSubRecipe == _this.isSubRecipe)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateMenuItemRequest;
  return Object.hash(runtimeType,_this.code,_this.name,_this.rowVersion,_this.posCode,_this.category,_this.isSubRecipe,_this.isActive);
}

@override
String toString() {
  final _this = this as UpdateMenuItemRequest;
  return 'UpdateMenuItemRequest(code: ${_this.code}, name: ${_this.name}, rowVersion: ${_this.rowVersion}, posCode: ${_this.posCode}, category: ${_this.category}, isSubRecipe: ${_this.isSubRecipe}, isActive: ${_this.isActive})';
}


}

/// @nodoc
abstract mixin class $UpdateMenuItemRequestCopyWith<$Res>  {
  factory $UpdateMenuItemRequestCopyWith(UpdateMenuItemRequest value, $Res Function(UpdateMenuItemRequest) _then) = _$UpdateMenuItemRequestCopyWithImpl;
@useResult
$Res call({
 String code, String name, int rowVersion, String? posCode, String? category, bool isSubRecipe, bool isActive
});




}
/// @nodoc
class _$UpdateMenuItemRequestCopyWithImpl<$Res>
    implements $UpdateMenuItemRequestCopyWith<$Res> {
  _$UpdateMenuItemRequestCopyWithImpl(this._self, this._then);

  final UpdateMenuItemRequest _self;
  final $Res Function(UpdateMenuItemRequest) _then;

/// Create a copy of UpdateMenuItemRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? rowVersion = null,Object? posCode = freezed,Object? category = freezed,Object? isSubRecipe = null,Object? isActive = null,}) {
  return _then(UpdateMenuItemRequest(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,posCode: freezed == posCode ? _self.posCode : posCode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isSubRecipe: null == isSubRecipe ? _self.isSubRecipe : isSubRecipe // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateMenuItemRequest].
extension UpdateMenuItemRequestPatterns on UpdateMenuItemRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateMenuItemRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateMenuItemRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateMenuItemRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateMenuItemRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateMenuItemRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateMenuItemRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  int rowVersion,  String? posCode,  String? category,  bool isSubRecipe,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateMenuItemRequest() when $default != null:
return $default(_that.code,_that.name,_that.rowVersion,_that.posCode,_that.category,_that.isSubRecipe,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  int rowVersion,  String? posCode,  String? category,  bool isSubRecipe,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _UpdateMenuItemRequest():
return $default(_that.code,_that.name,_that.rowVersion,_that.posCode,_that.category,_that.isSubRecipe,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  int rowVersion,  String? posCode,  String? category,  bool isSubRecipe,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _UpdateMenuItemRequest() when $default != null:
return $default(_that.code,_that.name,_that.rowVersion,_that.posCode,_that.category,_that.isSubRecipe,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateMenuItemRequest implements UpdateMenuItemRequest {
  const _UpdateMenuItemRequest({required this.code, required this.name, required this.rowVersion, this.posCode, this.category, this.isSubRecipe = false, this.isActive = true});
  factory _UpdateMenuItemRequest.fromJson(Map<String, dynamic> json) => _$UpdateMenuItemRequestFromJson(json);

@override final  String code;
@override final  String name;
@override final  int rowVersion;
@override final  String? posCode;
@override final  String? category;
@override@JsonKey() final  bool isSubRecipe;
@override@JsonKey() final  bool isActive;

/// Create a copy of UpdateMenuItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateMenuItemRequestCopyWith<_UpdateMenuItemRequest> get copyWith => __$UpdateMenuItemRequestCopyWithImpl<_UpdateMenuItemRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateMenuItemRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateMenuItemRequest&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&(identical(other.posCode, posCode) || other.posCode == posCode)&&(identical(other.category, category) || other.category == category)&&(identical(other.isSubRecipe, isSubRecipe) || other.isSubRecipe == isSubRecipe)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,name,rowVersion,posCode,category,isSubRecipe,isActive);
}

@override
String toString() {
    return 'UpdateMenuItemRequest(code: $code, name: $name, rowVersion: $rowVersion, posCode: $posCode, category: $category, isSubRecipe: $isSubRecipe, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$UpdateMenuItemRequestCopyWith<$Res> implements $UpdateMenuItemRequestCopyWith<$Res> {
  factory _$UpdateMenuItemRequestCopyWith(_UpdateMenuItemRequest value, $Res Function(_UpdateMenuItemRequest) _then) = __$UpdateMenuItemRequestCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, int rowVersion, String? posCode, String? category, bool isSubRecipe, bool isActive
});




}
/// @nodoc
class __$UpdateMenuItemRequestCopyWithImpl<$Res>
    implements _$UpdateMenuItemRequestCopyWith<$Res> {
  __$UpdateMenuItemRequestCopyWithImpl(this._self, this._then);

  final _UpdateMenuItemRequest _self;
  final $Res Function(_UpdateMenuItemRequest) _then;

/// Create a copy of UpdateMenuItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? rowVersion = null,Object? posCode = freezed,Object? category = freezed,Object? isSubRecipe = null,Object? isActive = null,}) {
  return _then(_UpdateMenuItemRequest(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,posCode: freezed == posCode ? _self.posCode : posCode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isSubRecipe: null == isSubRecipe ? _self.isSubRecipe : isSubRecipe // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RecipeLineDto {

 int get lineNo; ComponentType get componentType; Quantity get qtyPerPortion; int get uomId; Decimal get yieldPct; int? get productId; String? get productSku; String? get productName; int? get subMenuItemId; String? get subMenuItemName; String? get uomCode; bool get isOptional; Decimal? get attachRatePct; String? get note;
/// Create a copy of RecipeLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeLineDtoCopyWith<RecipeLineDto> get copyWith => _$RecipeLineDtoCopyWithImpl<RecipeLineDto>(this as RecipeLineDto, _$identity);

  /// Serializes this RecipeLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecipeLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeLineDto&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.componentType, _this.componentType) || other.componentType == _this.componentType)&&(identical(other.qtyPerPortion, _this.qtyPerPortion) || other.qtyPerPortion == _this.qtyPerPortion)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.yieldPct, _this.yieldPct) || other.yieldPct == _this.yieldPct)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productSku, _this.productSku) || other.productSku == _this.productSku)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.subMenuItemId, _this.subMenuItemId) || other.subMenuItemId == _this.subMenuItemId)&&(identical(other.subMenuItemName, _this.subMenuItemName) || other.subMenuItemName == _this.subMenuItemName)&&(identical(other.uomCode, _this.uomCode) || other.uomCode == _this.uomCode)&&(identical(other.isOptional, _this.isOptional) || other.isOptional == _this.isOptional)&&(identical(other.attachRatePct, _this.attachRatePct) || other.attachRatePct == _this.attachRatePct)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecipeLineDto;
  return Object.hash(runtimeType,_this.lineNo,_this.componentType,_this.qtyPerPortion,_this.uomId,_this.yieldPct,_this.productId,_this.productSku,_this.productName,_this.subMenuItemId,_this.subMenuItemName,_this.uomCode,_this.isOptional,_this.attachRatePct,_this.note);
}

@override
String toString() {
  final _this = this as RecipeLineDto;
  return 'RecipeLineDto(lineNo: ${_this.lineNo}, componentType: ${_this.componentType}, qtyPerPortion: ${_this.qtyPerPortion}, uomId: ${_this.uomId}, yieldPct: ${_this.yieldPct}, productId: ${_this.productId}, productSku: ${_this.productSku}, productName: ${_this.productName}, subMenuItemId: ${_this.subMenuItemId}, subMenuItemName: ${_this.subMenuItemName}, uomCode: ${_this.uomCode}, isOptional: ${_this.isOptional}, attachRatePct: ${_this.attachRatePct}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $RecipeLineDtoCopyWith<$Res>  {
  factory $RecipeLineDtoCopyWith(RecipeLineDto value, $Res Function(RecipeLineDto) _then) = _$RecipeLineDtoCopyWithImpl;
@useResult
$Res call({
 int lineNo, ComponentType componentType, Quantity qtyPerPortion, int uomId, Decimal yieldPct, int? productId, String? productSku, String? productName, int? subMenuItemId, String? subMenuItemName, String? uomCode, bool isOptional, Decimal? attachRatePct, String? note
});




}
/// @nodoc
class _$RecipeLineDtoCopyWithImpl<$Res>
    implements $RecipeLineDtoCopyWith<$Res> {
  _$RecipeLineDtoCopyWithImpl(this._self, this._then);

  final RecipeLineDto _self;
  final $Res Function(RecipeLineDto) _then;

/// Create a copy of RecipeLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? componentType = null,Object? qtyPerPortion = null,Object? uomId = null,Object? yieldPct = null,Object? productId = freezed,Object? productSku = freezed,Object? productName = freezed,Object? subMenuItemId = freezed,Object? subMenuItemName = freezed,Object? uomCode = freezed,Object? isOptional = null,Object? attachRatePct = freezed,Object? note = freezed,}) {
  return _then(RecipeLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,componentType: null == componentType ? _self.componentType : componentType // ignore: cast_nullable_to_non_nullable
as ComponentType,qtyPerPortion: null == qtyPerPortion ? _self.qtyPerPortion : qtyPerPortion // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,yieldPct: null == yieldPct ? _self.yieldPct : yieldPct // ignore: cast_nullable_to_non_nullable
as Decimal,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,productSku: freezed == productSku ? _self.productSku : productSku // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,subMenuItemId: freezed == subMenuItemId ? _self.subMenuItemId : subMenuItemId // ignore: cast_nullable_to_non_nullable
as int?,subMenuItemName: freezed == subMenuItemName ? _self.subMenuItemName : subMenuItemName // ignore: cast_nullable_to_non_nullable
as String?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,isOptional: null == isOptional ? _self.isOptional : isOptional // ignore: cast_nullable_to_non_nullable
as bool,attachRatePct: freezed == attachRatePct ? _self.attachRatePct : attachRatePct // ignore: cast_nullable_to_non_nullable
as Decimal?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipeLineDto].
extension RecipeLineDtoPatterns on RecipeLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeLineDto value)  $default,){
final _that = this;
switch (_that) {
case _RecipeLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  ComponentType componentType,  Quantity qtyPerPortion,  int uomId,  Decimal yieldPct,  int? productId,  String? productSku,  String? productName,  int? subMenuItemId,  String? subMenuItemName,  String? uomCode,  bool isOptional,  Decimal? attachRatePct,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeLineDto() when $default != null:
return $default(_that.lineNo,_that.componentType,_that.qtyPerPortion,_that.uomId,_that.yieldPct,_that.productId,_that.productSku,_that.productName,_that.subMenuItemId,_that.subMenuItemName,_that.uomCode,_that.isOptional,_that.attachRatePct,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  ComponentType componentType,  Quantity qtyPerPortion,  int uomId,  Decimal yieldPct,  int? productId,  String? productSku,  String? productName,  int? subMenuItemId,  String? subMenuItemName,  String? uomCode,  bool isOptional,  Decimal? attachRatePct,  String? note)  $default,) {final _that = this;
switch (_that) {
case _RecipeLineDto():
return $default(_that.lineNo,_that.componentType,_that.qtyPerPortion,_that.uomId,_that.yieldPct,_that.productId,_that.productSku,_that.productName,_that.subMenuItemId,_that.subMenuItemName,_that.uomCode,_that.isOptional,_that.attachRatePct,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  ComponentType componentType,  Quantity qtyPerPortion,  int uomId,  Decimal yieldPct,  int? productId,  String? productSku,  String? productName,  int? subMenuItemId,  String? subMenuItemName,  String? uomCode,  bool isOptional,  Decimal? attachRatePct,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _RecipeLineDto() when $default != null:
return $default(_that.lineNo,_that.componentType,_that.qtyPerPortion,_that.uomId,_that.yieldPct,_that.productId,_that.productSku,_that.productName,_that.subMenuItemId,_that.subMenuItemName,_that.uomCode,_that.isOptional,_that.attachRatePct,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipeLineDto extends RecipeLineDto {
  const _RecipeLineDto({required this.lineNo, required this.componentType, required this.qtyPerPortion, required this.uomId, required this.yieldPct, this.productId, this.productSku, this.productName, this.subMenuItemId, this.subMenuItemName, this.uomCode, this.isOptional = false, this.attachRatePct, this.note}): super._();
  factory _RecipeLineDto.fromJson(Map<String, dynamic> json) => _$RecipeLineDtoFromJson(json);

@override final  int lineNo;
@override final  ComponentType componentType;
@override final  Quantity qtyPerPortion;
@override final  int uomId;
@override final  Decimal yieldPct;
@override final  int? productId;
@override final  String? productSku;
@override final  String? productName;
@override final  int? subMenuItemId;
@override final  String? subMenuItemName;
@override final  String? uomCode;
@override@JsonKey() final  bool isOptional;
@override final  Decimal? attachRatePct;
@override final  String? note;

/// Create a copy of RecipeLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeLineDtoCopyWith<_RecipeLineDto> get copyWith => __$RecipeLineDtoCopyWithImpl<_RecipeLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeLineDto&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.componentType, componentType) || other.componentType == componentType)&&(identical(other.qtyPerPortion, qtyPerPortion) || other.qtyPerPortion == qtyPerPortion)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.yieldPct, yieldPct) || other.yieldPct == yieldPct)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productSku, productSku) || other.productSku == productSku)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.subMenuItemId, subMenuItemId) || other.subMenuItemId == subMenuItemId)&&(identical(other.subMenuItemName, subMenuItemName) || other.subMenuItemName == subMenuItemName)&&(identical(other.uomCode, uomCode) || other.uomCode == uomCode)&&(identical(other.isOptional, isOptional) || other.isOptional == isOptional)&&(identical(other.attachRatePct, attachRatePct) || other.attachRatePct == attachRatePct)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,componentType,qtyPerPortion,uomId,yieldPct,productId,productSku,productName,subMenuItemId,subMenuItemName,uomCode,isOptional,attachRatePct,note);
}

@override
String toString() {
    return 'RecipeLineDto(lineNo: $lineNo, componentType: $componentType, qtyPerPortion: $qtyPerPortion, uomId: $uomId, yieldPct: $yieldPct, productId: $productId, productSku: $productSku, productName: $productName, subMenuItemId: $subMenuItemId, subMenuItemName: $subMenuItemName, uomCode: $uomCode, isOptional: $isOptional, attachRatePct: $attachRatePct, note: $note)';
}


}

/// @nodoc
abstract mixin class _$RecipeLineDtoCopyWith<$Res> implements $RecipeLineDtoCopyWith<$Res> {
  factory _$RecipeLineDtoCopyWith(_RecipeLineDto value, $Res Function(_RecipeLineDto) _then) = __$RecipeLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, ComponentType componentType, Quantity qtyPerPortion, int uomId, Decimal yieldPct, int? productId, String? productSku, String? productName, int? subMenuItemId, String? subMenuItemName, String? uomCode, bool isOptional, Decimal? attachRatePct, String? note
});




}
/// @nodoc
class __$RecipeLineDtoCopyWithImpl<$Res>
    implements _$RecipeLineDtoCopyWith<$Res> {
  __$RecipeLineDtoCopyWithImpl(this._self, this._then);

  final _RecipeLineDto _self;
  final $Res Function(_RecipeLineDto) _then;

/// Create a copy of RecipeLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? componentType = null,Object? qtyPerPortion = null,Object? uomId = null,Object? yieldPct = null,Object? productId = freezed,Object? productSku = freezed,Object? productName = freezed,Object? subMenuItemId = freezed,Object? subMenuItemName = freezed,Object? uomCode = freezed,Object? isOptional = null,Object? attachRatePct = freezed,Object? note = freezed,}) {
  return _then(_RecipeLineDto(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,componentType: null == componentType ? _self.componentType : componentType // ignore: cast_nullable_to_non_nullable
as ComponentType,qtyPerPortion: null == qtyPerPortion ? _self.qtyPerPortion : qtyPerPortion // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,yieldPct: null == yieldPct ? _self.yieldPct : yieldPct // ignore: cast_nullable_to_non_nullable
as Decimal,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,productSku: freezed == productSku ? _self.productSku : productSku // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,subMenuItemId: freezed == subMenuItemId ? _self.subMenuItemId : subMenuItemId // ignore: cast_nullable_to_non_nullable
as int?,subMenuItemName: freezed == subMenuItemName ? _self.subMenuItemName : subMenuItemName // ignore: cast_nullable_to_non_nullable
as String?,uomCode: freezed == uomCode ? _self.uomCode : uomCode // ignore: cast_nullable_to_non_nullable
as String?,isOptional: null == isOptional ? _self.isOptional : isOptional // ignore: cast_nullable_to_non_nullable
as bool,attachRatePct: freezed == attachRatePct ? _self.attachRatePct : attachRatePct // ignore: cast_nullable_to_non_nullable
as Decimal?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RecipeLineInput {

 int get lineNo; ComponentType get componentType; Quantity get qtyPerPortion; int get uomId;/// Mandatory when `componentType = FOOD_PRODUCT`.
 int? get productId;/// Mandatory when `componentType = SUB_RECIPE`; must be a menu item with
/// `isSubRecipe = true`.
 int? get subMenuItemId;/// Processing loss. Lettuce trimmed by 8 % → `92`; the stock figure
/// becomes `qtyPerPortion ÷ (yieldPct ÷ 100)`. Defaults to 100.
 Decimal? get yieldPct; bool get isOptional;/// Share of orders that actually take an optional component.
 Decimal? get attachRatePct; String? get note;
/// Create a copy of RecipeLineInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeLineInputCopyWith<RecipeLineInput> get copyWith => _$RecipeLineInputCopyWithImpl<RecipeLineInput>(this as RecipeLineInput, _$identity);

  /// Serializes this RecipeLineInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecipeLineInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeLineInput&&(identical(other.lineNo, _this.lineNo) || other.lineNo == _this.lineNo)&&(identical(other.componentType, _this.componentType) || other.componentType == _this.componentType)&&(identical(other.qtyPerPortion, _this.qtyPerPortion) || other.qtyPerPortion == _this.qtyPerPortion)&&(identical(other.uomId, _this.uomId) || other.uomId == _this.uomId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.subMenuItemId, _this.subMenuItemId) || other.subMenuItemId == _this.subMenuItemId)&&(identical(other.yieldPct, _this.yieldPct) || other.yieldPct == _this.yieldPct)&&(identical(other.isOptional, _this.isOptional) || other.isOptional == _this.isOptional)&&(identical(other.attachRatePct, _this.attachRatePct) || other.attachRatePct == _this.attachRatePct)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecipeLineInput;
  return Object.hash(runtimeType,_this.lineNo,_this.componentType,_this.qtyPerPortion,_this.uomId,_this.productId,_this.subMenuItemId,_this.yieldPct,_this.isOptional,_this.attachRatePct,_this.note);
}

@override
String toString() {
  final _this = this as RecipeLineInput;
  return 'RecipeLineInput(lineNo: ${_this.lineNo}, componentType: ${_this.componentType}, qtyPerPortion: ${_this.qtyPerPortion}, uomId: ${_this.uomId}, productId: ${_this.productId}, subMenuItemId: ${_this.subMenuItemId}, yieldPct: ${_this.yieldPct}, isOptional: ${_this.isOptional}, attachRatePct: ${_this.attachRatePct}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $RecipeLineInputCopyWith<$Res>  {
  factory $RecipeLineInputCopyWith(RecipeLineInput value, $Res Function(RecipeLineInput) _then) = _$RecipeLineInputCopyWithImpl;
@useResult
$Res call({
 int lineNo, ComponentType componentType, Quantity qtyPerPortion, int uomId, int? productId, int? subMenuItemId, Decimal? yieldPct, bool isOptional, Decimal? attachRatePct, String? note
});




}
/// @nodoc
class _$RecipeLineInputCopyWithImpl<$Res>
    implements $RecipeLineInputCopyWith<$Res> {
  _$RecipeLineInputCopyWithImpl(this._self, this._then);

  final RecipeLineInput _self;
  final $Res Function(RecipeLineInput) _then;

/// Create a copy of RecipeLineInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineNo = null,Object? componentType = null,Object? qtyPerPortion = null,Object? uomId = null,Object? productId = freezed,Object? subMenuItemId = freezed,Object? yieldPct = freezed,Object? isOptional = null,Object? attachRatePct = freezed,Object? note = freezed,}) {
  return _then(RecipeLineInput(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,componentType: null == componentType ? _self.componentType : componentType // ignore: cast_nullable_to_non_nullable
as ComponentType,qtyPerPortion: null == qtyPerPortion ? _self.qtyPerPortion : qtyPerPortion // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,subMenuItemId: freezed == subMenuItemId ? _self.subMenuItemId : subMenuItemId // ignore: cast_nullable_to_non_nullable
as int?,yieldPct: freezed == yieldPct ? _self.yieldPct : yieldPct // ignore: cast_nullable_to_non_nullable
as Decimal?,isOptional: null == isOptional ? _self.isOptional : isOptional // ignore: cast_nullable_to_non_nullable
as bool,attachRatePct: freezed == attachRatePct ? _self.attachRatePct : attachRatePct // ignore: cast_nullable_to_non_nullable
as Decimal?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipeLineInput].
extension RecipeLineInputPatterns on RecipeLineInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeLineInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeLineInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeLineInput value)  $default,){
final _that = this;
switch (_that) {
case _RecipeLineInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeLineInput value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeLineInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineNo,  ComponentType componentType,  Quantity qtyPerPortion,  int uomId,  int? productId,  int? subMenuItemId,  Decimal? yieldPct,  bool isOptional,  Decimal? attachRatePct,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeLineInput() when $default != null:
return $default(_that.lineNo,_that.componentType,_that.qtyPerPortion,_that.uomId,_that.productId,_that.subMenuItemId,_that.yieldPct,_that.isOptional,_that.attachRatePct,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineNo,  ComponentType componentType,  Quantity qtyPerPortion,  int uomId,  int? productId,  int? subMenuItemId,  Decimal? yieldPct,  bool isOptional,  Decimal? attachRatePct,  String? note)  $default,) {final _that = this;
switch (_that) {
case _RecipeLineInput():
return $default(_that.lineNo,_that.componentType,_that.qtyPerPortion,_that.uomId,_that.productId,_that.subMenuItemId,_that.yieldPct,_that.isOptional,_that.attachRatePct,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineNo,  ComponentType componentType,  Quantity qtyPerPortion,  int uomId,  int? productId,  int? subMenuItemId,  Decimal? yieldPct,  bool isOptional,  Decimal? attachRatePct,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _RecipeLineInput() when $default != null:
return $default(_that.lineNo,_that.componentType,_that.qtyPerPortion,_that.uomId,_that.productId,_that.subMenuItemId,_that.yieldPct,_that.isOptional,_that.attachRatePct,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipeLineInput extends RecipeLineInput {
  const _RecipeLineInput({required this.lineNo, required this.componentType, required this.qtyPerPortion, required this.uomId, this.productId, this.subMenuItemId, this.yieldPct, this.isOptional = false, this.attachRatePct, this.note}): super._();
  factory _RecipeLineInput.fromJson(Map<String, dynamic> json) => _$RecipeLineInputFromJson(json);

@override final  int lineNo;
@override final  ComponentType componentType;
@override final  Quantity qtyPerPortion;
@override final  int uomId;
/// Mandatory when `componentType = FOOD_PRODUCT`.
@override final  int? productId;
/// Mandatory when `componentType = SUB_RECIPE`; must be a menu item with
/// `isSubRecipe = true`.
@override final  int? subMenuItemId;
/// Processing loss. Lettuce trimmed by 8 % → `92`; the stock figure
/// becomes `qtyPerPortion ÷ (yieldPct ÷ 100)`. Defaults to 100.
@override final  Decimal? yieldPct;
@override@JsonKey() final  bool isOptional;
/// Share of orders that actually take an optional component.
@override final  Decimal? attachRatePct;
@override final  String? note;

/// Create a copy of RecipeLineInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeLineInputCopyWith<_RecipeLineInput> get copyWith => __$RecipeLineInputCopyWithImpl<_RecipeLineInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeLineInputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeLineInput&&(identical(other.lineNo, lineNo) || other.lineNo == lineNo)&&(identical(other.componentType, componentType) || other.componentType == componentType)&&(identical(other.qtyPerPortion, qtyPerPortion) || other.qtyPerPortion == qtyPerPortion)&&(identical(other.uomId, uomId) || other.uomId == uomId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.subMenuItemId, subMenuItemId) || other.subMenuItemId == subMenuItemId)&&(identical(other.yieldPct, yieldPct) || other.yieldPct == yieldPct)&&(identical(other.isOptional, isOptional) || other.isOptional == isOptional)&&(identical(other.attachRatePct, attachRatePct) || other.attachRatePct == attachRatePct)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineNo,componentType,qtyPerPortion,uomId,productId,subMenuItemId,yieldPct,isOptional,attachRatePct,note);
}

@override
String toString() {
    return 'RecipeLineInput(lineNo: $lineNo, componentType: $componentType, qtyPerPortion: $qtyPerPortion, uomId: $uomId, productId: $productId, subMenuItemId: $subMenuItemId, yieldPct: $yieldPct, isOptional: $isOptional, attachRatePct: $attachRatePct, note: $note)';
}


}

/// @nodoc
abstract mixin class _$RecipeLineInputCopyWith<$Res> implements $RecipeLineInputCopyWith<$Res> {
  factory _$RecipeLineInputCopyWith(_RecipeLineInput value, $Res Function(_RecipeLineInput) _then) = __$RecipeLineInputCopyWithImpl;
@override @useResult
$Res call({
 int lineNo, ComponentType componentType, Quantity qtyPerPortion, int uomId, int? productId, int? subMenuItemId, Decimal? yieldPct, bool isOptional, Decimal? attachRatePct, String? note
});




}
/// @nodoc
class __$RecipeLineInputCopyWithImpl<$Res>
    implements _$RecipeLineInputCopyWith<$Res> {
  __$RecipeLineInputCopyWithImpl(this._self, this._then);

  final _RecipeLineInput _self;
  final $Res Function(_RecipeLineInput) _then;

/// Create a copy of RecipeLineInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineNo = null,Object? componentType = null,Object? qtyPerPortion = null,Object? uomId = null,Object? productId = freezed,Object? subMenuItemId = freezed,Object? yieldPct = freezed,Object? isOptional = null,Object? attachRatePct = freezed,Object? note = freezed,}) {
  return _then(_RecipeLineInput(
lineNo: null == lineNo ? _self.lineNo : lineNo // ignore: cast_nullable_to_non_nullable
as int,componentType: null == componentType ? _self.componentType : componentType // ignore: cast_nullable_to_non_nullable
as ComponentType,qtyPerPortion: null == qtyPerPortion ? _self.qtyPerPortion : qtyPerPortion // ignore: cast_nullable_to_non_nullable
as Quantity,uomId: null == uomId ? _self.uomId : uomId // ignore: cast_nullable_to_non_nullable
as int,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,subMenuItemId: freezed == subMenuItemId ? _self.subMenuItemId : subMenuItemId // ignore: cast_nullable_to_non_nullable
as int?,yieldPct: freezed == yieldPct ? _self.yieldPct : yieldPct // ignore: cast_nullable_to_non_nullable
as Decimal?,isOptional: null == isOptional ? _self.isOptional : isOptional // ignore: cast_nullable_to_non_nullable
as bool,attachRatePct: freezed == attachRatePct ? _self.attachRatePct : attachRatePct // ignore: cast_nullable_to_non_nullable
as Decimal?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RecipeSummaryDto {

 int get id; int get menuItemId; int get versionNo; RecipeStatus get status;@DateOnlyConverter() DateTime get validFrom; String? get menuItemName;@NullableDateOnlyConverter() DateTime? get validTo; int get lineCount;
/// Create a copy of RecipeSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeSummaryDtoCopyWith<RecipeSummaryDto> get copyWith => _$RecipeSummaryDtoCopyWithImpl<RecipeSummaryDto>(this as RecipeSummaryDto, _$identity);

  /// Serializes this RecipeSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecipeSummaryDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeSummaryDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.versionNo, _this.versionNo) || other.versionNo == _this.versionNo)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.validFrom, _this.validFrom) || other.validFrom == _this.validFrom)&&(identical(other.menuItemName, _this.menuItemName) || other.menuItemName == _this.menuItemName)&&(identical(other.validTo, _this.validTo) || other.validTo == _this.validTo)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecipeSummaryDto;
  return Object.hash(runtimeType,_this.id,_this.menuItemId,_this.versionNo,_this.status,_this.validFrom,_this.menuItemName,_this.validTo,_this.lineCount);
}

@override
String toString() {
  final _this = this as RecipeSummaryDto;
  return 'RecipeSummaryDto(id: ${_this.id}, menuItemId: ${_this.menuItemId}, versionNo: ${_this.versionNo}, status: ${_this.status}, validFrom: ${_this.validFrom}, menuItemName: ${_this.menuItemName}, validTo: ${_this.validTo}, lineCount: ${_this.lineCount})';
}


}

/// @nodoc
abstract mixin class $RecipeSummaryDtoCopyWith<$Res>  {
  factory $RecipeSummaryDtoCopyWith(RecipeSummaryDto value, $Res Function(RecipeSummaryDto) _then) = _$RecipeSummaryDtoCopyWithImpl;
@useResult
$Res call({
 int id, int menuItemId, int versionNo, RecipeStatus status,@DateOnlyConverter() DateTime validFrom, String? menuItemName,@NullableDateOnlyConverter() DateTime? validTo, int lineCount
});




}
/// @nodoc
class _$RecipeSummaryDtoCopyWithImpl<$Res>
    implements $RecipeSummaryDtoCopyWith<$Res> {
  _$RecipeSummaryDtoCopyWithImpl(this._self, this._then);

  final RecipeSummaryDto _self;
  final $Res Function(RecipeSummaryDto) _then;

/// Create a copy of RecipeSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? menuItemId = null,Object? versionNo = null,Object? status = null,Object? validFrom = null,Object? menuItemName = freezed,Object? validTo = freezed,Object? lineCount = null,}) {
  return _then(RecipeSummaryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as int,versionNo: null == versionNo ? _self.versionNo : versionNo // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecipeStatus,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,menuItemName: freezed == menuItemName ? _self.menuItemName : menuItemName // ignore: cast_nullable_to_non_nullable
as String?,validTo: freezed == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as DateTime?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipeSummaryDto].
extension RecipeSummaryDtoPatterns on RecipeSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _RecipeSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int menuItemId,  int versionNo,  RecipeStatus status, @DateOnlyConverter()  DateTime validFrom,  String? menuItemName, @NullableDateOnlyConverter()  DateTime? validTo,  int lineCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeSummaryDto() when $default != null:
return $default(_that.id,_that.menuItemId,_that.versionNo,_that.status,_that.validFrom,_that.menuItemName,_that.validTo,_that.lineCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int menuItemId,  int versionNo,  RecipeStatus status, @DateOnlyConverter()  DateTime validFrom,  String? menuItemName, @NullableDateOnlyConverter()  DateTime? validTo,  int lineCount)  $default,) {final _that = this;
switch (_that) {
case _RecipeSummaryDto():
return $default(_that.id,_that.menuItemId,_that.versionNo,_that.status,_that.validFrom,_that.menuItemName,_that.validTo,_that.lineCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int menuItemId,  int versionNo,  RecipeStatus status, @DateOnlyConverter()  DateTime validFrom,  String? menuItemName, @NullableDateOnlyConverter()  DateTime? validTo,  int lineCount)?  $default,) {final _that = this;
switch (_that) {
case _RecipeSummaryDto() when $default != null:
return $default(_that.id,_that.menuItemId,_that.versionNo,_that.status,_that.validFrom,_that.menuItemName,_that.validTo,_that.lineCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipeSummaryDto extends RecipeSummaryDto {
  const _RecipeSummaryDto({required this.id, required this.menuItemId, required this.versionNo, required this.status, @DateOnlyConverter() required this.validFrom, this.menuItemName, @NullableDateOnlyConverter() this.validTo, this.lineCount = 0}): super._();
  factory _RecipeSummaryDto.fromJson(Map<String, dynamic> json) => _$RecipeSummaryDtoFromJson(json);

@override final  int id;
@override final  int menuItemId;
@override final  int versionNo;
@override final  RecipeStatus status;
@override@DateOnlyConverter() final  DateTime validFrom;
@override final  String? menuItemName;
@override@NullableDateOnlyConverter() final  DateTime? validTo;
@override@JsonKey() final  int lineCount;

/// Create a copy of RecipeSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeSummaryDtoCopyWith<_RecipeSummaryDto> get copyWith => __$RecipeSummaryDtoCopyWithImpl<_RecipeSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.versionNo, versionNo) || other.versionNo == versionNo)&&(identical(other.status, status) || other.status == status)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.menuItemName, menuItemName) || other.menuItemName == menuItemName)&&(identical(other.validTo, validTo) || other.validTo == validTo)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,menuItemId,versionNo,status,validFrom,menuItemName,validTo,lineCount);
}

@override
String toString() {
    return 'RecipeSummaryDto(id: $id, menuItemId: $menuItemId, versionNo: $versionNo, status: $status, validFrom: $validFrom, menuItemName: $menuItemName, validTo: $validTo, lineCount: $lineCount)';
}


}

/// @nodoc
abstract mixin class _$RecipeSummaryDtoCopyWith<$Res> implements $RecipeSummaryDtoCopyWith<$Res> {
  factory _$RecipeSummaryDtoCopyWith(_RecipeSummaryDto value, $Res Function(_RecipeSummaryDto) _then) = __$RecipeSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int menuItemId, int versionNo, RecipeStatus status,@DateOnlyConverter() DateTime validFrom, String? menuItemName,@NullableDateOnlyConverter() DateTime? validTo, int lineCount
});




}
/// @nodoc
class __$RecipeSummaryDtoCopyWithImpl<$Res>
    implements _$RecipeSummaryDtoCopyWith<$Res> {
  __$RecipeSummaryDtoCopyWithImpl(this._self, this._then);

  final _RecipeSummaryDto _self;
  final $Res Function(_RecipeSummaryDto) _then;

/// Create a copy of RecipeSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? menuItemId = null,Object? versionNo = null,Object? status = null,Object? validFrom = null,Object? menuItemName = freezed,Object? validTo = freezed,Object? lineCount = null,}) {
  return _then(_RecipeSummaryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as int,versionNo: null == versionNo ? _self.versionNo : versionNo // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecipeStatus,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,menuItemName: freezed == menuItemName ? _self.menuItemName : menuItemName // ignore: cast_nullable_to_non_nullable
as String?,validTo: freezed == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as DateTime?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RecipeDto {

 int get id; int get menuItemId; int get versionNo; RecipeStatus get status;@DateOnlyConverter() DateTime get validFrom; Quantity get yieldPortions; int get rowVersion; String? get menuItemName;@NullableDateOnlyConverter() DateTime? get validTo; int get lineCount; String? get note; List<RecipeLineDto> get lines;
/// Create a copy of RecipeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeDtoCopyWith<RecipeDto> get copyWith => _$RecipeDtoCopyWithImpl<RecipeDto>(this as RecipeDto, _$identity);

  /// Serializes this RecipeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecipeDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.versionNo, _this.versionNo) || other.versionNo == _this.versionNo)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.validFrom, _this.validFrom) || other.validFrom == _this.validFrom)&&(identical(other.yieldPortions, _this.yieldPortions) || other.yieldPortions == _this.yieldPortions)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&(identical(other.menuItemName, _this.menuItemName) || other.menuItemName == _this.menuItemName)&&(identical(other.validTo, _this.validTo) || other.validTo == _this.validTo)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&(identical(other.note, _this.note) || other.note == _this.note)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecipeDto;
  return Object.hash(runtimeType,_this.id,_this.menuItemId,_this.versionNo,_this.status,_this.validFrom,_this.yieldPortions,_this.rowVersion,_this.menuItemName,_this.validTo,_this.lineCount,_this.note,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as RecipeDto;
  return 'RecipeDto(id: ${_this.id}, menuItemId: ${_this.menuItemId}, versionNo: ${_this.versionNo}, status: ${_this.status}, validFrom: ${_this.validFrom}, yieldPortions: ${_this.yieldPortions}, rowVersion: ${_this.rowVersion}, menuItemName: ${_this.menuItemName}, validTo: ${_this.validTo}, lineCount: ${_this.lineCount}, note: ${_this.note}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $RecipeDtoCopyWith<$Res>  {
  factory $RecipeDtoCopyWith(RecipeDto value, $Res Function(RecipeDto) _then) = _$RecipeDtoCopyWithImpl;
@useResult
$Res call({
 int id, int menuItemId, int versionNo, RecipeStatus status,@DateOnlyConverter() DateTime validFrom, Quantity yieldPortions, int rowVersion, String? menuItemName,@NullableDateOnlyConverter() DateTime? validTo, int lineCount, String? note, List<RecipeLineDto> lines
});




}
/// @nodoc
class _$RecipeDtoCopyWithImpl<$Res>
    implements $RecipeDtoCopyWith<$Res> {
  _$RecipeDtoCopyWithImpl(this._self, this._then);

  final RecipeDto _self;
  final $Res Function(RecipeDto) _then;

/// Create a copy of RecipeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? menuItemId = null,Object? versionNo = null,Object? status = null,Object? validFrom = null,Object? yieldPortions = null,Object? rowVersion = null,Object? menuItemName = freezed,Object? validTo = freezed,Object? lineCount = null,Object? note = freezed,Object? lines = null,}) {
  return _then(RecipeDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as int,versionNo: null == versionNo ? _self.versionNo : versionNo // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecipeStatus,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,yieldPortions: null == yieldPortions ? _self.yieldPortions : yieldPortions // ignore: cast_nullable_to_non_nullable
as Quantity,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,menuItemName: freezed == menuItemName ? _self.menuItemName : menuItemName // ignore: cast_nullable_to_non_nullable
as String?,validTo: freezed == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as DateTime?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<RecipeLineDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipeDto].
extension RecipeDtoPatterns on RecipeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeDto value)  $default,){
final _that = this;
switch (_that) {
case _RecipeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int menuItemId,  int versionNo,  RecipeStatus status, @DateOnlyConverter()  DateTime validFrom,  Quantity yieldPortions,  int rowVersion,  String? menuItemName, @NullableDateOnlyConverter()  DateTime? validTo,  int lineCount,  String? note,  List<RecipeLineDto> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeDto() when $default != null:
return $default(_that.id,_that.menuItemId,_that.versionNo,_that.status,_that.validFrom,_that.yieldPortions,_that.rowVersion,_that.menuItemName,_that.validTo,_that.lineCount,_that.note,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int menuItemId,  int versionNo,  RecipeStatus status, @DateOnlyConverter()  DateTime validFrom,  Quantity yieldPortions,  int rowVersion,  String? menuItemName, @NullableDateOnlyConverter()  DateTime? validTo,  int lineCount,  String? note,  List<RecipeLineDto> lines)  $default,) {final _that = this;
switch (_that) {
case _RecipeDto():
return $default(_that.id,_that.menuItemId,_that.versionNo,_that.status,_that.validFrom,_that.yieldPortions,_that.rowVersion,_that.menuItemName,_that.validTo,_that.lineCount,_that.note,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int menuItemId,  int versionNo,  RecipeStatus status, @DateOnlyConverter()  DateTime validFrom,  Quantity yieldPortions,  int rowVersion,  String? menuItemName, @NullableDateOnlyConverter()  DateTime? validTo,  int lineCount,  String? note,  List<RecipeLineDto> lines)?  $default,) {final _that = this;
switch (_that) {
case _RecipeDto() when $default != null:
return $default(_that.id,_that.menuItemId,_that.versionNo,_that.status,_that.validFrom,_that.yieldPortions,_that.rowVersion,_that.menuItemName,_that.validTo,_that.lineCount,_that.note,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipeDto extends RecipeDto {
  const _RecipeDto({required this.id, required this.menuItemId, required this.versionNo, required this.status, @DateOnlyConverter() required this.validFrom, required this.yieldPortions, required this.rowVersion, this.menuItemName, @NullableDateOnlyConverter() this.validTo, this.lineCount = 0, this.note,  List<RecipeLineDto> lines = const <RecipeLineDto>[]}): _lines = lines,super._();
  factory _RecipeDto.fromJson(Map<String, dynamic> json) => _$RecipeDtoFromJson(json);

@override final  int id;
@override final  int menuItemId;
@override final  int versionNo;
@override final  RecipeStatus status;
@override@DateOnlyConverter() final  DateTime validFrom;
@override final  Quantity yieldPortions;
@override final  int rowVersion;
@override final  String? menuItemName;
@override@NullableDateOnlyConverter() final  DateTime? validTo;
@override@JsonKey() final  int lineCount;
@override final  String? note;
 final  List<RecipeLineDto> _lines;
@override@JsonKey() List<RecipeLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of RecipeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeDtoCopyWith<_RecipeDto> get copyWith => __$RecipeDtoCopyWithImpl<_RecipeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeDto&&(identical(other.id, id) || other.id == id)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.versionNo, versionNo) || other.versionNo == versionNo)&&(identical(other.status, status) || other.status == status)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.yieldPortions, yieldPortions) || other.yieldPortions == yieldPortions)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&(identical(other.menuItemName, menuItemName) || other.menuItemName == menuItemName)&&(identical(other.validTo, validTo) || other.validTo == validTo)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,menuItemId,versionNo,status,validFrom,yieldPortions,rowVersion,menuItemName,validTo,lineCount,note,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'RecipeDto(id: $id, menuItemId: $menuItemId, versionNo: $versionNo, status: $status, validFrom: $validFrom, yieldPortions: $yieldPortions, rowVersion: $rowVersion, menuItemName: $menuItemName, validTo: $validTo, lineCount: $lineCount, note: $note, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$RecipeDtoCopyWith<$Res> implements $RecipeDtoCopyWith<$Res> {
  factory _$RecipeDtoCopyWith(_RecipeDto value, $Res Function(_RecipeDto) _then) = __$RecipeDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int menuItemId, int versionNo, RecipeStatus status,@DateOnlyConverter() DateTime validFrom, Quantity yieldPortions, int rowVersion, String? menuItemName,@NullableDateOnlyConverter() DateTime? validTo, int lineCount, String? note, List<RecipeLineDto> lines
});




}
/// @nodoc
class __$RecipeDtoCopyWithImpl<$Res>
    implements _$RecipeDtoCopyWith<$Res> {
  __$RecipeDtoCopyWithImpl(this._self, this._then);

  final _RecipeDto _self;
  final $Res Function(_RecipeDto) _then;

/// Create a copy of RecipeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? menuItemId = null,Object? versionNo = null,Object? status = null,Object? validFrom = null,Object? yieldPortions = null,Object? rowVersion = null,Object? menuItemName = freezed,Object? validTo = freezed,Object? lineCount = null,Object? note = freezed,Object? lines = null,}) {
  return _then(_RecipeDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as int,versionNo: null == versionNo ? _self.versionNo : versionNo // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecipeStatus,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,yieldPortions: null == yieldPortions ? _self.yieldPortions : yieldPortions // ignore: cast_nullable_to_non_nullable
as Quantity,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,menuItemName: freezed == menuItemName ? _self.menuItemName : menuItemName // ignore: cast_nullable_to_non_nullable
as String?,validTo: freezed == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as DateTime?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<RecipeLineDto>,
  ));
}


}


/// @nodoc
mixin _$CreateRecipeVersionRequest {

@DateOnlyConverter() DateTime get validFrom;/// Portions produced by one preparation; sauces and other sub-recipes
/// yield more than one. Defaults to 1.
 Quantity? get yieldPortions;/// Copies the component lines of an existing version.
 int? get copyFromRecipeId; String? get note; List<RecipeLineInput> get lines;
/// Create a copy of CreateRecipeVersionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateRecipeVersionRequestCopyWith<CreateRecipeVersionRequest> get copyWith => _$CreateRecipeVersionRequestCopyWithImpl<CreateRecipeVersionRequest>(this as CreateRecipeVersionRequest, _$identity);

  /// Serializes this CreateRecipeVersionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateRecipeVersionRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateRecipeVersionRequest&&(identical(other.validFrom, _this.validFrom) || other.validFrom == _this.validFrom)&&(identical(other.yieldPortions, _this.yieldPortions) || other.yieldPortions == _this.yieldPortions)&&(identical(other.copyFromRecipeId, _this.copyFromRecipeId) || other.copyFromRecipeId == _this.copyFromRecipeId)&&(identical(other.note, _this.note) || other.note == _this.note)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateRecipeVersionRequest;
  return Object.hash(runtimeType,_this.validFrom,_this.yieldPortions,_this.copyFromRecipeId,_this.note,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as CreateRecipeVersionRequest;
  return 'CreateRecipeVersionRequest(validFrom: ${_this.validFrom}, yieldPortions: ${_this.yieldPortions}, copyFromRecipeId: ${_this.copyFromRecipeId}, note: ${_this.note}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $CreateRecipeVersionRequestCopyWith<$Res>  {
  factory $CreateRecipeVersionRequestCopyWith(CreateRecipeVersionRequest value, $Res Function(CreateRecipeVersionRequest) _then) = _$CreateRecipeVersionRequestCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime validFrom, Quantity? yieldPortions, int? copyFromRecipeId, String? note, List<RecipeLineInput> lines
});




}
/// @nodoc
class _$CreateRecipeVersionRequestCopyWithImpl<$Res>
    implements $CreateRecipeVersionRequestCopyWith<$Res> {
  _$CreateRecipeVersionRequestCopyWithImpl(this._self, this._then);

  final CreateRecipeVersionRequest _self;
  final $Res Function(CreateRecipeVersionRequest) _then;

/// Create a copy of CreateRecipeVersionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? validFrom = null,Object? yieldPortions = freezed,Object? copyFromRecipeId = freezed,Object? note = freezed,Object? lines = null,}) {
  return _then(CreateRecipeVersionRequest(
validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,yieldPortions: freezed == yieldPortions ? _self.yieldPortions : yieldPortions // ignore: cast_nullable_to_non_nullable
as Quantity?,copyFromRecipeId: freezed == copyFromRecipeId ? _self.copyFromRecipeId : copyFromRecipeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<RecipeLineInput>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateRecipeVersionRequest].
extension CreateRecipeVersionRequestPatterns on CreateRecipeVersionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateRecipeVersionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateRecipeVersionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateRecipeVersionRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateRecipeVersionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateRecipeVersionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateRecipeVersionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime validFrom,  Quantity? yieldPortions,  int? copyFromRecipeId,  String? note,  List<RecipeLineInput> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateRecipeVersionRequest() when $default != null:
return $default(_that.validFrom,_that.yieldPortions,_that.copyFromRecipeId,_that.note,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime validFrom,  Quantity? yieldPortions,  int? copyFromRecipeId,  String? note,  List<RecipeLineInput> lines)  $default,) {final _that = this;
switch (_that) {
case _CreateRecipeVersionRequest():
return $default(_that.validFrom,_that.yieldPortions,_that.copyFromRecipeId,_that.note,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime validFrom,  Quantity? yieldPortions,  int? copyFromRecipeId,  String? note,  List<RecipeLineInput> lines)?  $default,) {final _that = this;
switch (_that) {
case _CreateRecipeVersionRequest() when $default != null:
return $default(_that.validFrom,_that.yieldPortions,_that.copyFromRecipeId,_that.note,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateRecipeVersionRequest implements CreateRecipeVersionRequest {
  const _CreateRecipeVersionRequest({@DateOnlyConverter() required this.validFrom, this.yieldPortions, this.copyFromRecipeId, this.note,  List<RecipeLineInput> lines = const <RecipeLineInput>[]}): _lines = lines;
  factory _CreateRecipeVersionRequest.fromJson(Map<String, dynamic> json) => _$CreateRecipeVersionRequestFromJson(json);

@override@DateOnlyConverter() final  DateTime validFrom;
/// Portions produced by one preparation; sauces and other sub-recipes
/// yield more than one. Defaults to 1.
@override final  Quantity? yieldPortions;
/// Copies the component lines of an existing version.
@override final  int? copyFromRecipeId;
@override final  String? note;
 final  List<RecipeLineInput> _lines;
@override@JsonKey() List<RecipeLineInput> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of CreateRecipeVersionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateRecipeVersionRequestCopyWith<_CreateRecipeVersionRequest> get copyWith => __$CreateRecipeVersionRequestCopyWithImpl<_CreateRecipeVersionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateRecipeVersionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateRecipeVersionRequest&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.yieldPortions, yieldPortions) || other.yieldPortions == yieldPortions)&&(identical(other.copyFromRecipeId, copyFromRecipeId) || other.copyFromRecipeId == copyFromRecipeId)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,validFrom,yieldPortions,copyFromRecipeId,note,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'CreateRecipeVersionRequest(validFrom: $validFrom, yieldPortions: $yieldPortions, copyFromRecipeId: $copyFromRecipeId, note: $note, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$CreateRecipeVersionRequestCopyWith<$Res> implements $CreateRecipeVersionRequestCopyWith<$Res> {
  factory _$CreateRecipeVersionRequestCopyWith(_CreateRecipeVersionRequest value, $Res Function(_CreateRecipeVersionRequest) _then) = __$CreateRecipeVersionRequestCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime validFrom, Quantity? yieldPortions, int? copyFromRecipeId, String? note, List<RecipeLineInput> lines
});




}
/// @nodoc
class __$CreateRecipeVersionRequestCopyWithImpl<$Res>
    implements _$CreateRecipeVersionRequestCopyWith<$Res> {
  __$CreateRecipeVersionRequestCopyWithImpl(this._self, this._then);

  final _CreateRecipeVersionRequest _self;
  final $Res Function(_CreateRecipeVersionRequest) _then;

/// Create a copy of CreateRecipeVersionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? validFrom = null,Object? yieldPortions = freezed,Object? copyFromRecipeId = freezed,Object? note = freezed,Object? lines = null,}) {
  return _then(_CreateRecipeVersionRequest(
validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,yieldPortions: freezed == yieldPortions ? _self.yieldPortions : yieldPortions // ignore: cast_nullable_to_non_nullable
as Quantity?,copyFromRecipeId: freezed == copyFromRecipeId ? _self.copyFromRecipeId : copyFromRecipeId // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<RecipeLineInput>,
  ));
}


}


/// @nodoc
mixin _$UpdateRecipeRequest {

 int get rowVersion; List<RecipeLineInput> get lines; Quantity? get yieldPortions; String? get note;
/// Create a copy of UpdateRecipeRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateRecipeRequestCopyWith<UpdateRecipeRequest> get copyWith => _$UpdateRecipeRequestCopyWithImpl<UpdateRecipeRequest>(this as UpdateRecipeRequest, _$identity);

  /// Serializes this UpdateRecipeRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateRecipeRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateRecipeRequest&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.yieldPortions, _this.yieldPortions) || other.yieldPortions == _this.yieldPortions)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateRecipeRequest;
  return Object.hash(runtimeType,_this.rowVersion,const DeepCollectionEquality().hash(_this.lines),_this.yieldPortions,_this.note);
}

@override
String toString() {
  final _this = this as UpdateRecipeRequest;
  return 'UpdateRecipeRequest(rowVersion: ${_this.rowVersion}, lines: ${_this.lines}, yieldPortions: ${_this.yieldPortions}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $UpdateRecipeRequestCopyWith<$Res>  {
  factory $UpdateRecipeRequestCopyWith(UpdateRecipeRequest value, $Res Function(UpdateRecipeRequest) _then) = _$UpdateRecipeRequestCopyWithImpl;
@useResult
$Res call({
 int rowVersion, List<RecipeLineInput> lines, Quantity? yieldPortions, String? note
});




}
/// @nodoc
class _$UpdateRecipeRequestCopyWithImpl<$Res>
    implements $UpdateRecipeRequestCopyWith<$Res> {
  _$UpdateRecipeRequestCopyWithImpl(this._self, this._then);

  final UpdateRecipeRequest _self;
  final $Res Function(UpdateRecipeRequest) _then;

/// Create a copy of UpdateRecipeRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowVersion = null,Object? lines = null,Object? yieldPortions = freezed,Object? note = freezed,}) {
  return _then(UpdateRecipeRequest(
rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<RecipeLineInput>,yieldPortions: freezed == yieldPortions ? _self.yieldPortions : yieldPortions // ignore: cast_nullable_to_non_nullable
as Quantity?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateRecipeRequest].
extension UpdateRecipeRequestPatterns on UpdateRecipeRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateRecipeRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateRecipeRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateRecipeRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateRecipeRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateRecipeRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateRecipeRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rowVersion,  List<RecipeLineInput> lines,  Quantity? yieldPortions,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateRecipeRequest() when $default != null:
return $default(_that.rowVersion,_that.lines,_that.yieldPortions,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rowVersion,  List<RecipeLineInput> lines,  Quantity? yieldPortions,  String? note)  $default,) {final _that = this;
switch (_that) {
case _UpdateRecipeRequest():
return $default(_that.rowVersion,_that.lines,_that.yieldPortions,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rowVersion,  List<RecipeLineInput> lines,  Quantity? yieldPortions,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _UpdateRecipeRequest() when $default != null:
return $default(_that.rowVersion,_that.lines,_that.yieldPortions,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateRecipeRequest implements UpdateRecipeRequest {
  const _UpdateRecipeRequest({required this.rowVersion, required  List<RecipeLineInput> lines, this.yieldPortions, this.note}): _lines = lines;
  factory _UpdateRecipeRequest.fromJson(Map<String, dynamic> json) => _$UpdateRecipeRequestFromJson(json);

@override final  int rowVersion;
 final  List<RecipeLineInput> _lines;
@override List<RecipeLineInput> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  Quantity? yieldPortions;
@override final  String? note;

/// Create a copy of UpdateRecipeRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateRecipeRequestCopyWith<_UpdateRecipeRequest> get copyWith => __$UpdateRecipeRequestCopyWithImpl<_UpdateRecipeRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateRecipeRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateRecipeRequest&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.yieldPortions, yieldPortions) || other.yieldPortions == yieldPortions)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rowVersion,const DeepCollectionEquality().hash(_lines),yieldPortions,note);
}

@override
String toString() {
    return 'UpdateRecipeRequest(rowVersion: $rowVersion, lines: $lines, yieldPortions: $yieldPortions, note: $note)';
}


}

/// @nodoc
abstract mixin class _$UpdateRecipeRequestCopyWith<$Res> implements $UpdateRecipeRequestCopyWith<$Res> {
  factory _$UpdateRecipeRequestCopyWith(_UpdateRecipeRequest value, $Res Function(_UpdateRecipeRequest) _then) = __$UpdateRecipeRequestCopyWithImpl;
@override @useResult
$Res call({
 int rowVersion, List<RecipeLineInput> lines, Quantity? yieldPortions, String? note
});




}
/// @nodoc
class __$UpdateRecipeRequestCopyWithImpl<$Res>
    implements _$UpdateRecipeRequestCopyWith<$Res> {
  __$UpdateRecipeRequestCopyWithImpl(this._self, this._then);

  final _UpdateRecipeRequest _self;
  final $Res Function(_UpdateRecipeRequest) _then;

/// Create a copy of UpdateRecipeRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowVersion = null,Object? lines = null,Object? yieldPortions = freezed,Object? note = freezed,}) {
  return _then(_UpdateRecipeRequest(
rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<RecipeLineInput>,yieldPortions: freezed == yieldPortions ? _self.yieldPortions : yieldPortions // ignore: cast_nullable_to_non_nullable
as Quantity?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ActivateRecipeRequest {

@DateOnlyConverter() DateTime get validFrom; int get rowVersion;
/// Create a copy of ActivateRecipeRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivateRecipeRequestCopyWith<ActivateRecipeRequest> get copyWith => _$ActivateRecipeRequestCopyWithImpl<ActivateRecipeRequest>(this as ActivateRecipeRequest, _$identity);

  /// Serializes this ActivateRecipeRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ActivateRecipeRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivateRecipeRequest&&(identical(other.validFrom, _this.validFrom) || other.validFrom == _this.validFrom)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ActivateRecipeRequest;
  return Object.hash(runtimeType,_this.validFrom,_this.rowVersion);
}

@override
String toString() {
  final _this = this as ActivateRecipeRequest;
  return 'ActivateRecipeRequest(validFrom: ${_this.validFrom}, rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $ActivateRecipeRequestCopyWith<$Res>  {
  factory $ActivateRecipeRequestCopyWith(ActivateRecipeRequest value, $Res Function(ActivateRecipeRequest) _then) = _$ActivateRecipeRequestCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime validFrom, int rowVersion
});




}
/// @nodoc
class _$ActivateRecipeRequestCopyWithImpl<$Res>
    implements $ActivateRecipeRequestCopyWith<$Res> {
  _$ActivateRecipeRequestCopyWithImpl(this._self, this._then);

  final ActivateRecipeRequest _self;
  final $Res Function(ActivateRecipeRequest) _then;

/// Create a copy of ActivateRecipeRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? validFrom = null,Object? rowVersion = null,}) {
  return _then(ActivateRecipeRequest(
validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivateRecipeRequest].
extension ActivateRecipeRequestPatterns on ActivateRecipeRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivateRecipeRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivateRecipeRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivateRecipeRequest value)  $default,){
final _that = this;
switch (_that) {
case _ActivateRecipeRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivateRecipeRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ActivateRecipeRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime validFrom,  int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivateRecipeRequest() when $default != null:
return $default(_that.validFrom,_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime validFrom,  int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _ActivateRecipeRequest():
return $default(_that.validFrom,_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime validFrom,  int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _ActivateRecipeRequest() when $default != null:
return $default(_that.validFrom,_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivateRecipeRequest implements ActivateRecipeRequest {
  const _ActivateRecipeRequest({@DateOnlyConverter() required this.validFrom, required this.rowVersion});
  factory _ActivateRecipeRequest.fromJson(Map<String, dynamic> json) => _$ActivateRecipeRequestFromJson(json);

@override@DateOnlyConverter() final  DateTime validFrom;
@override final  int rowVersion;

/// Create a copy of ActivateRecipeRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivateRecipeRequestCopyWith<_ActivateRecipeRequest> get copyWith => __$ActivateRecipeRequestCopyWithImpl<_ActivateRecipeRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivateRecipeRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivateRecipeRequest&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,validFrom,rowVersion);
}

@override
String toString() {
    return 'ActivateRecipeRequest(validFrom: $validFrom, rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$ActivateRecipeRequestCopyWith<$Res> implements $ActivateRecipeRequestCopyWith<$Res> {
  factory _$ActivateRecipeRequestCopyWith(_ActivateRecipeRequest value, $Res Function(_ActivateRecipeRequest) _then) = __$ActivateRecipeRequestCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime validFrom, int rowVersion
});




}
/// @nodoc
class __$ActivateRecipeRequestCopyWithImpl<$Res>
    implements _$ActivateRecipeRequestCopyWith<$Res> {
  __$ActivateRecipeRequestCopyWithImpl(this._self, this._then);

  final _ActivateRecipeRequest _self;
  final $Res Function(_ActivateRecipeRequest) _then;

/// Create a copy of ActivateRecipeRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? validFrom = null,Object? rowVersion = null,}) {
  return _then(_ActivateRecipeRequest(
validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RecipeExplosionLineDto {

 int get productId; Quantity get requiredQtyBase; int get baseUomId; String get baseUomCode; String? get productSku; String? get productName;/// Set when the ingredient arrived through a sub-recipe.
 String? get viaSubRecipe; int get depth;
/// Create a copy of RecipeExplosionLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeExplosionLineDtoCopyWith<RecipeExplosionLineDto> get copyWith => _$RecipeExplosionLineDtoCopyWithImpl<RecipeExplosionLineDto>(this as RecipeExplosionLineDto, _$identity);

  /// Serializes this RecipeExplosionLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecipeExplosionLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeExplosionLineDto&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.requiredQtyBase, _this.requiredQtyBase) || other.requiredQtyBase == _this.requiredQtyBase)&&(identical(other.baseUomId, _this.baseUomId) || other.baseUomId == _this.baseUomId)&&(identical(other.baseUomCode, _this.baseUomCode) || other.baseUomCode == _this.baseUomCode)&&(identical(other.productSku, _this.productSku) || other.productSku == _this.productSku)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.viaSubRecipe, _this.viaSubRecipe) || other.viaSubRecipe == _this.viaSubRecipe)&&(identical(other.depth, _this.depth) || other.depth == _this.depth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecipeExplosionLineDto;
  return Object.hash(runtimeType,_this.productId,_this.requiredQtyBase,_this.baseUomId,_this.baseUomCode,_this.productSku,_this.productName,_this.viaSubRecipe,_this.depth);
}

@override
String toString() {
  final _this = this as RecipeExplosionLineDto;
  return 'RecipeExplosionLineDto(productId: ${_this.productId}, requiredQtyBase: ${_this.requiredQtyBase}, baseUomId: ${_this.baseUomId}, baseUomCode: ${_this.baseUomCode}, productSku: ${_this.productSku}, productName: ${_this.productName}, viaSubRecipe: ${_this.viaSubRecipe}, depth: ${_this.depth})';
}


}

/// @nodoc
abstract mixin class $RecipeExplosionLineDtoCopyWith<$Res>  {
  factory $RecipeExplosionLineDtoCopyWith(RecipeExplosionLineDto value, $Res Function(RecipeExplosionLineDto) _then) = _$RecipeExplosionLineDtoCopyWithImpl;
@useResult
$Res call({
 int productId, Quantity requiredQtyBase, int baseUomId, String baseUomCode, String? productSku, String? productName, String? viaSubRecipe, int depth
});




}
/// @nodoc
class _$RecipeExplosionLineDtoCopyWithImpl<$Res>
    implements $RecipeExplosionLineDtoCopyWith<$Res> {
  _$RecipeExplosionLineDtoCopyWithImpl(this._self, this._then);

  final RecipeExplosionLineDto _self;
  final $Res Function(RecipeExplosionLineDto) _then;

/// Create a copy of RecipeExplosionLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? requiredQtyBase = null,Object? baseUomId = null,Object? baseUomCode = null,Object? productSku = freezed,Object? productName = freezed,Object? viaSubRecipe = freezed,Object? depth = null,}) {
  return _then(RecipeExplosionLineDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,requiredQtyBase: null == requiredQtyBase ? _self.requiredQtyBase : requiredQtyBase // ignore: cast_nullable_to_non_nullable
as Quantity,baseUomId: null == baseUomId ? _self.baseUomId : baseUomId // ignore: cast_nullable_to_non_nullable
as int,baseUomCode: null == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String,productSku: freezed == productSku ? _self.productSku : productSku // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,viaSubRecipe: freezed == viaSubRecipe ? _self.viaSubRecipe : viaSubRecipe // ignore: cast_nullable_to_non_nullable
as String?,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipeExplosionLineDto].
extension RecipeExplosionLineDtoPatterns on RecipeExplosionLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeExplosionLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeExplosionLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeExplosionLineDto value)  $default,){
final _that = this;
switch (_that) {
case _RecipeExplosionLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeExplosionLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeExplosionLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  Quantity requiredQtyBase,  int baseUomId,  String baseUomCode,  String? productSku,  String? productName,  String? viaSubRecipe,  int depth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeExplosionLineDto() when $default != null:
return $default(_that.productId,_that.requiredQtyBase,_that.baseUomId,_that.baseUomCode,_that.productSku,_that.productName,_that.viaSubRecipe,_that.depth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  Quantity requiredQtyBase,  int baseUomId,  String baseUomCode,  String? productSku,  String? productName,  String? viaSubRecipe,  int depth)  $default,) {final _that = this;
switch (_that) {
case _RecipeExplosionLineDto():
return $default(_that.productId,_that.requiredQtyBase,_that.baseUomId,_that.baseUomCode,_that.productSku,_that.productName,_that.viaSubRecipe,_that.depth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  Quantity requiredQtyBase,  int baseUomId,  String baseUomCode,  String? productSku,  String? productName,  String? viaSubRecipe,  int depth)?  $default,) {final _that = this;
switch (_that) {
case _RecipeExplosionLineDto() when $default != null:
return $default(_that.productId,_that.requiredQtyBase,_that.baseUomId,_that.baseUomCode,_that.productSku,_that.productName,_that.viaSubRecipe,_that.depth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipeExplosionLineDto extends RecipeExplosionLineDto {
  const _RecipeExplosionLineDto({required this.productId, required this.requiredQtyBase, required this.baseUomId, required this.baseUomCode, this.productSku, this.productName, this.viaSubRecipe, this.depth = 0}): super._();
  factory _RecipeExplosionLineDto.fromJson(Map<String, dynamic> json) => _$RecipeExplosionLineDtoFromJson(json);

@override final  int productId;
@override final  Quantity requiredQtyBase;
@override final  int baseUomId;
@override final  String baseUomCode;
@override final  String? productSku;
@override final  String? productName;
/// Set when the ingredient arrived through a sub-recipe.
@override final  String? viaSubRecipe;
@override@JsonKey() final  int depth;

/// Create a copy of RecipeExplosionLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeExplosionLineDtoCopyWith<_RecipeExplosionLineDto> get copyWith => __$RecipeExplosionLineDtoCopyWithImpl<_RecipeExplosionLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeExplosionLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeExplosionLineDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.requiredQtyBase, requiredQtyBase) || other.requiredQtyBase == requiredQtyBase)&&(identical(other.baseUomId, baseUomId) || other.baseUomId == baseUomId)&&(identical(other.baseUomCode, baseUomCode) || other.baseUomCode == baseUomCode)&&(identical(other.productSku, productSku) || other.productSku == productSku)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.viaSubRecipe, viaSubRecipe) || other.viaSubRecipe == viaSubRecipe)&&(identical(other.depth, depth) || other.depth == depth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,requiredQtyBase,baseUomId,baseUomCode,productSku,productName,viaSubRecipe,depth);
}

@override
String toString() {
    return 'RecipeExplosionLineDto(productId: $productId, requiredQtyBase: $requiredQtyBase, baseUomId: $baseUomId, baseUomCode: $baseUomCode, productSku: $productSku, productName: $productName, viaSubRecipe: $viaSubRecipe, depth: $depth)';
}


}

/// @nodoc
abstract mixin class _$RecipeExplosionLineDtoCopyWith<$Res> implements $RecipeExplosionLineDtoCopyWith<$Res> {
  factory _$RecipeExplosionLineDtoCopyWith(_RecipeExplosionLineDto value, $Res Function(_RecipeExplosionLineDto) _then) = __$RecipeExplosionLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int productId, Quantity requiredQtyBase, int baseUomId, String baseUomCode, String? productSku, String? productName, String? viaSubRecipe, int depth
});




}
/// @nodoc
class __$RecipeExplosionLineDtoCopyWithImpl<$Res>
    implements _$RecipeExplosionLineDtoCopyWith<$Res> {
  __$RecipeExplosionLineDtoCopyWithImpl(this._self, this._then);

  final _RecipeExplosionLineDto _self;
  final $Res Function(_RecipeExplosionLineDto) _then;

/// Create a copy of RecipeExplosionLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? requiredQtyBase = null,Object? baseUomId = null,Object? baseUomCode = null,Object? productSku = freezed,Object? productName = freezed,Object? viaSubRecipe = freezed,Object? depth = null,}) {
  return _then(_RecipeExplosionLineDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,requiredQtyBase: null == requiredQtyBase ? _self.requiredQtyBase : requiredQtyBase // ignore: cast_nullable_to_non_nullable
as Quantity,baseUomId: null == baseUomId ? _self.baseUomId : baseUomId // ignore: cast_nullable_to_non_nullable
as int,baseUomCode: null == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String,productSku: freezed == productSku ? _self.productSku : productSku // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,viaSubRecipe: freezed == viaSubRecipe ? _self.viaSubRecipe : viaSubRecipe // ignore: cast_nullable_to_non_nullable
as String?,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RecipeExplosionDto {

 int get recipeId; Quantity get portions; List<RecipeExplosionLineDto> get lines; String? get menuItemName; int get maxDepth;
/// Create a copy of RecipeExplosionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeExplosionDtoCopyWith<RecipeExplosionDto> get copyWith => _$RecipeExplosionDtoCopyWithImpl<RecipeExplosionDto>(this as RecipeExplosionDto, _$identity);

  /// Serializes this RecipeExplosionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecipeExplosionDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeExplosionDto&&(identical(other.recipeId, _this.recipeId) || other.recipeId == _this.recipeId)&&(identical(other.portions, _this.portions) || other.portions == _this.portions)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.menuItemName, _this.menuItemName) || other.menuItemName == _this.menuItemName)&&(identical(other.maxDepth, _this.maxDepth) || other.maxDepth == _this.maxDepth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecipeExplosionDto;
  return Object.hash(runtimeType,_this.recipeId,_this.portions,const DeepCollectionEquality().hash(_this.lines),_this.menuItemName,_this.maxDepth);
}

@override
String toString() {
  final _this = this as RecipeExplosionDto;
  return 'RecipeExplosionDto(recipeId: ${_this.recipeId}, portions: ${_this.portions}, lines: ${_this.lines}, menuItemName: ${_this.menuItemName}, maxDepth: ${_this.maxDepth})';
}


}

/// @nodoc
abstract mixin class $RecipeExplosionDtoCopyWith<$Res>  {
  factory $RecipeExplosionDtoCopyWith(RecipeExplosionDto value, $Res Function(RecipeExplosionDto) _then) = _$RecipeExplosionDtoCopyWithImpl;
@useResult
$Res call({
 int recipeId, Quantity portions, List<RecipeExplosionLineDto> lines, String? menuItemName, int maxDepth
});




}
/// @nodoc
class _$RecipeExplosionDtoCopyWithImpl<$Res>
    implements $RecipeExplosionDtoCopyWith<$Res> {
  _$RecipeExplosionDtoCopyWithImpl(this._self, this._then);

  final RecipeExplosionDto _self;
  final $Res Function(RecipeExplosionDto) _then;

/// Create a copy of RecipeExplosionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipeId = null,Object? portions = null,Object? lines = null,Object? menuItemName = freezed,Object? maxDepth = null,}) {
  return _then(RecipeExplosionDto(
recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as int,portions: null == portions ? _self.portions : portions // ignore: cast_nullable_to_non_nullable
as Quantity,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<RecipeExplosionLineDto>,menuItemName: freezed == menuItemName ? _self.menuItemName : menuItemName // ignore: cast_nullable_to_non_nullable
as String?,maxDepth: null == maxDepth ? _self.maxDepth : maxDepth // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipeExplosionDto].
extension RecipeExplosionDtoPatterns on RecipeExplosionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeExplosionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeExplosionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeExplosionDto value)  $default,){
final _that = this;
switch (_that) {
case _RecipeExplosionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeExplosionDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeExplosionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int recipeId,  Quantity portions,  List<RecipeExplosionLineDto> lines,  String? menuItemName,  int maxDepth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeExplosionDto() when $default != null:
return $default(_that.recipeId,_that.portions,_that.lines,_that.menuItemName,_that.maxDepth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int recipeId,  Quantity portions,  List<RecipeExplosionLineDto> lines,  String? menuItemName,  int maxDepth)  $default,) {final _that = this;
switch (_that) {
case _RecipeExplosionDto():
return $default(_that.recipeId,_that.portions,_that.lines,_that.menuItemName,_that.maxDepth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int recipeId,  Quantity portions,  List<RecipeExplosionLineDto> lines,  String? menuItemName,  int maxDepth)?  $default,) {final _that = this;
switch (_that) {
case _RecipeExplosionDto() when $default != null:
return $default(_that.recipeId,_that.portions,_that.lines,_that.menuItemName,_that.maxDepth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipeExplosionDto extends RecipeExplosionDto {
  const _RecipeExplosionDto({required this.recipeId, required this.portions,  List<RecipeExplosionLineDto> lines = const <RecipeExplosionLineDto>[], this.menuItemName, this.maxDepth = 0}): _lines = lines,super._();
  factory _RecipeExplosionDto.fromJson(Map<String, dynamic> json) => _$RecipeExplosionDtoFromJson(json);

@override final  int recipeId;
@override final  Quantity portions;
 final  List<RecipeExplosionLineDto> _lines;
@override@JsonKey() List<RecipeExplosionLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  String? menuItemName;
@override@JsonKey() final  int maxDepth;

/// Create a copy of RecipeExplosionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeExplosionDtoCopyWith<_RecipeExplosionDto> get copyWith => __$RecipeExplosionDtoCopyWithImpl<_RecipeExplosionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeExplosionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeExplosionDto&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.portions, portions) || other.portions == portions)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.menuItemName, menuItemName) || other.menuItemName == menuItemName)&&(identical(other.maxDepth, maxDepth) || other.maxDepth == maxDepth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,recipeId,portions,const DeepCollectionEquality().hash(_lines),menuItemName,maxDepth);
}

@override
String toString() {
    return 'RecipeExplosionDto(recipeId: $recipeId, portions: $portions, lines: $lines, menuItemName: $menuItemName, maxDepth: $maxDepth)';
}


}

/// @nodoc
abstract mixin class _$RecipeExplosionDtoCopyWith<$Res> implements $RecipeExplosionDtoCopyWith<$Res> {
  factory _$RecipeExplosionDtoCopyWith(_RecipeExplosionDto value, $Res Function(_RecipeExplosionDto) _then) = __$RecipeExplosionDtoCopyWithImpl;
@override @useResult
$Res call({
 int recipeId, Quantity portions, List<RecipeExplosionLineDto> lines, String? menuItemName, int maxDepth
});




}
/// @nodoc
class __$RecipeExplosionDtoCopyWithImpl<$Res>
    implements _$RecipeExplosionDtoCopyWith<$Res> {
  __$RecipeExplosionDtoCopyWithImpl(this._self, this._then);

  final _RecipeExplosionDto _self;
  final $Res Function(_RecipeExplosionDto) _then;

/// Create a copy of RecipeExplosionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipeId = null,Object? portions = null,Object? lines = null,Object? menuItemName = freezed,Object? maxDepth = null,}) {
  return _then(_RecipeExplosionDto(
recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as int,portions: null == portions ? _self.portions : portions // ignore: cast_nullable_to_non_nullable
as Quantity,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<RecipeExplosionLineDto>,menuItemName: freezed == menuItemName ? _self.menuItemName : menuItemName // ignore: cast_nullable_to_non_nullable
as String?,maxDepth: null == maxDepth ? _self.maxDepth : maxDepth // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SalesLineDto {

 Quantity get qtySold; int? get id; int? get menuItemId; String? get menuItemName;/// POS code kept verbatim when nothing matched it.
 String? get rawPosCode; bool get isMapped;/// `false` — the item is known but has no recipe, so it depletes nothing.
 bool get hasRecipe; Money? get grossAmount;
/// Create a copy of SalesLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesLineDtoCopyWith<SalesLineDto> get copyWith => _$SalesLineDtoCopyWithImpl<SalesLineDto>(this as SalesLineDto, _$identity);

  /// Serializes this SalesLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SalesLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesLineDto&&(identical(other.qtySold, _this.qtySold) || other.qtySold == _this.qtySold)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.menuItemName, _this.menuItemName) || other.menuItemName == _this.menuItemName)&&(identical(other.rawPosCode, _this.rawPosCode) || other.rawPosCode == _this.rawPosCode)&&(identical(other.isMapped, _this.isMapped) || other.isMapped == _this.isMapped)&&(identical(other.hasRecipe, _this.hasRecipe) || other.hasRecipe == _this.hasRecipe)&&(identical(other.grossAmount, _this.grossAmount) || other.grossAmount == _this.grossAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SalesLineDto;
  return Object.hash(runtimeType,_this.qtySold,_this.id,_this.menuItemId,_this.menuItemName,_this.rawPosCode,_this.isMapped,_this.hasRecipe,_this.grossAmount);
}

@override
String toString() {
  final _this = this as SalesLineDto;
  return 'SalesLineDto(qtySold: ${_this.qtySold}, id: ${_this.id}, menuItemId: ${_this.menuItemId}, menuItemName: ${_this.menuItemName}, rawPosCode: ${_this.rawPosCode}, isMapped: ${_this.isMapped}, hasRecipe: ${_this.hasRecipe}, grossAmount: ${_this.grossAmount})';
}


}

/// @nodoc
abstract mixin class $SalesLineDtoCopyWith<$Res>  {
  factory $SalesLineDtoCopyWith(SalesLineDto value, $Res Function(SalesLineDto) _then) = _$SalesLineDtoCopyWithImpl;
@useResult
$Res call({
 Quantity qtySold, int? id, int? menuItemId, String? menuItemName, String? rawPosCode, bool isMapped, bool hasRecipe, Money? grossAmount
});




}
/// @nodoc
class _$SalesLineDtoCopyWithImpl<$Res>
    implements $SalesLineDtoCopyWith<$Res> {
  _$SalesLineDtoCopyWithImpl(this._self, this._then);

  final SalesLineDto _self;
  final $Res Function(SalesLineDto) _then;

/// Create a copy of SalesLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? qtySold = null,Object? id = freezed,Object? menuItemId = freezed,Object? menuItemName = freezed,Object? rawPosCode = freezed,Object? isMapped = null,Object? hasRecipe = null,Object? grossAmount = freezed,}) {
  return _then(SalesLineDto(
qtySold: null == qtySold ? _self.qtySold : qtySold // ignore: cast_nullable_to_non_nullable
as Quantity,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as int?,menuItemName: freezed == menuItemName ? _self.menuItemName : menuItemName // ignore: cast_nullable_to_non_nullable
as String?,rawPosCode: freezed == rawPosCode ? _self.rawPosCode : rawPosCode // ignore: cast_nullable_to_non_nullable
as String?,isMapped: null == isMapped ? _self.isMapped : isMapped // ignore: cast_nullable_to_non_nullable
as bool,hasRecipe: null == hasRecipe ? _self.hasRecipe : hasRecipe // ignore: cast_nullable_to_non_nullable
as bool,grossAmount: freezed == grossAmount ? _self.grossAmount : grossAmount // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesLineDto].
extension SalesLineDtoPatterns on SalesLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesLineDto value)  $default,){
final _that = this;
switch (_that) {
case _SalesLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _SalesLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Quantity qtySold,  int? id,  int? menuItemId,  String? menuItemName,  String? rawPosCode,  bool isMapped,  bool hasRecipe,  Money? grossAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesLineDto() when $default != null:
return $default(_that.qtySold,_that.id,_that.menuItemId,_that.menuItemName,_that.rawPosCode,_that.isMapped,_that.hasRecipe,_that.grossAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Quantity qtySold,  int? id,  int? menuItemId,  String? menuItemName,  String? rawPosCode,  bool isMapped,  bool hasRecipe,  Money? grossAmount)  $default,) {final _that = this;
switch (_that) {
case _SalesLineDto():
return $default(_that.qtySold,_that.id,_that.menuItemId,_that.menuItemName,_that.rawPosCode,_that.isMapped,_that.hasRecipe,_that.grossAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Quantity qtySold,  int? id,  int? menuItemId,  String? menuItemName,  String? rawPosCode,  bool isMapped,  bool hasRecipe,  Money? grossAmount)?  $default,) {final _that = this;
switch (_that) {
case _SalesLineDto() when $default != null:
return $default(_that.qtySold,_that.id,_that.menuItemId,_that.menuItemName,_that.rawPosCode,_that.isMapped,_that.hasRecipe,_that.grossAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalesLineDto extends SalesLineDto {
  const _SalesLineDto({required this.qtySold, this.id, this.menuItemId, this.menuItemName, this.rawPosCode, this.isMapped = true, this.hasRecipe = true, this.grossAmount}): super._();
  factory _SalesLineDto.fromJson(Map<String, dynamic> json) => _$SalesLineDtoFromJson(json);

@override final  Quantity qtySold;
@override final  int? id;
@override final  int? menuItemId;
@override final  String? menuItemName;
/// POS code kept verbatim when nothing matched it.
@override final  String? rawPosCode;
@override@JsonKey() final  bool isMapped;
/// `false` — the item is known but has no recipe, so it depletes nothing.
@override@JsonKey() final  bool hasRecipe;
@override final  Money? grossAmount;

/// Create a copy of SalesLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesLineDtoCopyWith<_SalesLineDto> get copyWith => __$SalesLineDtoCopyWithImpl<_SalesLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalesLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesLineDto&&(identical(other.qtySold, qtySold) || other.qtySold == qtySold)&&(identical(other.id, id) || other.id == id)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.menuItemName, menuItemName) || other.menuItemName == menuItemName)&&(identical(other.rawPosCode, rawPosCode) || other.rawPosCode == rawPosCode)&&(identical(other.isMapped, isMapped) || other.isMapped == isMapped)&&(identical(other.hasRecipe, hasRecipe) || other.hasRecipe == hasRecipe)&&(identical(other.grossAmount, grossAmount) || other.grossAmount == grossAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,qtySold,id,menuItemId,menuItemName,rawPosCode,isMapped,hasRecipe,grossAmount);
}

@override
String toString() {
    return 'SalesLineDto(qtySold: $qtySold, id: $id, menuItemId: $menuItemId, menuItemName: $menuItemName, rawPosCode: $rawPosCode, isMapped: $isMapped, hasRecipe: $hasRecipe, grossAmount: $grossAmount)';
}


}

/// @nodoc
abstract mixin class _$SalesLineDtoCopyWith<$Res> implements $SalesLineDtoCopyWith<$Res> {
  factory _$SalesLineDtoCopyWith(_SalesLineDto value, $Res Function(_SalesLineDto) _then) = __$SalesLineDtoCopyWithImpl;
@override @useResult
$Res call({
 Quantity qtySold, int? id, int? menuItemId, String? menuItemName, String? rawPosCode, bool isMapped, bool hasRecipe, Money? grossAmount
});




}
/// @nodoc
class __$SalesLineDtoCopyWithImpl<$Res>
    implements _$SalesLineDtoCopyWith<$Res> {
  __$SalesLineDtoCopyWithImpl(this._self, this._then);

  final _SalesLineDto _self;
  final $Res Function(_SalesLineDto) _then;

/// Create a copy of SalesLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? qtySold = null,Object? id = freezed,Object? menuItemId = freezed,Object? menuItemName = freezed,Object? rawPosCode = freezed,Object? isMapped = null,Object? hasRecipe = null,Object? grossAmount = freezed,}) {
  return _then(_SalesLineDto(
qtySold: null == qtySold ? _self.qtySold : qtySold // ignore: cast_nullable_to_non_nullable
as Quantity,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as int?,menuItemName: freezed == menuItemName ? _self.menuItemName : menuItemName // ignore: cast_nullable_to_non_nullable
as String?,rawPosCode: freezed == rawPosCode ? _self.rawPosCode : rawPosCode // ignore: cast_nullable_to_non_nullable
as String?,isMapped: null == isMapped ? _self.isMapped : isMapped // ignore: cast_nullable_to_non_nullable
as bool,hasRecipe: null == hasRecipe ? _self.hasRecipe : hasRecipe // ignore: cast_nullable_to_non_nullable
as bool,grossAmount: freezed == grossAmount ? _self.grossAmount : grossAmount // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}


}


/// @nodoc
mixin _$SalesLineInput {

 Quantity get qtySold;/// Required unless [posCode] is given.
 int? get menuItemId;/// Stored as `rawPosCode` when unknown — never dropped silently.
 String? get posCode; Money? get grossAmount;
/// Create a copy of SalesLineInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesLineInputCopyWith<SalesLineInput> get copyWith => _$SalesLineInputCopyWithImpl<SalesLineInput>(this as SalesLineInput, _$identity);

  /// Serializes this SalesLineInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SalesLineInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesLineInput&&(identical(other.qtySold, _this.qtySold) || other.qtySold == _this.qtySold)&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.posCode, _this.posCode) || other.posCode == _this.posCode)&&(identical(other.grossAmount, _this.grossAmount) || other.grossAmount == _this.grossAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SalesLineInput;
  return Object.hash(runtimeType,_this.qtySold,_this.menuItemId,_this.posCode,_this.grossAmount);
}

@override
String toString() {
  final _this = this as SalesLineInput;
  return 'SalesLineInput(qtySold: ${_this.qtySold}, menuItemId: ${_this.menuItemId}, posCode: ${_this.posCode}, grossAmount: ${_this.grossAmount})';
}


}

/// @nodoc
abstract mixin class $SalesLineInputCopyWith<$Res>  {
  factory $SalesLineInputCopyWith(SalesLineInput value, $Res Function(SalesLineInput) _then) = _$SalesLineInputCopyWithImpl;
@useResult
$Res call({
 Quantity qtySold, int? menuItemId, String? posCode, Money? grossAmount
});




}
/// @nodoc
class _$SalesLineInputCopyWithImpl<$Res>
    implements $SalesLineInputCopyWith<$Res> {
  _$SalesLineInputCopyWithImpl(this._self, this._then);

  final SalesLineInput _self;
  final $Res Function(SalesLineInput) _then;

/// Create a copy of SalesLineInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? qtySold = null,Object? menuItemId = freezed,Object? posCode = freezed,Object? grossAmount = freezed,}) {
  return _then(SalesLineInput(
qtySold: null == qtySold ? _self.qtySold : qtySold // ignore: cast_nullable_to_non_nullable
as Quantity,menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as int?,posCode: freezed == posCode ? _self.posCode : posCode // ignore: cast_nullable_to_non_nullable
as String?,grossAmount: freezed == grossAmount ? _self.grossAmount : grossAmount // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesLineInput].
extension SalesLineInputPatterns on SalesLineInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesLineInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesLineInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesLineInput value)  $default,){
final _that = this;
switch (_that) {
case _SalesLineInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesLineInput value)?  $default,){
final _that = this;
switch (_that) {
case _SalesLineInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Quantity qtySold,  int? menuItemId,  String? posCode,  Money? grossAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesLineInput() when $default != null:
return $default(_that.qtySold,_that.menuItemId,_that.posCode,_that.grossAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Quantity qtySold,  int? menuItemId,  String? posCode,  Money? grossAmount)  $default,) {final _that = this;
switch (_that) {
case _SalesLineInput():
return $default(_that.qtySold,_that.menuItemId,_that.posCode,_that.grossAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Quantity qtySold,  int? menuItemId,  String? posCode,  Money? grossAmount)?  $default,) {final _that = this;
switch (_that) {
case _SalesLineInput() when $default != null:
return $default(_that.qtySold,_that.menuItemId,_that.posCode,_that.grossAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalesLineInput implements SalesLineInput {
  const _SalesLineInput({required this.qtySold, this.menuItemId, this.posCode, this.grossAmount});
  factory _SalesLineInput.fromJson(Map<String, dynamic> json) => _$SalesLineInputFromJson(json);

@override final  Quantity qtySold;
/// Required unless [posCode] is given.
@override final  int? menuItemId;
/// Stored as `rawPosCode` when unknown — never dropped silently.
@override final  String? posCode;
@override final  Money? grossAmount;

/// Create a copy of SalesLineInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesLineInputCopyWith<_SalesLineInput> get copyWith => __$SalesLineInputCopyWithImpl<_SalesLineInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalesLineInputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesLineInput&&(identical(other.qtySold, qtySold) || other.qtySold == qtySold)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.posCode, posCode) || other.posCode == posCode)&&(identical(other.grossAmount, grossAmount) || other.grossAmount == grossAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,qtySold,menuItemId,posCode,grossAmount);
}

@override
String toString() {
    return 'SalesLineInput(qtySold: $qtySold, menuItemId: $menuItemId, posCode: $posCode, grossAmount: $grossAmount)';
}


}

/// @nodoc
abstract mixin class _$SalesLineInputCopyWith<$Res> implements $SalesLineInputCopyWith<$Res> {
  factory _$SalesLineInputCopyWith(_SalesLineInput value, $Res Function(_SalesLineInput) _then) = __$SalesLineInputCopyWithImpl;
@override @useResult
$Res call({
 Quantity qtySold, int? menuItemId, String? posCode, Money? grossAmount
});




}
/// @nodoc
class __$SalesLineInputCopyWithImpl<$Res>
    implements _$SalesLineInputCopyWith<$Res> {
  __$SalesLineInputCopyWithImpl(this._self, this._then);

  final _SalesLineInput _self;
  final $Res Function(_SalesLineInput) _then;

/// Create a copy of SalesLineInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? qtySold = null,Object? menuItemId = freezed,Object? posCode = freezed,Object? grossAmount = freezed,}) {
  return _then(_SalesLineInput(
qtySold: null == qtySold ? _self.qtySold : qtySold // ignore: cast_nullable_to_non_nullable
as Quantity,menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as int?,posCode: freezed == posCode ? _self.posCode : posCode // ignore: cast_nullable_to_non_nullable
as String?,grossAmount: freezed == grossAmount ? _self.grossAmount : grossAmount // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}


}


/// @nodoc
mixin _$SalesImportDto {

 int get id; int get locationId;@DateOnlyConverter() DateTime get businessDate; SalesSource get source; SalesImportStatus get status; int get rowVersion; String? get locationName; String? get externalRef; int get lineCount;/// Unknown POS codes plus known items without a recipe.
 int get unmappedCount; Money? get grossAmount; DateTime? get importedAt; int? get consumptionRunId;
/// Create a copy of SalesImportDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesImportDtoCopyWith<SalesImportDto> get copyWith => _$SalesImportDtoCopyWithImpl<SalesImportDto>(this as SalesImportDto, _$identity);

  /// Serializes this SalesImportDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SalesImportDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesImportDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.businessDate, _this.businessDate) || other.businessDate == _this.businessDate)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&(identical(other.locationName, _this.locationName) || other.locationName == _this.locationName)&&(identical(other.externalRef, _this.externalRef) || other.externalRef == _this.externalRef)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&(identical(other.unmappedCount, _this.unmappedCount) || other.unmappedCount == _this.unmappedCount)&&(identical(other.grossAmount, _this.grossAmount) || other.grossAmount == _this.grossAmount)&&(identical(other.importedAt, _this.importedAt) || other.importedAt == _this.importedAt)&&(identical(other.consumptionRunId, _this.consumptionRunId) || other.consumptionRunId == _this.consumptionRunId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SalesImportDto;
  return Object.hash(runtimeType,_this.id,_this.locationId,_this.businessDate,_this.source,_this.status,_this.rowVersion,_this.locationName,_this.externalRef,_this.lineCount,_this.unmappedCount,_this.grossAmount,_this.importedAt,_this.consumptionRunId);
}

@override
String toString() {
  final _this = this as SalesImportDto;
  return 'SalesImportDto(id: ${_this.id}, locationId: ${_this.locationId}, businessDate: ${_this.businessDate}, source: ${_this.source}, status: ${_this.status}, rowVersion: ${_this.rowVersion}, locationName: ${_this.locationName}, externalRef: ${_this.externalRef}, lineCount: ${_this.lineCount}, unmappedCount: ${_this.unmappedCount}, grossAmount: ${_this.grossAmount}, importedAt: ${_this.importedAt}, consumptionRunId: ${_this.consumptionRunId})';
}


}

/// @nodoc
abstract mixin class $SalesImportDtoCopyWith<$Res>  {
  factory $SalesImportDtoCopyWith(SalesImportDto value, $Res Function(SalesImportDto) _then) = _$SalesImportDtoCopyWithImpl;
@useResult
$Res call({
 int id, int locationId,@DateOnlyConverter() DateTime businessDate, SalesSource source, SalesImportStatus status, int rowVersion, String? locationName, String? externalRef, int lineCount, int unmappedCount, Money? grossAmount, DateTime? importedAt, int? consumptionRunId
});




}
/// @nodoc
class _$SalesImportDtoCopyWithImpl<$Res>
    implements $SalesImportDtoCopyWith<$Res> {
  _$SalesImportDtoCopyWithImpl(this._self, this._then);

  final SalesImportDto _self;
  final $Res Function(SalesImportDto) _then;

/// Create a copy of SalesImportDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? locationId = null,Object? businessDate = null,Object? source = null,Object? status = null,Object? rowVersion = null,Object? locationName = freezed,Object? externalRef = freezed,Object? lineCount = null,Object? unmappedCount = null,Object? grossAmount = freezed,Object? importedAt = freezed,Object? consumptionRunId = freezed,}) {
  return _then(SalesImportDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,businessDate: null == businessDate ? _self.businessDate : businessDate // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SalesSource,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SalesImportStatus,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,externalRef: freezed == externalRef ? _self.externalRef : externalRef // ignore: cast_nullable_to_non_nullable
as String?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,unmappedCount: null == unmappedCount ? _self.unmappedCount : unmappedCount // ignore: cast_nullable_to_non_nullable
as int,grossAmount: freezed == grossAmount ? _self.grossAmount : grossAmount // ignore: cast_nullable_to_non_nullable
as Money?,importedAt: freezed == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,consumptionRunId: freezed == consumptionRunId ? _self.consumptionRunId : consumptionRunId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesImportDto].
extension SalesImportDtoPatterns on SalesImportDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesImportDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesImportDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesImportDto value)  $default,){
final _that = this;
switch (_that) {
case _SalesImportDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesImportDto value)?  $default,){
final _that = this;
switch (_that) {
case _SalesImportDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int locationId, @DateOnlyConverter()  DateTime businessDate,  SalesSource source,  SalesImportStatus status,  int rowVersion,  String? locationName,  String? externalRef,  int lineCount,  int unmappedCount,  Money? grossAmount,  DateTime? importedAt,  int? consumptionRunId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesImportDto() when $default != null:
return $default(_that.id,_that.locationId,_that.businessDate,_that.source,_that.status,_that.rowVersion,_that.locationName,_that.externalRef,_that.lineCount,_that.unmappedCount,_that.grossAmount,_that.importedAt,_that.consumptionRunId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int locationId, @DateOnlyConverter()  DateTime businessDate,  SalesSource source,  SalesImportStatus status,  int rowVersion,  String? locationName,  String? externalRef,  int lineCount,  int unmappedCount,  Money? grossAmount,  DateTime? importedAt,  int? consumptionRunId)  $default,) {final _that = this;
switch (_that) {
case _SalesImportDto():
return $default(_that.id,_that.locationId,_that.businessDate,_that.source,_that.status,_that.rowVersion,_that.locationName,_that.externalRef,_that.lineCount,_that.unmappedCount,_that.grossAmount,_that.importedAt,_that.consumptionRunId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int locationId, @DateOnlyConverter()  DateTime businessDate,  SalesSource source,  SalesImportStatus status,  int rowVersion,  String? locationName,  String? externalRef,  int lineCount,  int unmappedCount,  Money? grossAmount,  DateTime? importedAt,  int? consumptionRunId)?  $default,) {final _that = this;
switch (_that) {
case _SalesImportDto() when $default != null:
return $default(_that.id,_that.locationId,_that.businessDate,_that.source,_that.status,_that.rowVersion,_that.locationName,_that.externalRef,_that.lineCount,_that.unmappedCount,_that.grossAmount,_that.importedAt,_that.consumptionRunId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalesImportDto extends SalesImportDto {
  const _SalesImportDto({required this.id, required this.locationId, @DateOnlyConverter() required this.businessDate, required this.source, required this.status, required this.rowVersion, this.locationName, this.externalRef, this.lineCount = 0, this.unmappedCount = 0, this.grossAmount, this.importedAt, this.consumptionRunId}): super._();
  factory _SalesImportDto.fromJson(Map<String, dynamic> json) => _$SalesImportDtoFromJson(json);

@override final  int id;
@override final  int locationId;
@override@DateOnlyConverter() final  DateTime businessDate;
@override final  SalesSource source;
@override final  SalesImportStatus status;
@override final  int rowVersion;
@override final  String? locationName;
@override final  String? externalRef;
@override@JsonKey() final  int lineCount;
/// Unknown POS codes plus known items without a recipe.
@override@JsonKey() final  int unmappedCount;
@override final  Money? grossAmount;
@override final  DateTime? importedAt;
@override final  int? consumptionRunId;

/// Create a copy of SalesImportDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesImportDtoCopyWith<_SalesImportDto> get copyWith => __$SalesImportDtoCopyWithImpl<_SalesImportDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalesImportDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesImportDto&&(identical(other.id, id) || other.id == id)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.businessDate, businessDate) || other.businessDate == businessDate)&&(identical(other.source, source) || other.source == source)&&(identical(other.status, status) || other.status == status)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.externalRef, externalRef) || other.externalRef == externalRef)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&(identical(other.unmappedCount, unmappedCount) || other.unmappedCount == unmappedCount)&&(identical(other.grossAmount, grossAmount) || other.grossAmount == grossAmount)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.consumptionRunId, consumptionRunId) || other.consumptionRunId == consumptionRunId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,locationId,businessDate,source,status,rowVersion,locationName,externalRef,lineCount,unmappedCount,grossAmount,importedAt,consumptionRunId);
}

@override
String toString() {
    return 'SalesImportDto(id: $id, locationId: $locationId, businessDate: $businessDate, source: $source, status: $status, rowVersion: $rowVersion, locationName: $locationName, externalRef: $externalRef, lineCount: $lineCount, unmappedCount: $unmappedCount, grossAmount: $grossAmount, importedAt: $importedAt, consumptionRunId: $consumptionRunId)';
}


}

/// @nodoc
abstract mixin class _$SalesImportDtoCopyWith<$Res> implements $SalesImportDtoCopyWith<$Res> {
  factory _$SalesImportDtoCopyWith(_SalesImportDto value, $Res Function(_SalesImportDto) _then) = __$SalesImportDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int locationId,@DateOnlyConverter() DateTime businessDate, SalesSource source, SalesImportStatus status, int rowVersion, String? locationName, String? externalRef, int lineCount, int unmappedCount, Money? grossAmount, DateTime? importedAt, int? consumptionRunId
});




}
/// @nodoc
class __$SalesImportDtoCopyWithImpl<$Res>
    implements _$SalesImportDtoCopyWith<$Res> {
  __$SalesImportDtoCopyWithImpl(this._self, this._then);

  final _SalesImportDto _self;
  final $Res Function(_SalesImportDto) _then;

/// Create a copy of SalesImportDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? locationId = null,Object? businessDate = null,Object? source = null,Object? status = null,Object? rowVersion = null,Object? locationName = freezed,Object? externalRef = freezed,Object? lineCount = null,Object? unmappedCount = null,Object? grossAmount = freezed,Object? importedAt = freezed,Object? consumptionRunId = freezed,}) {
  return _then(_SalesImportDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,businessDate: null == businessDate ? _self.businessDate : businessDate // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SalesSource,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SalesImportStatus,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,externalRef: freezed == externalRef ? _self.externalRef : externalRef // ignore: cast_nullable_to_non_nullable
as String?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,unmappedCount: null == unmappedCount ? _self.unmappedCount : unmappedCount // ignore: cast_nullable_to_non_nullable
as int,grossAmount: freezed == grossAmount ? _self.grossAmount : grossAmount // ignore: cast_nullable_to_non_nullable
as Money?,importedAt: freezed == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,consumptionRunId: freezed == consumptionRunId ? _self.consumptionRunId : consumptionRunId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$SalesImportDetailDto {

 int get id; int get locationId;@DateOnlyConverter() DateTime get businessDate; SalesSource get source; SalesImportStatus get status; int get rowVersion; String? get locationName; String? get externalRef; int get lineCount; int get unmappedCount; Money? get grossAmount; DateTime? get importedAt; int? get consumptionRunId; List<SalesLineDto> get lines;
/// Create a copy of SalesImportDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesImportDetailDtoCopyWith<SalesImportDetailDto> get copyWith => _$SalesImportDetailDtoCopyWithImpl<SalesImportDetailDto>(this as SalesImportDetailDto, _$identity);

  /// Serializes this SalesImportDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SalesImportDetailDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesImportDetailDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.businessDate, _this.businessDate) || other.businessDate == _this.businessDate)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&(identical(other.locationName, _this.locationName) || other.locationName == _this.locationName)&&(identical(other.externalRef, _this.externalRef) || other.externalRef == _this.externalRef)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&(identical(other.unmappedCount, _this.unmappedCount) || other.unmappedCount == _this.unmappedCount)&&(identical(other.grossAmount, _this.grossAmount) || other.grossAmount == _this.grossAmount)&&(identical(other.importedAt, _this.importedAt) || other.importedAt == _this.importedAt)&&(identical(other.consumptionRunId, _this.consumptionRunId) || other.consumptionRunId == _this.consumptionRunId)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SalesImportDetailDto;
  return Object.hash(runtimeType,_this.id,_this.locationId,_this.businessDate,_this.source,_this.status,_this.rowVersion,_this.locationName,_this.externalRef,_this.lineCount,_this.unmappedCount,_this.grossAmount,_this.importedAt,_this.consumptionRunId,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as SalesImportDetailDto;
  return 'SalesImportDetailDto(id: ${_this.id}, locationId: ${_this.locationId}, businessDate: ${_this.businessDate}, source: ${_this.source}, status: ${_this.status}, rowVersion: ${_this.rowVersion}, locationName: ${_this.locationName}, externalRef: ${_this.externalRef}, lineCount: ${_this.lineCount}, unmappedCount: ${_this.unmappedCount}, grossAmount: ${_this.grossAmount}, importedAt: ${_this.importedAt}, consumptionRunId: ${_this.consumptionRunId}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $SalesImportDetailDtoCopyWith<$Res>  {
  factory $SalesImportDetailDtoCopyWith(SalesImportDetailDto value, $Res Function(SalesImportDetailDto) _then) = _$SalesImportDetailDtoCopyWithImpl;
@useResult
$Res call({
 int id, int locationId,@DateOnlyConverter() DateTime businessDate, SalesSource source, SalesImportStatus status, int rowVersion, String? locationName, String? externalRef, int lineCount, int unmappedCount, Money? grossAmount, DateTime? importedAt, int? consumptionRunId, List<SalesLineDto> lines
});




}
/// @nodoc
class _$SalesImportDetailDtoCopyWithImpl<$Res>
    implements $SalesImportDetailDtoCopyWith<$Res> {
  _$SalesImportDetailDtoCopyWithImpl(this._self, this._then);

  final SalesImportDetailDto _self;
  final $Res Function(SalesImportDetailDto) _then;

/// Create a copy of SalesImportDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? locationId = null,Object? businessDate = null,Object? source = null,Object? status = null,Object? rowVersion = null,Object? locationName = freezed,Object? externalRef = freezed,Object? lineCount = null,Object? unmappedCount = null,Object? grossAmount = freezed,Object? importedAt = freezed,Object? consumptionRunId = freezed,Object? lines = null,}) {
  return _then(SalesImportDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,businessDate: null == businessDate ? _self.businessDate : businessDate // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SalesSource,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SalesImportStatus,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,externalRef: freezed == externalRef ? _self.externalRef : externalRef // ignore: cast_nullable_to_non_nullable
as String?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,unmappedCount: null == unmappedCount ? _self.unmappedCount : unmappedCount // ignore: cast_nullable_to_non_nullable
as int,grossAmount: freezed == grossAmount ? _self.grossAmount : grossAmount // ignore: cast_nullable_to_non_nullable
as Money?,importedAt: freezed == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,consumptionRunId: freezed == consumptionRunId ? _self.consumptionRunId : consumptionRunId // ignore: cast_nullable_to_non_nullable
as int?,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<SalesLineDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesImportDetailDto].
extension SalesImportDetailDtoPatterns on SalesImportDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesImportDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesImportDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesImportDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _SalesImportDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesImportDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _SalesImportDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int locationId, @DateOnlyConverter()  DateTime businessDate,  SalesSource source,  SalesImportStatus status,  int rowVersion,  String? locationName,  String? externalRef,  int lineCount,  int unmappedCount,  Money? grossAmount,  DateTime? importedAt,  int? consumptionRunId,  List<SalesLineDto> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesImportDetailDto() when $default != null:
return $default(_that.id,_that.locationId,_that.businessDate,_that.source,_that.status,_that.rowVersion,_that.locationName,_that.externalRef,_that.lineCount,_that.unmappedCount,_that.grossAmount,_that.importedAt,_that.consumptionRunId,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int locationId, @DateOnlyConverter()  DateTime businessDate,  SalesSource source,  SalesImportStatus status,  int rowVersion,  String? locationName,  String? externalRef,  int lineCount,  int unmappedCount,  Money? grossAmount,  DateTime? importedAt,  int? consumptionRunId,  List<SalesLineDto> lines)  $default,) {final _that = this;
switch (_that) {
case _SalesImportDetailDto():
return $default(_that.id,_that.locationId,_that.businessDate,_that.source,_that.status,_that.rowVersion,_that.locationName,_that.externalRef,_that.lineCount,_that.unmappedCount,_that.grossAmount,_that.importedAt,_that.consumptionRunId,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int locationId, @DateOnlyConverter()  DateTime businessDate,  SalesSource source,  SalesImportStatus status,  int rowVersion,  String? locationName,  String? externalRef,  int lineCount,  int unmappedCount,  Money? grossAmount,  DateTime? importedAt,  int? consumptionRunId,  List<SalesLineDto> lines)?  $default,) {final _that = this;
switch (_that) {
case _SalesImportDetailDto() when $default != null:
return $default(_that.id,_that.locationId,_that.businessDate,_that.source,_that.status,_that.rowVersion,_that.locationName,_that.externalRef,_that.lineCount,_that.unmappedCount,_that.grossAmount,_that.importedAt,_that.consumptionRunId,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalesImportDetailDto extends SalesImportDetailDto {
  const _SalesImportDetailDto({required this.id, required this.locationId, @DateOnlyConverter() required this.businessDate, required this.source, required this.status, required this.rowVersion, this.locationName, this.externalRef, this.lineCount = 0, this.unmappedCount = 0, this.grossAmount, this.importedAt, this.consumptionRunId,  List<SalesLineDto> lines = const <SalesLineDto>[]}): _lines = lines,super._();
  factory _SalesImportDetailDto.fromJson(Map<String, dynamic> json) => _$SalesImportDetailDtoFromJson(json);

@override final  int id;
@override final  int locationId;
@override@DateOnlyConverter() final  DateTime businessDate;
@override final  SalesSource source;
@override final  SalesImportStatus status;
@override final  int rowVersion;
@override final  String? locationName;
@override final  String? externalRef;
@override@JsonKey() final  int lineCount;
@override@JsonKey() final  int unmappedCount;
@override final  Money? grossAmount;
@override final  DateTime? importedAt;
@override final  int? consumptionRunId;
 final  List<SalesLineDto> _lines;
@override@JsonKey() List<SalesLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of SalesImportDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesImportDetailDtoCopyWith<_SalesImportDetailDto> get copyWith => __$SalesImportDetailDtoCopyWithImpl<_SalesImportDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalesImportDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesImportDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.businessDate, businessDate) || other.businessDate == businessDate)&&(identical(other.source, source) || other.source == source)&&(identical(other.status, status) || other.status == status)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.externalRef, externalRef) || other.externalRef == externalRef)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&(identical(other.unmappedCount, unmappedCount) || other.unmappedCount == unmappedCount)&&(identical(other.grossAmount, grossAmount) || other.grossAmount == grossAmount)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.consumptionRunId, consumptionRunId) || other.consumptionRunId == consumptionRunId)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,locationId,businessDate,source,status,rowVersion,locationName,externalRef,lineCount,unmappedCount,grossAmount,importedAt,consumptionRunId,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'SalesImportDetailDto(id: $id, locationId: $locationId, businessDate: $businessDate, source: $source, status: $status, rowVersion: $rowVersion, locationName: $locationName, externalRef: $externalRef, lineCount: $lineCount, unmappedCount: $unmappedCount, grossAmount: $grossAmount, importedAt: $importedAt, consumptionRunId: $consumptionRunId, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$SalesImportDetailDtoCopyWith<$Res> implements $SalesImportDetailDtoCopyWith<$Res> {
  factory _$SalesImportDetailDtoCopyWith(_SalesImportDetailDto value, $Res Function(_SalesImportDetailDto) _then) = __$SalesImportDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int locationId,@DateOnlyConverter() DateTime businessDate, SalesSource source, SalesImportStatus status, int rowVersion, String? locationName, String? externalRef, int lineCount, int unmappedCount, Money? grossAmount, DateTime? importedAt, int? consumptionRunId, List<SalesLineDto> lines
});




}
/// @nodoc
class __$SalesImportDetailDtoCopyWithImpl<$Res>
    implements _$SalesImportDetailDtoCopyWith<$Res> {
  __$SalesImportDetailDtoCopyWithImpl(this._self, this._then);

  final _SalesImportDetailDto _self;
  final $Res Function(_SalesImportDetailDto) _then;

/// Create a copy of SalesImportDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? locationId = null,Object? businessDate = null,Object? source = null,Object? status = null,Object? rowVersion = null,Object? locationName = freezed,Object? externalRef = freezed,Object? lineCount = null,Object? unmappedCount = null,Object? grossAmount = freezed,Object? importedAt = freezed,Object? consumptionRunId = freezed,Object? lines = null,}) {
  return _then(_SalesImportDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,businessDate: null == businessDate ? _self.businessDate : businessDate // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SalesSource,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SalesImportStatus,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,externalRef: freezed == externalRef ? _self.externalRef : externalRef // ignore: cast_nullable_to_non_nullable
as String?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,unmappedCount: null == unmappedCount ? _self.unmappedCount : unmappedCount // ignore: cast_nullable_to_non_nullable
as int,grossAmount: freezed == grossAmount ? _self.grossAmount : grossAmount // ignore: cast_nullable_to_non_nullable
as Money?,importedAt: freezed == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,consumptionRunId: freezed == consumptionRunId ? _self.consumptionRunId : consumptionRunId // ignore: cast_nullable_to_non_nullable
as int?,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<SalesLineDto>,
  ));
}


}


/// @nodoc
mixin _$CreateSalesImportRequest {

 int get locationId;@DateOnlyConverter() DateTime get businessDate; SalesSource get source; List<SalesLineInput> get lines;/// POS batch or shift number.
 String? get externalRef;
/// Create a copy of CreateSalesImportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateSalesImportRequestCopyWith<CreateSalesImportRequest> get copyWith => _$CreateSalesImportRequestCopyWithImpl<CreateSalesImportRequest>(this as CreateSalesImportRequest, _$identity);

  /// Serializes this CreateSalesImportRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateSalesImportRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateSalesImportRequest&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.businessDate, _this.businessDate) || other.businessDate == _this.businessDate)&&(identical(other.source, _this.source) || other.source == _this.source)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.externalRef, _this.externalRef) || other.externalRef == _this.externalRef));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateSalesImportRequest;
  return Object.hash(runtimeType,_this.locationId,_this.businessDate,_this.source,const DeepCollectionEquality().hash(_this.lines),_this.externalRef);
}

@override
String toString() {
  final _this = this as CreateSalesImportRequest;
  return 'CreateSalesImportRequest(locationId: ${_this.locationId}, businessDate: ${_this.businessDate}, source: ${_this.source}, lines: ${_this.lines}, externalRef: ${_this.externalRef})';
}


}

/// @nodoc
abstract mixin class $CreateSalesImportRequestCopyWith<$Res>  {
  factory $CreateSalesImportRequestCopyWith(CreateSalesImportRequest value, $Res Function(CreateSalesImportRequest) _then) = _$CreateSalesImportRequestCopyWithImpl;
@useResult
$Res call({
 int locationId,@DateOnlyConverter() DateTime businessDate, SalesSource source, List<SalesLineInput> lines, String? externalRef
});




}
/// @nodoc
class _$CreateSalesImportRequestCopyWithImpl<$Res>
    implements $CreateSalesImportRequestCopyWith<$Res> {
  _$CreateSalesImportRequestCopyWithImpl(this._self, this._then);

  final CreateSalesImportRequest _self;
  final $Res Function(CreateSalesImportRequest) _then;

/// Create a copy of CreateSalesImportRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locationId = null,Object? businessDate = null,Object? source = null,Object? lines = null,Object? externalRef = freezed,}) {
  return _then(CreateSalesImportRequest(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,businessDate: null == businessDate ? _self.businessDate : businessDate // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SalesSource,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<SalesLineInput>,externalRef: freezed == externalRef ? _self.externalRef : externalRef // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateSalesImportRequest].
extension CreateSalesImportRequestPatterns on CreateSalesImportRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateSalesImportRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateSalesImportRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateSalesImportRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateSalesImportRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateSalesImportRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateSalesImportRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int locationId, @DateOnlyConverter()  DateTime businessDate,  SalesSource source,  List<SalesLineInput> lines,  String? externalRef)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateSalesImportRequest() when $default != null:
return $default(_that.locationId,_that.businessDate,_that.source,_that.lines,_that.externalRef);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int locationId, @DateOnlyConverter()  DateTime businessDate,  SalesSource source,  List<SalesLineInput> lines,  String? externalRef)  $default,) {final _that = this;
switch (_that) {
case _CreateSalesImportRequest():
return $default(_that.locationId,_that.businessDate,_that.source,_that.lines,_that.externalRef);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int locationId, @DateOnlyConverter()  DateTime businessDate,  SalesSource source,  List<SalesLineInput> lines,  String? externalRef)?  $default,) {final _that = this;
switch (_that) {
case _CreateSalesImportRequest() when $default != null:
return $default(_that.locationId,_that.businessDate,_that.source,_that.lines,_that.externalRef);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateSalesImportRequest implements CreateSalesImportRequest {
  const _CreateSalesImportRequest({required this.locationId, @DateOnlyConverter() required this.businessDate, required this.source, required  List<SalesLineInput> lines, this.externalRef}): _lines = lines;
  factory _CreateSalesImportRequest.fromJson(Map<String, dynamic> json) => _$CreateSalesImportRequestFromJson(json);

@override final  int locationId;
@override@DateOnlyConverter() final  DateTime businessDate;
@override final  SalesSource source;
 final  List<SalesLineInput> _lines;
@override List<SalesLineInput> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

/// POS batch or shift number.
@override final  String? externalRef;

/// Create a copy of CreateSalesImportRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateSalesImportRequestCopyWith<_CreateSalesImportRequest> get copyWith => __$CreateSalesImportRequestCopyWithImpl<_CreateSalesImportRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateSalesImportRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateSalesImportRequest&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.businessDate, businessDate) || other.businessDate == businessDate)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.externalRef, externalRef) || other.externalRef == externalRef));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,locationId,businessDate,source,const DeepCollectionEquality().hash(_lines),externalRef);
}

@override
String toString() {
    return 'CreateSalesImportRequest(locationId: $locationId, businessDate: $businessDate, source: $source, lines: $lines, externalRef: $externalRef)';
}


}

/// @nodoc
abstract mixin class _$CreateSalesImportRequestCopyWith<$Res> implements $CreateSalesImportRequestCopyWith<$Res> {
  factory _$CreateSalesImportRequestCopyWith(_CreateSalesImportRequest value, $Res Function(_CreateSalesImportRequest) _then) = __$CreateSalesImportRequestCopyWithImpl;
@override @useResult
$Res call({
 int locationId,@DateOnlyConverter() DateTime businessDate, SalesSource source, List<SalesLineInput> lines, String? externalRef
});




}
/// @nodoc
class __$CreateSalesImportRequestCopyWithImpl<$Res>
    implements _$CreateSalesImportRequestCopyWith<$Res> {
  __$CreateSalesImportRequestCopyWithImpl(this._self, this._then);

  final _CreateSalesImportRequest _self;
  final $Res Function(_CreateSalesImportRequest) _then;

/// Create a copy of CreateSalesImportRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locationId = null,Object? businessDate = null,Object? source = null,Object? lines = null,Object? externalRef = freezed,}) {
  return _then(_CreateSalesImportRequest(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,businessDate: null == businessDate ? _self.businessDate : businessDate // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SalesSource,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<SalesLineInput>,externalRef: freezed == externalRef ? _self.externalRef : externalRef // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateSalesImportRequest {

 int get rowVersion; List<SalesLineInput> get lines;
/// Create a copy of UpdateSalesImportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateSalesImportRequestCopyWith<UpdateSalesImportRequest> get copyWith => _$UpdateSalesImportRequestCopyWithImpl<UpdateSalesImportRequest>(this as UpdateSalesImportRequest, _$identity);

  /// Serializes this UpdateSalesImportRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateSalesImportRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateSalesImportRequest&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateSalesImportRequest;
  return Object.hash(runtimeType,_this.rowVersion,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as UpdateSalesImportRequest;
  return 'UpdateSalesImportRequest(rowVersion: ${_this.rowVersion}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $UpdateSalesImportRequestCopyWith<$Res>  {
  factory $UpdateSalesImportRequestCopyWith(UpdateSalesImportRequest value, $Res Function(UpdateSalesImportRequest) _then) = _$UpdateSalesImportRequestCopyWithImpl;
@useResult
$Res call({
 int rowVersion, List<SalesLineInput> lines
});




}
/// @nodoc
class _$UpdateSalesImportRequestCopyWithImpl<$Res>
    implements $UpdateSalesImportRequestCopyWith<$Res> {
  _$UpdateSalesImportRequestCopyWithImpl(this._self, this._then);

  final UpdateSalesImportRequest _self;
  final $Res Function(UpdateSalesImportRequest) _then;

/// Create a copy of UpdateSalesImportRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowVersion = null,Object? lines = null,}) {
  return _then(UpdateSalesImportRequest(
rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<SalesLineInput>,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateSalesImportRequest].
extension UpdateSalesImportRequestPatterns on UpdateSalesImportRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateSalesImportRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateSalesImportRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateSalesImportRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateSalesImportRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateSalesImportRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateSalesImportRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rowVersion,  List<SalesLineInput> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateSalesImportRequest() when $default != null:
return $default(_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rowVersion,  List<SalesLineInput> lines)  $default,) {final _that = this;
switch (_that) {
case _UpdateSalesImportRequest():
return $default(_that.rowVersion,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rowVersion,  List<SalesLineInput> lines)?  $default,) {final _that = this;
switch (_that) {
case _UpdateSalesImportRequest() when $default != null:
return $default(_that.rowVersion,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateSalesImportRequest implements UpdateSalesImportRequest {
  const _UpdateSalesImportRequest({required this.rowVersion, required  List<SalesLineInput> lines}): _lines = lines;
  factory _UpdateSalesImportRequest.fromJson(Map<String, dynamic> json) => _$UpdateSalesImportRequestFromJson(json);

@override final  int rowVersion;
 final  List<SalesLineInput> _lines;
@override List<SalesLineInput> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of UpdateSalesImportRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateSalesImportRequestCopyWith<_UpdateSalesImportRequest> get copyWith => __$UpdateSalesImportRequestCopyWithImpl<_UpdateSalesImportRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateSalesImportRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateSalesImportRequest&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rowVersion,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'UpdateSalesImportRequest(rowVersion: $rowVersion, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$UpdateSalesImportRequestCopyWith<$Res> implements $UpdateSalesImportRequestCopyWith<$Res> {
  factory _$UpdateSalesImportRequestCopyWith(_UpdateSalesImportRequest value, $Res Function(_UpdateSalesImportRequest) _then) = __$UpdateSalesImportRequestCopyWithImpl;
@override @useResult
$Res call({
 int rowVersion, List<SalesLineInput> lines
});




}
/// @nodoc
class __$UpdateSalesImportRequestCopyWithImpl<$Res>
    implements _$UpdateSalesImportRequestCopyWith<$Res> {
  __$UpdateSalesImportRequestCopyWithImpl(this._self, this._then);

  final _UpdateSalesImportRequest _self;
  final $Res Function(_UpdateSalesImportRequest) _then;

/// Create a copy of UpdateSalesImportRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowVersion = null,Object? lines = null,}) {
  return _then(_UpdateSalesImportRequest(
rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<SalesLineInput>,
  ));
}


}


/// @nodoc
mixin _$SalesParseErrorDto {

 int get rowNumber; String get message; String? get rawLine;
/// Create a copy of SalesParseErrorDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesParseErrorDtoCopyWith<SalesParseErrorDto> get copyWith => _$SalesParseErrorDtoCopyWithImpl<SalesParseErrorDto>(this as SalesParseErrorDto, _$identity);

  /// Serializes this SalesParseErrorDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SalesParseErrorDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesParseErrorDto&&(identical(other.rowNumber, _this.rowNumber) || other.rowNumber == _this.rowNumber)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.rawLine, _this.rawLine) || other.rawLine == _this.rawLine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SalesParseErrorDto;
  return Object.hash(runtimeType,_this.rowNumber,_this.message,_this.rawLine);
}

@override
String toString() {
  final _this = this as SalesParseErrorDto;
  return 'SalesParseErrorDto(rowNumber: ${_this.rowNumber}, message: ${_this.message}, rawLine: ${_this.rawLine})';
}


}

/// @nodoc
abstract mixin class $SalesParseErrorDtoCopyWith<$Res>  {
  factory $SalesParseErrorDtoCopyWith(SalesParseErrorDto value, $Res Function(SalesParseErrorDto) _then) = _$SalesParseErrorDtoCopyWithImpl;
@useResult
$Res call({
 int rowNumber, String message, String? rawLine
});




}
/// @nodoc
class _$SalesParseErrorDtoCopyWithImpl<$Res>
    implements $SalesParseErrorDtoCopyWith<$Res> {
  _$SalesParseErrorDtoCopyWithImpl(this._self, this._then);

  final SalesParseErrorDto _self;
  final $Res Function(SalesParseErrorDto) _then;

/// Create a copy of SalesParseErrorDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowNumber = null,Object? message = null,Object? rawLine = freezed,}) {
  return _then(SalesParseErrorDto(
rowNumber: null == rowNumber ? _self.rowNumber : rowNumber // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,rawLine: freezed == rawLine ? _self.rawLine : rawLine // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesParseErrorDto].
extension SalesParseErrorDtoPatterns on SalesParseErrorDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesParseErrorDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesParseErrorDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesParseErrorDto value)  $default,){
final _that = this;
switch (_that) {
case _SalesParseErrorDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesParseErrorDto value)?  $default,){
final _that = this;
switch (_that) {
case _SalesParseErrorDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rowNumber,  String message,  String? rawLine)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesParseErrorDto() when $default != null:
return $default(_that.rowNumber,_that.message,_that.rawLine);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rowNumber,  String message,  String? rawLine)  $default,) {final _that = this;
switch (_that) {
case _SalesParseErrorDto():
return $default(_that.rowNumber,_that.message,_that.rawLine);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rowNumber,  String message,  String? rawLine)?  $default,) {final _that = this;
switch (_that) {
case _SalesParseErrorDto() when $default != null:
return $default(_that.rowNumber,_that.message,_that.rawLine);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalesParseErrorDto implements SalesParseErrorDto {
  const _SalesParseErrorDto({required this.rowNumber, required this.message, this.rawLine});
  factory _SalesParseErrorDto.fromJson(Map<String, dynamic> json) => _$SalesParseErrorDtoFromJson(json);

@override final  int rowNumber;
@override final  String message;
@override final  String? rawLine;

/// Create a copy of SalesParseErrorDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesParseErrorDtoCopyWith<_SalesParseErrorDto> get copyWith => __$SalesParseErrorDtoCopyWithImpl<_SalesParseErrorDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalesParseErrorDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesParseErrorDto&&(identical(other.rowNumber, rowNumber) || other.rowNumber == rowNumber)&&(identical(other.message, message) || other.message == message)&&(identical(other.rawLine, rawLine) || other.rawLine == rawLine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rowNumber,message,rawLine);
}

@override
String toString() {
    return 'SalesParseErrorDto(rowNumber: $rowNumber, message: $message, rawLine: $rawLine)';
}


}

/// @nodoc
abstract mixin class _$SalesParseErrorDtoCopyWith<$Res> implements $SalesParseErrorDtoCopyWith<$Res> {
  factory _$SalesParseErrorDtoCopyWith(_SalesParseErrorDto value, $Res Function(_SalesParseErrorDto) _then) = __$SalesParseErrorDtoCopyWithImpl;
@override @useResult
$Res call({
 int rowNumber, String message, String? rawLine
});




}
/// @nodoc
class __$SalesParseErrorDtoCopyWithImpl<$Res>
    implements _$SalesParseErrorDtoCopyWith<$Res> {
  __$SalesParseErrorDtoCopyWithImpl(this._self, this._then);

  final _SalesParseErrorDto _self;
  final $Res Function(_SalesParseErrorDto) _then;

/// Create a copy of SalesParseErrorDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowNumber = null,Object? message = null,Object? rawLine = freezed,}) {
  return _then(_SalesParseErrorDto(
rowNumber: null == rowNumber ? _self.rowNumber : rowNumber // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,rawLine: freezed == rawLine ? _self.rawLine : rawLine // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SalesImportParseResultDto {

 SalesImportDetailDto get salesImport; int get parsedRows; List<SalesParseErrorDto> get parseErrors;
/// Create a copy of SalesImportParseResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesImportParseResultDtoCopyWith<SalesImportParseResultDto> get copyWith => _$SalesImportParseResultDtoCopyWithImpl<SalesImportParseResultDto>(this as SalesImportParseResultDto, _$identity);

  /// Serializes this SalesImportParseResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SalesImportParseResultDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesImportParseResultDto&&(identical(other.salesImport, _this.salesImport) || other.salesImport == _this.salesImport)&&(identical(other.parsedRows, _this.parsedRows) || other.parsedRows == _this.parsedRows)&&const DeepCollectionEquality().equals(other.parseErrors, _this.parseErrors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SalesImportParseResultDto;
  return Object.hash(runtimeType,_this.salesImport,_this.parsedRows,const DeepCollectionEquality().hash(_this.parseErrors));
}

@override
String toString() {
  final _this = this as SalesImportParseResultDto;
  return 'SalesImportParseResultDto(salesImport: ${_this.salesImport}, parsedRows: ${_this.parsedRows}, parseErrors: ${_this.parseErrors})';
}


}

/// @nodoc
abstract mixin class $SalesImportParseResultDtoCopyWith<$Res>  {
  factory $SalesImportParseResultDtoCopyWith(SalesImportParseResultDto value, $Res Function(SalesImportParseResultDto) _then) = _$SalesImportParseResultDtoCopyWithImpl;
@useResult
$Res call({
 SalesImportDetailDto salesImport, int parsedRows, List<SalesParseErrorDto> parseErrors
});


$SalesImportDetailDtoCopyWith<$Res> get salesImport;

}
/// @nodoc
class _$SalesImportParseResultDtoCopyWithImpl<$Res>
    implements $SalesImportParseResultDtoCopyWith<$Res> {
  _$SalesImportParseResultDtoCopyWithImpl(this._self, this._then);

  final SalesImportParseResultDto _self;
  final $Res Function(SalesImportParseResultDto) _then;

/// Create a copy of SalesImportParseResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? salesImport = null,Object? parsedRows = null,Object? parseErrors = null,}) {
  return _then(SalesImportParseResultDto(
salesImport: null == salesImport ? _self.salesImport : salesImport // ignore: cast_nullable_to_non_nullable
as SalesImportDetailDto,parsedRows: null == parsedRows ? _self.parsedRows : parsedRows // ignore: cast_nullable_to_non_nullable
as int,parseErrors: null == parseErrors ? _self.parseErrors : parseErrors // ignore: cast_nullable_to_non_nullable
as List<SalesParseErrorDto>,
  ));
}
/// Create a copy of SalesImportParseResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesImportDetailDtoCopyWith<$Res> get salesImport {
  
  return $SalesImportDetailDtoCopyWith<$Res>(_self.salesImport, (value) {
    return _then(_self.copyWith(salesImport: value));
  });
}
}


/// Adds pattern-matching-related methods to [SalesImportParseResultDto].
extension SalesImportParseResultDtoPatterns on SalesImportParseResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesImportParseResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesImportParseResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesImportParseResultDto value)  $default,){
final _that = this;
switch (_that) {
case _SalesImportParseResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesImportParseResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _SalesImportParseResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SalesImportDetailDto salesImport,  int parsedRows,  List<SalesParseErrorDto> parseErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesImportParseResultDto() when $default != null:
return $default(_that.salesImport,_that.parsedRows,_that.parseErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SalesImportDetailDto salesImport,  int parsedRows,  List<SalesParseErrorDto> parseErrors)  $default,) {final _that = this;
switch (_that) {
case _SalesImportParseResultDto():
return $default(_that.salesImport,_that.parsedRows,_that.parseErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SalesImportDetailDto salesImport,  int parsedRows,  List<SalesParseErrorDto> parseErrors)?  $default,) {final _that = this;
switch (_that) {
case _SalesImportParseResultDto() when $default != null:
return $default(_that.salesImport,_that.parsedRows,_that.parseErrors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalesImportParseResultDto extends SalesImportParseResultDto {
  const _SalesImportParseResultDto({required this.salesImport, this.parsedRows = 0,  List<SalesParseErrorDto> parseErrors = const <SalesParseErrorDto>[]}): _parseErrors = parseErrors,super._();
  factory _SalesImportParseResultDto.fromJson(Map<String, dynamic> json) => _$SalesImportParseResultDtoFromJson(json);

@override final  SalesImportDetailDto salesImport;
@override@JsonKey() final  int parsedRows;
 final  List<SalesParseErrorDto> _parseErrors;
@override@JsonKey() List<SalesParseErrorDto> get parseErrors {
  if (_parseErrors is EqualUnmodifiableListView) return _parseErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parseErrors);
}


/// Create a copy of SalesImportParseResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesImportParseResultDtoCopyWith<_SalesImportParseResultDto> get copyWith => __$SalesImportParseResultDtoCopyWithImpl<_SalesImportParseResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalesImportParseResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesImportParseResultDto&&(identical(other.salesImport, salesImport) || other.salesImport == salesImport)&&(identical(other.parsedRows, parsedRows) || other.parsedRows == parsedRows)&&const DeepCollectionEquality().equals(other.parseErrors, _parseErrors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,salesImport,parsedRows,const DeepCollectionEquality().hash(_parseErrors));
}

@override
String toString() {
    return 'SalesImportParseResultDto(salesImport: $salesImport, parsedRows: $parsedRows, parseErrors: $parseErrors)';
}


}

/// @nodoc
abstract mixin class _$SalesImportParseResultDtoCopyWith<$Res> implements $SalesImportParseResultDtoCopyWith<$Res> {
  factory _$SalesImportParseResultDtoCopyWith(_SalesImportParseResultDto value, $Res Function(_SalesImportParseResultDto) _then) = __$SalesImportParseResultDtoCopyWithImpl;
@override @useResult
$Res call({
 SalesImportDetailDto salesImport, int parsedRows, List<SalesParseErrorDto> parseErrors
});


@override $SalesImportDetailDtoCopyWith<$Res> get salesImport;

}
/// @nodoc
class __$SalesImportParseResultDtoCopyWithImpl<$Res>
    implements _$SalesImportParseResultDtoCopyWith<$Res> {
  __$SalesImportParseResultDtoCopyWithImpl(this._self, this._then);

  final _SalesImportParseResultDto _self;
  final $Res Function(_SalesImportParseResultDto) _then;

/// Create a copy of SalesImportParseResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? salesImport = null,Object? parsedRows = null,Object? parseErrors = null,}) {
  return _then(_SalesImportParseResultDto(
salesImport: null == salesImport ? _self.salesImport : salesImport // ignore: cast_nullable_to_non_nullable
as SalesImportDetailDto,parsedRows: null == parsedRows ? _self.parsedRows : parsedRows // ignore: cast_nullable_to_non_nullable
as int,parseErrors: null == parseErrors ? _self._parseErrors : parseErrors // ignore: cast_nullable_to_non_nullable
as List<SalesParseErrorDto>,
  ));
}

/// Create a copy of SalesImportParseResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesImportDetailDtoCopyWith<$Res> get salesImport {
  
  return $SalesImportDetailDtoCopyWith<$Res>(_self.salesImport, (value) {
    return _then(_self.copyWith(salesImport: value));
  });
}
}


/// @nodoc
mixin _$SalesCsvColumnMapping {

 String? get posCode; String? get qtySold; String? get grossAmount;
/// Create a copy of SalesCsvColumnMapping
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesCsvColumnMappingCopyWith<SalesCsvColumnMapping> get copyWith => _$SalesCsvColumnMappingCopyWithImpl<SalesCsvColumnMapping>(this as SalesCsvColumnMapping, _$identity);

  /// Serializes this SalesCsvColumnMapping to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SalesCsvColumnMapping;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesCsvColumnMapping&&(identical(other.posCode, _this.posCode) || other.posCode == _this.posCode)&&(identical(other.qtySold, _this.qtySold) || other.qtySold == _this.qtySold)&&(identical(other.grossAmount, _this.grossAmount) || other.grossAmount == _this.grossAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SalesCsvColumnMapping;
  return Object.hash(runtimeType,_this.posCode,_this.qtySold,_this.grossAmount);
}

@override
String toString() {
  final _this = this as SalesCsvColumnMapping;
  return 'SalesCsvColumnMapping(posCode: ${_this.posCode}, qtySold: ${_this.qtySold}, grossAmount: ${_this.grossAmount})';
}


}

/// @nodoc
abstract mixin class $SalesCsvColumnMappingCopyWith<$Res>  {
  factory $SalesCsvColumnMappingCopyWith(SalesCsvColumnMapping value, $Res Function(SalesCsvColumnMapping) _then) = _$SalesCsvColumnMappingCopyWithImpl;
@useResult
$Res call({
 String? posCode, String? qtySold, String? grossAmount
});




}
/// @nodoc
class _$SalesCsvColumnMappingCopyWithImpl<$Res>
    implements $SalesCsvColumnMappingCopyWith<$Res> {
  _$SalesCsvColumnMappingCopyWithImpl(this._self, this._then);

  final SalesCsvColumnMapping _self;
  final $Res Function(SalesCsvColumnMapping) _then;

/// Create a copy of SalesCsvColumnMapping
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? posCode = freezed,Object? qtySold = freezed,Object? grossAmount = freezed,}) {
  return _then(SalesCsvColumnMapping(
posCode: freezed == posCode ? _self.posCode : posCode // ignore: cast_nullable_to_non_nullable
as String?,qtySold: freezed == qtySold ? _self.qtySold : qtySold // ignore: cast_nullable_to_non_nullable
as String?,grossAmount: freezed == grossAmount ? _self.grossAmount : grossAmount // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesCsvColumnMapping].
extension SalesCsvColumnMappingPatterns on SalesCsvColumnMapping {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesCsvColumnMapping value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesCsvColumnMapping() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesCsvColumnMapping value)  $default,){
final _that = this;
switch (_that) {
case _SalesCsvColumnMapping():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesCsvColumnMapping value)?  $default,){
final _that = this;
switch (_that) {
case _SalesCsvColumnMapping() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? posCode,  String? qtySold,  String? grossAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesCsvColumnMapping() when $default != null:
return $default(_that.posCode,_that.qtySold,_that.grossAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? posCode,  String? qtySold,  String? grossAmount)  $default,) {final _that = this;
switch (_that) {
case _SalesCsvColumnMapping():
return $default(_that.posCode,_that.qtySold,_that.grossAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? posCode,  String? qtySold,  String? grossAmount)?  $default,) {final _that = this;
switch (_that) {
case _SalesCsvColumnMapping() when $default != null:
return $default(_that.posCode,_that.qtySold,_that.grossAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalesCsvColumnMapping extends SalesCsvColumnMapping {
  const _SalesCsvColumnMapping({this.posCode, this.qtySold, this.grossAmount}): super._();
  factory _SalesCsvColumnMapping.fromJson(Map<String, dynamic> json) => _$SalesCsvColumnMappingFromJson(json);

@override final  String? posCode;
@override final  String? qtySold;
@override final  String? grossAmount;

/// Create a copy of SalesCsvColumnMapping
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesCsvColumnMappingCopyWith<_SalesCsvColumnMapping> get copyWith => __$SalesCsvColumnMappingCopyWithImpl<_SalesCsvColumnMapping>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalesCsvColumnMappingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesCsvColumnMapping&&(identical(other.posCode, posCode) || other.posCode == posCode)&&(identical(other.qtySold, qtySold) || other.qtySold == qtySold)&&(identical(other.grossAmount, grossAmount) || other.grossAmount == grossAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,posCode,qtySold,grossAmount);
}

@override
String toString() {
    return 'SalesCsvColumnMapping(posCode: $posCode, qtySold: $qtySold, grossAmount: $grossAmount)';
}


}

/// @nodoc
abstract mixin class _$SalesCsvColumnMappingCopyWith<$Res> implements $SalesCsvColumnMappingCopyWith<$Res> {
  factory _$SalesCsvColumnMappingCopyWith(_SalesCsvColumnMapping value, $Res Function(_SalesCsvColumnMapping) _then) = __$SalesCsvColumnMappingCopyWithImpl;
@override @useResult
$Res call({
 String? posCode, String? qtySold, String? grossAmount
});




}
/// @nodoc
class __$SalesCsvColumnMappingCopyWithImpl<$Res>
    implements _$SalesCsvColumnMappingCopyWith<$Res> {
  __$SalesCsvColumnMappingCopyWithImpl(this._self, this._then);

  final _SalesCsvColumnMapping _self;
  final $Res Function(_SalesCsvColumnMapping) _then;

/// Create a copy of SalesCsvColumnMapping
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? posCode = freezed,Object? qtySold = freezed,Object? grossAmount = freezed,}) {
  return _then(_SalesCsvColumnMapping(
posCode: freezed == posCode ? _self.posCode : posCode // ignore: cast_nullable_to_non_nullable
as String?,qtySold: freezed == qtySold ? _self.qtySold : qtySold // ignore: cast_nullable_to_non_nullable
as String?,grossAmount: freezed == grossAmount ? _self.grossAmount : grossAmount // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ConsumptionRunLineDto {

 int get productId; Quantity get theoreticalQtyBase; Quantity get postedQtyBase; Quantity get shortfallQtyBase; int get baseUomId; String? get productSku; String? get productName; String? get baseUomCode;/// Absent without `master.product.view_cost` (SPEC §16).
 Money? get unitCost; Money? get costAmount;
/// Create a copy of ConsumptionRunLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsumptionRunLineDtoCopyWith<ConsumptionRunLineDto> get copyWith => _$ConsumptionRunLineDtoCopyWithImpl<ConsumptionRunLineDto>(this as ConsumptionRunLineDto, _$identity);

  /// Serializes this ConsumptionRunLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConsumptionRunLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsumptionRunLineDto&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.theoreticalQtyBase, _this.theoreticalQtyBase) || other.theoreticalQtyBase == _this.theoreticalQtyBase)&&(identical(other.postedQtyBase, _this.postedQtyBase) || other.postedQtyBase == _this.postedQtyBase)&&(identical(other.shortfallQtyBase, _this.shortfallQtyBase) || other.shortfallQtyBase == _this.shortfallQtyBase)&&(identical(other.baseUomId, _this.baseUomId) || other.baseUomId == _this.baseUomId)&&(identical(other.productSku, _this.productSku) || other.productSku == _this.productSku)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.baseUomCode, _this.baseUomCode) || other.baseUomCode == _this.baseUomCode)&&(identical(other.unitCost, _this.unitCost) || other.unitCost == _this.unitCost)&&(identical(other.costAmount, _this.costAmount) || other.costAmount == _this.costAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConsumptionRunLineDto;
  return Object.hash(runtimeType,_this.productId,_this.theoreticalQtyBase,_this.postedQtyBase,_this.shortfallQtyBase,_this.baseUomId,_this.productSku,_this.productName,_this.baseUomCode,_this.unitCost,_this.costAmount);
}

@override
String toString() {
  final _this = this as ConsumptionRunLineDto;
  return 'ConsumptionRunLineDto(productId: ${_this.productId}, theoreticalQtyBase: ${_this.theoreticalQtyBase}, postedQtyBase: ${_this.postedQtyBase}, shortfallQtyBase: ${_this.shortfallQtyBase}, baseUomId: ${_this.baseUomId}, productSku: ${_this.productSku}, productName: ${_this.productName}, baseUomCode: ${_this.baseUomCode}, unitCost: ${_this.unitCost}, costAmount: ${_this.costAmount})';
}


}

/// @nodoc
abstract mixin class $ConsumptionRunLineDtoCopyWith<$Res>  {
  factory $ConsumptionRunLineDtoCopyWith(ConsumptionRunLineDto value, $Res Function(ConsumptionRunLineDto) _then) = _$ConsumptionRunLineDtoCopyWithImpl;
@useResult
$Res call({
 int productId, Quantity theoreticalQtyBase, Quantity postedQtyBase, Quantity shortfallQtyBase, int baseUomId, String? productSku, String? productName, String? baseUomCode, Money? unitCost, Money? costAmount
});




}
/// @nodoc
class _$ConsumptionRunLineDtoCopyWithImpl<$Res>
    implements $ConsumptionRunLineDtoCopyWith<$Res> {
  _$ConsumptionRunLineDtoCopyWithImpl(this._self, this._then);

  final ConsumptionRunLineDto _self;
  final $Res Function(ConsumptionRunLineDto) _then;

/// Create a copy of ConsumptionRunLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? theoreticalQtyBase = null,Object? postedQtyBase = null,Object? shortfallQtyBase = null,Object? baseUomId = null,Object? productSku = freezed,Object? productName = freezed,Object? baseUomCode = freezed,Object? unitCost = freezed,Object? costAmount = freezed,}) {
  return _then(ConsumptionRunLineDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,theoreticalQtyBase: null == theoreticalQtyBase ? _self.theoreticalQtyBase : theoreticalQtyBase // ignore: cast_nullable_to_non_nullable
as Quantity,postedQtyBase: null == postedQtyBase ? _self.postedQtyBase : postedQtyBase // ignore: cast_nullable_to_non_nullable
as Quantity,shortfallQtyBase: null == shortfallQtyBase ? _self.shortfallQtyBase : shortfallQtyBase // ignore: cast_nullable_to_non_nullable
as Quantity,baseUomId: null == baseUomId ? _self.baseUomId : baseUomId // ignore: cast_nullable_to_non_nullable
as int,productSku: freezed == productSku ? _self.productSku : productSku // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,unitCost: freezed == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as Money?,costAmount: freezed == costAmount ? _self.costAmount : costAmount // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsumptionRunLineDto].
extension ConsumptionRunLineDtoPatterns on ConsumptionRunLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsumptionRunLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsumptionRunLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsumptionRunLineDto value)  $default,){
final _that = this;
switch (_that) {
case _ConsumptionRunLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsumptionRunLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConsumptionRunLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  Quantity theoreticalQtyBase,  Quantity postedQtyBase,  Quantity shortfallQtyBase,  int baseUomId,  String? productSku,  String? productName,  String? baseUomCode,  Money? unitCost,  Money? costAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsumptionRunLineDto() when $default != null:
return $default(_that.productId,_that.theoreticalQtyBase,_that.postedQtyBase,_that.shortfallQtyBase,_that.baseUomId,_that.productSku,_that.productName,_that.baseUomCode,_that.unitCost,_that.costAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  Quantity theoreticalQtyBase,  Quantity postedQtyBase,  Quantity shortfallQtyBase,  int baseUomId,  String? productSku,  String? productName,  String? baseUomCode,  Money? unitCost,  Money? costAmount)  $default,) {final _that = this;
switch (_that) {
case _ConsumptionRunLineDto():
return $default(_that.productId,_that.theoreticalQtyBase,_that.postedQtyBase,_that.shortfallQtyBase,_that.baseUomId,_that.productSku,_that.productName,_that.baseUomCode,_that.unitCost,_that.costAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  Quantity theoreticalQtyBase,  Quantity postedQtyBase,  Quantity shortfallQtyBase,  int baseUomId,  String? productSku,  String? productName,  String? baseUomCode,  Money? unitCost,  Money? costAmount)?  $default,) {final _that = this;
switch (_that) {
case _ConsumptionRunLineDto() when $default != null:
return $default(_that.productId,_that.theoreticalQtyBase,_that.postedQtyBase,_that.shortfallQtyBase,_that.baseUomId,_that.productSku,_that.productName,_that.baseUomCode,_that.unitCost,_that.costAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConsumptionRunLineDto extends ConsumptionRunLineDto {
  const _ConsumptionRunLineDto({required this.productId, required this.theoreticalQtyBase, required this.postedQtyBase, required this.shortfallQtyBase, required this.baseUomId, this.productSku, this.productName, this.baseUomCode, this.unitCost, this.costAmount}): super._();
  factory _ConsumptionRunLineDto.fromJson(Map<String, dynamic> json) => _$ConsumptionRunLineDtoFromJson(json);

@override final  int productId;
@override final  Quantity theoreticalQtyBase;
@override final  Quantity postedQtyBase;
@override final  Quantity shortfallQtyBase;
@override final  int baseUomId;
@override final  String? productSku;
@override final  String? productName;
@override final  String? baseUomCode;
/// Absent without `master.product.view_cost` (SPEC §16).
@override final  Money? unitCost;
@override final  Money? costAmount;

/// Create a copy of ConsumptionRunLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsumptionRunLineDtoCopyWith<_ConsumptionRunLineDto> get copyWith => __$ConsumptionRunLineDtoCopyWithImpl<_ConsumptionRunLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsumptionRunLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsumptionRunLineDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.theoreticalQtyBase, theoreticalQtyBase) || other.theoreticalQtyBase == theoreticalQtyBase)&&(identical(other.postedQtyBase, postedQtyBase) || other.postedQtyBase == postedQtyBase)&&(identical(other.shortfallQtyBase, shortfallQtyBase) || other.shortfallQtyBase == shortfallQtyBase)&&(identical(other.baseUomId, baseUomId) || other.baseUomId == baseUomId)&&(identical(other.productSku, productSku) || other.productSku == productSku)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.baseUomCode, baseUomCode) || other.baseUomCode == baseUomCode)&&(identical(other.unitCost, unitCost) || other.unitCost == unitCost)&&(identical(other.costAmount, costAmount) || other.costAmount == costAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,theoreticalQtyBase,postedQtyBase,shortfallQtyBase,baseUomId,productSku,productName,baseUomCode,unitCost,costAmount);
}

@override
String toString() {
    return 'ConsumptionRunLineDto(productId: $productId, theoreticalQtyBase: $theoreticalQtyBase, postedQtyBase: $postedQtyBase, shortfallQtyBase: $shortfallQtyBase, baseUomId: $baseUomId, productSku: $productSku, productName: $productName, baseUomCode: $baseUomCode, unitCost: $unitCost, costAmount: $costAmount)';
}


}

/// @nodoc
abstract mixin class _$ConsumptionRunLineDtoCopyWith<$Res> implements $ConsumptionRunLineDtoCopyWith<$Res> {
  factory _$ConsumptionRunLineDtoCopyWith(_ConsumptionRunLineDto value, $Res Function(_ConsumptionRunLineDto) _then) = __$ConsumptionRunLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int productId, Quantity theoreticalQtyBase, Quantity postedQtyBase, Quantity shortfallQtyBase, int baseUomId, String? productSku, String? productName, String? baseUomCode, Money? unitCost, Money? costAmount
});




}
/// @nodoc
class __$ConsumptionRunLineDtoCopyWithImpl<$Res>
    implements _$ConsumptionRunLineDtoCopyWith<$Res> {
  __$ConsumptionRunLineDtoCopyWithImpl(this._self, this._then);

  final _ConsumptionRunLineDto _self;
  final $Res Function(_ConsumptionRunLineDto) _then;

/// Create a copy of ConsumptionRunLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? theoreticalQtyBase = null,Object? postedQtyBase = null,Object? shortfallQtyBase = null,Object? baseUomId = null,Object? productSku = freezed,Object? productName = freezed,Object? baseUomCode = freezed,Object? unitCost = freezed,Object? costAmount = freezed,}) {
  return _then(_ConsumptionRunLineDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,theoreticalQtyBase: null == theoreticalQtyBase ? _self.theoreticalQtyBase : theoreticalQtyBase // ignore: cast_nullable_to_non_nullable
as Quantity,postedQtyBase: null == postedQtyBase ? _self.postedQtyBase : postedQtyBase // ignore: cast_nullable_to_non_nullable
as Quantity,shortfallQtyBase: null == shortfallQtyBase ? _self.shortfallQtyBase : shortfallQtyBase // ignore: cast_nullable_to_non_nullable
as Quantity,baseUomId: null == baseUomId ? _self.baseUomId : baseUomId // ignore: cast_nullable_to_non_nullable
as int,productSku: freezed == productSku ? _self.productSku : productSku // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,unitCost: freezed == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as Money?,costAmount: freezed == costAmount ? _self.costAmount : costAmount // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}


}


/// @nodoc
mixin _$ConsumptionRunDto {

 int get id; String get docNo; int get locationId;@DateOnlyConverter() DateTime get businessDate; ConsumptionRunStatus get status; int get rowVersion; String? get locationName; int? get salesImportId; int? get movementGroupId; int get shortfallCount; int get unmappedCount; String? get failureReason; DateTime? get calculatedAt; DateTime? get postedAt;
/// Create a copy of ConsumptionRunDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsumptionRunDtoCopyWith<ConsumptionRunDto> get copyWith => _$ConsumptionRunDtoCopyWithImpl<ConsumptionRunDto>(this as ConsumptionRunDto, _$identity);

  /// Serializes this ConsumptionRunDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConsumptionRunDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsumptionRunDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.businessDate, _this.businessDate) || other.businessDate == _this.businessDate)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&(identical(other.locationName, _this.locationName) || other.locationName == _this.locationName)&&(identical(other.salesImportId, _this.salesImportId) || other.salesImportId == _this.salesImportId)&&(identical(other.movementGroupId, _this.movementGroupId) || other.movementGroupId == _this.movementGroupId)&&(identical(other.shortfallCount, _this.shortfallCount) || other.shortfallCount == _this.shortfallCount)&&(identical(other.unmappedCount, _this.unmappedCount) || other.unmappedCount == _this.unmappedCount)&&(identical(other.failureReason, _this.failureReason) || other.failureReason == _this.failureReason)&&(identical(other.calculatedAt, _this.calculatedAt) || other.calculatedAt == _this.calculatedAt)&&(identical(other.postedAt, _this.postedAt) || other.postedAt == _this.postedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConsumptionRunDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.locationId,_this.businessDate,_this.status,_this.rowVersion,_this.locationName,_this.salesImportId,_this.movementGroupId,_this.shortfallCount,_this.unmappedCount,_this.failureReason,_this.calculatedAt,_this.postedAt);
}

@override
String toString() {
  final _this = this as ConsumptionRunDto;
  return 'ConsumptionRunDto(id: ${_this.id}, docNo: ${_this.docNo}, locationId: ${_this.locationId}, businessDate: ${_this.businessDate}, status: ${_this.status}, rowVersion: ${_this.rowVersion}, locationName: ${_this.locationName}, salesImportId: ${_this.salesImportId}, movementGroupId: ${_this.movementGroupId}, shortfallCount: ${_this.shortfallCount}, unmappedCount: ${_this.unmappedCount}, failureReason: ${_this.failureReason}, calculatedAt: ${_this.calculatedAt}, postedAt: ${_this.postedAt})';
}


}

/// @nodoc
abstract mixin class $ConsumptionRunDtoCopyWith<$Res>  {
  factory $ConsumptionRunDtoCopyWith(ConsumptionRunDto value, $Res Function(ConsumptionRunDto) _then) = _$ConsumptionRunDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo, int locationId,@DateOnlyConverter() DateTime businessDate, ConsumptionRunStatus status, int rowVersion, String? locationName, int? salesImportId, int? movementGroupId, int shortfallCount, int unmappedCount, String? failureReason, DateTime? calculatedAt, DateTime? postedAt
});




}
/// @nodoc
class _$ConsumptionRunDtoCopyWithImpl<$Res>
    implements $ConsumptionRunDtoCopyWith<$Res> {
  _$ConsumptionRunDtoCopyWithImpl(this._self, this._then);

  final ConsumptionRunDto _self;
  final $Res Function(ConsumptionRunDto) _then;

/// Create a copy of ConsumptionRunDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? locationId = null,Object? businessDate = null,Object? status = null,Object? rowVersion = null,Object? locationName = freezed,Object? salesImportId = freezed,Object? movementGroupId = freezed,Object? shortfallCount = null,Object? unmappedCount = null,Object? failureReason = freezed,Object? calculatedAt = freezed,Object? postedAt = freezed,}) {
  return _then(ConsumptionRunDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,businessDate: null == businessDate ? _self.businessDate : businessDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConsumptionRunStatus,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,salesImportId: freezed == salesImportId ? _self.salesImportId : salesImportId // ignore: cast_nullable_to_non_nullable
as int?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,shortfallCount: null == shortfallCount ? _self.shortfallCount : shortfallCount // ignore: cast_nullable_to_non_nullable
as int,unmappedCount: null == unmappedCount ? _self.unmappedCount : unmappedCount // ignore: cast_nullable_to_non_nullable
as int,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,postedAt: freezed == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsumptionRunDto].
extension ConsumptionRunDtoPatterns on ConsumptionRunDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsumptionRunDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsumptionRunDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsumptionRunDto value)  $default,){
final _that = this;
switch (_that) {
case _ConsumptionRunDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsumptionRunDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConsumptionRunDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo,  int locationId, @DateOnlyConverter()  DateTime businessDate,  ConsumptionRunStatus status,  int rowVersion,  String? locationName,  int? salesImportId,  int? movementGroupId,  int shortfallCount,  int unmappedCount,  String? failureReason,  DateTime? calculatedAt,  DateTime? postedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsumptionRunDto() when $default != null:
return $default(_that.id,_that.docNo,_that.locationId,_that.businessDate,_that.status,_that.rowVersion,_that.locationName,_that.salesImportId,_that.movementGroupId,_that.shortfallCount,_that.unmappedCount,_that.failureReason,_that.calculatedAt,_that.postedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo,  int locationId, @DateOnlyConverter()  DateTime businessDate,  ConsumptionRunStatus status,  int rowVersion,  String? locationName,  int? salesImportId,  int? movementGroupId,  int shortfallCount,  int unmappedCount,  String? failureReason,  DateTime? calculatedAt,  DateTime? postedAt)  $default,) {final _that = this;
switch (_that) {
case _ConsumptionRunDto():
return $default(_that.id,_that.docNo,_that.locationId,_that.businessDate,_that.status,_that.rowVersion,_that.locationName,_that.salesImportId,_that.movementGroupId,_that.shortfallCount,_that.unmappedCount,_that.failureReason,_that.calculatedAt,_that.postedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo,  int locationId, @DateOnlyConverter()  DateTime businessDate,  ConsumptionRunStatus status,  int rowVersion,  String? locationName,  int? salesImportId,  int? movementGroupId,  int shortfallCount,  int unmappedCount,  String? failureReason,  DateTime? calculatedAt,  DateTime? postedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConsumptionRunDto() when $default != null:
return $default(_that.id,_that.docNo,_that.locationId,_that.businessDate,_that.status,_that.rowVersion,_that.locationName,_that.salesImportId,_that.movementGroupId,_that.shortfallCount,_that.unmappedCount,_that.failureReason,_that.calculatedAt,_that.postedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConsumptionRunDto extends ConsumptionRunDto {
  const _ConsumptionRunDto({required this.id, required this.docNo, required this.locationId, @DateOnlyConverter() required this.businessDate, required this.status, required this.rowVersion, this.locationName, this.salesImportId, this.movementGroupId, this.shortfallCount = 0, this.unmappedCount = 0, this.failureReason, this.calculatedAt, this.postedAt}): super._();
  factory _ConsumptionRunDto.fromJson(Map<String, dynamic> json) => _$ConsumptionRunDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override final  int locationId;
@override@DateOnlyConverter() final  DateTime businessDate;
@override final  ConsumptionRunStatus status;
@override final  int rowVersion;
@override final  String? locationName;
@override final  int? salesImportId;
@override final  int? movementGroupId;
@override@JsonKey() final  int shortfallCount;
@override@JsonKey() final  int unmappedCount;
@override final  String? failureReason;
@override final  DateTime? calculatedAt;
@override final  DateTime? postedAt;

/// Create a copy of ConsumptionRunDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsumptionRunDtoCopyWith<_ConsumptionRunDto> get copyWith => __$ConsumptionRunDtoCopyWithImpl<_ConsumptionRunDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsumptionRunDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsumptionRunDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.businessDate, businessDate) || other.businessDate == businessDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.salesImportId, salesImportId) || other.salesImportId == salesImportId)&&(identical(other.movementGroupId, movementGroupId) || other.movementGroupId == movementGroupId)&&(identical(other.shortfallCount, shortfallCount) || other.shortfallCount == shortfallCount)&&(identical(other.unmappedCount, unmappedCount) || other.unmappedCount == unmappedCount)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,locationId,businessDate,status,rowVersion,locationName,salesImportId,movementGroupId,shortfallCount,unmappedCount,failureReason,calculatedAt,postedAt);
}

@override
String toString() {
    return 'ConsumptionRunDto(id: $id, docNo: $docNo, locationId: $locationId, businessDate: $businessDate, status: $status, rowVersion: $rowVersion, locationName: $locationName, salesImportId: $salesImportId, movementGroupId: $movementGroupId, shortfallCount: $shortfallCount, unmappedCount: $unmappedCount, failureReason: $failureReason, calculatedAt: $calculatedAt, postedAt: $postedAt)';
}


}

/// @nodoc
abstract mixin class _$ConsumptionRunDtoCopyWith<$Res> implements $ConsumptionRunDtoCopyWith<$Res> {
  factory _$ConsumptionRunDtoCopyWith(_ConsumptionRunDto value, $Res Function(_ConsumptionRunDto) _then) = __$ConsumptionRunDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo, int locationId,@DateOnlyConverter() DateTime businessDate, ConsumptionRunStatus status, int rowVersion, String? locationName, int? salesImportId, int? movementGroupId, int shortfallCount, int unmappedCount, String? failureReason, DateTime? calculatedAt, DateTime? postedAt
});




}
/// @nodoc
class __$ConsumptionRunDtoCopyWithImpl<$Res>
    implements _$ConsumptionRunDtoCopyWith<$Res> {
  __$ConsumptionRunDtoCopyWithImpl(this._self, this._then);

  final _ConsumptionRunDto _self;
  final $Res Function(_ConsumptionRunDto) _then;

/// Create a copy of ConsumptionRunDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? locationId = null,Object? businessDate = null,Object? status = null,Object? rowVersion = null,Object? locationName = freezed,Object? salesImportId = freezed,Object? movementGroupId = freezed,Object? shortfallCount = null,Object? unmappedCount = null,Object? failureReason = freezed,Object? calculatedAt = freezed,Object? postedAt = freezed,}) {
  return _then(_ConsumptionRunDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,businessDate: null == businessDate ? _self.businessDate : businessDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConsumptionRunStatus,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,salesImportId: freezed == salesImportId ? _self.salesImportId : salesImportId // ignore: cast_nullable_to_non_nullable
as int?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,shortfallCount: null == shortfallCount ? _self.shortfallCount : shortfallCount // ignore: cast_nullable_to_non_nullable
as int,unmappedCount: null == unmappedCount ? _self.unmappedCount : unmappedCount // ignore: cast_nullable_to_non_nullable
as int,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,postedAt: freezed == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ConsumptionRunDetailDto {

 int get id; String get docNo; int get locationId;@DateOnlyConverter() DateTime get businessDate; ConsumptionRunStatus get status; int get rowVersion; String? get locationName; int? get salesImportId; int? get movementGroupId; int get shortfallCount; int get unmappedCount; String? get failureReason; DateTime? get calculatedAt; DateTime? get postedAt; List<ConsumptionRunLineDto> get lines;/// Bound to `master.product.view_cost`.
 Money? get totalCostAmount;
/// Create a copy of ConsumptionRunDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsumptionRunDetailDtoCopyWith<ConsumptionRunDetailDto> get copyWith => _$ConsumptionRunDetailDtoCopyWithImpl<ConsumptionRunDetailDto>(this as ConsumptionRunDetailDto, _$identity);

  /// Serializes this ConsumptionRunDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConsumptionRunDetailDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsumptionRunDetailDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.docNo, _this.docNo) || other.docNo == _this.docNo)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.businessDate, _this.businessDate) || other.businessDate == _this.businessDate)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion)&&(identical(other.locationName, _this.locationName) || other.locationName == _this.locationName)&&(identical(other.salesImportId, _this.salesImportId) || other.salesImportId == _this.salesImportId)&&(identical(other.movementGroupId, _this.movementGroupId) || other.movementGroupId == _this.movementGroupId)&&(identical(other.shortfallCount, _this.shortfallCount) || other.shortfallCount == _this.shortfallCount)&&(identical(other.unmappedCount, _this.unmappedCount) || other.unmappedCount == _this.unmappedCount)&&(identical(other.failureReason, _this.failureReason) || other.failureReason == _this.failureReason)&&(identical(other.calculatedAt, _this.calculatedAt) || other.calculatedAt == _this.calculatedAt)&&(identical(other.postedAt, _this.postedAt) || other.postedAt == _this.postedAt)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.totalCostAmount, _this.totalCostAmount) || other.totalCostAmount == _this.totalCostAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConsumptionRunDetailDto;
  return Object.hash(runtimeType,_this.id,_this.docNo,_this.locationId,_this.businessDate,_this.status,_this.rowVersion,_this.locationName,_this.salesImportId,_this.movementGroupId,_this.shortfallCount,_this.unmappedCount,_this.failureReason,_this.calculatedAt,_this.postedAt,const DeepCollectionEquality().hash(_this.lines),_this.totalCostAmount);
}

@override
String toString() {
  final _this = this as ConsumptionRunDetailDto;
  return 'ConsumptionRunDetailDto(id: ${_this.id}, docNo: ${_this.docNo}, locationId: ${_this.locationId}, businessDate: ${_this.businessDate}, status: ${_this.status}, rowVersion: ${_this.rowVersion}, locationName: ${_this.locationName}, salesImportId: ${_this.salesImportId}, movementGroupId: ${_this.movementGroupId}, shortfallCount: ${_this.shortfallCount}, unmappedCount: ${_this.unmappedCount}, failureReason: ${_this.failureReason}, calculatedAt: ${_this.calculatedAt}, postedAt: ${_this.postedAt}, lines: ${_this.lines}, totalCostAmount: ${_this.totalCostAmount})';
}


}

/// @nodoc
abstract mixin class $ConsumptionRunDetailDtoCopyWith<$Res>  {
  factory $ConsumptionRunDetailDtoCopyWith(ConsumptionRunDetailDto value, $Res Function(ConsumptionRunDetailDto) _then) = _$ConsumptionRunDetailDtoCopyWithImpl;
@useResult
$Res call({
 int id, String docNo, int locationId,@DateOnlyConverter() DateTime businessDate, ConsumptionRunStatus status, int rowVersion, String? locationName, int? salesImportId, int? movementGroupId, int shortfallCount, int unmappedCount, String? failureReason, DateTime? calculatedAt, DateTime? postedAt, List<ConsumptionRunLineDto> lines, Money? totalCostAmount
});




}
/// @nodoc
class _$ConsumptionRunDetailDtoCopyWithImpl<$Res>
    implements $ConsumptionRunDetailDtoCopyWith<$Res> {
  _$ConsumptionRunDetailDtoCopyWithImpl(this._self, this._then);

  final ConsumptionRunDetailDto _self;
  final $Res Function(ConsumptionRunDetailDto) _then;

/// Create a copy of ConsumptionRunDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? docNo = null,Object? locationId = null,Object? businessDate = null,Object? status = null,Object? rowVersion = null,Object? locationName = freezed,Object? salesImportId = freezed,Object? movementGroupId = freezed,Object? shortfallCount = null,Object? unmappedCount = null,Object? failureReason = freezed,Object? calculatedAt = freezed,Object? postedAt = freezed,Object? lines = null,Object? totalCostAmount = freezed,}) {
  return _then(ConsumptionRunDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,businessDate: null == businessDate ? _self.businessDate : businessDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConsumptionRunStatus,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,salesImportId: freezed == salesImportId ? _self.salesImportId : salesImportId // ignore: cast_nullable_to_non_nullable
as int?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,shortfallCount: null == shortfallCount ? _self.shortfallCount : shortfallCount // ignore: cast_nullable_to_non_nullable
as int,unmappedCount: null == unmappedCount ? _self.unmappedCount : unmappedCount // ignore: cast_nullable_to_non_nullable
as int,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,postedAt: freezed == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<ConsumptionRunLineDto>,totalCostAmount: freezed == totalCostAmount ? _self.totalCostAmount : totalCostAmount // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsumptionRunDetailDto].
extension ConsumptionRunDetailDtoPatterns on ConsumptionRunDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsumptionRunDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsumptionRunDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsumptionRunDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _ConsumptionRunDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsumptionRunDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConsumptionRunDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String docNo,  int locationId, @DateOnlyConverter()  DateTime businessDate,  ConsumptionRunStatus status,  int rowVersion,  String? locationName,  int? salesImportId,  int? movementGroupId,  int shortfallCount,  int unmappedCount,  String? failureReason,  DateTime? calculatedAt,  DateTime? postedAt,  List<ConsumptionRunLineDto> lines,  Money? totalCostAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsumptionRunDetailDto() when $default != null:
return $default(_that.id,_that.docNo,_that.locationId,_that.businessDate,_that.status,_that.rowVersion,_that.locationName,_that.salesImportId,_that.movementGroupId,_that.shortfallCount,_that.unmappedCount,_that.failureReason,_that.calculatedAt,_that.postedAt,_that.lines,_that.totalCostAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String docNo,  int locationId, @DateOnlyConverter()  DateTime businessDate,  ConsumptionRunStatus status,  int rowVersion,  String? locationName,  int? salesImportId,  int? movementGroupId,  int shortfallCount,  int unmappedCount,  String? failureReason,  DateTime? calculatedAt,  DateTime? postedAt,  List<ConsumptionRunLineDto> lines,  Money? totalCostAmount)  $default,) {final _that = this;
switch (_that) {
case _ConsumptionRunDetailDto():
return $default(_that.id,_that.docNo,_that.locationId,_that.businessDate,_that.status,_that.rowVersion,_that.locationName,_that.salesImportId,_that.movementGroupId,_that.shortfallCount,_that.unmappedCount,_that.failureReason,_that.calculatedAt,_that.postedAt,_that.lines,_that.totalCostAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String docNo,  int locationId, @DateOnlyConverter()  DateTime businessDate,  ConsumptionRunStatus status,  int rowVersion,  String? locationName,  int? salesImportId,  int? movementGroupId,  int shortfallCount,  int unmappedCount,  String? failureReason,  DateTime? calculatedAt,  DateTime? postedAt,  List<ConsumptionRunLineDto> lines,  Money? totalCostAmount)?  $default,) {final _that = this;
switch (_that) {
case _ConsumptionRunDetailDto() when $default != null:
return $default(_that.id,_that.docNo,_that.locationId,_that.businessDate,_that.status,_that.rowVersion,_that.locationName,_that.salesImportId,_that.movementGroupId,_that.shortfallCount,_that.unmappedCount,_that.failureReason,_that.calculatedAt,_that.postedAt,_that.lines,_that.totalCostAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConsumptionRunDetailDto extends ConsumptionRunDetailDto {
  const _ConsumptionRunDetailDto({required this.id, required this.docNo, required this.locationId, @DateOnlyConverter() required this.businessDate, required this.status, required this.rowVersion, this.locationName, this.salesImportId, this.movementGroupId, this.shortfallCount = 0, this.unmappedCount = 0, this.failureReason, this.calculatedAt, this.postedAt,  List<ConsumptionRunLineDto> lines = const <ConsumptionRunLineDto>[], this.totalCostAmount}): _lines = lines,super._();
  factory _ConsumptionRunDetailDto.fromJson(Map<String, dynamic> json) => _$ConsumptionRunDetailDtoFromJson(json);

@override final  int id;
@override final  String docNo;
@override final  int locationId;
@override@DateOnlyConverter() final  DateTime businessDate;
@override final  ConsumptionRunStatus status;
@override final  int rowVersion;
@override final  String? locationName;
@override final  int? salesImportId;
@override final  int? movementGroupId;
@override@JsonKey() final  int shortfallCount;
@override@JsonKey() final  int unmappedCount;
@override final  String? failureReason;
@override final  DateTime? calculatedAt;
@override final  DateTime? postedAt;
 final  List<ConsumptionRunLineDto> _lines;
@override@JsonKey() List<ConsumptionRunLineDto> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

/// Bound to `master.product.view_cost`.
@override final  Money? totalCostAmount;

/// Create a copy of ConsumptionRunDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsumptionRunDetailDtoCopyWith<_ConsumptionRunDetailDto> get copyWith => __$ConsumptionRunDetailDtoCopyWithImpl<_ConsumptionRunDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsumptionRunDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsumptionRunDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.docNo, docNo) || other.docNo == docNo)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.businessDate, businessDate) || other.businessDate == businessDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.salesImportId, salesImportId) || other.salesImportId == salesImportId)&&(identical(other.movementGroupId, movementGroupId) || other.movementGroupId == movementGroupId)&&(identical(other.shortfallCount, shortfallCount) || other.shortfallCount == shortfallCount)&&(identical(other.unmappedCount, unmappedCount) || other.unmappedCount == unmappedCount)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.totalCostAmount, totalCostAmount) || other.totalCostAmount == totalCostAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,docNo,locationId,businessDate,status,rowVersion,locationName,salesImportId,movementGroupId,shortfallCount,unmappedCount,failureReason,calculatedAt,postedAt,const DeepCollectionEquality().hash(_lines),totalCostAmount);
}

@override
String toString() {
    return 'ConsumptionRunDetailDto(id: $id, docNo: $docNo, locationId: $locationId, businessDate: $businessDate, status: $status, rowVersion: $rowVersion, locationName: $locationName, salesImportId: $salesImportId, movementGroupId: $movementGroupId, shortfallCount: $shortfallCount, unmappedCount: $unmappedCount, failureReason: $failureReason, calculatedAt: $calculatedAt, postedAt: $postedAt, lines: $lines, totalCostAmount: $totalCostAmount)';
}


}

/// @nodoc
abstract mixin class _$ConsumptionRunDetailDtoCopyWith<$Res> implements $ConsumptionRunDetailDtoCopyWith<$Res> {
  factory _$ConsumptionRunDetailDtoCopyWith(_ConsumptionRunDetailDto value, $Res Function(_ConsumptionRunDetailDto) _then) = __$ConsumptionRunDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String docNo, int locationId,@DateOnlyConverter() DateTime businessDate, ConsumptionRunStatus status, int rowVersion, String? locationName, int? salesImportId, int? movementGroupId, int shortfallCount, int unmappedCount, String? failureReason, DateTime? calculatedAt, DateTime? postedAt, List<ConsumptionRunLineDto> lines, Money? totalCostAmount
});




}
/// @nodoc
class __$ConsumptionRunDetailDtoCopyWithImpl<$Res>
    implements _$ConsumptionRunDetailDtoCopyWith<$Res> {
  __$ConsumptionRunDetailDtoCopyWithImpl(this._self, this._then);

  final _ConsumptionRunDetailDto _self;
  final $Res Function(_ConsumptionRunDetailDto) _then;

/// Create a copy of ConsumptionRunDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? docNo = null,Object? locationId = null,Object? businessDate = null,Object? status = null,Object? rowVersion = null,Object? locationName = freezed,Object? salesImportId = freezed,Object? movementGroupId = freezed,Object? shortfallCount = null,Object? unmappedCount = null,Object? failureReason = freezed,Object? calculatedAt = freezed,Object? postedAt = freezed,Object? lines = null,Object? totalCostAmount = freezed,}) {
  return _then(_ConsumptionRunDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,docNo: null == docNo ? _self.docNo : docNo // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,businessDate: null == businessDate ? _self.businessDate : businessDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConsumptionRunStatus,rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,salesImportId: freezed == salesImportId ? _self.salesImportId : salesImportId // ignore: cast_nullable_to_non_nullable
as int?,movementGroupId: freezed == movementGroupId ? _self.movementGroupId : movementGroupId // ignore: cast_nullable_to_non_nullable
as int?,shortfallCount: null == shortfallCount ? _self.shortfallCount : shortfallCount // ignore: cast_nullable_to_non_nullable
as int,unmappedCount: null == unmappedCount ? _self.unmappedCount : unmappedCount // ignore: cast_nullable_to_non_nullable
as int,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,postedAt: freezed == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<ConsumptionRunLineDto>,totalCostAmount: freezed == totalCostAmount ? _self.totalCostAmount : totalCostAmount // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}


}


/// @nodoc
mixin _$CreateConsumptionRunRequest {

 int get salesImportId;/// Posts straight after the calculation; needs `cons.run.post`.
 bool get postImmediately;
/// Create a copy of CreateConsumptionRunRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateConsumptionRunRequestCopyWith<CreateConsumptionRunRequest> get copyWith => _$CreateConsumptionRunRequestCopyWithImpl<CreateConsumptionRunRequest>(this as CreateConsumptionRunRequest, _$identity);

  /// Serializes this CreateConsumptionRunRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateConsumptionRunRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateConsumptionRunRequest&&(identical(other.salesImportId, _this.salesImportId) || other.salesImportId == _this.salesImportId)&&(identical(other.postImmediately, _this.postImmediately) || other.postImmediately == _this.postImmediately));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateConsumptionRunRequest;
  return Object.hash(runtimeType,_this.salesImportId,_this.postImmediately);
}

@override
String toString() {
  final _this = this as CreateConsumptionRunRequest;
  return 'CreateConsumptionRunRequest(salesImportId: ${_this.salesImportId}, postImmediately: ${_this.postImmediately})';
}


}

/// @nodoc
abstract mixin class $CreateConsumptionRunRequestCopyWith<$Res>  {
  factory $CreateConsumptionRunRequestCopyWith(CreateConsumptionRunRequest value, $Res Function(CreateConsumptionRunRequest) _then) = _$CreateConsumptionRunRequestCopyWithImpl;
@useResult
$Res call({
 int salesImportId, bool postImmediately
});




}
/// @nodoc
class _$CreateConsumptionRunRequestCopyWithImpl<$Res>
    implements $CreateConsumptionRunRequestCopyWith<$Res> {
  _$CreateConsumptionRunRequestCopyWithImpl(this._self, this._then);

  final CreateConsumptionRunRequest _self;
  final $Res Function(CreateConsumptionRunRequest) _then;

/// Create a copy of CreateConsumptionRunRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? salesImportId = null,Object? postImmediately = null,}) {
  return _then(CreateConsumptionRunRequest(
salesImportId: null == salesImportId ? _self.salesImportId : salesImportId // ignore: cast_nullable_to_non_nullable
as int,postImmediately: null == postImmediately ? _self.postImmediately : postImmediately // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateConsumptionRunRequest].
extension CreateConsumptionRunRequestPatterns on CreateConsumptionRunRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateConsumptionRunRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateConsumptionRunRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateConsumptionRunRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateConsumptionRunRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateConsumptionRunRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateConsumptionRunRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int salesImportId,  bool postImmediately)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateConsumptionRunRequest() when $default != null:
return $default(_that.salesImportId,_that.postImmediately);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int salesImportId,  bool postImmediately)  $default,) {final _that = this;
switch (_that) {
case _CreateConsumptionRunRequest():
return $default(_that.salesImportId,_that.postImmediately);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int salesImportId,  bool postImmediately)?  $default,) {final _that = this;
switch (_that) {
case _CreateConsumptionRunRequest() when $default != null:
return $default(_that.salesImportId,_that.postImmediately);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateConsumptionRunRequest implements CreateConsumptionRunRequest {
  const _CreateConsumptionRunRequest({required this.salesImportId, this.postImmediately = false});
  factory _CreateConsumptionRunRequest.fromJson(Map<String, dynamic> json) => _$CreateConsumptionRunRequestFromJson(json);

@override final  int salesImportId;
/// Posts straight after the calculation; needs `cons.run.post`.
@override@JsonKey() final  bool postImmediately;

/// Create a copy of CreateConsumptionRunRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateConsumptionRunRequestCopyWith<_CreateConsumptionRunRequest> get copyWith => __$CreateConsumptionRunRequestCopyWithImpl<_CreateConsumptionRunRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateConsumptionRunRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateConsumptionRunRequest&&(identical(other.salesImportId, salesImportId) || other.salesImportId == salesImportId)&&(identical(other.postImmediately, postImmediately) || other.postImmediately == postImmediately));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,salesImportId,postImmediately);
}

@override
String toString() {
    return 'CreateConsumptionRunRequest(salesImportId: $salesImportId, postImmediately: $postImmediately)';
}


}

/// @nodoc
abstract mixin class _$CreateConsumptionRunRequestCopyWith<$Res> implements $CreateConsumptionRunRequestCopyWith<$Res> {
  factory _$CreateConsumptionRunRequestCopyWith(_CreateConsumptionRunRequest value, $Res Function(_CreateConsumptionRunRequest) _then) = __$CreateConsumptionRunRequestCopyWithImpl;
@override @useResult
$Res call({
 int salesImportId, bool postImmediately
});




}
/// @nodoc
class __$CreateConsumptionRunRequestCopyWithImpl<$Res>
    implements _$CreateConsumptionRunRequestCopyWith<$Res> {
  __$CreateConsumptionRunRequestCopyWithImpl(this._self, this._then);

  final _CreateConsumptionRunRequest _self;
  final $Res Function(_CreateConsumptionRunRequest) _then;

/// Create a copy of CreateConsumptionRunRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? salesImportId = null,Object? postImmediately = null,}) {
  return _then(_CreateConsumptionRunRequest(
salesImportId: null == salesImportId ? _self.salesImportId : salesImportId // ignore: cast_nullable_to_non_nullable
as int,postImmediately: null == postImmediately ? _self.postImmediately : postImmediately // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ConsumptionVersionedAction {

 int get rowVersion;
/// Create a copy of ConsumptionVersionedAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsumptionVersionedActionCopyWith<ConsumptionVersionedAction> get copyWith => _$ConsumptionVersionedActionCopyWithImpl<ConsumptionVersionedAction>(this as ConsumptionVersionedAction, _$identity);

  /// Serializes this ConsumptionVersionedAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConsumptionVersionedAction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsumptionVersionedAction&&(identical(other.rowVersion, _this.rowVersion) || other.rowVersion == _this.rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConsumptionVersionedAction;
  return Object.hash(runtimeType,_this.rowVersion);
}

@override
String toString() {
  final _this = this as ConsumptionVersionedAction;
  return 'ConsumptionVersionedAction(rowVersion: ${_this.rowVersion})';
}


}

/// @nodoc
abstract mixin class $ConsumptionVersionedActionCopyWith<$Res>  {
  factory $ConsumptionVersionedActionCopyWith(ConsumptionVersionedAction value, $Res Function(ConsumptionVersionedAction) _then) = _$ConsumptionVersionedActionCopyWithImpl;
@useResult
$Res call({
 int rowVersion
});




}
/// @nodoc
class _$ConsumptionVersionedActionCopyWithImpl<$Res>
    implements $ConsumptionVersionedActionCopyWith<$Res> {
  _$ConsumptionVersionedActionCopyWithImpl(this._self, this._then);

  final ConsumptionVersionedAction _self;
  final $Res Function(ConsumptionVersionedAction) _then;

/// Create a copy of ConsumptionVersionedAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowVersion = null,}) {
  return _then(ConsumptionVersionedAction(
rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsumptionVersionedAction].
extension ConsumptionVersionedActionPatterns on ConsumptionVersionedAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsumptionVersionedAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsumptionVersionedAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsumptionVersionedAction value)  $default,){
final _that = this;
switch (_that) {
case _ConsumptionVersionedAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsumptionVersionedAction value)?  $default,){
final _that = this;
switch (_that) {
case _ConsumptionVersionedAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rowVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsumptionVersionedAction() when $default != null:
return $default(_that.rowVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rowVersion)  $default,) {final _that = this;
switch (_that) {
case _ConsumptionVersionedAction():
return $default(_that.rowVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rowVersion)?  $default,) {final _that = this;
switch (_that) {
case _ConsumptionVersionedAction() when $default != null:
return $default(_that.rowVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConsumptionVersionedAction implements ConsumptionVersionedAction {
  const _ConsumptionVersionedAction({required this.rowVersion});
  factory _ConsumptionVersionedAction.fromJson(Map<String, dynamic> json) => _$ConsumptionVersionedActionFromJson(json);

@override final  int rowVersion;

/// Create a copy of ConsumptionVersionedAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsumptionVersionedActionCopyWith<_ConsumptionVersionedAction> get copyWith => __$ConsumptionVersionedActionCopyWithImpl<_ConsumptionVersionedAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsumptionVersionedActionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsumptionVersionedAction&&(identical(other.rowVersion, rowVersion) || other.rowVersion == rowVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rowVersion);
}

@override
String toString() {
    return 'ConsumptionVersionedAction(rowVersion: $rowVersion)';
}


}

/// @nodoc
abstract mixin class _$ConsumptionVersionedActionCopyWith<$Res> implements $ConsumptionVersionedActionCopyWith<$Res> {
  factory _$ConsumptionVersionedActionCopyWith(_ConsumptionVersionedAction value, $Res Function(_ConsumptionVersionedAction) _then) = __$ConsumptionVersionedActionCopyWithImpl;
@override @useResult
$Res call({
 int rowVersion
});




}
/// @nodoc
class __$ConsumptionVersionedActionCopyWithImpl<$Res>
    implements _$ConsumptionVersionedActionCopyWith<$Res> {
  __$ConsumptionVersionedActionCopyWithImpl(this._self, this._then);

  final _ConsumptionVersionedAction _self;
  final $Res Function(_ConsumptionVersionedAction) _then;

/// Create a copy of ConsumptionVersionedAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowVersion = null,}) {
  return _then(_ConsumptionVersionedAction(
rowVersion: null == rowVersion ? _self.rowVersion : rowVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ReverseConsumptionRunRequest {

 int get reasonCodeId; String? get note;
/// Create a copy of ReverseConsumptionRunRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReverseConsumptionRunRequestCopyWith<ReverseConsumptionRunRequest> get copyWith => _$ReverseConsumptionRunRequestCopyWithImpl<ReverseConsumptionRunRequest>(this as ReverseConsumptionRunRequest, _$identity);

  /// Serializes this ReverseConsumptionRunRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReverseConsumptionRunRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReverseConsumptionRunRequest&&(identical(other.reasonCodeId, _this.reasonCodeId) || other.reasonCodeId == _this.reasonCodeId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReverseConsumptionRunRequest;
  return Object.hash(runtimeType,_this.reasonCodeId,_this.note);
}

@override
String toString() {
  final _this = this as ReverseConsumptionRunRequest;
  return 'ReverseConsumptionRunRequest(reasonCodeId: ${_this.reasonCodeId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $ReverseConsumptionRunRequestCopyWith<$Res>  {
  factory $ReverseConsumptionRunRequestCopyWith(ReverseConsumptionRunRequest value, $Res Function(ReverseConsumptionRunRequest) _then) = _$ReverseConsumptionRunRequestCopyWithImpl;
@useResult
$Res call({
 int reasonCodeId, String? note
});




}
/// @nodoc
class _$ReverseConsumptionRunRequestCopyWithImpl<$Res>
    implements $ReverseConsumptionRunRequestCopyWith<$Res> {
  _$ReverseConsumptionRunRequestCopyWithImpl(this._self, this._then);

  final ReverseConsumptionRunRequest _self;
  final $Res Function(ReverseConsumptionRunRequest) _then;

/// Create a copy of ReverseConsumptionRunRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reasonCodeId = null,Object? note = freezed,}) {
  return _then(ReverseConsumptionRunRequest(
reasonCodeId: null == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReverseConsumptionRunRequest].
extension ReverseConsumptionRunRequestPatterns on ReverseConsumptionRunRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReverseConsumptionRunRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReverseConsumptionRunRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReverseConsumptionRunRequest value)  $default,){
final _that = this;
switch (_that) {
case _ReverseConsumptionRunRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReverseConsumptionRunRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ReverseConsumptionRunRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int reasonCodeId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReverseConsumptionRunRequest() when $default != null:
return $default(_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int reasonCodeId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _ReverseConsumptionRunRequest():
return $default(_that.reasonCodeId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int reasonCodeId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _ReverseConsumptionRunRequest() when $default != null:
return $default(_that.reasonCodeId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReverseConsumptionRunRequest implements ReverseConsumptionRunRequest {
  const _ReverseConsumptionRunRequest({required this.reasonCodeId, this.note});
  factory _ReverseConsumptionRunRequest.fromJson(Map<String, dynamic> json) => _$ReverseConsumptionRunRequestFromJson(json);

@override final  int reasonCodeId;
@override final  String? note;

/// Create a copy of ReverseConsumptionRunRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReverseConsumptionRunRequestCopyWith<_ReverseConsumptionRunRequest> get copyWith => __$ReverseConsumptionRunRequestCopyWithImpl<_ReverseConsumptionRunRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReverseConsumptionRunRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReverseConsumptionRunRequest&&(identical(other.reasonCodeId, reasonCodeId) || other.reasonCodeId == reasonCodeId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reasonCodeId,note);
}

@override
String toString() {
    return 'ReverseConsumptionRunRequest(reasonCodeId: $reasonCodeId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ReverseConsumptionRunRequestCopyWith<$Res> implements $ReverseConsumptionRunRequestCopyWith<$Res> {
  factory _$ReverseConsumptionRunRequestCopyWith(_ReverseConsumptionRunRequest value, $Res Function(_ReverseConsumptionRunRequest) _then) = __$ReverseConsumptionRunRequestCopyWithImpl;
@override @useResult
$Res call({
 int reasonCodeId, String? note
});




}
/// @nodoc
class __$ReverseConsumptionRunRequestCopyWithImpl<$Res>
    implements _$ReverseConsumptionRunRequestCopyWith<$Res> {
  __$ReverseConsumptionRunRequestCopyWithImpl(this._self, this._then);

  final _ReverseConsumptionRunRequest _self;
  final $Res Function(_ReverseConsumptionRunRequest) _then;

/// Create a copy of ReverseConsumptionRunRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reasonCodeId = null,Object? note = freezed,}) {
  return _then(_ReverseConsumptionRunRequest(
reasonCodeId: null == reasonCodeId ? _self.reasonCodeId : reasonCodeId // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ConsumptionVarianceLineDto {

 int get productId; int get locationId; Quantity get openingQty; Quantity get receivedQty; Quantity get theoreticalConsumedQty; Quantity get wasteQty; Quantity get expectedQty; Quantity get countedQty; Quantity get varianceQty; String? get productSku; String? get productName; String? get locationName; String? get baseUomCode; Quantity? get sampleQty;/// Signed net effect of inter-branch transfers.
 Quantity? get transferNetQty; Decimal? get variancePct;/// Bound to `master.product.view_cost`.
 Money? get varianceValue;
/// Create a copy of ConsumptionVarianceLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsumptionVarianceLineDtoCopyWith<ConsumptionVarianceLineDto> get copyWith => _$ConsumptionVarianceLineDtoCopyWithImpl<ConsumptionVarianceLineDto>(this as ConsumptionVarianceLineDto, _$identity);

  /// Serializes this ConsumptionVarianceLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConsumptionVarianceLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsumptionVarianceLineDto&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.openingQty, _this.openingQty) || other.openingQty == _this.openingQty)&&(identical(other.receivedQty, _this.receivedQty) || other.receivedQty == _this.receivedQty)&&(identical(other.theoreticalConsumedQty, _this.theoreticalConsumedQty) || other.theoreticalConsumedQty == _this.theoreticalConsumedQty)&&(identical(other.wasteQty, _this.wasteQty) || other.wasteQty == _this.wasteQty)&&(identical(other.expectedQty, _this.expectedQty) || other.expectedQty == _this.expectedQty)&&(identical(other.countedQty, _this.countedQty) || other.countedQty == _this.countedQty)&&(identical(other.varianceQty, _this.varianceQty) || other.varianceQty == _this.varianceQty)&&(identical(other.productSku, _this.productSku) || other.productSku == _this.productSku)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.locationName, _this.locationName) || other.locationName == _this.locationName)&&(identical(other.baseUomCode, _this.baseUomCode) || other.baseUomCode == _this.baseUomCode)&&(identical(other.sampleQty, _this.sampleQty) || other.sampleQty == _this.sampleQty)&&(identical(other.transferNetQty, _this.transferNetQty) || other.transferNetQty == _this.transferNetQty)&&(identical(other.variancePct, _this.variancePct) || other.variancePct == _this.variancePct)&&(identical(other.varianceValue, _this.varianceValue) || other.varianceValue == _this.varianceValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConsumptionVarianceLineDto;
  return Object.hash(runtimeType,_this.productId,_this.locationId,_this.openingQty,_this.receivedQty,_this.theoreticalConsumedQty,_this.wasteQty,_this.expectedQty,_this.countedQty,_this.varianceQty,_this.productSku,_this.productName,_this.locationName,_this.baseUomCode,_this.sampleQty,_this.transferNetQty,_this.variancePct,_this.varianceValue);
}

@override
String toString() {
  final _this = this as ConsumptionVarianceLineDto;
  return 'ConsumptionVarianceLineDto(productId: ${_this.productId}, locationId: ${_this.locationId}, openingQty: ${_this.openingQty}, receivedQty: ${_this.receivedQty}, theoreticalConsumedQty: ${_this.theoreticalConsumedQty}, wasteQty: ${_this.wasteQty}, expectedQty: ${_this.expectedQty}, countedQty: ${_this.countedQty}, varianceQty: ${_this.varianceQty}, productSku: ${_this.productSku}, productName: ${_this.productName}, locationName: ${_this.locationName}, baseUomCode: ${_this.baseUomCode}, sampleQty: ${_this.sampleQty}, transferNetQty: ${_this.transferNetQty}, variancePct: ${_this.variancePct}, varianceValue: ${_this.varianceValue})';
}


}

/// @nodoc
abstract mixin class $ConsumptionVarianceLineDtoCopyWith<$Res>  {
  factory $ConsumptionVarianceLineDtoCopyWith(ConsumptionVarianceLineDto value, $Res Function(ConsumptionVarianceLineDto) _then) = _$ConsumptionVarianceLineDtoCopyWithImpl;
@useResult
$Res call({
 int productId, int locationId, Quantity openingQty, Quantity receivedQty, Quantity theoreticalConsumedQty, Quantity wasteQty, Quantity expectedQty, Quantity countedQty, Quantity varianceQty, String? productSku, String? productName, String? locationName, String? baseUomCode, Quantity? sampleQty, Quantity? transferNetQty, Decimal? variancePct, Money? varianceValue
});




}
/// @nodoc
class _$ConsumptionVarianceLineDtoCopyWithImpl<$Res>
    implements $ConsumptionVarianceLineDtoCopyWith<$Res> {
  _$ConsumptionVarianceLineDtoCopyWithImpl(this._self, this._then);

  final ConsumptionVarianceLineDto _self;
  final $Res Function(ConsumptionVarianceLineDto) _then;

/// Create a copy of ConsumptionVarianceLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? locationId = null,Object? openingQty = null,Object? receivedQty = null,Object? theoreticalConsumedQty = null,Object? wasteQty = null,Object? expectedQty = null,Object? countedQty = null,Object? varianceQty = null,Object? productSku = freezed,Object? productName = freezed,Object? locationName = freezed,Object? baseUomCode = freezed,Object? sampleQty = freezed,Object? transferNetQty = freezed,Object? variancePct = freezed,Object? varianceValue = freezed,}) {
  return _then(ConsumptionVarianceLineDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,openingQty: null == openingQty ? _self.openingQty : openingQty // ignore: cast_nullable_to_non_nullable
as Quantity,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,theoreticalConsumedQty: null == theoreticalConsumedQty ? _self.theoreticalConsumedQty : theoreticalConsumedQty // ignore: cast_nullable_to_non_nullable
as Quantity,wasteQty: null == wasteQty ? _self.wasteQty : wasteQty // ignore: cast_nullable_to_non_nullable
as Quantity,expectedQty: null == expectedQty ? _self.expectedQty : expectedQty // ignore: cast_nullable_to_non_nullable
as Quantity,countedQty: null == countedQty ? _self.countedQty : countedQty // ignore: cast_nullable_to_non_nullable
as Quantity,varianceQty: null == varianceQty ? _self.varianceQty : varianceQty // ignore: cast_nullable_to_non_nullable
as Quantity,productSku: freezed == productSku ? _self.productSku : productSku // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,sampleQty: freezed == sampleQty ? _self.sampleQty : sampleQty // ignore: cast_nullable_to_non_nullable
as Quantity?,transferNetQty: freezed == transferNetQty ? _self.transferNetQty : transferNetQty // ignore: cast_nullable_to_non_nullable
as Quantity?,variancePct: freezed == variancePct ? _self.variancePct : variancePct // ignore: cast_nullable_to_non_nullable
as Decimal?,varianceValue: freezed == varianceValue ? _self.varianceValue : varianceValue // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsumptionVarianceLineDto].
extension ConsumptionVarianceLineDtoPatterns on ConsumptionVarianceLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsumptionVarianceLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsumptionVarianceLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsumptionVarianceLineDto value)  $default,){
final _that = this;
switch (_that) {
case _ConsumptionVarianceLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsumptionVarianceLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConsumptionVarianceLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  int locationId,  Quantity openingQty,  Quantity receivedQty,  Quantity theoreticalConsumedQty,  Quantity wasteQty,  Quantity expectedQty,  Quantity countedQty,  Quantity varianceQty,  String? productSku,  String? productName,  String? locationName,  String? baseUomCode,  Quantity? sampleQty,  Quantity? transferNetQty,  Decimal? variancePct,  Money? varianceValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsumptionVarianceLineDto() when $default != null:
return $default(_that.productId,_that.locationId,_that.openingQty,_that.receivedQty,_that.theoreticalConsumedQty,_that.wasteQty,_that.expectedQty,_that.countedQty,_that.varianceQty,_that.productSku,_that.productName,_that.locationName,_that.baseUomCode,_that.sampleQty,_that.transferNetQty,_that.variancePct,_that.varianceValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  int locationId,  Quantity openingQty,  Quantity receivedQty,  Quantity theoreticalConsumedQty,  Quantity wasteQty,  Quantity expectedQty,  Quantity countedQty,  Quantity varianceQty,  String? productSku,  String? productName,  String? locationName,  String? baseUomCode,  Quantity? sampleQty,  Quantity? transferNetQty,  Decimal? variancePct,  Money? varianceValue)  $default,) {final _that = this;
switch (_that) {
case _ConsumptionVarianceLineDto():
return $default(_that.productId,_that.locationId,_that.openingQty,_that.receivedQty,_that.theoreticalConsumedQty,_that.wasteQty,_that.expectedQty,_that.countedQty,_that.varianceQty,_that.productSku,_that.productName,_that.locationName,_that.baseUomCode,_that.sampleQty,_that.transferNetQty,_that.variancePct,_that.varianceValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  int locationId,  Quantity openingQty,  Quantity receivedQty,  Quantity theoreticalConsumedQty,  Quantity wasteQty,  Quantity expectedQty,  Quantity countedQty,  Quantity varianceQty,  String? productSku,  String? productName,  String? locationName,  String? baseUomCode,  Quantity? sampleQty,  Quantity? transferNetQty,  Decimal? variancePct,  Money? varianceValue)?  $default,) {final _that = this;
switch (_that) {
case _ConsumptionVarianceLineDto() when $default != null:
return $default(_that.productId,_that.locationId,_that.openingQty,_that.receivedQty,_that.theoreticalConsumedQty,_that.wasteQty,_that.expectedQty,_that.countedQty,_that.varianceQty,_that.productSku,_that.productName,_that.locationName,_that.baseUomCode,_that.sampleQty,_that.transferNetQty,_that.variancePct,_that.varianceValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConsumptionVarianceLineDto extends ConsumptionVarianceLineDto {
  const _ConsumptionVarianceLineDto({required this.productId, required this.locationId, required this.openingQty, required this.receivedQty, required this.theoreticalConsumedQty, required this.wasteQty, required this.expectedQty, required this.countedQty, required this.varianceQty, this.productSku, this.productName, this.locationName, this.baseUomCode, this.sampleQty, this.transferNetQty, this.variancePct, this.varianceValue}): super._();
  factory _ConsumptionVarianceLineDto.fromJson(Map<String, dynamic> json) => _$ConsumptionVarianceLineDtoFromJson(json);

@override final  int productId;
@override final  int locationId;
@override final  Quantity openingQty;
@override final  Quantity receivedQty;
@override final  Quantity theoreticalConsumedQty;
@override final  Quantity wasteQty;
@override final  Quantity expectedQty;
@override final  Quantity countedQty;
@override final  Quantity varianceQty;
@override final  String? productSku;
@override final  String? productName;
@override final  String? locationName;
@override final  String? baseUomCode;
@override final  Quantity? sampleQty;
/// Signed net effect of inter-branch transfers.
@override final  Quantity? transferNetQty;
@override final  Decimal? variancePct;
/// Bound to `master.product.view_cost`.
@override final  Money? varianceValue;

/// Create a copy of ConsumptionVarianceLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsumptionVarianceLineDtoCopyWith<_ConsumptionVarianceLineDto> get copyWith => __$ConsumptionVarianceLineDtoCopyWithImpl<_ConsumptionVarianceLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsumptionVarianceLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsumptionVarianceLineDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.openingQty, openingQty) || other.openingQty == openingQty)&&(identical(other.receivedQty, receivedQty) || other.receivedQty == receivedQty)&&(identical(other.theoreticalConsumedQty, theoreticalConsumedQty) || other.theoreticalConsumedQty == theoreticalConsumedQty)&&(identical(other.wasteQty, wasteQty) || other.wasteQty == wasteQty)&&(identical(other.expectedQty, expectedQty) || other.expectedQty == expectedQty)&&(identical(other.countedQty, countedQty) || other.countedQty == countedQty)&&(identical(other.varianceQty, varianceQty) || other.varianceQty == varianceQty)&&(identical(other.productSku, productSku) || other.productSku == productSku)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.baseUomCode, baseUomCode) || other.baseUomCode == baseUomCode)&&(identical(other.sampleQty, sampleQty) || other.sampleQty == sampleQty)&&(identical(other.transferNetQty, transferNetQty) || other.transferNetQty == transferNetQty)&&(identical(other.variancePct, variancePct) || other.variancePct == variancePct)&&(identical(other.varianceValue, varianceValue) || other.varianceValue == varianceValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productId,locationId,openingQty,receivedQty,theoreticalConsumedQty,wasteQty,expectedQty,countedQty,varianceQty,productSku,productName,locationName,baseUomCode,sampleQty,transferNetQty,variancePct,varianceValue);
}

@override
String toString() {
    return 'ConsumptionVarianceLineDto(productId: $productId, locationId: $locationId, openingQty: $openingQty, receivedQty: $receivedQty, theoreticalConsumedQty: $theoreticalConsumedQty, wasteQty: $wasteQty, expectedQty: $expectedQty, countedQty: $countedQty, varianceQty: $varianceQty, productSku: $productSku, productName: $productName, locationName: $locationName, baseUomCode: $baseUomCode, sampleQty: $sampleQty, transferNetQty: $transferNetQty, variancePct: $variancePct, varianceValue: $varianceValue)';
}


}

/// @nodoc
abstract mixin class _$ConsumptionVarianceLineDtoCopyWith<$Res> implements $ConsumptionVarianceLineDtoCopyWith<$Res> {
  factory _$ConsumptionVarianceLineDtoCopyWith(_ConsumptionVarianceLineDto value, $Res Function(_ConsumptionVarianceLineDto) _then) = __$ConsumptionVarianceLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int productId, int locationId, Quantity openingQty, Quantity receivedQty, Quantity theoreticalConsumedQty, Quantity wasteQty, Quantity expectedQty, Quantity countedQty, Quantity varianceQty, String? productSku, String? productName, String? locationName, String? baseUomCode, Quantity? sampleQty, Quantity? transferNetQty, Decimal? variancePct, Money? varianceValue
});




}
/// @nodoc
class __$ConsumptionVarianceLineDtoCopyWithImpl<$Res>
    implements _$ConsumptionVarianceLineDtoCopyWith<$Res> {
  __$ConsumptionVarianceLineDtoCopyWithImpl(this._self, this._then);

  final _ConsumptionVarianceLineDto _self;
  final $Res Function(_ConsumptionVarianceLineDto) _then;

/// Create a copy of ConsumptionVarianceLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? locationId = null,Object? openingQty = null,Object? receivedQty = null,Object? theoreticalConsumedQty = null,Object? wasteQty = null,Object? expectedQty = null,Object? countedQty = null,Object? varianceQty = null,Object? productSku = freezed,Object? productName = freezed,Object? locationName = freezed,Object? baseUomCode = freezed,Object? sampleQty = freezed,Object? transferNetQty = freezed,Object? variancePct = freezed,Object? varianceValue = freezed,}) {
  return _then(_ConsumptionVarianceLineDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,openingQty: null == openingQty ? _self.openingQty : openingQty // ignore: cast_nullable_to_non_nullable
as Quantity,receivedQty: null == receivedQty ? _self.receivedQty : receivedQty // ignore: cast_nullable_to_non_nullable
as Quantity,theoreticalConsumedQty: null == theoreticalConsumedQty ? _self.theoreticalConsumedQty : theoreticalConsumedQty // ignore: cast_nullable_to_non_nullable
as Quantity,wasteQty: null == wasteQty ? _self.wasteQty : wasteQty // ignore: cast_nullable_to_non_nullable
as Quantity,expectedQty: null == expectedQty ? _self.expectedQty : expectedQty // ignore: cast_nullable_to_non_nullable
as Quantity,countedQty: null == countedQty ? _self.countedQty : countedQty // ignore: cast_nullable_to_non_nullable
as Quantity,varianceQty: null == varianceQty ? _self.varianceQty : varianceQty // ignore: cast_nullable_to_non_nullable
as Quantity,productSku: freezed == productSku ? _self.productSku : productSku // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,sampleQty: freezed == sampleQty ? _self.sampleQty : sampleQty // ignore: cast_nullable_to_non_nullable
as Quantity?,transferNetQty: freezed == transferNetQty ? _self.transferNetQty : transferNetQty // ignore: cast_nullable_to_non_nullable
as Quantity?,variancePct: freezed == variancePct ? _self.variancePct : variancePct // ignore: cast_nullable_to_non_nullable
as Decimal?,varianceValue: freezed == varianceValue ? _self.varianceValue : varianceValue // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}


}


/// @nodoc
mixin _$ConsumptionVariancePageDto {

@DateOnlyConverter() DateTime get periodFrom;@DateOnlyConverter() DateTime get periodTo; List<ConsumptionVarianceLineDto> get items; int get page; int get size; int get total;
/// Create a copy of ConsumptionVariancePageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsumptionVariancePageDtoCopyWith<ConsumptionVariancePageDto> get copyWith => _$ConsumptionVariancePageDtoCopyWithImpl<ConsumptionVariancePageDto>(this as ConsumptionVariancePageDto, _$identity);

  /// Serializes this ConsumptionVariancePageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConsumptionVariancePageDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsumptionVariancePageDto&&(identical(other.periodFrom, _this.periodFrom) || other.periodFrom == _this.periodFrom)&&(identical(other.periodTo, _this.periodTo) || other.periodTo == _this.periodTo)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.total, _this.total) || other.total == _this.total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConsumptionVariancePageDto;
  return Object.hash(runtimeType,_this.periodFrom,_this.periodTo,const DeepCollectionEquality().hash(_this.items),_this.page,_this.size,_this.total);
}

@override
String toString() {
  final _this = this as ConsumptionVariancePageDto;
  return 'ConsumptionVariancePageDto(periodFrom: ${_this.periodFrom}, periodTo: ${_this.periodTo}, items: ${_this.items}, page: ${_this.page}, size: ${_this.size}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $ConsumptionVariancePageDtoCopyWith<$Res>  {
  factory $ConsumptionVariancePageDtoCopyWith(ConsumptionVariancePageDto value, $Res Function(ConsumptionVariancePageDto) _then) = _$ConsumptionVariancePageDtoCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime periodFrom,@DateOnlyConverter() DateTime periodTo, List<ConsumptionVarianceLineDto> items, int page, int size, int total
});




}
/// @nodoc
class _$ConsumptionVariancePageDtoCopyWithImpl<$Res>
    implements $ConsumptionVariancePageDtoCopyWith<$Res> {
  _$ConsumptionVariancePageDtoCopyWithImpl(this._self, this._then);

  final ConsumptionVariancePageDto _self;
  final $Res Function(ConsumptionVariancePageDto) _then;

/// Create a copy of ConsumptionVariancePageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodFrom = null,Object? periodTo = null,Object? items = null,Object? page = null,Object? size = null,Object? total = null,}) {
  return _then(ConsumptionVariancePageDto(
periodFrom: null == periodFrom ? _self.periodFrom : periodFrom // ignore: cast_nullable_to_non_nullable
as DateTime,periodTo: null == periodTo ? _self.periodTo : periodTo // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ConsumptionVarianceLineDto>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsumptionVariancePageDto].
extension ConsumptionVariancePageDtoPatterns on ConsumptionVariancePageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsumptionVariancePageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsumptionVariancePageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsumptionVariancePageDto value)  $default,){
final _that = this;
switch (_that) {
case _ConsumptionVariancePageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsumptionVariancePageDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConsumptionVariancePageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime periodFrom, @DateOnlyConverter()  DateTime periodTo,  List<ConsumptionVarianceLineDto> items,  int page,  int size,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsumptionVariancePageDto() when $default != null:
return $default(_that.periodFrom,_that.periodTo,_that.items,_that.page,_that.size,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime periodFrom, @DateOnlyConverter()  DateTime periodTo,  List<ConsumptionVarianceLineDto> items,  int page,  int size,  int total)  $default,) {final _that = this;
switch (_that) {
case _ConsumptionVariancePageDto():
return $default(_that.periodFrom,_that.periodTo,_that.items,_that.page,_that.size,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime periodFrom, @DateOnlyConverter()  DateTime periodTo,  List<ConsumptionVarianceLineDto> items,  int page,  int size,  int total)?  $default,) {final _that = this;
switch (_that) {
case _ConsumptionVariancePageDto() when $default != null:
return $default(_that.periodFrom,_that.periodTo,_that.items,_that.page,_that.size,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConsumptionVariancePageDto extends ConsumptionVariancePageDto {
  const _ConsumptionVariancePageDto({@DateOnlyConverter() required this.periodFrom, @DateOnlyConverter() required this.periodTo,  List<ConsumptionVarianceLineDto> items = const <ConsumptionVarianceLineDto>[], this.page = 1, this.size = 50, this.total = 0}): _items = items,super._();
  factory _ConsumptionVariancePageDto.fromJson(Map<String, dynamic> json) => _$ConsumptionVariancePageDtoFromJson(json);

@override@DateOnlyConverter() final  DateTime periodFrom;
@override@DateOnlyConverter() final  DateTime periodTo;
 final  List<ConsumptionVarianceLineDto> _items;
@override@JsonKey() List<ConsumptionVarianceLineDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int page;
@override@JsonKey() final  int size;
@override@JsonKey() final  int total;

/// Create a copy of ConsumptionVariancePageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsumptionVariancePageDtoCopyWith<_ConsumptionVariancePageDto> get copyWith => __$ConsumptionVariancePageDtoCopyWithImpl<_ConsumptionVariancePageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsumptionVariancePageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsumptionVariancePageDto&&(identical(other.periodFrom, periodFrom) || other.periodFrom == periodFrom)&&(identical(other.periodTo, periodTo) || other.periodTo == periodTo)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,periodFrom,periodTo,const DeepCollectionEquality().hash(_items),page,size,total);
}

@override
String toString() {
    return 'ConsumptionVariancePageDto(periodFrom: $periodFrom, periodTo: $periodTo, items: $items, page: $page, size: $size, total: $total)';
}


}

/// @nodoc
abstract mixin class _$ConsumptionVariancePageDtoCopyWith<$Res> implements $ConsumptionVariancePageDtoCopyWith<$Res> {
  factory _$ConsumptionVariancePageDtoCopyWith(_ConsumptionVariancePageDto value, $Res Function(_ConsumptionVariancePageDto) _then) = __$ConsumptionVariancePageDtoCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime periodFrom,@DateOnlyConverter() DateTime periodTo, List<ConsumptionVarianceLineDto> items, int page, int size, int total
});




}
/// @nodoc
class __$ConsumptionVariancePageDtoCopyWithImpl<$Res>
    implements _$ConsumptionVariancePageDtoCopyWith<$Res> {
  __$ConsumptionVariancePageDtoCopyWithImpl(this._self, this._then);

  final _ConsumptionVariancePageDto _self;
  final $Res Function(_ConsumptionVariancePageDto) _then;

/// Create a copy of ConsumptionVariancePageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodFrom = null,Object? periodTo = null,Object? items = null,Object? page = null,Object? size = null,Object? total = null,}) {
  return _then(_ConsumptionVariancePageDto(
periodFrom: null == periodFrom ? _self.periodFrom : periodFrom // ignore: cast_nullable_to_non_nullable
as DateTime,periodTo: null == periodTo ? _self.periodTo : periodTo // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ConsumptionVarianceLineDto>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PortionComplianceLineDto {

 int get menuItemId; int get productId; Quantity get portionsSold; Quantity get recipeQtyPerPortion; Quantity get actualQtyPerPortion; Decimal get compliancePct; String? get menuItemName; String? get productName; String? get baseUomCode;
/// Create a copy of PortionComplianceLineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortionComplianceLineDtoCopyWith<PortionComplianceLineDto> get copyWith => _$PortionComplianceLineDtoCopyWithImpl<PortionComplianceLineDto>(this as PortionComplianceLineDto, _$identity);

  /// Serializes this PortionComplianceLineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PortionComplianceLineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortionComplianceLineDto&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.portionsSold, _this.portionsSold) || other.portionsSold == _this.portionsSold)&&(identical(other.recipeQtyPerPortion, _this.recipeQtyPerPortion) || other.recipeQtyPerPortion == _this.recipeQtyPerPortion)&&(identical(other.actualQtyPerPortion, _this.actualQtyPerPortion) || other.actualQtyPerPortion == _this.actualQtyPerPortion)&&(identical(other.compliancePct, _this.compliancePct) || other.compliancePct == _this.compliancePct)&&(identical(other.menuItemName, _this.menuItemName) || other.menuItemName == _this.menuItemName)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.baseUomCode, _this.baseUomCode) || other.baseUomCode == _this.baseUomCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PortionComplianceLineDto;
  return Object.hash(runtimeType,_this.menuItemId,_this.productId,_this.portionsSold,_this.recipeQtyPerPortion,_this.actualQtyPerPortion,_this.compliancePct,_this.menuItemName,_this.productName,_this.baseUomCode);
}

@override
String toString() {
  final _this = this as PortionComplianceLineDto;
  return 'PortionComplianceLineDto(menuItemId: ${_this.menuItemId}, productId: ${_this.productId}, portionsSold: ${_this.portionsSold}, recipeQtyPerPortion: ${_this.recipeQtyPerPortion}, actualQtyPerPortion: ${_this.actualQtyPerPortion}, compliancePct: ${_this.compliancePct}, menuItemName: ${_this.menuItemName}, productName: ${_this.productName}, baseUomCode: ${_this.baseUomCode})';
}


}

/// @nodoc
abstract mixin class $PortionComplianceLineDtoCopyWith<$Res>  {
  factory $PortionComplianceLineDtoCopyWith(PortionComplianceLineDto value, $Res Function(PortionComplianceLineDto) _then) = _$PortionComplianceLineDtoCopyWithImpl;
@useResult
$Res call({
 int menuItemId, int productId, Quantity portionsSold, Quantity recipeQtyPerPortion, Quantity actualQtyPerPortion, Decimal compliancePct, String? menuItemName, String? productName, String? baseUomCode
});




}
/// @nodoc
class _$PortionComplianceLineDtoCopyWithImpl<$Res>
    implements $PortionComplianceLineDtoCopyWith<$Res> {
  _$PortionComplianceLineDtoCopyWithImpl(this._self, this._then);

  final PortionComplianceLineDto _self;
  final $Res Function(PortionComplianceLineDto) _then;

/// Create a copy of PortionComplianceLineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menuItemId = null,Object? productId = null,Object? portionsSold = null,Object? recipeQtyPerPortion = null,Object? actualQtyPerPortion = null,Object? compliancePct = null,Object? menuItemName = freezed,Object? productName = freezed,Object? baseUomCode = freezed,}) {
  return _then(PortionComplianceLineDto(
menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,portionsSold: null == portionsSold ? _self.portionsSold : portionsSold // ignore: cast_nullable_to_non_nullable
as Quantity,recipeQtyPerPortion: null == recipeQtyPerPortion ? _self.recipeQtyPerPortion : recipeQtyPerPortion // ignore: cast_nullable_to_non_nullable
as Quantity,actualQtyPerPortion: null == actualQtyPerPortion ? _self.actualQtyPerPortion : actualQtyPerPortion // ignore: cast_nullable_to_non_nullable
as Quantity,compliancePct: null == compliancePct ? _self.compliancePct : compliancePct // ignore: cast_nullable_to_non_nullable
as Decimal,menuItemName: freezed == menuItemName ? _self.menuItemName : menuItemName // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortionComplianceLineDto].
extension PortionComplianceLineDtoPatterns on PortionComplianceLineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortionComplianceLineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortionComplianceLineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortionComplianceLineDto value)  $default,){
final _that = this;
switch (_that) {
case _PortionComplianceLineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortionComplianceLineDto value)?  $default,){
final _that = this;
switch (_that) {
case _PortionComplianceLineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int menuItemId,  int productId,  Quantity portionsSold,  Quantity recipeQtyPerPortion,  Quantity actualQtyPerPortion,  Decimal compliancePct,  String? menuItemName,  String? productName,  String? baseUomCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortionComplianceLineDto() when $default != null:
return $default(_that.menuItemId,_that.productId,_that.portionsSold,_that.recipeQtyPerPortion,_that.actualQtyPerPortion,_that.compliancePct,_that.menuItemName,_that.productName,_that.baseUomCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int menuItemId,  int productId,  Quantity portionsSold,  Quantity recipeQtyPerPortion,  Quantity actualQtyPerPortion,  Decimal compliancePct,  String? menuItemName,  String? productName,  String? baseUomCode)  $default,) {final _that = this;
switch (_that) {
case _PortionComplianceLineDto():
return $default(_that.menuItemId,_that.productId,_that.portionsSold,_that.recipeQtyPerPortion,_that.actualQtyPerPortion,_that.compliancePct,_that.menuItemName,_that.productName,_that.baseUomCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int menuItemId,  int productId,  Quantity portionsSold,  Quantity recipeQtyPerPortion,  Quantity actualQtyPerPortion,  Decimal compliancePct,  String? menuItemName,  String? productName,  String? baseUomCode)?  $default,) {final _that = this;
switch (_that) {
case _PortionComplianceLineDto() when $default != null:
return $default(_that.menuItemId,_that.productId,_that.portionsSold,_that.recipeQtyPerPortion,_that.actualQtyPerPortion,_that.compliancePct,_that.menuItemName,_that.productName,_that.baseUomCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortionComplianceLineDto extends PortionComplianceLineDto {
  const _PortionComplianceLineDto({required this.menuItemId, required this.productId, required this.portionsSold, required this.recipeQtyPerPortion, required this.actualQtyPerPortion, required this.compliancePct, this.menuItemName, this.productName, this.baseUomCode}): super._();
  factory _PortionComplianceLineDto.fromJson(Map<String, dynamic> json) => _$PortionComplianceLineDtoFromJson(json);

@override final  int menuItemId;
@override final  int productId;
@override final  Quantity portionsSold;
@override final  Quantity recipeQtyPerPortion;
@override final  Quantity actualQtyPerPortion;
@override final  Decimal compliancePct;
@override final  String? menuItemName;
@override final  String? productName;
@override final  String? baseUomCode;

/// Create a copy of PortionComplianceLineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortionComplianceLineDtoCopyWith<_PortionComplianceLineDto> get copyWith => __$PortionComplianceLineDtoCopyWithImpl<_PortionComplianceLineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortionComplianceLineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortionComplianceLineDto&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.portionsSold, portionsSold) || other.portionsSold == portionsSold)&&(identical(other.recipeQtyPerPortion, recipeQtyPerPortion) || other.recipeQtyPerPortion == recipeQtyPerPortion)&&(identical(other.actualQtyPerPortion, actualQtyPerPortion) || other.actualQtyPerPortion == actualQtyPerPortion)&&(identical(other.compliancePct, compliancePct) || other.compliancePct == compliancePct)&&(identical(other.menuItemName, menuItemName) || other.menuItemName == menuItemName)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.baseUomCode, baseUomCode) || other.baseUomCode == baseUomCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,menuItemId,productId,portionsSold,recipeQtyPerPortion,actualQtyPerPortion,compliancePct,menuItemName,productName,baseUomCode);
}

@override
String toString() {
    return 'PortionComplianceLineDto(menuItemId: $menuItemId, productId: $productId, portionsSold: $portionsSold, recipeQtyPerPortion: $recipeQtyPerPortion, actualQtyPerPortion: $actualQtyPerPortion, compliancePct: $compliancePct, menuItemName: $menuItemName, productName: $productName, baseUomCode: $baseUomCode)';
}


}

/// @nodoc
abstract mixin class _$PortionComplianceLineDtoCopyWith<$Res> implements $PortionComplianceLineDtoCopyWith<$Res> {
  factory _$PortionComplianceLineDtoCopyWith(_PortionComplianceLineDto value, $Res Function(_PortionComplianceLineDto) _then) = __$PortionComplianceLineDtoCopyWithImpl;
@override @useResult
$Res call({
 int menuItemId, int productId, Quantity portionsSold, Quantity recipeQtyPerPortion, Quantity actualQtyPerPortion, Decimal compliancePct, String? menuItemName, String? productName, String? baseUomCode
});




}
/// @nodoc
class __$PortionComplianceLineDtoCopyWithImpl<$Res>
    implements _$PortionComplianceLineDtoCopyWith<$Res> {
  __$PortionComplianceLineDtoCopyWithImpl(this._self, this._then);

  final _PortionComplianceLineDto _self;
  final $Res Function(_PortionComplianceLineDto) _then;

/// Create a copy of PortionComplianceLineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menuItemId = null,Object? productId = null,Object? portionsSold = null,Object? recipeQtyPerPortion = null,Object? actualQtyPerPortion = null,Object? compliancePct = null,Object? menuItemName = freezed,Object? productName = freezed,Object? baseUomCode = freezed,}) {
  return _then(_PortionComplianceLineDto(
menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,portionsSold: null == portionsSold ? _self.portionsSold : portionsSold // ignore: cast_nullable_to_non_nullable
as Quantity,recipeQtyPerPortion: null == recipeQtyPerPortion ? _self.recipeQtyPerPortion : recipeQtyPerPortion // ignore: cast_nullable_to_non_nullable
as Quantity,actualQtyPerPortion: null == actualQtyPerPortion ? _self.actualQtyPerPortion : actualQtyPerPortion // ignore: cast_nullable_to_non_nullable
as Quantity,compliancePct: null == compliancePct ? _self.compliancePct : compliancePct // ignore: cast_nullable_to_non_nullable
as Decimal,menuItemName: freezed == menuItemName ? _self.menuItemName : menuItemName // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,baseUomCode: freezed == baseUomCode ? _self.baseUomCode : baseUomCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
