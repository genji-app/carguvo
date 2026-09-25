import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/profile/withdraw/domain/entities/withdraw_crypto_request.dart';
import 'package:sun_sports/features/profile/withdraw/domain/entities/withdraw_response.dart';
import 'package:sun_sports/features/profile/withdraw/domain/repositories/withdraw_repository.dart';

class SubmitWithdrawCryptoUseCase {
  final WithdrawRepository _repository;

  SubmitWithdrawCryptoUseCase(this._repository);

  Future<Either<Failure, WithdrawResponse>> call(
    WithdrawCryptoRequest request,
  ) async {
    return await _repository.submitCryptoWithdraw(request);
  }
}
