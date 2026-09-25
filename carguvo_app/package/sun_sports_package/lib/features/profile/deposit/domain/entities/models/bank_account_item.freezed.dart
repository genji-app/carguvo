// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bank_account_item.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$BankAccountItem {

@JsonKey(name: 'supportQRCode') bool get supportQrCode; bool get supportWithdraw; int get bankType; String get name; String get fullName; String get id; List<ItemAccount> get accounts; List<SuggestedTransCode> get suggestedTransCode; String get shortName; String get url;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankAccountItemCopyWith<BankAccountItem> get copyWith => _$BankAccountItemCopyWithImpl<BankAccountItem>(this as BankAccountItem, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankAccountItem&&(identical(other.supportQrCode, supportQrCode) || other.supportQrCode == supportQrCode)&&(identical(other.supportWithdraw, supportWithdraw) || other.supportWithdraw == supportWithdraw)&&(identical(other.bankType, bankType) || other.bankType == bankType)&&(identical(other.name, name) || other.name == name)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.accounts, accounts)&&const DeepCollectionEquality().equals(other.suggestedTransCode, suggestedTransCode)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,supportQrCode,supportWithdraw,bankType,name,fullName,id,const DeepCollectionEquality().hash(accounts),const DeepCollectionEquality().hash(suggestedTransCode),shortName,url);

@override
String toString() {
  return 'BankAccountItem(supportQrCode: $supportQrCode, supportWithdraw: $supportWithdraw, bankType: $bankType, name: $name, fullName: $fullName, id: $id, accounts: $accounts, suggestedTransCode: $suggestedTransCode, shortName: $shortName, url: $url)';
}

}

abstract mixin class $BankAccountItemCopyWith<$Res>  {
  factory $BankAccountItemCopyWith(BankAccountItem value, $Res Function(BankAccountItem) _then) = _$BankAccountItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'supportQRCode') bool supportQrCode, bool supportWithdraw, int bankType, String name, String fullName, String id, List<ItemAccount> accounts, List<SuggestedTransCode> suggestedTransCode, String shortName, String url
});

}
class _$BankAccountItemCopyWithImpl<$Res>
    implements $BankAccountItemCopyWith<$Res> {
  _$BankAccountItemCopyWithImpl(this._self, this._then);

  final BankAccountItem _self;
  final $Res Function(BankAccountItem) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? supportQrCode = null,Object? supportWithdraw = null,Object? bankType = null,Object? name = null,Object? fullName = null,Object? id = null,Object? accounts = null,Object? suggestedTransCode = null,Object? shortName = null,Object? url = null,}) {
  return _then(_self.copyWith(
supportQrCode: null == supportQrCode ? _self.supportQrCode : supportQrCode // ignore: cast_nullable_to_non_nullable
as bool,supportWithdraw: null == supportWithdraw ? _self.supportWithdraw : supportWithdraw // ignore: cast_nullable_to_non_nullable
as bool,bankType: null == bankType ? _self.bankType : bankType // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<ItemAccount>,suggestedTransCode: null == suggestedTransCode ? _self.suggestedTransCode : suggestedTransCode // ignore: cast_nullable_to_non_nullable
as List<SuggestedTransCode>,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension BankAccountItemPatterns on BankAccountItem {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankAccountItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankAccountItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankAccountItem value)  $default,){
final _that = this;
switch (_that) {
case _BankAccountItem():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankAccountItem value)?  $default,){
final _that = this;
switch (_that) {
case _BankAccountItem() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'supportQRCode')  bool supportQrCode,  bool supportWithdraw,  int bankType,  String name,  String fullName,  String id,  List<ItemAccount> accounts,  List<SuggestedTransCode> suggestedTransCode,  String shortName,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankAccountItem() when $default != null:
return $default(_that.supportQrCode,_that.supportWithdraw,_that.bankType,_that.name,_that.fullName,_that.id,_that.accounts,_that.suggestedTransCode,_that.shortName,_that.url);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'supportQRCode')  bool supportQrCode,  bool supportWithdraw,  int bankType,  String name,  String fullName,  String id,  List<ItemAccount> accounts,  List<SuggestedTransCode> suggestedTransCode,  String shortName,  String url)  $default,) {final _that = this;
switch (_that) {
case _BankAccountItem():
return $default(_that.supportQrCode,_that.supportWithdraw,_that.bankType,_that.name,_that.fullName,_that.id,_that.accounts,_that.suggestedTransCode,_that.shortName,_that.url);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'supportQRCode')  bool supportQrCode,  bool supportWithdraw,  int bankType,  String name,  String fullName,  String id,  List<ItemAccount> accounts,  List<SuggestedTransCode> suggestedTransCode,  String shortName,  String url)?  $default,) {final _that = this;
switch (_that) {
case _BankAccountItem() when $default != null:
return $default(_that.supportQrCode,_that.supportWithdraw,_that.bankType,_that.name,_that.fullName,_that.id,_that.accounts,_that.suggestedTransCode,_that.shortName,_that.url);case _:
  return null;

}
}

}

@JsonSerializable()

class _BankAccountItem implements BankAccountItem {
  const _BankAccountItem({@JsonKey(name: 'supportQRCode') required this.supportQrCode, required this.supportWithdraw, required this.bankType, required this.name, required this.fullName, required this.id, final  List<ItemAccount> accounts = const [], final  List<SuggestedTransCode> suggestedTransCode = const [], required this.shortName, required this.url}): _accounts = accounts,_suggestedTransCode = suggestedTransCode;
  factory _BankAccountItem.fromJson(Map<String, dynamic> json) => _$BankAccountItemFromJson(json);

@override@JsonKey(name: 'supportQRCode') final  bool supportQrCode;
@override final  bool supportWithdraw;
@override final  int bankType;
@override final  String name;
@override final  String fullName;
@override final  String id;
 final  List<ItemAccount> _accounts;
@override@JsonKey() List<ItemAccount> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}

 final  List<SuggestedTransCode> _suggestedTransCode;
@override@JsonKey() List<SuggestedTransCode> get suggestedTransCode {
  if (_suggestedTransCode is EqualUnmodifiableListView) return _suggestedTransCode;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestedTransCode);
}

@override final  String shortName;
@override final  String url;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankAccountItemCopyWith<_BankAccountItem> get copyWith => __$BankAccountItemCopyWithImpl<_BankAccountItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BankAccountItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankAccountItem&&(identical(other.supportQrCode, supportQrCode) || other.supportQrCode == supportQrCode)&&(identical(other.supportWithdraw, supportWithdraw) || other.supportWithdraw == supportWithdraw)&&(identical(other.bankType, bankType) || other.bankType == bankType)&&(identical(other.name, name) || other.name == name)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._accounts, _accounts)&&const DeepCollectionEquality().equals(other._suggestedTransCode, _suggestedTransCode)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,supportQrCode,supportWithdraw,bankType,name,fullName,id,const DeepCollectionEquality().hash(_accounts),const DeepCollectionEquality().hash(_suggestedTransCode),shortName,url);

@override
String toString() {
  return 'BankAccountItem(supportQrCode: $supportQrCode, supportWithdraw: $supportWithdraw, bankType: $bankType, name: $name, fullName: $fullName, id: $id, accounts: $accounts, suggestedTransCode: $suggestedTransCode, shortName: $shortName, url: $url)';
}

}

abstract mixin class _$BankAccountItemCopyWith<$Res> implements $BankAccountItemCopyWith<$Res> {
  factory _$BankAccountItemCopyWith(_BankAccountItem value, $Res Function(_BankAccountItem) _then) = __$BankAccountItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'supportQRCode') bool supportQrCode, bool supportWithdraw, int bankType, String name, String fullName, String id, List<ItemAccount> accounts, List<SuggestedTransCode> suggestedTransCode, String shortName, String url
});

}
class __$BankAccountItemCopyWithImpl<$Res>
    implements _$BankAccountItemCopyWith<$Res> {
  __$BankAccountItemCopyWithImpl(this._self, this._then);

  final _BankAccountItem _self;
  final $Res Function(_BankAccountItem) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? supportQrCode = null,Object? supportWithdraw = null,Object? bankType = null,Object? name = null,Object? fullName = null,Object? id = null,Object? accounts = null,Object? suggestedTransCode = null,Object? shortName = null,Object? url = null,}) {
  return _then(_BankAccountItem(
supportQrCode: null == supportQrCode ? _self.supportQrCode : supportQrCode // ignore: cast_nullable_to_non_nullable
as bool,supportWithdraw: null == supportWithdraw ? _self.supportWithdraw : supportWithdraw // ignore: cast_nullable_to_non_nullable
as bool,bankType: null == bankType ? _self.bankType : bankType // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<ItemAccount>,suggestedTransCode: null == suggestedTransCode ? _self._suggestedTransCode : suggestedTransCode // ignore: cast_nullable_to_non_nullable
as List<SuggestedTransCode>,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
