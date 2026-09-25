// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cashout_gift_card_item.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$CashoutGiftCardItem {

 String get image; int get amount; String get displayName; int get price; String get name; bool get active; String get id; int get type; String get brand; int get telcoId;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashoutGiftCardItemCopyWith<CashoutGiftCardItem> get copyWith => _$CashoutGiftCardItemCopyWithImpl<CashoutGiftCardItem>(this as CashoutGiftCardItem, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashoutGiftCardItem&&(identical(other.image, image) || other.image == image)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.price, price) || other.price == price)&&(identical(other.name, name) || other.name == name)&&(identical(other.active, active) || other.active == active)&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.telcoId, telcoId) || other.telcoId == telcoId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,image,amount,displayName,price,name,active,id,type,brand,telcoId);

@override
String toString() {
  return 'CashoutGiftCardItem(image: $image, amount: $amount, displayName: $displayName, price: $price, name: $name, active: $active, id: $id, type: $type, brand: $brand, telcoId: $telcoId)';
}

}

abstract mixin class $CashoutGiftCardItemCopyWith<$Res>  {
  factory $CashoutGiftCardItemCopyWith(CashoutGiftCardItem value, $Res Function(CashoutGiftCardItem) _then) = _$CashoutGiftCardItemCopyWithImpl;
@useResult
$Res call({
 String image, int amount, String displayName, int price, String name, bool active, String id, int type, String brand, int telcoId
});

}
class _$CashoutGiftCardItemCopyWithImpl<$Res>
    implements $CashoutGiftCardItemCopyWith<$Res> {
  _$CashoutGiftCardItemCopyWithImpl(this._self, this._then);

  final CashoutGiftCardItem _self;
  final $Res Function(CashoutGiftCardItem) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? image = null,Object? amount = null,Object? displayName = null,Object? price = null,Object? name = null,Object? active = null,Object? id = null,Object? type = null,Object? brand = null,Object? telcoId = null,}) {
  return _then(_self.copyWith(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,telcoId: null == telcoId ? _self.telcoId : telcoId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension CashoutGiftCardItemPatterns on CashoutGiftCardItem {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashoutGiftCardItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashoutGiftCardItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashoutGiftCardItem value)  $default,){
final _that = this;
switch (_that) {
case _CashoutGiftCardItem():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashoutGiftCardItem value)?  $default,){
final _that = this;
switch (_that) {
case _CashoutGiftCardItem() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String image,  int amount,  String displayName,  int price,  String name,  bool active,  String id,  int type,  String brand,  int telcoId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashoutGiftCardItem() when $default != null:
return $default(_that.image,_that.amount,_that.displayName,_that.price,_that.name,_that.active,_that.id,_that.type,_that.brand,_that.telcoId);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String image,  int amount,  String displayName,  int price,  String name,  bool active,  String id,  int type,  String brand,  int telcoId)  $default,) {final _that = this;
switch (_that) {
case _CashoutGiftCardItem():
return $default(_that.image,_that.amount,_that.displayName,_that.price,_that.name,_that.active,_that.id,_that.type,_that.brand,_that.telcoId);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String image,  int amount,  String displayName,  int price,  String name,  bool active,  String id,  int type,  String brand,  int telcoId)?  $default,) {final _that = this;
switch (_that) {
case _CashoutGiftCardItem() when $default != null:
return $default(_that.image,_that.amount,_that.displayName,_that.price,_that.name,_that.active,_that.id,_that.type,_that.brand,_that.telcoId);case _:
  return null;

}
}

}

@JsonSerializable()

class _CashoutGiftCardItem implements CashoutGiftCardItem {
  const _CashoutGiftCardItem({required this.image, required this.amount, required this.displayName, required this.price, required this.name, required this.active, required this.id, required this.type, required this.brand, required this.telcoId});
  factory _CashoutGiftCardItem.fromJson(Map<String, dynamic> json) => _$CashoutGiftCardItemFromJson(json);

@override final  String image;
@override final  int amount;
@override final  String displayName;
@override final  int price;
@override final  String name;
@override final  bool active;
@override final  String id;
@override final  int type;
@override final  String brand;
@override final  int telcoId;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashoutGiftCardItemCopyWith<_CashoutGiftCardItem> get copyWith => __$CashoutGiftCardItemCopyWithImpl<_CashoutGiftCardItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashoutGiftCardItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashoutGiftCardItem&&(identical(other.image, image) || other.image == image)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.price, price) || other.price == price)&&(identical(other.name, name) || other.name == name)&&(identical(other.active, active) || other.active == active)&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.telcoId, telcoId) || other.telcoId == telcoId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,image,amount,displayName,price,name,active,id,type,brand,telcoId);

@override
String toString() {
  return 'CashoutGiftCardItem(image: $image, amount: $amount, displayName: $displayName, price: $price, name: $name, active: $active, id: $id, type: $type, brand: $brand, telcoId: $telcoId)';
}

}

abstract mixin class _$CashoutGiftCardItemCopyWith<$Res> implements $CashoutGiftCardItemCopyWith<$Res> {
  factory _$CashoutGiftCardItemCopyWith(_CashoutGiftCardItem value, $Res Function(_CashoutGiftCardItem) _then) = __$CashoutGiftCardItemCopyWithImpl;
@override @useResult
$Res call({
 String image, int amount, String displayName, int price, String name, bool active, String id, int type, String brand, int telcoId
});

}
class __$CashoutGiftCardItemCopyWithImpl<$Res>
    implements _$CashoutGiftCardItemCopyWith<$Res> {
  __$CashoutGiftCardItemCopyWithImpl(this._self, this._then);

  final _CashoutGiftCardItem _self;
  final $Res Function(_CashoutGiftCardItem) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? image = null,Object? amount = null,Object? displayName = null,Object? price = null,Object? name = null,Object? active = null,Object? id = null,Object? type = null,Object? brand = null,Object? telcoId = null,}) {
  return _then(_CashoutGiftCardItem(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,telcoId: null == telcoId ? _self.telcoId : telcoId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

// dart format on
