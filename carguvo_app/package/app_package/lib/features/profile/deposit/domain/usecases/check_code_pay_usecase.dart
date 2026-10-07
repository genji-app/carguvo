import 'package:dartz/dartz.dart';
import 'package:app_package/core/error/failures.dart';
import 'package:app_package/features/profile/deposit/domain/entities/check_codepay_request.dart';
import 'package:app_package/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:app_package/features/profile/deposit/domain/repositories/deposit_repository.dart';

class CheckCodePayUseCase {
  final DepositRepository _repository;

  CheckCodePayUseCase(this._repository);

  Future<Either<Failure, CodepayCreateQrResponse>> call(
    CheckCodePayRequest request,
  ) async {
    return await _repository.checkCodePay(request);
  }
}
