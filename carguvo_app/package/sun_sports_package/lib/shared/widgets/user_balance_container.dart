import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shimmer_animation/shimmer_animation.dart' as shimmer;
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/onboarding/onboarding.dart';
import 'package:sun_sports/features/profile/deposit/presentation/show_deposit_flow.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/shared/widgets/avatar/avatar.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/inset_shadow/inset_shadow.dart'
    as inset;
import 'package:sun_sports/shared/widgets/scoin_icon.dart';

class UserBalanceContainer extends ConsumerWidget {
  final double balance;

  final bool isLoading;

  const UserBalanceContainer({
    required this.balance,
    super.key,
    this.isLoading = false,
  });

  static const double _width = 191;
  static const double _height = 44;
  static const Color _body = Color(0xFF1B1A19);
  static const BorderRadius _radius = BorderRadius.all(
    Radius.circular(_height / 2),
  );

  static const inset.BoxDecoration _insetShadows = inset.BoxDecoration(
    borderRadius: _radius,
    boxShadow: [
      inset.BoxShadow(
        color: Color(0x1FFFE6AB),
        offset: Offset(0, -2),
        blurRadius: 4,
        inset: true,
      ),
      inset.BoxShadow(
        color: Color(0x1FFFFFFF),
        offset: Offset(0, 0.5),
        blurRadius: 0.5,
        inset: true,
      ),
    ],
  );

  static double _balanceFontSize(String formatted, double balance) {
    if (formatted.length >= 15) return 9;
    if (balance > 100000000) return 10;
    return 12;
  }

  static double _balanceLineHeight(double fontSize) => switch (fontSize) {
    9 => 14,
    10 => 16,
    _ => 18,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(userDisplayNameProvider);
    final formatted = MoneyFormatter.formatWithCommas(balance.toInt());
    final fontSize = _balanceFontSize(formatted, balance);
    return SizedBox(
      width: _width,
      height: _height,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: _radius,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: ColoredBox(color: _body),
                  ),
                  Positioned(
                    left: 8,
                    top: 0,
                    child: Container(
                      width: 138,
                      height: 13,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [_body, Color(0xFF303030), _body],
                          stops: [0, 0.6106, 1],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
              children: [
                GestureDetector(
                  onTap: SoundTap.wrap(() => showDepositFlow(context, ref)),
                  child: ImageHelper.load(
                    path: AppIcons.btnRefill,
                    width: 40,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 13,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 110),
                          padding: const EdgeInsets.only(left: 12, right: 4),
                          alignment: Alignment.centerRight,
                          child: Text(
                            username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.textStyle(
                              color: const Color(0xFFC3C2BC),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              height: 13 / 9,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 26,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isLoading)
                                shimmer.Shimmer(
                                  duration: const Duration(milliseconds: 1500),
                                  color: Colors.white,
                                  colorOpacity: 0.3,
                                  child: Container(
                                    width: 48,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                )
                              else
                                Flexible(
                                  child: Text(
                                    formatted,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.textStyle(
                                      color: AppColorStyles.contentPrimary,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w700,
                                      height:
                                          _balanceLineHeight(fontSize) /
                                          fontSize,
                                    ),
                                  ),
                                ),
                              const Gap(1),
                              const SCoinIcon(size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SpotlightAnchor(
                  id: SpotlightTargetId.avatarProfile,
                  child: ProfileAvatar.user(
                    size: const Size.square(38),
                    borderRadius: const BorderRadius.all(Radius.circular(19)),
                    onPressed: () => context.openProfile(),
                  ),
                ),
              ],
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(decoration: _insetShadows),
            ),
          ),
        ],
      ),
    );
  }
}
