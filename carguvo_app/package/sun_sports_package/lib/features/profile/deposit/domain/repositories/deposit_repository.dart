import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/bank_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/bank_transaction_slip_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/card_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/check_codepay_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_address_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_address_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/giftcode_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';

abstract class DepositRepository {
  Future<Either<Failure, FetchBankAccountsData>> getConfigDeposit();

  Future<Either<Failure, DepositResponse>> submitBankDeposit(
    BankDepositRequest request,
  );

  Future<Either<Failure, DepositResponse>> submitCodepayDeposit(
    CodepayDepositRequest request,
  );

  Future<Either<Failure, DepositResponse>> submitCryptoDeposit(
    CryptoDepositRequest request,
  );

  Future<Either<Failure, DepositResponse>> submitCardDeposit(
    CardDepositRequest request,
  );

  Future<Either<Failure, DepositResponse>> submitGiftcodeDeposit(
    GiftcodeDepositRequest request,
  );

  Future<Either<Failure, DepositResponse>> createTransactionSlip(
    BankTransactionSlipRequest request,
  );

  Future<Either<Failure, CodepayCreateQrResponse>> createCodePay(
    CodepayCreateQrRequest request,
  );

  Future<Either<Failure, CodepayCreateQrResponse>> checkCodePay(
    CheckCodePayRequest request,
  );

  Future<Either<Failure, CryptoAddressResponse>> getCryptoAddress(
    CryptoAddressRequest request,
  );

  Future<Either<Failure, String>> verifyBankAccount({
    required String bankId,
    required String accountHolder,
    required String accountNo,
  });
}
