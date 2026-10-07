// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_account.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$ItemAccount {

 String get bankId; String get accountNumberOrigin; String get bankNote; String get accountName; String get bankBranch; int get publicRss; String get id; String get accountNumber; int get type; String get qrCodeImage;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemAccountCopyWith<ItemAccount> get copyWith => _$ItemAccountCopyWithImpl<ItemAccount>(this as ItemAccount, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemAccount&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountNumberOrigin, accountNumberOrigin) || other.accountNumberOrigin == accountNumberOrigin)&&(identical(other.bankNote, bankNote) || other.bankNote == bankNote)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.bankBranch, bankBranch) || other.bankBranch == bankBranch)&&(identical(other.publicRss, publicRss) || other.publicRss == publicRss)&&(identical(other.id, id) || other.id == id)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.type, type) || other.type == type)&&(identical(other.qrCodeImage, qrCodeImage) || other.qrCodeImage == qrCodeImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountNumberOrigin,bankNote,accountName,bankBranch,publicRss,id,accountNumber,type,qrCodeImage);

@override
String toString() {
  return 'ItemAccount(bankId: $bankId, accountNumberOrigin: $accountNumberOrigin, bankNote: $bankNote, accountName: $accountName, bankBranch: $bankBranch, publicRss: $publicRss, id: $id, accountNumber: $accountNumber, type: $type, qrCodeImage: $qrCodeImage)';
}

}

abstract mixin class $ItemAccountCopyWith<$Res>  {
  factory $ItemAccountCopyWith(ItemAccount value, $Res Function(ItemAccount) _then) = _$ItemAccountCopyWithImpl;
@useResult
$Res call({
 String bankId, String accountNumberOrigin, String bankNote, String accountName, String bankBranch, int publicRss, String id, String accountNumber, int type, String qrCodeImage
});

}
class _$ItemAccountCopyWithImpl<$Res>
    implements $ItemAccountCopyWith<$Res> {
  _$ItemAccountCopyWithImpl(this._self, this._then);

  final ItemAccount _self;
  final $Res Function(ItemAccount) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? bankId = null,Object? accountNumberOrigin = null,Object? bankNote = null,Object? accountName = null,Object? bankBranch = null,Object? publicRss = null,Object? id = null,Object? accountNumber = null,Object? type = null,Object? qrCodeImage = null,}) {
  return _then(_self.copyWith(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountNumberOrigin: null == accountNumberOrigin ? _self.accountNumberOrigin : accountNumberOrigin // ignore: cast_nullable_to_non_nullable
as String,bankNote: null == bankNote ? _self.bankNote : bankNote // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,bankBranch: null == bankBranch ? _self.bankBranch : bankBranch // ignore: cast_nullable_to_non_nullable
as String,publicRss: null == publicRss ? _self.publicRss : publicRss // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,qrCodeImage: null == qrCodeImage ? _self.qrCodeImage : qrCodeImage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension ItemAccountPatterns on ItemAccount {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemAccount() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemAccount value)  $default,){
final _that = this;
switch (_that) {
case _ItemAccount():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemAccount value)?  $default,){
final _that = this;
switch (_that) {
case _ItemAccount() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bankId,  String accountNumberOrigin,  String bankNote,  String accountName,  String bankBranch,  int publicRss,  String id,  String accountNumber,  int type,  String qrCodeImage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemAccount() when $default != null:
return $default(_that.bankId,_that.accountNumberOrigin,_that.bankNote,_that.accountName,_that.bankBranch,_that.publicRss,_that.id,_that.accountNumber,_that.type,_that.qrCodeImage);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bankId,  String accountNumberOrigin,  String bankNote,  String accountName,  String bankBranch,  int publicRss,  String id,  String accountNumber,  int type,  String qrCodeImage)  $default,) {final _that = this;
switch (_that) {
case _ItemAccount():
return $default(_that.bankId,_that.accountNumberOrigin,_that.bankNote,_that.accountName,_that.bankBranch,_that.publicRss,_that.id,_that.accountNumber,_that.type,_that.qrCodeImage);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bankId,  String accountNumberOrigin,  String bankNote,  String accountName,  String bankBranch,  int publicRss,  String id,  String accountNumber,  int type,  String qrCodeImage)?  $default,) {final _that = this;
switch (_that) {
case _ItemAccount() when $default != null:
return $default(_that.bankId,_that.accountNumberOrigin,_that.bankNote,_that.accountName,_that.bankBranch,_that.publicRss,_that.id,_that.accountNumber,_that.type,_that.qrCodeImage);case _:
  return null;

}
}

}

@JsonSerializable()

class _ItemAccount implements ItemAccount {
  const _ItemAccount({required this.bankId, required this.accountNumberOrigin, required this.bankNote, required this.accountName, required this.bankBranch, required this.publicRss, required this.id, required this.accountNumber, required this.type, required this.qrCodeImage});
  factory _ItemAccount.fromJson(Map<String, dynamic> json) => _$ItemAccountFromJson(json);

@override final  String bankId;
@override final  String accountNumberOrigin;
@override final  String bankNote;
@override final  String accountName;
@override final  String bankBranch;
@override final  int publicRss;
@override final  String id;
@override final  String accountNumber;
@override final  int type;
@override final  String qrCodeImage;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemAccountCopyWith<_ItemAccount> get copyWith => __$ItemAccountCopyWithImpl<_ItemAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemAccount&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountNumberOrigin, accountNumberOrigin) || other.accountNumberOrigin == accountNumberOrigin)&&(identical(other.bankNote, bankNote) || other.bankNote == bankNote)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.bankBranch, bankBranch) || other.bankBranch == bankBranch)&&(identical(other.publicRss, publicRss) || other.publicRss == publicRss)&&(identical(other.id, id) || other.id == id)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.type, type) || other.type == type)&&(identical(other.qrCodeImage, qrCodeImage) || other.qrCodeImage == qrCodeImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountNumberOrigin,bankNote,accountName,bankBranch,publicRss,id,accountNumber,type,qrCodeImage);

@override
String toString() {
  return 'ItemAccount(bankId: $bankId, accountNumberOrigin: $accountNumberOrigin, bankNote: $bankNote, accountName: $accountName, bankBranch: $bankBranch, publicRss: $publicRss, id: $id, accountNumber: $accountNumber, type: $type, qrCodeImage: $qrCodeImage)';
}

}

abstract mixin class _$ItemAccountCopyWith<$Res> implements $ItemAccountCopyWith<$Res> {
  factory _$ItemAccountCopyWith(_ItemAccount value, $Res Function(_ItemAccount) _then) = __$ItemAccountCopyWithImpl;
@override @useResult
$Res call({
 String bankId, String accountNumberOrigin, String bankNote, String accountName, String bankBranch, int publicRss, String id, String accountNumber, int type, String qrCodeImage
});

}
class __$ItemAccountCopyWithImpl<$Res>
    implements _$ItemAccountCopyWith<$Res> {
  __$ItemAccountCopyWithImpl(this._self, this._then);

  final _ItemAccount _self;
  final $Res Function(_ItemAccount) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? bankId = null,Object? accountNumberOrigin = null,Object? bankNote = null,Object? accountName = null,Object? bankBranch = null,Object? publicRss = null,Object? id = null,Object? accountNumber = null,Object? type = null,Object? qrCodeImage = null,}) {
  return _then(_ItemAccount(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountNumberOrigin: null == accountNumberOrigin ? _self.accountNumberOrigin : accountNumberOrigin // ignore: cast_nullable_to_non_nullable
as String,bankNote: null == bankNote ? _self.bankNote : bankNote // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,bankBranch: null == bankBranch ? _self.bankBranch : bankBranch // ignore: cast_nullable_to_non_nullable
as String,publicRss: null == publicRss ? _self.publicRss : publicRss // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,qrCodeImage: null == qrCodeImage ? _self.qrCodeImage : qrCodeImage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
