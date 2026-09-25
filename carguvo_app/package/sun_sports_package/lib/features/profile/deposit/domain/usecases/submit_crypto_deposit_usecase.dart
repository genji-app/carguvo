import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/repositories/deposit_repository.dart';

class SubmitCryptoDepositUseCase {
  final DepositRepository _repository;

  SubmitCryptoDepositUseCase(this._repository);

  Future<Either<Failure, DepositResponse>> call(
    CryptoDepositRequest request,
  ) async {
    return await _repository.submitCryptoDeposit(request);
  }
}
