import 'package:freezed_annotation/freezed_annotation.dart';
import 'fetch_bank_account_data.dart';

part 'fetch_bank_account_response.freezed.dart';
part 'fetch_bank_account_response.g.dart';

@freezed
sealed class FetchBankAccountsResponse with _$FetchBankAccountsResponse {
  const factory FetchBankAccountsResponse({
    @Default('') String codePayHelpUrl,
    @Default('') String bankHelpUrl,
    required FetchBankAccountsData data,
    @Default('') String eWalletHelpUrl,
    @Default(0) int status,
  }) = _FetchBankAccountsResponse;

  factory FetchBankAccountsResponse.fromJson(Map<String, dynamic> json) =>
      _$FetchBankAccountsResponseFromJson(json);
}
