import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:paygate_domain/paygate_domain.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/core/network/sb_api_client.dart'
    show HttpException, TimeoutHttpException;
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/hash_utils.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/fetch_bank_account_response.dart';
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
import 'package:sun_sports/features/profile/deposit/domain/repositories/deposit_repository.dart';

class DepositRepositoryImpl implements DepositRepository {
  final SbHttpManager _httpManager;
  final AppLogger _logger = AppLogger(tag: 'DepositRepository');

  DepositRepositoryImpl({SbHttpManager? httpManager})
    : _httpManager = httpManager ?? SbHttpManager.instance;

  static const _mockDepositConfig = FetchBankAccountsData(
    minTranfer: 0,
    tranferTax: 0,
    sSportUrl: '',
  );

  @override
  Future<Either<Failure, FetchBankAccountsData>> getConfigDeposit() async {
    try {
      final config = SbConfig.instance;
      final apiDomain = config.mainConfig['api_domain'] as String? ?? '';

      if (apiDomain.isEmpty) {
        return Right(_mockDepositConfig);
      }

      final normalizedApiDomain = apiDomain.endsWith('/')
          ? apiDomain
          : '$apiDomain/';
      final url = '${normalizedApiDomain}paygate?command=fetchBankAccounts';

      final userToken = SbHttpManager.instance.userToken;
      if (userToken.isEmpty) {
        return Right(_mockDepositConfig);
      }

      final responseJson = await _httpManager.send(
        url,
        json: true,
        authorization: true,
        token: userToken,
      );

      debugPrint('responseJson===============: $responseJson');

      if (responseJson == null) {
        return Right(_mockDepositConfig);
      }

      if (responseJson is! Map<String, dynamic>) {
        return Right(_mockDepositConfig);
      }

      FetchBankAccountsResponse response;
      try {
        response = FetchBankAccountsResponse.fromJson(responseJson);
      } catch (e, stackTrace) {
        _logger.e(
          'Failed to parse deposit config response',
          error: e,
          stackTrace: stackTrace,
        );
        return Right(_mockDepositConfig);
      }

      if (response.status != 0) {
        return Right(_mockDepositConfig);
      }

      return Right(response.data);
    } on HttpException catch (e) {
      _logger.w('Deposit config lỗi mạng ${e.statusCode}: ${e.message}');
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to fetch deposit config from API',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(const Failure.unexpected());
    }
  }

  @override
  Future<Either<Failure, DepositResponse>> submitBankDeposit(
    BankDepositRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    return Right(
      DepositResponse(
        transactionId: 'TX${DateTime.now().millisecondsSinceEpoch}',
        qrCodeUrl: 'https://example.com/qr-code.png',
        additionalData: {
          'bank_id': request.bankId,
          'account_number': request.accountNumber,
          'account_name': request.accountName,
          'amount': request.amount,
        },
      ),
    );
  }

  @override
  Future<Either<Failure, DepositResponse>> submitCryptoDeposit(
    CryptoDepositRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    return Right(
      DepositResponse(
        transactionId: 'TX${DateTime.now().millisecondsSinceEpoch}',
        qrCodeUrl: 'https://example.com/qr-code.png',
        additionalData: {
          'crypto_type': request.cryptoType,
          'amount': request.amount,
          'deposit_address': request.depositAddress,
        },
      ),
    );
  }

  @override
  Future<Either<Failure, DepositResponse>> submitCodepayDeposit(
    CodepayDepositRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    return Right(
      DepositResponse(
        transactionId: 'TX${DateTime.now().millisecondsSinceEpoch}',
        qrCodeUrl: 'https://example.com/qr-code.png',
        additionalData: {'bank_id': request.bankId, 'amount': request.amount},
      ),
    );
  }

  @override
  Future<Either<Failure, DepositResponse>> submitCardDeposit(
    CardDepositRequest request,
  ) async {
    try {
      final config = SbConfig.instance;
      final apiDomain = config.mainConfig['api_domain'] as String? ?? '';

      if (apiDomain.isEmpty) {
        return Left(ServerFailure(message: 'API domain not configured'));
      }

      final normalizedApiDomain = apiDomain.endsWith('/')
          ? apiDomain
          : '$apiDomain/';

      final url = Uri.parse('${normalizedApiDomain}paygate')
          .replace(
            queryParameters: {
              'command': 'chargeCard',
              'serial': request.serial,
              'code': request.code,
              'telcoId': request.telcoId.toString(),
              'amount': request.amount.toString(),
            },
          )
          .toString();

      final userToken = SbHttpManager.instance.userToken;
      if (userToken.isEmpty) {
        return Left(ServerFailure(message: 'User token not available'));
      }

      final responseJson = await _httpManager.send(
        url,
        json: true,
        authorization: true,
        token: userToken,
      );

      if (responseJson == null) {
        return Left(ServerFailure(message: 'Empty response from server'));
      }

      if (responseJson is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Invalid response format'));
      }

      final status = paygateStatusOf(responseJson);

      if (PaygateCommand.chargeCard.isSoftProcessing(status)) {
        final message =
            responseJson['data']?['message'] ??
            responseJson['message'] ??
            'Thẻ đang được xử lý';

        final transactionId =
            responseJson['transactionId'] ??
            responseJson['transaction_id'] ??
            responseJson['data']?['transactionId'] ??
            responseJson['data']?['transaction_id'] ??
            'TX${DateTime.now().millisecondsSinceEpoch}';

        return Right(
          DepositResponse(
            transactionId: transactionId.toString(),
            additionalData: {...responseJson, 'processing_message': message},
          ),
        );
      }

      if (!PaygateCommand.chargeCard.isSuccess(status)) {
        final message =
            responseJson['data']?['message'] ??
            responseJson['message'] ??
            'Có lỗi xảy ra';
        return Left(ServerFailure(message: message.toString()));
      }

      final transactionId =
          responseJson['transactionId'] ??
          responseJson['transaction_id'] ??
          responseJson['data']?['transactionId'] ??
          responseJson['data']?['transaction_id'] ??
          DateTime.now().millisecondsSinceEpoch.toString();

      _logger.d('🆔 Extracted transaction ID: $transactionId');

      return Right(
        DepositResponse(
          transactionId: transactionId.toString(),
          additionalData: responseJson,
        ),
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to charge card', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DepositResponse>> submitGiftcodeDeposit(
    GiftcodeDepositRequest request,
  ) async {
    try {
      final config = SbConfig.instance;
      final apiDomain = config.mainConfig['api_domain'] as String? ?? '';

      if (apiDomain.isEmpty) {
        return Left(ServerFailure(message: 'API domain not configured'));
      }

      final normalizedApiDomain = apiDomain.endsWith('/')
          ? apiDomain
          : '$apiDomain/';

      final url = '${normalizedApiDomain}paygate';

      final userToken = SbHttpManager.instance.userToken;
      if (userToken.isEmpty) {
        return Left(ServerFailure(message: 'User token not available'));
      }

      final hash = HashUtils.createGiftCodeHash(
        code: request.giftCode,
        hsk: SbConfig.hsk,
      );

      final command = kIsWeb ? 'preUseGiftCodeWeb' : 'preUseGiftCode';

      final body = <String, dynamic>{
        'command': command,
        'code': request.giftCode,
        'hash': hash,
      };

      final responseJson = await _httpManager.send(
        url,
        post: true,
        body: jsonEncode(body),
        contentJson: true,
        json: true,
        authorization: true,
        token: userToken,
      );

      if (responseJson == null) {
        return Left(ServerFailure(message: 'Empty response from server'));
      }

      if (responseJson is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Invalid response format'));
      }

      final status = paygateStatusOf(responseJson);
      final data = responseJson['data'];
      final dataMessage = (data is Map<String, dynamic>)
          ? data['message']?.toString()
          : null;

      if (PaygateCommand.useGiftCode.isSuccess(status)) {
        final transactionId =
            responseJson['transactionId'] ??
            responseJson['transaction_id'] ??
            (data is Map<String, dynamic>
                ? (data['transactionId'] ?? data['transaction_id'])
                : null) ??
            'TX${DateTime.now().millisecondsSinceEpoch}';

        return Right(
          DepositResponse(
            transactionId: transactionId.toString(),
            qrCodeUrl: null,
            additionalData: {
              ...responseJson,
              if (dataMessage != null) 'success_message': dataMessage,
            },
          ),
        );
      }

      if (status == 500) {
        return Left(ServerFailure(message: ''));
      }

      final message =
          dataMessage ?? responseJson['message']?.toString() ?? 'Có lỗi xảy ra';
      return Left(ServerFailure(message: message));
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to submit giftcode deposit',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DepositResponse>> createTransactionSlip(
    BankTransactionSlipRequest request,
  ) async {
    try {
      final config = SbConfig.instance;
      final apiDomain = config.mainConfig['api_domain'] as String? ?? '';

      if (apiDomain.isEmpty) {
        return Left(ServerFailure(message: 'API domain not configured'));
      }

      final normalizedApiDomain = apiDomain.endsWith('/')
          ? apiDomain
          : '$apiDomain/';

      final url = Uri.parse('${normalizedApiDomain}paygate')
          .replace(
            queryParameters: {
              'command': 'createTransactionSlip',
              'bankAccountId': request.bankAccountId,
              'slipType': '1',
              'amount': request.amount.toString(),
              'accountName': request.accountName,
              'transactionCode': request.transactionCode,
              'type': request.type.toString(),
            },
          )
          .toString();

      final userToken = SbHttpManager.instance.userToken;
      if (userToken.isEmpty) {
        return Left(ServerFailure(message: 'User token not available'));
      }

      final responseJson = await _httpManager.send(
        url,
        json: true,
        authorization: true,
        token: userToken,
      );

      if (responseJson == null) {
        return Left(ServerFailure(message: 'Empty response from server'));
      }

      if (responseJson is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Invalid response format'));
      }

      if (!PaygateCommand.createDepositSlip.isSuccess(
        paygateStatusOf(responseJson),
      )) {
        final message =
            responseJson['message'] ??
            responseJson['data']?['message'] ??
            'Có lỗi xảy ra';
        return Left(ServerFailure(message: message.toString()));
      }

      final transactionId =
          responseJson['transactionId'] ??
          responseJson['transaction_id'] ??
          responseJson['data']?['transactionId'] ??
          responseJson['data']?['transaction_id'] ??
          DateTime.now().millisecondsSinceEpoch.toString();

      _logger.d('🆔 Extracted transaction ID: $transactionId');

      return Right(
        DepositResponse(
          transactionId: transactionId.toString(),
          additionalData: responseJson,
        ),
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to create transaction slip',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CodepayCreateQrResponse>> createCodePay(
    CodepayCreateQrRequest request,
  ) async {
    try {
      final config = SbConfig.instance;
      final apiDomain = config.mainConfig['api_domain'] as String? ?? '';

      if (apiDomain.isEmpty) {
        return Left(ServerFailure(message: 'API domain not configured'));
      }

      final normalizedApiDomain = apiDomain.endsWith('/')
          ? apiDomain
          : '$apiDomain/';

      final url = Uri.parse('${normalizedApiDomain}paygate')
          .replace(
            queryParameters: {
              'command': 'createCodePay',
              'bankAccountId': request.bankAccountId,
              'amount': request.amount.toString(),
              'bankId': request.bankId,
            },
          )
          .toString();

      final userToken = SbHttpManager.instance.userToken;
      if (userToken.isEmpty) {
        return Left(ServerFailure(message: 'User token not available'));
      }

      final responseJson = await _httpManager.send(
        url,
        json: true,
        authorization: true,
        token: userToken,
      );

      if (responseJson == null) {
        return Left(ServerFailure(message: 'Empty response from server'));
      }

      if (responseJson is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Invalid response format'));
      }

      if (!PaygateCommand.createCodePay.isSuccess(
        paygateStatusOf(responseJson),
      )) {
        final message =
            responseJson['message'] ??
            responseJson['data']?['message'] ??
            'Có lỗi xảy ra';
        return Left(ServerFailure(message: message.toString()));
      }

      final data = responseJson['data'];
      if (data == null || data is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Missing data in response'));
      }

      final qrResponse = CodepayCreateQrResponse.fromJson(data);
      return Right(qrResponse);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to create Codepay QR',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CodepayCreateQrResponse>> checkCodePay(
    CheckCodePayRequest request,
  ) async {
    try {
      final config = SbConfig.instance;
      final apiDomain = config.mainConfig['api_domain'] as String? ?? '';

      if (apiDomain.isEmpty) {
        return Left(ServerFailure(message: 'API domain not configured'));
      }

      final normalizedApiDomain = apiDomain.endsWith('/')
          ? apiDomain
          : '$apiDomain/';

      final url = Uri.parse('${normalizedApiDomain}paygate')
          .replace(
            queryParameters: {
              'command': 'checkCodePay',
              'bankAccountId': request.bankAccountId,
              'bankId': request.bankId,
              'type': request.type,
            },
          )
          .toString();

      final userToken = SbHttpManager.instance.userToken;
      if (userToken.isEmpty) {
        return Left(ServerFailure(message: 'User token not available'));
      }

      final responseJson = await _httpManager.send(
        url,
        json: true,
        authorization: true,
        token: userToken,
      );

      if (responseJson == null) {
        return Left(ServerFailure(message: 'Empty response from server'));
      }

      if (responseJson is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Invalid response format'));
      }

      if (!PaygateCommand.checkCodePay.isSuccess(
        paygateStatusOf(responseJson),
      )) {
        final message =
            responseJson['message'] ??
            responseJson['data']?['message'] ??
            'Có lỗi xảy ra';
        return Left(ServerFailure(message: message.toString()));
      }

      final data = responseJson['data'];
      if (data == null || data is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Missing data in response'));
      }

      final qrResponse = CodepayCreateQrResponse.fromJson(data);
      return Right(qrResponse);
    } catch (e, stackTrace) {
      _logger.e('Failed to check Codepay QR', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CryptoAddressResponse>> getCryptoAddress(
    CryptoAddressRequest request,
  ) async {
    try {
      final config = SbConfig.instance;
      final apiDomain = config.mainConfig['api_domain'] as String? ?? '';

      if (apiDomain.isEmpty) {
        return Left(ServerFailure(message: 'API domain not configured'));
      }

      final normalizedApiDomain = apiDomain.endsWith('/')
          ? apiDomain
          : '$apiDomain/';

      final url = '${normalizedApiDomain}paygate';

      final userToken = SbHttpManager.instance.userToken;
      if (userToken.isEmpty) {
        return Left(ServerFailure(message: 'User token not available'));
      }

      final bodyJson = request.toJson();
      final bodyString = jsonEncode(bodyJson);

      final responseJson = await _httpManager.send(
        url,
        post: true,
        body: bodyString,
        contentJson: true,
        json: true,
        authorization: true,
        token: userToken,
      );

      if (responseJson == null) {
        return Left(ServerFailure(message: 'Empty response from server'));
      }

      if (responseJson is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Invalid response format'));
      }

      if (!PaygateCommand.getCryptoAddress.isSuccess(
        paygateStatusOf(responseJson),
      )) {
        final message =
            responseJson['message'] ??
            responseJson['data']?['message'] ??
            'Có lỗi xảy ra';
        return Left(ServerFailure(message: message.toString()));
      }

      final addressResponse = CryptoAddressResponse.fromJson(responseJson);
      return Right(addressResponse);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get crypto address',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyBankAccount({
    required String bankId,
    required String accountHolder,
    required String accountNo,
  }) async {
    try {
      final config = SbConfig.instance;
      final apiDomain = config.mainConfig['api_domain'] as String? ?? '';

      if (apiDomain.isEmpty) {
        return Left(ServerFailure(message: 'API domain not configured'));
      }

      final normalizedApiDomain = apiDomain.endsWith('/')
          ? apiDomain
          : '$apiDomain/';

      final url = Uri.parse('${normalizedApiDomain}paygate')
          .replace(
            queryParameters: <String, String>{
              'command': 'userCreateBankAccount',
              'bankId': bankId,
              'accountHolder': accountHolder,
              'accountNo': accountNo,
            },
          )
          .toString();

      final userToken = SbHttpManager.instance.userToken;
      if (userToken.isEmpty) {
        return Left(ServerFailure(message: 'User token not available'));
      }

      final responseJson = await _httpManager.send(
        url,
        json: true,
        authorization: true,
        token: userToken,
      );

      if (responseJson == null) {
        return Left(ServerFailure(message: 'Empty response from server'));
      }

      if (responseJson is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Invalid response format'));
      }

      final status = paygateStatusOf(responseJson);
      final message =
          (responseJson['data'] as Map<String, dynamic>?)?['message']
              as String? ??
          responseJson['message']?.toString() ??
          'Lỗi hệ thống';

      if (!PaygateCommand.createUserBankAccount.isSuccess(status)) {
        return Left(ServerFailure(message: message));
      }

      return Right(message);
    } catch (e, stackTrace) {
      _logger.e('verifyBankAccount error', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
