// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unified_transaction.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$UnifiedTransaction {

 String get id;
 num get amount;
 TransactionSource get source;
 TransactionStatus get status;
 String get statusDescription;
 DateTime get sortTime;
@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? get debugRawJson;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnifiedTransactionCopyWith<UnifiedTransaction> get copyWith => _$UnifiedTransactionCopyWithImpl<UnifiedTransaction>(this as UnifiedTransaction, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnifiedTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.source, source) || other.source == source)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.sortTime, sortTime) || other.sortTime == sortTime)&&const DeepCollectionEquality().equals(other.debugRawJson, debugRawJson));
}

@override
int get hashCode => Object.hash(runtimeType,id,amount,source,status,statusDescription,sortTime,const DeepCollectionEquality().hash(debugRawJson));

@override
String toString() {
  return 'UnifiedTransaction(id: $id, amount: $amount, source: $source, status: $status, statusDescription: $statusDescription, sortTime: $sortTime, debugRawJson: $debugRawJson)';
}

}

abstract mixin class $UnifiedTransactionCopyWith<$Res>  {
  factory $UnifiedTransactionCopyWith(UnifiedTransaction value, $Res Function(UnifiedTransaction) _then) = _$UnifiedTransactionCopyWithImpl;
@useResult
$Res call({
 String id, num amount, TransactionSource source, TransactionStatus status, String statusDescription, DateTime sortTime,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? debugRawJson
});

}
class _$UnifiedTransactionCopyWithImpl<$Res>
    implements $UnifiedTransactionCopyWith<$Res> {
  _$UnifiedTransactionCopyWithImpl(this._self, this._then);

  final UnifiedTransaction _self;
  final $Res Function(UnifiedTransaction) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? source = null,Object? status = null,Object? statusDescription = null,Object? sortTime = null,Object? debugRawJson = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TransactionSource,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,statusDescription: null == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String,sortTime: null == sortTime ? _self.sortTime : sortTime // ignore: cast_nullable_to_non_nullable
as DateTime,debugRawJson: freezed == debugRawJson ? _self.debugRawJson : debugRawJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}

extension UnifiedTransactionPatterns on UnifiedTransaction {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SlipTransaction value)?  slip,TResult Function( CardDepositTransaction value)?  cardDeposit,TResult Function( CardWithdrawTransaction value)?  cardWithdraw,TResult Function( ActivityTransaction value)?  activity,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SlipTransaction() when slip != null:
return slip(_that);case CardDepositTransaction() when cardDeposit != null:
return cardDeposit(_that);case CardWithdrawTransaction() when cardWithdraw != null:
return cardWithdraw(_that);case ActivityTransaction() when activity != null:
return activity(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SlipTransaction value)  slip,required TResult Function( CardDepositTransaction value)  cardDeposit,required TResult Function( CardWithdrawTransaction value)  cardWithdraw,required TResult Function( ActivityTransaction value)  activity,}){
final _that = this;
switch (_that) {
case SlipTransaction():
return slip(_that);case CardDepositTransaction():
return cardDeposit(_that);case CardWithdrawTransaction():
return cardWithdraw(_that);case ActivityTransaction():
return activity(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SlipTransaction value)?  slip,TResult? Function( CardDepositTransaction value)?  cardDeposit,TResult? Function( CardWithdrawTransaction value)?  cardWithdraw,TResult? Function( ActivityTransaction value)?  activity,}){
final _that = this;
switch (_that) {
case SlipTransaction() when slip != null:
return slip(_that);case CardDepositTransaction() when cardDeposit != null:
return cardDeposit(_that);case CardWithdrawTransaction() when cardWithdraw != null:
return cardWithdraw(_that);case ActivityTransaction() when activity != null:
return activity(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  num amount,  TransactionSource source,  TransactionSlipType slipType,  TransactionStatus status,  TransactionPaymentMethod paymentMethod,  String statusDescription,  String transactionCode,  DateTime sortTime,  String? bankName,  String? accountName,  String? accountNumber,  String? notes, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? debugRawJson)?  slip,TResult Function( String id,  num amount,  TransactionSource source,  TransactionStatus status,  String statusDescription,  String serial,  String code,  String network,  DateTime sortTime,  num? receivedAmount, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? debugRawJson)?  cardDeposit,TResult Function( String id,  num amount,  TransactionSource source,  TransactionStatus status,  String statusDescription,  String telcoName,  DateTime sortTime,  String? serial,  String? code, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? debugRawJson)?  cardWithdraw,TResult Function( String id,  num amount,  TransactionSource source,  TransactionSlipType slipType,  TransactionStatus status,  String statusDescription,  num closingBalance,  ActivityGroup group,  String rawServiceName,  DateTime sortTime, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? debugRawJson)?  activity,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SlipTransaction() when slip != null:
return slip(_that.id,_that.amount,_that.source,_that.slipType,_that.status,_that.paymentMethod,_that.statusDescription,_that.transactionCode,_that.sortTime,_that.bankName,_that.accountName,_that.accountNumber,_that.notes,_that.debugRawJson);case CardDepositTransaction() when cardDeposit != null:
return cardDeposit(_that.id,_that.amount,_that.source,_that.status,_that.statusDescription,_that.serial,_that.code,_that.network,_that.sortTime,_that.receivedAmount,_that.debugRawJson);case CardWithdrawTransaction() when cardWithdraw != null:
return cardWithdraw(_that.id,_that.amount,_that.source,_that.status,_that.statusDescription,_that.telcoName,_that.sortTime,_that.serial,_that.code,_that.debugRawJson);case ActivityTransaction() when activity != null:
return activity(_that.id,_that.amount,_that.source,_that.slipType,_that.status,_that.statusDescription,_that.closingBalance,_that.group,_that.rawServiceName,_that.sortTime,_that.debugRawJson);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  num amount,  TransactionSource source,  TransactionSlipType slipType,  TransactionStatus status,  TransactionPaymentMethod paymentMethod,  String statusDescription,  String transactionCode,  DateTime sortTime,  String? bankName,  String? accountName,  String? accountNumber,  String? notes, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? debugRawJson)  slip,required TResult Function( String id,  num amount,  TransactionSource source,  TransactionStatus status,  String statusDescription,  String serial,  String code,  String network,  DateTime sortTime,  num? receivedAmount, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? debugRawJson)  cardDeposit,required TResult Function( String id,  num amount,  TransactionSource source,  TransactionStatus status,  String statusDescription,  String telcoName,  DateTime sortTime,  String? serial,  String? code, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? debugRawJson)  cardWithdraw,required TResult Function( String id,  num amount,  TransactionSource source,  TransactionSlipType slipType,  TransactionStatus status,  String statusDescription,  num closingBalance,  ActivityGroup group,  String rawServiceName,  DateTime sortTime, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? debugRawJson)  activity,}) {final _that = this;
switch (_that) {
case SlipTransaction():
return slip(_that.id,_that.amount,_that.source,_that.slipType,_that.status,_that.paymentMethod,_that.statusDescription,_that.transactionCode,_that.sortTime,_that.bankName,_that.accountName,_that.accountNumber,_that.notes,_that.debugRawJson);case CardDepositTransaction():
return cardDeposit(_that.id,_that.amount,_that.source,_that.status,_that.statusDescription,_that.serial,_that.code,_that.network,_that.sortTime,_that.receivedAmount,_that.debugRawJson);case CardWithdrawTransaction():
return cardWithdraw(_that.id,_that.amount,_that.source,_that.status,_that.statusDescription,_that.telcoName,_that.sortTime,_that.serial,_that.code,_that.debugRawJson);case ActivityTransaction():
return activity(_that.id,_that.amount,_that.source,_that.slipType,_that.status,_that.statusDescription,_that.closingBalance,_that.group,_that.rawServiceName,_that.sortTime,_that.debugRawJson);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  num amount,  TransactionSource source,  TransactionSlipType slipType,  TransactionStatus status,  TransactionPaymentMethod paymentMethod,  String statusDescription,  String transactionCode,  DateTime sortTime,  String? bankName,  String? accountName,  String? accountNumber,  String? notes, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? debugRawJson)?  slip,TResult? Function( String id,  num amount,  TransactionSource source,  TransactionStatus status,  String statusDescription,  String serial,  String code,  String network,  DateTime sortTime,  num? receivedAmount, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? debugRawJson)?  cardDeposit,TResult? Function( String id,  num amount,  TransactionSource source,  TransactionStatus status,  String statusDescription,  String telcoName,  DateTime sortTime,  String? serial,  String? code, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? debugRawJson)?  cardWithdraw,TResult? Function( String id,  num amount,  TransactionSource source,  TransactionSlipType slipType,  TransactionStatus status,  String statusDescription,  num closingBalance,  ActivityGroup group,  String rawServiceName,  DateTime sortTime, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic>? debugRawJson)?  activity,}) {final _that = this;
switch (_that) {
case SlipTransaction() when slip != null:
return slip(_that.id,_that.amount,_that.source,_that.slipType,_that.status,_that.paymentMethod,_that.statusDescription,_that.transactionCode,_that.sortTime,_that.bankName,_that.accountName,_that.accountNumber,_that.notes,_that.debugRawJson);case CardDepositTransaction() when cardDeposit != null:
return cardDeposit(_that.id,_that.amount,_that.source,_that.status,_that.statusDescription,_that.serial,_that.code,_that.network,_that.sortTime,_that.receivedAmount,_that.debugRawJson);case CardWithdrawTransaction() when cardWithdraw != null:
return cardWithdraw(_that.id,_that.amount,_that.source,_that.status,_that.statusDescription,_that.telcoName,_that.sortTime,_that.serial,_that.code,_that.debugRawJson);case ActivityTransaction() when activity != null:
return activity(_that.id,_that.amount,_that.source,_that.slipType,_that.status,_that.statusDescription,_that.closingBalance,_that.group,_that.rawServiceName,_that.sortTime,_that.debugRawJson);case _:
  return null;

}
}

}

class SlipTransaction implements UnifiedTransaction {
  const SlipTransaction({required this.id, required this.amount, required this.source, required this.slipType, required this.status, required this.paymentMethod, required this.statusDescription, required this.transactionCode, required this.sortTime, this.bankName, this.accountName, this.accountNumber, this.notes, @JsonKey(includeFromJson: false, includeToJson: false) final  Map<String, dynamic>? debugRawJson}): _debugRawJson = debugRawJson;
  
@override final  String id;
@override final  num amount;
@override final  TransactionSource source;
 final  TransactionSlipType slipType;
@override final  TransactionStatus status;
 final  TransactionPaymentMethod paymentMethod;
@override final  String statusDescription;
 final  String transactionCode;
@override final  DateTime sortTime;
 final  String? bankName;
 final  String? accountName;
 final  String? accountNumber;
 final  String? notes;
 final  Map<String, dynamic>? _debugRawJson;
@override@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? get debugRawJson {
  final value = _debugRawJson;
  if (value == null) return null;
  if (_debugRawJson is EqualUnmodifiableMapView) return _debugRawJson;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlipTransactionCopyWith<SlipTransaction> get copyWith => _$SlipTransactionCopyWithImpl<SlipTransaction>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlipTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.source, source) || other.source == source)&&(identical(other.slipType, slipType) || other.slipType == slipType)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.transactionCode, transactionCode) || other.transactionCode == transactionCode)&&(identical(other.sortTime, sortTime) || other.sortTime == sortTime)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._debugRawJson, _debugRawJson));
}

@override
int get hashCode => Object.hash(runtimeType,id,amount,source,slipType,status,paymentMethod,statusDescription,transactionCode,sortTime,bankName,accountName,accountNumber,notes,const DeepCollectionEquality().hash(_debugRawJson));

@override
String toString() {
  return 'UnifiedTransaction.slip(id: $id, amount: $amount, source: $source, slipType: $slipType, status: $status, paymentMethod: $paymentMethod, statusDescription: $statusDescription, transactionCode: $transactionCode, sortTime: $sortTime, bankName: $bankName, accountName: $accountName, accountNumber: $accountNumber, notes: $notes, debugRawJson: $debugRawJson)';
}

}

abstract mixin class $SlipTransactionCopyWith<$Res> implements $UnifiedTransactionCopyWith<$Res> {
  factory $SlipTransactionCopyWith(SlipTransaction value, $Res Function(SlipTransaction) _then) = _$SlipTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, num amount, TransactionSource source, TransactionSlipType slipType, TransactionStatus status, TransactionPaymentMethod paymentMethod, String statusDescription, String transactionCode, DateTime sortTime, String? bankName, String? accountName, String? accountNumber, String? notes,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? debugRawJson
});

}
class _$SlipTransactionCopyWithImpl<$Res>
    implements $SlipTransactionCopyWith<$Res> {
  _$SlipTransactionCopyWithImpl(this._self, this._then);

  final SlipTransaction _self;
  final $Res Function(SlipTransaction) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? source = null,Object? slipType = null,Object? status = null,Object? paymentMethod = null,Object? statusDescription = null,Object? transactionCode = null,Object? sortTime = null,Object? bankName = freezed,Object? accountName = freezed,Object? accountNumber = freezed,Object? notes = freezed,Object? debugRawJson = freezed,}) {
  return _then(SlipTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TransactionSource,slipType: null == slipType ? _self.slipType : slipType // ignore: cast_nullable_to_non_nullable
as TransactionSlipType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as TransactionPaymentMethod,statusDescription: null == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String,transactionCode: null == transactionCode ? _self.transactionCode : transactionCode // ignore: cast_nullable_to_non_nullable
as String,sortTime: null == sortTime ? _self.sortTime : sortTime // ignore: cast_nullable_to_non_nullable
as DateTime,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,debugRawJson: freezed == debugRawJson ? _self._debugRawJson : debugRawJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}

class CardDepositTransaction implements UnifiedTransaction {
  const CardDepositTransaction({required this.id, required this.amount, required this.source, required this.status, required this.statusDescription, required this.serial, required this.code, required this.network, required this.sortTime, this.receivedAmount, @JsonKey(includeFromJson: false, includeToJson: false) final  Map<String, dynamic>? debugRawJson}): _debugRawJson = debugRawJson;
  
@override final  String id;
@override final  num amount;
@override final  TransactionSource source;
@override final  TransactionStatus status;
@override final  String statusDescription;
 final  String serial;
 final  String code;
 final  String network;
@override final  DateTime sortTime;
 final  num? receivedAmount;
 final  Map<String, dynamic>? _debugRawJson;
@override@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? get debugRawJson {
  final value = _debugRawJson;
  if (value == null) return null;
  if (_debugRawJson is EqualUnmodifiableMapView) return _debugRawJson;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardDepositTransactionCopyWith<CardDepositTransaction> get copyWith => _$CardDepositTransactionCopyWithImpl<CardDepositTransaction>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardDepositTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.source, source) || other.source == source)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.code, code) || other.code == code)&&(identical(other.network, network) || other.network == network)&&(identical(other.sortTime, sortTime) || other.sortTime == sortTime)&&(identical(other.receivedAmount, receivedAmount) || other.receivedAmount == receivedAmount)&&const DeepCollectionEquality().equals(other._debugRawJson, _debugRawJson));
}

@override
int get hashCode => Object.hash(runtimeType,id,amount,source,status,statusDescription,serial,code,network,sortTime,receivedAmount,const DeepCollectionEquality().hash(_debugRawJson));

@override
String toString() {
  return 'UnifiedTransaction.cardDeposit(id: $id, amount: $amount, source: $source, status: $status, statusDescription: $statusDescription, serial: $serial, code: $code, network: $network, sortTime: $sortTime, receivedAmount: $receivedAmount, debugRawJson: $debugRawJson)';
}

}

abstract mixin class $CardDepositTransactionCopyWith<$Res> implements $UnifiedTransactionCopyWith<$Res> {
  factory $CardDepositTransactionCopyWith(CardDepositTransaction value, $Res Function(CardDepositTransaction) _then) = _$CardDepositTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, num amount, TransactionSource source, TransactionStatus status, String statusDescription, String serial, String code, String network, DateTime sortTime, num? receivedAmount,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? debugRawJson
});

}
class _$CardDepositTransactionCopyWithImpl<$Res>
    implements $CardDepositTransactionCopyWith<$Res> {
  _$CardDepositTransactionCopyWithImpl(this._self, this._then);

  final CardDepositTransaction _self;
  final $Res Function(CardDepositTransaction) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? source = null,Object? status = null,Object? statusDescription = null,Object? serial = null,Object? code = null,Object? network = null,Object? sortTime = null,Object? receivedAmount = freezed,Object? debugRawJson = freezed,}) {
  return _then(CardDepositTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TransactionSource,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,statusDescription: null == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String,serial: null == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,sortTime: null == sortTime ? _self.sortTime : sortTime // ignore: cast_nullable_to_non_nullable
as DateTime,receivedAmount: freezed == receivedAmount ? _self.receivedAmount : receivedAmount // ignore: cast_nullable_to_non_nullable
as num?,debugRawJson: freezed == debugRawJson ? _self._debugRawJson : debugRawJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}

class CardWithdrawTransaction implements UnifiedTransaction {
  const CardWithdrawTransaction({required this.id, required this.amount, required this.source, required this.status, required this.statusDescription, required this.telcoName, required this.sortTime, this.serial, this.code, @JsonKey(includeFromJson: false, includeToJson: false) final  Map<String, dynamic>? debugRawJson}): _debugRawJson = debugRawJson;
  
@override final  String id;
@override final  num amount;
@override final  TransactionSource source;
@override final  TransactionStatus status;
@override final  String statusDescription;
 final  String telcoName;
@override final  DateTime sortTime;
 final  String? serial;
 final  String? code;
 final  Map<String, dynamic>? _debugRawJson;
@override@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? get debugRawJson {
  final value = _debugRawJson;
  if (value == null) return null;
  if (_debugRawJson is EqualUnmodifiableMapView) return _debugRawJson;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardWithdrawTransactionCopyWith<CardWithdrawTransaction> get copyWith => _$CardWithdrawTransactionCopyWithImpl<CardWithdrawTransaction>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardWithdrawTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.source, source) || other.source == source)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.telcoName, telcoName) || other.telcoName == telcoName)&&(identical(other.sortTime, sortTime) || other.sortTime == sortTime)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.code, code) || other.code == code)&&const DeepCollectionEquality().equals(other._debugRawJson, _debugRawJson));
}

@override
int get hashCode => Object.hash(runtimeType,id,amount,source,status,statusDescription,telcoName,sortTime,serial,code,const DeepCollectionEquality().hash(_debugRawJson));

@override
String toString() {
  return 'UnifiedTransaction.cardWithdraw(id: $id, amount: $amount, source: $source, status: $status, statusDescription: $statusDescription, telcoName: $telcoName, sortTime: $sortTime, serial: $serial, code: $code, debugRawJson: $debugRawJson)';
}

}

abstract mixin class $CardWithdrawTransactionCopyWith<$Res> implements $UnifiedTransactionCopyWith<$Res> {
  factory $CardWithdrawTransactionCopyWith(CardWithdrawTransaction value, $Res Function(CardWithdrawTransaction) _then) = _$CardWithdrawTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, num amount, TransactionSource source, TransactionStatus status, String statusDescription, String telcoName, DateTime sortTime, String? serial, String? code,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? debugRawJson
});

}
class _$CardWithdrawTransactionCopyWithImpl<$Res>
    implements $CardWithdrawTransactionCopyWith<$Res> {
  _$CardWithdrawTransactionCopyWithImpl(this._self, this._then);

  final CardWithdrawTransaction _self;
  final $Res Function(CardWithdrawTransaction) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? source = null,Object? status = null,Object? statusDescription = null,Object? telcoName = null,Object? sortTime = null,Object? serial = freezed,Object? code = freezed,Object? debugRawJson = freezed,}) {
  return _then(CardWithdrawTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TransactionSource,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,statusDescription: null == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String,telcoName: null == telcoName ? _self.telcoName : telcoName // ignore: cast_nullable_to_non_nullable
as String,sortTime: null == sortTime ? _self.sortTime : sortTime // ignore: cast_nullable_to_non_nullable
as DateTime,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,debugRawJson: freezed == debugRawJson ? _self._debugRawJson : debugRawJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}

class ActivityTransaction implements UnifiedTransaction {
  const ActivityTransaction({required this.id, required this.amount, required this.source, required this.slipType, required this.status, required this.statusDescription, required this.closingBalance, required this.group, required this.rawServiceName, required this.sortTime, @JsonKey(includeFromJson: false, includeToJson: false) final  Map<String, dynamic>? debugRawJson}): _debugRawJson = debugRawJson;
  
@override final  String id;
@override final  num amount;
@override final  TransactionSource source;
 final  TransactionSlipType slipType;
@override final  TransactionStatus status;
@override final  String statusDescription;
 final  num closingBalance;
 final  ActivityGroup group;
 final  String rawServiceName;
@override final  DateTime sortTime;
 final  Map<String, dynamic>? _debugRawJson;
@override@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? get debugRawJson {
  final value = _debugRawJson;
  if (value == null) return null;
  if (_debugRawJson is EqualUnmodifiableMapView) return _debugRawJson;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityTransactionCopyWith<ActivityTransaction> get copyWith => _$ActivityTransactionCopyWithImpl<ActivityTransaction>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.source, source) || other.source == source)&&(identical(other.slipType, slipType) || other.slipType == slipType)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.closingBalance, closingBalance) || other.closingBalance == closingBalance)&&(identical(other.group, group) || other.group == group)&&(identical(other.rawServiceName, rawServiceName) || other.rawServiceName == rawServiceName)&&(identical(other.sortTime, sortTime) || other.sortTime == sortTime)&&const DeepCollectionEquality().equals(other._debugRawJson, _debugRawJson));
}

@override
int get hashCode => Object.hash(runtimeType,id,amount,source,slipType,status,statusDescription,closingBalance,group,rawServiceName,sortTime,const DeepCollectionEquality().hash(_debugRawJson));

@override
String toString() {
  return 'UnifiedTransaction.activity(id: $id, amount: $amount, source: $source, slipType: $slipType, status: $status, statusDescription: $statusDescription, closingBalance: $closingBalance, group: $group, rawServiceName: $rawServiceName, sortTime: $sortTime, debugRawJson: $debugRawJson)';
}

}

abstract mixin class $ActivityTransactionCopyWith<$Res> implements $UnifiedTransactionCopyWith<$Res> {
  factory $ActivityTransactionCopyWith(ActivityTransaction value, $Res Function(ActivityTransaction) _then) = _$ActivityTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, num amount, TransactionSource source, TransactionSlipType slipType, TransactionStatus status, String statusDescription, num closingBalance, ActivityGroup group, String rawServiceName, DateTime sortTime,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic>? debugRawJson
});

}
class _$ActivityTransactionCopyWithImpl<$Res>
    implements $ActivityTransactionCopyWith<$Res> {
  _$ActivityTransactionCopyWithImpl(this._self, this._then);

  final ActivityTransaction _self;
  final $Res Function(ActivityTransaction) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? source = null,Object? slipType = null,Object? status = null,Object? statusDescription = null,Object? closingBalance = null,Object? group = null,Object? rawServiceName = null,Object? sortTime = null,Object? debugRawJson = freezed,}) {
  return _then(ActivityTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TransactionSource,slipType: null == slipType ? _self.slipType : slipType // ignore: cast_nullable_to_non_nullable
as TransactionSlipType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,statusDescription: null == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String,closingBalance: null == closingBalance ? _self.closingBalance : closingBalance // ignore: cast_nullable_to_non_nullable
as num,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as ActivityGroup,rawServiceName: null == rawServiceName ? _self.rawServiceName : rawServiceName // ignore: cast_nullable_to_non_nullable
as String,sortTime: null == sortTime ? _self.sortTime : sortTime // ignore: cast_nullable_to_non_nullable
as DateTime,debugRawJson: freezed == debugRawJson ? _self._debugRawJson : debugRawJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}

// dart format on
