import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_account.freezed.dart';
part 'item_account.g.dart';

@freezed
sealed class ItemAccount with _$ItemAccount {
  const factory ItemAccount({
    required String bankId,
    required String accountNumberOrigin,
    required String bankNote,
    required String accountName,
    required String bankBranch,
    required int publicRss,
    required String id,
    required String accountNumber,
    required int type,
    required String qrCodeImage,
  }) = _ItemAccount;

  factory ItemAccount.fromJson(Map<String, dynamic> json) =>
      _$ItemAccountFromJson(json);
}
