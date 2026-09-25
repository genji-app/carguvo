import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/card_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/repositories/deposit_repository.dart';

class SubmitCardDepositUseCase {
  final DepositRepository _repository;

  SubmitCardDepositUseCase(this._repository);

  Future<Either<Failure, DepositResponse>> call(
    CardDepositRequest request,
  ) async {
    return await _repository.submitCardDeposit(request);
  }
}
