import 'package:freezed_annotation/freezed_annotation.dart';

part 'cashout_gift_card_item.freezed.dart';
part 'cashout_gift_card_item.g.dart';

@freezed
sealed class CashoutGiftCardItem with _$CashoutGiftCardItem {
  const factory CashoutGiftCardItem({
    required String image,
    required int amount,
    required String displayName,
    required int price,
    required String name,
    required bool active,
    required String id,
    required int type,
    required String brand,
    required int telcoId,
  }) = _CashoutGiftCardItem;

  factory CashoutGiftCardItem.fromJson(Map<String, dynamic> json) =>
      _$CashoutGiftCardItemFromJson(json);
}
