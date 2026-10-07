// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bank.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$CodePayBank {

@JsonKey(name: 'id') String get id;@JsonKey(name: 'name') String get name;@JsonKey(name: 'fullName') String? get fullName;@JsonKey(name: 'shortName') String? get shortName;@JsonKey(name: 'url') String? get url;@JsonKey(name: 'bankType') int? get bankType;@JsonKey(name: 'supportQRCode') bool? get supportQRCode;@JsonKey(name: 'supportWithdraw') bool? get supportWithdraw;@JsonKey(name: 'codePayDisplayOrder') int? get codePayDisplayOrder;@JsonKey(name: 'accounts') List<BankAccount>? get accounts;@JsonKey(name: 'suggestedTransCode') List<SuggestedTransCode>? get suggestedTransCode;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodePayBankCopyWith<CodePayBank> get copyWith => _$CodePayBankCopyWithImpl<CodePayBank>(this as CodePayBank, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodePayBank&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.url, url) || other.url == url)&&(identical(other.bankType, bankType) || other.bankType == bankType)&&(identical(other.supportQRCode, supportQRCode) || other.supportQRCode == supportQRCode)&&(identical(other.supportWithdraw, supportWithdraw) || other.supportWithdraw == supportWithdraw)&&(identical(other.codePayDisplayOrder, codePayDisplayOrder) || other.codePayDisplayOrder == codePayDisplayOrder)&&const DeepCollectionEquality().equals(other.accounts, accounts)&&const DeepCollectionEquality().equals(other.suggestedTransCode, suggestedTransCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,fullName,shortName,url,bankType,supportQRCode,supportWithdraw,codePayDisplayOrder,const DeepCollectionEquality().hash(accounts),const DeepCollectionEquality().hash(suggestedTransCode));

@override
String toString() {
  return 'CodePayBank(id: $id, name: $name, fullName: $fullName, shortName: $shortName, url: $url, bankType: $bankType, supportQRCode: $supportQRCode, supportWithdraw: $supportWithdraw, codePayDisplayOrder: $codePayDisplayOrder, accounts: $accounts, suggestedTransCode: $suggestedTransCode)';
}

}

abstract mixin class $CodePayBankCopyWith<$Res>  {
  factory $CodePayBankCopyWith(CodePayBank value, $Res Function(CodePayBank) _then) = _$CodePayBankCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'name') String name,@JsonKey(name: 'fullName') String? fullName,@JsonKey(name: 'shortName') String? shortName,@JsonKey(name: 'url') String? url,@JsonKey(name: 'bankType') int? bankType,@JsonKey(name: 'supportQRCode') bool? supportQRCode,@JsonKey(name: 'supportWithdraw') bool? supportWithdraw,@JsonKey(name: 'codePayDisplayOrder') int? codePayDisplayOrder,@JsonKey(name: 'accounts') List<BankAccount>? accounts,@JsonKey(name: 'suggestedTransCode') List<SuggestedTransCode>? suggestedTransCode
});

}
class _$CodePayBankCopyWithImpl<$Res>
    implements $CodePayBankCopyWith<$Res> {
  _$CodePayBankCopyWithImpl(this._self, this._then);

  final CodePayBank _self;
  final $Res Function(CodePayBank) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? fullName = freezed,Object? shortName = freezed,Object? url = freezed,Object? bankType = freezed,Object? supportQRCode = freezed,Object? supportWithdraw = freezed,Object? codePayDisplayOrder = freezed,Object? accounts = freezed,Object? suggestedTransCode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,bankType: freezed == bankType ? _self.bankType : bankType // ignore: cast_nullable_to_non_nullable
as int?,supportQRCode: freezed == supportQRCode ? _self.supportQRCode : supportQRCode // ignore: cast_nullable_to_non_nullable
as bool?,supportWithdraw: freezed == supportWithdraw ? _self.supportWithdraw : supportWithdraw // ignore: cast_nullable_to_non_nullable
as bool?,codePayDisplayOrder: freezed == codePayDisplayOrder ? _self.codePayDisplayOrder : codePayDisplayOrder // ignore: cast_nullable_to_non_nullable
as int?,accounts: freezed == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<BankAccount>?,suggestedTransCode: freezed == suggestedTransCode ? _self.suggestedTransCode : suggestedTransCode // ignore: cast_nullable_to_non_nullable
as List<SuggestedTransCode>?,
  ));
}

}

extension CodePayBankPatterns on CodePayBank {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodePayBank value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodePayBank() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodePayBank value)  $default,){
final _that = this;
switch (_that) {
case _CodePayBank():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodePayBank value)?  $default,){
final _that = this;
switch (_that) {
case _CodePayBank() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'fullName')  String? fullName, @JsonKey(name: 'shortName')  String? shortName, @JsonKey(name: 'url')  String? url, @JsonKey(name: 'bankType')  int? bankType, @JsonKey(name: 'supportQRCode')  bool? supportQRCode, @JsonKey(name: 'supportWithdraw')  bool? supportWithdraw, @JsonKey(name: 'codePayDisplayOrder')  int? codePayDisplayOrder, @JsonKey(name: 'accounts')  List<BankAccount>? accounts, @JsonKey(name: 'suggestedTransCode')  List<SuggestedTransCode>? suggestedTransCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodePayBank() when $default != null:
return $default(_that.id,_that.name,_that.fullName,_that.shortName,_that.url,_that.bankType,_that.supportQRCode,_that.supportWithdraw,_that.codePayDisplayOrder,_that.accounts,_that.suggestedTransCode);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'fullName')  String? fullName, @JsonKey(name: 'shortName')  String? shortName, @JsonKey(name: 'url')  String? url, @JsonKey(name: 'bankType')  int? bankType, @JsonKey(name: 'supportQRCode')  bool? supportQRCode, @JsonKey(name: 'supportWithdraw')  bool? supportWithdraw, @JsonKey(name: 'codePayDisplayOrder')  int? codePayDisplayOrder, @JsonKey(name: 'accounts')  List<BankAccount>? accounts, @JsonKey(name: 'suggestedTransCode')  List<SuggestedTransCode>? suggestedTransCode)  $default,) {final _that = this;
switch (_that) {
case _CodePayBank():
return $default(_that.id,_that.name,_that.fullName,_that.shortName,_that.url,_that.bankType,_that.supportQRCode,_that.supportWithdraw,_that.codePayDisplayOrder,_that.accounts,_that.suggestedTransCode);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'fullName')  String? fullName, @JsonKey(name: 'shortName')  String? shortName, @JsonKey(name: 'url')  String? url, @JsonKey(name: 'bankType')  int? bankType, @JsonKey(name: 'supportQRCode')  bool? supportQRCode, @JsonKey(name: 'supportWithdraw')  bool? supportWithdraw, @JsonKey(name: 'codePayDisplayOrder')  int? codePayDisplayOrder, @JsonKey(name: 'accounts')  List<BankAccount>? accounts, @JsonKey(name: 'suggestedTransCode')  List<SuggestedTransCode>? suggestedTransCode)?  $default,) {final _that = this;
switch (_that) {
case _CodePayBank() when $default != null:
return $default(_that.id,_that.name,_that.fullName,_that.shortName,_that.url,_that.bankType,_that.supportQRCode,_that.supportWithdraw,_that.codePayDisplayOrder,_that.accounts,_that.suggestedTransCode);case _:
  return null;

}
}

}

@JsonSerializable()

class _CodePayBank implements CodePayBank {
  const _CodePayBank({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'fullName') this.fullName, @JsonKey(name: 'shortName') this.shortName, @JsonKey(name: 'url') this.url, @JsonKey(name: 'bankType') this.bankType, @JsonKey(name: 'supportQRCode') this.supportQRCode, @JsonKey(name: 'supportWithdraw') this.supportWithdraw, @JsonKey(name: 'codePayDisplayOrder') this.codePayDisplayOrder, @JsonKey(name: 'accounts') final  List<BankAccount>? accounts, @JsonKey(name: 'suggestedTransCode') final  List<SuggestedTransCode>? suggestedTransCode}): _accounts = accounts,_suggestedTransCode = suggestedTransCode;
  factory _CodePayBank.fromJson(Map<String, dynamic> json) => _$CodePayBankFromJson(json);

@override@JsonKey(name: 'id') final  String id;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'fullName') final  String? fullName;
@override@JsonKey(name: 'shortName') final  String? shortName;
@override@JsonKey(name: 'url') final  String? url;
@override@JsonKey(name: 'bankType') final  int? bankType;
@override@JsonKey(name: 'supportQRCode') final  bool? supportQRCode;
@override@JsonKey(name: 'supportWithdraw') final  bool? supportWithdraw;
@override@JsonKey(name: 'codePayDisplayOrder') final  int? codePayDisplayOrder;
 final  List<BankAccount>? _accounts;
@override@JsonKey(name: 'accounts') List<BankAccount>? get accounts {
  final value = _accounts;
  if (value == null) return null;
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<SuggestedTransCode>? _suggestedTransCode;
@override@JsonKey(name: 'suggestedTransCode') List<SuggestedTransCode>? get suggestedTransCode {
  final value = _suggestedTransCode;
  if (value == null) return null;
  if (_suggestedTransCode is EqualUnmodifiableListView) return _suggestedTransCode;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodePayBankCopyWith<_CodePayBank> get copyWith => __$CodePayBankCopyWithImpl<_CodePayBank>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CodePayBankToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodePayBank&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.url, url) || other.url == url)&&(identical(other.bankType, bankType) || other.bankType == bankType)&&(identical(other.supportQRCode, supportQRCode) || other.supportQRCode == supportQRCode)&&(identical(other.supportWithdraw, supportWithdraw) || other.supportWithdraw == supportWithdraw)&&(identical(other.codePayDisplayOrder, codePayDisplayOrder) || other.codePayDisplayOrder == codePayDisplayOrder)&&const DeepCollectionEquality().equals(other._accounts, _accounts)&&const DeepCollectionEquality().equals(other._suggestedTransCode, _suggestedTransCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,fullName,shortName,url,bankType,supportQRCode,supportWithdraw,codePayDisplayOrder,const DeepCollectionEquality().hash(_accounts),const DeepCollectionEquality().hash(_suggestedTransCode));

@override
String toString() {
  return 'CodePayBank(id: $id, name: $name, fullName: $fullName, shortName: $shortName, url: $url, bankType: $bankType, supportQRCode: $supportQRCode, supportWithdraw: $supportWithdraw, codePayDisplayOrder: $codePayDisplayOrder, accounts: $accounts, suggestedTransCode: $suggestedTransCode)';
}

}

abstract mixin class _$CodePayBankCopyWith<$Res> implements $CodePayBankCopyWith<$Res> {
  factory _$CodePayBankCopyWith(_CodePayBank value, $Res Function(_CodePayBank) _then) = __$CodePayBankCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'name') String name,@JsonKey(name: 'fullName') String? fullName,@JsonKey(name: 'shortName') String? shortName,@JsonKey(name: 'url') String? url,@JsonKey(name: 'bankType') int? bankType,@JsonKey(name: 'supportQRCode') bool? supportQRCode,@JsonKey(name: 'supportWithdraw') bool? supportWithdraw,@JsonKey(name: 'codePayDisplayOrder') int? codePayDisplayOrder,@JsonKey(name: 'accounts') List<BankAccount>? accounts,@JsonKey(name: 'suggestedTransCode') List<SuggestedTransCode>? suggestedTransCode
});

}
class __$CodePayBankCopyWithImpl<$Res>
    implements _$CodePayBankCopyWith<$Res> {
  __$CodePayBankCopyWithImpl(this._self, this._then);

  final _CodePayBank _self;
  final $Res Function(_CodePayBank) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? fullName = freezed,Object? shortName = freezed,Object? url = freezed,Object? bankType = freezed,Object? supportQRCode = freezed,Object? supportWithdraw = freezed,Object? codePayDisplayOrder = freezed,Object? accounts = freezed,Object? suggestedTransCode = freezed,}) {
  return _then(_CodePayBank(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,bankType: freezed == bankType ? _self.bankType : bankType // ignore: cast_nullable_to_non_nullable
as int?,supportQRCode: freezed == supportQRCode ? _self.supportQRCode : supportQRCode // ignore: cast_nullable_to_non_nullable
as bool?,supportWithdraw: freezed == supportWithdraw ? _self.supportWithdraw : supportWithdraw // ignore: cast_nullable_to_non_nullable
as bool?,codePayDisplayOrder: freezed == codePayDisplayOrder ? _self.codePayDisplayOrder : codePayDisplayOrder // ignore: cast_nullable_to_non_nullable
as int?,accounts: freezed == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<BankAccount>?,suggestedTransCode: freezed == suggestedTransCode ? _self._suggestedTransCode : suggestedTransCode // ignore: cast_nullable_to_non_nullable
as List<SuggestedTransCode>?,
  ));
}

}

mixin _$BankItem {

@JsonKey(name: 'id') String get id;@JsonKey(name: 'name') String get name;@JsonKey(name: 'fullName') String? get fullName;@JsonKey(name: 'shortName') String? get shortName;@JsonKey(name: 'url') String? get url;@JsonKey(name: 'bankType') int? get bankType;@JsonKey(name: 'supportQRCode') bool? get supportQRCode;@JsonKey(name: 'supportWithdraw') bool? get supportWithdraw;@JsonKey(name: 'codePayDisplayOrder') int? get codePayDisplayOrder;@JsonKey(name: 'accounts') List<BankAccount>? get accounts;@JsonKey(name: 'suggestedTransCode') List<SuggestedTransCode>? get suggestedTransCode;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankItemCopyWith<BankItem> get copyWith => _$BankItemCopyWithImpl<BankItem>(this as BankItem, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.url, url) || other.url == url)&&(identical(other.bankType, bankType) || other.bankType == bankType)&&(identical(other.supportQRCode, supportQRCode) || other.supportQRCode == supportQRCode)&&(identical(other.supportWithdraw, supportWithdraw) || other.supportWithdraw == supportWithdraw)&&(identical(other.codePayDisplayOrder, codePayDisplayOrder) || other.codePayDisplayOrder == codePayDisplayOrder)&&const DeepCollectionEquality().equals(other.accounts, accounts)&&const DeepCollectionEquality().equals(other.suggestedTransCode, suggestedTransCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,fullName,shortName,url,bankType,supportQRCode,supportWithdraw,codePayDisplayOrder,const DeepCollectionEquality().hash(accounts),const DeepCollectionEquality().hash(suggestedTransCode));

@override
String toString() {
  return 'BankItem(id: $id, name: $name, fullName: $fullName, shortName: $shortName, url: $url, bankType: $bankType, supportQRCode: $supportQRCode, supportWithdraw: $supportWithdraw, codePayDisplayOrder: $codePayDisplayOrder, accounts: $accounts, suggestedTransCode: $suggestedTransCode)';
}

}

abstract mixin class $BankItemCopyWith<$Res>  {
  factory $BankItemCopyWith(BankItem value, $Res Function(BankItem) _then) = _$BankItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'name') String name,@JsonKey(name: 'fullName') String? fullName,@JsonKey(name: 'shortName') String? shortName,@JsonKey(name: 'url') String? url,@JsonKey(name: 'bankType') int? bankType,@JsonKey(name: 'supportQRCode') bool? supportQRCode,@JsonKey(name: 'supportWithdraw') bool? supportWithdraw,@JsonKey(name: 'codePayDisplayOrder') int? codePayDisplayOrder,@JsonKey(name: 'accounts') List<BankAccount>? accounts,@JsonKey(name: 'suggestedTransCode') List<SuggestedTransCode>? suggestedTransCode
});

}
class _$BankItemCopyWithImpl<$Res>
    implements $BankItemCopyWith<$Res> {
  _$BankItemCopyWithImpl(this._self, this._then);

  final BankItem _self;
  final $Res Function(BankItem) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? fullName = freezed,Object? shortName = freezed,Object? url = freezed,Object? bankType = freezed,Object? supportQRCode = freezed,Object? supportWithdraw = freezed,Object? codePayDisplayOrder = freezed,Object? accounts = freezed,Object? suggestedTransCode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,bankType: freezed == bankType ? _self.bankType : bankType // ignore: cast_nullable_to_non_nullable
as int?,supportQRCode: freezed == supportQRCode ? _self.supportQRCode : supportQRCode // ignore: cast_nullable_to_non_nullable
as bool?,supportWithdraw: freezed == supportWithdraw ? _self.supportWithdraw : supportWithdraw // ignore: cast_nullable_to_non_nullable
as bool?,codePayDisplayOrder: freezed == codePayDisplayOrder ? _self.codePayDisplayOrder : codePayDisplayOrder // ignore: cast_nullable_to_non_nullable
as int?,accounts: freezed == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<BankAccount>?,suggestedTransCode: freezed == suggestedTransCode ? _self.suggestedTransCode : suggestedTransCode // ignore: cast_nullable_to_non_nullable
as List<SuggestedTransCode>?,
  ));
}

}

extension BankItemPatterns on BankItem {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankItem value)  $default,){
final _that = this;
switch (_that) {
case _BankItem():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankItem value)?  $default,){
final _that = this;
switch (_that) {
case _BankItem() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'fullName')  String? fullName, @JsonKey(name: 'shortName')  String? shortName, @JsonKey(name: 'url')  String? url, @JsonKey(name: 'bankType')  int? bankType, @JsonKey(name: 'supportQRCode')  bool? supportQRCode, @JsonKey(name: 'supportWithdraw')  bool? supportWithdraw, @JsonKey(name: 'codePayDisplayOrder')  int? codePayDisplayOrder, @JsonKey(name: 'accounts')  List<BankAccount>? accounts, @JsonKey(name: 'suggestedTransCode')  List<SuggestedTransCode>? suggestedTransCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankItem() when $default != null:
return $default(_that.id,_that.name,_that.fullName,_that.shortName,_that.url,_that.bankType,_that.supportQRCode,_that.supportWithdraw,_that.codePayDisplayOrder,_that.accounts,_that.suggestedTransCode);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'fullName')  String? fullName, @JsonKey(name: 'shortName')  String? shortName, @JsonKey(name: 'url')  String? url, @JsonKey(name: 'bankType')  int? bankType, @JsonKey(name: 'supportQRCode')  bool? supportQRCode, @JsonKey(name: 'supportWithdraw')  bool? supportWithdraw, @JsonKey(name: 'codePayDisplayOrder')  int? codePayDisplayOrder, @JsonKey(name: 'accounts')  List<BankAccount>? accounts, @JsonKey(name: 'suggestedTransCode')  List<SuggestedTransCode>? suggestedTransCode)  $default,) {final _that = this;
switch (_that) {
case _BankItem():
return $default(_that.id,_that.name,_that.fullName,_that.shortName,_that.url,_that.bankType,_that.supportQRCode,_that.supportWithdraw,_that.codePayDisplayOrder,_that.accounts,_that.suggestedTransCode);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'fullName')  String? fullName, @JsonKey(name: 'shortName')  String? shortName, @JsonKey(name: 'url')  String? url, @JsonKey(name: 'bankType')  int? bankType, @JsonKey(name: 'supportQRCode')  bool? supportQRCode, @JsonKey(name: 'supportWithdraw')  bool? supportWithdraw, @JsonKey(name: 'codePayDisplayOrder')  int? codePayDisplayOrder, @JsonKey(name: 'accounts')  List<BankAccount>? accounts, @JsonKey(name: 'suggestedTransCode')  List<SuggestedTransCode>? suggestedTransCode)?  $default,) {final _that = this;
switch (_that) {
case _BankItem() when $default != null:
return $default(_that.id,_that.name,_that.fullName,_that.shortName,_that.url,_that.bankType,_that.supportQRCode,_that.supportWithdraw,_that.codePayDisplayOrder,_that.accounts,_that.suggestedTransCode);case _:
  return null;

}
}

}

@JsonSerializable()

class _BankItem implements BankItem {
  const _BankItem({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'fullName') this.fullName, @JsonKey(name: 'shortName') this.shortName, @JsonKey(name: 'url') this.url, @JsonKey(name: 'bankType') this.bankType, @JsonKey(name: 'supportQRCode') this.supportQRCode, @JsonKey(name: 'supportWithdraw') this.supportWithdraw, @JsonKey(name: 'codePayDisplayOrder') this.codePayDisplayOrder, @JsonKey(name: 'accounts') final  List<BankAccount>? accounts, @JsonKey(name: 'suggestedTransCode') final  List<SuggestedTransCode>? suggestedTransCode}): _accounts = accounts,_suggestedTransCode = suggestedTransCode;
  factory _BankItem.fromJson(Map<String, dynamic> json) => _$BankItemFromJson(json);

@override@JsonKey(name: 'id') final  String id;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'fullName') final  String? fullName;
@override@JsonKey(name: 'shortName') final  String? shortName;
@override@JsonKey(name: 'url') final  String? url;
@override@JsonKey(name: 'bankType') final  int? bankType;
@override@JsonKey(name: 'supportQRCode') final  bool? supportQRCode;
@override@JsonKey(name: 'supportWithdraw') final  bool? supportWithdraw;
@override@JsonKey(name: 'codePayDisplayOrder') final  int? codePayDisplayOrder;
 final  List<BankAccount>? _accounts;
@override@JsonKey(name: 'accounts') List<BankAccount>? get accounts {
  final value = _accounts;
  if (value == null) return null;
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<SuggestedTransCode>? _suggestedTransCode;
@override@JsonKey(name: 'suggestedTransCode') List<SuggestedTransCode>? get suggestedTransCode {
  final value = _suggestedTransCode;
  if (value == null) return null;
  if (_suggestedTransCode is EqualUnmodifiableListView) return _suggestedTransCode;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankItemCopyWith<_BankItem> get copyWith => __$BankItemCopyWithImpl<_BankItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BankItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.url, url) || other.url == url)&&(identical(other.bankType, bankType) || other.bankType == bankType)&&(identical(other.supportQRCode, supportQRCode) || other.supportQRCode == supportQRCode)&&(identical(other.supportWithdraw, supportWithdraw) || other.supportWithdraw == supportWithdraw)&&(identical(other.codePayDisplayOrder, codePayDisplayOrder) || other.codePayDisplayOrder == codePayDisplayOrder)&&const DeepCollectionEquality().equals(other._accounts, _accounts)&&const DeepCollectionEquality().equals(other._suggestedTransCode, _suggestedTransCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,fullName,shortName,url,bankType,supportQRCode,supportWithdraw,codePayDisplayOrder,const DeepCollectionEquality().hash(_accounts),const DeepCollectionEquality().hash(_suggestedTransCode));

@override
String toString() {
  return 'BankItem(id: $id, name: $name, fullName: $fullName, shortName: $shortName, url: $url, bankType: $bankType, supportQRCode: $supportQRCode, supportWithdraw: $supportWithdraw, codePayDisplayOrder: $codePayDisplayOrder, accounts: $accounts, suggestedTransCode: $suggestedTransCode)';
}

}

abstract mixin class _$BankItemCopyWith<$Res> implements $BankItemCopyWith<$Res> {
  factory _$BankItemCopyWith(_BankItem value, $Res Function(_BankItem) _then) = __$BankItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'name') String name,@JsonKey(name: 'fullName') String? fullName,@JsonKey(name: 'shortName') String? shortName,@JsonKey(name: 'url') String? url,@JsonKey(name: 'bankType') int? bankType,@JsonKey(name: 'supportQRCode') bool? supportQRCode,@JsonKey(name: 'supportWithdraw') bool? supportWithdraw,@JsonKey(name: 'codePayDisplayOrder') int? codePayDisplayOrder,@JsonKey(name: 'accounts') List<BankAccount>? accounts,@JsonKey(name: 'suggestedTransCode') List<SuggestedTransCode>? suggestedTransCode
});

}
class __$BankItemCopyWithImpl<$Res>
    implements _$BankItemCopyWith<$Res> {
  __$BankItemCopyWithImpl(this._self, this._then);

  final _BankItem _self;
  final $Res Function(_BankItem) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? fullName = freezed,Object? shortName = freezed,Object? url = freezed,Object? bankType = freezed,Object? supportQRCode = freezed,Object? supportWithdraw = freezed,Object? codePayDisplayOrder = freezed,Object? accounts = freezed,Object? suggestedTransCode = freezed,}) {
  return _then(_BankItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,bankType: freezed == bankType ? _self.bankType : bankType // ignore: cast_nullable_to_non_nullable
as int?,supportQRCode: freezed == supportQRCode ? _self.supportQRCode : supportQRCode // ignore: cast_nullable_to_non_nullable
as bool?,supportWithdraw: freezed == supportWithdraw ? _self.supportWithdraw : supportWithdraw // ignore: cast_nullable_to_non_nullable
as bool?,codePayDisplayOrder: freezed == codePayDisplayOrder ? _self.codePayDisplayOrder : codePayDisplayOrder // ignore: cast_nullable_to_non_nullable
as int?,accounts: freezed == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<BankAccount>?,suggestedTransCode: freezed == suggestedTransCode ? _self._suggestedTransCode : suggestedTransCode // ignore: cast_nullable_to_non_nullable
as List<SuggestedTransCode>?,
  ));
}

}

mixin _$BankAccount {

@JsonKey(name: 'id') String? get id;@JsonKey(name: 'bankId') String? get bankId;@JsonKey(name: 'accountName') String? get accountName;@JsonKey(name: 'accountNumber') String? get accountNumber;@JsonKey(name: 'accountNumberOrigin') String? get accountNumberOrigin;@JsonKey(name: 'bankBranch') String? get bankBranch;@JsonKey(name: 'bankNote') String? get bankNote;@JsonKey(name: 'publicRss') int? get publicRss;@JsonKey(name: 'type') int? get type;@JsonKey(name: 'qrCodeImage') String? get qrCodeImage;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankAccountCopyWith<BankAccount> get copyWith => _$BankAccountCopyWithImpl<BankAccount>(this as BankAccount, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.accountNumberOrigin, accountNumberOrigin) || other.accountNumberOrigin == accountNumberOrigin)&&(identical(other.bankBranch, bankBranch) || other.bankBranch == bankBranch)&&(identical(other.bankNote, bankNote) || other.bankNote == bankNote)&&(identical(other.publicRss, publicRss) || other.publicRss == publicRss)&&(identical(other.type, type) || other.type == type)&&(identical(other.qrCodeImage, qrCodeImage) || other.qrCodeImage == qrCodeImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bankId,accountName,accountNumber,accountNumberOrigin,bankBranch,bankNote,publicRss,type,qrCodeImage);

@override
String toString() {
  return 'BankAccount(id: $id, bankId: $bankId, accountName: $accountName, accountNumber: $accountNumber, accountNumberOrigin: $accountNumberOrigin, bankBranch: $bankBranch, bankNote: $bankNote, publicRss: $publicRss, type: $type, qrCodeImage: $qrCodeImage)';
}

}

abstract mixin class $BankAccountCopyWith<$Res>  {
  factory $BankAccountCopyWith(BankAccount value, $Res Function(BankAccount) _then) = _$BankAccountCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String? id,@JsonKey(name: 'bankId') String? bankId,@JsonKey(name: 'accountName') String? accountName,@JsonKey(name: 'accountNumber') String? accountNumber,@JsonKey(name: 'accountNumberOrigin') String? accountNumberOrigin,@JsonKey(name: 'bankBranch') String? bankBranch,@JsonKey(name: 'bankNote') String? bankNote,@JsonKey(name: 'publicRss') int? publicRss,@JsonKey(name: 'type') int? type,@JsonKey(name: 'qrCodeImage') String? qrCodeImage
});

}
class _$BankAccountCopyWithImpl<$Res>
    implements $BankAccountCopyWith<$Res> {
  _$BankAccountCopyWithImpl(this._self, this._then);

  final BankAccount _self;
  final $Res Function(BankAccount) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? bankId = freezed,Object? accountName = freezed,Object? accountNumber = freezed,Object? accountNumberOrigin = freezed,Object? bankBranch = freezed,Object? bankNote = freezed,Object? publicRss = freezed,Object? type = freezed,Object? qrCodeImage = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,bankId: freezed == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String?,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,accountNumberOrigin: freezed == accountNumberOrigin ? _self.accountNumberOrigin : accountNumberOrigin // ignore: cast_nullable_to_non_nullable
as String?,bankBranch: freezed == bankBranch ? _self.bankBranch : bankBranch // ignore: cast_nullable_to_non_nullable
as String?,bankNote: freezed == bankNote ? _self.bankNote : bankNote // ignore: cast_nullable_to_non_nullable
as String?,publicRss: freezed == publicRss ? _self.publicRss : publicRss // ignore: cast_nullable_to_non_nullable
as int?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,qrCodeImage: freezed == qrCodeImage ? _self.qrCodeImage : qrCodeImage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension BankAccountPatterns on BankAccount {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankAccount() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankAccount value)  $default,){
final _that = this;
switch (_that) {
case _BankAccount():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankAccount value)?  $default,){
final _that = this;
switch (_that) {
case _BankAccount() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String? id, @JsonKey(name: 'bankId')  String? bankId, @JsonKey(name: 'accountName')  String? accountName, @JsonKey(name: 'accountNumber')  String? accountNumber, @JsonKey(name: 'accountNumberOrigin')  String? accountNumberOrigin, @JsonKey(name: 'bankBranch')  String? bankBranch, @JsonKey(name: 'bankNote')  String? bankNote, @JsonKey(name: 'publicRss')  int? publicRss, @JsonKey(name: 'type')  int? type, @JsonKey(name: 'qrCodeImage')  String? qrCodeImage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankAccount() when $default != null:
return $default(_that.id,_that.bankId,_that.accountName,_that.accountNumber,_that.accountNumberOrigin,_that.bankBranch,_that.bankNote,_that.publicRss,_that.type,_that.qrCodeImage);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String? id, @JsonKey(name: 'bankId')  String? bankId, @JsonKey(name: 'accountName')  String? accountName, @JsonKey(name: 'accountNumber')  String? accountNumber, @JsonKey(name: 'accountNumberOrigin')  String? accountNumberOrigin, @JsonKey(name: 'bankBranch')  String? bankBranch, @JsonKey(name: 'bankNote')  String? bankNote, @JsonKey(name: 'publicRss')  int? publicRss, @JsonKey(name: 'type')  int? type, @JsonKey(name: 'qrCodeImage')  String? qrCodeImage)  $default,) {final _that = this;
switch (_that) {
case _BankAccount():
return $default(_that.id,_that.bankId,_that.accountName,_that.accountNumber,_that.accountNumberOrigin,_that.bankBranch,_that.bankNote,_that.publicRss,_that.type,_that.qrCodeImage);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String? id, @JsonKey(name: 'bankId')  String? bankId, @JsonKey(name: 'accountName')  String? accountName, @JsonKey(name: 'accountNumber')  String? accountNumber, @JsonKey(name: 'accountNumberOrigin')  String? accountNumberOrigin, @JsonKey(name: 'bankBranch')  String? bankBranch, @JsonKey(name: 'bankNote')  String? bankNote, @JsonKey(name: 'publicRss')  int? publicRss, @JsonKey(name: 'type')  int? type, @JsonKey(name: 'qrCodeImage')  String? qrCodeImage)?  $default,) {final _that = this;
switch (_that) {
case _BankAccount() when $default != null:
return $default(_that.id,_that.bankId,_that.accountName,_that.accountNumber,_that.accountNumberOrigin,_that.bankBranch,_that.bankNote,_that.publicRss,_that.type,_that.qrCodeImage);case _:
  return null;

}
}

}

@JsonSerializable()

class _BankAccount implements BankAccount {
  const _BankAccount({@JsonKey(name: 'id') this.id, @JsonKey(name: 'bankId') this.bankId, @JsonKey(name: 'accountName') this.accountName, @JsonKey(name: 'accountNumber') this.accountNumber, @JsonKey(name: 'accountNumberOrigin') this.accountNumberOrigin, @JsonKey(name: 'bankBranch') this.bankBranch, @JsonKey(name: 'bankNote') this.bankNote, @JsonKey(name: 'publicRss') this.publicRss, @JsonKey(name: 'type') this.type, @JsonKey(name: 'qrCodeImage') this.qrCodeImage});
  factory _BankAccount.fromJson(Map<String, dynamic> json) => _$BankAccountFromJson(json);

@override@JsonKey(name: 'id') final  String? id;
@override@JsonKey(name: 'bankId') final  String? bankId;
@override@JsonKey(name: 'accountName') final  String? accountName;
@override@JsonKey(name: 'accountNumber') final  String? accountNumber;
@override@JsonKey(name: 'accountNumberOrigin') final  String? accountNumberOrigin;
@override@JsonKey(name: 'bankBranch') final  String? bankBranch;
@override@JsonKey(name: 'bankNote') final  String? bankNote;
@override@JsonKey(name: 'publicRss') final  int? publicRss;
@override@JsonKey(name: 'type') final  int? type;
@override@JsonKey(name: 'qrCodeImage') final  String? qrCodeImage;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankAccountCopyWith<_BankAccount> get copyWith => __$BankAccountCopyWithImpl<_BankAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BankAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.accountNumberOrigin, accountNumberOrigin) || other.accountNumberOrigin == accountNumberOrigin)&&(identical(other.bankBranch, bankBranch) || other.bankBranch == bankBranch)&&(identical(other.bankNote, bankNote) || other.bankNote == bankNote)&&(identical(other.publicRss, publicRss) || other.publicRss == publicRss)&&(identical(other.type, type) || other.type == type)&&(identical(other.qrCodeImage, qrCodeImage) || other.qrCodeImage == qrCodeImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bankId,accountName,accountNumber,accountNumberOrigin,bankBranch,bankNote,publicRss,type,qrCodeImage);

@override
String toString() {
  return 'BankAccount(id: $id, bankId: $bankId, accountName: $accountName, accountNumber: $accountNumber, accountNumberOrigin: $accountNumberOrigin, bankBranch: $bankBranch, bankNote: $bankNote, publicRss: $publicRss, type: $type, qrCodeImage: $qrCodeImage)';
}

}

abstract mixin class _$BankAccountCopyWith<$Res> implements $BankAccountCopyWith<$Res> {
  factory _$BankAccountCopyWith(_BankAccount value, $Res Function(_BankAccount) _then) = __$BankAccountCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String? id,@JsonKey(name: 'bankId') String? bankId,@JsonKey(name: 'accountName') String? accountName,@JsonKey(name: 'accountNumber') String? accountNumber,@JsonKey(name: 'accountNumberOrigin') String? accountNumberOrigin,@JsonKey(name: 'bankBranch') String? bankBranch,@JsonKey(name: 'bankNote') String? bankNote,@JsonKey(name: 'publicRss') int? publicRss,@JsonKey(name: 'type') int? type,@JsonKey(name: 'qrCodeImage') String? qrCodeImage
});

}
class __$BankAccountCopyWithImpl<$Res>
    implements _$BankAccountCopyWith<$Res> {
  __$BankAccountCopyWithImpl(this._self, this._then);

  final _BankAccount _self;
  final $Res Function(_BankAccount) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? bankId = freezed,Object? accountName = freezed,Object? accountNumber = freezed,Object? accountNumberOrigin = freezed,Object? bankBranch = freezed,Object? bankNote = freezed,Object? publicRss = freezed,Object? type = freezed,Object? qrCodeImage = freezed,}) {
  return _then(_BankAccount(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,bankId: freezed == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String?,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,accountNumberOrigin: freezed == accountNumberOrigin ? _self.accountNumberOrigin : accountNumberOrigin // ignore: cast_nullable_to_non_nullable
as String?,bankBranch: freezed == bankBranch ? _self.bankBranch : bankBranch // ignore: cast_nullable_to_non_nullable
as String?,bankNote: freezed == bankNote ? _self.bankNote : bankNote // ignore: cast_nullable_to_non_nullable
as String?,publicRss: freezed == publicRss ? _self.publicRss : publicRss // ignore: cast_nullable_to_non_nullable
as int?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,qrCodeImage: freezed == qrCodeImage ? _self.qrCodeImage : qrCodeImage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

mixin _$SuggestedTransCode {

@JsonKey(name: 'text') String? get text;@JsonKey(name: 'type') int? get type;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestedTransCodeCopyWith<SuggestedTransCode> get copyWith => _$SuggestedTransCodeCopyWithImpl<SuggestedTransCode>(this as SuggestedTransCode, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestedTransCode&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,type);

@override
String toString() {
  return 'SuggestedTransCode(text: $text, type: $type)';
}

}

abstract mixin class $SuggestedTransCodeCopyWith<$Res>  {
  factory $SuggestedTransCodeCopyWith(SuggestedTransCode value, $Res Function(SuggestedTransCode) _then) = _$SuggestedTransCodeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'text') String? text,@JsonKey(name: 'type') int? type
});

}
class _$SuggestedTransCodeCopyWithImpl<$Res>
    implements $SuggestedTransCodeCopyWith<$Res> {
  _$SuggestedTransCodeCopyWithImpl(this._self, this._then);

  final SuggestedTransCode _self;
  final $Res Function(SuggestedTransCode) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? text = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

extension SuggestedTransCodePatterns on SuggestedTransCode {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SuggestedTransCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SuggestedTransCode() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SuggestedTransCode value)  $default,){
final _that = this;
switch (_that) {
case _SuggestedTransCode():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SuggestedTransCode value)?  $default,){
final _that = this;
switch (_that) {
case _SuggestedTransCode() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'text')  String? text, @JsonKey(name: 'type')  int? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SuggestedTransCode() when $default != null:
return $default(_that.text,_that.type);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'text')  String? text, @JsonKey(name: 'type')  int? type)  $default,) {final _that = this;
switch (_that) {
case _SuggestedTransCode():
return $default(_that.text,_that.type);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'text')  String? text, @JsonKey(name: 'type')  int? type)?  $default,) {final _that = this;
switch (_that) {
case _SuggestedTransCode() when $default != null:
return $default(_that.text,_that.type);case _:
  return null;

}
}

}

@JsonSerializable()

class _SuggestedTransCode implements SuggestedTransCode {
  const _SuggestedTransCode({@JsonKey(name: 'text') this.text, @JsonKey(name: 'type') this.type});
  factory _SuggestedTransCode.fromJson(Map<String, dynamic> json) => _$SuggestedTransCodeFromJson(json);

@override@JsonKey(name: 'text') final  String? text;
@override@JsonKey(name: 'type') final  int? type;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestedTransCodeCopyWith<_SuggestedTransCode> get copyWith => __$SuggestedTransCodeCopyWithImpl<_SuggestedTransCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuggestedTransCodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuggestedTransCode&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,type);

@override
String toString() {
  return 'SuggestedTransCode(text: $text, type: $type)';
}

}

abstract mixin class _$SuggestedTransCodeCopyWith<$Res> implements $SuggestedTransCodeCopyWith<$Res> {
  factory _$SuggestedTransCodeCopyWith(_SuggestedTransCode value, $Res Function(_SuggestedTransCode) _then) = __$SuggestedTransCodeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'text') String? text,@JsonKey(name: 'type') int? type
});

}
class __$SuggestedTransCodeCopyWithImpl<$Res>
    implements _$SuggestedTransCodeCopyWith<$Res> {
  __$SuggestedTransCodeCopyWithImpl(this._self, this._then);

  final _SuggestedTransCode _self;
  final $Res Function(_SuggestedTransCode) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? text = freezed,Object? type = freezed,}) {
  return _then(_SuggestedTransCode(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

// dart format on
