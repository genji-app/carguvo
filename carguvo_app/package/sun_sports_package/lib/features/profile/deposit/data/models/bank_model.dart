import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/bank.dart';

part 'bank_model.freezed.dart';
part 'bank_model.g.dart';

@freezed
sealed class BankModel with _$BankModel {
  const factory BankModel({
    required String id,
    required String name,
    @JsonKey(name: 'icon_url') String? iconUrl,
  }) = _BankModel;

  factory BankModel.fromJson(Map<String, dynamic> json) =>
      _$BankModelFromJson(json);
}

extension BankModelX on BankModel {
  Bank toEntity() => Bank(id: id, name: name, iconUrl: iconUrl);
}
