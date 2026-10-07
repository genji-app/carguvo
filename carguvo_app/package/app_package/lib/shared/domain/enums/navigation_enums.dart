enum MainContentType {
  home,
  sport,
  casino,
  betDetail,
  sportDetail,
  sun247,
  tournaments,
  live,
  upcoming,
  leagueDetail,
}

extension MainContentTypeExtension on MainContentType {
  String get displayName {
    switch (this) {
      case MainContentType.home:
        return 'Trang chủ';
      case MainContentType.sport:
        return 'Thể thao';
      case MainContentType.casino:
        return 'Casino';
      case MainContentType.betDetail:
        return 'Chi tiết cược';
      case MainContentType.sportDetail:
        return 'Chi tiết thể thao';
      case MainContentType.sun247:
        return 'Hỗ trợ';
      case MainContentType.tournaments:
        return 'Top giải đấu';
      case MainContentType.live:
        return 'Đang diễn ra';
      case MainContentType.upcoming:
        return 'Sắp diễn ra';
      case MainContentType.leagueDetail:
        return 'Chi tiết giải đấu';
    }
  }

  bool get isSport => this == MainContentType.sport;

  bool get isCasino => this == MainContentType.casino;

  bool get isHome => this == MainContentType.home;

  bool get isBetDetail => this == MainContentType.betDetail;

  bool get isSportDetail => this == MainContentType.sportDetail;
}

enum MenuItemType {
  allSports,
  live,
  upcoming,
  myBets,
  topTournaments,
  volta,
  events,
  soccer,
  tennis,
  basketball,
  badminton,
  tableTennis,
  volleyball,
  liveChat,
  depositWithdraw,
  trollSport,
  analysis,
  support,
  settings,
  downloadApp,
}
