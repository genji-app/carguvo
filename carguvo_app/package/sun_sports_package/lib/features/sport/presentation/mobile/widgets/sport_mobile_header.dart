import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/currency_helper.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/presentation/show_deposit_flow.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/shared/widgets/avatar/avatar.dart';

class SportMobileHeader extends ConsumerWidget implements PreferredSizeWidget {
  const SportMobileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
          decoration: BoxDecoration(
          ),
          child: Row(
            children: [
              SizedBox(
                child: ImageHelper.load(
                  path: AppIcons.sun88,
                  width: 77,
                  height: 12,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              Container(
                width: 219,
                padding: const EdgeInsets.only(
                  top: 4,
                  left: 16,
                  right: 4,
                  bottom: 4,
                ),
                decoration: ShapeDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: const Color(0x1EFFE5C0)),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFE5B8), Color(0xFFFFB732)],
                      ).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        '\$',
                        style: AppTextStyles.labelMedium().copyWith(
                          height: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (Rect bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFE5B8), Color(0xFFFFB732)],
                      ).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        CurrencyHelper.formatCurrencyNoUnit(2000000),
                        style: AppTextStyles.labelMedium().copyWith(
                          height: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => showDepositFlow(context, ref),
                      child: ImageHelper.load(
                        path: AppIcons.btnRefill,
                        width: 56,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ProfileAvatar.user(
                size: const Size.square(44),
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                onPressed: () => context.openProfile(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(68);
}
