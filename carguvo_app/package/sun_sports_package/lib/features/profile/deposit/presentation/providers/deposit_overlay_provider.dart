import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';

final depositOverlayVisibleProvider = StateProvider<bool>((ref) => false);
final codepayTransferOverlayVisibleProvider = StateProvider<bool>(
  (ref) => false,
);

final needVerifyBankAccountOverrideProvider = StateProvider<bool?>(
  (ref) => null,
);

final needVerifyBankAccountProvider = Provider<bool>((ref) {
  final override = ref.watch(needVerifyBankAccountOverrideProvider);
  if (override != null) {
    return override;
  }

  final depositDataAsync = ref.watch(configDepositProvider);
  return depositDataAsync.maybeWhen(
    data: (data) => data.needVerifyBankAccount,
    orElse: () =>
        true,
  );
});
