import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_collapse_provider.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_tab_provider.dart';
import 'package:sun_sports/features/sport_detail/presentation/mobile/widgets/sport_detail_mobile_matches_section.dart';
import 'package:sun_sports/shared/domain/enums/navigation_enums.dart';

export 'package:sun_sports/shared/domain/enums/navigation_enums.dart'
    show MainContentType, MainContentTypeExtension;

class MainContentNotifier extends StateNotifier<MainContentType> {
  final Ref _ref;

  int _resetFilterGeneration = 0;

  MainContentNotifier(this._ref) : super(MainContentType.home);

  void switchTo(MainContentType type) {
    if (state != type) {
      final previousState = state;

      if (type == MainContentType.tournaments ||
          type == MainContentType.leagueDetail) {
        _ref.read(previousContentProvider.notifier).state = previousState;
      }

      state = type;

      if (previousState != MainContentType.betDetail &&
          (type == MainContentType.sport ||
              type == MainContentType.live ||
              type == MainContentType.upcoming ||
              type == MainContentType.tournaments)) {
        _scheduleResetSportFilterToDefault();
      }

      if (previousState == MainContentType.betDetail) {
        _clearBetDetailState();
      }

      if (previousState == MainContentType.sportDetail &&
          type != MainContentType.betDetail) {
        _clearSportDetailTabState();
      }
    }
  }

  void _clearBetDetailState() {}

  void _resetSportFilterToDefault() {
    const defaultSport = SportType.soccer;
    if (_ref.read(selectedSportV2Provider) == defaultSport) return;
    _ref.read(selectedSportV2Provider.notifier).state = defaultSport;
    _ref
        .read(sportSocketAdapterProvider)
        .subscriptionManager
        .setActiveSport(defaultSport.id);
  }

  void _scheduleResetSportFilterToDefault() {
    final gen = ++_resetFilterGeneration;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (gen != _resetFilterGeneration) return;
      _resetSportFilterToDefault();
    });
  }

  void _clearSportDetailTabState() {
    _ref.read(sportDetailTabProvider.notifier).state =
        SportDetailFilterType.today;
  }

  void goToHome() => switchTo(MainContentType.home);

  void goToSport() => switchTo(MainContentType.sport);

  void goToTournaments() => switchTo(MainContentType.tournaments);

  void goToLive() => switchTo(MainContentType.live);

  void goToUpcoming() => switchTo(MainContentType.upcoming);

  void goToSun247() => switchTo(MainContentType.sun247);

  void goToCasino() => switchTo(MainContentType.casino);

  void goToBetDetail() {
    _ref.read(previousBetDetailContentProvider.notifier).state = state;
    switchTo(MainContentType.betDetail);
  }

  void goBackFromBetDetail() {
    final previousState = _ref.read(previousBetDetailContentProvider);
    if (previousState != null && previousState != MainContentType.betDetail) {
      switchTo(previousState);
    } else {
      switchTo(MainContentType.sport);
    }
    _ref.read(previousBetDetailContentProvider.notifier).state = null;
  }

  void goToSportDetail() {
    if (state != MainContentType.sportDetail) {
      _ref.read(sportDetailCollapseAllProvider.notifier).state = false;
    }
    switchTo(MainContentType.sportDetail);
  }

  void goToLeagueDetail() => switchTo(MainContentType.leagueDetail);
}

final mainContentProvider =
    StateNotifierProvider<MainContentNotifier, MainContentType>(
      (ref) => MainContentNotifier(ref),
    );

final previousContentProvider = StateProvider<MainContentType?>((ref) => null);

final previousBetDetailContentProvider = StateProvider<MainContentType?>(
  (ref) => null,
);
