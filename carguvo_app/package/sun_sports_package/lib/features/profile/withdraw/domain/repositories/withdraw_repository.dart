import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/profile/withdraw/domain/entities/withdraw_bank_request.dart';
import 'package:sun_sports/features/profile/withdraw/domain/entities/withdraw_card_request.dart';
import 'package:sun_sports/features/profile/withdraw/domain/entities/withdraw_crypto_request.dart';
import 'package:sun_sports/features/profile/withdraw/domain/entities/withdraw_response.dart';

abstract class WithdrawRepository {
  Future<Either<Failure, WithdrawResponse>> submitBankWithdraw(
    WithdrawBankRequest request,
  );

  Future<Either<Failure, WithdrawResponse>> submitCardWithdraw(
    WithdrawCardRequest request,
  );

  Future<Either<Failure, WithdrawResponse>> submitCryptoWithdraw(
    WithdrawCryptoRequest request,
  );
}
