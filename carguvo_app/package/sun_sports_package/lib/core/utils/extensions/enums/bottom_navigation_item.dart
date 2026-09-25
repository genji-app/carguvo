import 'package:sun_sports/core/utils/styles/app_icons.dart';

enum BottomNavigationItem {
  menu,
  casino,
  bettingTickets,
  sports,
  sun247,
  home,
  miniGames;

  int get tabIndex {
    switch (this) {
      case BottomNavigationItem.home:
        return 0;
      case BottomNavigationItem.casino:
        return 1;
      case BottomNavigationItem.bettingTickets:
        return 2;
      case BottomNavigationItem.sports:
        return 3;
      case BottomNavigationItem.menu:
        return 4;
      case BottomNavigationItem.sun247:
        return 5;
      case BottomNavigationItem.miniGames:
        return 6;
    }
  }

  String get label {
    switch (this) {
      case BottomNavigationItem.home:
        return 'Trang chủ';
      case BottomNavigationItem.casino:
        return 'Casino';
      case BottomNavigationItem.bettingTickets:
        return 'Phiếu cược';
      case BottomNavigationItem.sports:
        return 'Thể thao';
      case BottomNavigationItem.menu:
        return 'Menu';
      case BottomNavigationItem.sun247:
        return 'Hỗ trợ';
      case BottomNavigationItem.miniGames:
        return 'Mini games';
    }
  }

  String get iconPath {
    switch (this) {
      case BottomNavigationItem.home:
        return AppIcons.iconS;
      case BottomNavigationItem.casino:
        return AppIcons.iconCasino;
      case BottomNavigationItem.bettingTickets:
        return AppIcons.iconBet;
      case BottomNavigationItem.sports:
        return AppIcons.iconSoccer;
      case BottomNavigationItem.menu:
        return AppIcons.iconMenu;
      case BottomNavigationItem.sun247:
        return AppIcons.iconLivechat;
      case BottomNavigationItem.miniGames:
        return AppIcons.iconNavMiniGame;
    }
  }

  String get iconSelectedPath {
    switch (this) {
      case BottomNavigationItem.home:
        return AppIcons.iconSSelected;
      case BottomNavigationItem.casino:
        return AppIcons.iconCasinoSelected;
      case BottomNavigationItem.bettingTickets:
        return AppIcons.iconBetSelected;
      case BottomNavigationItem.sports:
        return AppIcons.iconSoccerSelected;
      case BottomNavigationItem.menu:
        return AppIcons.iconMenuSelected;
      case BottomNavigationItem.sun247:
        return AppIcons.iconChatSelected;
      case BottomNavigationItem.miniGames:
        return AppIcons.iconNavMiniGame;
    }
  }

  bool get isSport {
    return this == BottomNavigationItem.sports;
  }

  static BottomNavigationItem fromIndex(int index) {
    switch (index) {
      case 0:
        return BottomNavigationItem.home;
      case 1:
        return BottomNavigationItem.sports;
      case 2:
        return BottomNavigationItem.bettingTickets;
      case 3:
        return BottomNavigationItem.sun247;
      case 4:
        return BottomNavigationItem.miniGames;
      default:
        return BottomNavigationItem.sports;
    }
  }

  static List<BottomNavigationItem> get all => [
    BottomNavigationItem.home,
    BottomNavigationItem.sports,
    BottomNavigationItem.bettingTickets,
    BottomNavigationItem.sun247,
    BottomNavigationItem.miniGames,
  ];
}
