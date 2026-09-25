// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cashout_gift_card.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$CashoutGiftCard {

 String get name; int get id; List<CashoutGiftCardItem> get items; String get url;@JsonKey(name: 'exchangeRates') List<Map<String, dynamic>> get exchangeRates; int get bankType;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashoutGiftCardCopyWith<CashoutGiftCard> get copyWith => _$CashoutGiftCardCopyWithImpl<CashoutGiftCard>(this as CashoutGiftCard, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashoutGiftCard&&(identical(other.name, name) || other.name == name)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.exchangeRates, exchangeRates)&&(identical(other.bankType, bankType) || other.bankType == bankType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,id,const DeepCollectionEquality().hash(items),url,const DeepCollectionEquality().hash(exchangeRates),bankType);

@override
String toString() {
  return 'CashoutGiftCard(name: $name, id: $id, items: $items, url: $url, exchangeRates: $exchangeRates, bankType: $bankType)';
}

}

abstract mixin class $CashoutGiftCardCopyWith<$Res>  {
  factory $CashoutGiftCardCopyWith(CashoutGiftCard value, $Res Function(CashoutGiftCard) _then) = _$CashoutGiftCardCopyWithImpl;
@useResult
$Res call({
 String name, int id, List<CashoutGiftCardItem> items, String url,@JsonKey(name: 'exchangeRates') List<Map<String, dynamic>> exchangeRates, int bankType
});

}
class _$CashoutGiftCardCopyWithImpl<$Res>
    implements $CashoutGiftCardCopyWith<$Res> {
  _$CashoutGiftCardCopyWithImpl(this._self, this._then);

  final CashoutGiftCard _self;
  final $Res Function(CashoutGiftCard) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? id = null,Object? items = null,Object? url = null,Object? exchangeRates = null,Object? bankType = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CashoutGiftCardItem>,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,exchangeRates: null == exchangeRates ? _self.exchangeRates : exchangeRates // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,bankType: null == bankType ? _self.bankType : bankType // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension CashoutGiftCardPatterns on CashoutGiftCard {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashoutGiftCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashoutGiftCard() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashoutGiftCard value)  $default,){
final _that = this;
switch (_that) {
case _CashoutGiftCard():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashoutGiftCard value)?  $default,){
final _that = this;
switch (_that) {
case _CashoutGiftCard() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int id,  List<CashoutGiftCardItem> items,  String url, @JsonKey(name: 'exchangeRates')  List<Map<String, dynamic>> exchangeRates,  int bankType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashoutGiftCard() when $default != null:
return $default(_that.name,_that.id,_that.items,_that.url,_that.exchangeRates,_that.bankType);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int id,  List<CashoutGiftCardItem> items,  String url, @JsonKey(name: 'exchangeRates')  List<Map<String, dynamic>> exchangeRates,  int bankType)  $default,) {final _that = this;
switch (_that) {
case _CashoutGiftCard():
return $default(_that.name,_that.id,_that.items,_that.url,_that.exchangeRates,_that.bankType);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int id,  List<CashoutGiftCardItem> items,  String url, @JsonKey(name: 'exchangeRates')  List<Map<String, dynamic>> exchangeRates,  int bankType)?  $default,) {final _that = this;
switch (_that) {
case _CashoutGiftCard() when $default != null:
return $default(_that.name,_that.id,_that.items,_that.url,_that.exchangeRates,_that.bankType);case _:
  return null;

}
}

}

@JsonSerializable()

class _CashoutGiftCard implements CashoutGiftCard {
  const _CashoutGiftCard({required this.name, required this.id, final  List<CashoutGiftCardItem> items = const [], required this.url, @JsonKey(name: 'exchangeRates') final  List<Map<String, dynamic>> exchangeRates = const [], this.bankType = 0}): _items = items,_exchangeRates = exchangeRates;
  factory _CashoutGiftCard.fromJson(Map<String, dynamic> json) => _$CashoutGiftCardFromJson(json);

@override final  String name;
@override final  int id;
 final  List<CashoutGiftCardItem> _items;
@override@JsonKey() List<CashoutGiftCardItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String url;
 final  List<Map<String, dynamic>> _exchangeRates;
@override@JsonKey(name: 'exchangeRates') List<Map<String, dynamic>> get exchangeRates {
  if (_exchangeRates is EqualUnmodifiableListView) return _exchangeRates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exchangeRates);
}

@override@JsonKey() final  int bankType;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashoutGiftCardCopyWith<_CashoutGiftCard> get copyWith => __$CashoutGiftCardCopyWithImpl<_CashoutGiftCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashoutGiftCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashoutGiftCard&&(identical(other.name, name) || other.name == name)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._exchangeRates, _exchangeRates)&&(identical(other.bankType, bankType) || other.bankType == bankType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,id,const DeepCollectionEquality().hash(_items),url,const DeepCollectionEquality().hash(_exchangeRates),bankType);

@override
String toString() {
  return 'CashoutGiftCard(name: $name, id: $id, items: $items, url: $url, exchangeRates: $exchangeRates, bankType: $bankType)';
}

}

abstract mixin class _$CashoutGiftCardCopyWith<$Res> implements $CashoutGiftCardCopyWith<$Res> {
  factory _$CashoutGiftCardCopyWith(_CashoutGiftCard value, $Res Function(_CashoutGiftCard) _then) = __$CashoutGiftCardCopyWithImpl;
@override @useResult
$Res call({
 String name, int id, List<CashoutGiftCardItem> items, String url,@JsonKey(name: 'exchangeRates') List<Map<String, dynamic>> exchangeRates, int bankType
});

}
class __$CashoutGiftCardCopyWithImpl<$Res>
    implements _$CashoutGiftCardCopyWith<$Res> {
  __$CashoutGiftCardCopyWithImpl(this._self, this._then);

  final _CashoutGiftCard _self;
  final $Res Function(_CashoutGiftCard) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? id = null,Object? items = null,Object? url = null,Object? exchangeRates = null,Object? bankType = null,}) {
  return _then(_CashoutGiftCard(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CashoutGiftCardItem>,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,exchangeRates: null == exchangeRates ? _self._exchangeRates : exchangeRates // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,bankType: null == bankType ? _self.bankType : bankType // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

// dart format on
