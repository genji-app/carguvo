// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_history_dto.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$PlayHistoryResponseDto {

 int get count; List<PlayHistoryItemDto> get items;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayHistoryResponseDtoCopyWith<PlayHistoryResponseDto> get copyWith => _$PlayHistoryResponseDtoCopyWithImpl<PlayHistoryResponseDto>(this as PlayHistoryResponseDto, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayHistoryResponseDto&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'PlayHistoryResponseDto(count: $count, items: $items)';
}

}

abstract mixin class $PlayHistoryResponseDtoCopyWith<$Res>  {
  factory $PlayHistoryResponseDtoCopyWith(PlayHistoryResponseDto value, $Res Function(PlayHistoryResponseDto) _then) = _$PlayHistoryResponseDtoCopyWithImpl;
@useResult
$Res call({
 int count, List<PlayHistoryItemDto> items
});

}
class _$PlayHistoryResponseDtoCopyWithImpl<$Res>
    implements $PlayHistoryResponseDtoCopyWith<$Res> {
  _$PlayHistoryResponseDtoCopyWithImpl(this._self, this._then);

  final PlayHistoryResponseDto _self;
  final $Res Function(PlayHistoryResponseDto) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? items = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PlayHistoryItemDto>,
  ));
}

}

extension PlayHistoryResponseDtoPatterns on PlayHistoryResponseDto {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayHistoryResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayHistoryResponseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayHistoryResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _PlayHistoryResponseDto():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayHistoryResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlayHistoryResponseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  List<PlayHistoryItemDto> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayHistoryResponseDto() when $default != null:
return $default(_that.count,_that.items);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  List<PlayHistoryItemDto> items)  $default,) {final _that = this;
switch (_that) {
case _PlayHistoryResponseDto():
return $default(_that.count,_that.items);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  List<PlayHistoryItemDto> items)?  $default,) {final _that = this;
switch (_that) {
case _PlayHistoryResponseDto() when $default != null:
return $default(_that.count,_that.items);case _:
  return null;

}
}

}

@JsonSerializable()

class _PlayHistoryResponseDto implements PlayHistoryResponseDto {
  const _PlayHistoryResponseDto({this.count = 0, final  List<PlayHistoryItemDto> items = const []}): _items = items;
  factory _PlayHistoryResponseDto.fromJson(Map<String, dynamic> json) => _$PlayHistoryResponseDtoFromJson(json);

@override@JsonKey() final  int count;
 final  List<PlayHistoryItemDto> _items;
@override@JsonKey() List<PlayHistoryItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayHistoryResponseDtoCopyWith<_PlayHistoryResponseDto> get copyWith => __$PlayHistoryResponseDtoCopyWithImpl<_PlayHistoryResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayHistoryResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayHistoryResponseDto&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'PlayHistoryResponseDto(count: $count, items: $items)';
}

}

abstract mixin class _$PlayHistoryResponseDtoCopyWith<$Res> implements $PlayHistoryResponseDtoCopyWith<$Res> {
  factory _$PlayHistoryResponseDtoCopyWith(_PlayHistoryResponseDto value, $Res Function(_PlayHistoryResponseDto) _then) = __$PlayHistoryResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 int count, List<PlayHistoryItemDto> items
});

}
class __$PlayHistoryResponseDtoCopyWithImpl<$Res>
    implements _$PlayHistoryResponseDtoCopyWith<$Res> {
  __$PlayHistoryResponseDtoCopyWithImpl(this._self, this._then);

  final _PlayHistoryResponseDto _self;
  final $Res Function(_PlayHistoryResponseDto) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? items = null,}) {
  return _then(_PlayHistoryResponseDto(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PlayHistoryItemDto>,
  ));
}

}

mixin _$PlayHistoryItemDto {

 int get activityType; int get createdTime; String get serviceName; String get description; num get closingValue; num get exchangeValue;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayHistoryItemDtoCopyWith<PlayHistoryItemDto> get copyWith => _$PlayHistoryItemDtoCopyWithImpl<PlayHistoryItemDto>(this as PlayHistoryItemDto, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayHistoryItemDto&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.createdTime, createdTime) || other.createdTime == createdTime)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.description, description) || other.description == description)&&(identical(other.closingValue, closingValue) || other.closingValue == closingValue)&&(identical(other.exchangeValue, exchangeValue) || other.exchangeValue == exchangeValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activityType,createdTime,serviceName,description,closingValue,exchangeValue);

@override
String toString() {
  return 'PlayHistoryItemDto(activityType: $activityType, createdTime: $createdTime, serviceName: $serviceName, description: $description, closingValue: $closingValue, exchangeValue: $exchangeValue)';
}

}

abstract mixin class $PlayHistoryItemDtoCopyWith<$Res>  {
  factory $PlayHistoryItemDtoCopyWith(PlayHistoryItemDto value, $Res Function(PlayHistoryItemDto) _then) = _$PlayHistoryItemDtoCopyWithImpl;
@useResult
$Res call({
 int activityType, int createdTime, String serviceName, String description, num closingValue, num exchangeValue
});

}
class _$PlayHistoryItemDtoCopyWithImpl<$Res>
    implements $PlayHistoryItemDtoCopyWith<$Res> {
  _$PlayHistoryItemDtoCopyWithImpl(this._self, this._then);

  final PlayHistoryItemDto _self;
  final $Res Function(PlayHistoryItemDto) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? activityType = null,Object? createdTime = null,Object? serviceName = null,Object? description = null,Object? closingValue = null,Object? exchangeValue = null,}) {
  return _then(_self.copyWith(
activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as int,createdTime: null == createdTime ? _self.createdTime : createdTime // ignore: cast_nullable_to_non_nullable
as int,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,closingValue: null == closingValue ? _self.closingValue : closingValue // ignore: cast_nullable_to_non_nullable
as num,exchangeValue: null == exchangeValue ? _self.exchangeValue : exchangeValue // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}

extension PlayHistoryItemDtoPatterns on PlayHistoryItemDto {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayHistoryItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayHistoryItemDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayHistoryItemDto value)  $default,){
final _that = this;
switch (_that) {
case _PlayHistoryItemDto():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayHistoryItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlayHistoryItemDto() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int activityType,  int createdTime,  String serviceName,  String description,  num closingValue,  num exchangeValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayHistoryItemDto() when $default != null:
return $default(_that.activityType,_that.createdTime,_that.serviceName,_that.description,_that.closingValue,_that.exchangeValue);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int activityType,  int createdTime,  String serviceName,  String description,  num closingValue,  num exchangeValue)  $default,) {final _that = this;
switch (_that) {
case _PlayHistoryItemDto():
return $default(_that.activityType,_that.createdTime,_that.serviceName,_that.description,_that.closingValue,_that.exchangeValue);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int activityType,  int createdTime,  String serviceName,  String description,  num closingValue,  num exchangeValue)?  $default,) {final _that = this;
switch (_that) {
case _PlayHistoryItemDto() when $default != null:
return $default(_that.activityType,_that.createdTime,_that.serviceName,_that.description,_that.closingValue,_that.exchangeValue);case _:
  return null;

}
}

}

@JsonSerializable()

class _PlayHistoryItemDto implements PlayHistoryItemDto {
  const _PlayHistoryItemDto({this.activityType = 0, this.createdTime = 0, this.serviceName = '', this.description = '', this.closingValue = 0.0, this.exchangeValue = 0.0});
  factory _PlayHistoryItemDto.fromJson(Map<String, dynamic> json) => _$PlayHistoryItemDtoFromJson(json);

@override@JsonKey() final  int activityType;
@override@JsonKey() final  int createdTime;
@override@JsonKey() final  String serviceName;
@override@JsonKey() final  String description;
@override@JsonKey() final  num closingValue;
@override@JsonKey() final  num exchangeValue;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayHistoryItemDtoCopyWith<_PlayHistoryItemDto> get copyWith => __$PlayHistoryItemDtoCopyWithImpl<_PlayHistoryItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayHistoryItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayHistoryItemDto&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.createdTime, createdTime) || other.createdTime == createdTime)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.description, description) || other.description == description)&&(identical(other.closingValue, closingValue) || other.closingValue == closingValue)&&(identical(other.exchangeValue, exchangeValue) || other.exchangeValue == exchangeValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activityType,createdTime,serviceName,description,closingValue,exchangeValue);

@override
String toString() {
  return 'PlayHistoryItemDto(activityType: $activityType, createdTime: $createdTime, serviceName: $serviceName, description: $description, closingValue: $closingValue, exchangeValue: $exchangeValue)';
}

}

abstract mixin class _$PlayHistoryItemDtoCopyWith<$Res> implements $PlayHistoryItemDtoCopyWith<$Res> {
  factory _$PlayHistoryItemDtoCopyWith(_PlayHistoryItemDto value, $Res Function(_PlayHistoryItemDto) _then) = __$PlayHistoryItemDtoCopyWithImpl;
@override @useResult
$Res call({
 int activityType, int createdTime, String serviceName, String description, num closingValue, num exchangeValue
});

}
class __$PlayHistoryItemDtoCopyWithImpl<$Res>
    implements _$PlayHistoryItemDtoCopyWith<$Res> {
  __$PlayHistoryItemDtoCopyWithImpl(this._self, this._then);

  final _PlayHistoryItemDto _self;
  final $Res Function(_PlayHistoryItemDto) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? activityType = null,Object? createdTime = null,Object? serviceName = null,Object? description = null,Object? closingValue = null,Object? exchangeValue = null,}) {
  return _then(_PlayHistoryItemDto(
activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as int,createdTime: null == createdTime ? _self.createdTime : createdTime // ignore: cast_nullable_to_non_nullable
as int,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,closingValue: null == closingValue ? _self.closingValue : closingValue // ignore: cast_nullable_to_non_nullable
as num,exchangeValue: null == exchangeValue ? _self.exchangeValue : exchangeValue // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}

// dart format on
