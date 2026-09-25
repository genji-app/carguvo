import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/infra_provider.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/features/profile/deposit/data/repositories/deposit_repository_impl.dart';
import 'package:sun_sports/features/profile/deposit/domain/constants/deposit_constants.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/bank.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_option.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/cashout_gift_card.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/cashout_gift_card_item.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/codepay_bank.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/crypto_deposit_option.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';
import 'package:sun_sports/features/profile/deposit/domain/repositories/deposit_repository.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/deposit_notifiers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/bank_submit_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/bank_transaction_slip_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/card_submit_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/codepay_qr_timer_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/codepay_submit_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/crypto_submit_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/giftcode_submit_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/verify_bank_submit_notifier.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/create_code_pay_qr_usecase.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/check_code_pay_usecase.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/create_transaction_slip_usecase.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/get_crypto_address_usecase.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/submit_bank_deposit_usecase.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/submit_card_deposit_usecase.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/submit_codepay_deposit_usecase.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/submit_crypto_deposit_usecase.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/submit_giftcode_deposit_usecase.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/verify_bank_account_usecase.dart';

final depositRepositoryProvider = Provider<DepositRepository>((ref) {
  final httpManager = ref.read(sbHttpManagerProvider);
  return DepositRepositoryImpl(httpManager: httpManager);
});

final bankListNoNeedAccountProvider = FutureProvider.autoDispose<List<Bank>>((
  ref,
) async {
  ref.keepAlive();

  final depositData = await ref.read(configDepositProvider.future);

  final banksWithAccounts = depositData.items
      .map(
        (BankAccountItem item) => Bank(
          id: item.id,
          name: item.name,
          iconUrl: item.url.isNotEmpty ? item.url : null,
        ),
      )
      .toList();

  return banksWithAccounts;
});

final bankListProvider = FutureProvider.autoDispose<List<Bank>>((ref) async {
  ref.keepAlive();

  final depositData = await ref.read(configDepositProvider.future);

  final banksWithAccounts = depositData.items
      .where((BankAccountItem item) => item.accounts.isNotEmpty)
      .map(
        (BankAccountItem item) => Bank(
          id: item.id,
          name: item.name,
          iconUrl: item.url.isNotEmpty ? item.url : null,
        ),
      )
      .toList();

  return banksWithAccounts;
});

final configDepositProvider = FutureProvider.autoDispose<FetchBankAccountsData>(
  (ref) async {
    ref.keepAlive();

    final repository = ref.read(depositRepositoryProvider);
    final result = await repository.getConfigDeposit();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (data) => data,
    );
  },
);

final isDepositConfigLoadingProvider = Provider.autoDispose<bool>((ref) {
  final config = ref.watch(configDepositProvider);
  if (config.isLoading && !config.hasValue) return true;

  final bank = ref.watch(bankListProvider);
  final wallet = ref.watch(walletListProvider);
  final crypto = ref.watch(cryptoListProvider);
  return (bank.isLoading && !bank.hasValue) ||
      (wallet.isLoading && !wallet.hasValue) ||
      (crypto.isLoading && !crypto.hasValue);
});

final hasBankAccountsProvider = Provider.autoDispose<bool>((ref) {
  final banksAsync = ref.watch(bankListProvider);
  return banksAsync.when(
    data: (banks) => banks.isNotEmpty,
    loading: () => true,
    error: (_, __) => true,
  );
});

final hasEWalletsProvider = Provider.autoDispose<bool>((ref) {
  final walletsAsync = ref.watch(walletListProvider);
  return walletsAsync.when(
    data: (wallets) => wallets.isNotEmpty,
    loading: () => true,
    error: (_, __) => true,
  );
});

final hasCryptoOptionsProvider = Provider.autoDispose<bool>((ref) {
  final cryptoAsync = ref.watch(cryptoListProvider);
  return cryptoAsync.when(
    data: (cryptos) => cryptos.isNotEmpty,
    loading: () => true,
    error: (_, __) => true,
  );
});

final walletListProvider = FutureProvider<List<CodepayBank>>((ref) async {
  final depositData = await ref.read(configDepositProvider.future);

  final eWallets = depositData.codepay
      .where((CodepayBank item) => item.bankType == BankType.eWallet)
      .toList();
  return eWallets;
});

final cardTypeListProvider = FutureProvider<List<CashoutGiftCard>>((ref) async {
  final depositData = await ref.read(configDepositProvider.future);
  return depositData.cashoutGiftCards;
});

final telcoListProvider = FutureProvider<List<CashoutGiftCard>>((ref) async {
  final depositData = await ref.read(configDepositProvider.future);
  return depositData.telcos
      .where((CashoutGiftCard t) => t.exchangeRates.isNotEmpty)
      .toList();
});

final denominationListProvider = Provider.family<List<String>, String?>((
  ref,
  cardTypeName,
) {
  return _denominationsFor(
    ref: ref,
    name: cardTypeName,
    pickList: (data) => data.cashoutGiftCards,
  );
});

final telcoDenominationListProvider = Provider.family<List<String>, String?>((
  ref,
  telcoName,
) {
  if (telcoName == null || telcoName.isEmpty) {
    return const [];
  }

  final depositDataAsync = ref.watch(configDepositProvider);
  return depositDataAsync.when(
    data: (depositData) {
      try {
        final selectedTelco = depositData.telcos.firstWhere(
          (CashoutGiftCard t) => t.name == telcoName,
        );

        final denominations =
            selectedTelco.exchangeRates
                .map(_extractAmount)
                .whereType<int>()
                .map(_formatAmount)
                .toSet()
                .toList()
              ..sort((String a, String b) {
                final aValue = int.tryParse(a.replaceAll(',', '')) ?? 0;
                final bValue = int.tryParse(b.replaceAll(',', '')) ?? 0;
                return aValue.compareTo(bValue);
              });

        return denominations;
      } catch (_) {
        return const [];
      }
    },
    loading: () => const [],
    error: (_, __) => const [],
  );
});

int? _extractAmount(Map<String, dynamic> rate) {
  final raw = rate['amount'];
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) {
    return int.tryParse(raw.replaceAll(',', '').replaceAll('.', ''));
  }
  return null;
}

List<String> _denominationsFor({
  required Ref ref,
  required String? name,
  required List<CashoutGiftCard> Function(FetchBankAccountsData) pickList,
}) {
  if (name == null || name.isEmpty) {
    return const [];
  }

  final depositDataAsync = ref.watch(configDepositProvider);

  return depositDataAsync.when(
    data: (depositData) {
      try {
        final list = pickList(depositData);
        final selectedCard = list.firstWhere(
          (CashoutGiftCard card) => card.name == name,
        );

        final denominations =
            selectedCard.items
                .where((CashoutGiftCardItem item) => item.active)
                .map((CashoutGiftCardItem item) => _formatAmount(item.amount))
                .toSet()
                .toList()
              ..sort((String a, String b) {
                final aValue = int.tryParse(a.replaceAll(',', '')) ?? 0;
                final bValue = int.tryParse(b.replaceAll(',', '')) ?? 0;
                return aValue.compareTo(bValue);
              });

        return denominations;
      } catch (_) {
        return const [];
      }
    },
    loading: () => const [],
    error: (_, __) => const [],
  );
}

String _formatAmount(int amount) {
  if (amount < 0) {
    return '-${_formatAmount(-amount)}';
  }

  final amountStr = amount.toString();
  final length = amountStr.length;

  if (length <= 3) {
    return amountStr;
  }

  final buffer = StringBuffer();

  final remainder = length % 3;
  final firstGroupSize = remainder == 0 ? 3 : remainder;

  buffer.write(amountStr.substring(0, firstGroupSize));

  for (int i = firstGroupSize; i < length; i += 3) {
    buffer.write(',');
    buffer.write(amountStr.substring(i, i + 3));
  }

  return buffer.toString();
}

String _formatPrice(int price) {
  final formatted = _formatAmount(price);
  return '$formatted';
}

final cryptoListProvider = FutureProvider<List<CryptoOption>>((ref) async {
  try {
    final depositData = await ref.read(configDepositProvider.future);

    if (depositData.crypto.isEmpty) {
      return [];
    }

    final cryptoOptions = <CryptoOption>[];
    for (final CryptoDepositOption crypto in depositData.crypto) {
      final networks = crypto.depositNetworks.isEmpty
          ? [crypto.network]
          : crypto.depositNetworks;

      if (networks.isEmpty) {
        continue;
      }

      for (final String network in networks) {
        if (network.isEmpty) {
          continue;
        }

        cryptoOptions.add(
          CryptoOption(
            id: '${crypto.bankId}-${crypto.currencyName.toLowerCase()}-${network.toLowerCase()}',
            name: crypto.currencyName,
            network: network,
            iconPath: AppIcons.icPaymentCrypto,
            price: _formatPrice(crypto.exchangeRate),
          ),
        );
      }
    }

    return cryptoOptions;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('cryptoListProvider error: $e');
    }
    return [];
  }
});

final submitCardDepositUseCaseProvider = Provider<SubmitCardDepositUseCase>((
  ref,
) {
  final repository = ref.read(depositRepositoryProvider);
  return SubmitCardDepositUseCase(repository);
});

final submitBankDepositUseCaseProvider = Provider<SubmitBankDepositUseCase>((
  ref,
) {
  final repository = ref.read(depositRepositoryProvider);
  return SubmitBankDepositUseCase(repository);
});

final submitCodepayDepositUseCaseProvider =
    Provider<SubmitCodepayDepositUseCase>((ref) {
      final repository = ref.read(depositRepositoryProvider);
      return SubmitCodepayDepositUseCase(repository);
    });

final submitCryptoDepositUseCaseProvider = Provider<SubmitCryptoDepositUseCase>(
  (ref) {
    final repository = ref.read(depositRepositoryProvider);
    return SubmitCryptoDepositUseCase(repository);
  },
);

final submitGiftcodeDepositUseCaseProvider =
    Provider<SubmitGiftcodeDepositUseCase>((ref) {
      final repository = ref.read(depositRepositoryProvider);
      return SubmitGiftcodeDepositUseCase(repository);
    });

final verifyBankAccountUseCaseProvider = Provider<VerifyBankAccountUseCase>((
  ref,
) {
  final repository = ref.read(depositRepositoryProvider);
  return VerifyBankAccountUseCase(repository);
});

final createCodePayQrUseCaseProvider = Provider<CreateCodePayQrUseCase>((ref) {
  final repository = ref.read(depositRepositoryProvider);
  return CreateCodePayQrUseCase(repository);
});

final checkCodePayUseCaseProvider = Provider<CheckCodePayUseCase>((ref) {
  final repository = ref.read(depositRepositoryProvider);
  return CheckCodePayUseCase(repository);
});

final getCryptoAddressUseCaseProvider = Provider<GetCryptoAddressUseCase>((
  ref,
) {
  final repository = ref.read(depositRepositoryProvider);
  return GetCryptoAddressUseCase(repository);
});

final createTransactionSlipUseCaseProvider =
    Provider<CreateTransactionSlipUseCase>((ref) {
      final repository = ref.read(depositRepositoryProvider);
      return CreateTransactionSlipUseCase(repository);
    });

final depositSelectionProvider =
    StateNotifierProvider<DepositSelectionNotifier, DepositSelectionState>(
      (ref) => DepositSelectionNotifier(),
    );

final bankSubmitNotifierProvider =
    StateNotifierProvider<BankSubmitNotifier, BankSubmitState>((ref) {
      final submitBankDepositUseCase = ref.read(
        submitBankDepositUseCaseProvider,
      );
      return BankSubmitNotifier(submitBankDepositUseCase);
    });

final bankTransactionSlipNotifierProvider =
    StateNotifierProvider<
      BankTransactionSlipNotifier,
      BankTransactionSlipState
    >((ref) {
      final createTransactionSlipUseCase = ref.read(
        createTransactionSlipUseCaseProvider,
      );
      return BankTransactionSlipNotifier(createTransactionSlipUseCase);
    });

final codepaySubmitNotifierProvider =
    StateNotifierProvider<CodepaySubmitNotifier, CodepaySubmitState>((ref) {
      final submitCodepayDepositUseCase = ref.read(
        submitCodepayDepositUseCaseProvider,
      );
      final createCodePayQrUseCase = ref.read(createCodePayQrUseCaseProvider);
      return CodepaySubmitNotifier(
        submitCodepayDepositUseCase,
        createCodePayQrUseCase,
      );
    });

final cryptoSubmitNotifierProvider =
    StateNotifierProvider<CryptoSubmitNotifier, CryptoSubmitState>((ref) {
      final submitCryptoDepositUseCase = ref.read(
        submitCryptoDepositUseCaseProvider,
      );
      final getCryptoAddressUseCase = ref.read(getCryptoAddressUseCaseProvider);
      return CryptoSubmitNotifier(
        submitCryptoDepositUseCase,
        getCryptoAddressUseCase,
      );
    });

final cardSubmitNotifierProvider =
    StateNotifierProvider<CardSubmitNotifier, CardSubmitState>((ref) {
      final submitCardDepositUseCase = ref.read(
        submitCardDepositUseCaseProvider,
      );
      return CardSubmitNotifier(submitCardDepositUseCase);
    });

final giftcodeSubmitNotifierProvider =
    StateNotifierProvider<GiftcodeSubmitNotifier, GiftcodeSubmitState>((ref) {
      final submitGiftcodeDepositUseCase = ref.read(
        submitGiftcodeDepositUseCaseProvider,
      );
      return GiftcodeSubmitNotifier(submitGiftcodeDepositUseCase);
    });

final verifyBankSubmitNotifierProvider =
    StateNotifierProvider<VerifyBankSubmitNotifier, VerifyBankSubmitState>((
      ref,
    ) {
      final useCase = ref.read(verifyBankAccountUseCaseProvider);
      return VerifyBankSubmitNotifier(ref, useCase);
    });

final codepayQrTimerProvider = StateNotifierProvider.autoDispose
    .family<CodepayQrTimerNotifier, CodepayQrTimerState, CodepayQrTimerArgs>((
      ref,
      args,
    ) {
      return CodepayQrTimerNotifier(args.remainingTime);
    });
