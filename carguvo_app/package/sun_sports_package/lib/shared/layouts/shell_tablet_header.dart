import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/providers/slider_drawer_provider.dart';
import 'package:sun_sports/router/auth_navigation.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/my_bet_hub/my_bet_hub.dart';
import 'package:sun_sports/features/notification/presentation/notification_panel.dart';
import 'package:sun_sports/features/preferences/preferences.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_dialog.dart';
import 'package:sun_sports/shared/widgets/avatar/avatar.dart';
import 'package:sun_sports/shared/widgets/balance_container.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/flying_bet_animation.dart';

class ShellTabletHeader extends ConsumerWidget implements PreferredSizeWidget {
  const ShellTabletHeader({
    super.key,
    this.onBackPressed,
    this.showOddsStyle = true,
  });

  final bool showOddsStyle;

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final balanceVND = ref.watch(balanceInVNDProvider);

    return Container(
      color: const Color(0xFF111010),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 50,
            right: 50,
            bottom: 20,
            child: ImageHelper.load(
              path: AppImages.headerShadow,
              fit: BoxFit.fill,
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (onBackPressed != null) ...<Widget>[
                      GestureDetector(
                        onTap: SoundTap.wrap(onBackPressed!),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColorStyles.backgroundQuaternary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ImageHelper.load(
                            path: AppIcons.icBack,
                            width: 24,
                            height: 24,
                            color: const Color(0xFFFFFCDB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else ...<Widget>[
                      _menuButton(ref),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: showOddsStyle
                          ? Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 240,
                                ),
                                child: _buildOddStyleButton(context),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (isAuthenticated) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: BalanceContainer(
                            balance: balanceVND,
                            width: 236,
                          ),
                        ),
                      ),
                    ],
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: isAuthenticated
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MyBetHubToggleButton(
                                  key: onBackPressed == null
                                      ? FlyingBetController
                                            .instance
                                            .desktopBettingBadgeKey
                                      : null,
                                  onTap: () {
                                    ref
                                        .read(myBetHubControllerProvider)
                                        .open(
                                          initialMenu:
                                              MyBetMenu.bettingSlip,
                                        );
                                  },
                                ),
                                const SizedBox(width: 12),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: SoundTap.wrap(
                                      () => SearchDialog.show(context),
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                    child: ImageHelper.load(
                                      path: AppIcons.btnSearch,
                                      width: 44,
                                      height: 44,
                                      color: const Color(0xB3FFFFFF),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: AppColorStyles.backgroundTertiary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    onTap: SoundTap.wrap(
                                      isAuthenticated
                                          ? () =>
                                                NotificationPanel.show(context)
                                          : null,
                                    ),
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
                                const SizedBox(width: 12),
                                ProfileAvatar.user(
                                  size: const Size.square(44),
                                  onPressed: () {
                                    ProfileHub.maybeOf(context)?.toggle();
                                  },
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShineButton(
                                  text: I18n.txtLogin,
                                  size: ShineButtonSize.large,
                                  height: 44,
                                  style: ShineButtonStyle.primaryGray,
                                  onPressed: () {
                                    openAuth(context, showLogin: true);
                                  },
                                ),
                                const SizedBox(width: 12),
                                ShineButton(
                                  text: I18n.txtRegister,
                                  size: ShineButtonSize.large,
                                  height: 44,
                                  style: ShineButtonStyle.primaryYellow,
                                  onPressed: () {
                                    openAuth(context, showLogin: false);
                                  },
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOddStyleButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: SoundTap.wrap(() {
        ProfileHub.maybeOf(
          context,
        )?.pushAndRemoveUntilRoot(ProfileHub.betPreferences);
      }),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x33FFFFFF)),
          borderRadius: BorderRadius.circular(1000),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(1000),
          child: Stack(
            children: [
              Positioned.fill(
                right: -1,
                child: ImageHelper.load(
                  path: AppImages.backgroundOddStyle,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Tỷ lệ cược:',
                        style: AppTextStyles.labelXSmall(
                          color: AppColorStyles.contentTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const Gap(8),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Consumer(
                              builder: (context, ref, _) {
                                final oddsStyle = ref.watch(
                                  betPreferencesProvider.select(
                                    (s) => s.oddsStyle,
                                  ),
                                );
                                return Text(
                                  oddsStyle.label,
                                  style: AppTextStyles.labelXSmall(
                                    color: AppColors.green300,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                );
                              },
                            ),
                          ),
                          const Gap(8),
                          ImageHelper.load(
                            path: AppIcons.iconSwitch,
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton(WidgetRef ref) {
    return Semantics(
      button: true,
      label: 'Menu',
      child: GestureDetector(
        onTap: SoundTap.wrap(
          () => ref.read(sliderDrawerKeyProvider).currentState?.toggle(),
        ),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: ImageHelper.load(
              path: AppIcons.icMenu,
              width: 24,
              height: 24,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(68);
}
