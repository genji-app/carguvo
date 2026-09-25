import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/bank_transaction_slip_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/repositories/deposit_repository.dart';

class CreateTransactionSlipUseCase {
  final DepositRepository _repository;

  CreateTransactionSlipUseCase(this._repository);

  Future<Either<Failure, DepositResponse>> call(
    BankTransactionSlipRequest request,
  ) async {
    return await _repository.createTransactionSlip(request);
  }
}
