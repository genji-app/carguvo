import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/withdraw/data/repositories/withdraw_repository_impl.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/notifiers/crypto_withdraw_submit_notifier.dart';
import 'package:sun_sports/features/profile/withdraw/domain/repositories/withdraw_repository.dart';
import 'package:sun_sports/features/profile/withdraw/domain/state/withdraw_state.dart';
import 'package:sun_sports/features/profile/withdraw/domain/usecases/submit_withdraw_bank_usecase.dart';
import 'package:sun_sports/features/profile/withdraw/domain/usecases/submit_withdraw_card_usecase.dart';
import 'package:sun_sports/features/profile/withdraw/domain/usecases/submit_withdraw_crypto_usecase.dart';

final withdrawRepositoryProvider = Provider<WithdrawRepository>((ref) {
  return WithdrawRepositoryImpl();
});

final submitWithdrawBankUseCaseProvider = Provider<SubmitWithdrawBankUseCase>((
  ref,
) {
  final repository = ref.read(withdrawRepositoryProvider);
  return SubmitWithdrawBankUseCase(repository);
});

final submitWithdrawCardUseCaseProvider = Provider<SubmitWithdrawCardUseCase>((
  ref,
) {
  final repository = ref.read(withdrawRepositoryProvider);
  return SubmitWithdrawCardUseCase(repository);
});

final submitWithdrawCryptoUseCaseProvider =
    Provider<SubmitWithdrawCryptoUseCase>((ref) {
      final repository = ref.read(withdrawRepositoryProvider);
      return SubmitWithdrawCryptoUseCase(repository);
    });

final cryptoWithdrawSubmitNotifierProvider =
    StateNotifierProvider.autoDispose<
      CryptoWithdrawSubmitNotifier,
      CryptoWithdrawSubmitState
    >((ref) {
      final useCase = ref.read(submitWithdrawCryptoUseCaseProvider);
      return CryptoWithdrawSubmitNotifier(useCase);
    });
