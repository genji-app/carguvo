import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/presentation/show_deposit_flow.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/shared/widgets/avatar/avatar.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class SportDesktopHeader extends ConsumerWidget implements PreferredSizeWidget {
  const SportDesktopHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -20,
          child: ImageHelper.load(
            path: AppImages.headerShadow,
            fit: BoxFit.fill,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Row(
                children: [
                  const SizedBox(width: 24),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: SoundTap.wrap(() {}),
                      borderRadius: BorderRadius.circular(100),
                      child: Center(
                        child: ImageHelper.load(
                          path: AppIcons.btnSearch,
                          width: 44,
                          height: 44,
                          color: const Color(0xB3FFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 219,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 44,
                      child: ImageHelper.load(
                        path: AppImages.backgroundBalance,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 24.0),
                              child: ImageHelper.load(
                                path: AppIcons.moneyTxt,
                                width: 119,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: SoundTap.wrap(
                              () => showDepositFlow(context, ref),
                            ),
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
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    height: 44,
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 12,
                      top: 10,
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0x0FFFFCDB,
                      ),
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD791),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '4',
                              style: AppTextStyles.textStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF27231C),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Phiếu cược',
                          style: AppTextStyles.textStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xB3FFFCDB),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0x1A000000),
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      onTap: SoundTap.wrap(() {}),
                      borderRadius: BorderRadius.circular(100),
                      child: Center(
                        child: ImageHelper.load(
                          path: AppIcons.iconNotification,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ProfileAvatar.user(
                    size: const Size.square(44),
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    onPressed: () {
                      ProfileHub.maybeOf(context)?.close();
                    },
                  ),
                ],
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
