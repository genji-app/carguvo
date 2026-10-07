// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_slip_dto.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$PaymentSlipBankDto {

@JsonKey(name: 'bankId') String get bankId;@JsonKey(name: 'publicRss') int get publicRss;@JsonKey(name: 'type') int get type;@JsonKey(name: 'accountName') String? get accountName;@JsonKey(name: 'accountNumber') String? get accountNumber;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentSlipBankDtoCopyWith<PaymentSlipBankDto> get copyWith => _$PaymentSlipBankDtoCopyWithImpl<PaymentSlipBankDto>(this as PaymentSlipBankDto, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentSlipBankDto&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.publicRss, publicRss) || other.publicRss == publicRss)&&(identical(other.type, type) || other.type == type)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,publicRss,type,accountName,accountNumber);

@override
String toString() {
  return 'PaymentSlipBankDto(bankId: $bankId, publicRss: $publicRss, type: $type, accountName: $accountName, accountNumber: $accountNumber)';
}

}

abstract mixin class $PaymentSlipBankDtoCopyWith<$Res>  {
  factory $PaymentSlipBankDtoCopyWith(PaymentSlipBankDto value, $Res Function(PaymentSlipBankDto) _then) = _$PaymentSlipBankDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'bankId') String bankId,@JsonKey(name: 'publicRss') int publicRss,@JsonKey(name: 'type') int type,@JsonKey(name: 'accountName') String? accountName,@JsonKey(name: 'accountNumber') String? accountNumber
});

}
class _$PaymentSlipBankDtoCopyWithImpl<$Res>
    implements $PaymentSlipBankDtoCopyWith<$Res> {
  _$PaymentSlipBankDtoCopyWithImpl(this._self, this._then);

  final PaymentSlipBankDto _self;
  final $Res Function(PaymentSlipBankDto) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? bankId = null,Object? publicRss = null,Object? type = null,Object? accountName = freezed,Object? accountNumber = freezed,}) {
  return _then(_self.copyWith(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,publicRss: null == publicRss ? _self.publicRss : publicRss // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension PaymentSlipBankDtoPatterns on PaymentSlipBankDto {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentSlipBankDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentSlipBankDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentSlipBankDto value)  $default,){
final _that = this;
switch (_that) {
case _PaymentSlipBankDto():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentSlipBankDto value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentSlipBankDto() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'bankId')  String bankId, @JsonKey(name: 'publicRss')  int publicRss, @JsonKey(name: 'type')  int type, @JsonKey(name: 'accountName')  String? accountName, @JsonKey(name: 'accountNumber')  String? accountNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentSlipBankDto() when $default != null:
return $default(_that.bankId,_that.publicRss,_that.type,_that.accountName,_that.accountNumber);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'bankId')  String bankId, @JsonKey(name: 'publicRss')  int publicRss, @JsonKey(name: 'type')  int type, @JsonKey(name: 'accountName')  String? accountName, @JsonKey(name: 'accountNumber')  String? accountNumber)  $default,) {final _that = this;
switch (_that) {
case _PaymentSlipBankDto():
return $default(_that.bankId,_that.publicRss,_that.type,_that.accountName,_that.accountNumber);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'bankId')  String bankId, @JsonKey(name: 'publicRss')  int publicRss, @JsonKey(name: 'type')  int type, @JsonKey(name: 'accountName')  String? accountName, @JsonKey(name: 'accountNumber')  String? accountNumber)?  $default,) {final _that = this;
switch (_that) {
case _PaymentSlipBankDto() when $default != null:
return $default(_that.bankId,_that.publicRss,_that.type,_that.accountName,_that.accountNumber);case _:
  return null;

}
}

}

@JsonSerializable()

class _PaymentSlipBankDto implements PaymentSlipBankDto {
  const _PaymentSlipBankDto({@JsonKey(name: 'bankId') required this.bankId, @JsonKey(name: 'publicRss') required this.publicRss, @JsonKey(name: 'type') required this.type, @JsonKey(name: 'accountName') this.accountName, @JsonKey(name: 'accountNumber') this.accountNumber});
  factory _PaymentSlipBankDto.fromJson(Map<String, dynamic> json) => _$PaymentSlipBankDtoFromJson(json);

@override@JsonKey(name: 'bankId') final  String bankId;
@override@JsonKey(name: 'publicRss') final  int publicRss;
@override@JsonKey(name: 'type') final  int type;
@override@JsonKey(name: 'accountName') final  String? accountName;
@override@JsonKey(name: 'accountNumber') final  String? accountNumber;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentSlipBankDtoCopyWith<_PaymentSlipBankDto> get copyWith => __$PaymentSlipBankDtoCopyWithImpl<_PaymentSlipBankDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentSlipBankDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentSlipBankDto&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.publicRss, publicRss) || other.publicRss == publicRss)&&(identical(other.type, type) || other.type == type)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,publicRss,type,accountName,accountNumber);

@override
String toString() {
  return 'PaymentSlipBankDto(bankId: $bankId, publicRss: $publicRss, type: $type, accountName: $accountName, accountNumber: $accountNumber)';
}

}

abstract mixin class _$PaymentSlipBankDtoCopyWith<$Res> implements $PaymentSlipBankDtoCopyWith<$Res> {
  factory _$PaymentSlipBankDtoCopyWith(_PaymentSlipBankDto value, $Res Function(_PaymentSlipBankDto) _then) = __$PaymentSlipBankDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'bankId') String bankId,@JsonKey(name: 'publicRss') int publicRss,@JsonKey(name: 'type') int type,@JsonKey(name: 'accountName') String? accountName,@JsonKey(name: 'accountNumber') String? accountNumber
});

}
class __$PaymentSlipBankDtoCopyWithImpl<$Res>
    implements _$PaymentSlipBankDtoCopyWith<$Res> {
  __$PaymentSlipBankDtoCopyWithImpl(this._self, this._then);

  final _PaymentSlipBankDto _self;
  final $Res Function(_PaymentSlipBankDto) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? bankId = null,Object? publicRss = null,Object? type = null,Object? accountName = freezed,Object? accountNumber = freezed,}) {
  return _then(_PaymentSlipBankDto(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,publicRss: null == publicRss ? _self.publicRss : publicRss // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

mixin _$PaymentSlipDto {

@JsonKey(name: 'id') int get id;@JsonKey(name: 'transactionCode') String get transactionCode;@JsonKey(name: 'amount') num get amount;
@JsonKey(name: 'type') int get type;
@JsonKey(name: 'status') int get status;
@JsonKey(name: 'slipType') int get slipType;@JsonKey(name: 'statusDescription') String get statusDescription;@JsonKey(name: 'bankSent') PaymentSlipBankDto get bankSent;@JsonKey(name: 'bankReceive') PaymentSlipBankDto get bankReceive;@JsonKey(name: 'requestTime') int get requestTime;@JsonKey(name: 'responseTime') int get responseTime;@JsonKey(name: 'notes') String? get notes;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentSlipDtoCopyWith<PaymentSlipDto> get copyWith => _$PaymentSlipDtoCopyWithImpl<PaymentSlipDto>(this as PaymentSlipDto, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentSlipDto&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionCode, transactionCode) || other.transactionCode == transactionCode)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.slipType, slipType) || other.slipType == slipType)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.bankSent, bankSent) || other.bankSent == bankSent)&&(identical(other.bankReceive, bankReceive) || other.bankReceive == bankReceive)&&(identical(other.requestTime, requestTime) || other.requestTime == requestTime)&&(identical(other.responseTime, responseTime) || other.responseTime == responseTime)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionCode,amount,type,status,slipType,statusDescription,bankSent,bankReceive,requestTime,responseTime,notes);

@override
String toString() {
  return 'PaymentSlipDto(id: $id, transactionCode: $transactionCode, amount: $amount, type: $type, status: $status, slipType: $slipType, statusDescription: $statusDescription, bankSent: $bankSent, bankReceive: $bankReceive, requestTime: $requestTime, responseTime: $responseTime, notes: $notes)';
}

}

abstract mixin class $PaymentSlipDtoCopyWith<$Res>  {
  factory $PaymentSlipDtoCopyWith(PaymentSlipDto value, $Res Function(PaymentSlipDto) _then) = _$PaymentSlipDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'transactionCode') String transactionCode,@JsonKey(name: 'amount') num amount,@JsonKey(name: 'type') int type,@JsonKey(name: 'status') int status,@JsonKey(name: 'slipType') int slipType,@JsonKey(name: 'statusDescription') String statusDescription,@JsonKey(name: 'bankSent') PaymentSlipBankDto bankSent,@JsonKey(name: 'bankReceive') PaymentSlipBankDto bankReceive,@JsonKey(name: 'requestTime') int requestTime,@JsonKey(name: 'responseTime') int responseTime,@JsonKey(name: 'notes') String? notes
});

$PaymentSlipBankDtoCopyWith<$Res> get bankSent;$PaymentSlipBankDtoCopyWith<$Res> get bankReceive;

}
class _$PaymentSlipDtoCopyWithImpl<$Res>
    implements $PaymentSlipDtoCopyWith<$Res> {
  _$PaymentSlipDtoCopyWithImpl(this._self, this._then);

  final PaymentSlipDto _self;
  final $Res Function(PaymentSlipDto) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? transactionCode = null,Object? amount = null,Object? type = null,Object? status = null,Object? slipType = null,Object? statusDescription = null,Object? bankSent = null,Object? bankReceive = null,Object? requestTime = null,Object? responseTime = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,transactionCode: null == transactionCode ? _self.transactionCode : transactionCode // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,slipType: null == slipType ? _self.slipType : slipType // ignore: cast_nullable_to_non_nullable
as int,statusDescription: null == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String,bankSent: null == bankSent ? _self.bankSent : bankSent // ignore: cast_nullable_to_non_nullable
as PaymentSlipBankDto,bankReceive: null == bankReceive ? _self.bankReceive : bankReceive // ignore: cast_nullable_to_non_nullable
as PaymentSlipBankDto,requestTime: null == requestTime ? _self.requestTime : requestTime // ignore: cast_nullable_to_non_nullable
as int,responseTime: null == responseTime ? _self.responseTime : responseTime // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
@override
@pragma('vm:prefer-inline')
$PaymentSlipBankDtoCopyWith<$Res> get bankSent {
  
  return $PaymentSlipBankDtoCopyWith<$Res>(_self.bankSent, (value) {
    return _then(_self.copyWith(bankSent: value));
  });
}
@override
@pragma('vm:prefer-inline')
$PaymentSlipBankDtoCopyWith<$Res> get bankReceive {
  
  return $PaymentSlipBankDtoCopyWith<$Res>(_self.bankReceive, (value) {
    return _then(_self.copyWith(bankReceive: value));
  });
}
}

extension PaymentSlipDtoPatterns on PaymentSlipDto {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentSlipDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentSlipDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentSlipDto value)  $default,){
final _that = this;
switch (_that) {
case _PaymentSlipDto():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentSlipDto value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentSlipDto() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'transactionCode')  String transactionCode, @JsonKey(name: 'amount')  num amount, @JsonKey(name: 'type')  int type, @JsonKey(name: 'status')  int status, @JsonKey(name: 'slipType')  int slipType, @JsonKey(name: 'statusDescription')  String statusDescription, @JsonKey(name: 'bankSent')  PaymentSlipBankDto bankSent, @JsonKey(name: 'bankReceive')  PaymentSlipBankDto bankReceive, @JsonKey(name: 'requestTime')  int requestTime, @JsonKey(name: 'responseTime')  int responseTime, @JsonKey(name: 'notes')  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentSlipDto() when $default != null:
return $default(_that.id,_that.transactionCode,_that.amount,_that.type,_that.status,_that.slipType,_that.statusDescription,_that.bankSent,_that.bankReceive,_that.requestTime,_that.responseTime,_that.notes);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'transactionCode')  String transactionCode, @JsonKey(name: 'amount')  num amount, @JsonKey(name: 'type')  int type, @JsonKey(name: 'status')  int status, @JsonKey(name: 'slipType')  int slipType, @JsonKey(name: 'statusDescription')  String statusDescription, @JsonKey(name: 'bankSent')  PaymentSlipBankDto bankSent, @JsonKey(name: 'bankReceive')  PaymentSlipBankDto bankReceive, @JsonKey(name: 'requestTime')  int requestTime, @JsonKey(name: 'responseTime')  int responseTime, @JsonKey(name: 'notes')  String? notes)  $default,) {final _that = this;
switch (_that) {
case _PaymentSlipDto():
return $default(_that.id,_that.transactionCode,_that.amount,_that.type,_that.status,_that.slipType,_that.statusDescription,_that.bankSent,_that.bankReceive,_that.requestTime,_that.responseTime,_that.notes);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'transactionCode')  String transactionCode, @JsonKey(name: 'amount')  num amount, @JsonKey(name: 'type')  int type, @JsonKey(name: 'status')  int status, @JsonKey(name: 'slipType')  int slipType, @JsonKey(name: 'statusDescription')  String statusDescription, @JsonKey(name: 'bankSent')  PaymentSlipBankDto bankSent, @JsonKey(name: 'bankReceive')  PaymentSlipBankDto bankReceive, @JsonKey(name: 'requestTime')  int requestTime, @JsonKey(name: 'responseTime')  int responseTime, @JsonKey(name: 'notes')  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _PaymentSlipDto() when $default != null:
return $default(_that.id,_that.transactionCode,_that.amount,_that.type,_that.status,_that.slipType,_that.statusDescription,_that.bankSent,_that.bankReceive,_that.requestTime,_that.responseTime,_that.notes);case _:
  return null;

}
}

}

@JsonSerializable()

class _PaymentSlipDto implements PaymentSlipDto {
  const _PaymentSlipDto({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'transactionCode') required this.transactionCode, @JsonKey(name: 'amount') required this.amount, @JsonKey(name: 'type') required this.type, @JsonKey(name: 'status') required this.status, @JsonKey(name: 'slipType') required this.slipType, @JsonKey(name: 'statusDescription') required this.statusDescription, @JsonKey(name: 'bankSent') required this.bankSent, @JsonKey(name: 'bankReceive') required this.bankReceive, @JsonKey(name: 'requestTime') required this.requestTime, @JsonKey(name: 'responseTime') required this.responseTime, @JsonKey(name: 'notes') this.notes});
  factory _PaymentSlipDto.fromJson(Map<String, dynamic> json) => _$PaymentSlipDtoFromJson(json);

@override@JsonKey(name: 'id') final  int id;
@override@JsonKey(name: 'transactionCode') final  String transactionCode;
@override@JsonKey(name: 'amount') final  num amount;
@override@JsonKey(name: 'type') final  int type;
@override@JsonKey(name: 'status') final  int status;
@override@JsonKey(name: 'slipType') final  int slipType;
@override@JsonKey(name: 'statusDescription') final  String statusDescription;
@override@JsonKey(name: 'bankSent') final  PaymentSlipBankDto bankSent;
@override@JsonKey(name: 'bankReceive') final  PaymentSlipBankDto bankReceive;
@override@JsonKey(name: 'requestTime') final  int requestTime;
@override@JsonKey(name: 'responseTime') final  int responseTime;
@override@JsonKey(name: 'notes') final  String? notes;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentSlipDtoCopyWith<_PaymentSlipDto> get copyWith => __$PaymentSlipDtoCopyWithImpl<_PaymentSlipDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentSlipDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentSlipDto&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionCode, transactionCode) || other.transactionCode == transactionCode)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.slipType, slipType) || other.slipType == slipType)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.bankSent, bankSent) || other.bankSent == bankSent)&&(identical(other.bankReceive, bankReceive) || other.bankReceive == bankReceive)&&(identical(other.requestTime, requestTime) || other.requestTime == requestTime)&&(identical(other.responseTime, responseTime) || other.responseTime == responseTime)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionCode,amount,type,status,slipType,statusDescription,bankSent,bankReceive,requestTime,responseTime,notes);

@override
String toString() {
  return 'PaymentSlipDto(id: $id, transactionCode: $transactionCode, amount: $amount, type: $type, status: $status, slipType: $slipType, statusDescription: $statusDescription, bankSent: $bankSent, bankReceive: $bankReceive, requestTime: $requestTime, responseTime: $responseTime, notes: $notes)';
}

}

abstract mixin class _$PaymentSlipDtoCopyWith<$Res> implements $PaymentSlipDtoCopyWith<$Res> {
  factory _$PaymentSlipDtoCopyWith(_PaymentSlipDto value, $Res Function(_PaymentSlipDto) _then) = __$PaymentSlipDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'transactionCode') String transactionCode,@JsonKey(name: 'amount') num amount,@JsonKey(name: 'type') int type,@JsonKey(name: 'status') int status,@JsonKey(name: 'slipType') int slipType,@JsonKey(name: 'statusDescription') String statusDescription,@JsonKey(name: 'bankSent') PaymentSlipBankDto bankSent,@JsonKey(name: 'bankReceive') PaymentSlipBankDto bankReceive,@JsonKey(name: 'requestTime') int requestTime,@JsonKey(name: 'responseTime') int responseTime,@JsonKey(name: 'notes') String? notes
});

@override $PaymentSlipBankDtoCopyWith<$Res> get bankSent;@override $PaymentSlipBankDtoCopyWith<$Res> get bankReceive;

}
class __$PaymentSlipDtoCopyWithImpl<$Res>
    implements _$PaymentSlipDtoCopyWith<$Res> {
  __$PaymentSlipDtoCopyWithImpl(this._self, this._then);

  final _PaymentSlipDto _self;
  final $Res Function(_PaymentSlipDto) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? transactionCode = null,Object? amount = null,Object? type = null,Object? status = null,Object? slipType = null,Object? statusDescription = null,Object? bankSent = null,Object? bankReceive = null,Object? requestTime = null,Object? responseTime = null,Object? notes = freezed,}) {
  return _then(_PaymentSlipDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,transactionCode: null == transactionCode ? _self.transactionCode : transactionCode // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,slipType: null == slipType ? _self.slipType : slipType // ignore: cast_nullable_to_non_nullable
as int,statusDescription: null == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String,bankSent: null == bankSent ? _self.bankSent : bankSent // ignore: cast_nullable_to_non_nullable
as PaymentSlipBankDto,bankReceive: null == bankReceive ? _self.bankReceive : bankReceive // ignore: cast_nullable_to_non_nullable
as PaymentSlipBankDto,requestTime: null == requestTime ? _self.requestTime : requestTime // ignore: cast_nullable_to_non_nullable
as int,responseTime: null == responseTime ? _self.responseTime : responseTime // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

@override
@pragma('vm:prefer-inline')
$PaymentSlipBankDtoCopyWith<$Res> get bankSent {
  
  return $PaymentSlipBankDtoCopyWith<$Res>(_self.bankSent, (value) {
    return _then(_self.copyWith(bankSent: value));
  });
}
@override
@pragma('vm:prefer-inline')
$PaymentSlipBankDtoCopyWith<$Res> get bankReceive {
  
  return $PaymentSlipBankDtoCopyWith<$Res>(_self.bankReceive, (value) {
    return _then(_self.copyWith(bankReceive: value));
  });
}
}

mixin _$PaymentSlipResponseDto {

@JsonKey(name: 'count') int get count;@JsonKey(name: 'message') String get message;@JsonKey(name: 'items') List<PaymentSlipDto> get items;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentSlipResponseDtoCopyWith<PaymentSlipResponseDto> get copyWith => _$PaymentSlipResponseDtoCopyWithImpl<PaymentSlipResponseDto>(this as PaymentSlipResponseDto, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentSlipResponseDto&&(identical(other.count, count) || other.count == count)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,message,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'PaymentSlipResponseDto(count: $count, message: $message, items: $items)';
}

}

abstract mixin class $PaymentSlipResponseDtoCopyWith<$Res>  {
  factory $PaymentSlipResponseDtoCopyWith(PaymentSlipResponseDto value, $Res Function(PaymentSlipResponseDto) _then) = _$PaymentSlipResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'count') int count,@JsonKey(name: 'message') String message,@JsonKey(name: 'items') List<PaymentSlipDto> items
});

}
class _$PaymentSlipResponseDtoCopyWithImpl<$Res>
    implements $PaymentSlipResponseDtoCopyWith<$Res> {
  _$PaymentSlipResponseDtoCopyWithImpl(this._self, this._then);

  final PaymentSlipResponseDto _self;
  final $Res Function(PaymentSlipResponseDto) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? message = null,Object? items = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PaymentSlipDto>,
  ));
}

}

extension PaymentSlipResponseDtoPatterns on PaymentSlipResponseDto {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentSlipResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentSlipResponseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentSlipResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _PaymentSlipResponseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentSlipResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentSlipResponseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'count')  int count, @JsonKey(name: 'message')  String message, @JsonKey(name: 'items')  List<PaymentSlipDto> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentSlipResponseDto() when $default != null:
return $default(_that.count,_that.message,_that.items);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'count')  int count, @JsonKey(name: 'message')  String message, @JsonKey(name: 'items')  List<PaymentSlipDto> items)  $default,) {final _that = this;
switch (_that) {
case _PaymentSlipResponseDto():
return $default(_that.count,_that.message,_that.items);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'count')  int count, @JsonKey(name: 'message')  String message, @JsonKey(name: 'items')  List<PaymentSlipDto> items)?  $default,) {final _that = this;
switch (_that) {
case _PaymentSlipResponseDto() when $default != null:
return $default(_that.count,_that.message,_that.items);case _:
  return null;

}
}

}

@JsonSerializable()

class _PaymentSlipResponseDto implements PaymentSlipResponseDto {
  const _PaymentSlipResponseDto({@JsonKey(name: 'count') required this.count, @JsonKey(name: 'message') required this.message, @JsonKey(name: 'items') required final  List<PaymentSlipDto> items}): _items = items;
  factory _PaymentSlipResponseDto.fromJson(Map<String, dynamic> json) => _$PaymentSlipResponseDtoFromJson(json);

@override@JsonKey(name: 'count') final  int count;
@override@JsonKey(name: 'message') final  String message;
 final  List<PaymentSlipDto> _items;
@override@JsonKey(name: 'items') List<PaymentSlipDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentSlipResponseDtoCopyWith<_PaymentSlipResponseDto> get copyWith => __$PaymentSlipResponseDtoCopyWithImpl<_PaymentSlipResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentSlipResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentSlipResponseDto&&(identical(other.count, count) || other.count == count)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,message,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'PaymentSlipResponseDto(count: $count, message: $message, items: $items)';
}

}

abstract mixin class _$PaymentSlipResponseDtoCopyWith<$Res> implements $PaymentSlipResponseDtoCopyWith<$Res> {
  factory _$PaymentSlipResponseDtoCopyWith(_PaymentSlipResponseDto value, $Res Function(_PaymentSlipResponseDto) _then) = __$PaymentSlipResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'count') int count,@JsonKey(name: 'message') String message,@JsonKey(name: 'items') List<PaymentSlipDto> items
});

}
class __$PaymentSlipResponseDtoCopyWithImpl<$Res>
    implements _$PaymentSlipResponseDtoCopyWith<$Res> {
  __$PaymentSlipResponseDtoCopyWithImpl(this._self, this._then);

  final _PaymentSlipResponseDto _self;
  final $Res Function(_PaymentSlipResponseDto) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? message = null,Object? items = null,}) {
  return _then(_PaymentSlipResponseDto(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PaymentSlipDto>,
  ));
}

}

// dart format on
