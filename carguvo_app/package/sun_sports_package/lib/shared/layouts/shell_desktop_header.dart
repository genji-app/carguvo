import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/router/auth_navigation.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/services/storage/search_onboarding_storage.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/my_bet_hub/my_bet_hub.dart';
import 'package:sun_sports/features/onboarding/onboarding.dart';
import 'package:sun_sports/features/notification/presentation/notification_panel.dart';
import 'package:sun_sports/features/preferences/preferences.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_dialog.dart';
import 'package:sun_sports/shared/widgets/avatar/avatar.dart';
import 'package:sun_sports/shared/widgets/balance_container.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/flying_bet_animation.dart';

class ShellDesktopHeader extends ConsumerWidget implements PreferredSizeWidget {
  const ShellDesktopHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final balanceVND = ref.watch(balanceInVNDProvider);
    final profilePending = ref.watch(profilePendingProvider);

    return Stack(
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
        LayoutBuilder(
          builder: (context, constraints) {
            const sidebarWidth = 260.0;
            const gap = AppSpacingStyles.space300;
            const rightSidebarWidth = 402.0;
            const mainMaxWidth = 1140.0;
            final availableForContent =
                constraints.maxWidth -
                sidebarWidth -
                gap -
                gap -
                rightSidebarWidth;
            final contentWidth = availableForContent > mainMaxWidth
                ? mainMaxWidth
                : availableForContent;
            final mainContentLeft =
                sidebarWidth + gap + (availableForContent - contentWidth) / 2;

            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: SoundTap.wrap(() {
                                ref
                                    .read(mainContentProvider.notifier)
                                    .goToHome();
                              }),
                              child: SizedBox(
                                height: 44,
                                child: ImageHelper.load(
                                  path: AppImages.logoUrl,
                                  width: 60,
                                  height: 56,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 120),
                        ],
                      ),
                      const Spacer(),
                      if (isAuthenticated)
                        SpotlightAnchor(
                          id: SpotlightTargetId.balanceDeposit,
                          child: BalanceContainer(
                            balance: balanceVND,
                            width: 236,
                            isLoading: profilePending,
                          ),
                        ),
                      const Spacer(),
                      if (isAuthenticated)
                        Row(
                          children: [
                            SpotlightAnchor(
                              id: SpotlightTargetId.betSlipButton,
                              child: MyBetHubToggleButton(
                                key: FlyingBetController
                                    .instance
                                    .desktopBettingBadgeKey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SpotlightAnchor(
                              id: SpotlightTargetId.searchButton,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: SoundTap.wrap(() {
                                    if (SearchOnboardingStorage
                                        .instance
                                        .isPending) {
                                      SearchOnboardingStorage.instance
                                          .setPending(false);
                                      ref
                                          .read(
                                            spotlightControllerProvider
                                                .notifier,
                                          )
                                          .start(searchQuickGuideTour);
                                      return;
                                    }
                                    SearchDialog.show(context);
                                  }),
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
                            ),
                            const SizedBox(width: 12),
                            Builder(
                              builder: (anchorContext) {
                                return Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Color(0x1A000000),
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    onTap: SoundTap.wrap(
                                      () => NotificationPanel.show(
                                        context,
                                        anchorContext: anchorContext,
                                      ),
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
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            SpotlightAnchor(
                              id: SpotlightTargetId.avatarProfile,
                              child: ProfileAvatar.user(
                                size: const Size.square(44),
                                onPressed: () {
                                  ProfileHub.maybeOf(context)?.toggle();
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
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
                    ],
                  ),
                ),
                Positioned(
                  left: mainContentLeft,
                  child: const OddsStyleDropdown(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(68);
}
