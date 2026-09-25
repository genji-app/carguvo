import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shimmer_animation/shimmer_animation.dart' as shimmer;
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/shared/layouts/shell_mobile_header.dart';
import 'package:sun_sports/shared/widgets/inset_shadow/inset_shadow.dart'
    as inset;
import 'package:sun_sports/shared/widgets/scoin_icon.dart';

class ShellScrollHeaderBar extends StatelessWidget {
  const ShellScrollHeaderBar({
    required this.progress,
    this.showFade = true,
    super.key,
  });

  final bool showFade;

  final ValueListenable<double> progress;

  static const double barHeight = 37;
  static const double fadeHeight = 20;

  static const double overlayHeight = barHeight + fadeHeight;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<double>(
        valueListenable: progress,
        child: RepaintBoundary(child: _BarContent(showFade: showFade)),
        builder: (context, value, child) =>
            Opacity(opacity: value.clamp(0.0, 1.0), child: child),
      ),
    );
  }
}

class _BarContent extends ConsumerWidget {
  const _BarContent({required this.showFade});

  final bool showFade;

  static const double _logoWidth = 71.4;
  static const double _logoHeight = 17.5;

  static const double _pillMaxWidth = 217;
  static const double _pillHeight = 22;
  static const double _nameSlotWidth = 101;

  static const double _gutter = 12;

  static const BorderRadius _nameSlotRadius = BorderRadius.only(
    topRight: Radius.circular(_pillHeight / 2),
    bottomRight: Radius.circular(_pillHeight / 2),
    bottomLeft: Radius.circular(_pillHeight),
  );

  static const inset.BoxDecoration _pillInsetShadows = inset.BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(_pillHeight / 2)),
    boxShadow: [
      inset.BoxShadow(
        color: Color(0x80000000),
        offset: Offset(0, 2),
        blurRadius: 4,
        inset: true,
      ),
      inset.BoxShadow(
        color: Color(0x1FFFE6AB),
        offset: Offset(0, -2),
        blurRadius: 4,
        inset: true,
      ),
    ],
  );

  static double _balanceFontSize(int amount) {
    if (MoneyFormatter.formatWithCommas(amount).length >= 15) return 9;
    if (amount > 100000000) return 10;
    return 11;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final username = ref.watch(userDisplayNameProvider);
    final balance = ref.watch(balanceInVNDProvider);
    final isLoading = ref.watch(profilePendingProvider);

    return Column(
      children: [
        Container(
          height: ShellScrollHeaderBar.barHeight,
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF000000),
                Color(0xFF000000),
                ShellMobileHeader.bottomColor,
              ],
              stops: [0, 0.5061, 1],
            ),
          ),
          child: Row(
            children: [
              ImageHelper.load(
                path: AppImages.logoSun88Scroll,
                width: _logoWidth,
                height: _logoHeight,
                fit: BoxFit.contain,
              ),
              const Gap(_gutter),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _pillMaxWidth),
                    child: SizedBox(
                      height: _pillHeight,
                      child: isAuthenticated
                          ? _pill(username, balance, isLoading)
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showFade)
          const SizedBox(
            width: double.infinity,
            height: ShellScrollHeaderBar.fadeHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ShellMobileHeader.bottomColor, Color(0x00111010)],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _pill(String username, double balance, bool isLoading) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_pillHeight / 2),
      child: ColoredBox(
        color: AppColorStyles.backgroundTertiary,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      children: [
                        if (isLoading)
                          shimmer.Shimmer(
                            duration: const Duration(milliseconds: 1500),
                            color: Colors.white,
                            colorOpacity: 0.3,
                            child: Container(
                              width: 40,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          )
                        else
                          Flexible(
                            child: Text(
                              MoneyFormatter.formatWithCommas(balance.toInt()),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.textStyle(
                                color: AppColorStyles.contentPrimary,
                                fontSize: _balanceFontSize(balance.toInt()),
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ),
                        const Gap(4),
                        const SCoinIcon(size: 13),
                      ],
                    ),
                  ),
                ),
                if (username.isNotEmpty)
                  Container(
                    width: _nameSlotWidth,
                    padding: const EdgeInsets.only(left: 8, right: 7),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF585858).withValues(alpha: 0.12),
                      borderRadius: _nameSlotRadius,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.textStyle(
                        color: AppColors.gray200.withValues(alpha: 0.6),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        height: 16 / 9,
                      ),
                    ),
                  ),
              ],
            ),
            const IgnorePointer(
              child: DecoratedBox(decoration: _pillInsetShadows),
            ),
          ],
        ),
      ),
    );
  }
}
