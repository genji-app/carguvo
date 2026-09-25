// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deposit_complains_dto.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$DepositComplainResponseDto {

@JsonKey(name: 'id') dynamic get id;@JsonKey(name: '_id') dynamic get objectId;@JsonKey(name: 'amount') num? get amount;@JsonKey(name: 'value') num? get value;@JsonKey(name: 'status') int? get status;@JsonKey(name: 'type') int? get type;@JsonKey(name: 'method') int? get method;@JsonKey(name: 'statusDescription') String? get statusDescription;@JsonKey(name: 'reason') String? get reason;@JsonKey(name: 'note') String? get note;@JsonKey(name: 'transactionCode') String? get transactionCode;@JsonKey(name: 'code') String? get code;@JsonKey(name: 'ref') String? get ref;@JsonKey(name: 'responseTime') int? get responseTime;@JsonKey(name: 'requestTime') int? get requestTime;@JsonKey(name: 'createdTime') int? get createdTime;@JsonKey(name: 'createdAt') int? get createdAt;@JsonKey(name: 'time') int? get time;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepositComplainResponseDtoCopyWith<DepositComplainResponseDto> get copyWith => _$DepositComplainResponseDtoCopyWithImpl<DepositComplainResponseDto>(this as DepositComplainResponseDto, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DepositComplainResponseDto&&const DeepCollectionEquality().equals(other.id, id)&&const DeepCollectionEquality().equals(other.objectId, objectId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.value, value) || other.value == value)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.method, method) || other.method == method)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note)&&(identical(other.transactionCode, transactionCode) || other.transactionCode == transactionCode)&&(identical(other.code, code) || other.code == code)&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.responseTime, responseTime) || other.responseTime == responseTime)&&(identical(other.requestTime, requestTime) || other.requestTime == requestTime)&&(identical(other.createdTime, createdTime) || other.createdTime == createdTime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(id),const DeepCollectionEquality().hash(objectId),amount,value,status,type,method,statusDescription,reason,note,transactionCode,code,ref,responseTime,requestTime,createdTime,createdAt,time);

@override
String toString() {
  return 'DepositComplainResponseDto(id: $id, objectId: $objectId, amount: $amount, value: $value, status: $status, type: $type, method: $method, statusDescription: $statusDescription, reason: $reason, note: $note, transactionCode: $transactionCode, code: $code, ref: $ref, responseTime: $responseTime, requestTime: $requestTime, createdTime: $createdTime, createdAt: $createdAt, time: $time)';
}

}

abstract mixin class $DepositComplainResponseDtoCopyWith<$Res>  {
  factory $DepositComplainResponseDtoCopyWith(DepositComplainResponseDto value, $Res Function(DepositComplainResponseDto) _then) = _$DepositComplainResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') dynamic id,@JsonKey(name: '_id') dynamic objectId,@JsonKey(name: 'amount') num? amount,@JsonKey(name: 'value') num? value,@JsonKey(name: 'status') int? status,@JsonKey(name: 'type') int? type,@JsonKey(name: 'method') int? method,@JsonKey(name: 'statusDescription') String? statusDescription,@JsonKey(name: 'reason') String? reason,@JsonKey(name: 'note') String? note,@JsonKey(name: 'transactionCode') String? transactionCode,@JsonKey(name: 'code') String? code,@JsonKey(name: 'ref') String? ref,@JsonKey(name: 'responseTime') int? responseTime,@JsonKey(name: 'requestTime') int? requestTime,@JsonKey(name: 'createdTime') int? createdTime,@JsonKey(name: 'createdAt') int? createdAt,@JsonKey(name: 'time') int? time
});

}
class _$DepositComplainResponseDtoCopyWithImpl<$Res>
    implements $DepositComplainResponseDtoCopyWith<$Res> {
  _$DepositComplainResponseDtoCopyWithImpl(this._self, this._then);

  final DepositComplainResponseDto _self;
  final $Res Function(DepositComplainResponseDto) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? objectId = freezed,Object? amount = freezed,Object? value = freezed,Object? status = freezed,Object? type = freezed,Object? method = freezed,Object? statusDescription = freezed,Object? reason = freezed,Object? note = freezed,Object? transactionCode = freezed,Object? code = freezed,Object? ref = freezed,Object? responseTime = freezed,Object? requestTime = freezed,Object? createdTime = freezed,Object? createdAt = freezed,Object? time = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as dynamic,objectId: freezed == objectId ? _self.objectId : objectId // ignore: cast_nullable_to_non_nullable
as dynamic,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as int?,statusDescription: freezed == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,transactionCode: freezed == transactionCode ? _self.transactionCode : transactionCode // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,ref: freezed == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String?,responseTime: freezed == responseTime ? _self.responseTime : responseTime // ignore: cast_nullable_to_non_nullable
as int?,requestTime: freezed == requestTime ? _self.requestTime : requestTime // ignore: cast_nullable_to_non_nullable
as int?,createdTime: freezed == createdTime ? _self.createdTime : createdTime // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

extension DepositComplainResponseDtoPatterns on DepositComplainResponseDto {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DepositComplainResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DepositComplainResponseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DepositComplainResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _DepositComplainResponseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DepositComplainResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _DepositComplainResponseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  dynamic id, @JsonKey(name: '_id')  dynamic objectId, @JsonKey(name: 'amount')  num? amount, @JsonKey(name: 'value')  num? value, @JsonKey(name: 'status')  int? status, @JsonKey(name: 'type')  int? type, @JsonKey(name: 'method')  int? method, @JsonKey(name: 'statusDescription')  String? statusDescription, @JsonKey(name: 'reason')  String? reason, @JsonKey(name: 'note')  String? note, @JsonKey(name: 'transactionCode')  String? transactionCode, @JsonKey(name: 'code')  String? code, @JsonKey(name: 'ref')  String? ref, @JsonKey(name: 'responseTime')  int? responseTime, @JsonKey(name: 'requestTime')  int? requestTime, @JsonKey(name: 'createdTime')  int? createdTime, @JsonKey(name: 'createdAt')  int? createdAt, @JsonKey(name: 'time')  int? time)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DepositComplainResponseDto() when $default != null:
return $default(_that.id,_that.objectId,_that.amount,_that.value,_that.status,_that.type,_that.method,_that.statusDescription,_that.reason,_that.note,_that.transactionCode,_that.code,_that.ref,_that.responseTime,_that.requestTime,_that.createdTime,_that.createdAt,_that.time);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  dynamic id, @JsonKey(name: '_id')  dynamic objectId, @JsonKey(name: 'amount')  num? amount, @JsonKey(name: 'value')  num? value, @JsonKey(name: 'status')  int? status, @JsonKey(name: 'type')  int? type, @JsonKey(name: 'method')  int? method, @JsonKey(name: 'statusDescription')  String? statusDescription, @JsonKey(name: 'reason')  String? reason, @JsonKey(name: 'note')  String? note, @JsonKey(name: 'transactionCode')  String? transactionCode, @JsonKey(name: 'code')  String? code, @JsonKey(name: 'ref')  String? ref, @JsonKey(name: 'responseTime')  int? responseTime, @JsonKey(name: 'requestTime')  int? requestTime, @JsonKey(name: 'createdTime')  int? createdTime, @JsonKey(name: 'createdAt')  int? createdAt, @JsonKey(name: 'time')  int? time)  $default,) {final _that = this;
switch (_that) {
case _DepositComplainResponseDto():
return $default(_that.id,_that.objectId,_that.amount,_that.value,_that.status,_that.type,_that.method,_that.statusDescription,_that.reason,_that.note,_that.transactionCode,_that.code,_that.ref,_that.responseTime,_that.requestTime,_that.createdTime,_that.createdAt,_that.time);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  dynamic id, @JsonKey(name: '_id')  dynamic objectId, @JsonKey(name: 'amount')  num? amount, @JsonKey(name: 'value')  num? value, @JsonKey(name: 'status')  int? status, @JsonKey(name: 'type')  int? type, @JsonKey(name: 'method')  int? method, @JsonKey(name: 'statusDescription')  String? statusDescription, @JsonKey(name: 'reason')  String? reason, @JsonKey(name: 'note')  String? note, @JsonKey(name: 'transactionCode')  String? transactionCode, @JsonKey(name: 'code')  String? code, @JsonKey(name: 'ref')  String? ref, @JsonKey(name: 'responseTime')  int? responseTime, @JsonKey(name: 'requestTime')  int? requestTime, @JsonKey(name: 'createdTime')  int? createdTime, @JsonKey(name: 'createdAt')  int? createdAt, @JsonKey(name: 'time')  int? time)?  $default,) {final _that = this;
switch (_that) {
case _DepositComplainResponseDto() when $default != null:
return $default(_that.id,_that.objectId,_that.amount,_that.value,_that.status,_that.type,_that.method,_that.statusDescription,_that.reason,_that.note,_that.transactionCode,_that.code,_that.ref,_that.responseTime,_that.requestTime,_that.createdTime,_that.createdAt,_that.time);case _:
  return null;

}
}

}

@JsonSerializable()

class _DepositComplainResponseDto implements DepositComplainResponseDto {
  const _DepositComplainResponseDto({@JsonKey(name: 'id') this.id, @JsonKey(name: '_id') this.objectId, @JsonKey(name: 'amount') this.amount, @JsonKey(name: 'value') this.value, @JsonKey(name: 'status') this.status, @JsonKey(name: 'type') this.type, @JsonKey(name: 'method') this.method, @JsonKey(name: 'statusDescription') this.statusDescription, @JsonKey(name: 'reason') this.reason, @JsonKey(name: 'note') this.note, @JsonKey(name: 'transactionCode') this.transactionCode, @JsonKey(name: 'code') this.code, @JsonKey(name: 'ref') this.ref, @JsonKey(name: 'responseTime') this.responseTime, @JsonKey(name: 'requestTime') this.requestTime, @JsonKey(name: 'createdTime') this.createdTime, @JsonKey(name: 'createdAt') this.createdAt, @JsonKey(name: 'time') this.time});
  factory _DepositComplainResponseDto.fromJson(Map<String, dynamic> json) => _$DepositComplainResponseDtoFromJson(json);

@override@JsonKey(name: 'id') final  dynamic id;
@override@JsonKey(name: '_id') final  dynamic objectId;
@override@JsonKey(name: 'amount') final  num? amount;
@override@JsonKey(name: 'value') final  num? value;
@override@JsonKey(name: 'status') final  int? status;
@override@JsonKey(name: 'type') final  int? type;
@override@JsonKey(name: 'method') final  int? method;
@override@JsonKey(name: 'statusDescription') final  String? statusDescription;
@override@JsonKey(name: 'reason') final  String? reason;
@override@JsonKey(name: 'note') final  String? note;
@override@JsonKey(name: 'transactionCode') final  String? transactionCode;
@override@JsonKey(name: 'code') final  String? code;
@override@JsonKey(name: 'ref') final  String? ref;
@override@JsonKey(name: 'responseTime') final  int? responseTime;
@override@JsonKey(name: 'requestTime') final  int? requestTime;
@override@JsonKey(name: 'createdTime') final  int? createdTime;
@override@JsonKey(name: 'createdAt') final  int? createdAt;
@override@JsonKey(name: 'time') final  int? time;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepositComplainResponseDtoCopyWith<_DepositComplainResponseDto> get copyWith => __$DepositComplainResponseDtoCopyWithImpl<_DepositComplainResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DepositComplainResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DepositComplainResponseDto&&const DeepCollectionEquality().equals(other.id, id)&&const DeepCollectionEquality().equals(other.objectId, objectId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.value, value) || other.value == value)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.method, method) || other.method == method)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note)&&(identical(other.transactionCode, transactionCode) || other.transactionCode == transactionCode)&&(identical(other.code, code) || other.code == code)&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.responseTime, responseTime) || other.responseTime == responseTime)&&(identical(other.requestTime, requestTime) || other.requestTime == requestTime)&&(identical(other.createdTime, createdTime) || other.createdTime == createdTime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(id),const DeepCollectionEquality().hash(objectId),amount,value,status,type,method,statusDescription,reason,note,transactionCode,code,ref,responseTime,requestTime,createdTime,createdAt,time);

@override
String toString() {
  return 'DepositComplainResponseDto(id: $id, objectId: $objectId, amount: $amount, value: $value, status: $status, type: $type, method: $method, statusDescription: $statusDescription, reason: $reason, note: $note, transactionCode: $transactionCode, code: $code, ref: $ref, responseTime: $responseTime, requestTime: $requestTime, createdTime: $createdTime, createdAt: $createdAt, time: $time)';
}

}

abstract mixin class _$DepositComplainResponseDtoCopyWith<$Res> implements $DepositComplainResponseDtoCopyWith<$Res> {
  factory _$DepositComplainResponseDtoCopyWith(_DepositComplainResponseDto value, $Res Function(_DepositComplainResponseDto) _then) = __$DepositComplainResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') dynamic id,@JsonKey(name: '_id') dynamic objectId,@JsonKey(name: 'amount') num? amount,@JsonKey(name: 'value') num? value,@JsonKey(name: 'status') int? status,@JsonKey(name: 'type') int? type,@JsonKey(name: 'method') int? method,@JsonKey(name: 'statusDescription') String? statusDescription,@JsonKey(name: 'reason') String? reason,@JsonKey(name: 'note') String? note,@JsonKey(name: 'transactionCode') String? transactionCode,@JsonKey(name: 'code') String? code,@JsonKey(name: 'ref') String? ref,@JsonKey(name: 'responseTime') int? responseTime,@JsonKey(name: 'requestTime') int? requestTime,@JsonKey(name: 'createdTime') int? createdTime,@JsonKey(name: 'createdAt') int? createdAt,@JsonKey(name: 'time') int? time
});

}
class __$DepositComplainResponseDtoCopyWithImpl<$Res>
    implements _$DepositComplainResponseDtoCopyWith<$Res> {
  __$DepositComplainResponseDtoCopyWithImpl(this._self, this._then);

  final _DepositComplainResponseDto _self;
  final $Res Function(_DepositComplainResponseDto) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? objectId = freezed,Object? amount = freezed,Object? value = freezed,Object? status = freezed,Object? type = freezed,Object? method = freezed,Object? statusDescription = freezed,Object? reason = freezed,Object? note = freezed,Object? transactionCode = freezed,Object? code = freezed,Object? ref = freezed,Object? responseTime = freezed,Object? requestTime = freezed,Object? createdTime = freezed,Object? createdAt = freezed,Object? time = freezed,}) {
  return _then(_DepositComplainResponseDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as dynamic,objectId: freezed == objectId ? _self.objectId : objectId // ignore: cast_nullable_to_non_nullable
as dynamic,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as int?,statusDescription: freezed == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,transactionCode: freezed == transactionCode ? _self.transactionCode : transactionCode // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,ref: freezed == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String?,responseTime: freezed == responseTime ? _self.responseTime : responseTime // ignore: cast_nullable_to_non_nullable
as int?,requestTime: freezed == requestTime ? _self.requestTime : requestTime // ignore: cast_nullable_to_non_nullable
as int?,createdTime: freezed == createdTime ? _self.createdTime : createdTime // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

// dart format on
