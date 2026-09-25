import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/create_code_pay_qr_usecase.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/submit_codepay_deposit_usecase.dart';
import 'package:sun_sports/features/profile/deposit/data/storage/deposit_storage.dart';

class CodepaySubmitNotifier extends StateNotifier<CodepaySubmitState> {
  final SubmitCodepayDepositUseCase _submitCodepayDepositUseCase;
  final CreateCodePayQrUseCase _createCodePayQrUseCase;
  CodepayCreateQrResponse? _codepayCreateResponse;

  CodepaySubmitNotifier(
    this._submitCodepayDepositUseCase,
    this._createCodePayQrUseCase,
  ) : super(const CodepaySubmitState.idle());

  CodepayCreateQrResponse? get codepayCreateResponse => _codepayCreateResponse;

  Future<void> submit(CodepayDepositRequest request) async {
    state = const CodepaySubmitState.submitting();

    final result = await _submitCodepayDepositUseCase(request);

    result.fold(
      (failure) => state = CodepaySubmitState.error(failure.message),
      (response) => state = const CodepaySubmitState.success(),
    );
  }

  Future<void> createCodePay(
    CodepayCreateQrRequest request, {
    PaymentMethod paymentMethod = PaymentMethod.codepay,
    String? walletName,
  }) async {
    state = const CodepaySubmitState.submitting();

    final result = await _createCodePayQrUseCase(request);

    result.fold(
      (failure) => state = CodepaySubmitState.error(failure.message),
      (response) async {
        _codepayCreateResponse = response;
        state = const CodepaySubmitState.success();
        final userId = SbHttpManager.instance.custId;
        if (userId.isNotEmpty) {
          await DepositStorage.saveCodepayResponse(
            response,
            userId: userId,
            paymentMethod: paymentMethod,
            walletName: walletName,
          );
        }
      },
    );
  }

  void reset() {
    state = const CodepaySubmitState.idle();
    _codepayCreateResponse = null;
  }
}
