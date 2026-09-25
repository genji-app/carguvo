import 'package:betting_domain/betting_domain.dart' show HotTrend;
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/market_model_v2.dart';

export 'package:betting_domain/betting_domain.dart' show HotTrendSide;

typedef HotBettingTrend = HotTrend;

class HotMatchEventStatistics {
  final HotBettingTrend? bettingTrend;
  final int? totalUsers;

  const HotMatchEventStatistics({this.bettingTrend, this.totalUsers});
}

class HotMatchState {
  final List<LeagueModelV2> leagues;

  final List<int> hotOrder;

  final Map<int, HotMatchEventStatistics> eventStatistics;

  final Set<int> pendingStatisticsIds;

  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;
  final int currentPageIndex;

  final int rightSidebarPageIndex;

  const HotMatchState({
    this.leagues = const [],
    this.hotOrder = const [],
    this.eventStatistics = const {},
    this.pendingStatisticsIds = const <int>{},
    this.isLoading = false,
    this.error,
    this.lastUpdated,
    this.currentPageIndex = 0,
    this.rightSidebarPageIndex = 0,
  });

  HotMatchState copyWith({
    List<LeagueModelV2>? leagues,
    List<int>? hotOrder,
    Map<int, HotMatchEventStatistics>? eventStatistics,
    Set<int>? pendingStatisticsIds,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    int? currentPageIndex,
    int? rightSidebarPageIndex,
  }) {
    return HotMatchState(
      leagues: leagues ?? this.leagues,
      hotOrder: hotOrder ?? this.hotOrder,
      eventStatistics: eventStatistics ?? this.eventStatistics,
      pendingStatisticsIds: pendingStatisticsIds ?? this.pendingStatisticsIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      rightSidebarPageIndex:
          rightSidebarPageIndex ?? this.rightSidebarPageIndex,
    );
  }

  bool get hasData => leagues.isNotEmpty;

  bool get isStatisticsFullyLoaded => pendingStatisticsIds.isEmpty;

  bool isStatisticsPending(int eventId) =>
      pendingStatisticsIds.contains(eventId);

  int get totalCount => leagues.fold<int>(0, (sum, l) => sum + l.events.length);
}

List<HotMatchEventV2> flattenLeaguesToHotMatches(
  List<LeagueModelV2> leagues, {
  Map<int, HotMatchEventStatistics> eventStatistics = const {},
}) {
  final list = <HotMatchEventV2>[];
  for (final league in leagues) {
    for (final event in league.events) {
      final stats = eventStatistics[event.eventId];
      list.add(
        HotMatchEventV2(
          event: event,
          leagueName: league.leagueName,
          leagueLogo: league.leagueLogo,
          leagueId: league.leagueId,
          bettingTrend: stats?.bettingTrend,
          totalUsers: stats?.totalUsers,
        ),
      );
    }
  }
  return list;
}

class HotMatchEventItem {
  final LeagueEventData event;
  final String leagueName;
  final String leagueLogo;
  final int leagueId;

  final HotBettingTrend? bettingTrend;

  final int? totalUsers;

  const HotMatchEventItem({
    required this.event,
    required this.leagueName,
    required this.leagueLogo,
    required this.leagueId,
    this.bettingTrend,
    this.totalUsers,
  });

  factory HotMatchEventItem.fromLeague(
    LeagueData league,
    LeagueEventData event, {
    HotBettingTrend? bettingTrend,
    int? totalUsers,
  }) {
    return HotMatchEventItem(
      event: event,
      leagueName: league.leagueName,
      leagueLogo: league.leagueLogo,
      leagueId: league.leagueId,
      bettingTrend: bettingTrend,
      totalUsers: totalUsers,
    );
  }

  HotMatchEventItem copyWith({
    LeagueEventData? event,
    String? leagueName,
    String? leagueLogo,
    int? leagueId,
    HotBettingTrend? bettingTrend,
    int? totalUsers,
  }) {
    return HotMatchEventItem(
      event: event ?? this.event,
      leagueName: leagueName ?? this.leagueName,
      leagueLogo: leagueLogo ?? this.leagueLogo,
      leagueId: leagueId ?? this.leagueId,
      bettingTrend: bettingTrend ?? this.bettingTrend,
      totalUsers: totalUsers ?? this.totalUsers,
    );
  }

  int get eventId => event.eventId;

  String get homeName => event.homeName;

  String get awayName => event.awayName;

  String get homeLogo => event.homeLogo;

  String get awayLogo => event.awayLogo;

  String get formattedTime => event.formattedTime;

  String get formattedDate => event.formattedDate;

  bool get isLive => event.isLive;

  String get scoreString => event.scoreString;

  List<LeagueMarketData> get markets => event.markets;

  LeagueMarketData? getHandicapMarket(int sportId) {
    final marketId = _getHandicapMarketId(sportId);
    return event.getMarketById(marketId);
  }

  LeagueMarketData? getOverUnderMarket(int sportId) {
    final marketId = _getOverUnderMarketId(sportId);
    return event.getMarketById(marketId);
  }

  int _getHandicapMarketId(int sportId) {
    switch (sportId) {
      case 1:
        return 5;
      case 2:
        return 201;
      case 4:
        return 402;
      case 5:
        return 509;
      default:
        return 5;
    }
  }

  int _getOverUnderMarketId(int sportId) {
    switch (sportId) {
      case 1:
        return 3;
      case 2:
        return 202;
      case 4:
        return 401;
      case 5:
        return 510;
      default:
        return 3;
    }
  }
}

class HotMatchEventV2 {
  final EventModelV2 event;
  final String leagueName;
  final String leagueLogo;
  final int leagueId;

  final HotBettingTrend? bettingTrend;

  final int? totalUsers;

  const HotMatchEventV2({
    required this.event,
    required this.leagueName,
    required this.leagueLogo,
    required this.leagueId,
    this.bettingTrend,
    this.totalUsers,
  });

  HotMatchEventV2 copyWith({
    EventModelV2? event,
    String? leagueName,
    String? leagueLogo,
    int? leagueId,
    HotBettingTrend? bettingTrend,
    int? totalUsers,
  }) {
    return HotMatchEventV2(
      event: event ?? this.event,
      leagueName: leagueName ?? this.leagueName,
      leagueLogo: leagueLogo ?? this.leagueLogo,
      leagueId: leagueId ?? this.leagueId,
      bettingTrend: bettingTrend ?? this.bettingTrend,
      totalUsers: totalUsers ?? this.totalUsers,
    );
  }

  int get eventId => event.eventId;
  String get homeName => event.homeName;
  String get awayName => event.awayName;
  String get homeLogo => event.homeLogo;
  String get awayLogo => event.awayLogo;
  bool get isLive => event.isLive;
  String get scoreString => event.scoreDisplay;
  int get startTime => event.startTime;

  String get formattedTime {
    final dt = event.startDateTime;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get formattedDate {
    final dt = event.startDateTime;
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$d/$mo';
  }

  MarketModelV2? getHandicapMarket(int sportId) {
    return event.getMarketById(_handicapMarketId(sportId));
  }

  MarketModelV2? getOverUnderMarket(int sportId) {
    return event.getMarketById(_overUnderMarketId(sportId));
  }

  static int _handicapMarketId(int sportId) {
    switch (sportId) {
      case 1:
        return 5;
      case 2:
        return 201;
      case 4:
        return 402;
      case 5:
        return 509;
      default:
        return 5;
    }
  }

  static int _overUnderMarketId(int sportId) {
    switch (sportId) {
      case 1:
        return 3;
      case 2:
        return 202;
      case 4:
        return 401;
      case 5:
        return 510;
      default:
        return 3;
    }
  }
}
