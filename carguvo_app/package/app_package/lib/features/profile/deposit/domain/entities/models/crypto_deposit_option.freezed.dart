// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crypto_deposit_option.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$CryptoDepositOption {

 List<String> get depositNetworks; String get bankId; String get currencyName; String get exchangeRateString; int get exchangeRate; int get fee; String get network;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoDepositOptionCopyWith<CryptoDepositOption> get copyWith => _$CryptoDepositOptionCopyWithImpl<CryptoDepositOption>(this as CryptoDepositOption, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoDepositOption&&const DeepCollectionEquality().equals(other.depositNetworks, depositNetworks)&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.currencyName, currencyName) || other.currencyName == currencyName)&&(identical(other.exchangeRateString, exchangeRateString) || other.exchangeRateString == exchangeRateString)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.network, network) || other.network == network));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(depositNetworks),bankId,currencyName,exchangeRateString,exchangeRate,fee,network);

@override
String toString() {
  return 'CryptoDepositOption(depositNetworks: $depositNetworks, bankId: $bankId, currencyName: $currencyName, exchangeRateString: $exchangeRateString, exchangeRate: $exchangeRate, fee: $fee, network: $network)';
}

}

abstract mixin class $CryptoDepositOptionCopyWith<$Res>  {
  factory $CryptoDepositOptionCopyWith(CryptoDepositOption value, $Res Function(CryptoDepositOption) _then) = _$CryptoDepositOptionCopyWithImpl;
@useResult
$Res call({
 List<String> depositNetworks, String bankId, String currencyName, String exchangeRateString, int exchangeRate, int fee, String network
});

}
class _$CryptoDepositOptionCopyWithImpl<$Res>
    implements $CryptoDepositOptionCopyWith<$Res> {
  _$CryptoDepositOptionCopyWithImpl(this._self, this._then);

  final CryptoDepositOption _self;
  final $Res Function(CryptoDepositOption) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? depositNetworks = null,Object? bankId = null,Object? currencyName = null,Object? exchangeRateString = null,Object? exchangeRate = null,Object? fee = null,Object? network = null,}) {
  return _then(_self.copyWith(
depositNetworks: null == depositNetworks ? _self.depositNetworks : depositNetworks // ignore: cast_nullable_to_non_nullable
as List<String>,bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,currencyName: null == currencyName ? _self.currencyName : currencyName // ignore: cast_nullable_to_non_nullable
as String,exchangeRateString: null == exchangeRateString ? _self.exchangeRateString : exchangeRateString // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as int,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as int,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension CryptoDepositOptionPatterns on CryptoDepositOption {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CryptoDepositOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CryptoDepositOption() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CryptoDepositOption value)  $default,){
final _that = this;
switch (_that) {
case _CryptoDepositOption():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CryptoDepositOption value)?  $default,){
final _that = this;
switch (_that) {
case _CryptoDepositOption() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> depositNetworks,  String bankId,  String currencyName,  String exchangeRateString,  int exchangeRate,  int fee,  String network)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CryptoDepositOption() when $default != null:
return $default(_that.depositNetworks,_that.bankId,_that.currencyName,_that.exchangeRateString,_that.exchangeRate,_that.fee,_that.network);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> depositNetworks,  String bankId,  String currencyName,  String exchangeRateString,  int exchangeRate,  int fee,  String network)  $default,) {final _that = this;
switch (_that) {
case _CryptoDepositOption():
return $default(_that.depositNetworks,_that.bankId,_that.currencyName,_that.exchangeRateString,_that.exchangeRate,_that.fee,_that.network);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> depositNetworks,  String bankId,  String currencyName,  String exchangeRateString,  int exchangeRate,  int fee,  String network)?  $default,) {final _that = this;
switch (_that) {
case _CryptoDepositOption() when $default != null:
return $default(_that.depositNetworks,_that.bankId,_that.currencyName,_that.exchangeRateString,_that.exchangeRate,_that.fee,_that.network);case _:
  return null;

}
}

}

@JsonSerializable()

class _CryptoDepositOption implements CryptoDepositOption {
  const _CryptoDepositOption({final  List<String> depositNetworks = const [], required this.bankId, required this.currencyName, required this.exchangeRateString, required this.exchangeRate, required this.fee, required this.network}): _depositNetworks = depositNetworks;
  factory _CryptoDepositOption.fromJson(Map<String, dynamic> json) => _$CryptoDepositOptionFromJson(json);

 final  List<String> _depositNetworks;
@override@JsonKey() List<String> get depositNetworks {
  if (_depositNetworks is EqualUnmodifiableListView) return _depositNetworks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_depositNetworks);
}

@override final  String bankId;
@override final  String currencyName;
@override final  String exchangeRateString;
@override final  int exchangeRate;
@override final  int fee;
@override final  String network;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CryptoDepositOptionCopyWith<_CryptoDepositOption> get copyWith => __$CryptoDepositOptionCopyWithImpl<_CryptoDepositOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CryptoDepositOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoDepositOption&&const DeepCollectionEquality().equals(other._depositNetworks, _depositNetworks)&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.currencyName, currencyName) || other.currencyName == currencyName)&&(identical(other.exchangeRateString, exchangeRateString) || other.exchangeRateString == exchangeRateString)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.network, network) || other.network == network));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_depositNetworks),bankId,currencyName,exchangeRateString,exchangeRate,fee,network);

@override
String toString() {
  return 'CryptoDepositOption(depositNetworks: $depositNetworks, bankId: $bankId, currencyName: $currencyName, exchangeRateString: $exchangeRateString, exchangeRate: $exchangeRate, fee: $fee, network: $network)';
}

}

abstract mixin class _$CryptoDepositOptionCopyWith<$Res> implements $CryptoDepositOptionCopyWith<$Res> {
  factory _$CryptoDepositOptionCopyWith(_CryptoDepositOption value, $Res Function(_CryptoDepositOption) _then) = __$CryptoDepositOptionCopyWithImpl;
@override @useResult
$Res call({
 List<String> depositNetworks, String bankId, String currencyName, String exchangeRateString, int exchangeRate, int fee, String network
});

}
class __$CryptoDepositOptionCopyWithImpl<$Res>
    implements _$CryptoDepositOptionCopyWith<$Res> {
  __$CryptoDepositOptionCopyWithImpl(this._self, this._then);

  final _CryptoDepositOption _self;
  final $Res Function(_CryptoDepositOption) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? depositNetworks = null,Object? bankId = null,Object? currencyName = null,Object? exchangeRateString = null,Object? exchangeRate = null,Object? fee = null,Object? network = null,}) {
  return _then(_CryptoDepositOption(
depositNetworks: null == depositNetworks ? _self._depositNetworks : depositNetworks // ignore: cast_nullable_to_non_nullable
as List<String>,bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,currencyName: null == currencyName ? _self.currencyName : currencyName // ignore: cast_nullable_to_non_nullable
as String,exchangeRateString: null == exchangeRateString ? _self.exchangeRateString : exchangeRateString // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as int,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as int,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
