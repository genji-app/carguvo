import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/profile/withdraw/domain/entities/withdraw_card_request.dart';
import 'package:sun_sports/features/profile/withdraw/domain/entities/withdraw_response.dart';
import 'package:sun_sports/features/profile/withdraw/domain/repositories/withdraw_repository.dart';

class SubmitWithdrawCardUseCase {
  final WithdrawRepository _repository;

  SubmitWithdrawCardUseCase(this._repository);

  Future<Either<Failure, WithdrawResponse>> call(
    WithdrawCardRequest request,
  ) async {
    return await _repository.submitCardWithdraw(request);
  }
}
