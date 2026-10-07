
part of 'fetch_bank_account_response.dart';

_FetchBankAccountsResponse _$FetchBankAccountsResponseFromJson(
  Map<String, dynamic> json,
) => _FetchBankAccountsResponse(
  codePayHelpUrl: json['codePayHelpUrl'] as String? ?? '',
  bankHelpUrl: json['bankHelpUrl'] as String? ?? '',
  data: FetchBankAccountsData.fromJson(json['data'] as Map<String, dynamic>),
  eWalletHelpUrl: json['eWalletHelpUrl'] as String? ?? '',
  status: (json['status'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$FetchBankAccountsResponseToJson(
  _FetchBankAccountsResponse instance,
) => <String, dynamic>{
  'codePayHelpUrl': instance.codePayHelpUrl,
  'bankHelpUrl': instance.bankHelpUrl,
  'data': instance.data.toJson(),
  'eWalletHelpUrl': instance.eWalletHelpUrl,
  'status': instance.status,
};
