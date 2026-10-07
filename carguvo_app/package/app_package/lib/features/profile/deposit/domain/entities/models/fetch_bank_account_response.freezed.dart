// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fetch_bank_account_response.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$FetchBankAccountsResponse {

 String get codePayHelpUrl; String get bankHelpUrl; FetchBankAccountsData get data; String get eWalletHelpUrl; int get status;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FetchBankAccountsResponseCopyWith<FetchBankAccountsResponse> get copyWith => _$FetchBankAccountsResponseCopyWithImpl<FetchBankAccountsResponse>(this as FetchBankAccountsResponse, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FetchBankAccountsResponse&&(identical(other.codePayHelpUrl, codePayHelpUrl) || other.codePayHelpUrl == codePayHelpUrl)&&(identical(other.bankHelpUrl, bankHelpUrl) || other.bankHelpUrl == bankHelpUrl)&&(identical(other.data, data) || other.data == data)&&(identical(other.eWalletHelpUrl, eWalletHelpUrl) || other.eWalletHelpUrl == eWalletHelpUrl)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,codePayHelpUrl,bankHelpUrl,data,eWalletHelpUrl,status);

@override
String toString() {
  return 'FetchBankAccountsResponse(codePayHelpUrl: $codePayHelpUrl, bankHelpUrl: $bankHelpUrl, data: $data, eWalletHelpUrl: $eWalletHelpUrl, status: $status)';
}

}

abstract mixin class $FetchBankAccountsResponseCopyWith<$Res>  {
  factory $FetchBankAccountsResponseCopyWith(FetchBankAccountsResponse value, $Res Function(FetchBankAccountsResponse) _then) = _$FetchBankAccountsResponseCopyWithImpl;
@useResult
$Res call({
 String codePayHelpUrl, String bankHelpUrl, FetchBankAccountsData data, String eWalletHelpUrl, int status
});

$FetchBankAccountsDataCopyWith<$Res> get data;

}
class _$FetchBankAccountsResponseCopyWithImpl<$Res>
    implements $FetchBankAccountsResponseCopyWith<$Res> {
  _$FetchBankAccountsResponseCopyWithImpl(this._self, this._then);

  final FetchBankAccountsResponse _self;
  final $Res Function(FetchBankAccountsResponse) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? codePayHelpUrl = null,Object? bankHelpUrl = null,Object? data = null,Object? eWalletHelpUrl = null,Object? status = null,}) {
  return _then(_self.copyWith(
codePayHelpUrl: null == codePayHelpUrl ? _self.codePayHelpUrl : codePayHelpUrl // ignore: cast_nullable_to_non_nullable
as String,bankHelpUrl: null == bankHelpUrl ? _self.bankHelpUrl : bankHelpUrl // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as FetchBankAccountsData,eWalletHelpUrl: null == eWalletHelpUrl ? _self.eWalletHelpUrl : eWalletHelpUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
@override
@pragma('vm:prefer-inline')
$FetchBankAccountsDataCopyWith<$Res> get data {
  
  return $FetchBankAccountsDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

extension FetchBankAccountsResponsePatterns on FetchBankAccountsResponse {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FetchBankAccountsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FetchBankAccountsResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FetchBankAccountsResponse value)  $default,){
final _that = this;
switch (_that) {
case _FetchBankAccountsResponse():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FetchBankAccountsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _FetchBankAccountsResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String codePayHelpUrl,  String bankHelpUrl,  FetchBankAccountsData data,  String eWalletHelpUrl,  int status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FetchBankAccountsResponse() when $default != null:
return $default(_that.codePayHelpUrl,_that.bankHelpUrl,_that.data,_that.eWalletHelpUrl,_that.status);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String codePayHelpUrl,  String bankHelpUrl,  FetchBankAccountsData data,  String eWalletHelpUrl,  int status)  $default,) {final _that = this;
switch (_that) {
case _FetchBankAccountsResponse():
return $default(_that.codePayHelpUrl,_that.bankHelpUrl,_that.data,_that.eWalletHelpUrl,_that.status);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String codePayHelpUrl,  String bankHelpUrl,  FetchBankAccountsData data,  String eWalletHelpUrl,  int status)?  $default,) {final _that = this;
switch (_that) {
case _FetchBankAccountsResponse() when $default != null:
return $default(_that.codePayHelpUrl,_that.bankHelpUrl,_that.data,_that.eWalletHelpUrl,_that.status);case _:
  return null;

}
}

}

@JsonSerializable()

class _FetchBankAccountsResponse implements FetchBankAccountsResponse {
  const _FetchBankAccountsResponse({this.codePayHelpUrl = '', this.bankHelpUrl = '', required this.data, this.eWalletHelpUrl = '', this.status = 0});
  factory _FetchBankAccountsResponse.fromJson(Map<String, dynamic> json) => _$FetchBankAccountsResponseFromJson(json);

@override@JsonKey() final  String codePayHelpUrl;
@override@JsonKey() final  String bankHelpUrl;
@override final  FetchBankAccountsData data;
@override@JsonKey() final  String eWalletHelpUrl;
@override@JsonKey() final  int status;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FetchBankAccountsResponseCopyWith<_FetchBankAccountsResponse> get copyWith => __$FetchBankAccountsResponseCopyWithImpl<_FetchBankAccountsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FetchBankAccountsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchBankAccountsResponse&&(identical(other.codePayHelpUrl, codePayHelpUrl) || other.codePayHelpUrl == codePayHelpUrl)&&(identical(other.bankHelpUrl, bankHelpUrl) || other.bankHelpUrl == bankHelpUrl)&&(identical(other.data, data) || other.data == data)&&(identical(other.eWalletHelpUrl, eWalletHelpUrl) || other.eWalletHelpUrl == eWalletHelpUrl)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,codePayHelpUrl,bankHelpUrl,data,eWalletHelpUrl,status);

@override
String toString() {
  return 'FetchBankAccountsResponse(codePayHelpUrl: $codePayHelpUrl, bankHelpUrl: $bankHelpUrl, data: $data, eWalletHelpUrl: $eWalletHelpUrl, status: $status)';
}

}

abstract mixin class _$FetchBankAccountsResponseCopyWith<$Res> implements $FetchBankAccountsResponseCopyWith<$Res> {
  factory _$FetchBankAccountsResponseCopyWith(_FetchBankAccountsResponse value, $Res Function(_FetchBankAccountsResponse) _then) = __$FetchBankAccountsResponseCopyWithImpl;
@override @useResult
$Res call({
 String codePayHelpUrl, String bankHelpUrl, FetchBankAccountsData data, String eWalletHelpUrl, int status
});

@override $FetchBankAccountsDataCopyWith<$Res> get data;

}
class __$FetchBankAccountsResponseCopyWithImpl<$Res>
    implements _$FetchBankAccountsResponseCopyWith<$Res> {
  __$FetchBankAccountsResponseCopyWithImpl(this._self, this._then);

  final _FetchBankAccountsResponse _self;
  final $Res Function(_FetchBankAccountsResponse) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? codePayHelpUrl = null,Object? bankHelpUrl = null,Object? data = null,Object? eWalletHelpUrl = null,Object? status = null,}) {
  return _then(_FetchBankAccountsResponse(
codePayHelpUrl: null == codePayHelpUrl ? _self.codePayHelpUrl : codePayHelpUrl // ignore: cast_nullable_to_non_nullable
as String,bankHelpUrl: null == bankHelpUrl ? _self.bankHelpUrl : bankHelpUrl // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as FetchBankAccountsData,eWalletHelpUrl: null == eWalletHelpUrl ? _self.eWalletHelpUrl : eWalletHelpUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

@override
@pragma('vm:prefer-inline')
$FetchBankAccountsDataCopyWith<$Res> get data {
  
  return $FetchBankAccountsDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
