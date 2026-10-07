// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_withdraw_dto.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$CardWithdrawResponseDto {

@JsonKey(name: 'id') String? get id;@JsonKey(name: 'requestTime') int? get requestTime;@JsonKey(name: 'responseTime') int? get responseTime;@JsonKey(name: 'status') int? get status;@JsonKey(name: 'description') String? get description;@JsonKey(name: 'displayName') String? get displayName;@JsonKey(name: 'userId') int? get userId;@JsonKey(name: 'result') CardWithdrawResultDto? get result;@JsonKey(name: 'item') CardWithdrawItemDto? get item;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardWithdrawResponseDtoCopyWith<CardWithdrawResponseDto> get copyWith => _$CardWithdrawResponseDtoCopyWithImpl<CardWithdrawResponseDto>(this as CardWithdrawResponseDto, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardWithdrawResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.requestTime, requestTime) || other.requestTime == requestTime)&&(identical(other.responseTime, responseTime) || other.responseTime == responseTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.result, result) || other.result == result)&&(identical(other.item, item) || other.item == item));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestTime,responseTime,status,description,displayName,userId,result,item);

@override
String toString() {
  return 'CardWithdrawResponseDto(id: $id, requestTime: $requestTime, responseTime: $responseTime, status: $status, description: $description, displayName: $displayName, userId: $userId, result: $result, item: $item)';
}

}

abstract mixin class $CardWithdrawResponseDtoCopyWith<$Res>  {
  factory $CardWithdrawResponseDtoCopyWith(CardWithdrawResponseDto value, $Res Function(CardWithdrawResponseDto) _then) = _$CardWithdrawResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String? id,@JsonKey(name: 'requestTime') int? requestTime,@JsonKey(name: 'responseTime') int? responseTime,@JsonKey(name: 'status') int? status,@JsonKey(name: 'description') String? description,@JsonKey(name: 'displayName') String? displayName,@JsonKey(name: 'userId') int? userId,@JsonKey(name: 'result') CardWithdrawResultDto? result,@JsonKey(name: 'item') CardWithdrawItemDto? item
});

$CardWithdrawResultDtoCopyWith<$Res>? get result;$CardWithdrawItemDtoCopyWith<$Res>? get item;

}
class _$CardWithdrawResponseDtoCopyWithImpl<$Res>
    implements $CardWithdrawResponseDtoCopyWith<$Res> {
  _$CardWithdrawResponseDtoCopyWithImpl(this._self, this._then);

  final CardWithdrawResponseDto _self;
  final $Res Function(CardWithdrawResponseDto) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? requestTime = freezed,Object? responseTime = freezed,Object? status = freezed,Object? description = freezed,Object? displayName = freezed,Object? userId = freezed,Object? result = freezed,Object? item = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,requestTime: freezed == requestTime ? _self.requestTime : requestTime // ignore: cast_nullable_to_non_nullable
as int?,responseTime: freezed == responseTime ? _self.responseTime : responseTime // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as CardWithdrawResultDto?,item: freezed == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as CardWithdrawItemDto?,
  ));
}
@override
@pragma('vm:prefer-inline')
$CardWithdrawResultDtoCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $CardWithdrawResultDtoCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
@override
@pragma('vm:prefer-inline')
$CardWithdrawItemDtoCopyWith<$Res>? get item {
    if (_self.item == null) {
    return null;
  }

  return $CardWithdrawItemDtoCopyWith<$Res>(_self.item!, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}

extension CardWithdrawResponseDtoPatterns on CardWithdrawResponseDto {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardWithdrawResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardWithdrawResponseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardWithdrawResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _CardWithdrawResponseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardWithdrawResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _CardWithdrawResponseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String? id, @JsonKey(name: 'requestTime')  int? requestTime, @JsonKey(name: 'responseTime')  int? responseTime, @JsonKey(name: 'status')  int? status, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'displayName')  String? displayName, @JsonKey(name: 'userId')  int? userId, @JsonKey(name: 'result')  CardWithdrawResultDto? result, @JsonKey(name: 'item')  CardWithdrawItemDto? item)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardWithdrawResponseDto() when $default != null:
return $default(_that.id,_that.requestTime,_that.responseTime,_that.status,_that.description,_that.displayName,_that.userId,_that.result,_that.item);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String? id, @JsonKey(name: 'requestTime')  int? requestTime, @JsonKey(name: 'responseTime')  int? responseTime, @JsonKey(name: 'status')  int? status, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'displayName')  String? displayName, @JsonKey(name: 'userId')  int? userId, @JsonKey(name: 'result')  CardWithdrawResultDto? result, @JsonKey(name: 'item')  CardWithdrawItemDto? item)  $default,) {final _that = this;
switch (_that) {
case _CardWithdrawResponseDto():
return $default(_that.id,_that.requestTime,_that.responseTime,_that.status,_that.description,_that.displayName,_that.userId,_that.result,_that.item);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String? id, @JsonKey(name: 'requestTime')  int? requestTime, @JsonKey(name: 'responseTime')  int? responseTime, @JsonKey(name: 'status')  int? status, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'displayName')  String? displayName, @JsonKey(name: 'userId')  int? userId, @JsonKey(name: 'result')  CardWithdrawResultDto? result, @JsonKey(name: 'item')  CardWithdrawItemDto? item)?  $default,) {final _that = this;
switch (_that) {
case _CardWithdrawResponseDto() when $default != null:
return $default(_that.id,_that.requestTime,_that.responseTime,_that.status,_that.description,_that.displayName,_that.userId,_that.result,_that.item);case _:
  return null;

}
}

}

@JsonSerializable()

class _CardWithdrawResponseDto implements CardWithdrawResponseDto {
  const _CardWithdrawResponseDto({@JsonKey(name: 'id') this.id, @JsonKey(name: 'requestTime') this.requestTime, @JsonKey(name: 'responseTime') this.responseTime, @JsonKey(name: 'status') this.status, @JsonKey(name: 'description') this.description, @JsonKey(name: 'displayName') this.displayName, @JsonKey(name: 'userId') this.userId, @JsonKey(name: 'result') this.result, @JsonKey(name: 'item') this.item});
  factory _CardWithdrawResponseDto.fromJson(Map<String, dynamic> json) => _$CardWithdrawResponseDtoFromJson(json);

@override@JsonKey(name: 'id') final  String? id;
@override@JsonKey(name: 'requestTime') final  int? requestTime;
@override@JsonKey(name: 'responseTime') final  int? responseTime;
@override@JsonKey(name: 'status') final  int? status;
@override@JsonKey(name: 'description') final  String? description;
@override@JsonKey(name: 'displayName') final  String? displayName;
@override@JsonKey(name: 'userId') final  int? userId;
@override@JsonKey(name: 'result') final  CardWithdrawResultDto? result;
@override@JsonKey(name: 'item') final  CardWithdrawItemDto? item;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardWithdrawResponseDtoCopyWith<_CardWithdrawResponseDto> get copyWith => __$CardWithdrawResponseDtoCopyWithImpl<_CardWithdrawResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardWithdrawResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardWithdrawResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.requestTime, requestTime) || other.requestTime == requestTime)&&(identical(other.responseTime, responseTime) || other.responseTime == responseTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.result, result) || other.result == result)&&(identical(other.item, item) || other.item == item));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestTime,responseTime,status,description,displayName,userId,result,item);

@override
String toString() {
  return 'CardWithdrawResponseDto(id: $id, requestTime: $requestTime, responseTime: $responseTime, status: $status, description: $description, displayName: $displayName, userId: $userId, result: $result, item: $item)';
}

}

abstract mixin class _$CardWithdrawResponseDtoCopyWith<$Res> implements $CardWithdrawResponseDtoCopyWith<$Res> {
  factory _$CardWithdrawResponseDtoCopyWith(_CardWithdrawResponseDto value, $Res Function(_CardWithdrawResponseDto) _then) = __$CardWithdrawResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String? id,@JsonKey(name: 'requestTime') int? requestTime,@JsonKey(name: 'responseTime') int? responseTime,@JsonKey(name: 'status') int? status,@JsonKey(name: 'description') String? description,@JsonKey(name: 'displayName') String? displayName,@JsonKey(name: 'userId') int? userId,@JsonKey(name: 'result') CardWithdrawResultDto? result,@JsonKey(name: 'item') CardWithdrawItemDto? item
});

@override $CardWithdrawResultDtoCopyWith<$Res>? get result;@override $CardWithdrawItemDtoCopyWith<$Res>? get item;

}
class __$CardWithdrawResponseDtoCopyWithImpl<$Res>
    implements _$CardWithdrawResponseDtoCopyWith<$Res> {
  __$CardWithdrawResponseDtoCopyWithImpl(this._self, this._then);

  final _CardWithdrawResponseDto _self;
  final $Res Function(_CardWithdrawResponseDto) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? requestTime = freezed,Object? responseTime = freezed,Object? status = freezed,Object? description = freezed,Object? displayName = freezed,Object? userId = freezed,Object? result = freezed,Object? item = freezed,}) {
  return _then(_CardWithdrawResponseDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,requestTime: freezed == requestTime ? _self.requestTime : requestTime // ignore: cast_nullable_to_non_nullable
as int?,responseTime: freezed == responseTime ? _self.responseTime : responseTime // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as CardWithdrawResultDto?,item: freezed == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as CardWithdrawItemDto?,
  ));
}

@override
@pragma('vm:prefer-inline')
$CardWithdrawResultDtoCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $CardWithdrawResultDtoCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
@override
@pragma('vm:prefer-inline')
$CardWithdrawItemDtoCopyWith<$Res>? get item {
    if (_self.item == null) {
    return null;
  }

  return $CardWithdrawItemDtoCopyWith<$Res>(_self.item!, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}

mixin _$CardWithdrawResultDto {

@JsonKey(name: 'code') dynamic get code;@JsonKey(name: 'serial') dynamic get serial;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardWithdrawResultDtoCopyWith<CardWithdrawResultDto> get copyWith => _$CardWithdrawResultDtoCopyWithImpl<CardWithdrawResultDto>(this as CardWithdrawResultDto, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardWithdrawResultDto&&const DeepCollectionEquality().equals(other.code, code)&&const DeepCollectionEquality().equals(other.serial, serial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(code),const DeepCollectionEquality().hash(serial));

@override
String toString() {
  return 'CardWithdrawResultDto(code: $code, serial: $serial)';
}

}

abstract mixin class $CardWithdrawResultDtoCopyWith<$Res>  {
  factory $CardWithdrawResultDtoCopyWith(CardWithdrawResultDto value, $Res Function(CardWithdrawResultDto) _then) = _$CardWithdrawResultDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'code') dynamic code,@JsonKey(name: 'serial') dynamic serial
});

}
class _$CardWithdrawResultDtoCopyWithImpl<$Res>
    implements $CardWithdrawResultDtoCopyWith<$Res> {
  _$CardWithdrawResultDtoCopyWithImpl(this._self, this._then);

  final CardWithdrawResultDto _self;
  final $Res Function(CardWithdrawResultDto) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? serial = freezed,}) {
  return _then(_self.copyWith(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as dynamic,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}

extension CardWithdrawResultDtoPatterns on CardWithdrawResultDto {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardWithdrawResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardWithdrawResultDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardWithdrawResultDto value)  $default,){
final _that = this;
switch (_that) {
case _CardWithdrawResultDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardWithdrawResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _CardWithdrawResultDto() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  dynamic code, @JsonKey(name: 'serial')  dynamic serial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardWithdrawResultDto() when $default != null:
return $default(_that.code,_that.serial);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  dynamic code, @JsonKey(name: 'serial')  dynamic serial)  $default,) {final _that = this;
switch (_that) {
case _CardWithdrawResultDto():
return $default(_that.code,_that.serial);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'code')  dynamic code, @JsonKey(name: 'serial')  dynamic serial)?  $default,) {final _that = this;
switch (_that) {
case _CardWithdrawResultDto() when $default != null:
return $default(_that.code,_that.serial);case _:
  return null;

}
}

}

@JsonSerializable()

class _CardWithdrawResultDto implements CardWithdrawResultDto {
  const _CardWithdrawResultDto({@JsonKey(name: 'code') this.code, @JsonKey(name: 'serial') this.serial});
  factory _CardWithdrawResultDto.fromJson(Map<String, dynamic> json) => _$CardWithdrawResultDtoFromJson(json);

@override@JsonKey(name: 'code') final  dynamic code;
@override@JsonKey(name: 'serial') final  dynamic serial;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardWithdrawResultDtoCopyWith<_CardWithdrawResultDto> get copyWith => __$CardWithdrawResultDtoCopyWithImpl<_CardWithdrawResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardWithdrawResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardWithdrawResultDto&&const DeepCollectionEquality().equals(other.code, code)&&const DeepCollectionEquality().equals(other.serial, serial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(code),const DeepCollectionEquality().hash(serial));

@override
String toString() {
  return 'CardWithdrawResultDto(code: $code, serial: $serial)';
}

}

abstract mixin class _$CardWithdrawResultDtoCopyWith<$Res> implements $CardWithdrawResultDtoCopyWith<$Res> {
  factory _$CardWithdrawResultDtoCopyWith(_CardWithdrawResultDto value, $Res Function(_CardWithdrawResultDto) _then) = __$CardWithdrawResultDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'code') dynamic code,@JsonKey(name: 'serial') dynamic serial
});

}
class __$CardWithdrawResultDtoCopyWithImpl<$Res>
    implements _$CardWithdrawResultDtoCopyWith<$Res> {
  __$CardWithdrawResultDtoCopyWithImpl(this._self, this._then);

  final _CardWithdrawResultDto _self;
  final $Res Function(_CardWithdrawResultDto) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? serial = freezed,}) {
  return _then(_CardWithdrawResultDto(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as dynamic,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}

mixin _$CardWithdrawItemDto {

@JsonKey(name: 'amount') num? get amount;@JsonKey(name: 'price') num? get price;@JsonKey(name: 'displayName') String? get displayName;@JsonKey(name: 'name') String? get name;@JsonKey(name: 'image') String? get image;@JsonKey(name: 'brand') String? get brand;@JsonKey(name: 'active') bool? get active;@JsonKey(name: 'type') int? get type;@JsonKey(name: 'telcoId') int? get telcoId;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardWithdrawItemDtoCopyWith<CardWithdrawItemDto> get copyWith => _$CardWithdrawItemDtoCopyWithImpl<CardWithdrawItemDto>(this as CardWithdrawItemDto, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardWithdrawItemDto&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.price, price) || other.price == price)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.name, name) || other.name == name)&&(identical(other.image, image) || other.image == image)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.active, active) || other.active == active)&&(identical(other.type, type) || other.type == type)&&(identical(other.telcoId, telcoId) || other.telcoId == telcoId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,price,displayName,name,image,brand,active,type,telcoId);

@override
String toString() {
  return 'CardWithdrawItemDto(amount: $amount, price: $price, displayName: $displayName, name: $name, image: $image, brand: $brand, active: $active, type: $type, telcoId: $telcoId)';
}

}

abstract mixin class $CardWithdrawItemDtoCopyWith<$Res>  {
  factory $CardWithdrawItemDtoCopyWith(CardWithdrawItemDto value, $Res Function(CardWithdrawItemDto) _then) = _$CardWithdrawItemDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'amount') num? amount,@JsonKey(name: 'price') num? price,@JsonKey(name: 'displayName') String? displayName,@JsonKey(name: 'name') String? name,@JsonKey(name: 'image') String? image,@JsonKey(name: 'brand') String? brand,@JsonKey(name: 'active') bool? active,@JsonKey(name: 'type') int? type,@JsonKey(name: 'telcoId') int? telcoId
});

}
class _$CardWithdrawItemDtoCopyWithImpl<$Res>
    implements $CardWithdrawItemDtoCopyWith<$Res> {
  _$CardWithdrawItemDtoCopyWithImpl(this._self, this._then);

  final CardWithdrawItemDto _self;
  final $Res Function(CardWithdrawItemDto) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? amount = freezed,Object? price = freezed,Object? displayName = freezed,Object? name = freezed,Object? image = freezed,Object? brand = freezed,Object? active = freezed,Object? type = freezed,Object? telcoId = freezed,}) {
  return _then(_self.copyWith(
amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as num?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,telcoId: freezed == telcoId ? _self.telcoId : telcoId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

extension CardWithdrawItemDtoPatterns on CardWithdrawItemDto {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardWithdrawItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardWithdrawItemDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardWithdrawItemDto value)  $default,){
final _that = this;
switch (_that) {
case _CardWithdrawItemDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardWithdrawItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _CardWithdrawItemDto() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'amount')  num? amount, @JsonKey(name: 'price')  num? price, @JsonKey(name: 'displayName')  String? displayName, @JsonKey(name: 'name')  String? name, @JsonKey(name: 'image')  String? image, @JsonKey(name: 'brand')  String? brand, @JsonKey(name: 'active')  bool? active, @JsonKey(name: 'type')  int? type, @JsonKey(name: 'telcoId')  int? telcoId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardWithdrawItemDto() when $default != null:
return $default(_that.amount,_that.price,_that.displayName,_that.name,_that.image,_that.brand,_that.active,_that.type,_that.telcoId);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'amount')  num? amount, @JsonKey(name: 'price')  num? price, @JsonKey(name: 'displayName')  String? displayName, @JsonKey(name: 'name')  String? name, @JsonKey(name: 'image')  String? image, @JsonKey(name: 'brand')  String? brand, @JsonKey(name: 'active')  bool? active, @JsonKey(name: 'type')  int? type, @JsonKey(name: 'telcoId')  int? telcoId)  $default,) {final _that = this;
switch (_that) {
case _CardWithdrawItemDto():
return $default(_that.amount,_that.price,_that.displayName,_that.name,_that.image,_that.brand,_that.active,_that.type,_that.telcoId);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'amount')  num? amount, @JsonKey(name: 'price')  num? price, @JsonKey(name: 'displayName')  String? displayName, @JsonKey(name: 'name')  String? name, @JsonKey(name: 'image')  String? image, @JsonKey(name: 'brand')  String? brand, @JsonKey(name: 'active')  bool? active, @JsonKey(name: 'type')  int? type, @JsonKey(name: 'telcoId')  int? telcoId)?  $default,) {final _that = this;
switch (_that) {
case _CardWithdrawItemDto() when $default != null:
return $default(_that.amount,_that.price,_that.displayName,_that.name,_that.image,_that.brand,_that.active,_that.type,_that.telcoId);case _:
  return null;

}
}

}

@JsonSerializable()

class _CardWithdrawItemDto implements CardWithdrawItemDto {
  const _CardWithdrawItemDto({@JsonKey(name: 'amount') this.amount, @JsonKey(name: 'price') this.price, @JsonKey(name: 'displayName') this.displayName, @JsonKey(name: 'name') this.name, @JsonKey(name: 'image') this.image, @JsonKey(name: 'brand') this.brand, @JsonKey(name: 'active') this.active, @JsonKey(name: 'type') this.type, @JsonKey(name: 'telcoId') this.telcoId});
  factory _CardWithdrawItemDto.fromJson(Map<String, dynamic> json) => _$CardWithdrawItemDtoFromJson(json);

@override@JsonKey(name: 'amount') final  num? amount;
@override@JsonKey(name: 'price') final  num? price;
@override@JsonKey(name: 'displayName') final  String? displayName;
@override@JsonKey(name: 'name') final  String? name;
@override@JsonKey(name: 'image') final  String? image;
@override@JsonKey(name: 'brand') final  String? brand;
@override@JsonKey(name: 'active') final  bool? active;
@override@JsonKey(name: 'type') final  int? type;
@override@JsonKey(name: 'telcoId') final  int? telcoId;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardWithdrawItemDtoCopyWith<_CardWithdrawItemDto> get copyWith => __$CardWithdrawItemDtoCopyWithImpl<_CardWithdrawItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardWithdrawItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardWithdrawItemDto&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.price, price) || other.price == price)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.name, name) || other.name == name)&&(identical(other.image, image) || other.image == image)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.active, active) || other.active == active)&&(identical(other.type, type) || other.type == type)&&(identical(other.telcoId, telcoId) || other.telcoId == telcoId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,price,displayName,name,image,brand,active,type,telcoId);

@override
String toString() {
  return 'CardWithdrawItemDto(amount: $amount, price: $price, displayName: $displayName, name: $name, image: $image, brand: $brand, active: $active, type: $type, telcoId: $telcoId)';
}

}

abstract mixin class _$CardWithdrawItemDtoCopyWith<$Res> implements $CardWithdrawItemDtoCopyWith<$Res> {
  factory _$CardWithdrawItemDtoCopyWith(_CardWithdrawItemDto value, $Res Function(_CardWithdrawItemDto) _then) = __$CardWithdrawItemDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'amount') num? amount,@JsonKey(name: 'price') num? price,@JsonKey(name: 'displayName') String? displayName,@JsonKey(name: 'name') String? name,@JsonKey(name: 'image') String? image,@JsonKey(name: 'brand') String? brand,@JsonKey(name: 'active') bool? active,@JsonKey(name: 'type') int? type,@JsonKey(name: 'telcoId') int? telcoId
});

}
class __$CardWithdrawItemDtoCopyWithImpl<$Res>
    implements _$CardWithdrawItemDtoCopyWith<$Res> {
  __$CardWithdrawItemDtoCopyWithImpl(this._self, this._then);

  final _CardWithdrawItemDto _self;
  final $Res Function(_CardWithdrawItemDto) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? amount = freezed,Object? price = freezed,Object? displayName = freezed,Object? name = freezed,Object? image = freezed,Object? brand = freezed,Object? active = freezed,Object? type = freezed,Object? telcoId = freezed,}) {
  return _then(_CardWithdrawItemDto(
amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as num?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,telcoId: freezed == telcoId ? _self.telcoId : telcoId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

// dart format on
