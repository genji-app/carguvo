import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/router/auth_navigation.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/features/search/presentation/mobile/search_mobile_screen.dart';
import 'package:sun_sports/shared/layouts/shell_header_widgets.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/user_balance_container.dart';

class SportDetailMobileHeader extends ConsumerWidget
    implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;

  const SportDetailMobileHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceVND = ref.watch(balanceInVNDProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final profilePending = ref.watch(profilePendingProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
      decoration: const BoxDecoration(
        color: AppColorStyles.backgroundPrimary,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: SoundTap.wrap(
              onBackPressed ?? () => Navigator.of(context).maybePop(),
            ),
            child: Container(
              width: 32,
              height: 33,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundQuaternary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ImageHelper.load(
                path: AppIcons.icBack,
                width: 20,
                height: 20,
                color: const Color(0xFFFFFCDB),
              ),
            ),
          ),
          const Gap(4),
          const ShellHeaderMenuButton(),
          if (isAuthenticated) ...[
            const Gap(4),
            GestureDetector(
              onTap: SoundTap.wrap(
                () => SearchMobileScreen.showAsBottomSheet(context),
              ),
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
            const Gap(4),
            const ShellHeaderLogoButton(),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: UserBalanceContainer(
                    balance: balanceVND,
                    isLoading: profilePending,
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
                  text: 'Đăng nhập',
                  size: ShineButtonSize.large,
                  height: 36,
                  style: ShineButtonStyle.primaryGray,
                  onPressed: () {
                    openAuth(context, showLogin: true);
                  },
                ),
                const SizedBox(width: 12),
                ShineButton(
                  text: 'Đăng ký',
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(68);
}
