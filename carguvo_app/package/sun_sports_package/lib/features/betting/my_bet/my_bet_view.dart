import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/onboarding/onboarding.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/screens/parlay_view.dart';
import 'package:sun_sports/shared/widgets/flying_bet_animation.dart';
import 'package:sun_sports/shared/widgets/tabs/glow_filter_tabbar.dart';

class MyBetView extends StatelessWidget {
  const MyBetView({
    required this.selectedMenu,
    required this.onMenuChanged,
    required this.onClosePressed,
    super.key,
    this.decoration,
  });

  final MyBetMenu selectedMenu;

  final ValueChanged<MyBetMenu> onMenuChanged;

  final VoidCallback onClosePressed;

  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    return SpotlightAnchor(
      id: SpotlightTargetId.betSlipPanelTabs,
      child: Container(
        decoration: decoration,
        child: Column(
          children: [
            Consumer(
              builder: (context, ref, _) {
                final betSlipCount = ref.watch(
                  myBetNotifierProvider.select((state) => state.betSlipCount),
                );
                final myBetsCount = ref.watch(
                  myBetNotifierProvider.select((state) => state.myBetsCount),
                );
                return SpotlightAnchor(
                  id: SpotlightTargetId.myBetsTab,
                  child: _MyBetHeader(
                    bettingSlipCount: betSlipCount,
                    myBetCount: myBetsCount,
                    selectedMenu: selectedMenu,
                    onMenuChanged: onMenuChanged,
                    onClosePressed: onClosePressed,
                  ),
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: switch (selectedMenu) {
                  MyBetMenu.bettingSlip => const ParlayView(),
                  MyBetMenu.myBets => const BettingHistoryView(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyBetHeader extends StatelessWidget implements PreferredSizeWidget {
  const _MyBetHeader({
    required this.selectedMenu,
    required this.onClosePressed,
    this.onMenuChanged,
    this.myBetCount = 0,
    this.bettingSlipCount = 0,
  });

  final ValueChanged<MyBetMenu>? onMenuChanged;
  final MyBetMenu selectedMenu;
  final int myBetCount;
  final int bettingSlipCount;
  final VoidCallback onClosePressed;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsetsDirectional.only(start: 8, end: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColorStyles.borderSecondary, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GlowFilterTabbar<MyBetMenu>(
              tabs: MyBetMenu.values,
              selectedTab: selectedMenu,
              labelGetter: (menu) => menu.label,
              decoration: const BoxDecoration(),
              itemKeyGetter: (menu) => menu == MyBetMenu.bettingSlip
                  ? FlyingBetController.instance.bettingSlipTabKey
                  : null,
              itemWrapper: (menu, child) => SpotlightAnchor(
                id: menu == MyBetMenu.bettingSlip
                    ? SpotlightTargetId.betSlipTab
                    : SpotlightTargetId.myBetsTabItem,
                child: child,
              ),
              iconBuilder: (menu, isSelected) {
                final count = menu == MyBetMenu.bettingSlip
                    ? bettingSlipCount
                    : myBetCount;
                final icon = switch (menu) {
                  MyBetMenu.bettingSlip =>
                    isSelected
                        ? AppIcons.sportTicketSelected
                        : AppIcons.sportTicketNormal,
                  MyBetMenu.myBets =>
                    isSelected
                        ? AppIcons.sportMyBetSelected
                        : AppIcons.iconMyOrder,
                };
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ImageHelper.load(path: icon, width: 20, height: 20),
                    Positioned(
                      top: -12,
                      right: -14,
                      child: _Badge(count: count, isSelected: isSelected),
                    ),
                  ],
                );
              },
              onTabChanged: (newTab, currentTab) {
                onMenuChanged?.call(newTab);
              },
            ),
          ),
          const Gap(8),
          CloseButton(
            onPressed: () {
              SoundEffects.instance.playTap();
              onClosePressed();
            },
            color: AppColorStyles.contentSecondary,
          ),
          const Gap(8),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.isSelected});

  final int count;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.green300 : AppColors.gray300,
        borderRadius: BorderRadius.circular(1000),
        border: Border.all(color: AppColorStyles.backgroundSecondary, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      child: Center(
        widthFactor: 1.0,
        heightFactor: 1.0,
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: AppTextStyles.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.gray950,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
