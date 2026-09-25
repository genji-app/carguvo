// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_deposit_dto.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$CardDepositResponseDto {

@JsonKey(name: 'amount') num? get amount;@JsonKey(name: 'code') String? get code;@JsonKey(name: 'serial') String? get serial;@JsonKey(name: 'network') String? get network;@JsonKey(name: 'createdTime') int? get createdTime;@JsonKey(name: 'statusMessage') String? get statusMessage;@JsonKey(name: 'receivedAmount') num? get receivedAmount;@JsonKey(name: 'slipId') dynamic get slipId;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardDepositResponseDtoCopyWith<CardDepositResponseDto> get copyWith => _$CardDepositResponseDtoCopyWithImpl<CardDepositResponseDto>(this as CardDepositResponseDto, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardDepositResponseDto&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.code, code) || other.code == code)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.network, network) || other.network == network)&&(identical(other.createdTime, createdTime) || other.createdTime == createdTime)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage)&&(identical(other.receivedAmount, receivedAmount) || other.receivedAmount == receivedAmount)&&const DeepCollectionEquality().equals(other.slipId, slipId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,code,serial,network,createdTime,statusMessage,receivedAmount,const DeepCollectionEquality().hash(slipId));

@override
String toString() {
  return 'CardDepositResponseDto(amount: $amount, code: $code, serial: $serial, network: $network, createdTime: $createdTime, statusMessage: $statusMessage, receivedAmount: $receivedAmount, slipId: $slipId)';
}

}

abstract mixin class $CardDepositResponseDtoCopyWith<$Res>  {
  factory $CardDepositResponseDtoCopyWith(CardDepositResponseDto value, $Res Function(CardDepositResponseDto) _then) = _$CardDepositResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'amount') num? amount,@JsonKey(name: 'code') String? code,@JsonKey(name: 'serial') String? serial,@JsonKey(name: 'network') String? network,@JsonKey(name: 'createdTime') int? createdTime,@JsonKey(name: 'statusMessage') String? statusMessage,@JsonKey(name: 'receivedAmount') num? receivedAmount,@JsonKey(name: 'slipId') dynamic slipId
});

}
class _$CardDepositResponseDtoCopyWithImpl<$Res>
    implements $CardDepositResponseDtoCopyWith<$Res> {
  _$CardDepositResponseDtoCopyWithImpl(this._self, this._then);

  final CardDepositResponseDto _self;
  final $Res Function(CardDepositResponseDto) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? amount = freezed,Object? code = freezed,Object? serial = freezed,Object? network = freezed,Object? createdTime = freezed,Object? statusMessage = freezed,Object? receivedAmount = freezed,Object? slipId = freezed,}) {
  return _then(_self.copyWith(
amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,createdTime: freezed == createdTime ? _self.createdTime : createdTime // ignore: cast_nullable_to_non_nullable
as int?,statusMessage: freezed == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String?,receivedAmount: freezed == receivedAmount ? _self.receivedAmount : receivedAmount // ignore: cast_nullable_to_non_nullable
as num?,slipId: freezed == slipId ? _self.slipId : slipId // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}

extension CardDepositResponseDtoPatterns on CardDepositResponseDto {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardDepositResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardDepositResponseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardDepositResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _CardDepositResponseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardDepositResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _CardDepositResponseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'amount')  num? amount, @JsonKey(name: 'code')  String? code, @JsonKey(name: 'serial')  String? serial, @JsonKey(name: 'network')  String? network, @JsonKey(name: 'createdTime')  int? createdTime, @JsonKey(name: 'statusMessage')  String? statusMessage, @JsonKey(name: 'receivedAmount')  num? receivedAmount, @JsonKey(name: 'slipId')  dynamic slipId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardDepositResponseDto() when $default != null:
return $default(_that.amount,_that.code,_that.serial,_that.network,_that.createdTime,_that.statusMessage,_that.receivedAmount,_that.slipId);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'amount')  num? amount, @JsonKey(name: 'code')  String? code, @JsonKey(name: 'serial')  String? serial, @JsonKey(name: 'network')  String? network, @JsonKey(name: 'createdTime')  int? createdTime, @JsonKey(name: 'statusMessage')  String? statusMessage, @JsonKey(name: 'receivedAmount')  num? receivedAmount, @JsonKey(name: 'slipId')  dynamic slipId)  $default,) {final _that = this;
switch (_that) {
case _CardDepositResponseDto():
return $default(_that.amount,_that.code,_that.serial,_that.network,_that.createdTime,_that.statusMessage,_that.receivedAmount,_that.slipId);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'amount')  num? amount, @JsonKey(name: 'code')  String? code, @JsonKey(name: 'serial')  String? serial, @JsonKey(name: 'network')  String? network, @JsonKey(name: 'createdTime')  int? createdTime, @JsonKey(name: 'statusMessage')  String? statusMessage, @JsonKey(name: 'receivedAmount')  num? receivedAmount, @JsonKey(name: 'slipId')  dynamic slipId)?  $default,) {final _that = this;
switch (_that) {
case _CardDepositResponseDto() when $default != null:
return $default(_that.amount,_that.code,_that.serial,_that.network,_that.createdTime,_that.statusMessage,_that.receivedAmount,_that.slipId);case _:
  return null;

}
}

}

@JsonSerializable()

class _CardDepositResponseDto implements CardDepositResponseDto {
  const _CardDepositResponseDto({@JsonKey(name: 'amount') this.amount, @JsonKey(name: 'code') this.code, @JsonKey(name: 'serial') this.serial, @JsonKey(name: 'network') this.network, @JsonKey(name: 'createdTime') this.createdTime, @JsonKey(name: 'statusMessage') this.statusMessage, @JsonKey(name: 'receivedAmount') this.receivedAmount, @JsonKey(name: 'slipId') this.slipId});
  factory _CardDepositResponseDto.fromJson(Map<String, dynamic> json) => _$CardDepositResponseDtoFromJson(json);

@override@JsonKey(name: 'amount') final  num? amount;
@override@JsonKey(name: 'code') final  String? code;
@override@JsonKey(name: 'serial') final  String? serial;
@override@JsonKey(name: 'network') final  String? network;
@override@JsonKey(name: 'createdTime') final  int? createdTime;
@override@JsonKey(name: 'statusMessage') final  String? statusMessage;
@override@JsonKey(name: 'receivedAmount') final  num? receivedAmount;
@override@JsonKey(name: 'slipId') final  dynamic slipId;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardDepositResponseDtoCopyWith<_CardDepositResponseDto> get copyWith => __$CardDepositResponseDtoCopyWithImpl<_CardDepositResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardDepositResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardDepositResponseDto&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.code, code) || other.code == code)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.network, network) || other.network == network)&&(identical(other.createdTime, createdTime) || other.createdTime == createdTime)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage)&&(identical(other.receivedAmount, receivedAmount) || other.receivedAmount == receivedAmount)&&const DeepCollectionEquality().equals(other.slipId, slipId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,code,serial,network,createdTime,statusMessage,receivedAmount,const DeepCollectionEquality().hash(slipId));

@override
String toString() {
  return 'CardDepositResponseDto(amount: $amount, code: $code, serial: $serial, network: $network, createdTime: $createdTime, statusMessage: $statusMessage, receivedAmount: $receivedAmount, slipId: $slipId)';
}

}

abstract mixin class _$CardDepositResponseDtoCopyWith<$Res> implements $CardDepositResponseDtoCopyWith<$Res> {
  factory _$CardDepositResponseDtoCopyWith(_CardDepositResponseDto value, $Res Function(_CardDepositResponseDto) _then) = __$CardDepositResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'amount') num? amount,@JsonKey(name: 'code') String? code,@JsonKey(name: 'serial') String? serial,@JsonKey(name: 'network') String? network,@JsonKey(name: 'createdTime') int? createdTime,@JsonKey(name: 'statusMessage') String? statusMessage,@JsonKey(name: 'receivedAmount') num? receivedAmount,@JsonKey(name: 'slipId') dynamic slipId
});

}
class __$CardDepositResponseDtoCopyWithImpl<$Res>
    implements _$CardDepositResponseDtoCopyWith<$Res> {
  __$CardDepositResponseDtoCopyWithImpl(this._self, this._then);

  final _CardDepositResponseDto _self;
  final $Res Function(_CardDepositResponseDto) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? amount = freezed,Object? code = freezed,Object? serial = freezed,Object? network = freezed,Object? createdTime = freezed,Object? statusMessage = freezed,Object? receivedAmount = freezed,Object? slipId = freezed,}) {
  return _then(_CardDepositResponseDto(
amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,createdTime: freezed == createdTime ? _self.createdTime : createdTime // ignore: cast_nullable_to_non_nullable
as int?,statusMessage: freezed == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String?,receivedAmount: freezed == receivedAmount ? _self.receivedAmount : receivedAmount // ignore: cast_nullable_to_non_nullable
as num?,slipId: freezed == slipId ? _self.slipId : slipId // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}

// dart format on
