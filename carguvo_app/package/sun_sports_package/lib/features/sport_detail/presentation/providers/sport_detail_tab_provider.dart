import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/shared/widgets/sport/enums/sport_filter_enums.dart';

final sportDetailTabProvider = StateProvider<SportDetailFilterType>(
  (ref) => SportDetailFilterType.live,
);
