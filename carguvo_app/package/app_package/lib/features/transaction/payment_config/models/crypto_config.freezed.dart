// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crypto_config.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$CryptoConfig {

@JsonKey(name: 'bankId') String? get bankId;@JsonKey(name: 'currencyName') String? get currencyName;@JsonKey(name: 'exchangeRate') num? get exchangeRate;@JsonKey(name: 'exchangeRateString') String? get exchangeRateString;@JsonKey(name: 'fee') num? get fee;@JsonKey(name: 'network') String? get network;@JsonKey(name: 'depositNetworks') List<String>? get depositNetworks;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoConfigCopyWith<CryptoConfig> get copyWith => _$CryptoConfigCopyWithImpl<CryptoConfig>(this as CryptoConfig, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoConfig&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.currencyName, currencyName) || other.currencyName == currencyName)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.exchangeRateString, exchangeRateString) || other.exchangeRateString == exchangeRateString)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.network, network) || other.network == network)&&const DeepCollectionEquality().equals(other.depositNetworks, depositNetworks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,currencyName,exchangeRate,exchangeRateString,fee,network,const DeepCollectionEquality().hash(depositNetworks));

@override
String toString() {
  return 'CryptoConfig(bankId: $bankId, currencyName: $currencyName, exchangeRate: $exchangeRate, exchangeRateString: $exchangeRateString, fee: $fee, network: $network, depositNetworks: $depositNetworks)';
}

}

abstract mixin class $CryptoConfigCopyWith<$Res>  {
  factory $CryptoConfigCopyWith(CryptoConfig value, $Res Function(CryptoConfig) _then) = _$CryptoConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'bankId') String? bankId,@JsonKey(name: 'currencyName') String? currencyName,@JsonKey(name: 'exchangeRate') num? exchangeRate,@JsonKey(name: 'exchangeRateString') String? exchangeRateString,@JsonKey(name: 'fee') num? fee,@JsonKey(name: 'network') String? network,@JsonKey(name: 'depositNetworks') List<String>? depositNetworks
});

}
class _$CryptoConfigCopyWithImpl<$Res>
    implements $CryptoConfigCopyWith<$Res> {
  _$CryptoConfigCopyWithImpl(this._self, this._then);

  final CryptoConfig _self;
  final $Res Function(CryptoConfig) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? bankId = freezed,Object? currencyName = freezed,Object? exchangeRate = freezed,Object? exchangeRateString = freezed,Object? fee = freezed,Object? network = freezed,Object? depositNetworks = freezed,}) {
  return _then(_self.copyWith(
bankId: freezed == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String?,currencyName: freezed == currencyName ? _self.currencyName : currencyName // ignore: cast_nullable_to_non_nullable
as String?,exchangeRate: freezed == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as num?,exchangeRateString: freezed == exchangeRateString ? _self.exchangeRateString : exchangeRateString // ignore: cast_nullable_to_non_nullable
as String?,fee: freezed == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as num?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,depositNetworks: freezed == depositNetworks ? _self.depositNetworks : depositNetworks // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}

extension CryptoConfigPatterns on CryptoConfig {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CryptoConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CryptoConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CryptoConfig value)  $default,){
final _that = this;
switch (_that) {
case _CryptoConfig():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CryptoConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CryptoConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'bankId')  String? bankId, @JsonKey(name: 'currencyName')  String? currencyName, @JsonKey(name: 'exchangeRate')  num? exchangeRate, @JsonKey(name: 'exchangeRateString')  String? exchangeRateString, @JsonKey(name: 'fee')  num? fee, @JsonKey(name: 'network')  String? network, @JsonKey(name: 'depositNetworks')  List<String>? depositNetworks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CryptoConfig() when $default != null:
return $default(_that.bankId,_that.currencyName,_that.exchangeRate,_that.exchangeRateString,_that.fee,_that.network,_that.depositNetworks);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'bankId')  String? bankId, @JsonKey(name: 'currencyName')  String? currencyName, @JsonKey(name: 'exchangeRate')  num? exchangeRate, @JsonKey(name: 'exchangeRateString')  String? exchangeRateString, @JsonKey(name: 'fee')  num? fee, @JsonKey(name: 'network')  String? network, @JsonKey(name: 'depositNetworks')  List<String>? depositNetworks)  $default,) {final _that = this;
switch (_that) {
case _CryptoConfig():
return $default(_that.bankId,_that.currencyName,_that.exchangeRate,_that.exchangeRateString,_that.fee,_that.network,_that.depositNetworks);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'bankId')  String? bankId, @JsonKey(name: 'currencyName')  String? currencyName, @JsonKey(name: 'exchangeRate')  num? exchangeRate, @JsonKey(name: 'exchangeRateString')  String? exchangeRateString, @JsonKey(name: 'fee')  num? fee, @JsonKey(name: 'network')  String? network, @JsonKey(name: 'depositNetworks')  List<String>? depositNetworks)?  $default,) {final _that = this;
switch (_that) {
case _CryptoConfig() when $default != null:
return $default(_that.bankId,_that.currencyName,_that.exchangeRate,_that.exchangeRateString,_that.fee,_that.network,_that.depositNetworks);case _:
  return null;

}
}

}

@JsonSerializable()

class _CryptoConfig implements CryptoConfig {
  const _CryptoConfig({@JsonKey(name: 'bankId') this.bankId, @JsonKey(name: 'currencyName') this.currencyName, @JsonKey(name: 'exchangeRate') this.exchangeRate, @JsonKey(name: 'exchangeRateString') this.exchangeRateString, @JsonKey(name: 'fee') this.fee, @JsonKey(name: 'network') this.network, @JsonKey(name: 'depositNetworks') final  List<String>? depositNetworks}): _depositNetworks = depositNetworks;
  factory _CryptoConfig.fromJson(Map<String, dynamic> json) => _$CryptoConfigFromJson(json);

@override@JsonKey(name: 'bankId') final  String? bankId;
@override@JsonKey(name: 'currencyName') final  String? currencyName;
@override@JsonKey(name: 'exchangeRate') final  num? exchangeRate;
@override@JsonKey(name: 'exchangeRateString') final  String? exchangeRateString;
@override@JsonKey(name: 'fee') final  num? fee;
@override@JsonKey(name: 'network') final  String? network;
 final  List<String>? _depositNetworks;
@override@JsonKey(name: 'depositNetworks') List<String>? get depositNetworks {
  final value = _depositNetworks;
  if (value == null) return null;
  if (_depositNetworks is EqualUnmodifiableListView) return _depositNetworks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CryptoConfigCopyWith<_CryptoConfig> get copyWith => __$CryptoConfigCopyWithImpl<_CryptoConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CryptoConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoConfig&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.currencyName, currencyName) || other.currencyName == currencyName)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.exchangeRateString, exchangeRateString) || other.exchangeRateString == exchangeRateString)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.network, network) || other.network == network)&&const DeepCollectionEquality().equals(other._depositNetworks, _depositNetworks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,currencyName,exchangeRate,exchangeRateString,fee,network,const DeepCollectionEquality().hash(_depositNetworks));

@override
String toString() {
  return 'CryptoConfig(bankId: $bankId, currencyName: $currencyName, exchangeRate: $exchangeRate, exchangeRateString: $exchangeRateString, fee: $fee, network: $network, depositNetworks: $depositNetworks)';
}

}

abstract mixin class _$CryptoConfigCopyWith<$Res> implements $CryptoConfigCopyWith<$Res> {
  factory _$CryptoConfigCopyWith(_CryptoConfig value, $Res Function(_CryptoConfig) _then) = __$CryptoConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'bankId') String? bankId,@JsonKey(name: 'currencyName') String? currencyName,@JsonKey(name: 'exchangeRate') num? exchangeRate,@JsonKey(name: 'exchangeRateString') String? exchangeRateString,@JsonKey(name: 'fee') num? fee,@JsonKey(name: 'network') String? network,@JsonKey(name: 'depositNetworks') List<String>? depositNetworks
});

}
class __$CryptoConfigCopyWithImpl<$Res>
    implements _$CryptoConfigCopyWith<$Res> {
  __$CryptoConfigCopyWithImpl(this._self, this._then);

  final _CryptoConfig _self;
  final $Res Function(_CryptoConfig) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? bankId = freezed,Object? currencyName = freezed,Object? exchangeRate = freezed,Object? exchangeRateString = freezed,Object? fee = freezed,Object? network = freezed,Object? depositNetworks = freezed,}) {
  return _then(_CryptoConfig(
bankId: freezed == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String?,currencyName: freezed == currencyName ? _self.currencyName : currencyName // ignore: cast_nullable_to_non_nullable
as String?,exchangeRate: freezed == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as num?,exchangeRateString: freezed == exchangeRateString ? _self.exchangeRateString : exchangeRateString // ignore: cast_nullable_to_non_nullable
as String?,fee: freezed == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as num?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,depositNetworks: freezed == depositNetworks ? _self._depositNetworks : depositNetworks // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}

// dart format on
