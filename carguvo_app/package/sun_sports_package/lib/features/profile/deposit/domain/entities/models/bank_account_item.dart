import 'package:freezed_annotation/freezed_annotation.dart';
import 'item_account.dart';
import 'suggested_trans_code.dart';

part 'bank_account_item.freezed.dart';
part 'bank_account_item.g.dart';

@freezed
sealed class BankAccountItem with _$BankAccountItem {
  const factory BankAccountItem({
    @JsonKey(name: 'supportQRCode') required bool supportQrCode,
    required bool supportWithdraw,
    required int bankType,
    required String name,
    required String fullName,
    required String id,
    @Default([]) List<ItemAccount> accounts,
    @Default([]) List<SuggestedTransCode> suggestedTransCode,
    required String shortName,
    required String url,
  }) = _BankAccountItem;

  factory BankAccountItem.fromJson(Map<String, dynamic> json) =>
      _$BankAccountItemFromJson(json);
}
