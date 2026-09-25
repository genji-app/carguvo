import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer_animation/shimmer_animation.dart' as shimmer;
import 'package:sun_sports/core/utils/extensions/currency_helper.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/presentation/show_deposit_flow.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';

class BalanceContainer extends StatelessWidget {
  final double balance;
  final double? width;
  final EdgeInsets? padding;
  final bool showRefillButton;

  final bool isLoading;

  const BalanceContainer({
    required this.balance,
    super.key,
    this.width,
    this.padding,
    this.showRefillButton = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 219,
      padding:
          padding ??
          const EdgeInsets.only(top: 4, left: 8, right: 4, bottom: 4),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x1EFFE5C0)),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: _BalanceText(
        balance: balance,
        showRefillButton: showRefillButton,
        isLoading: isLoading,
      ),
    );
  }
}

class _BalanceText extends ConsumerWidget {
  final double balance;
  final bool showRefillButton;
  final bool isLoading;

  const _BalanceText({
    required this.balance,
    this.showRefillButton = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const SCoinIcon(),
      Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isLoading) {
              return Center(
                child: shimmer.Shimmer(
                  duration: const Duration(milliseconds: 1500),
                  color: Colors.white,
                  colorOpacity: 0.3,
                  child: Container(
                    width: 48,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }
            final balanceVnd = balance.toInt();
            final balanceText = ResponsiveBuilder.isDesktop(context)
                ? MoneyFormatter.formatWithCommas(balanceVnd)
                : MoneyFormatter.formatCompact(balanceVnd);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  balanceText,
                  style: AppTextStyles.textStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      ),
      if (showRefillButton)
        GestureDetector(
          onTap: SoundTap.wrap(() => showDepositFlow(context, ref)),
          child: ImageHelper.load(
            path: AppIcons.btnRefill,
            width: 56,
            height: 36,
            fit: BoxFit.contain,
          ),
        ),
    ],
  );
}
