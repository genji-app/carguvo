import 'package:sun_sports/core/utils/styles/app_icons.dart';

enum SportType {
  soccer(1, 'Soccer', 'Bong da'),
  basketball(2, 'Basketball', 'Bong ro'),
  boxing(3, 'Boxing/MMA', 'Quyen anh'),
  tennis(4, 'Tennis', 'Quan vot'),
  volleyball(5, 'Volleyball', 'Bong chuyen'),
  tableTennis(6, 'Table Tennis', 'Bong ban'),
  badminton(7, 'Badminton', 'Cau long');

  final int id;
  final String nameEn;
  final String nameVi;

  const SportType(this.id, this.nameEn, this.nameVi);

  static SportType? fromId(int id) {
    try {
      return SportType.values.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  String get iconPath {
    switch (this) {
      case SportType.soccer:
        return AppIcons.iconSoccer;
      case SportType.basketball:
        return AppIcons.iconBasketball;
      case SportType.tennis:
        return AppIcons.iconTennis;
      case SportType.volleyball:
        return AppIcons.iconVolleyball;
      case SportType.tableTennis:
        return AppIcons.iconTableTennis;
      case SportType.badminton:
        return AppIcons.iconBadminton;
      default:
        return '';
    }
  }

  String displayName({bool vietnamese = true}) => vietnamese ? nameVi : nameEn;
}

enum EventTimeRange {
  live(0, 'Live', 'Truc tuyen'),

  today(1, 'Today', 'Hom nay'),

  early(2, 'Early', 'Dau som'),

  todayAndEarly(3, 'All', 'Tat ca');

  final int value;
  final String labelEn;
  final String labelVi;

  const EventTimeRange(this.value, this.labelEn, this.labelVi);

  String displayLabel({bool vietnamese = true}) =>
      vietnamese ? labelVi : labelEn;

  static EventTimeRange fromValue(int value) {
    return EventTimeRange.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventTimeRange.live,
    );
  }
}

enum BoxingType {
  muayThai(1, 'Muay Thai'),
  mma(2, 'MMA/UFC'),
  boxing(3, 'Boxing');

  final int id;
  final String name;

  const BoxingType(this.id, this.name);

  static BoxingType? fromId(int? id) {
    if (id == null) return null;
    try {
      return BoxingType.values.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
