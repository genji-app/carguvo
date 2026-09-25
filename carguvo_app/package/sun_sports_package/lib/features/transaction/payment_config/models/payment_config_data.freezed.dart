// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_config_data.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$PaymentConfigResponse {

@JsonKey(name: 'codePayHelpUrl') String? get codePayHelpUrl;@JsonKey(name: 'bankHelpUrl') String? get bankHelpUrl;@JsonKey(name: 'eWalletHelpUrl') String? get eWalletHelpUrl;@JsonKey(name: 'data') PaymentConfigData? get data;@JsonKey(name: 'status') int? get status;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentConfigResponseCopyWith<PaymentConfigResponse> get copyWith => _$PaymentConfigResponseCopyWithImpl<PaymentConfigResponse>(this as PaymentConfigResponse, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentConfigResponse&&(identical(other.codePayHelpUrl, codePayHelpUrl) || other.codePayHelpUrl == codePayHelpUrl)&&(identical(other.bankHelpUrl, bankHelpUrl) || other.bankHelpUrl == bankHelpUrl)&&(identical(other.eWalletHelpUrl, eWalletHelpUrl) || other.eWalletHelpUrl == eWalletHelpUrl)&&(identical(other.data, data) || other.data == data)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,codePayHelpUrl,bankHelpUrl,eWalletHelpUrl,data,status);

@override
String toString() {
  return 'PaymentConfigResponse(codePayHelpUrl: $codePayHelpUrl, bankHelpUrl: $bankHelpUrl, eWalletHelpUrl: $eWalletHelpUrl, data: $data, status: $status)';
}

}

abstract mixin class $PaymentConfigResponseCopyWith<$Res>  {
  factory $PaymentConfigResponseCopyWith(PaymentConfigResponse value, $Res Function(PaymentConfigResponse) _then) = _$PaymentConfigResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'codePayHelpUrl') String? codePayHelpUrl,@JsonKey(name: 'bankHelpUrl') String? bankHelpUrl,@JsonKey(name: 'eWalletHelpUrl') String? eWalletHelpUrl,@JsonKey(name: 'data') PaymentConfigData? data,@JsonKey(name: 'status') int? status
});

$PaymentConfigDataCopyWith<$Res>? get data;

}
class _$PaymentConfigResponseCopyWithImpl<$Res>
    implements $PaymentConfigResponseCopyWith<$Res> {
  _$PaymentConfigResponseCopyWithImpl(this._self, this._then);

  final PaymentConfigResponse _self;
  final $Res Function(PaymentConfigResponse) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? codePayHelpUrl = freezed,Object? bankHelpUrl = freezed,Object? eWalletHelpUrl = freezed,Object? data = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
codePayHelpUrl: freezed == codePayHelpUrl ? _self.codePayHelpUrl : codePayHelpUrl // ignore: cast_nullable_to_non_nullable
as String?,bankHelpUrl: freezed == bankHelpUrl ? _self.bankHelpUrl : bankHelpUrl // ignore: cast_nullable_to_non_nullable
as String?,eWalletHelpUrl: freezed == eWalletHelpUrl ? _self.eWalletHelpUrl : eWalletHelpUrl // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PaymentConfigData?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
@override
@pragma('vm:prefer-inline')
$PaymentConfigDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $PaymentConfigDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

extension PaymentConfigResponsePatterns on PaymentConfigResponse {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentConfigResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentConfigResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentConfigResponse value)  $default,){
final _that = this;
switch (_that) {
case _PaymentConfigResponse():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentConfigResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentConfigResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'codePayHelpUrl')  String? codePayHelpUrl, @JsonKey(name: 'bankHelpUrl')  String? bankHelpUrl, @JsonKey(name: 'eWalletHelpUrl')  String? eWalletHelpUrl, @JsonKey(name: 'data')  PaymentConfigData? data, @JsonKey(name: 'status')  int? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentConfigResponse() when $default != null:
return $default(_that.codePayHelpUrl,_that.bankHelpUrl,_that.eWalletHelpUrl,_that.data,_that.status);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'codePayHelpUrl')  String? codePayHelpUrl, @JsonKey(name: 'bankHelpUrl')  String? bankHelpUrl, @JsonKey(name: 'eWalletHelpUrl')  String? eWalletHelpUrl, @JsonKey(name: 'data')  PaymentConfigData? data, @JsonKey(name: 'status')  int? status)  $default,) {final _that = this;
switch (_that) {
case _PaymentConfigResponse():
return $default(_that.codePayHelpUrl,_that.bankHelpUrl,_that.eWalletHelpUrl,_that.data,_that.status);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'codePayHelpUrl')  String? codePayHelpUrl, @JsonKey(name: 'bankHelpUrl')  String? bankHelpUrl, @JsonKey(name: 'eWalletHelpUrl')  String? eWalletHelpUrl, @JsonKey(name: 'data')  PaymentConfigData? data, @JsonKey(name: 'status')  int? status)?  $default,) {final _that = this;
switch (_that) {
case _PaymentConfigResponse() when $default != null:
return $default(_that.codePayHelpUrl,_that.bankHelpUrl,_that.eWalletHelpUrl,_that.data,_that.status);case _:
  return null;

}
}

}

@JsonSerializable()

class _PaymentConfigResponse implements PaymentConfigResponse {
  const _PaymentConfigResponse({@JsonKey(name: 'codePayHelpUrl') this.codePayHelpUrl, @JsonKey(name: 'bankHelpUrl') this.bankHelpUrl, @JsonKey(name: 'eWalletHelpUrl') this.eWalletHelpUrl, @JsonKey(name: 'data') this.data, @JsonKey(name: 'status') this.status});
  factory _PaymentConfigResponse.fromJson(Map<String, dynamic> json) => _$PaymentConfigResponseFromJson(json);

@override@JsonKey(name: 'codePayHelpUrl') final  String? codePayHelpUrl;
@override@JsonKey(name: 'bankHelpUrl') final  String? bankHelpUrl;
@override@JsonKey(name: 'eWalletHelpUrl') final  String? eWalletHelpUrl;
@override@JsonKey(name: 'data') final  PaymentConfigData? data;
@override@JsonKey(name: 'status') final  int? status;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentConfigResponseCopyWith<_PaymentConfigResponse> get copyWith => __$PaymentConfigResponseCopyWithImpl<_PaymentConfigResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentConfigResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentConfigResponse&&(identical(other.codePayHelpUrl, codePayHelpUrl) || other.codePayHelpUrl == codePayHelpUrl)&&(identical(other.bankHelpUrl, bankHelpUrl) || other.bankHelpUrl == bankHelpUrl)&&(identical(other.eWalletHelpUrl, eWalletHelpUrl) || other.eWalletHelpUrl == eWalletHelpUrl)&&(identical(other.data, data) || other.data == data)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,codePayHelpUrl,bankHelpUrl,eWalletHelpUrl,data,status);

@override
String toString() {
  return 'PaymentConfigResponse(codePayHelpUrl: $codePayHelpUrl, bankHelpUrl: $bankHelpUrl, eWalletHelpUrl: $eWalletHelpUrl, data: $data, status: $status)';
}

}

abstract mixin class _$PaymentConfigResponseCopyWith<$Res> implements $PaymentConfigResponseCopyWith<$Res> {
  factory _$PaymentConfigResponseCopyWith(_PaymentConfigResponse value, $Res Function(_PaymentConfigResponse) _then) = __$PaymentConfigResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'codePayHelpUrl') String? codePayHelpUrl,@JsonKey(name: 'bankHelpUrl') String? bankHelpUrl,@JsonKey(name: 'eWalletHelpUrl') String? eWalletHelpUrl,@JsonKey(name: 'data') PaymentConfigData? data,@JsonKey(name: 'status') int? status
});

@override $PaymentConfigDataCopyWith<$Res>? get data;

}
class __$PaymentConfigResponseCopyWithImpl<$Res>
    implements _$PaymentConfigResponseCopyWith<$Res> {
  __$PaymentConfigResponseCopyWithImpl(this._self, this._then);

  final _PaymentConfigResponse _self;
  final $Res Function(_PaymentConfigResponse) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? codePayHelpUrl = freezed,Object? bankHelpUrl = freezed,Object? eWalletHelpUrl = freezed,Object? data = freezed,Object? status = freezed,}) {
  return _then(_PaymentConfigResponse(
codePayHelpUrl: freezed == codePayHelpUrl ? _self.codePayHelpUrl : codePayHelpUrl // ignore: cast_nullable_to_non_nullable
as String?,bankHelpUrl: freezed == bankHelpUrl ? _self.bankHelpUrl : bankHelpUrl // ignore: cast_nullable_to_non_nullable
as String?,eWalletHelpUrl: freezed == eWalletHelpUrl ? _self.eWalletHelpUrl : eWalletHelpUrl // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PaymentConfigData?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

@override
@pragma('vm:prefer-inline')
$PaymentConfigDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $PaymentConfigDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

mixin _$PaymentConfigData {

@JsonKey(name: 'minTranfer') int? get minTransfer;@JsonKey(name: 'needVerifyBankAccount') bool? get needVerifyBankAccount;@JsonKey(name: 'smartOTPRegistered') bool? get smartOTPRegistered;@JsonKey(name: 'batCK') bool? get batCK;@JsonKey(name: 'tranferTax') double? get transferTax;@JsonKey(name: 'sSportUrl') String? get sSportUrl;@JsonKey(name: 'depositTypes') List<DepositType>? get depositTypes;@JsonKey(name: 'telcos') List<Telco>? get telcos;@JsonKey(name: 'codepay') List<CodePayBank>? get codepay;@JsonKey(name: 'items') List<BankItem>? get items;@JsonKey(name: 'crypto') List<CryptoConfig>? get crypto;@JsonKey(name: 'digitalWallets') List<dynamic>? get digitalWallets;@JsonKey(name: 'verifiedAccountHolder') List<String>? get verifiedAccountHolder;@JsonKey(name: 'verifiedBankAccounts') List<VerifiedBankAccount>? get verifiedBankAccounts;@JsonKey(name: 'cashoutGiftCards') List<CashoutGiftCard>? get cashoutGiftCards;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentConfigDataCopyWith<PaymentConfigData> get copyWith => _$PaymentConfigDataCopyWithImpl<PaymentConfigData>(this as PaymentConfigData, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentConfigData&&(identical(other.minTransfer, minTransfer) || other.minTransfer == minTransfer)&&(identical(other.needVerifyBankAccount, needVerifyBankAccount) || other.needVerifyBankAccount == needVerifyBankAccount)&&(identical(other.smartOTPRegistered, smartOTPRegistered) || other.smartOTPRegistered == smartOTPRegistered)&&(identical(other.batCK, batCK) || other.batCK == batCK)&&(identical(other.transferTax, transferTax) || other.transferTax == transferTax)&&(identical(other.sSportUrl, sSportUrl) || other.sSportUrl == sSportUrl)&&const DeepCollectionEquality().equals(other.depositTypes, depositTypes)&&const DeepCollectionEquality().equals(other.telcos, telcos)&&const DeepCollectionEquality().equals(other.codepay, codepay)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.crypto, crypto)&&const DeepCollectionEquality().equals(other.digitalWallets, digitalWallets)&&const DeepCollectionEquality().equals(other.verifiedAccountHolder, verifiedAccountHolder)&&const DeepCollectionEquality().equals(other.verifiedBankAccounts, verifiedBankAccounts)&&const DeepCollectionEquality().equals(other.cashoutGiftCards, cashoutGiftCards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minTransfer,needVerifyBankAccount,smartOTPRegistered,batCK,transferTax,sSportUrl,const DeepCollectionEquality().hash(depositTypes),const DeepCollectionEquality().hash(telcos),const DeepCollectionEquality().hash(codepay),const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(crypto),const DeepCollectionEquality().hash(digitalWallets),const DeepCollectionEquality().hash(verifiedAccountHolder),const DeepCollectionEquality().hash(verifiedBankAccounts),const DeepCollectionEquality().hash(cashoutGiftCards));

@override
String toString() {
  return 'PaymentConfigData(minTransfer: $minTransfer, needVerifyBankAccount: $needVerifyBankAccount, smartOTPRegistered: $smartOTPRegistered, batCK: $batCK, transferTax: $transferTax, sSportUrl: $sSportUrl, depositTypes: $depositTypes, telcos: $telcos, codepay: $codepay, items: $items, crypto: $crypto, digitalWallets: $digitalWallets, verifiedAccountHolder: $verifiedAccountHolder, verifiedBankAccounts: $verifiedBankAccounts, cashoutGiftCards: $cashoutGiftCards)';
}

}

abstract mixin class $PaymentConfigDataCopyWith<$Res>  {
  factory $PaymentConfigDataCopyWith(PaymentConfigData value, $Res Function(PaymentConfigData) _then) = _$PaymentConfigDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'minTranfer') int? minTransfer,@JsonKey(name: 'needVerifyBankAccount') bool? needVerifyBankAccount,@JsonKey(name: 'smartOTPRegistered') bool? smartOTPRegistered,@JsonKey(name: 'batCK') bool? batCK,@JsonKey(name: 'tranferTax') double? transferTax,@JsonKey(name: 'sSportUrl') String? sSportUrl,@JsonKey(name: 'depositTypes') List<DepositType>? depositTypes,@JsonKey(name: 'telcos') List<Telco>? telcos,@JsonKey(name: 'codepay') List<CodePayBank>? codepay,@JsonKey(name: 'items') List<BankItem>? items,@JsonKey(name: 'crypto') List<CryptoConfig>? crypto,@JsonKey(name: 'digitalWallets') List<dynamic>? digitalWallets,@JsonKey(name: 'verifiedAccountHolder') List<String>? verifiedAccountHolder,@JsonKey(name: 'verifiedBankAccounts') List<VerifiedBankAccount>? verifiedBankAccounts,@JsonKey(name: 'cashoutGiftCards') List<CashoutGiftCard>? cashoutGiftCards
});

}
class _$PaymentConfigDataCopyWithImpl<$Res>
    implements $PaymentConfigDataCopyWith<$Res> {
  _$PaymentConfigDataCopyWithImpl(this._self, this._then);

  final PaymentConfigData _self;
  final $Res Function(PaymentConfigData) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? minTransfer = freezed,Object? needVerifyBankAccount = freezed,Object? smartOTPRegistered = freezed,Object? batCK = freezed,Object? transferTax = freezed,Object? sSportUrl = freezed,Object? depositTypes = freezed,Object? telcos = freezed,Object? codepay = freezed,Object? items = freezed,Object? crypto = freezed,Object? digitalWallets = freezed,Object? verifiedAccountHolder = freezed,Object? verifiedBankAccounts = freezed,Object? cashoutGiftCards = freezed,}) {
  return _then(_self.copyWith(
minTransfer: freezed == minTransfer ? _self.minTransfer : minTransfer // ignore: cast_nullable_to_non_nullable
as int?,needVerifyBankAccount: freezed == needVerifyBankAccount ? _self.needVerifyBankAccount : needVerifyBankAccount // ignore: cast_nullable_to_non_nullable
as bool?,smartOTPRegistered: freezed == smartOTPRegistered ? _self.smartOTPRegistered : smartOTPRegistered // ignore: cast_nullable_to_non_nullable
as bool?,batCK: freezed == batCK ? _self.batCK : batCK // ignore: cast_nullable_to_non_nullable
as bool?,transferTax: freezed == transferTax ? _self.transferTax : transferTax // ignore: cast_nullable_to_non_nullable
as double?,sSportUrl: freezed == sSportUrl ? _self.sSportUrl : sSportUrl // ignore: cast_nullable_to_non_nullable
as String?,depositTypes: freezed == depositTypes ? _self.depositTypes : depositTypes // ignore: cast_nullable_to_non_nullable
as List<DepositType>?,telcos: freezed == telcos ? _self.telcos : telcos // ignore: cast_nullable_to_non_nullable
as List<Telco>?,codepay: freezed == codepay ? _self.codepay : codepay // ignore: cast_nullable_to_non_nullable
as List<CodePayBank>?,items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BankItem>?,crypto: freezed == crypto ? _self.crypto : crypto // ignore: cast_nullable_to_non_nullable
as List<CryptoConfig>?,digitalWallets: freezed == digitalWallets ? _self.digitalWallets : digitalWallets // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,verifiedAccountHolder: freezed == verifiedAccountHolder ? _self.verifiedAccountHolder : verifiedAccountHolder // ignore: cast_nullable_to_non_nullable
as List<String>?,verifiedBankAccounts: freezed == verifiedBankAccounts ? _self.verifiedBankAccounts : verifiedBankAccounts // ignore: cast_nullable_to_non_nullable
as List<VerifiedBankAccount>?,cashoutGiftCards: freezed == cashoutGiftCards ? _self.cashoutGiftCards : cashoutGiftCards // ignore: cast_nullable_to_non_nullable
as List<CashoutGiftCard>?,
  ));
}

}

extension PaymentConfigDataPatterns on PaymentConfigData {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentConfigData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentConfigData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentConfigData value)  $default,){
final _that = this;
switch (_that) {
case _PaymentConfigData():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentConfigData value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentConfigData() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'minTranfer')  int? minTransfer, @JsonKey(name: 'needVerifyBankAccount')  bool? needVerifyBankAccount, @JsonKey(name: 'smartOTPRegistered')  bool? smartOTPRegistered, @JsonKey(name: 'batCK')  bool? batCK, @JsonKey(name: 'tranferTax')  double? transferTax, @JsonKey(name: 'sSportUrl')  String? sSportUrl, @JsonKey(name: 'depositTypes')  List<DepositType>? depositTypes, @JsonKey(name: 'telcos')  List<Telco>? telcos, @JsonKey(name: 'codepay')  List<CodePayBank>? codepay, @JsonKey(name: 'items')  List<BankItem>? items, @JsonKey(name: 'crypto')  List<CryptoConfig>? crypto, @JsonKey(name: 'digitalWallets')  List<dynamic>? digitalWallets, @JsonKey(name: 'verifiedAccountHolder')  List<String>? verifiedAccountHolder, @JsonKey(name: 'verifiedBankAccounts')  List<VerifiedBankAccount>? verifiedBankAccounts, @JsonKey(name: 'cashoutGiftCards')  List<CashoutGiftCard>? cashoutGiftCards)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentConfigData() when $default != null:
return $default(_that.minTransfer,_that.needVerifyBankAccount,_that.smartOTPRegistered,_that.batCK,_that.transferTax,_that.sSportUrl,_that.depositTypes,_that.telcos,_that.codepay,_that.items,_that.crypto,_that.digitalWallets,_that.verifiedAccountHolder,_that.verifiedBankAccounts,_that.cashoutGiftCards);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'minTranfer')  int? minTransfer, @JsonKey(name: 'needVerifyBankAccount')  bool? needVerifyBankAccount, @JsonKey(name: 'smartOTPRegistered')  bool? smartOTPRegistered, @JsonKey(name: 'batCK')  bool? batCK, @JsonKey(name: 'tranferTax')  double? transferTax, @JsonKey(name: 'sSportUrl')  String? sSportUrl, @JsonKey(name: 'depositTypes')  List<DepositType>? depositTypes, @JsonKey(name: 'telcos')  List<Telco>? telcos, @JsonKey(name: 'codepay')  List<CodePayBank>? codepay, @JsonKey(name: 'items')  List<BankItem>? items, @JsonKey(name: 'crypto')  List<CryptoConfig>? crypto, @JsonKey(name: 'digitalWallets')  List<dynamic>? digitalWallets, @JsonKey(name: 'verifiedAccountHolder')  List<String>? verifiedAccountHolder, @JsonKey(name: 'verifiedBankAccounts')  List<VerifiedBankAccount>? verifiedBankAccounts, @JsonKey(name: 'cashoutGiftCards')  List<CashoutGiftCard>? cashoutGiftCards)  $default,) {final _that = this;
switch (_that) {
case _PaymentConfigData():
return $default(_that.minTransfer,_that.needVerifyBankAccount,_that.smartOTPRegistered,_that.batCK,_that.transferTax,_that.sSportUrl,_that.depositTypes,_that.telcos,_that.codepay,_that.items,_that.crypto,_that.digitalWallets,_that.verifiedAccountHolder,_that.verifiedBankAccounts,_that.cashoutGiftCards);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'minTranfer')  int? minTransfer, @JsonKey(name: 'needVerifyBankAccount')  bool? needVerifyBankAccount, @JsonKey(name: 'smartOTPRegistered')  bool? smartOTPRegistered, @JsonKey(name: 'batCK')  bool? batCK, @JsonKey(name: 'tranferTax')  double? transferTax, @JsonKey(name: 'sSportUrl')  String? sSportUrl, @JsonKey(name: 'depositTypes')  List<DepositType>? depositTypes, @JsonKey(name: 'telcos')  List<Telco>? telcos, @JsonKey(name: 'codepay')  List<CodePayBank>? codepay, @JsonKey(name: 'items')  List<BankItem>? items, @JsonKey(name: 'crypto')  List<CryptoConfig>? crypto, @JsonKey(name: 'digitalWallets')  List<dynamic>? digitalWallets, @JsonKey(name: 'verifiedAccountHolder')  List<String>? verifiedAccountHolder, @JsonKey(name: 'verifiedBankAccounts')  List<VerifiedBankAccount>? verifiedBankAccounts, @JsonKey(name: 'cashoutGiftCards')  List<CashoutGiftCard>? cashoutGiftCards)?  $default,) {final _that = this;
switch (_that) {
case _PaymentConfigData() when $default != null:
return $default(_that.minTransfer,_that.needVerifyBankAccount,_that.smartOTPRegistered,_that.batCK,_that.transferTax,_that.sSportUrl,_that.depositTypes,_that.telcos,_that.codepay,_that.items,_that.crypto,_that.digitalWallets,_that.verifiedAccountHolder,_that.verifiedBankAccounts,_that.cashoutGiftCards);case _:
  return null;

}
}

}

@JsonSerializable()

class _PaymentConfigData implements PaymentConfigData {
  const _PaymentConfigData({@JsonKey(name: 'minTranfer') this.minTransfer, @JsonKey(name: 'needVerifyBankAccount') this.needVerifyBankAccount, @JsonKey(name: 'smartOTPRegistered') this.smartOTPRegistered, @JsonKey(name: 'batCK') this.batCK, @JsonKey(name: 'tranferTax') this.transferTax, @JsonKey(name: 'sSportUrl') this.sSportUrl, @JsonKey(name: 'depositTypes') final  List<DepositType>? depositTypes, @JsonKey(name: 'telcos') final  List<Telco>? telcos, @JsonKey(name: 'codepay') final  List<CodePayBank>? codepay, @JsonKey(name: 'items') final  List<BankItem>? items, @JsonKey(name: 'crypto') final  List<CryptoConfig>? crypto, @JsonKey(name: 'digitalWallets') final  List<dynamic>? digitalWallets, @JsonKey(name: 'verifiedAccountHolder') final  List<String>? verifiedAccountHolder, @JsonKey(name: 'verifiedBankAccounts') final  List<VerifiedBankAccount>? verifiedBankAccounts, @JsonKey(name: 'cashoutGiftCards') final  List<CashoutGiftCard>? cashoutGiftCards}): _depositTypes = depositTypes,_telcos = telcos,_codepay = codepay,_items = items,_crypto = crypto,_digitalWallets = digitalWallets,_verifiedAccountHolder = verifiedAccountHolder,_verifiedBankAccounts = verifiedBankAccounts,_cashoutGiftCards = cashoutGiftCards;
  factory _PaymentConfigData.fromJson(Map<String, dynamic> json) => _$PaymentConfigDataFromJson(json);

@override@JsonKey(name: 'minTranfer') final  int? minTransfer;
@override@JsonKey(name: 'needVerifyBankAccount') final  bool? needVerifyBankAccount;
@override@JsonKey(name: 'smartOTPRegistered') final  bool? smartOTPRegistered;
@override@JsonKey(name: 'batCK') final  bool? batCK;
@override@JsonKey(name: 'tranferTax') final  double? transferTax;
@override@JsonKey(name: 'sSportUrl') final  String? sSportUrl;
 final  List<DepositType>? _depositTypes;
@override@JsonKey(name: 'depositTypes') List<DepositType>? get depositTypes {
  final value = _depositTypes;
  if (value == null) return null;
  if (_depositTypes is EqualUnmodifiableListView) return _depositTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Telco>? _telcos;
@override@JsonKey(name: 'telcos') List<Telco>? get telcos {
  final value = _telcos;
  if (value == null) return null;
  if (_telcos is EqualUnmodifiableListView) return _telcos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<CodePayBank>? _codepay;
@override@JsonKey(name: 'codepay') List<CodePayBank>? get codepay {
  final value = _codepay;
  if (value == null) return null;
  if (_codepay is EqualUnmodifiableListView) return _codepay;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<BankItem>? _items;
@override@JsonKey(name: 'items') List<BankItem>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<CryptoConfig>? _crypto;
@override@JsonKey(name: 'crypto') List<CryptoConfig>? get crypto {
  final value = _crypto;
  if (value == null) return null;
  if (_crypto is EqualUnmodifiableListView) return _crypto;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<dynamic>? _digitalWallets;
@override@JsonKey(name: 'digitalWallets') List<dynamic>? get digitalWallets {
  final value = _digitalWallets;
  if (value == null) return null;
  if (_digitalWallets is EqualUnmodifiableListView) return _digitalWallets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _verifiedAccountHolder;
@override@JsonKey(name: 'verifiedAccountHolder') List<String>? get verifiedAccountHolder {
  final value = _verifiedAccountHolder;
  if (value == null) return null;
  if (_verifiedAccountHolder is EqualUnmodifiableListView) return _verifiedAccountHolder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<VerifiedBankAccount>? _verifiedBankAccounts;
@override@JsonKey(name: 'verifiedBankAccounts') List<VerifiedBankAccount>? get verifiedBankAccounts {
  final value = _verifiedBankAccounts;
  if (value == null) return null;
  if (_verifiedBankAccounts is EqualUnmodifiableListView) return _verifiedBankAccounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<CashoutGiftCard>? _cashoutGiftCards;
@override@JsonKey(name: 'cashoutGiftCards') List<CashoutGiftCard>? get cashoutGiftCards {
  final value = _cashoutGiftCards;
  if (value == null) return null;
  if (_cashoutGiftCards is EqualUnmodifiableListView) return _cashoutGiftCards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentConfigDataCopyWith<_PaymentConfigData> get copyWith => __$PaymentConfigDataCopyWithImpl<_PaymentConfigData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentConfigDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentConfigData&&(identical(other.minTransfer, minTransfer) || other.minTransfer == minTransfer)&&(identical(other.needVerifyBankAccount, needVerifyBankAccount) || other.needVerifyBankAccount == needVerifyBankAccount)&&(identical(other.smartOTPRegistered, smartOTPRegistered) || other.smartOTPRegistered == smartOTPRegistered)&&(identical(other.batCK, batCK) || other.batCK == batCK)&&(identical(other.transferTax, transferTax) || other.transferTax == transferTax)&&(identical(other.sSportUrl, sSportUrl) || other.sSportUrl == sSportUrl)&&const DeepCollectionEquality().equals(other._depositTypes, _depositTypes)&&const DeepCollectionEquality().equals(other._telcos, _telcos)&&const DeepCollectionEquality().equals(other._codepay, _codepay)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._crypto, _crypto)&&const DeepCollectionEquality().equals(other._digitalWallets, _digitalWallets)&&const DeepCollectionEquality().equals(other._verifiedAccountHolder, _verifiedAccountHolder)&&const DeepCollectionEquality().equals(other._verifiedBankAccounts, _verifiedBankAccounts)&&const DeepCollectionEquality().equals(other._cashoutGiftCards, _cashoutGiftCards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minTransfer,needVerifyBankAccount,smartOTPRegistered,batCK,transferTax,sSportUrl,const DeepCollectionEquality().hash(_depositTypes),const DeepCollectionEquality().hash(_telcos),const DeepCollectionEquality().hash(_codepay),const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_crypto),const DeepCollectionEquality().hash(_digitalWallets),const DeepCollectionEquality().hash(_verifiedAccountHolder),const DeepCollectionEquality().hash(_verifiedBankAccounts),const DeepCollectionEquality().hash(_cashoutGiftCards));

@override
String toString() {
  return 'PaymentConfigData(minTransfer: $minTransfer, needVerifyBankAccount: $needVerifyBankAccount, smartOTPRegistered: $smartOTPRegistered, batCK: $batCK, transferTax: $transferTax, sSportUrl: $sSportUrl, depositTypes: $depositTypes, telcos: $telcos, codepay: $codepay, items: $items, crypto: $crypto, digitalWallets: $digitalWallets, verifiedAccountHolder: $verifiedAccountHolder, verifiedBankAccounts: $verifiedBankAccounts, cashoutGiftCards: $cashoutGiftCards)';
}

}

abstract mixin class _$PaymentConfigDataCopyWith<$Res> implements $PaymentConfigDataCopyWith<$Res> {
  factory _$PaymentConfigDataCopyWith(_PaymentConfigData value, $Res Function(_PaymentConfigData) _then) = __$PaymentConfigDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'minTranfer') int? minTransfer,@JsonKey(name: 'needVerifyBankAccount') bool? needVerifyBankAccount,@JsonKey(name: 'smartOTPRegistered') bool? smartOTPRegistered,@JsonKey(name: 'batCK') bool? batCK,@JsonKey(name: 'tranferTax') double? transferTax,@JsonKey(name: 'sSportUrl') String? sSportUrl,@JsonKey(name: 'depositTypes') List<DepositType>? depositTypes,@JsonKey(name: 'telcos') List<Telco>? telcos,@JsonKey(name: 'codepay') List<CodePayBank>? codepay,@JsonKey(name: 'items') List<BankItem>? items,@JsonKey(name: 'crypto') List<CryptoConfig>? crypto,@JsonKey(name: 'digitalWallets') List<dynamic>? digitalWallets,@JsonKey(name: 'verifiedAccountHolder') List<String>? verifiedAccountHolder,@JsonKey(name: 'verifiedBankAccounts') List<VerifiedBankAccount>? verifiedBankAccounts,@JsonKey(name: 'cashoutGiftCards') List<CashoutGiftCard>? cashoutGiftCards
});

}
class __$PaymentConfigDataCopyWithImpl<$Res>
    implements _$PaymentConfigDataCopyWith<$Res> {
  __$PaymentConfigDataCopyWithImpl(this._self, this._then);

  final _PaymentConfigData _self;
  final $Res Function(_PaymentConfigData) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? minTransfer = freezed,Object? needVerifyBankAccount = freezed,Object? smartOTPRegistered = freezed,Object? batCK = freezed,Object? transferTax = freezed,Object? sSportUrl = freezed,Object? depositTypes = freezed,Object? telcos = freezed,Object? codepay = freezed,Object? items = freezed,Object? crypto = freezed,Object? digitalWallets = freezed,Object? verifiedAccountHolder = freezed,Object? verifiedBankAccounts = freezed,Object? cashoutGiftCards = freezed,}) {
  return _then(_PaymentConfigData(
minTransfer: freezed == minTransfer ? _self.minTransfer : minTransfer // ignore: cast_nullable_to_non_nullable
as int?,needVerifyBankAccount: freezed == needVerifyBankAccount ? _self.needVerifyBankAccount : needVerifyBankAccount // ignore: cast_nullable_to_non_nullable
as bool?,smartOTPRegistered: freezed == smartOTPRegistered ? _self.smartOTPRegistered : smartOTPRegistered // ignore: cast_nullable_to_non_nullable
as bool?,batCK: freezed == batCK ? _self.batCK : batCK // ignore: cast_nullable_to_non_nullable
as bool?,transferTax: freezed == transferTax ? _self.transferTax : transferTax // ignore: cast_nullable_to_non_nullable
as double?,sSportUrl: freezed == sSportUrl ? _self.sSportUrl : sSportUrl // ignore: cast_nullable_to_non_nullable
as String?,depositTypes: freezed == depositTypes ? _self._depositTypes : depositTypes // ignore: cast_nullable_to_non_nullable
as List<DepositType>?,telcos: freezed == telcos ? _self._telcos : telcos // ignore: cast_nullable_to_non_nullable
as List<Telco>?,codepay: freezed == codepay ? _self._codepay : codepay // ignore: cast_nullable_to_non_nullable
as List<CodePayBank>?,items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<BankItem>?,crypto: freezed == crypto ? _self._crypto : crypto // ignore: cast_nullable_to_non_nullable
as List<CryptoConfig>?,digitalWallets: freezed == digitalWallets ? _self._digitalWallets : digitalWallets // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,verifiedAccountHolder: freezed == verifiedAccountHolder ? _self._verifiedAccountHolder : verifiedAccountHolder // ignore: cast_nullable_to_non_nullable
as List<String>?,verifiedBankAccounts: freezed == verifiedBankAccounts ? _self._verifiedBankAccounts : verifiedBankAccounts // ignore: cast_nullable_to_non_nullable
as List<VerifiedBankAccount>?,cashoutGiftCards: freezed == cashoutGiftCards ? _self._cashoutGiftCards : cashoutGiftCards // ignore: cast_nullable_to_non_nullable
as List<CashoutGiftCard>?,
  ));
}

}

// dart format on
