import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/repositories/deposit_repository.dart';

class CreateCodePayQrUseCase {
  final DepositRepository _repository;

  CreateCodePayQrUseCase(this._repository);

  Future<Either<Failure, CodepayCreateQrResponse>> call(
    CodepayCreateQrRequest request,
  ) async {
    return await _repository.createCodePay(request);
  }
}
