// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gift_card.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$CashoutGiftCard {

@JsonKey(name: 'id') int get id;@JsonKey(name: 'name') String get name;@JsonKey(name: 'url') String? get url;@JsonKey(name: 'items') List<GiftCardItem>? get items;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashoutGiftCardCopyWith<CashoutGiftCard> get copyWith => _$CashoutGiftCardCopyWithImpl<CashoutGiftCard>(this as CashoutGiftCard, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashoutGiftCard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,url,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'CashoutGiftCard(id: $id, name: $name, url: $url, items: $items)';
}

}

abstract mixin class $CashoutGiftCardCopyWith<$Res>  {
  factory $CashoutGiftCardCopyWith(CashoutGiftCard value, $Res Function(CashoutGiftCard) _then) = _$CashoutGiftCardCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'name') String name,@JsonKey(name: 'url') String? url,@JsonKey(name: 'items') List<GiftCardItem>? items
});

}
class _$CashoutGiftCardCopyWithImpl<$Res>
    implements $CashoutGiftCardCopyWith<$Res> {
  _$CashoutGiftCardCopyWithImpl(this._self, this._then);

  final CashoutGiftCard _self;
  final $Res Function(CashoutGiftCard) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? url = freezed,Object? items = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GiftCardItem>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'url')  String? url, @JsonKey(name: 'items')  List<GiftCardItem>? items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashoutGiftCard() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.items);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'url')  String? url, @JsonKey(name: 'items')  List<GiftCardItem>? items)  $default,) {final _that = this;
switch (_that) {
case _CashoutGiftCard():
return $default(_that.id,_that.name,_that.url,_that.items);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'url')  String? url, @JsonKey(name: 'items')  List<GiftCardItem>? items)?  $default,) {final _that = this;
switch (_that) {
case _CashoutGiftCard() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.items);case _:
  return null;

}
}

}

@JsonSerializable()

class _CashoutGiftCard implements CashoutGiftCard {
  const _CashoutGiftCard({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'url') this.url, @JsonKey(name: 'items') final  List<GiftCardItem>? items}): _items = items;
  factory _CashoutGiftCard.fromJson(Map<String, dynamic> json) => _$CashoutGiftCardFromJson(json);

@override@JsonKey(name: 'id') final  int id;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'url') final  String? url;
 final  List<GiftCardItem>? _items;
@override@JsonKey(name: 'items') List<GiftCardItem>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashoutGiftCardCopyWith<_CashoutGiftCard> get copyWith => __$CashoutGiftCardCopyWithImpl<_CashoutGiftCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashoutGiftCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashoutGiftCard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,url,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'CashoutGiftCard(id: $id, name: $name, url: $url, items: $items)';
}

}

abstract mixin class _$CashoutGiftCardCopyWith<$Res> implements $CashoutGiftCardCopyWith<$Res> {
  factory _$CashoutGiftCardCopyWith(_CashoutGiftCard value, $Res Function(_CashoutGiftCard) _then) = __$CashoutGiftCardCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'name') String name,@JsonKey(name: 'url') String? url,@JsonKey(name: 'items') List<GiftCardItem>? items
});

}
class __$CashoutGiftCardCopyWithImpl<$Res>
    implements _$CashoutGiftCardCopyWith<$Res> {
  __$CashoutGiftCardCopyWithImpl(this._self, this._then);

  final _CashoutGiftCard _self;
  final $Res Function(_CashoutGiftCard) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? url = freezed,Object? items = freezed,}) {
  return _then(_CashoutGiftCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GiftCardItem>?,
  ));
}

}

mixin _$GiftCardItem {

@JsonKey(name: 'id') String? get id;@JsonKey(name: 'name') String? get name;@JsonKey(name: 'displayName') String? get displayName;@JsonKey(name: 'image') String? get image;@JsonKey(name: 'amount') int? get amount;@JsonKey(name: 'price') int? get price;@JsonKey(name: 'active') bool? get active;@JsonKey(name: 'type') int? get type;@JsonKey(name: 'brand') String? get brand;@JsonKey(name: 'telcoId') int? get telcoId;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GiftCardItemCopyWith<GiftCardItem> get copyWith => _$GiftCardItemCopyWithImpl<GiftCardItem>(this as GiftCardItem, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GiftCardItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.image, image) || other.image == image)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.price, price) || other.price == price)&&(identical(other.active, active) || other.active == active)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.telcoId, telcoId) || other.telcoId == telcoId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,displayName,image,amount,price,active,type,brand,telcoId);

@override
String toString() {
  return 'GiftCardItem(id: $id, name: $name, displayName: $displayName, image: $image, amount: $amount, price: $price, active: $active, type: $type, brand: $brand, telcoId: $telcoId)';
}

}

abstract mixin class $GiftCardItemCopyWith<$Res>  {
  factory $GiftCardItemCopyWith(GiftCardItem value, $Res Function(GiftCardItem) _then) = _$GiftCardItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String? id,@JsonKey(name: 'name') String? name,@JsonKey(name: 'displayName') String? displayName,@JsonKey(name: 'image') String? image,@JsonKey(name: 'amount') int? amount,@JsonKey(name: 'price') int? price,@JsonKey(name: 'active') bool? active,@JsonKey(name: 'type') int? type,@JsonKey(name: 'brand') String? brand,@JsonKey(name: 'telcoId') int? telcoId
});

}
class _$GiftCardItemCopyWithImpl<$Res>
    implements $GiftCardItemCopyWith<$Res> {
  _$GiftCardItemCopyWithImpl(this._self, this._then);

  final GiftCardItem _self;
  final $Res Function(GiftCardItem) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? displayName = freezed,Object? image = freezed,Object? amount = freezed,Object? price = freezed,Object? active = freezed,Object? type = freezed,Object? brand = freezed,Object? telcoId = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int?,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,telcoId: freezed == telcoId ? _self.telcoId : telcoId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

extension GiftCardItemPatterns on GiftCardItem {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GiftCardItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GiftCardItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GiftCardItem value)  $default,){
final _that = this;
switch (_that) {
case _GiftCardItem():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GiftCardItem value)?  $default,){
final _that = this;
switch (_that) {
case _GiftCardItem() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String? id, @JsonKey(name: 'name')  String? name, @JsonKey(name: 'displayName')  String? displayName, @JsonKey(name: 'image')  String? image, @JsonKey(name: 'amount')  int? amount, @JsonKey(name: 'price')  int? price, @JsonKey(name: 'active')  bool? active, @JsonKey(name: 'type')  int? type, @JsonKey(name: 'brand')  String? brand, @JsonKey(name: 'telcoId')  int? telcoId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GiftCardItem() when $default != null:
return $default(_that.id,_that.name,_that.displayName,_that.image,_that.amount,_that.price,_that.active,_that.type,_that.brand,_that.telcoId);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String? id, @JsonKey(name: 'name')  String? name, @JsonKey(name: 'displayName')  String? displayName, @JsonKey(name: 'image')  String? image, @JsonKey(name: 'amount')  int? amount, @JsonKey(name: 'price')  int? price, @JsonKey(name: 'active')  bool? active, @JsonKey(name: 'type')  int? type, @JsonKey(name: 'brand')  String? brand, @JsonKey(name: 'telcoId')  int? telcoId)  $default,) {final _that = this;
switch (_that) {
case _GiftCardItem():
return $default(_that.id,_that.name,_that.displayName,_that.image,_that.amount,_that.price,_that.active,_that.type,_that.brand,_that.telcoId);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String? id, @JsonKey(name: 'name')  String? name, @JsonKey(name: 'displayName')  String? displayName, @JsonKey(name: 'image')  String? image, @JsonKey(name: 'amount')  int? amount, @JsonKey(name: 'price')  int? price, @JsonKey(name: 'active')  bool? active, @JsonKey(name: 'type')  int? type, @JsonKey(name: 'brand')  String? brand, @JsonKey(name: 'telcoId')  int? telcoId)?  $default,) {final _that = this;
switch (_that) {
case _GiftCardItem() when $default != null:
return $default(_that.id,_that.name,_that.displayName,_that.image,_that.amount,_that.price,_that.active,_that.type,_that.brand,_that.telcoId);case _:
  return null;

}
}

}

@JsonSerializable()

class _GiftCardItem implements GiftCardItem {
  const _GiftCardItem({@JsonKey(name: 'id') this.id, @JsonKey(name: 'name') this.name, @JsonKey(name: 'displayName') this.displayName, @JsonKey(name: 'image') this.image, @JsonKey(name: 'amount') this.amount, @JsonKey(name: 'price') this.price, @JsonKey(name: 'active') this.active, @JsonKey(name: 'type') this.type, @JsonKey(name: 'brand') this.brand, @JsonKey(name: 'telcoId') this.telcoId});
  factory _GiftCardItem.fromJson(Map<String, dynamic> json) => _$GiftCardItemFromJson(json);

@override@JsonKey(name: 'id') final  String? id;
@override@JsonKey(name: 'name') final  String? name;
@override@JsonKey(name: 'displayName') final  String? displayName;
@override@JsonKey(name: 'image') final  String? image;
@override@JsonKey(name: 'amount') final  int? amount;
@override@JsonKey(name: 'price') final  int? price;
@override@JsonKey(name: 'active') final  bool? active;
@override@JsonKey(name: 'type') final  int? type;
@override@JsonKey(name: 'brand') final  String? brand;
@override@JsonKey(name: 'telcoId') final  int? telcoId;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GiftCardItemCopyWith<_GiftCardItem> get copyWith => __$GiftCardItemCopyWithImpl<_GiftCardItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GiftCardItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GiftCardItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.image, image) || other.image == image)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.price, price) || other.price == price)&&(identical(other.active, active) || other.active == active)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.telcoId, telcoId) || other.telcoId == telcoId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,displayName,image,amount,price,active,type,brand,telcoId);

@override
String toString() {
  return 'GiftCardItem(id: $id, name: $name, displayName: $displayName, image: $image, amount: $amount, price: $price, active: $active, type: $type, brand: $brand, telcoId: $telcoId)';
}

}

abstract mixin class _$GiftCardItemCopyWith<$Res> implements $GiftCardItemCopyWith<$Res> {
  factory _$GiftCardItemCopyWith(_GiftCardItem value, $Res Function(_GiftCardItem) _then) = __$GiftCardItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String? id,@JsonKey(name: 'name') String? name,@JsonKey(name: 'displayName') String? displayName,@JsonKey(name: 'image') String? image,@JsonKey(name: 'amount') int? amount,@JsonKey(name: 'price') int? price,@JsonKey(name: 'active') bool? active,@JsonKey(name: 'type') int? type,@JsonKey(name: 'brand') String? brand,@JsonKey(name: 'telcoId') int? telcoId
});

}
class __$GiftCardItemCopyWithImpl<$Res>
    implements _$GiftCardItemCopyWith<$Res> {
  __$GiftCardItemCopyWithImpl(this._self, this._then);

  final _GiftCardItem _self;
  final $Res Function(_GiftCardItem) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? displayName = freezed,Object? image = freezed,Object? amount = freezed,Object? price = freezed,Object? active = freezed,Object? type = freezed,Object? brand = freezed,Object? telcoId = freezed,}) {
  return _then(_GiftCardItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int?,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,telcoId: freezed == telcoId ? _self.telcoId : telcoId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

// dart format on
