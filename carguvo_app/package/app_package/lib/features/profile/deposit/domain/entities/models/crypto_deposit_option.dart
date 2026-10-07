import 'package:freezed_annotation/freezed_annotation.dart';

part 'crypto_deposit_option.freezed.dart';
part 'crypto_deposit_option.g.dart';

@freezed
sealed class CryptoDepositOption with _$CryptoDepositOption {
  const factory CryptoDepositOption({
    @Default([]) List<String> depositNetworks,
    required String bankId,
    required String currencyName,
    required String exchangeRateString,
    required int exchangeRate,
    required int fee,
    required String network,
  }) = _CryptoDepositOption;

  factory CryptoDepositOption.fromJson(Map<String, dynamic> json) =>
      _$CryptoDepositOptionFromJson(json);
}
