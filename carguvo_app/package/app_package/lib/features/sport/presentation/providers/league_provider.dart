import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/providers/infra_provider.dart';
import 'package:app_package/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:app_package/core/services/storage/sport_storage.dart';
import 'package:app_package/shared/domain/enums/league_enums.dart';

final currentSportIdProvider = Provider<int>(
  (ref) => ref.watch(selectedSportV2Provider).id,
);

class OddsStyleNotifier extends StateNotifier<OddsStyle> {
  OddsStyleNotifier(this._storage)
      : super(OddsStyle.fromShortName(_storage.getOddsStyleSync()));

  final SportStorage _storage;

  void change(OddsStyle style) {
    if (state == style) return;
    state = style;
    _storage.saveOddsStyle(style.shortName);
  }
}

final oddsStyleProvider = StateNotifierProvider<OddsStyleNotifier, OddsStyle>(
  (ref) => OddsStyleNotifier(ref.watch(sportStorageProvider)),
);
