import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_address_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_address_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/repositories/deposit_repository.dart';

class GetCryptoAddressUseCase {
  final DepositRepository _repository;

  GetCryptoAddressUseCase(this._repository);

  Future<Either<Failure, CryptoAddressResponse>> call(
    CryptoAddressRequest request,
  ) async {
    return await _repository.getCryptoAddress(request);
  }
}
