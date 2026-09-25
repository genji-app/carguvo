import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/bank_deposit_request.dart';

part 'bank_deposit_request_model.freezed.dart';
part 'bank_deposit_request_model.g.dart';

@freezed
sealed class BankDepositRequestModel with _$BankDepositRequestModel {
  const factory BankDepositRequestModel({
    @JsonKey(name: 'bank_id') required String bankId,
    @JsonKey(name: 'account_number') required String accountNumber,
    @JsonKey(name: 'account_name') required String accountName,
    required String amount,
  }) = _BankDepositRequestModel;

  factory BankDepositRequestModel.fromJson(Map<String, dynamic> json) =>
      _$BankDepositRequestModelFromJson(json);
}

extension BankDepositRequestModelX on BankDepositRequestModel {
  BankDepositRequest toEntity() => BankDepositRequest(
    bankId: bankId,
    accountNumber: accountNumber,
    accountName: accountName,
    amount: amount,
  );
}

extension BankDepositRequestX on BankDepositRequest {
  BankDepositRequestModel toModel() => BankDepositRequestModel(
    bankId: bankId,
    accountNumber: accountNumber,
    accountName: accountName,
    amount: amount,
  );
}
