
part of 'deposit_response_model.dart';

_DepositResponseModel _$DepositResponseModelFromJson(
  Map<String, dynamic> json,
) => _DepositResponseModel(
  transactionId: json['transaction_id'] as String,
  qrCodeUrl: json['qr_code_url'] as String?,
  depositAddress: json['deposit_address'] as String?,
  additionalData: json['additional_data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DepositResponseModelToJson(
  _DepositResponseModel instance,
) => <String, dynamic>{
  'transaction_id': instance.transactionId,
  'qr_code_url': instance.qrCodeUrl,
  'deposit_address': instance.depositAddress,
  'additional_data': instance.additionalData,
};
