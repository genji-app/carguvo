import 'package:freezed_annotation/freezed_annotation.dart';

part 'gift_card.freezed.dart';
part 'gift_card.g.dart';

@freezed
sealed class CashoutGiftCard with _$CashoutGiftCard {
  const factory CashoutGiftCard({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'url') String? url,
    @JsonKey(name: 'items') List<GiftCardItem>? items,
  }) = _CashoutGiftCard;

  factory CashoutGiftCard.fromJson(Map<String, Object?> json) =>
      _$CashoutGiftCardFromJson(json);
}

@freezed
sealed class GiftCardItem with _$GiftCardItem {
  const factory GiftCardItem({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'displayName') String? displayName,
    @JsonKey(name: 'image') String? image,
    @JsonKey(name: 'amount') int? amount,
    @JsonKey(name: 'price') int? price,
    @JsonKey(name: 'active') bool? active,
    @JsonKey(name: 'type') int? type,
    @JsonKey(name: 'brand') String? brand,
    @JsonKey(name: 'telcoId') int? telcoId,
  }) = _GiftCardItem;

  factory GiftCardItem.fromJson(Map<String, Object?> json) =>
      _$GiftCardItemFromJson(json);
}
