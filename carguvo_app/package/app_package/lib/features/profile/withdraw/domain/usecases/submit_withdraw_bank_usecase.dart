import 'package:dartz/dartz.dart';
import 'package:app_package/core/error/failures.dart';
import 'package:app_package/features/profile/withdraw/domain/entities/withdraw_bank_request.dart';
import 'package:app_package/features/profile/withdraw/domain/entities/withdraw_response.dart';
import 'package:app_package/features/profile/withdraw/domain/repositories/withdraw_repository.dart';

class SubmitWithdrawBankUseCase {
  final WithdrawRepository _repository;

  SubmitWithdrawBankUseCase(this._repository);

  Future<Either<Failure, WithdrawResponse>> call(
    WithdrawBankRequest request,
  ) async {
    return await _repository.submitBankWithdraw(request);
  }
}
