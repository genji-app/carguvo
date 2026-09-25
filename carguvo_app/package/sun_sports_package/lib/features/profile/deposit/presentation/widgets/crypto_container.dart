import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_address_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_option.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_overlay_provider.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_form_providers.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/crypto/crypto_confirm_money_transfer_bottom_sheet.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/deposit_mobile_bottom_sheet.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/crypto_confirm_money_transfer_overlay.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/payment_util.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/features/profile/shared/money_flow_success.dart';

class CryptoContainer extends ConsumerStatefulWidget {
  const CryptoContainer({super.key});

  @override
  ConsumerState<CryptoContainer> createState() => _CryptoContainerState();
}

class _CryptoContainerState extends ConsumerState<CryptoContainer> {
  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(cryptoFormProvider);
    final cryptosAsync = ref.watch(cryptoListProvider);
    ref.listen<CryptoSubmitState>(cryptoSubmitNotifierProvider, (
      previous,
      next,
    ) {
      next.maybeWhen(
        success: () => _handleGetCryptoAddressSuccess(),
        error: (message) => _handleGetCryptoAddressError(message),
        orElse: () {},
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cryptosAsync.when(
                  data: (cryptos) =>
                      _buildCryptoSelectionForm(formState, cryptos),
                  loading: () => _buildCryptoSelectionForm(formState, []),
                  error: (_, __) => _buildCryptoSelectionForm(formState, []),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCryptoSelectionForm(
    CryptoFormState formState,
    List<CryptoOption> cryptos,
  ) {
    debugPrint('✅ cryptos: ${cryptos.length}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại tiền',
          style: AppTextStyles.labelSmall(
            color: AppColors.gray300,
          ),
        ),
        if (formState.cryptoError != null) ...[
          const SizedBox(height: 4),
          Text(
            formState.cryptoError!,
            style: AppTextStyles.labelSmall(color: Colors.red),
          ),
        ],
        const SizedBox(height: 8),
        cryptos.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Không có loại tiền nào',
                    style: AppTextStyles.labelMedium(color: AppColors.gray300),
                  ),
                ),
              )
            : Column(
                children: [
                  for (int index = 0; index < cryptos.length; index++)
                    _HoverableCryptoItem(
                      crypto: cryptos[index],
                      iconPath: PaymentUtil.getCryptoIconPath(
                        cryptos[index].name,
                      ),
                      isLast: index == cryptos.length - 1,
                      onTap: () => _handleCryptoItemTap(cryptos[index]),
                    ),
                ],
              ),
      ],
    );
  }

  Future<void> _handleCryptoItemTap(CryptoOption crypto) async {
    ref.read(cryptoFormProvider.notifier).updateCrypto(crypto.id);

    if (!ref.read(cryptoFormProvider.notifier).validate()) {
      return;
    }

    final request = CryptoAddressRequest(
      network: crypto.network,
      currencyName: crypto.name,
      fiatCurrency: 'VND',
    );

    await ref
        .read(cryptoSubmitNotifierProvider.notifier)
        .getCryptoAddress(request);
  }

  void _handleGetCryptoAddressSuccess() {
    final cryptoAddressResponse = ref
        .read(cryptoSubmitNotifierProvider.notifier)
        .cryptoAddressResponse;

    if (cryptoAddressResponse == null) {
      debugPrint('⚠️ Crypto address response is null');
      return;
    }

    notifyMoneyFlowSuccess(
      ref,
      source: TransactionSource.paymentSlip,
      refreshBalance: false,
      watchBalance: false,
    );

    final formState = ref.read(cryptoFormProvider);
    final cryptosAsync = ref.read(cryptoListProvider);

    cryptosAsync.whenData((cryptos) {
      final selectedCrypto = cryptos.firstWhere(
        (c) => c.id == formState.selectedCrypto,
        orElse: () => cryptos.first,
      );

      final rootContext = Navigator.of(context, rootNavigator: true).context;
      final navigator = DepositNavigator();

      navigator.push(
        context: rootContext,
        mobileShowMethod: (ctx) => CryptoConfirmMoneyTransferBottomSheet.show(
          ctx,
          cryptoAddressResponse: cryptoAddressResponse,
          cryptoOption: selectedCrypto,
          paymentMethod: PaymentMethod.crypto,
        ),
        webShowMethod: (ctx) => DepositNavigator.showWebDialog<void>(
          context: ctx,
          builder: (dialogContext, animation, secondaryAnimation) =>
              CryptoConfirmMoneyTransferOverlay(
                cryptoAddressResponse: cryptoAddressResponse,
                cryptoOption: selectedCrypto,
                paymentMethod: PaymentMethod.crypto,
              ),
        ),
        showPreviousDialog: (rootContext, deviceType) async {
          if (deviceType == DeviceType.mobile) {
            await DepositMobileBottomSheet.show(rootContext);
          } else {
            final container = ProviderScope.containerOf(
              rootContext,
              listen: false,
            );
            container.read(depositOverlayVisibleProvider.notifier).state = true;
            await Future<void>.delayed(const Duration(milliseconds: 50));
            if (rootContext.mounted) {
              container
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.crypto);
            }
          }
        },
      );
    });
  }

  void _handleGetCryptoAddressError(String message) {
    if (!mounted) return;
    AppToast.showError(
      context,
      message: localizedMoneyError('Lấy địa chỉ crypto', message),
    );
  }
}

class _HoverableCryptoItem extends StatefulWidget {
  const _HoverableCryptoItem({
    required this.crypto,
    required this.iconPath,
    required this.isLast,
    required this.onTap,
  });

  final CryptoOption crypto;
  final String iconPath;
  final bool isLast;
  final VoidCallback onTap;

  @override
  State<_HoverableCryptoItem> createState() => _HoverableCryptoItemState();
}

class _HoverableCryptoItemState extends State<_HoverableCryptoItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = InkWell(
      onTap: SoundTap.wrap(widget.onTap),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: kIsWeb && _isHovered
              ? Colors.grey.shade800
              : Colors.transparent,
          border: widget.isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.gray700, width: 0.75),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ImageHelper.load(
                  path: widget.iconPath,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.crypto.name,
                    style: AppTextStyles.paragraphMedium(
                      color: AppColors.gray25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.crypto.name} - ${widget.crypto.network}',
                    style: AppTextStyles.paragraphXSmall(
                      color: AppColors.gray300,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  widget.crypto.price,
                  style: AppTextStyles.paragraphMedium(
                    color: AppColors.yellow300,
                  ),
                ),
                const Row(children: [Gap(4), SCoinIcon()]),
              ],
            ),
          ],
        ),
      ),
    );

    if (!kIsWeb) return item;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: item,
    );
  }
}
