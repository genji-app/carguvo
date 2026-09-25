// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telco.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$Telco {

@JsonKey(name: 'id') int get id;@JsonKey(name: 'name') String get name;@JsonKey(name: 'url') String? get url;@JsonKey(name: 'exchangeRates') List<ExchangeRate>? get exchangeRates;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelcoCopyWith<Telco> get copyWith => _$TelcoCopyWithImpl<Telco>(this as Telco, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Telco&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.exchangeRates, exchangeRates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,url,const DeepCollectionEquality().hash(exchangeRates));

@override
String toString() {
  return 'Telco(id: $id, name: $name, url: $url, exchangeRates: $exchangeRates)';
}

}

abstract mixin class $TelcoCopyWith<$Res>  {
  factory $TelcoCopyWith(Telco value, $Res Function(Telco) _then) = _$TelcoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'name') String name,@JsonKey(name: 'url') String? url,@JsonKey(name: 'exchangeRates') List<ExchangeRate>? exchangeRates
});

}
class _$TelcoCopyWithImpl<$Res>
    implements $TelcoCopyWith<$Res> {
  _$TelcoCopyWithImpl(this._self, this._then);

  final Telco _self;
  final $Res Function(Telco) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? url = freezed,Object? exchangeRates = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,exchangeRates: freezed == exchangeRates ? _self.exchangeRates : exchangeRates // ignore: cast_nullable_to_non_nullable
as List<ExchangeRate>?,
  ));
}

}

extension TelcoPatterns on Telco {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Telco value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Telco() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Telco value)  $default,){
final _that = this;
switch (_that) {
case _Telco():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Telco value)?  $default,){
final _that = this;
switch (_that) {
case _Telco() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'url')  String? url, @JsonKey(name: 'exchangeRates')  List<ExchangeRate>? exchangeRates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Telco() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.exchangeRates);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'url')  String? url, @JsonKey(name: 'exchangeRates')  List<ExchangeRate>? exchangeRates)  $default,) {final _that = this;
switch (_that) {
case _Telco():
return $default(_that.id,_that.name,_that.url,_that.exchangeRates);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'url')  String? url, @JsonKey(name: 'exchangeRates')  List<ExchangeRate>? exchangeRates)?  $default,) {final _that = this;
switch (_that) {
case _Telco() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.exchangeRates);case _:
  return null;

}
}

}

@JsonSerializable()

class _Telco implements Telco {
  const _Telco({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'url') this.url, @JsonKey(name: 'exchangeRates') final  List<ExchangeRate>? exchangeRates}): _exchangeRates = exchangeRates;
  factory _Telco.fromJson(Map<String, dynamic> json) => _$TelcoFromJson(json);

@override@JsonKey(name: 'id') final  int id;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'url') final  String? url;
 final  List<ExchangeRate>? _exchangeRates;
@override@JsonKey(name: 'exchangeRates') List<ExchangeRate>? get exchangeRates {
  final value = _exchangeRates;
  if (value == null) return null;
  if (_exchangeRates is EqualUnmodifiableListView) return _exchangeRates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TelcoCopyWith<_Telco> get copyWith => __$TelcoCopyWithImpl<_Telco>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TelcoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Telco&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._exchangeRates, _exchangeRates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,url,const DeepCollectionEquality().hash(_exchangeRates));

@override
String toString() {
  return 'Telco(id: $id, name: $name, url: $url, exchangeRates: $exchangeRates)';
}

}

abstract mixin class _$TelcoCopyWith<$Res> implements $TelcoCopyWith<$Res> {
  factory _$TelcoCopyWith(_Telco value, $Res Function(_Telco) _then) = __$TelcoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'name') String name,@JsonKey(name: 'url') String? url,@JsonKey(name: 'exchangeRates') List<ExchangeRate>? exchangeRates
});

}
class __$TelcoCopyWithImpl<$Res>
    implements _$TelcoCopyWith<$Res> {
  __$TelcoCopyWithImpl(this._self, this._then);

  final _Telco _self;
  final $Res Function(_Telco) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? url = freezed,Object? exchangeRates = freezed,}) {
  return _then(_Telco(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,exchangeRates: freezed == exchangeRates ? _self._exchangeRates : exchangeRates // ignore: cast_nullable_to_non_nullable
as List<ExchangeRate>?,
  ));
}

}

mixin _$ExchangeRate {

@JsonKey(name: 'gold') int get gold;@JsonKey(name: 'amount') int get amount;@JsonKey(name: 'promotionPercent') int? get promotionPercent;@JsonKey(name: 'brand') String? get brand;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExchangeRateCopyWith<ExchangeRate> get copyWith => _$ExchangeRateCopyWithImpl<ExchangeRate>(this as ExchangeRate, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExchangeRate&&(identical(other.gold, gold) || other.gold == gold)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.promotionPercent, promotionPercent) || other.promotionPercent == promotionPercent)&&(identical(other.brand, brand) || other.brand == brand));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gold,amount,promotionPercent,brand);

@override
String toString() {
  return 'ExchangeRate(gold: $gold, amount: $amount, promotionPercent: $promotionPercent, brand: $brand)';
}

}

abstract mixin class $ExchangeRateCopyWith<$Res>  {
  factory $ExchangeRateCopyWith(ExchangeRate value, $Res Function(ExchangeRate) _then) = _$ExchangeRateCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'gold') int gold,@JsonKey(name: 'amount') int amount,@JsonKey(name: 'promotionPercent') int? promotionPercent,@JsonKey(name: 'brand') String? brand
});

}
class _$ExchangeRateCopyWithImpl<$Res>
    implements $ExchangeRateCopyWith<$Res> {
  _$ExchangeRateCopyWithImpl(this._self, this._then);

  final ExchangeRate _self;
  final $Res Function(ExchangeRate) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? gold = null,Object? amount = null,Object? promotionPercent = freezed,Object? brand = freezed,}) {
  return _then(_self.copyWith(
gold: null == gold ? _self.gold : gold // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,promotionPercent: freezed == promotionPercent ? _self.promotionPercent : promotionPercent // ignore: cast_nullable_to_non_nullable
as int?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension ExchangeRatePatterns on ExchangeRate {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExchangeRate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExchangeRate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExchangeRate value)  $default,){
final _that = this;
switch (_that) {
case _ExchangeRate():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExchangeRate value)?  $default,){
final _that = this;
switch (_that) {
case _ExchangeRate() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'gold')  int gold, @JsonKey(name: 'amount')  int amount, @JsonKey(name: 'promotionPercent')  int? promotionPercent, @JsonKey(name: 'brand')  String? brand)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExchangeRate() when $default != null:
return $default(_that.gold,_that.amount,_that.promotionPercent,_that.brand);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'gold')  int gold, @JsonKey(name: 'amount')  int amount, @JsonKey(name: 'promotionPercent')  int? promotionPercent, @JsonKey(name: 'brand')  String? brand)  $default,) {final _that = this;
switch (_that) {
case _ExchangeRate():
return $default(_that.gold,_that.amount,_that.promotionPercent,_that.brand);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'gold')  int gold, @JsonKey(name: 'amount')  int amount, @JsonKey(name: 'promotionPercent')  int? promotionPercent, @JsonKey(name: 'brand')  String? brand)?  $default,) {final _that = this;
switch (_that) {
case _ExchangeRate() when $default != null:
return $default(_that.gold,_that.amount,_that.promotionPercent,_that.brand);case _:
  return null;

}
}

}

@JsonSerializable()

class _ExchangeRate implements ExchangeRate {
  const _ExchangeRate({@JsonKey(name: 'gold') required this.gold, @JsonKey(name: 'amount') required this.amount, @JsonKey(name: 'promotionPercent') this.promotionPercent, @JsonKey(name: 'brand') this.brand});
  factory _ExchangeRate.fromJson(Map<String, dynamic> json) => _$ExchangeRateFromJson(json);

@override@JsonKey(name: 'gold') final  int gold;
@override@JsonKey(name: 'amount') final  int amount;
@override@JsonKey(name: 'promotionPercent') final  int? promotionPercent;
@override@JsonKey(name: 'brand') final  String? brand;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExchangeRateCopyWith<_ExchangeRate> get copyWith => __$ExchangeRateCopyWithImpl<_ExchangeRate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExchangeRateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExchangeRate&&(identical(other.gold, gold) || other.gold == gold)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.promotionPercent, promotionPercent) || other.promotionPercent == promotionPercent)&&(identical(other.brand, brand) || other.brand == brand));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gold,amount,promotionPercent,brand);

@override
String toString() {
  return 'ExchangeRate(gold: $gold, amount: $amount, promotionPercent: $promotionPercent, brand: $brand)';
}

}

abstract mixin class _$ExchangeRateCopyWith<$Res> implements $ExchangeRateCopyWith<$Res> {
  factory _$ExchangeRateCopyWith(_ExchangeRate value, $Res Function(_ExchangeRate) _then) = __$ExchangeRateCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'gold') int gold,@JsonKey(name: 'amount') int amount,@JsonKey(name: 'promotionPercent') int? promotionPercent,@JsonKey(name: 'brand') String? brand
});

}
class __$ExchangeRateCopyWithImpl<$Res>
    implements _$ExchangeRateCopyWith<$Res> {
  __$ExchangeRateCopyWithImpl(this._self, this._then);

  final _ExchangeRate _self;
  final $Res Function(_ExchangeRate) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? gold = null,Object? amount = null,Object? promotionPercent = freezed,Object? brand = freezed,}) {
  return _then(_ExchangeRate(
gold: null == gold ? _self.gold : gold // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,promotionPercent: freezed == promotionPercent ? _self.promotionPercent : promotionPercent // ignore: cast_nullable_to_non_nullable
as int?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

// dart format on
