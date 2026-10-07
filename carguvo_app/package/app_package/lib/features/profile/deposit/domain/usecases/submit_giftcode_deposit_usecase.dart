import 'package:dartz/dartz.dart';
import 'package:app_package/core/error/failures.dart';
import 'package:app_package/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:app_package/features/profile/deposit/domain/entities/giftcode_deposit_request.dart';
import 'package:app_package/features/profile/deposit/domain/repositories/deposit_repository.dart';

class SubmitGiftcodeDepositUseCase {
  final DepositRepository _repository;

  SubmitGiftcodeDepositUseCase(this._repository);

  Future<Either<Failure, DepositResponse>> call(
    GiftcodeDepositRequest request,
  ) async {
    return await _repository.submitGiftcodeDeposit(request);
  }
}
