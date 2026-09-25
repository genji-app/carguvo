import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/crypto_deposit_option.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/payment_util.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/widgets/withdraw_crypto.dart';
import 'package:sun_sports/features/profile/withdraw/domain/models/withdraw_crypto_option.dart';
import 'package:sun_sports/shared/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class WithdrawCryptoContainer extends ConsumerStatefulWidget {
  const WithdrawCryptoContainer({super.key});

  @override
  ConsumerState<WithdrawCryptoContainer> createState() =>
      _WithdrawCryptoContainerState();
}

class _WithdrawCryptoContainerState
    extends ConsumerState<WithdrawCryptoContainer> {
  String? _selectedCryptoId;

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
    return formatted;
  }

  List<WithdrawCryptoOption> _convertCryptoOptions(
    List<CryptoDepositOption> cryptoOptions,
  ) {
    final List<WithdrawCryptoOption> result = [];

    for (final CryptoDepositOption crypto in cryptoOptions) {
      final networks = crypto.depositNetworks.isNotEmpty
          ? crypto.depositNetworks
          : [crypto.network];

      for (final String network in networks) {
        if (network.isEmpty) {
          continue;
        }

        final fullName = '${crypto.currencyName} - $network';

        final id =
            '${crypto.currencyName.toLowerCase()}_${network.toLowerCase()}';

        final price = _formatPrice(crypto.exchangeRate);

        result.add(
          WithdrawCryptoOption(
            id: id,
            name: crypto.currencyName,
            network: network,
            fullName: fullName,
            price: price,
          ),
        );
      }
    }

    return result;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final depositConfigAsync = ref.watch(configDepositProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                depositConfigAsync.when(
                  data: (depositData) {
                    final cryptoOptions = _convertCryptoOptions(
                      depositData.crypto,
                    );
                    return _buildCryptoSelectionForm(cryptoOptions);
                  },
                  loading: () => _buildCryptoSelectionForm([]),
                  error: (_, __) => _buildCryptoSelectionForm([]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCryptoSelectionForm(List<WithdrawCryptoOption> cryptoOptions) {
    if (_selectedCryptoId == null && cryptoOptions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCryptoId = cryptoOptions.first.id;
          });
        }
      });
    }

    if (cryptoOptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Không có loại tiền nào',
            style: AppTextStyles.labelMedium(color: AppColors.gray300),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại tiền',
          style: AppTextStyles.labelSmall(color: AppColors.gray25),
        ),
        const SizedBox(height: 6),
        Column(
          children: [
            for (int i = 0; i < cryptoOptions.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _buildCryptoItem(cryptoOptions[i], i < cryptoOptions.length - 1),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCryptoItem(WithdrawCryptoOption crypto, bool showDivider) {
    return _HoverableWithdrawCryptoItem(
      crypto: crypto,
      iconPath: PaymentUtil.getCryptoIconPath(crypto.name),
      showDivider: showDivider,
      onTap: () => _openWithdrawCryptoDialog(crypto),
    );
  }

  void _openWithdrawCryptoDialog(WithdrawCryptoOption crypto) {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final deviceType = ResponsiveBuilder.getDeviceType(rootContext);

    if (deviceType == DeviceType.mobile) {
      AppBottomSheet.show(
        rootContext,
        builder: (ctx) {
          final statusBarHeight = MediaQuery.of(ctx).padding.top;
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            alignment: Alignment.bottomCenter,
            insetPadding: EdgeInsets.only(top: statusBarHeight),
            child: WithdrawCrypto(selectedCrypto: crypto),
          );
        },
      );
    } else {
      showGeneralDialog(
        context: rootContext,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(
          rootContext,
        ).modalBarrierDismissLabel,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            child: WithdrawCrypto(selectedCrypto: crypto),
          );
        },
      );
    }
  }

}

class _HoverableWithdrawCryptoItem extends StatefulWidget {
  const _HoverableWithdrawCryptoItem({
    required this.crypto,
    required this.iconPath,
    required this.showDivider,
    required this.onTap,
  });

  final WithdrawCryptoOption crypto;
  final String iconPath;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  State<_HoverableWithdrawCryptoItem> createState() =>
      _HoverableWithdrawCryptoItemState();
}

class _HoverableWithdrawCryptoItemState
    extends State<_HoverableWithdrawCryptoItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = GestureDetector(
      onTap: SoundTap.wrap(widget.onTap),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            color: kIsWeb && _isHovered ? Colors.grey.shade800 : null,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ImageHelper.load(
                      path: widget.iconPath,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 4),
                      Text(
                        widget.crypto.fullName,
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
          if (widget.showDivider)
            Container(
              height: 1,
              margin: const EdgeInsets.only(left: 64),
              color: AppColors.gray700,
            ),
        ],
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
