// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fetch_bank_account_data.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$FetchBankAccountsData {

 int get minTranfer; List<CashoutGiftCard> get cashoutGiftCards; List<dynamic> get digitalWallets;@JsonKey(name: 'smartOTPRegistered') bool get smartOtpRegistered; List<CryptoDepositOption> get crypto;@JsonKey(name: 'batCK') bool get batCk; int get tranferTax; String get sSportUrl; List<DepositType> get depositTypes; List<CashoutGiftCard> get telcos; List<CodepayBank> get codepay; bool get needVerifyBankAccount; List<dynamic> get verifiedAccountHolder; List<BankAccountItem> get items; List<VerifiedBankAccount> get verifiedBankAccounts;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FetchBankAccountsDataCopyWith<FetchBankAccountsData> get copyWith => _$FetchBankAccountsDataCopyWithImpl<FetchBankAccountsData>(this as FetchBankAccountsData, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FetchBankAccountsData&&(identical(other.minTranfer, minTranfer) || other.minTranfer == minTranfer)&&const DeepCollectionEquality().equals(other.cashoutGiftCards, cashoutGiftCards)&&const DeepCollectionEquality().equals(other.digitalWallets, digitalWallets)&&(identical(other.smartOtpRegistered, smartOtpRegistered) || other.smartOtpRegistered == smartOtpRegistered)&&const DeepCollectionEquality().equals(other.crypto, crypto)&&(identical(other.batCk, batCk) || other.batCk == batCk)&&(identical(other.tranferTax, tranferTax) || other.tranferTax == tranferTax)&&(identical(other.sSportUrl, sSportUrl) || other.sSportUrl == sSportUrl)&&const DeepCollectionEquality().equals(other.depositTypes, depositTypes)&&const DeepCollectionEquality().equals(other.telcos, telcos)&&const DeepCollectionEquality().equals(other.codepay, codepay)&&(identical(other.needVerifyBankAccount, needVerifyBankAccount) || other.needVerifyBankAccount == needVerifyBankAccount)&&const DeepCollectionEquality().equals(other.verifiedAccountHolder, verifiedAccountHolder)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.verifiedBankAccounts, verifiedBankAccounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minTranfer,const DeepCollectionEquality().hash(cashoutGiftCards),const DeepCollectionEquality().hash(digitalWallets),smartOtpRegistered,const DeepCollectionEquality().hash(crypto),batCk,tranferTax,sSportUrl,const DeepCollectionEquality().hash(depositTypes),const DeepCollectionEquality().hash(telcos),const DeepCollectionEquality().hash(codepay),needVerifyBankAccount,const DeepCollectionEquality().hash(verifiedAccountHolder),const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(verifiedBankAccounts));

@override
String toString() {
  return 'FetchBankAccountsData(minTranfer: $minTranfer, cashoutGiftCards: $cashoutGiftCards, digitalWallets: $digitalWallets, smartOtpRegistered: $smartOtpRegistered, crypto: $crypto, batCk: $batCk, tranferTax: $tranferTax, sSportUrl: $sSportUrl, depositTypes: $depositTypes, telcos: $telcos, codepay: $codepay, needVerifyBankAccount: $needVerifyBankAccount, verifiedAccountHolder: $verifiedAccountHolder, items: $items, verifiedBankAccounts: $verifiedBankAccounts)';
}

}

abstract mixin class $FetchBankAccountsDataCopyWith<$Res>  {
  factory $FetchBankAccountsDataCopyWith(FetchBankAccountsData value, $Res Function(FetchBankAccountsData) _then) = _$FetchBankAccountsDataCopyWithImpl;
@useResult
$Res call({
 int minTranfer, List<CashoutGiftCard> cashoutGiftCards, List<dynamic> digitalWallets,@JsonKey(name: 'smartOTPRegistered') bool smartOtpRegistered, List<CryptoDepositOption> crypto,@JsonKey(name: 'batCK') bool batCk, int tranferTax, String sSportUrl, List<DepositType> depositTypes, List<CashoutGiftCard> telcos, List<CodepayBank> codepay, bool needVerifyBankAccount, List<dynamic> verifiedAccountHolder, List<BankAccountItem> items, List<VerifiedBankAccount> verifiedBankAccounts
});

}
class _$FetchBankAccountsDataCopyWithImpl<$Res>
    implements $FetchBankAccountsDataCopyWith<$Res> {
  _$FetchBankAccountsDataCopyWithImpl(this._self, this._then);

  final FetchBankAccountsData _self;
  final $Res Function(FetchBankAccountsData) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? minTranfer = null,Object? cashoutGiftCards = null,Object? digitalWallets = null,Object? smartOtpRegistered = null,Object? crypto = null,Object? batCk = null,Object? tranferTax = null,Object? sSportUrl = null,Object? depositTypes = null,Object? telcos = null,Object? codepay = null,Object? needVerifyBankAccount = null,Object? verifiedAccountHolder = null,Object? items = null,Object? verifiedBankAccounts = null,}) {
  return _then(_self.copyWith(
minTranfer: null == minTranfer ? _self.minTranfer : minTranfer // ignore: cast_nullable_to_non_nullable
as int,cashoutGiftCards: null == cashoutGiftCards ? _self.cashoutGiftCards : cashoutGiftCards // ignore: cast_nullable_to_non_nullable
as List<CashoutGiftCard>,digitalWallets: null == digitalWallets ? _self.digitalWallets : digitalWallets // ignore: cast_nullable_to_non_nullable
as List<dynamic>,smartOtpRegistered: null == smartOtpRegistered ? _self.smartOtpRegistered : smartOtpRegistered // ignore: cast_nullable_to_non_nullable
as bool,crypto: null == crypto ? _self.crypto : crypto // ignore: cast_nullable_to_non_nullable
as List<CryptoDepositOption>,batCk: null == batCk ? _self.batCk : batCk // ignore: cast_nullable_to_non_nullable
as bool,tranferTax: null == tranferTax ? _self.tranferTax : tranferTax // ignore: cast_nullable_to_non_nullable
as int,sSportUrl: null == sSportUrl ? _self.sSportUrl : sSportUrl // ignore: cast_nullable_to_non_nullable
as String,depositTypes: null == depositTypes ? _self.depositTypes : depositTypes // ignore: cast_nullable_to_non_nullable
as List<DepositType>,telcos: null == telcos ? _self.telcos : telcos // ignore: cast_nullable_to_non_nullable
as List<CashoutGiftCard>,codepay: null == codepay ? _self.codepay : codepay // ignore: cast_nullable_to_non_nullable
as List<CodepayBank>,needVerifyBankAccount: null == needVerifyBankAccount ? _self.needVerifyBankAccount : needVerifyBankAccount // ignore: cast_nullable_to_non_nullable
as bool,verifiedAccountHolder: null == verifiedAccountHolder ? _self.verifiedAccountHolder : verifiedAccountHolder // ignore: cast_nullable_to_non_nullable
as List<dynamic>,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BankAccountItem>,verifiedBankAccounts: null == verifiedBankAccounts ? _self.verifiedBankAccounts : verifiedBankAccounts // ignore: cast_nullable_to_non_nullable
as List<VerifiedBankAccount>,
  ));
}

}

extension FetchBankAccountsDataPatterns on FetchBankAccountsData {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FetchBankAccountsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FetchBankAccountsData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FetchBankAccountsData value)  $default,){
final _that = this;
switch (_that) {
case _FetchBankAccountsData():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FetchBankAccountsData value)?  $default,){
final _that = this;
switch (_that) {
case _FetchBankAccountsData() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int minTranfer,  List<CashoutGiftCard> cashoutGiftCards,  List<dynamic> digitalWallets, @JsonKey(name: 'smartOTPRegistered')  bool smartOtpRegistered,  List<CryptoDepositOption> crypto, @JsonKey(name: 'batCK')  bool batCk,  int tranferTax,  String sSportUrl,  List<DepositType> depositTypes,  List<CashoutGiftCard> telcos,  List<CodepayBank> codepay,  bool needVerifyBankAccount,  List<dynamic> verifiedAccountHolder,  List<BankAccountItem> items,  List<VerifiedBankAccount> verifiedBankAccounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FetchBankAccountsData() when $default != null:
return $default(_that.minTranfer,_that.cashoutGiftCards,_that.digitalWallets,_that.smartOtpRegistered,_that.crypto,_that.batCk,_that.tranferTax,_that.sSportUrl,_that.depositTypes,_that.telcos,_that.codepay,_that.needVerifyBankAccount,_that.verifiedAccountHolder,_that.items,_that.verifiedBankAccounts);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int minTranfer,  List<CashoutGiftCard> cashoutGiftCards,  List<dynamic> digitalWallets, @JsonKey(name: 'smartOTPRegistered')  bool smartOtpRegistered,  List<CryptoDepositOption> crypto, @JsonKey(name: 'batCK')  bool batCk,  int tranferTax,  String sSportUrl,  List<DepositType> depositTypes,  List<CashoutGiftCard> telcos,  List<CodepayBank> codepay,  bool needVerifyBankAccount,  List<dynamic> verifiedAccountHolder,  List<BankAccountItem> items,  List<VerifiedBankAccount> verifiedBankAccounts)  $default,) {final _that = this;
switch (_that) {
case _FetchBankAccountsData():
return $default(_that.minTranfer,_that.cashoutGiftCards,_that.digitalWallets,_that.smartOtpRegistered,_that.crypto,_that.batCk,_that.tranferTax,_that.sSportUrl,_that.depositTypes,_that.telcos,_that.codepay,_that.needVerifyBankAccount,_that.verifiedAccountHolder,_that.items,_that.verifiedBankAccounts);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int minTranfer,  List<CashoutGiftCard> cashoutGiftCards,  List<dynamic> digitalWallets, @JsonKey(name: 'smartOTPRegistered')  bool smartOtpRegistered,  List<CryptoDepositOption> crypto, @JsonKey(name: 'batCK')  bool batCk,  int tranferTax,  String sSportUrl,  List<DepositType> depositTypes,  List<CashoutGiftCard> telcos,  List<CodepayBank> codepay,  bool needVerifyBankAccount,  List<dynamic> verifiedAccountHolder,  List<BankAccountItem> items,  List<VerifiedBankAccount> verifiedBankAccounts)?  $default,) {final _that = this;
switch (_that) {
case _FetchBankAccountsData() when $default != null:
return $default(_that.minTranfer,_that.cashoutGiftCards,_that.digitalWallets,_that.smartOtpRegistered,_that.crypto,_that.batCk,_that.tranferTax,_that.sSportUrl,_that.depositTypes,_that.telcos,_that.codepay,_that.needVerifyBankAccount,_that.verifiedAccountHolder,_that.items,_that.verifiedBankAccounts);case _:
  return null;

}
}

}

@JsonSerializable()

class _FetchBankAccountsData implements FetchBankAccountsData {
  const _FetchBankAccountsData({this.minTranfer = 0, final  List<CashoutGiftCard> cashoutGiftCards = const [], final  List<dynamic> digitalWallets = const [], @JsonKey(name: 'smartOTPRegistered') this.smartOtpRegistered = false, final  List<CryptoDepositOption> crypto = const [], @JsonKey(name: 'batCK') this.batCk = false, this.tranferTax = 0, this.sSportUrl = '', final  List<DepositType> depositTypes = const [], final  List<CashoutGiftCard> telcos = const [], final  List<CodepayBank> codepay = const [], this.needVerifyBankAccount = false, final  List<dynamic> verifiedAccountHolder = const [], final  List<BankAccountItem> items = const [], final  List<VerifiedBankAccount> verifiedBankAccounts = const []}): _cashoutGiftCards = cashoutGiftCards,_digitalWallets = digitalWallets,_crypto = crypto,_depositTypes = depositTypes,_telcos = telcos,_codepay = codepay,_verifiedAccountHolder = verifiedAccountHolder,_items = items,_verifiedBankAccounts = verifiedBankAccounts;
  factory _FetchBankAccountsData.fromJson(Map<String, dynamic> json) => _$FetchBankAccountsDataFromJson(json);

@override@JsonKey() final  int minTranfer;
 final  List<CashoutGiftCard> _cashoutGiftCards;
@override@JsonKey() List<CashoutGiftCard> get cashoutGiftCards {
  if (_cashoutGiftCards is EqualUnmodifiableListView) return _cashoutGiftCards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cashoutGiftCards);
}

 final  List<dynamic> _digitalWallets;
@override@JsonKey() List<dynamic> get digitalWallets {
  if (_digitalWallets is EqualUnmodifiableListView) return _digitalWallets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_digitalWallets);
}

@override@JsonKey(name: 'smartOTPRegistered') final  bool smartOtpRegistered;
 final  List<CryptoDepositOption> _crypto;
@override@JsonKey() List<CryptoDepositOption> get crypto {
  if (_crypto is EqualUnmodifiableListView) return _crypto;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_crypto);
}

@override@JsonKey(name: 'batCK') final  bool batCk;
@override@JsonKey() final  int tranferTax;
@override@JsonKey() final  String sSportUrl;
 final  List<DepositType> _depositTypes;
@override@JsonKey() List<DepositType> get depositTypes {
  if (_depositTypes is EqualUnmodifiableListView) return _depositTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_depositTypes);
}

 final  List<CashoutGiftCard> _telcos;
@override@JsonKey() List<CashoutGiftCard> get telcos {
  if (_telcos is EqualUnmodifiableListView) return _telcos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_telcos);
}

 final  List<CodepayBank> _codepay;
@override@JsonKey() List<CodepayBank> get codepay {
  if (_codepay is EqualUnmodifiableListView) return _codepay;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_codepay);
}

@override@JsonKey() final  bool needVerifyBankAccount;
 final  List<dynamic> _verifiedAccountHolder;
@override@JsonKey() List<dynamic> get verifiedAccountHolder {
  if (_verifiedAccountHolder is EqualUnmodifiableListView) return _verifiedAccountHolder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_verifiedAccountHolder);
}

 final  List<BankAccountItem> _items;
@override@JsonKey() List<BankAccountItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<VerifiedBankAccount> _verifiedBankAccounts;
@override@JsonKey() List<VerifiedBankAccount> get verifiedBankAccounts {
  if (_verifiedBankAccounts is EqualUnmodifiableListView) return _verifiedBankAccounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_verifiedBankAccounts);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FetchBankAccountsDataCopyWith<_FetchBankAccountsData> get copyWith => __$FetchBankAccountsDataCopyWithImpl<_FetchBankAccountsData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FetchBankAccountsDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchBankAccountsData&&(identical(other.minTranfer, minTranfer) || other.minTranfer == minTranfer)&&const DeepCollectionEquality().equals(other._cashoutGiftCards, _cashoutGiftCards)&&const DeepCollectionEquality().equals(other._digitalWallets, _digitalWallets)&&(identical(other.smartOtpRegistered, smartOtpRegistered) || other.smartOtpRegistered == smartOtpRegistered)&&const DeepCollectionEquality().equals(other._crypto, _crypto)&&(identical(other.batCk, batCk) || other.batCk == batCk)&&(identical(other.tranferTax, tranferTax) || other.tranferTax == tranferTax)&&(identical(other.sSportUrl, sSportUrl) || other.sSportUrl == sSportUrl)&&const DeepCollectionEquality().equals(other._depositTypes, _depositTypes)&&const DeepCollectionEquality().equals(other._telcos, _telcos)&&const DeepCollectionEquality().equals(other._codepay, _codepay)&&(identical(other.needVerifyBankAccount, needVerifyBankAccount) || other.needVerifyBankAccount == needVerifyBankAccount)&&const DeepCollectionEquality().equals(other._verifiedAccountHolder, _verifiedAccountHolder)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._verifiedBankAccounts, _verifiedBankAccounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minTranfer,const DeepCollectionEquality().hash(_cashoutGiftCards),const DeepCollectionEquality().hash(_digitalWallets),smartOtpRegistered,const DeepCollectionEquality().hash(_crypto),batCk,tranferTax,sSportUrl,const DeepCollectionEquality().hash(_depositTypes),const DeepCollectionEquality().hash(_telcos),const DeepCollectionEquality().hash(_codepay),needVerifyBankAccount,const DeepCollectionEquality().hash(_verifiedAccountHolder),const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_verifiedBankAccounts));

@override
String toString() {
  return 'FetchBankAccountsData(minTranfer: $minTranfer, cashoutGiftCards: $cashoutGiftCards, digitalWallets: $digitalWallets, smartOtpRegistered: $smartOtpRegistered, crypto: $crypto, batCk: $batCk, tranferTax: $tranferTax, sSportUrl: $sSportUrl, depositTypes: $depositTypes, telcos: $telcos, codepay: $codepay, needVerifyBankAccount: $needVerifyBankAccount, verifiedAccountHolder: $verifiedAccountHolder, items: $items, verifiedBankAccounts: $verifiedBankAccounts)';
}

}

abstract mixin class _$FetchBankAccountsDataCopyWith<$Res> implements $FetchBankAccountsDataCopyWith<$Res> {
  factory _$FetchBankAccountsDataCopyWith(_FetchBankAccountsData value, $Res Function(_FetchBankAccountsData) _then) = __$FetchBankAccountsDataCopyWithImpl;
@override @useResult
$Res call({
 int minTranfer, List<CashoutGiftCard> cashoutGiftCards, List<dynamic> digitalWallets,@JsonKey(name: 'smartOTPRegistered') bool smartOtpRegistered, List<CryptoDepositOption> crypto,@JsonKey(name: 'batCK') bool batCk, int tranferTax, String sSportUrl, List<DepositType> depositTypes, List<CashoutGiftCard> telcos, List<CodepayBank> codepay, bool needVerifyBankAccount, List<dynamic> verifiedAccountHolder, List<BankAccountItem> items, List<VerifiedBankAccount> verifiedBankAccounts
});

}
class __$FetchBankAccountsDataCopyWithImpl<$Res>
    implements _$FetchBankAccountsDataCopyWith<$Res> {
  __$FetchBankAccountsDataCopyWithImpl(this._self, this._then);

  final _FetchBankAccountsData _self;
  final $Res Function(_FetchBankAccountsData) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? minTranfer = null,Object? cashoutGiftCards = null,Object? digitalWallets = null,Object? smartOtpRegistered = null,Object? crypto = null,Object? batCk = null,Object? tranferTax = null,Object? sSportUrl = null,Object? depositTypes = null,Object? telcos = null,Object? codepay = null,Object? needVerifyBankAccount = null,Object? verifiedAccountHolder = null,Object? items = null,Object? verifiedBankAccounts = null,}) {
  return _then(_FetchBankAccountsData(
minTranfer: null == minTranfer ? _self.minTranfer : minTranfer // ignore: cast_nullable_to_non_nullable
as int,cashoutGiftCards: null == cashoutGiftCards ? _self._cashoutGiftCards : cashoutGiftCards // ignore: cast_nullable_to_non_nullable
as List<CashoutGiftCard>,digitalWallets: null == digitalWallets ? _self._digitalWallets : digitalWallets // ignore: cast_nullable_to_non_nullable
as List<dynamic>,smartOtpRegistered: null == smartOtpRegistered ? _self.smartOtpRegistered : smartOtpRegistered // ignore: cast_nullable_to_non_nullable
as bool,crypto: null == crypto ? _self._crypto : crypto // ignore: cast_nullable_to_non_nullable
as List<CryptoDepositOption>,batCk: null == batCk ? _self.batCk : batCk // ignore: cast_nullable_to_non_nullable
as bool,tranferTax: null == tranferTax ? _self.tranferTax : tranferTax // ignore: cast_nullable_to_non_nullable
as int,sSportUrl: null == sSportUrl ? _self.sSportUrl : sSportUrl // ignore: cast_nullable_to_non_nullable
as String,depositTypes: null == depositTypes ? _self._depositTypes : depositTypes // ignore: cast_nullable_to_non_nullable
as List<DepositType>,telcos: null == telcos ? _self._telcos : telcos // ignore: cast_nullable_to_non_nullable
as List<CashoutGiftCard>,codepay: null == codepay ? _self._codepay : codepay // ignore: cast_nullable_to_non_nullable
as List<CodepayBank>,needVerifyBankAccount: null == needVerifyBankAccount ? _self.needVerifyBankAccount : needVerifyBankAccount // ignore: cast_nullable_to_non_nullable
as bool,verifiedAccountHolder: null == verifiedAccountHolder ? _self._verifiedAccountHolder : verifiedAccountHolder // ignore: cast_nullable_to_non_nullable
as List<dynamic>,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<BankAccountItem>,verifiedBankAccounts: null == verifiedBankAccounts ? _self._verifiedBankAccounts : verifiedBankAccounts // ignore: cast_nullable_to_non_nullable
as List<VerifiedBankAccount>,
  ));
}

}

// dart format on
