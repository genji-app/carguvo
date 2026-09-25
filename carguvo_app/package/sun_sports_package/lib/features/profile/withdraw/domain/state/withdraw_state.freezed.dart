// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'withdraw_state.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$WithdrawBankFormState {

 String? get selectedBank; String get accountNumber; String get accountName; String get amount; String? get bankError; String? get accountNumberError; String? get accountNameError; String? get amountError;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WithdrawBankFormStateCopyWith<WithdrawBankFormState> get copyWith => _$WithdrawBankFormStateCopyWithImpl<WithdrawBankFormState>(this as WithdrawBankFormState, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WithdrawBankFormState&&(identical(other.selectedBank, selectedBank) || other.selectedBank == selectedBank)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.bankError, bankError) || other.bankError == bankError)&&(identical(other.accountNumberError, accountNumberError) || other.accountNumberError == accountNumberError)&&(identical(other.accountNameError, accountNameError) || other.accountNameError == accountNameError)&&(identical(other.amountError, amountError) || other.amountError == amountError));
}

@override
int get hashCode => Object.hash(runtimeType,selectedBank,accountNumber,accountName,amount,bankError,accountNumberError,accountNameError,amountError);

@override
String toString() {
  return 'WithdrawBankFormState(selectedBank: $selectedBank, accountNumber: $accountNumber, accountName: $accountName, amount: $amount, bankError: $bankError, accountNumberError: $accountNumberError, accountNameError: $accountNameError, amountError: $amountError)';
}

}

abstract mixin class $WithdrawBankFormStateCopyWith<$Res>  {
  factory $WithdrawBankFormStateCopyWith(WithdrawBankFormState value, $Res Function(WithdrawBankFormState) _then) = _$WithdrawBankFormStateCopyWithImpl;
@useResult
$Res call({
 String? selectedBank, String accountNumber, String accountName, String amount, String? bankError, String? accountNumberError, String? accountNameError, String? amountError
});

}
class _$WithdrawBankFormStateCopyWithImpl<$Res>
    implements $WithdrawBankFormStateCopyWith<$Res> {
  _$WithdrawBankFormStateCopyWithImpl(this._self, this._then);

  final WithdrawBankFormState _self;
  final $Res Function(WithdrawBankFormState) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? selectedBank = freezed,Object? accountNumber = null,Object? accountName = null,Object? amount = null,Object? bankError = freezed,Object? accountNumberError = freezed,Object? accountNameError = freezed,Object? amountError = freezed,}) {
  return _then(_self.copyWith(
selectedBank: freezed == selectedBank ? _self.selectedBank : selectedBank // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,bankError: freezed == bankError ? _self.bankError : bankError // ignore: cast_nullable_to_non_nullable
as String?,accountNumberError: freezed == accountNumberError ? _self.accountNumberError : accountNumberError // ignore: cast_nullable_to_non_nullable
as String?,accountNameError: freezed == accountNameError ? _self.accountNameError : accountNameError // ignore: cast_nullable_to_non_nullable
as String?,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension WithdrawBankFormStatePatterns on WithdrawBankFormState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WithdrawBankFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WithdrawBankFormState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WithdrawBankFormState value)  $default,){
final _that = this;
switch (_that) {
case _WithdrawBankFormState():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WithdrawBankFormState value)?  $default,){
final _that = this;
switch (_that) {
case _WithdrawBankFormState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? selectedBank,  String accountNumber,  String accountName,  String amount,  String? bankError,  String? accountNumberError,  String? accountNameError,  String? amountError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WithdrawBankFormState() when $default != null:
return $default(_that.selectedBank,_that.accountNumber,_that.accountName,_that.amount,_that.bankError,_that.accountNumberError,_that.accountNameError,_that.amountError);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? selectedBank,  String accountNumber,  String accountName,  String amount,  String? bankError,  String? accountNumberError,  String? accountNameError,  String? amountError)  $default,) {final _that = this;
switch (_that) {
case _WithdrawBankFormState():
return $default(_that.selectedBank,_that.accountNumber,_that.accountName,_that.amount,_that.bankError,_that.accountNumberError,_that.accountNameError,_that.amountError);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? selectedBank,  String accountNumber,  String accountName,  String amount,  String? bankError,  String? accountNumberError,  String? accountNameError,  String? amountError)?  $default,) {final _that = this;
switch (_that) {
case _WithdrawBankFormState() when $default != null:
return $default(_that.selectedBank,_that.accountNumber,_that.accountName,_that.amount,_that.bankError,_that.accountNumberError,_that.accountNameError,_that.amountError);case _:
  return null;

}
}

}

class _WithdrawBankFormState implements WithdrawBankFormState {
  const _WithdrawBankFormState({this.selectedBank, this.accountNumber = '', this.accountName = '', this.amount = '', this.bankError, this.accountNumberError, this.accountNameError, this.amountError});
  
@override final  String? selectedBank;
@override@JsonKey() final  String accountNumber;
@override@JsonKey() final  String accountName;
@override@JsonKey() final  String amount;
@override final  String? bankError;
@override final  String? accountNumberError;
@override final  String? accountNameError;
@override final  String? amountError;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WithdrawBankFormStateCopyWith<_WithdrawBankFormState> get copyWith => __$WithdrawBankFormStateCopyWithImpl<_WithdrawBankFormState>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WithdrawBankFormState&&(identical(other.selectedBank, selectedBank) || other.selectedBank == selectedBank)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.bankError, bankError) || other.bankError == bankError)&&(identical(other.accountNumberError, accountNumberError) || other.accountNumberError == accountNumberError)&&(identical(other.accountNameError, accountNameError) || other.accountNameError == accountNameError)&&(identical(other.amountError, amountError) || other.amountError == amountError));
}

@override
int get hashCode => Object.hash(runtimeType,selectedBank,accountNumber,accountName,amount,bankError,accountNumberError,accountNameError,amountError);

@override
String toString() {
  return 'WithdrawBankFormState(selectedBank: $selectedBank, accountNumber: $accountNumber, accountName: $accountName, amount: $amount, bankError: $bankError, accountNumberError: $accountNumberError, accountNameError: $accountNameError, amountError: $amountError)';
}

}

abstract mixin class _$WithdrawBankFormStateCopyWith<$Res> implements $WithdrawBankFormStateCopyWith<$Res> {
  factory _$WithdrawBankFormStateCopyWith(_WithdrawBankFormState value, $Res Function(_WithdrawBankFormState) _then) = __$WithdrawBankFormStateCopyWithImpl;
@override @useResult
$Res call({
 String? selectedBank, String accountNumber, String accountName, String amount, String? bankError, String? accountNumberError, String? accountNameError, String? amountError
});

}
class __$WithdrawBankFormStateCopyWithImpl<$Res>
    implements _$WithdrawBankFormStateCopyWith<$Res> {
  __$WithdrawBankFormStateCopyWithImpl(this._self, this._then);

  final _WithdrawBankFormState _self;
  final $Res Function(_WithdrawBankFormState) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? selectedBank = freezed,Object? accountNumber = null,Object? accountName = null,Object? amount = null,Object? bankError = freezed,Object? accountNumberError = freezed,Object? accountNameError = freezed,Object? amountError = freezed,}) {
  return _then(_WithdrawBankFormState(
selectedBank: freezed == selectedBank ? _self.selectedBank : selectedBank // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,bankError: freezed == bankError ? _self.bankError : bankError // ignore: cast_nullable_to_non_nullable
as String?,accountNumberError: freezed == accountNumberError ? _self.accountNumberError : accountNumberError // ignore: cast_nullable_to_non_nullable
as String?,accountNameError: freezed == accountNameError ? _self.accountNameError : accountNameError // ignore: cast_nullable_to_non_nullable
as String?,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

mixin _$CryptoWithdrawSubmitState {

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoWithdrawSubmitState);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CryptoWithdrawSubmitState()';
}

}

class $CryptoWithdrawSubmitStateCopyWith<$Res>  {
$CryptoWithdrawSubmitStateCopyWith(CryptoWithdrawSubmitState _, $Res Function(CryptoWithdrawSubmitState) __);
}

extension CryptoWithdrawSubmitStatePatterns on CryptoWithdrawSubmitState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CryptoWithdrawIdle value)?  idle,TResult Function( _CryptoWithdrawSubmitting value)?  submitting,TResult Function( _CryptoWithdrawSuccess value)?  success,TResult Function( _CryptoWithdrawError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CryptoWithdrawIdle() when idle != null:
return idle(_that);case _CryptoWithdrawSubmitting() when submitting != null:
return submitting(_that);case _CryptoWithdrawSuccess() when success != null:
return success(_that);case _CryptoWithdrawError() when error != null:
return error(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CryptoWithdrawIdle value)  idle,required TResult Function( _CryptoWithdrawSubmitting value)  submitting,required TResult Function( _CryptoWithdrawSuccess value)  success,required TResult Function( _CryptoWithdrawError value)  error,}){
final _that = this;
switch (_that) {
case _CryptoWithdrawIdle():
return idle(_that);case _CryptoWithdrawSubmitting():
return submitting(_that);case _CryptoWithdrawSuccess():
return success(_that);case _CryptoWithdrawError():
return error(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CryptoWithdrawIdle value)?  idle,TResult? Function( _CryptoWithdrawSubmitting value)?  submitting,TResult? Function( _CryptoWithdrawSuccess value)?  success,TResult? Function( _CryptoWithdrawError value)?  error,}){
final _that = this;
switch (_that) {
case _CryptoWithdrawIdle() when idle != null:
return idle(_that);case _CryptoWithdrawSubmitting() when submitting != null:
return submitting(_that);case _CryptoWithdrawSuccess() when success != null:
return success(_that);case _CryptoWithdrawError() when error != null:
return error(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function()?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CryptoWithdrawIdle() when idle != null:
return idle();case _CryptoWithdrawSubmitting() when submitting != null:
return submitting();case _CryptoWithdrawSuccess() when success != null:
return success();case _CryptoWithdrawError() when error != null:
return error(_that.message);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function()  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _CryptoWithdrawIdle():
return idle();case _CryptoWithdrawSubmitting():
return submitting();case _CryptoWithdrawSuccess():
return success();case _CryptoWithdrawError():
return error(_that.message);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function()?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _CryptoWithdrawIdle() when idle != null:
return idle();case _CryptoWithdrawSubmitting() when submitting != null:
return submitting();case _CryptoWithdrawSuccess() when success != null:
return success();case _CryptoWithdrawError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

class _CryptoWithdrawIdle implements CryptoWithdrawSubmitState {
  const _CryptoWithdrawIdle();
  
@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoWithdrawIdle);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CryptoWithdrawSubmitState.idle()';
}

}

class _CryptoWithdrawSubmitting implements CryptoWithdrawSubmitState {
  const _CryptoWithdrawSubmitting();
  
@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoWithdrawSubmitting);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CryptoWithdrawSubmitState.submitting()';
}

}

class _CryptoWithdrawSuccess implements CryptoWithdrawSubmitState {
  const _CryptoWithdrawSuccess();
  
@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoWithdrawSuccess);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CryptoWithdrawSubmitState.success()';
}

}

class _CryptoWithdrawError implements CryptoWithdrawSubmitState {
  const _CryptoWithdrawError(this.message);
  
 final  String message;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CryptoWithdrawErrorCopyWith<_CryptoWithdrawError> get copyWith => __$CryptoWithdrawErrorCopyWithImpl<_CryptoWithdrawError>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoWithdrawError&&(identical(other.message, message) || other.message == message));
}

@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CryptoWithdrawSubmitState.error(message: $message)';
}

}

abstract mixin class _$CryptoWithdrawErrorCopyWith<$Res> implements $CryptoWithdrawSubmitStateCopyWith<$Res> {
  factory _$CryptoWithdrawErrorCopyWith(_CryptoWithdrawError value, $Res Function(_CryptoWithdrawError) _then) = __$CryptoWithdrawErrorCopyWithImpl;
@useResult
$Res call({
 String message
});

}
class __$CryptoWithdrawErrorCopyWithImpl<$Res>
    implements _$CryptoWithdrawErrorCopyWith<$Res> {
  __$CryptoWithdrawErrorCopyWithImpl(this._self, this._then);

  final _CryptoWithdrawError _self;
  final $Res Function(_CryptoWithdrawError) _then;

@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_CryptoWithdrawError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
