import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/shared/domain/enums/navigation_enums.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class SportDesktopSidebar extends StatefulWidget {
  const SportDesktopSidebar({super.key});

  @override
  State<SportDesktopSidebar> createState() => _SportDesktopSidebarState();
}

class _SportDesktopSidebarState extends State<SportDesktopSidebar> {
  bool _isCasino = true;
  MenuItemType? _selectedItem = MenuItemType.allSports;

  String? _getIconPath(MenuItemType type, bool isSelected) {
    switch (type) {
      case MenuItemType.allSports:
        return isSelected ? AppIcons.iconHomeSelected : AppIcons.iconHome;
      case MenuItemType.live:
        return AppIcons.liveDot;
      case MenuItemType.upcoming:
        return isSelected ? AppIcons.iconTimerSelected : AppIcons.iconComming;
      case MenuItemType.myBets:
        return isSelected ? AppIcons.iconBet1Selected : AppIcons.iconMyOrder;
      case MenuItemType.topTournaments:
        return isSelected ? AppIcons.iconTrophySelected : AppIcons.iconTrophy;
      case MenuItemType.events:
        return isSelected ? AppIcons.iconEventSelected : AppIcons.iconEvent;
      case MenuItemType.volta:
      case MenuItemType.soccer:
        return isSelected ? AppIcons.iconSoccerSelected : AppIcons.iconSoccer;
      case MenuItemType.badminton:
        return isSelected
            ? AppIcons.iconBadmintonSelected
            : AppIcons.iconBadminton;
      case MenuItemType.tennis:
        return isSelected ? AppIcons.iconTennisSelected : AppIcons.iconTennis;
      case MenuItemType.basketball:
        return isSelected
            ? AppIcons.iconBasketballSelected
            : AppIcons.iconBasketball;
      case MenuItemType.tableTennis:
        return isSelected
            ? AppIcons.iconTableTennisSelected
            : AppIcons.iconTableTennis;
      case MenuItemType.volleyball:
        return isSelected
            ? AppIcons.iconVolleyballSelected
            : AppIcons.iconVolleyball;
      case MenuItemType.liveChat:
        return isSelected ? AppIcons.iconChatSelected : AppIcons.iconLivechat;
      case MenuItemType.depositWithdraw:
        return isSelected
            ? AppIcons.iconTransferSelected
            : AppIcons.arrowsOppositeDirection;
      case MenuItemType.trollSport:
        return isSelected
            ? AppIcons.iconEmojiSelected
            : AppIcons.iconTrollSport;
      case MenuItemType.analysis:
        return isSelected ? AppIcons.iconNewsSelected : AppIcons.iconRemark;
      case MenuItemType.support:
        return isSelected ? AppIcons.iconSupportSelected : AppIcons.iconSupport;
      case MenuItemType.settings:
        return isSelected ? AppIcons.iconSettingSelected : AppIcons.iconSetting;
      case MenuItemType.downloadApp:
        return isSelected ? AppIcons.iconDownloadApp : AppIcons.iconDownloadApp;
    }
  }

  void _onMenuItemTap(MenuItemType type) {
    setState(() {
      _selectedItem = type;
    });
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    child: Container(
      alignment: Alignment.topCenter,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: 'Thể thao',
                        icon: AppImages.backgroundTabMenu,
                        iconSelected: AppImages.backgroundTabMenuSelected,
                        isActive: _isCasino,
                        onTap: () {
                          setState(() {
                            _isCasino = true;
                          });
                        },
                      ),
                    ),
                    const Gap(AppSpacingStyles.space200),
                    Expanded(
                      child: _TabButton(
                        label: 'Casino',
                         icon: AppImages.backgroundTabMenu,
                        iconSelected: AppImages.backgroundTabMenuSelected,
                        isActive: !_isCasino,
                        onTap: () {
                          setState(() {
                            _isCasino = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacingStyles.space400),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.allSports,
                  _selectedItem == MenuItemType.allSports,
                ),
                label: 'Tất cả thể thao',
                isSelected: _selectedItem == MenuItemType.allSports,
                onTap: () => _onMenuItemTap(MenuItemType.allSports),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.live,
                  _selectedItem == MenuItemType.live,
                ),
                label: 'Đang diễn ra',
                badge: '78',
                txtColorDefault: const Color(0xFF989582),
                isSelected: _selectedItem == MenuItemType.live,
                onTap: () => _onMenuItemTap(MenuItemType.live),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.upcoming,
                  _selectedItem == MenuItemType.upcoming,
                ),
                label: 'Sắp diễn ra',
                isSelected: _selectedItem == MenuItemType.upcoming,
                onTap: () => _onMenuItemTap(MenuItemType.upcoming),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.myBets,
                  _selectedItem == MenuItemType.myBets,
                ),
                label: 'Cược của tôi',
                isSelected: _selectedItem == MenuItemType.myBets,
                onTap: () => _onMenuItemTap(MenuItemType.myBets),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.topTournaments,
                  _selectedItem == MenuItemType.topTournaments,
                ),
                label: 'Top giải đấu',
                isSelected: _selectedItem == MenuItemType.topTournaments,
                onTap: () => _onMenuItemTap(MenuItemType.topTournaments),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.volta,
                  _selectedItem == MenuItemType.volta,
                ),
                label: 'Volta',
                isSelected: _selectedItem == MenuItemType.volta,
                onTap: () => _onMenuItemTap(MenuItemType.volta),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.events,
                  _selectedItem == MenuItemType.events,
                ),
                label: 'Sự kiện',
                isSelected: _selectedItem == MenuItemType.events,
                onTap: () => _onMenuItemTap(MenuItemType.events),
              ),
              _buildDivider(),
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 14,
                ),
                child: Text(
                  'Môn thể thao',
                  style: AppTextStyles.textStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFAAA49B),
                  ),
                ),
              ),
              const Gap(2),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.soccer,
                  _selectedItem == MenuItemType.soccer,
                ),
                label: 'Bóng đá',
                isSelected: _selectedItem == MenuItemType.soccer,
                onTap: () => _onMenuItemTap(MenuItemType.soccer),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.tennis,
                  _selectedItem == MenuItemType.tennis,
                ),
                label: 'Quần vợt',
                isSelected: _selectedItem == MenuItemType.tennis,
                onTap: () => _onMenuItemTap(MenuItemType.tennis),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.basketball,
                  _selectedItem == MenuItemType.basketball,
                ),
                label: 'Bóng rổ',
                isSelected: _selectedItem == MenuItemType.basketball,
                onTap: () => _onMenuItemTap(MenuItemType.basketball),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.tableTennis,
                  _selectedItem == MenuItemType.tableTennis,
                ),
                label: 'Bóng bàn',
                isSelected: _selectedItem == MenuItemType.tableTennis,
                onTap: () => _onMenuItemTap(MenuItemType.tableTennis),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.volleyball,
                  _selectedItem == MenuItemType.volleyball,
                ),
                label: 'Bóng chuyền',
                isSelected: _selectedItem == MenuItemType.volleyball,
                onTap: () => _onMenuItemTap(MenuItemType.volleyball),
              ),
              _buildDivider(),
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Row(
                  children: [
                    RepaintBoundary(
                      child: ImageHelper.load(
                        path: AppIcons.iconDownloadApp,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tải app\ncho IOS & Android',
                        style: AppTextStyles.textStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFAAA49B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildDivider(),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.liveChat,
                  _selectedItem == MenuItemType.liveChat,
                ),
                label: 'Live chat',
                isSelected: _selectedItem == MenuItemType.liveChat,
                onTap: () => _onMenuItemTap(MenuItemType.liveChat),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.depositWithdraw,
                  _selectedItem == MenuItemType.depositWithdraw,
                ),
                label: 'Hướng dẫn nạp rút',
                isSelected: _selectedItem == MenuItemType.depositWithdraw,
                onTap: () => _onMenuItemTap(MenuItemType.depositWithdraw),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.trollSport,
                  _selectedItem == MenuItemType.trollSport,
                ),
                label: 'Troll thể thao',
                isSelected: _selectedItem == MenuItemType.trollSport,
                onTap: () => _onMenuItemTap(MenuItemType.trollSport),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.analysis,
                  _selectedItem == MenuItemType.analysis,
                ),
                label: 'Nhận định',
                isSelected: _selectedItem == MenuItemType.analysis,
                onTap: () => _onMenuItemTap(MenuItemType.analysis),
              ),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.support,
                  _selectedItem == MenuItemType.support,
                ),
                label: 'Hỗ trợ',
                isSelected: _selectedItem == MenuItemType.support,
                onTap: () => _onMenuItemTap(MenuItemType.support),
              ),
              const SizedBox(height: 16),
              _MenuItem(
                icon: _getIconPath(
                  MenuItemType.settings,
                  _selectedItem == MenuItemType.settings,
                ),
                label: 'Cài đặt',
                isSelected: _selectedItem == MenuItemType.settings,
                onTap: () => _onMenuItemTap(MenuItemType.settings),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildDivider() => RepaintBoundary(
    child: Padding(
      padding: const EdgeInsets.only(left: 8, right: 0, bottom: 8, top: 10),
      child: ImageHelper.load(
        path: AppIcons.hr,
        width: double.infinity,
        height: 2,
        fit: BoxFit.fill,
      ),
    ),
  );
}

class _TabButton extends StatelessWidget {
  final String label;
  final String icon;
  final String iconSelected;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.iconSelected,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InnerShadowCard(
    color: Colors.white.withValues(alpha: 0.02),
    child: GestureDetector(
      onTap: SoundTap.wrap(onTap),
      child: Container(
        width: double.infinity,
        height: 69,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: 69,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RepaintBoundary(
                  child: ImageHelper.load(
                    path: isActive ? iconSelected : icon,
                    width: 116,
                    height: 69,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final String? icon;
  final String label;
  final bool isSelected;
  final String? badge;
  final Color? txtColorDefault;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.label,
    this.icon,
    this.isSelected = false,
    this.badge,
    this.txtColorDefault,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    child: Row(
      children: [
        if (isSelected)
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                top: -30,
                child: RepaintBoundary(
                  child: ImageHelper.load(
                    path: AppIcons.menuSelectedShadow,
                    width: 30,
                    height: 97,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              RepaintBoundary(
                child: ImageHelper.load(
                  path: AppIcons.menuSelected,
                  width: 1,
                  height: 36,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        Expanded(
          child: InkWell(
            onTap: SoundTap.wrap(onTap),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 36,
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0x14FFD791),
                          Color(0x00FFD791),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    RepaintBoundary(
                      child: ImageHelper.load(
                        path: icon!,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Gap(8),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.textStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFFFFD691)
                            : txtColorDefault ?? const Color(0xFFAAA49B),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3B768),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        badge!,
                        style: AppTextStyles.textStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF27231C),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
