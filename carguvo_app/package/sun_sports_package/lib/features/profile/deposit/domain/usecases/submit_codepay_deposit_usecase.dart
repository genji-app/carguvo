import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/repositories/deposit_repository.dart';

class SubmitCodepayDepositUseCase {
  final DepositRepository _repository;

  SubmitCodepayDepositUseCase(this._repository);

  Future<Either<Failure, DepositResponse>> call(
    CodepayDepositRequest request,
  ) async {
    return await _repository.submitCodepayDeposit(request);
  }
}
