import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';
import 'package:sun_sports/features/profile/deposit/domain/repositories/deposit_repository.dart';

class GetConfigDepositUseCase {
  final DepositRepository _repository;

  GetConfigDepositUseCase(this._repository);

  Future<Either<Failure, FetchBankAccountsData>> call() async {
    return await _repository.getConfigDeposit();
  }
}
