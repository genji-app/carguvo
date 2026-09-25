import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/deposit_response.dart';

part 'deposit_response_model.freezed.dart';
part 'deposit_response_model.g.dart';

@freezed
sealed class DepositResponseModel with _$DepositResponseModel {
  const factory DepositResponseModel({
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'qr_code_url') String? qrCodeUrl,
    @JsonKey(name: 'deposit_address') String? depositAddress,
    @JsonKey(name: 'additional_data') Map<String, dynamic>? additionalData,
  }) = _DepositResponseModel;

  factory DepositResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DepositResponseModelFromJson(json);
}

extension DepositResponseModelX on DepositResponseModel {
  DepositResponse toEntity() => DepositResponse(
    transactionId: transactionId,
    qrCodeUrl: qrCodeUrl,
    depositAddress: depositAddress,
    additionalData: additionalData,
  );
}
