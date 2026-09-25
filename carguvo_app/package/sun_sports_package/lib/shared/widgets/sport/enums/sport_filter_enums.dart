enum SportDetailFilterType { today, special, upcoming, live, favorites }

extension SportDetailFilterTypeX on SportDetailFilterType {
  String get label {
    switch (this) {
      case SportDetailFilterType.today:
        return 'Hôm nay';
      case SportDetailFilterType.special:
        return 'Đặc biệt';
      case SportDetailFilterType.upcoming:
        return 'Sắp diễn ra';
      case SportDetailFilterType.live:
        return 'Trực tiếp';
      case SportDetailFilterType.favorites:
        return 'Yêu thích';
    }
  }

  String get labelEn {
    switch (this) {
      case SportDetailFilterType.today:
        return 'Today';
      case SportDetailFilterType.special:
        return 'Special';
      case SportDetailFilterType.upcoming:
        return 'Upcoming';
      case SportDetailFilterType.live:
        return 'Live';
      case SportDetailFilterType.favorites:
        return 'Favorites';
    }
  }
}
