// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verified_bank_account.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$VerifiedBankAccount {

@JsonKey(name: 'accountHolder') String get accountHolder;@JsonKey(name: 'bankId') String get bankId;@JsonKey(name: 'accountNo') String get accountNo;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifiedBankAccountCopyWith<VerifiedBankAccount> get copyWith => _$VerifiedBankAccountCopyWithImpl<VerifiedBankAccount>(this as VerifiedBankAccount, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifiedBankAccount&&(identical(other.accountHolder, accountHolder) || other.accountHolder == accountHolder)&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountNo, accountNo) || other.accountNo == accountNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountHolder,bankId,accountNo);

@override
String toString() {
  return 'VerifiedBankAccount(accountHolder: $accountHolder, bankId: $bankId, accountNo: $accountNo)';
}

}

abstract mixin class $VerifiedBankAccountCopyWith<$Res>  {
  factory $VerifiedBankAccountCopyWith(VerifiedBankAccount value, $Res Function(VerifiedBankAccount) _then) = _$VerifiedBankAccountCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'accountHolder') String accountHolder,@JsonKey(name: 'bankId') String bankId,@JsonKey(name: 'accountNo') String accountNo
});

}
class _$VerifiedBankAccountCopyWithImpl<$Res>
    implements $VerifiedBankAccountCopyWith<$Res> {
  _$VerifiedBankAccountCopyWithImpl(this._self, this._then);

  final VerifiedBankAccount _self;
  final $Res Function(VerifiedBankAccount) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? accountHolder = null,Object? bankId = null,Object? accountNo = null,}) {
  return _then(_self.copyWith(
accountHolder: null == accountHolder ? _self.accountHolder : accountHolder // ignore: cast_nullable_to_non_nullable
as String,bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountNo: null == accountNo ? _self.accountNo : accountNo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension VerifiedBankAccountPatterns on VerifiedBankAccount {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifiedBankAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifiedBankAccount() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifiedBankAccount value)  $default,){
final _that = this;
switch (_that) {
case _VerifiedBankAccount():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifiedBankAccount value)?  $default,){
final _that = this;
switch (_that) {
case _VerifiedBankAccount() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'accountHolder')  String accountHolder, @JsonKey(name: 'bankId')  String bankId, @JsonKey(name: 'accountNo')  String accountNo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifiedBankAccount() when $default != null:
return $default(_that.accountHolder,_that.bankId,_that.accountNo);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'accountHolder')  String accountHolder, @JsonKey(name: 'bankId')  String bankId, @JsonKey(name: 'accountNo')  String accountNo)  $default,) {final _that = this;
switch (_that) {
case _VerifiedBankAccount():
return $default(_that.accountHolder,_that.bankId,_that.accountNo);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'accountHolder')  String accountHolder, @JsonKey(name: 'bankId')  String bankId, @JsonKey(name: 'accountNo')  String accountNo)?  $default,) {final _that = this;
switch (_that) {
case _VerifiedBankAccount() when $default != null:
return $default(_that.accountHolder,_that.bankId,_that.accountNo);case _:
  return null;

}
}

}

@JsonSerializable()

class _VerifiedBankAccount implements VerifiedBankAccount {
  const _VerifiedBankAccount({@JsonKey(name: 'accountHolder') required this.accountHolder, @JsonKey(name: 'bankId') required this.bankId, @JsonKey(name: 'accountNo') required this.accountNo});
  factory _VerifiedBankAccount.fromJson(Map<String, dynamic> json) => _$VerifiedBankAccountFromJson(json);

@override@JsonKey(name: 'accountHolder') final  String accountHolder;
@override@JsonKey(name: 'bankId') final  String bankId;
@override@JsonKey(name: 'accountNo') final  String accountNo;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifiedBankAccountCopyWith<_VerifiedBankAccount> get copyWith => __$VerifiedBankAccountCopyWithImpl<_VerifiedBankAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifiedBankAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifiedBankAccount&&(identical(other.accountHolder, accountHolder) || other.accountHolder == accountHolder)&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountNo, accountNo) || other.accountNo == accountNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountHolder,bankId,accountNo);

@override
String toString() {
  return 'VerifiedBankAccount(accountHolder: $accountHolder, bankId: $bankId, accountNo: $accountNo)';
}

}

abstract mixin class _$VerifiedBankAccountCopyWith<$Res> implements $VerifiedBankAccountCopyWith<$Res> {
  factory _$VerifiedBankAccountCopyWith(_VerifiedBankAccount value, $Res Function(_VerifiedBankAccount) _then) = __$VerifiedBankAccountCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'accountHolder') String accountHolder,@JsonKey(name: 'bankId') String bankId,@JsonKey(name: 'accountNo') String accountNo
});

}
class __$VerifiedBankAccountCopyWithImpl<$Res>
    implements _$VerifiedBankAccountCopyWith<$Res> {
  __$VerifiedBankAccountCopyWithImpl(this._self, this._then);

  final _VerifiedBankAccount _self;
  final $Res Function(_VerifiedBankAccount) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? accountHolder = null,Object? bankId = null,Object? accountNo = null,}) {
  return _then(_VerifiedBankAccount(
accountHolder: null == accountHolder ? _self.accountHolder : accountHolder // ignore: cast_nullable_to_non_nullable
as String,bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountNo: null == accountNo ? _self.accountNo : accountNo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
