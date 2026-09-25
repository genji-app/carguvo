// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bank_deposit_request_model.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$BankDepositRequestModel {

@JsonKey(name: 'bank_id') String get bankId;@JsonKey(name: 'account_number') String get accountNumber;@JsonKey(name: 'account_name') String get accountName; String get amount;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankDepositRequestModelCopyWith<BankDepositRequestModel> get copyWith => _$BankDepositRequestModelCopyWithImpl<BankDepositRequestModel>(this as BankDepositRequestModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankDepositRequestModel&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountNumber,accountName,amount);

@override
String toString() {
  return 'BankDepositRequestModel(bankId: $bankId, accountNumber: $accountNumber, accountName: $accountName, amount: $amount)';
}

}

abstract mixin class $BankDepositRequestModelCopyWith<$Res>  {
  factory $BankDepositRequestModelCopyWith(BankDepositRequestModel value, $Res Function(BankDepositRequestModel) _then) = _$BankDepositRequestModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'bank_id') String bankId,@JsonKey(name: 'account_number') String accountNumber,@JsonKey(name: 'account_name') String accountName, String amount
});

}
class _$BankDepositRequestModelCopyWithImpl<$Res>
    implements $BankDepositRequestModelCopyWith<$Res> {
  _$BankDepositRequestModelCopyWithImpl(this._self, this._then);

  final BankDepositRequestModel _self;
  final $Res Function(BankDepositRequestModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? bankId = null,Object? accountNumber = null,Object? accountName = null,Object? amount = null,}) {
  return _then(_self.copyWith(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension BankDepositRequestModelPatterns on BankDepositRequestModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankDepositRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankDepositRequestModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankDepositRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _BankDepositRequestModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankDepositRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _BankDepositRequestModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'bank_id')  String bankId, @JsonKey(name: 'account_number')  String accountNumber, @JsonKey(name: 'account_name')  String accountName,  String amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankDepositRequestModel() when $default != null:
return $default(_that.bankId,_that.accountNumber,_that.accountName,_that.amount);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'bank_id')  String bankId, @JsonKey(name: 'account_number')  String accountNumber, @JsonKey(name: 'account_name')  String accountName,  String amount)  $default,) {final _that = this;
switch (_that) {
case _BankDepositRequestModel():
return $default(_that.bankId,_that.accountNumber,_that.accountName,_that.amount);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'bank_id')  String bankId, @JsonKey(name: 'account_number')  String accountNumber, @JsonKey(name: 'account_name')  String accountName,  String amount)?  $default,) {final _that = this;
switch (_that) {
case _BankDepositRequestModel() when $default != null:
return $default(_that.bankId,_that.accountNumber,_that.accountName,_that.amount);case _:
  return null;

}
}

}

@JsonSerializable()

class _BankDepositRequestModel implements BankDepositRequestModel {
  const _BankDepositRequestModel({@JsonKey(name: 'bank_id') required this.bankId, @JsonKey(name: 'account_number') required this.accountNumber, @JsonKey(name: 'account_name') required this.accountName, required this.amount});
  factory _BankDepositRequestModel.fromJson(Map<String, dynamic> json) => _$BankDepositRequestModelFromJson(json);

@override@JsonKey(name: 'bank_id') final  String bankId;
@override@JsonKey(name: 'account_number') final  String accountNumber;
@override@JsonKey(name: 'account_name') final  String accountName;
@override final  String amount;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankDepositRequestModelCopyWith<_BankDepositRequestModel> get copyWith => __$BankDepositRequestModelCopyWithImpl<_BankDepositRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BankDepositRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankDepositRequestModel&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountNumber,accountName,amount);

@override
String toString() {
  return 'BankDepositRequestModel(bankId: $bankId, accountNumber: $accountNumber, accountName: $accountName, amount: $amount)';
}

}

abstract mixin class _$BankDepositRequestModelCopyWith<$Res> implements $BankDepositRequestModelCopyWith<$Res> {
  factory _$BankDepositRequestModelCopyWith(_BankDepositRequestModel value, $Res Function(_BankDepositRequestModel) _then) = __$BankDepositRequestModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'bank_id') String bankId,@JsonKey(name: 'account_number') String accountNumber,@JsonKey(name: 'account_name') String accountName, String amount
});

}
class __$BankDepositRequestModelCopyWithImpl<$Res>
    implements _$BankDepositRequestModelCopyWith<$Res> {
  __$BankDepositRequestModelCopyWithImpl(this._self, this._then);

  final _BankDepositRequestModel _self;
  final $Res Function(_BankDepositRequestModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? bankId = null,Object? accountNumber = null,Object? accountName = null,Object? amount = null,}) {
  return _then(_BankDepositRequestModel(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
