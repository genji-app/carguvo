// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codepay_account.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$CodepayAccount {

 String get bankId; String get accountName;@BankBranchConverter() BankBranch get bankBranch; int get publicRss; String get id; String get accountNumber; int get type;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodepayAccountCopyWith<CodepayAccount> get copyWith => _$CodepayAccountCopyWithImpl<CodepayAccount>(this as CodepayAccount, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodepayAccount&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.bankBranch, bankBranch) || other.bankBranch == bankBranch)&&(identical(other.publicRss, publicRss) || other.publicRss == publicRss)&&(identical(other.id, id) || other.id == id)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountName,bankBranch,publicRss,id,accountNumber,type);

@override
String toString() {
  return 'CodepayAccount(bankId: $bankId, accountName: $accountName, bankBranch: $bankBranch, publicRss: $publicRss, id: $id, accountNumber: $accountNumber, type: $type)';
}

}

abstract mixin class $CodepayAccountCopyWith<$Res>  {
  factory $CodepayAccountCopyWith(CodepayAccount value, $Res Function(CodepayAccount) _then) = _$CodepayAccountCopyWithImpl;
@useResult
$Res call({
 String bankId, String accountName,@BankBranchConverter() BankBranch bankBranch, int publicRss, String id, String accountNumber, int type
});

}
class _$CodepayAccountCopyWithImpl<$Res>
    implements $CodepayAccountCopyWith<$Res> {
  _$CodepayAccountCopyWithImpl(this._self, this._then);

  final CodepayAccount _self;
  final $Res Function(CodepayAccount) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? bankId = null,Object? accountName = null,Object? bankBranch = null,Object? publicRss = null,Object? id = null,Object? accountNumber = null,Object? type = null,}) {
  return _then(_self.copyWith(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,bankBranch: null == bankBranch ? _self.bankBranch : bankBranch // ignore: cast_nullable_to_non_nullable
as BankBranch,publicRss: null == publicRss ? _self.publicRss : publicRss // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension CodepayAccountPatterns on CodepayAccount {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodepayAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodepayAccount() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodepayAccount value)  $default,){
final _that = this;
switch (_that) {
case _CodepayAccount():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodepayAccount value)?  $default,){
final _that = this;
switch (_that) {
case _CodepayAccount() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bankId,  String accountName, @BankBranchConverter()  BankBranch bankBranch,  int publicRss,  String id,  String accountNumber,  int type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodepayAccount() when $default != null:
return $default(_that.bankId,_that.accountName,_that.bankBranch,_that.publicRss,_that.id,_that.accountNumber,_that.type);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bankId,  String accountName, @BankBranchConverter()  BankBranch bankBranch,  int publicRss,  String id,  String accountNumber,  int type)  $default,) {final _that = this;
switch (_that) {
case _CodepayAccount():
return $default(_that.bankId,_that.accountName,_that.bankBranch,_that.publicRss,_that.id,_that.accountNumber,_that.type);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bankId,  String accountName, @BankBranchConverter()  BankBranch bankBranch,  int publicRss,  String id,  String accountNumber,  int type)?  $default,) {final _that = this;
switch (_that) {
case _CodepayAccount() when $default != null:
return $default(_that.bankId,_that.accountName,_that.bankBranch,_that.publicRss,_that.id,_that.accountNumber,_that.type);case _:
  return null;

}
}

}

@JsonSerializable()

class _CodepayAccount implements CodepayAccount {
  const _CodepayAccount({required this.bankId, required this.accountName, @BankBranchConverter() required this.bankBranch, required this.publicRss, required this.id, required this.accountNumber, required this.type});
  factory _CodepayAccount.fromJson(Map<String, dynamic> json) => _$CodepayAccountFromJson(json);

@override final  String bankId;
@override final  String accountName;
@override@BankBranchConverter() final  BankBranch bankBranch;
@override final  int publicRss;
@override final  String id;
@override final  String accountNumber;
@override final  int type;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodepayAccountCopyWith<_CodepayAccount> get copyWith => __$CodepayAccountCopyWithImpl<_CodepayAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CodepayAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodepayAccount&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.bankBranch, bankBranch) || other.bankBranch == bankBranch)&&(identical(other.publicRss, publicRss) || other.publicRss == publicRss)&&(identical(other.id, id) || other.id == id)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountName,bankBranch,publicRss,id,accountNumber,type);

@override
String toString() {
  return 'CodepayAccount(bankId: $bankId, accountName: $accountName, bankBranch: $bankBranch, publicRss: $publicRss, id: $id, accountNumber: $accountNumber, type: $type)';
}

}

abstract mixin class _$CodepayAccountCopyWith<$Res> implements $CodepayAccountCopyWith<$Res> {
  factory _$CodepayAccountCopyWith(_CodepayAccount value, $Res Function(_CodepayAccount) _then) = __$CodepayAccountCopyWithImpl;
@override @useResult
$Res call({
 String bankId, String accountName,@BankBranchConverter() BankBranch bankBranch, int publicRss, String id, String accountNumber, int type
});

}
class __$CodepayAccountCopyWithImpl<$Res>
    implements _$CodepayAccountCopyWith<$Res> {
  __$CodepayAccountCopyWithImpl(this._self, this._then);

  final _CodepayAccount _self;
  final $Res Function(_CodepayAccount) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? bankId = null,Object? accountName = null,Object? bankBranch = null,Object? publicRss = null,Object? id = null,Object? accountNumber = null,Object? type = null,}) {
  return _then(_CodepayAccount(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,bankBranch: null == bankBranch ? _self.bankBranch : bankBranch // ignore: cast_nullable_to_non_nullable
as BankBranch,publicRss: null == publicRss ? _self.publicRss : publicRss // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

// dart format on
