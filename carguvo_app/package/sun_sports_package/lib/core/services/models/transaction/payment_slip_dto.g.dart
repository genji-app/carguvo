
part of 'payment_slip_dto.dart';

_PaymentSlipBankDto _$PaymentSlipBankDtoFromJson(Map<String, dynamic> json) =>
    _PaymentSlipBankDto(
      bankId: json['bankId'] as String,
      publicRss: (json['publicRss'] as num).toInt(),
      type: (json['type'] as num).toInt(),
      accountName: json['accountName'] as String?,
      accountNumber: json['accountNumber'] as String?,
    );

Map<String, dynamic> _$PaymentSlipBankDtoToJson(_PaymentSlipBankDto instance) =>
    <String, dynamic>{
      'bankId': instance.bankId,
      'publicRss': instance.publicRss,
      'type': instance.type,
      'accountName': instance.accountName,
      'accountNumber': instance.accountNumber,
    };

_PaymentSlipDto _$PaymentSlipDtoFromJson(Map<String, dynamic> json) =>
    _PaymentSlipDto(
      id: (json['id'] as num).toInt(),
      transactionCode: json['transactionCode'] as String,
      amount: json['amount'] as num,
      type: (json['type'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      slipType: (json['slipType'] as num).toInt(),
      statusDescription: json['statusDescription'] as String,
      bankSent: PaymentSlipBankDto.fromJson(
        json['bankSent'] as Map<String, dynamic>,
      ),
      bankReceive: PaymentSlipBankDto.fromJson(
        json['bankReceive'] as Map<String, dynamic>,
      ),
      requestTime: (json['requestTime'] as num).toInt(),
      responseTime: (json['responseTime'] as num).toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PaymentSlipDtoToJson(_PaymentSlipDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionCode': instance.transactionCode,
      'amount': instance.amount,
      'type': instance.type,
      'status': instance.status,
      'slipType': instance.slipType,
      'statusDescription': instance.statusDescription,
      'bankSent': instance.bankSent.toJson(),
      'bankReceive': instance.bankReceive.toJson(),
      'requestTime': instance.requestTime,
      'responseTime': instance.responseTime,
      'notes': instance.notes,
    };

_PaymentSlipResponseDto _$PaymentSlipResponseDtoFromJson(
  Map<String, dynamic> json,
) => _PaymentSlipResponseDto(
  count: (json['count'] as num).toInt(),
  message: json['message'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => PaymentSlipDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaymentSlipResponseDtoToJson(
  _PaymentSlipResponseDto instance,
) => <String, dynamic>{
  'count': instance.count,
  'message': instance.message,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
