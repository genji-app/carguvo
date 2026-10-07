import 'package:dartz/dartz.dart';
import 'package:app_package/core/error/failures.dart';
import 'package:app_package/features/profile/deposit/domain/entities/bank_deposit_request.dart';
import 'package:app_package/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:app_package/features/profile/deposit/domain/repositories/deposit_repository.dart';

class SubmitBankDepositUseCase {
  final DepositRepository _repository;

  SubmitBankDepositUseCase(this._repository);

  Future<Either<Failure, DepositResponse>> call(
    BankDepositRequest request,
  ) async {
    return await _repository.submitBankDeposit(request);
  }
}
