import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/router/auth_navigation.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/services/storage/search_onboarding_storage.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/features/onboarding/onboarding.dart';
import 'package:sun_sports/features/search/presentation/mobile/search_mobile_screen.dart';
import 'package:sun_sports/shared/layouts/shell_header_widgets.dart';
import 'package:sun_sports/shared/layouts/shell_top_block.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/user_balance_container.dart';

class ShellMobileHeader extends ConsumerWidget implements PreferredSizeWidget {
  const ShellMobileHeader({super.key});

  static const Color bottomColor = Color(0xFF111010);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final balanceVND = ref.watch(balanceInVNDProvider);
    final profilePending = ref.watch(profilePendingProvider);
    return Container(
      color: bottomColor,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF000000),
                    Color(0x00000000),
                  ],
                  stops: [
                    0.0,
                    1.0,
                  ],
                ),
                border: ref.watch(shellHasChatProvider)
                    ? null
                    : const Border(
                        bottom: BorderSide(
                          color: AppColorStyles.borderSecondary,
                          width: 1,
                        ),
                      ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const ShellHeaderMenuButton(),
                if (isAuthenticated) ...[
                  const Gap(4),
                  SpotlightAnchor(
                    id: SpotlightTargetId.searchButton,
                    child: GestureDetector(
                      onTap: SoundTap.wrap(() {
                        if (SearchOnboardingStorage.instance.isPending) {
                          SearchOnboardingStorage.instance.setPending(false);
                          ref
                              .read(spotlightControllerProvider.notifier)
                              .start(searchQuickGuideTour);
                          return;
                        }
                        SearchMobileScreen.showAsBottomSheet(context);
                      }),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColorStyles.backgroundQuaternary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: ImageHelper.load(
                            path: AppIcons.icSearch,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(4),
                  const ShellHeaderLogoButton(),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SpotlightAnchor(
                        id: SpotlightTargetId.balanceDeposit,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: UserBalanceContainer(
                            balance: balanceVND,
                            isLoading: profilePending,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (!isAuthenticated) const Spacer(),
                if (!isAuthenticated)
                  Row(
                    children: [
                      ShineButton(
                        text: I18n.txtLogin,
                        size: ShineButtonSize.large,
                        height: 36,
                        style: ShineButtonStyle.primaryGray,
                        onPressed: () {
                          openAuth(context, showLogin: true);
                        },
                      ),
                      const SizedBox(width: 12),
                      ShineButton(
                        text: I18n.txtRegister,
                        size: ShineButtonSize.large,
                        height: 36,
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
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(68);
}
