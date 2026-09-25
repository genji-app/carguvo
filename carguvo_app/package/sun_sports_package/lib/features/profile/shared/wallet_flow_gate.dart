library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/shared/widgets/loading/s88_loading.dart';

bool _walletFlowBusy = false;

@visibleForTesting
void debugResetWalletFlowGate() => _walletFlowBusy = false;

Future<void> openWalletFlowWithLoading({
  required BuildContext context,
  required WidgetRef ref,
  required Future<void> Function() prefetch,
  required VoidCallback open,
}) async {
  if (_walletFlowBusy) return;

  // ignore: unawaited_futures
  ref.read(userProvider.notifier).refreshBalanceThrottled();

  final loading = S88Loading.show(context);
  _walletFlowBusy = true;

  try {
    await prefetch();
  } finally {
    loading.remove();
    _walletFlowBusy = false;
  }

  if (!context.mounted) return;
  open();
}

Future<void> _ignoreError(Future<Object?> future) async {
  try {
    await future;
  } catch (_) {
  }
}

Future<void> prefetchWalletConfig(WidgetRef ref) {
  ref
    ..invalidate(configDepositProvider)
    ..invalidate(bankListProvider)
    ..invalidate(bankListNoNeedAccountProvider)
    ..invalidate(walletListProvider)
    ..invalidate(cryptoListProvider)
    ..invalidate(telcoListProvider)
    ..invalidate(cardTypeListProvider);

  return Future.wait<void>(
    <Future<void>>[
      _ignoreError(ref.read(configDepositProvider.future)),
      _ignoreError(ref.read(bankListProvider.future)),
      _ignoreError(ref.read(bankListNoNeedAccountProvider.future)),
      _ignoreError(ref.read(walletListProvider.future)),
      _ignoreError(ref.read(cryptoListProvider.future)),
      _ignoreError(ref.read(telcoListProvider.future)),
      _ignoreError(ref.read(cardTypeListProvider.future)),
    ],
  );
}
