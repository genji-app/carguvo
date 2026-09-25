import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/env/app_env.dart';
import 'package:sun_sports/features/game/lobby_game_extensions.dart';
import 'package:sun_sports/providers/casino_provider_menu_provider.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sport_events/sport_events.dart'
    show LeagueAliasStore, leagueChipLabels, normalizeLeagueName;
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_detail_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/top_league_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/download_app/download_app_action.dart';
import 'package:sun_sports/features/download_app/dialog_download_app.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/features/home/domain/ncc_sportbook.dart';
import 'package:sun_sports/features/home/presentation/ncc_launch_handler.dart';
import 'package:sun_sports/shared/domain/enums/navigation_enums.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/maintenance/sb_maintenance_view.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ShellDesktopSidebar extends ConsumerStatefulWidget {
  final VoidCallback? onItemTap;

  final VoidCallback? onTopTournamentsTapForMobile;

  final VoidCallback? onMyBetsTapForMobile;

  final bool isDesktop;

  const ShellDesktopSidebar({
    super.key,
    this.onItemTap,
    this.onTopTournamentsTapForMobile,
    this.onMyBetsTapForMobile,
    this.isDesktop = true,
  });

  @override
  ConsumerState<ShellDesktopSidebar> createState() =>
      _ShellDesktopSidebarState();
}

class _ShellDesktopSidebarState extends ConsumerState<ShellDesktopSidebar> {
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
        return isSelected
            ? AppImages.iconDownloadApp
            : AppImages.iconDownloadApp;
    }
  }

  MenuItemType _sportTypeToMenuItem(v2.SportType sport) {
    switch (sport) {
      case v2.SportType.soccer:
        return MenuItemType.soccer;
      case v2.SportType.badminton:
        return MenuItemType.badminton;
      case v2.SportType.tennis:
        return MenuItemType.tennis;
      case v2.SportType.basketball:
        return MenuItemType.basketball;
      case v2.SportType.tableTennis:
        return MenuItemType.tableTennis;
      case v2.SportType.volleyball:
        return MenuItemType.volleyball;
      default:
        return MenuItemType.allSports;
    }
  }

  void _onMenuItemTap(MenuItemType type) {
    setState(() {
      _selectedItem = type;
    });

    switch (type) {
      case MenuItemType.myBets:
        ref.read(myBetHubControllerProvider).changeMenu(MyBetMenu.myBets);
        if (widget.onMyBetsTapForMobile != null) {
          widget.onMyBetsTapForMobile!();
        } else {
          ref.read(myBetHubControllerProvider).open(
                initialMenu: MyBetMenu.myBets,
              );
        }
      case MenuItemType.allSports:
        ref.read(mainContentProvider.notifier).goToSport();
      case MenuItemType.live:
        ref.read(mainContentProvider.notifier).goToLive();
      case MenuItemType.topTournaments:
        if (widget.onTopTournamentsTapForMobile != null) {
          widget.onTopTournamentsTapForMobile!();
        } else {
          ref.read(mainContentProvider.notifier).goToTournaments();
        }
      case MenuItemType.upcoming:
        ref.read(mainContentProvider.notifier).goToUpcoming();
      case MenuItemType.events:
        _dontSupportSportDetailMenuItemTap();
      case MenuItemType.volta:
        _dontSupportSportDetailMenuItemTap();
      case MenuItemType.soccer:
        _onSportDetailMenuItemTap(SportType.soccer.id);
      case MenuItemType.badminton:
        _onSportDetailMenuItemTap(SportType.badminton.id);
      case MenuItemType.tennis:
        _onSportDetailMenuItemTap(SportType.tennis.id);
      case MenuItemType.basketball:
        _onSportDetailMenuItemTap(SportType.basketball.id);
      case MenuItemType.tableTennis:
        _onSportDetailMenuItemTap(SportType.tableTennis.id);
      case MenuItemType.volleyball:
        _onSportDetailMenuItemTap(SportType.volleyball.id);
      case MenuItemType.support:
        widget.onItemTap?.call();
        launchUrl(
          Uri.parse(SbConfig.livechatUrl),
          mode: LaunchMode.externalApplication,
        );
        return;
      case MenuItemType.downloadApp:
        launchUrl(
          Uri.parse(AppEnv.downloadAppUrl),
          mode: LaunchMode.externalApplication,
        );
        return;
      case MenuItemType.liveChat:
      case MenuItemType.depositWithdraw:
      case MenuItemType.trollSport:
      case MenuItemType.analysis:
      case MenuItemType.settings:
        _dontSupportSportDetailMenuItemTap();
    }

    widget.onItemTap?.call();
  }

  void _onSportDetailMenuItemTap(int sportId) {
    ref.read(previousContentProvider.notifier).state = MainContentType.home;
    final sport = v2.SportType.fromId(sportId) ?? v2.SportType.soccer;
    ref.read(selectedSportV2Provider.notifier).state = sport;

    if (!ref.read(sbMaintenanceProvider)) {
      ref
          .read(sportSocketAdapterProvider)
          .subscriptionManager
          .setActiveSport(sportId);
    }

    ref.read(mainContentProvider.notifier).goToSportDetail();
  }

  void _dontSupportSportDetailMenuItemTap() {
    AppToast.showError(context, message: 'Tính năng này chưa được hỗ trợ');
  }

  @override
  Widget build(BuildContext context) {
    final currentContent = ref.watch(mainContentProvider);
    final isHome = currentContent == MainContentType.home;
    final isCasinoActive = currentContent == MainContentType.casino;
    final sbMaintenance = ref.watch(sbMaintenanceProvider);
    final isSportActive = !isCasinoActive && !isHome;
    final MenuItemType? effectiveSelectedItem;
    if (isHome) {
      effectiveSelectedItem = null;
    } else if (widget.onTopTournamentsTapForMobile != null &&
        currentContent == MainContentType.tournaments) {
      effectiveSelectedItem = MenuItemType.topTournaments;
    } else if (currentContent == MainContentType.sport) {
      effectiveSelectedItem = MenuItemType.allSports;
    } else if (currentContent == MainContentType.live) {
      effectiveSelectedItem = MenuItemType.live;
    } else if (currentContent == MainContentType.upcoming) {
      effectiveSelectedItem = MenuItemType.upcoming;
    } else if (currentContent == MainContentType.tournaments) {
      effectiveSelectedItem = MenuItemType.topTournaments;
    } else if (currentContent == MainContentType.sportDetail) {
      final sport = ref.watch(selectedSportV2Provider);
      effectiveSelectedItem = _sportTypeToMenuItem(sport);
    } else if (currentContent == MainContentType.betDetail) {
      final sportId =
          ref.watch(selectedLeagueV2Provider.select((l) => l?.sportId)) ??
          ref.watch(selectedSportV2Provider).id;
      final sport = v2.SportType.fromId(sportId) ?? v2.SportType.soccer;
      effectiveSelectedItem = _sportTypeToMenuItem(sport);
    } else if (currentContent == MainContentType.leagueDetail) {
      effectiveSelectedItem = null;
    } else {
      effectiveSelectedItem = _selectedItem;
    }

    return SizedBox(
      width: widget.isDesktop ? 200 : double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    right: widget.isDesktop ? 0 : 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          label: 'Thể thao',
                          iconPlatform: AppIcons.iconSoccer,
                          iconPlatformSelected: AppIcons.iconSoccerSelected,
                          icon: AppImages.backgroundTabMenu,
                          iconSelected: AppImages.backgroundTabMenuSelected,
                          isActive: isSportActive,
                          onTap: () {
                            ref.read(mainContentProvider.notifier).goToSport();
                            setState(() {
                              _selectedItem = MenuItemType.allSports;
                            });
                          },
                        ),
                      ),
                      const Gap(AppSpacingStyles.space200),
                      Expanded(
                        child: _TabButton(
                          label: 'Casino',
                          iconPlatform: AppIcons.iconCasino,
                          iconPlatformSelected: AppIcons.iconCasinoSelected,
                          icon: AppImages.backgroundTabMenu,
                          iconSelected: AppImages.backgroundTabMenuSelected,
                          isActive: isCasinoActive,
                          onTap: () {
                            _updateCasinoSelection(
                              const GameCategorySelection(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacingStyles.space600),
                if (isCasinoActive)
                  ..._buildCasinoMenuItems()
                else ...[
                  if (!sbMaintenance) ...[
                  _MenuItem(
                    icon: _getIconPath(
                      MenuItemType.allSports,
                      effectiveSelectedItem == MenuItemType.allSports,
                    ),
                    label: 'Tất cả thể thao',
                    isSelected: effectiveSelectedItem == MenuItemType.allSports,
                    onTap: () => _onMenuItemTap(MenuItemType.allSports),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                  ),
                  _MenuItem(
                    icon: _getIconPath(
                      MenuItemType.live,
                      effectiveSelectedItem == MenuItemType.live,
                    ),
                    label: 'Đang diễn ra',
                    txtColorDefault: const Color(0xFF989582),
                    isSelected: effectiveSelectedItem == MenuItemType.live,
                    onTap: () => _onMenuItemTap(MenuItemType.live),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                  ),
                  _MenuItem(
                    icon: _getIconPath(
                      MenuItemType.upcoming,
                      effectiveSelectedItem == MenuItemType.upcoming,
                    ),
                    label: 'Sắp diễn ra',
                    isSelected: effectiveSelectedItem == MenuItemType.upcoming,
                    onTap: () => _onMenuItemTap(MenuItemType.upcoming),
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final isAuthenticated = ref.watch(
                        isAuthenticatedProvider,
                      );
                      final betCount = ref.watch(
                        myBetNotifierProvider.select((s) => s.myBetsCount),
                      );
                      return _MenuItem(
                        icon: _getIconPath(
                          MenuItemType.myBets,
                          effectiveSelectedItem == MenuItemType.myBets,
                        ),
                        label: 'Cược của tôi',
                        isSelected:
                            effectiveSelectedItem == MenuItemType.myBets,
                        badge: isAuthenticated && betCount > 0
                            ? (betCount > 99 ? '99+' : betCount.toString())
                            : null,
                        onTap: () {
                          if (!requireLogin(context, ref)) return;
                          if (blockedBySbMaintenance(context, ref)) return;
                          if (effectiveSelectedItem != MenuItemType.myBets) {
                            _onMenuItemTap(MenuItemType.myBets);
                          } else {
                            ref.read(myBetHubControllerProvider).changeMenu(
                                  MyBetMenu.myBets,
                                );
                          }
                        },
                        showSelectedShadow:
                            widget.onTopTournamentsTapForMobile == null,
                      );
                    },
                  ),
                  _MenuItem(
                    icon: _getIconPath(
                      MenuItemType.topTournaments,
                      effectiveSelectedItem == MenuItemType.topTournaments,
                    ),
                    label: 'Top giải đấu',
                    isSelected:
                        effectiveSelectedItem == MenuItemType.topTournaments,
                    onTap: () => _onMenuItemTap(MenuItemType.topTournaments),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
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
                  _ExpandableSportMenuItem(
                    sportId: v2.SportType.soccer.id,
                    type: MenuItemType.soccer,
                    label: 'Bóng đá',
                    isSelected: effectiveSelectedItem == MenuItemType.soccer,
                    onTap: () => _onMenuItemTap(MenuItemType.soccer),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                    getIconPath: _getIconPath,
                    onLeagueTap: widget.onItemTap,
                    initExpanded: true,
                  ),
                  _ExpandableSportMenuItem(
                    sportId: v2.SportType.badminton.id,
                    type: MenuItemType.badminton,
                    label: 'Cầu lông',
                    isSelected: effectiveSelectedItem == MenuItemType.badminton,
                    onTap: () => _onMenuItemTap(MenuItemType.badminton),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                    getIconPath: _getIconPath,
                    onLeagueTap: widget.onItemTap,
                    initExpanded: true,
                  ),
                  _ExpandableSportMenuItem(
                    sportId: v2.SportType.tennis.id,
                    type: MenuItemType.tennis,
                    label: 'Quần vợt',
                    isSelected: effectiveSelectedItem == MenuItemType.tennis,
                    onTap: () => _onMenuItemTap(MenuItemType.tennis),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                    getIconPath: _getIconPath,
                    onLeagueTap: widget.onItemTap,
                  ),
                  _ExpandableSportMenuItem(
                    sportId: v2.SportType.basketball.id,
                    type: MenuItemType.basketball,
                    label: 'Bóng rổ',
                    isSelected:
                        effectiveSelectedItem == MenuItemType.basketball,
                    onTap: () => _onMenuItemTap(MenuItemType.basketball),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                    getIconPath: _getIconPath,
                    onLeagueTap: widget.onItemTap,
                  ),
                  _ExpandableSportMenuItem(
                    sportId: v2.SportType.volleyball.id,
                    type: MenuItemType.volleyball,
                    label: 'Bóng chuyền',
                    isSelected:
                        effectiveSelectedItem == MenuItemType.volleyball,
                    onTap: () => _onMenuItemTap(MenuItemType.volleyball),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                    getIconPath: _getIconPath,
                    onLeagueTap: widget.onItemTap,
                  ),
                  _buildDivider(),
                  ],
                  _ProviderMenuSection(
                    key: ValueKey('ncc-$sbMaintenance'),
                    initExpanded: sbMaintenance,
                    onItemTap: widget.onItemTap,
                  ),
                  _buildDivider(),
                  _MenuItem(
                    icon: _getIconPath(
                      MenuItemType.support,
                      effectiveSelectedItem == MenuItemType.support,
                    ),
                    label: 'Hỗ trợ',
                    isSelected: effectiveSelectedItem == MenuItemType.support,
                    onTap: () => _onMenuItemTap(MenuItemType.support),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                  ),
                ],
              ],
                    ),
                  ),
                ),
              ),
            ),
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: DownloadAppButton(onClose: widget.onItemTap),
            ),
        ],
      ),
    );
  }

  void _updateCasinoSelection(GameCategorySelection selection) {
    ref.goToCasino(selection: selection);
    widget.onItemTap?.call();
  }

  List<Widget> _buildCasinoMenuItems() {
    final categories = ref.watch(lobbyCategoriesProvider);
    final selection = ref.watch(gameCategorySelectionProvider);
    final providerCategories = ref.watch(casinoProviderCategoriesProvider);
    final showShadow = widget.onTopTournamentsTapForMobile == null;
    final providerIds = {for (final c in providerCategories) c.id};

    Widget buildMenuItem(LobbyCategory category) {
      final isAll = category.isAll;
      final isSelected = isAll
          ? selection.isEmpty
          : selection.category?.id == category.id;

      final iconPath = category.iconPath(active: isSelected);

      return _MenuItem(
        iconKey: ValueKey('category_icon_${category.id}'),
        icon: iconPath,
        label: isAll ? 'Tất cả casino' : category.displayName,
        isSelected: isSelected,
        onTap: () => _updateCasinoSelection(
          isAll
              ? const GameCategorySelection()
              : GameCategorySelection.fromCategory(category),
        ),
        showSelectedShadow: showShadow,
      );
    }

    final menuItems = <Widget>[];
    for (final group in SidebarGroup.values) {
      final inGroup = categories.where((c) {
        if (c.id == 'sun' && providerIds.contains('sun')) return false;
        if (providerIds.contains('ncc:' + c.id)) return false;
        return c.sidebarGroup == group;
      });
      if (inGroup.isEmpty) continue;
      if (menuItems.isNotEmpty) menuItems.add(_buildDivider());
      for (final category in inGroup) {
        menuItems.add(buildMenuItem(category));
        if (category.isAll && providerCategories.isNotEmpty) {
          menuItems.add(
            _CasinoProviderMenuSection(
              categories: providerCategories,
              selectedId: selection.category?.id,
              showSelectedShadow: showShadow,
              onSelect: (category) => _updateCasinoSelection(
                GameCategorySelection.fromCategory(category),
              ),
            ),
          );
        }
      }
    }

    return menuItems;
  }

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
  final String iconPlatform;
  final String iconPlatformSelected;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.iconSelected,
    required this.isActive,
    required this.onTap,
    required this.iconPlatform,
    required this.iconPlatformSelected,
  });

  @override
  Widget build(BuildContext context) => InnerShadowCard(
    color: Colors.white.withValues(alpha: 0.02),
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
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
                      width: double.infinity,
                      height: 69,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageHelper.load(
                      path: isActive ? iconPlatformSelected : iconPlatform,
                      width: 20,
                      height: 20,
                      fit: BoxFit.fill,
                    ),
                    const Gap(10),
                    Text(
                      label,
                      style: AppTextStyles.displayStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppColors.yellow300
                            : AppColorStyles.contentSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SelectedMenuIndicator extends StatelessWidget {
  const _SelectedMenuIndicator();

  static const Color _accent = Color(0xFFFFD691);

  @override
  Widget build(BuildContext context) => Container(
    width: 2,
    height: 36,
    decoration: BoxDecoration(
      color: _accent,
      borderRadius: BorderRadius.circular(2),
      boxShadow: [
        BoxShadow(
          color: _accent.withValues(alpha: 0.55),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ],
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final String? icon;
  final Key? iconKey;

  final BoxFit iconFit;
  final String label;
  final bool isSelected;
  final String? badge;
  final Widget? trailing;
  final Color? txtColorDefault;
  final VoidCallback? onTap;

  final bool showSelectedShadow;

  const _MenuItem({
    required this.label,
    this.icon,
    this.iconKey,
    this.iconFit = BoxFit.cover,
    this.isSelected = false,
    this.badge,
    this.trailing,
    this.txtColorDefault,
    this.onTap,
    this.showSelectedShadow = true,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    child: Row(
      children: [
        if (isSelected && showSelectedShadow) const _SelectedMenuIndicator(),
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
                        colors: [Color(0x14FFD791), Color(0x00FFD791)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    RepaintBoundary(
                      key: iconKey,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: ImageHelper.load(
                            path: icon.toString(),
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const Gap(8),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.textStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFFFFD691)
                            : txtColorDefault ?? const Color(0xFFAAA49B),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      width: 28,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.green300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Center(
                        child: Text(
                          badge!,
                          style: AppTextStyles.textStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray950,
                          ),
                        ),
                      ),
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class DownloadAppButton extends ConsumerStatefulWidget {
  const DownloadAppButton({super.key, this.onClose, this.horizontalPadding = 8});

  final VoidCallback? onClose;

  final double horizontalPadding;

  @override
  ConsumerState<DownloadAppButton> createState() => _DownloadAppButtonState();
}

class _DownloadAppButtonState extends ConsumerState<DownloadAppButton> {
  static const Color _textColor = Color(0xFFFDEAD7);

  bool _loading = false;

  Future<void> _handleTap() async {
    if (_loading) return;
    await runDownloadAppAction(
      context: context,
      ref: ref,
      onClose: widget.onClose,
      onLoading: (loading) {
        if (mounted) setState(() => _loading = loading);
      },
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
    child: GestureDetector(
      onTap: SoundTap.wrap(_handleTap),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: ImageHelper.load(
                path: AppImages.backgroundDownloadApp,
                width: 175,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            width: 172,
            height: 44,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RepaintBoundary(
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _textColor,
                            ),
                          ),
                        )
                      : ImageHelper.load(
                          path: AppIcons.iconMobileSelected,
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                ),
                const Gap(8),
                Flexible(
                  child: Text(
                    'Tải app ngay',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.textStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 18 / 12,
                      color: _textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ExpandableSportMenuItem extends ConsumerStatefulWidget {
  final int sportId;
  final MenuItemType type;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showSelectedShadow;
  final String? Function(MenuItemType, bool) getIconPath;
  final VoidCallback? onLeagueTap;

  final bool initExpanded;

  const _ExpandableSportMenuItem({
    required this.sportId,
    required this.type,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.showSelectedShadow,
    required this.getIconPath,
    this.onLeagueTap,
    this.initExpanded = false,
  });

  @override
  ConsumerState<_ExpandableSportMenuItem> createState() =>
      _ExpandableSportMenuItemState();
}

class _ExpandableSportMenuItemState
    extends ConsumerState<_ExpandableSportMenuItem> {
  bool _isExpanded = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    LeagueAliasStore.instance.addListener(_onLeagueAliasChanged);
  }

  @override
  void dispose() {
    LeagueAliasStore.instance.removeListener(_onLeagueAliasChanged);
    super.dispose();
  }

  void _onLeagueAliasChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final leagues = ref.watch(sbMaintenanceProvider)
        ? null
        : ref.watch(topLeagueEventsProvider(widget.sportId)).valueOrNull;
    final hasData = leagues != null && leagues.isNotEmpty;

    if (widget.initExpanded && hasData && !_hasInitialized) {
      _hasInitialized = true;
      _isExpanded = true;
    }

    final labels = hasData
        ? leagueChipLabels(
            [
              for (final l in leagues)
                (id: l.leagueId, name: l.leagueName),
            ],
            sportId: widget.sportId,
            table: LeagueAliasStore.instance.table,
          )
        : const <int, String>{};

    return Column(
      children: [
        _MenuItem(
          icon: widget.getIconPath(widget.type, widget.isSelected),
          label: widget.label,
          isSelected: widget.isSelected,
          onTap: widget.onTap,
          showSelectedShadow: widget.showSelectedShadow,
          trailing: hasData
              ? InkWell(
                  onTap: SoundTap.wrap(() {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  }),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFFAAA49B),
                      size: 20,
                    ),
                  ),
                )
              : null,
        ),
        if (_isExpanded && hasData)
          Container(
            margin: const EdgeInsets.only(left: 24),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColorStyles.borderPrimary, width: 2),
              ),
            ),
            child: Column(
              children: leagues
                  .map(
                    (league) => _buildLeagueItem(
                      league,
                      labels[league.leagueId] ?? league.leagueName,
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _leagueLabel(LeagueModelV2 league, String label, bool isSelected) {
    final text = Text(
      label,
      style: AppTextStyles.textStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isSelected
            ? const Color(0xFFFFD691)
            : const Color(0xFFAAA49B),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final fullName = normalizeLeagueName(league.leagueName);
    if (label == fullName) return text;
    return Tooltip(message: fullName, child: text);
  }

  Widget _buildLeagueItem(LeagueModelV2 league, String label) {
    final selectedLeague = ref.watch(selectedLeagueInfoProvider);
    final currentContent = ref.watch(mainContentProvider);
    final isSelected =
        currentContent == MainContentType.leagueDetail &&
        selectedLeague?.leagueId == league.leagueId;

    return Row(
      children: [
        if (isSelected && widget.showSelectedShadow)
          const _SelectedMenuIndicator(),
        Expanded(
          child: InkWell(
            onTap: SoundTap.wrap(() {
              ref
                  .read(selectedLeagueInfoProvider.notifier)
                  .state = SelectedLeagueInfo(
                sportId: league.sportId,
                leagueId: league.leagueId,
                leagueName: league.leagueName,
                leagueLogo: league.leagueLogo,
              );
              ref.read(mainContentProvider.notifier).goToLeagueDetail();
              ref.read(previousContentProvider.notifier).state = null;
              widget.onLeagueTap?.call();
            }),
            child: Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0x14FFD791), Color(0x00FFD791)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (league.leagueLogo.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        color: Colors.white,
                        width: 20,
                        height: 20,
                        child: ImageHelper.load(
                          path: league.leagueLogo,
                          fit: BoxFit.contain,
                          errorWidget: const SizedBox(width: 20),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 20),
                  const SizedBox(width: 8),
                  Expanded(child: _leagueLabel(league, label, isSelected)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CasinoProviderMenuSection extends StatefulWidget {
  const _CasinoProviderMenuSection({
    required this.categories,
    required this.onSelect,
    this.selectedId,
    this.showSelectedShadow = true,
  });

  final List<LobbyCategory> categories;
  final ValueChanged<LobbyCategory> onSelect;
  final String? selectedId;
  final bool showSelectedShadow;

  @override
  State<_CasinoProviderMenuSection> createState() =>
      _CasinoProviderMenuSectionState();
}

class _CasinoProviderMenuSectionState
    extends State<_CasinoProviderMenuSection> {
  bool? _expandedByUser;

  @override
  Widget build(BuildContext context) {
    final hasSelected = widget.categories.any(
      (c) => c.id == widget.selectedId,
    );
    final isExpanded = _expandedByUser ?? hasSelected;

    return Column(
      children: [
        _MenuItem(
          label: 'Nhà cung cấp',
          showSelectedShadow: false,
          onTap: () => setState(() => _expandedByUser = !isExpanded),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xFFAAA49B),
              size: 20,
            ),
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(left: 24),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColorStyles.borderPrimary, width: 2),
              ),
            ),
            child: Column(
              children: [
                for (final category in widget.categories)
                  _MenuItem(
                    iconKey: ValueKey('ncc_icon_${category.id}'),
                    icon: category.iconPath(
                      active: category.id == widget.selectedId,
                    ),
                    iconFit: BoxFit.contain,
                    label: category.displayName,
                    isSelected: category.id == widget.selectedId,
                    showSelectedShadow: false,
                    onTap: () => widget.onSelect(category),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ProviderMenuSection extends ConsumerStatefulWidget {
  final bool initExpanded;

  final VoidCallback? onItemTap;

  const _ProviderMenuSection({
    super.key,
    this.initExpanded = false,
    this.onItemTap,
  });

  @override
  ConsumerState<_ProviderMenuSection> createState() =>
      _ProviderMenuSectionState();
}

class _ProviderMenuSectionState extends ConsumerState<_ProviderMenuSection> {
  late bool _isExpanded = widget.initExpanded;

  @override
  Widget build(BuildContext context) {
    final sbMaintenance = ref.watch(sbMaintenanceProvider);

    return Column(
      children: [
        _MenuItem(
          label: 'Nhà cung cấp',
          showSelectedShadow: false,
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xFFAAA49B),
              size: 20,
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(left: 24),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColorStyles.borderPrimary, width: 2),
              ),
            ),
            child: Column(
              children: [
                if (sbMaintenance)
                  Opacity(
                    opacity: 0.5,
                    child: _MenuItem(
                      icon: AppIcons.iconKSport,
                      label: 'KSport',
                      showSelectedShadow: false,
                      trailing: const _SbMaintenancePill(),
                    ),
                  )
                else
                  _MenuItem(
                    icon: AppIcons.iconKSport,
                    label: 'KSport',
                    showSelectedShadow: false,
                    onTap: () => _open(NccProvider.ksport),
                  ),
                _MenuItem(
                  icon: AppIcons.iconSaba,
                  label: 'Saba Sport',
                  showSelectedShadow: false,
                  trailing: ImageHelper.load(
                    path: AppIcons.iconNCCShare,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                  onTap: () => _open(NccProvider.saba),
                ),
                _MenuItem(
                  icon: AppIcons.iconBTI,
                  label: 'BTI Sport',
                  showSelectedShadow: false,
                  trailing: ImageHelper.load(
                    path: AppIcons.iconNCCShare,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                  onTap: () => _open(NccProvider.bti),
                ),
                _MenuItem(
                  icon: AppIcons.iconIMSport,
                  label: 'IM Sport',
                  showSelectedShadow: false,
                  trailing: ImageHelper.load(
                    path: AppIcons.iconNCCShare,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                  onTap: () => _open(NccProvider.imSport),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _open(NccProvider provider) {
    unawaited(handleNccTap(ref, context, provider));
    widget.onItemTap?.call();
  }
}

class _SbMaintenancePill extends StatelessWidget {
  const _SbMaintenancePill();

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 16,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.red600,
      borderRadius: BorderRadius.circular(100),
    ),
    child: Text(
      'Bảo trì',
      style: AppTextStyles.textStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFC9C9),
      ).copyWith(height: 1.0),
    ),
  );
}
