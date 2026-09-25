import 'package:freezed_annotation/freezed_annotation.dart';
import 'cashout_gift_card_item.dart';

part 'cashout_gift_card.freezed.dart';
part 'cashout_gift_card.g.dart';

@freezed
sealed class CashoutGiftCard with _$CashoutGiftCard {
  const factory CashoutGiftCard({
    required String name,
    required int id,
    @Default([]) List<CashoutGiftCardItem> items,
    required String url,
    @Default([])
    @JsonKey(name: 'exchangeRates')
    List<Map<String, dynamic>> exchangeRates,
    @Default(0) int bankType,
  }) = _CashoutGiftCard;

  factory CashoutGiftCard.fromJson(Map<String, dynamic> json) =>
      _$CashoutGiftCardFromJson(json);
}
