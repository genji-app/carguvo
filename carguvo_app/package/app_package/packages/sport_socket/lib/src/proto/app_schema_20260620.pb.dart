
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

enum Payload_Data {
  league,
  event,
  hotEvent,
  outrightEvent,
  betSlipStatus,
  popularLeagues,
  notSet
}

class Payload extends $pb.GeneratedMessage {
  factory Payload({
    $core.String? channel,
    $core.String? type,
    $core.int? timeRange,
    LeagueResponse? league,
    EventResponse? event,
    HotEventsResponse? hotEvent,
    OutrightEventResponse? outrightEvent,
    BetSlipStatusResponse? betSlipStatus,
    PopularLeaguesResponse? popularLeagues,
  }) {
    final result = create();
    if (channel != null) result.channel = channel;
    if (type != null) result.type = type;
    if (timeRange != null) result.timeRange = timeRange;
    if (league != null) result.league = league;
    if (event != null) result.event = event;
    if (hotEvent != null) result.hotEvent = hotEvent;
    if (outrightEvent != null) result.outrightEvent = outrightEvent;
    if (betSlipStatus != null) result.betSlipStatus = betSlipStatus;
    if (popularLeagues != null) result.popularLeagues = popularLeagues;
    return result;
  }

  Payload._();

  factory Payload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Payload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Payload_Data> _Payload_DataByTag = {
    4: Payload_Data.league,
    5: Payload_Data.event,
    6: Payload_Data.hotEvent,
    7: Payload_Data.outrightEvent,
    8: Payload_Data.betSlipStatus,
    9: Payload_Data.popularLeagues,
    0: Payload_Data.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Payload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..oo(0, [4, 5, 6, 7, 8, 9])
    ..aOS(1, _omitFieldNames ? '' : 'channel')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aI(3, _omitFieldNames ? '' : 'timeRange')
    ..aOM<LeagueResponse>(4, _omitFieldNames ? '' : 'league',
        subBuilder: LeagueResponse.create)
    ..aOM<EventResponse>(5, _omitFieldNames ? '' : 'event',
        subBuilder: EventResponse.create)
    ..aOM<HotEventsResponse>(6, _omitFieldNames ? '' : 'hotEvent',
        subBuilder: HotEventsResponse.create)
    ..aOM<OutrightEventResponse>(7, _omitFieldNames ? '' : 'outrightEvent',
        subBuilder: OutrightEventResponse.create)
    ..aOM<BetSlipStatusResponse>(8, _omitFieldNames ? '' : 'betSlipStatus',
        subBuilder: BetSlipStatusResponse.create)
    ..aOM<PopularLeaguesResponse>(9, _omitFieldNames ? '' : 'popularLeagues',
        subBuilder: PopularLeaguesResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Payload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Payload copyWith(void Function(Payload) updates) =>
      super.copyWith((message) => updates(message as Payload)) as Payload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Payload create() => Payload._();
  @$core.override
  Payload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Payload getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Payload>(create);
  static Payload? _defaultInstance;

  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  Payload_Data whichData() => _Payload_DataByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  void clearData() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get channel => $_getSZ(0);
  @$pb.TagNumber(1)
  set channel($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannel() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get timeRange => $_getIZ(2);
  @$pb.TagNumber(3)
  set timeRange($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimeRange() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeRange() => $_clearField(3);

  @$pb.TagNumber(4)
  LeagueResponse get league => $_getN(3);
  @$pb.TagNumber(4)
  set league(LeagueResponse value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLeague() => $_has(3);
  @$pb.TagNumber(4)
  void clearLeague() => $_clearField(4);
  @$pb.TagNumber(4)
  LeagueResponse ensureLeague() => $_ensure(3);

  @$pb.TagNumber(5)
  EventResponse get event => $_getN(4);
  @$pb.TagNumber(5)
  set event(EventResponse value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasEvent() => $_has(4);
  @$pb.TagNumber(5)
  void clearEvent() => $_clearField(5);
  @$pb.TagNumber(5)
  EventResponse ensureEvent() => $_ensure(4);

  @$pb.TagNumber(6)
  HotEventsResponse get hotEvent => $_getN(5);
  @$pb.TagNumber(6)
  set hotEvent(HotEventsResponse value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasHotEvent() => $_has(5);
  @$pb.TagNumber(6)
  void clearHotEvent() => $_clearField(6);
  @$pb.TagNumber(6)
  HotEventsResponse ensureHotEvent() => $_ensure(5);

  @$pb.TagNumber(7)
  OutrightEventResponse get outrightEvent => $_getN(6);
  @$pb.TagNumber(7)
  set outrightEvent(OutrightEventResponse value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasOutrightEvent() => $_has(6);
  @$pb.TagNumber(7)
  void clearOutrightEvent() => $_clearField(7);
  @$pb.TagNumber(7)
  OutrightEventResponse ensureOutrightEvent() => $_ensure(6);

  @$pb.TagNumber(8)
  BetSlipStatusResponse get betSlipStatus => $_getN(7);
  @$pb.TagNumber(8)
  set betSlipStatus(BetSlipStatusResponse value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasBetSlipStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearBetSlipStatus() => $_clearField(8);
  @$pb.TagNumber(8)
  BetSlipStatusResponse ensureBetSlipStatus() => $_ensure(7);

  @$pb.TagNumber(9)
  PopularLeaguesResponse get popularLeagues => $_getN(8);
  @$pb.TagNumber(9)
  set popularLeagues(PopularLeaguesResponse value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasPopularLeagues() => $_has(8);
  @$pb.TagNumber(9)
  void clearPopularLeagues() => $_clearField(9);
  @$pb.TagNumber(9)
  PopularLeaguesResponse ensurePopularLeagues() => $_ensure(8);
}

class LeagueResponse extends $pb.GeneratedMessage {
  factory LeagueResponse({
    $core.Iterable<EventResponse>? events,
    $core.int? sportId,
    $core.String? sportName,
    $core.int? leagueId,
    $core.String? leagueName,
    $core.String? leagueNameEn,
    $core.String? leagueLogo,
    $core.int? leagueOrder,
    $core.int? leaguePriorityOrder,
    $core.int? type,
    $core.bool? isParlay,
    $core.bool? isCashOut,
    $core.bool? isPin,
    $core.String? sportType,
    $core.int? sportTypeId,
  }) {
    final result = create();
    if (events != null) result.events.addAll(events);
    if (sportId != null) result.sportId = sportId;
    if (sportName != null) result.sportName = sportName;
    if (leagueId != null) result.leagueId = leagueId;
    if (leagueName != null) result.leagueName = leagueName;
    if (leagueNameEn != null) result.leagueNameEn = leagueNameEn;
    if (leagueLogo != null) result.leagueLogo = leagueLogo;
    if (leagueOrder != null) result.leagueOrder = leagueOrder;
    if (leaguePriorityOrder != null)
      result.leaguePriorityOrder = leaguePriorityOrder;
    if (type != null) result.type = type;
    if (isParlay != null) result.isParlay = isParlay;
    if (isCashOut != null) result.isCashOut = isCashOut;
    if (isPin != null) result.isPin = isPin;
    if (sportType != null) result.sportType = sportType;
    if (sportTypeId != null) result.sportTypeId = sportTypeId;
    return result;
  }

  LeagueResponse._();

  factory LeagueResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeagueResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeagueResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..pPM<EventResponse>(1, _omitFieldNames ? '' : 'events',
        subBuilder: EventResponse.create)
    ..aI(2, _omitFieldNames ? '' : 'sportId')
    ..aOS(3, _omitFieldNames ? '' : 'sportName')
    ..aI(4, _omitFieldNames ? '' : 'leagueId')
    ..aOS(5, _omitFieldNames ? '' : 'leagueName')
    ..aOS(6, _omitFieldNames ? '' : 'leagueNameEn')
    ..aOS(7, _omitFieldNames ? '' : 'leagueLogo')
    ..aI(8, _omitFieldNames ? '' : 'leagueOrder')
    ..aI(9, _omitFieldNames ? '' : 'leaguePriorityOrder')
    ..aI(10, _omitFieldNames ? '' : 'type')
    ..aOB(11, _omitFieldNames ? '' : 'isParlay')
    ..aOB(12, _omitFieldNames ? '' : 'isCashOut')
    ..aOB(13, _omitFieldNames ? '' : 'isPin')
    ..aOS(14, _omitFieldNames ? '' : 'sportType')
    ..aI(15, _omitFieldNames ? '' : 'sportTypeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeagueResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeagueResponse copyWith(void Function(LeagueResponse) updates) =>
      super.copyWith((message) => updates(message as LeagueResponse))
          as LeagueResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeagueResponse create() => LeagueResponse._();
  @$core.override
  LeagueResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeagueResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeagueResponse>(create);
  static LeagueResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<EventResponse> get events => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get sportId => $_getIZ(1);
  @$pb.TagNumber(2)
  set sportId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSportId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSportId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sportName => $_getSZ(2);
  @$pb.TagNumber(3)
  set sportName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSportName() => $_has(2);
  @$pb.TagNumber(3)
  void clearSportName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get leagueId => $_getIZ(3);
  @$pb.TagNumber(4)
  set leagueId($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLeagueId() => $_has(3);
  @$pb.TagNumber(4)
  void clearLeagueId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get leagueName => $_getSZ(4);
  @$pb.TagNumber(5)
  set leagueName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLeagueName() => $_has(4);
  @$pb.TagNumber(5)
  void clearLeagueName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get leagueNameEn => $_getSZ(5);
  @$pb.TagNumber(6)
  set leagueNameEn($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLeagueNameEn() => $_has(5);
  @$pb.TagNumber(6)
  void clearLeagueNameEn() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get leagueLogo => $_getSZ(6);
  @$pb.TagNumber(7)
  set leagueLogo($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLeagueLogo() => $_has(6);
  @$pb.TagNumber(7)
  void clearLeagueLogo() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get leagueOrder => $_getIZ(7);
  @$pb.TagNumber(8)
  set leagueOrder($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLeagueOrder() => $_has(7);
  @$pb.TagNumber(8)
  void clearLeagueOrder() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get leaguePriorityOrder => $_getIZ(8);
  @$pb.TagNumber(9)
  set leaguePriorityOrder($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLeaguePriorityOrder() => $_has(8);
  @$pb.TagNumber(9)
  void clearLeaguePriorityOrder() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get type => $_getIZ(9);
  @$pb.TagNumber(10)
  set type($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasType() => $_has(9);
  @$pb.TagNumber(10)
  void clearType() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get isParlay => $_getBF(10);
  @$pb.TagNumber(11)
  set isParlay($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasIsParlay() => $_has(10);
  @$pb.TagNumber(11)
  void clearIsParlay() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get isCashOut => $_getBF(11);
  @$pb.TagNumber(12)
  set isCashOut($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasIsCashOut() => $_has(11);
  @$pb.TagNumber(12)
  void clearIsCashOut() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get isPin => $_getBF(12);
  @$pb.TagNumber(13)
  set isPin($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasIsPin() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsPin() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get sportType => $_getSZ(13);
  @$pb.TagNumber(14)
  set sportType($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSportType() => $_has(13);
  @$pb.TagNumber(14)
  void clearSportType() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get sportTypeId => $_getIZ(14);
  @$pb.TagNumber(15)
  set sportTypeId($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasSportTypeId() => $_has(14);
  @$pb.TagNumber(15)
  void clearSportTypeId() => $_clearField(15);
}

class EventResponse extends $pb.GeneratedMessage {
  factory EventResponse({
    $core.Iterable<EventResponse>? children,
    $core.Iterable<MarketResponse>? markets,
    $core.int? sportId,
    $core.int? leagueId,
    $fixnum.Int64? eventId,
    $core.String? startDate,
    $fixnum.Int64? startTime,
    $core.bool? isSuspended,
    $core.bool? isHidden,
    $core.bool? isParlay,
    $core.bool? isCashOut,
    $core.int? type,
    $core.int? pinType,
    $core.String? specialSituation,
    $fixnum.Int64? eventStatsId,
    $core.int? sportTypeId,
    $core.String? sportTypeName,
    $core.int? homeId,
    $core.int? awayId,
    $core.String? homeName,
    $core.String? awayName,
    $core.String? homeLogo,
    $core.String? awayLogo,
    $core.int? marketCount,
    $core.Iterable<$core.int>? marketGroups,
    $core.Iterable<$core.int>? timeMarketGroups,
    $core.bool? isHot,
    $core.bool? isGoingLive,
    $core.bool? isLive,
    $core.bool? isLiveStream,
    $core.int? gamePart,
    $core.int? gameTime,
    $core.int? stoppageTime,
    ScoreResponse? liveScore,
    $core.int? childType,
  }) {
    final result = create();
    if (children != null) result.children.addAll(children);
    if (markets != null) result.markets.addAll(markets);
    if (sportId != null) result.sportId = sportId;
    if (leagueId != null) result.leagueId = leagueId;
    if (eventId != null) result.eventId = eventId;
    if (startDate != null) result.startDate = startDate;
    if (startTime != null) result.startTime = startTime;
    if (isSuspended != null) result.isSuspended = isSuspended;
    if (isHidden != null) result.isHidden = isHidden;
    if (isParlay != null) result.isParlay = isParlay;
    if (isCashOut != null) result.isCashOut = isCashOut;
    if (type != null) result.type = type;
    if (pinType != null) result.pinType = pinType;
    if (specialSituation != null) result.specialSituation = specialSituation;
    if (eventStatsId != null) result.eventStatsId = eventStatsId;
    if (sportTypeId != null) result.sportTypeId = sportTypeId;
    if (sportTypeName != null) result.sportTypeName = sportTypeName;
    if (homeId != null) result.homeId = homeId;
    if (awayId != null) result.awayId = awayId;
    if (homeName != null) result.homeName = homeName;
    if (awayName != null) result.awayName = awayName;
    if (homeLogo != null) result.homeLogo = homeLogo;
    if (awayLogo != null) result.awayLogo = awayLogo;
    if (marketCount != null) result.marketCount = marketCount;
    if (marketGroups != null) result.marketGroups.addAll(marketGroups);
    if (timeMarketGroups != null)
      result.timeMarketGroups.addAll(timeMarketGroups);
    if (isHot != null) result.isHot = isHot;
    if (isGoingLive != null) result.isGoingLive = isGoingLive;
    if (isLive != null) result.isLive = isLive;
    if (isLiveStream != null) result.isLiveStream = isLiveStream;
    if (gamePart != null) result.gamePart = gamePart;
    if (gameTime != null) result.gameTime = gameTime;
    if (stoppageTime != null) result.stoppageTime = stoppageTime;
    if (liveScore != null) result.liveScore = liveScore;
    if (childType != null) result.childType = childType;
    return result;
  }

  EventResponse._();

  factory EventResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EventResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EventResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..pPM<EventResponse>(1, _omitFieldNames ? '' : 'children',
        subBuilder: EventResponse.create)
    ..pPM<MarketResponse>(2, _omitFieldNames ? '' : 'markets',
        subBuilder: MarketResponse.create)
    ..aI(3, _omitFieldNames ? '' : 'sportId')
    ..aI(4, _omitFieldNames ? '' : 'leagueId')
    ..aInt64(5, _omitFieldNames ? '' : 'eventId')
    ..aOS(6, _omitFieldNames ? '' : 'startDate')
    ..aInt64(7, _omitFieldNames ? '' : 'startTime')
    ..aOB(8, _omitFieldNames ? '' : 'isSuspended')
    ..aOB(9, _omitFieldNames ? '' : 'isHidden')
    ..aOB(10, _omitFieldNames ? '' : 'isParlay')
    ..aOB(11, _omitFieldNames ? '' : 'isCashOut')
    ..aI(12, _omitFieldNames ? '' : 'type')
    ..aI(13, _omitFieldNames ? '' : 'pinType')
    ..aOS(14, _omitFieldNames ? '' : 'specialSituation')
    ..aInt64(15, _omitFieldNames ? '' : 'eventStatsId')
    ..aI(16, _omitFieldNames ? '' : 'sportTypeId')
    ..aOS(17, _omitFieldNames ? '' : 'sportTypeName')
    ..aI(18, _omitFieldNames ? '' : 'homeId')
    ..aI(19, _omitFieldNames ? '' : 'awayId')
    ..aOS(20, _omitFieldNames ? '' : 'homeName')
    ..aOS(21, _omitFieldNames ? '' : 'awayName')
    ..aOS(22, _omitFieldNames ? '' : 'homeLogo')
    ..aOS(23, _omitFieldNames ? '' : 'awayLogo')
    ..aI(24, _omitFieldNames ? '' : 'marketCount')
    ..p<$core.int>(
        25, _omitFieldNames ? '' : 'marketGroups', $pb.PbFieldType.K3)
    ..p<$core.int>(
        26, _omitFieldNames ? '' : 'timeMarketGroups', $pb.PbFieldType.K3)
    ..aOB(27, _omitFieldNames ? '' : 'isHot')
    ..aOB(28, _omitFieldNames ? '' : 'isGoingLive')
    ..aOB(29, _omitFieldNames ? '' : 'isLive')
    ..aOB(30, _omitFieldNames ? '' : 'isLiveStream')
    ..aI(31, _omitFieldNames ? '' : 'gamePart')
    ..aI(32, _omitFieldNames ? '' : 'gameTime')
    ..aI(33, _omitFieldNames ? '' : 'stoppageTime')
    ..aOM<ScoreResponse>(34, _omitFieldNames ? '' : 'liveScore',
        subBuilder: ScoreResponse.create)
    ..aI(35, _omitFieldNames ? '' : 'childType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventResponse copyWith(void Function(EventResponse) updates) =>
      super.copyWith((message) => updates(message as EventResponse))
          as EventResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EventResponse create() => EventResponse._();
  @$core.override
  EventResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EventResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EventResponse>(create);
  static EventResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<EventResponse> get children => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<MarketResponse> get markets => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get sportId => $_getIZ(2);
  @$pb.TagNumber(3)
  set sportId($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSportId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSportId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get leagueId => $_getIZ(3);
  @$pb.TagNumber(4)
  set leagueId($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLeagueId() => $_has(3);
  @$pb.TagNumber(4)
  void clearLeagueId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get eventId => $_getI64(4);
  @$pb.TagNumber(5)
  set eventId($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEventId() => $_has(4);
  @$pb.TagNumber(5)
  void clearEventId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get startDate => $_getSZ(5);
  @$pb.TagNumber(6)
  set startDate($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStartDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearStartDate() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get startTime => $_getI64(6);
  @$pb.TagNumber(7)
  set startTime($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStartTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isSuspended => $_getBF(7);
  @$pb.TagNumber(8)
  set isSuspended($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsSuspended() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsSuspended() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isHidden => $_getBF(8);
  @$pb.TagNumber(9)
  set isHidden($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIsHidden() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsHidden() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isParlay => $_getBF(9);
  @$pb.TagNumber(10)
  set isParlay($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIsParlay() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsParlay() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get isCashOut => $_getBF(10);
  @$pb.TagNumber(11)
  set isCashOut($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasIsCashOut() => $_has(10);
  @$pb.TagNumber(11)
  void clearIsCashOut() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get type => $_getIZ(11);
  @$pb.TagNumber(12)
  set type($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasType() => $_has(11);
  @$pb.TagNumber(12)
  void clearType() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get pinType => $_getIZ(12);
  @$pb.TagNumber(13)
  set pinType($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasPinType() => $_has(12);
  @$pb.TagNumber(13)
  void clearPinType() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get specialSituation => $_getSZ(13);
  @$pb.TagNumber(14)
  set specialSituation($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSpecialSituation() => $_has(13);
  @$pb.TagNumber(14)
  void clearSpecialSituation() => $_clearField(14);

  @$pb.TagNumber(15)
  $fixnum.Int64 get eventStatsId => $_getI64(14);
  @$pb.TagNumber(15)
  set eventStatsId($fixnum.Int64 value) => $_setInt64(14, value);
  @$pb.TagNumber(15)
  $core.bool hasEventStatsId() => $_has(14);
  @$pb.TagNumber(15)
  void clearEventStatsId() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get sportTypeId => $_getIZ(15);
  @$pb.TagNumber(16)
  set sportTypeId($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasSportTypeId() => $_has(15);
  @$pb.TagNumber(16)
  void clearSportTypeId() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get sportTypeName => $_getSZ(16);
  @$pb.TagNumber(17)
  set sportTypeName($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasSportTypeName() => $_has(16);
  @$pb.TagNumber(17)
  void clearSportTypeName() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.int get homeId => $_getIZ(17);
  @$pb.TagNumber(18)
  set homeId($core.int value) => $_setSignedInt32(17, value);
  @$pb.TagNumber(18)
  $core.bool hasHomeId() => $_has(17);
  @$pb.TagNumber(18)
  void clearHomeId() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.int get awayId => $_getIZ(18);
  @$pb.TagNumber(19)
  set awayId($core.int value) => $_setSignedInt32(18, value);
  @$pb.TagNumber(19)
  $core.bool hasAwayId() => $_has(18);
  @$pb.TagNumber(19)
  void clearAwayId() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get homeName => $_getSZ(19);
  @$pb.TagNumber(20)
  set homeName($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasHomeName() => $_has(19);
  @$pb.TagNumber(20)
  void clearHomeName() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.String get awayName => $_getSZ(20);
  @$pb.TagNumber(21)
  set awayName($core.String value) => $_setString(20, value);
  @$pb.TagNumber(21)
  $core.bool hasAwayName() => $_has(20);
  @$pb.TagNumber(21)
  void clearAwayName() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get homeLogo => $_getSZ(21);
  @$pb.TagNumber(22)
  set homeLogo($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasHomeLogo() => $_has(21);
  @$pb.TagNumber(22)
  void clearHomeLogo() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.String get awayLogo => $_getSZ(22);
  @$pb.TagNumber(23)
  set awayLogo($core.String value) => $_setString(22, value);
  @$pb.TagNumber(23)
  $core.bool hasAwayLogo() => $_has(22);
  @$pb.TagNumber(23)
  void clearAwayLogo() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.int get marketCount => $_getIZ(23);
  @$pb.TagNumber(24)
  set marketCount($core.int value) => $_setSignedInt32(23, value);
  @$pb.TagNumber(24)
  $core.bool hasMarketCount() => $_has(23);
  @$pb.TagNumber(24)
  void clearMarketCount() => $_clearField(24);

  @$pb.TagNumber(25)
  $pb.PbList<$core.int> get marketGroups => $_getList(24);

  @$pb.TagNumber(26)
  $pb.PbList<$core.int> get timeMarketGroups => $_getList(25);

  @$pb.TagNumber(27)
  $core.bool get isHot => $_getBF(26);
  @$pb.TagNumber(27)
  set isHot($core.bool value) => $_setBool(26, value);
  @$pb.TagNumber(27)
  $core.bool hasIsHot() => $_has(26);
  @$pb.TagNumber(27)
  void clearIsHot() => $_clearField(27);

  @$pb.TagNumber(28)
  $core.bool get isGoingLive => $_getBF(27);
  @$pb.TagNumber(28)
  set isGoingLive($core.bool value) => $_setBool(27, value);
  @$pb.TagNumber(28)
  $core.bool hasIsGoingLive() => $_has(27);
  @$pb.TagNumber(28)
  void clearIsGoingLive() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.bool get isLive => $_getBF(28);
  @$pb.TagNumber(29)
  set isLive($core.bool value) => $_setBool(28, value);
  @$pb.TagNumber(29)
  $core.bool hasIsLive() => $_has(28);
  @$pb.TagNumber(29)
  void clearIsLive() => $_clearField(29);

  @$pb.TagNumber(30)
  $core.bool get isLiveStream => $_getBF(29);
  @$pb.TagNumber(30)
  set isLiveStream($core.bool value) => $_setBool(29, value);
  @$pb.TagNumber(30)
  $core.bool hasIsLiveStream() => $_has(29);
  @$pb.TagNumber(30)
  void clearIsLiveStream() => $_clearField(30);

  @$pb.TagNumber(31)
  $core.int get gamePart => $_getIZ(30);
  @$pb.TagNumber(31)
  set gamePart($core.int value) => $_setSignedInt32(30, value);
  @$pb.TagNumber(31)
  $core.bool hasGamePart() => $_has(30);
  @$pb.TagNumber(31)
  void clearGamePart() => $_clearField(31);

  @$pb.TagNumber(32)
  $core.int get gameTime => $_getIZ(31);
  @$pb.TagNumber(32)
  set gameTime($core.int value) => $_setSignedInt32(31, value);
  @$pb.TagNumber(32)
  $core.bool hasGameTime() => $_has(31);
  @$pb.TagNumber(32)
  void clearGameTime() => $_clearField(32);

  @$pb.TagNumber(33)
  $core.int get stoppageTime => $_getIZ(32);
  @$pb.TagNumber(33)
  set stoppageTime($core.int value) => $_setSignedInt32(32, value);
  @$pb.TagNumber(33)
  $core.bool hasStoppageTime() => $_has(32);
  @$pb.TagNumber(33)
  void clearStoppageTime() => $_clearField(33);

  @$pb.TagNumber(34)
  ScoreResponse get liveScore => $_getN(33);
  @$pb.TagNumber(34)
  set liveScore(ScoreResponse value) => $_setField(34, value);
  @$pb.TagNumber(34)
  $core.bool hasLiveScore() => $_has(33);
  @$pb.TagNumber(34)
  void clearLiveScore() => $_clearField(34);
  @$pb.TagNumber(34)
  ScoreResponse ensureLiveScore() => $_ensure(33);

  @$pb.TagNumber(35)
  $core.int get childType => $_getIZ(34);
  @$pb.TagNumber(35)
  set childType($core.int value) => $_setSignedInt32(34, value);
  @$pb.TagNumber(35)
  $core.bool hasChildType() => $_has(34);
  @$pb.TagNumber(35)
  void clearChildType() => $_clearField(35);
}

enum ScoreResponse_Data {
  soccer,
  basketball,
  volleyball,
  tennis,
  tableTennis,
  badminton,
  notSet
}

class ScoreResponse extends $pb.GeneratedMessage {
  factory ScoreResponse({
    SoccerScoreResponse? soccer,
    BasketballScoreResponse? basketball,
    VolleyballScoreResponse? volleyball,
    TennisScoreResponse? tennis,
    TableTennisScoreResponse? tableTennis,
    BadmintonScoreResponse? badminton,
  }) {
    final result = create();
    if (soccer != null) result.soccer = soccer;
    if (basketball != null) result.basketball = basketball;
    if (volleyball != null) result.volleyball = volleyball;
    if (tennis != null) result.tennis = tennis;
    if (tableTennis != null) result.tableTennis = tableTennis;
    if (badminton != null) result.badminton = badminton;
    return result;
  }

  ScoreResponse._();

  factory ScoreResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScoreResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ScoreResponse_Data>
      _ScoreResponse_DataByTag = {
    1: ScoreResponse_Data.soccer,
    2: ScoreResponse_Data.basketball,
    3: ScoreResponse_Data.volleyball,
    4: ScoreResponse_Data.tennis,
    5: ScoreResponse_Data.tableTennis,
    6: ScoreResponse_Data.badminton,
    0: ScoreResponse_Data.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScoreResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6])
    ..aOM<SoccerScoreResponse>(1, _omitFieldNames ? '' : 'soccer',
        subBuilder: SoccerScoreResponse.create)
    ..aOM<BasketballScoreResponse>(2, _omitFieldNames ? '' : 'basketball',
        subBuilder: BasketballScoreResponse.create)
    ..aOM<VolleyballScoreResponse>(3, _omitFieldNames ? '' : 'volleyball',
        subBuilder: VolleyballScoreResponse.create)
    ..aOM<TennisScoreResponse>(4, _omitFieldNames ? '' : 'tennis',
        subBuilder: TennisScoreResponse.create)
    ..aOM<TableTennisScoreResponse>(5, _omitFieldNames ? '' : 'tableTennis',
        subBuilder: TableTennisScoreResponse.create)
    ..aOM<BadmintonScoreResponse>(6, _omitFieldNames ? '' : 'badminton',
        subBuilder: BadmintonScoreResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScoreResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScoreResponse copyWith(void Function(ScoreResponse) updates) =>
      super.copyWith((message) => updates(message as ScoreResponse))
          as ScoreResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScoreResponse create() => ScoreResponse._();
  @$core.override
  ScoreResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScoreResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScoreResponse>(create);
  static ScoreResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  ScoreResponse_Data whichData() => _ScoreResponse_DataByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  void clearData() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SoccerScoreResponse get soccer => $_getN(0);
  @$pb.TagNumber(1)
  set soccer(SoccerScoreResponse value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSoccer() => $_has(0);
  @$pb.TagNumber(1)
  void clearSoccer() => $_clearField(1);
  @$pb.TagNumber(1)
  SoccerScoreResponse ensureSoccer() => $_ensure(0);

  @$pb.TagNumber(2)
  BasketballScoreResponse get basketball => $_getN(1);
  @$pb.TagNumber(2)
  set basketball(BasketballScoreResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBasketball() => $_has(1);
  @$pb.TagNumber(2)
  void clearBasketball() => $_clearField(2);
  @$pb.TagNumber(2)
  BasketballScoreResponse ensureBasketball() => $_ensure(1);

  @$pb.TagNumber(3)
  VolleyballScoreResponse get volleyball => $_getN(2);
  @$pb.TagNumber(3)
  set volleyball(VolleyballScoreResponse value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasVolleyball() => $_has(2);
  @$pb.TagNumber(3)
  void clearVolleyball() => $_clearField(3);
  @$pb.TagNumber(3)
  VolleyballScoreResponse ensureVolleyball() => $_ensure(2);

  @$pb.TagNumber(4)
  TennisScoreResponse get tennis => $_getN(3);
  @$pb.TagNumber(4)
  set tennis(TennisScoreResponse value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTennis() => $_has(3);
  @$pb.TagNumber(4)
  void clearTennis() => $_clearField(4);
  @$pb.TagNumber(4)
  TennisScoreResponse ensureTennis() => $_ensure(3);

  @$pb.TagNumber(5)
  TableTennisScoreResponse get tableTennis => $_getN(4);
  @$pb.TagNumber(5)
  set tableTennis(TableTennisScoreResponse value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasTableTennis() => $_has(4);
  @$pb.TagNumber(5)
  void clearTableTennis() => $_clearField(5);
  @$pb.TagNumber(5)
  TableTennisScoreResponse ensureTableTennis() => $_ensure(4);

  @$pb.TagNumber(6)
  BadmintonScoreResponse get badminton => $_getN(5);
  @$pb.TagNumber(6)
  set badminton(BadmintonScoreResponse value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasBadminton() => $_has(5);
  @$pb.TagNumber(6)
  void clearBadminton() => $_clearField(6);
  @$pb.TagNumber(6)
  BadmintonScoreResponse ensureBadminton() => $_ensure(5);
}

class SoccerScoreResponse extends $pb.GeneratedMessage {
  factory SoccerScoreResponse({
    $core.int? homeScore,
    $core.int? awayScore,
    $core.int? homeScoreH2,
    $core.int? awayScoreH2,
    $core.int? homeCorner,
    $core.int? awayCorner,
    $core.int? homeScoreOT,
    $core.int? awayScoreOT,
    $core.int? homeScorePen,
    $core.int? awayScorePen,
    $core.int? yellowCardsHome,
    $core.int? yellowCardsAway,
    $core.int? redCardsHome,
    $core.int? redCardsAway,
  }) {
    final result = create();
    if (homeScore != null) result.homeScore = homeScore;
    if (awayScore != null) result.awayScore = awayScore;
    if (homeScoreH2 != null) result.homeScoreH2 = homeScoreH2;
    if (awayScoreH2 != null) result.awayScoreH2 = awayScoreH2;
    if (homeCorner != null) result.homeCorner = homeCorner;
    if (awayCorner != null) result.awayCorner = awayCorner;
    if (homeScoreOT != null) result.homeScoreOT = homeScoreOT;
    if (awayScoreOT != null) result.awayScoreOT = awayScoreOT;
    if (homeScorePen != null) result.homeScorePen = homeScorePen;
    if (awayScorePen != null) result.awayScorePen = awayScorePen;
    if (yellowCardsHome != null) result.yellowCardsHome = yellowCardsHome;
    if (yellowCardsAway != null) result.yellowCardsAway = yellowCardsAway;
    if (redCardsHome != null) result.redCardsHome = redCardsHome;
    if (redCardsAway != null) result.redCardsAway = redCardsAway;
    return result;
  }

  SoccerScoreResponse._();

  factory SoccerScoreResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SoccerScoreResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SoccerScoreResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'homeScore')
    ..aI(2, _omitFieldNames ? '' : 'awayScore')
    ..aI(3, _omitFieldNames ? '' : 'homeScoreH2')
    ..aI(4, _omitFieldNames ? '' : 'awayScoreH2')
    ..aI(5, _omitFieldNames ? '' : 'homeCorner')
    ..aI(6, _omitFieldNames ? '' : 'awayCorner')
    ..aI(7, _omitFieldNames ? '' : 'homeScoreOT')
    ..aI(8, _omitFieldNames ? '' : 'awayScoreOT')
    ..aI(9, _omitFieldNames ? '' : 'homeScorePen')
    ..aI(10, _omitFieldNames ? '' : 'awayScorePen')
    ..aI(11, _omitFieldNames ? '' : 'yellowCardsHome')
    ..aI(12, _omitFieldNames ? '' : 'yellowCardsAway')
    ..aI(13, _omitFieldNames ? '' : 'redCardsHome')
    ..aI(14, _omitFieldNames ? '' : 'redCardsAway')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoccerScoreResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoccerScoreResponse copyWith(void Function(SoccerScoreResponse) updates) =>
      super.copyWith((message) => updates(message as SoccerScoreResponse))
          as SoccerScoreResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SoccerScoreResponse create() => SoccerScoreResponse._();
  @$core.override
  SoccerScoreResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SoccerScoreResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SoccerScoreResponse>(create);
  static SoccerScoreResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get homeScore => $_getIZ(0);
  @$pb.TagNumber(1)
  set homeScore($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHomeScore() => $_has(0);
  @$pb.TagNumber(1)
  void clearHomeScore() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get awayScore => $_getIZ(1);
  @$pb.TagNumber(2)
  set awayScore($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAwayScore() => $_has(1);
  @$pb.TagNumber(2)
  void clearAwayScore() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get homeScoreH2 => $_getIZ(2);
  @$pb.TagNumber(3)
  set homeScoreH2($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHomeScoreH2() => $_has(2);
  @$pb.TagNumber(3)
  void clearHomeScoreH2() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get awayScoreH2 => $_getIZ(3);
  @$pb.TagNumber(4)
  set awayScoreH2($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAwayScoreH2() => $_has(3);
  @$pb.TagNumber(4)
  void clearAwayScoreH2() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get homeCorner => $_getIZ(4);
  @$pb.TagNumber(5)
  set homeCorner($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHomeCorner() => $_has(4);
  @$pb.TagNumber(5)
  void clearHomeCorner() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get awayCorner => $_getIZ(5);
  @$pb.TagNumber(6)
  set awayCorner($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAwayCorner() => $_has(5);
  @$pb.TagNumber(6)
  void clearAwayCorner() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get homeScoreOT => $_getIZ(6);
  @$pb.TagNumber(7)
  set homeScoreOT($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHomeScoreOT() => $_has(6);
  @$pb.TagNumber(7)
  void clearHomeScoreOT() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get awayScoreOT => $_getIZ(7);
  @$pb.TagNumber(8)
  set awayScoreOT($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAwayScoreOT() => $_has(7);
  @$pb.TagNumber(8)
  void clearAwayScoreOT() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get homeScorePen => $_getIZ(8);
  @$pb.TagNumber(9)
  set homeScorePen($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasHomeScorePen() => $_has(8);
  @$pb.TagNumber(9)
  void clearHomeScorePen() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get awayScorePen => $_getIZ(9);
  @$pb.TagNumber(10)
  set awayScorePen($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasAwayScorePen() => $_has(9);
  @$pb.TagNumber(10)
  void clearAwayScorePen() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get yellowCardsHome => $_getIZ(10);
  @$pb.TagNumber(11)
  set yellowCardsHome($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasYellowCardsHome() => $_has(10);
  @$pb.TagNumber(11)
  void clearYellowCardsHome() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get yellowCardsAway => $_getIZ(11);
  @$pb.TagNumber(12)
  set yellowCardsAway($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasYellowCardsAway() => $_has(11);
  @$pb.TagNumber(12)
  void clearYellowCardsAway() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get redCardsHome => $_getIZ(12);
  @$pb.TagNumber(13)
  set redCardsHome($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasRedCardsHome() => $_has(12);
  @$pb.TagNumber(13)
  void clearRedCardsHome() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get redCardsAway => $_getIZ(13);
  @$pb.TagNumber(14)
  set redCardsAway($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasRedCardsAway() => $_has(13);
  @$pb.TagNumber(14)
  void clearRedCardsAway() => $_clearField(14);
}

class LiveScore extends $pb.GeneratedMessage {
  factory LiveScore({
    $core.String? homeScore,
    $core.String? awayScore,
  }) {
    final result = create();
    if (homeScore != null) result.homeScore = homeScore;
    if (awayScore != null) result.awayScore = awayScore;
    return result;
  }

  LiveScore._();

  factory LiveScore.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LiveScore.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LiveScore',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'homeScore')
    ..aOS(2, _omitFieldNames ? '' : 'awayScore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LiveScore clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LiveScore copyWith(void Function(LiveScore) updates) =>
      super.copyWith((message) => updates(message as LiveScore)) as LiveScore;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LiveScore create() => LiveScore._();
  @$core.override
  LiveScore createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LiveScore getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LiveScore>(create);
  static LiveScore? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get homeScore => $_getSZ(0);
  @$pb.TagNumber(1)
  set homeScore($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHomeScore() => $_has(0);
  @$pb.TagNumber(1)
  void clearHomeScore() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get awayScore => $_getSZ(1);
  @$pb.TagNumber(2)
  set awayScore($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAwayScore() => $_has(1);
  @$pb.TagNumber(2)
  void clearAwayScore() => $_clearField(2);
}

class BasketballScoreResponse extends $pb.GeneratedMessage {
  factory BasketballScoreResponse({
    $core.Iterable<LiveScore>? liveScores,
    $core.int? homeScoreFT,
    $core.int? awayScoreFT,
    $core.int? homeScoreOT,
    $core.int? awayScoreOT,
  }) {
    final result = create();
    if (liveScores != null) result.liveScores.addAll(liveScores);
    if (homeScoreFT != null) result.homeScoreFT = homeScoreFT;
    if (awayScoreFT != null) result.awayScoreFT = awayScoreFT;
    if (homeScoreOT != null) result.homeScoreOT = homeScoreOT;
    if (awayScoreOT != null) result.awayScoreOT = awayScoreOT;
    return result;
  }

  BasketballScoreResponse._();

  factory BasketballScoreResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BasketballScoreResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BasketballScoreResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..pPM<LiveScore>(1, _omitFieldNames ? '' : 'liveScores',
        subBuilder: LiveScore.create)
    ..aI(2, _omitFieldNames ? '' : 'homeScoreFT')
    ..aI(3, _omitFieldNames ? '' : 'awayScoreFT')
    ..aI(4, _omitFieldNames ? '' : 'homeScoreOT')
    ..aI(5, _omitFieldNames ? '' : 'awayScoreOT')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BasketballScoreResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BasketballScoreResponse copyWith(
          void Function(BasketballScoreResponse) updates) =>
      super.copyWith((message) => updates(message as BasketballScoreResponse))
          as BasketballScoreResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BasketballScoreResponse create() => BasketballScoreResponse._();
  @$core.override
  BasketballScoreResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BasketballScoreResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BasketballScoreResponse>(create);
  static BasketballScoreResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LiveScore> get liveScores => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get homeScoreFT => $_getIZ(1);
  @$pb.TagNumber(2)
  set homeScoreFT($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHomeScoreFT() => $_has(1);
  @$pb.TagNumber(2)
  void clearHomeScoreFT() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get awayScoreFT => $_getIZ(2);
  @$pb.TagNumber(3)
  set awayScoreFT($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAwayScoreFT() => $_has(2);
  @$pb.TagNumber(3)
  void clearAwayScoreFT() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get homeScoreOT => $_getIZ(3);
  @$pb.TagNumber(4)
  set homeScoreOT($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHomeScoreOT() => $_has(3);
  @$pb.TagNumber(4)
  void clearHomeScoreOT() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get awayScoreOT => $_getIZ(4);
  @$pb.TagNumber(5)
  set awayScoreOT($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAwayScoreOT() => $_has(4);
  @$pb.TagNumber(5)
  void clearAwayScoreOT() => $_clearField(5);
}

class VolleyballScoreResponse extends $pb.GeneratedMessage {
  factory VolleyballScoreResponse({
    $core.Iterable<LiveScore>? liveScores,
    $core.int? homeSetScore,
    $core.int? awaySetScore,
    $core.int? homeTotalPoint,
    $core.int? awayTotalPoint,
    $core.String? servingSide,
    $core.int? currentSet,
    $core.String? numOfSets,
  }) {
    final result = create();
    if (liveScores != null) result.liveScores.addAll(liveScores);
    if (homeSetScore != null) result.homeSetScore = homeSetScore;
    if (awaySetScore != null) result.awaySetScore = awaySetScore;
    if (homeTotalPoint != null) result.homeTotalPoint = homeTotalPoint;
    if (awayTotalPoint != null) result.awayTotalPoint = awayTotalPoint;
    if (servingSide != null) result.servingSide = servingSide;
    if (currentSet != null) result.currentSet = currentSet;
    if (numOfSets != null) result.numOfSets = numOfSets;
    return result;
  }

  VolleyballScoreResponse._();

  factory VolleyballScoreResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VolleyballScoreResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VolleyballScoreResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..pPM<LiveScore>(1, _omitFieldNames ? '' : 'liveScores',
        subBuilder: LiveScore.create)
    ..aI(2, _omitFieldNames ? '' : 'homeSetScore')
    ..aI(3, _omitFieldNames ? '' : 'awaySetScore')
    ..aI(4, _omitFieldNames ? '' : 'homeTotalPoint')
    ..aI(5, _omitFieldNames ? '' : 'awayTotalPoint')
    ..aOS(6, _omitFieldNames ? '' : 'servingSide')
    ..aI(7, _omitFieldNames ? '' : 'currentSet')
    ..aOS(8, _omitFieldNames ? '' : 'numOfSets')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VolleyballScoreResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VolleyballScoreResponse copyWith(
          void Function(VolleyballScoreResponse) updates) =>
      super.copyWith((message) => updates(message as VolleyballScoreResponse))
          as VolleyballScoreResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VolleyballScoreResponse create() => VolleyballScoreResponse._();
  @$core.override
  VolleyballScoreResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VolleyballScoreResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VolleyballScoreResponse>(create);
  static VolleyballScoreResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LiveScore> get liveScores => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get homeSetScore => $_getIZ(1);
  @$pb.TagNumber(2)
  set homeSetScore($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHomeSetScore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHomeSetScore() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get awaySetScore => $_getIZ(2);
  @$pb.TagNumber(3)
  set awaySetScore($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAwaySetScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearAwaySetScore() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get homeTotalPoint => $_getIZ(3);
  @$pb.TagNumber(4)
  set homeTotalPoint($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHomeTotalPoint() => $_has(3);
  @$pb.TagNumber(4)
  void clearHomeTotalPoint() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get awayTotalPoint => $_getIZ(4);
  @$pb.TagNumber(5)
  set awayTotalPoint($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAwayTotalPoint() => $_has(4);
  @$pb.TagNumber(5)
  void clearAwayTotalPoint() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get servingSide => $_getSZ(5);
  @$pb.TagNumber(6)
  set servingSide($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasServingSide() => $_has(5);
  @$pb.TagNumber(6)
  void clearServingSide() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get currentSet => $_getIZ(6);
  @$pb.TagNumber(7)
  set currentSet($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCurrentSet() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrentSet() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get numOfSets => $_getSZ(7);
  @$pb.TagNumber(8)
  set numOfSets($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNumOfSets() => $_has(7);
  @$pb.TagNumber(8)
  void clearNumOfSets() => $_clearField(8);
}

class TennisScoreResponse extends $pb.GeneratedMessage {
  factory TennisScoreResponse({
    $core.Iterable<LiveScore>? liveScores,
    $core.int? homeSetScore,
    $core.int? awaySetScore,
    $core.int? homeGameScore,
    $core.int? awayGameScore,
    $core.String? homeCurrentPoint,
    $core.String? awayCurrentPoint,
    $core.String? servingSide,
    $core.int? currentSet,
    $core.String? numOfSets,
  }) {
    final result = create();
    if (liveScores != null) result.liveScores.addAll(liveScores);
    if (homeSetScore != null) result.homeSetScore = homeSetScore;
    if (awaySetScore != null) result.awaySetScore = awaySetScore;
    if (homeGameScore != null) result.homeGameScore = homeGameScore;
    if (awayGameScore != null) result.awayGameScore = awayGameScore;
    if (homeCurrentPoint != null) result.homeCurrentPoint = homeCurrentPoint;
    if (awayCurrentPoint != null) result.awayCurrentPoint = awayCurrentPoint;
    if (servingSide != null) result.servingSide = servingSide;
    if (currentSet != null) result.currentSet = currentSet;
    if (numOfSets != null) result.numOfSets = numOfSets;
    return result;
  }

  TennisScoreResponse._();

  factory TennisScoreResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TennisScoreResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TennisScoreResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..pPM<LiveScore>(1, _omitFieldNames ? '' : 'liveScores',
        subBuilder: LiveScore.create)
    ..aI(2, _omitFieldNames ? '' : 'homeSetScore')
    ..aI(3, _omitFieldNames ? '' : 'awaySetScore')
    ..aI(4, _omitFieldNames ? '' : 'homeGameScore')
    ..aI(5, _omitFieldNames ? '' : 'awayGameScore')
    ..aOS(6, _omitFieldNames ? '' : 'homeCurrentPoint')
    ..aOS(7, _omitFieldNames ? '' : 'awayCurrentPoint')
    ..aOS(8, _omitFieldNames ? '' : 'servingSide')
    ..aI(9, _omitFieldNames ? '' : 'currentSet')
    ..aOS(10, _omitFieldNames ? '' : 'numOfSets')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TennisScoreResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TennisScoreResponse copyWith(void Function(TennisScoreResponse) updates) =>
      super.copyWith((message) => updates(message as TennisScoreResponse))
          as TennisScoreResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TennisScoreResponse create() => TennisScoreResponse._();
  @$core.override
  TennisScoreResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TennisScoreResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TennisScoreResponse>(create);
  static TennisScoreResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LiveScore> get liveScores => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get homeSetScore => $_getIZ(1);
  @$pb.TagNumber(2)
  set homeSetScore($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHomeSetScore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHomeSetScore() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get awaySetScore => $_getIZ(2);
  @$pb.TagNumber(3)
  set awaySetScore($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAwaySetScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearAwaySetScore() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get homeGameScore => $_getIZ(3);
  @$pb.TagNumber(4)
  set homeGameScore($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHomeGameScore() => $_has(3);
  @$pb.TagNumber(4)
  void clearHomeGameScore() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get awayGameScore => $_getIZ(4);
  @$pb.TagNumber(5)
  set awayGameScore($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAwayGameScore() => $_has(4);
  @$pb.TagNumber(5)
  void clearAwayGameScore() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get homeCurrentPoint => $_getSZ(5);
  @$pb.TagNumber(6)
  set homeCurrentPoint($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHomeCurrentPoint() => $_has(5);
  @$pb.TagNumber(6)
  void clearHomeCurrentPoint() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get awayCurrentPoint => $_getSZ(6);
  @$pb.TagNumber(7)
  set awayCurrentPoint($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAwayCurrentPoint() => $_has(6);
  @$pb.TagNumber(7)
  void clearAwayCurrentPoint() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get servingSide => $_getSZ(7);
  @$pb.TagNumber(8)
  set servingSide($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasServingSide() => $_has(7);
  @$pb.TagNumber(8)
  void clearServingSide() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get currentSet => $_getIZ(8);
  @$pb.TagNumber(9)
  set currentSet($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCurrentSet() => $_has(8);
  @$pb.TagNumber(9)
  void clearCurrentSet() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get numOfSets => $_getSZ(9);
  @$pb.TagNumber(10)
  set numOfSets($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNumOfSets() => $_has(9);
  @$pb.TagNumber(10)
  void clearNumOfSets() => $_clearField(10);
}

class TableTennisScoreResponse extends $pb.GeneratedMessage {
  factory TableTennisScoreResponse({
    $core.Iterable<LiveScore>? liveScores,
    $core.int? homeSetScore,
    $core.int? awaySetScore,
    $core.int? homeTotalPoint,
    $core.int? awayTotalPoint,
    $core.String? servingSide,
    $core.int? currentSet,
    $core.String? numOfSets,
  }) {
    final result = create();
    if (liveScores != null) result.liveScores.addAll(liveScores);
    if (homeSetScore != null) result.homeSetScore = homeSetScore;
    if (awaySetScore != null) result.awaySetScore = awaySetScore;
    if (homeTotalPoint != null) result.homeTotalPoint = homeTotalPoint;
    if (awayTotalPoint != null) result.awayTotalPoint = awayTotalPoint;
    if (servingSide != null) result.servingSide = servingSide;
    if (currentSet != null) result.currentSet = currentSet;
    if (numOfSets != null) result.numOfSets = numOfSets;
    return result;
  }

  TableTennisScoreResponse._();

  factory TableTennisScoreResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TableTennisScoreResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TableTennisScoreResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..pPM<LiveScore>(1, _omitFieldNames ? '' : 'liveScores',
        subBuilder: LiveScore.create)
    ..aI(2, _omitFieldNames ? '' : 'homeSetScore')
    ..aI(3, _omitFieldNames ? '' : 'awaySetScore')
    ..aI(4, _omitFieldNames ? '' : 'homeTotalPoint')
    ..aI(5, _omitFieldNames ? '' : 'awayTotalPoint')
    ..aOS(6, _omitFieldNames ? '' : 'servingSide')
    ..aI(7, _omitFieldNames ? '' : 'currentSet')
    ..aOS(8, _omitFieldNames ? '' : 'numOfSets')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TableTennisScoreResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TableTennisScoreResponse copyWith(
          void Function(TableTennisScoreResponse) updates) =>
      super.copyWith((message) => updates(message as TableTennisScoreResponse))
          as TableTennisScoreResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TableTennisScoreResponse create() => TableTennisScoreResponse._();
  @$core.override
  TableTennisScoreResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TableTennisScoreResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TableTennisScoreResponse>(create);
  static TableTennisScoreResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LiveScore> get liveScores => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get homeSetScore => $_getIZ(1);
  @$pb.TagNumber(2)
  set homeSetScore($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHomeSetScore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHomeSetScore() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get awaySetScore => $_getIZ(2);
  @$pb.TagNumber(3)
  set awaySetScore($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAwaySetScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearAwaySetScore() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get homeTotalPoint => $_getIZ(3);
  @$pb.TagNumber(4)
  set homeTotalPoint($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHomeTotalPoint() => $_has(3);
  @$pb.TagNumber(4)
  void clearHomeTotalPoint() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get awayTotalPoint => $_getIZ(4);
  @$pb.TagNumber(5)
  set awayTotalPoint($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAwayTotalPoint() => $_has(4);
  @$pb.TagNumber(5)
  void clearAwayTotalPoint() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get servingSide => $_getSZ(5);
  @$pb.TagNumber(6)
  set servingSide($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasServingSide() => $_has(5);
  @$pb.TagNumber(6)
  void clearServingSide() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get currentSet => $_getIZ(6);
  @$pb.TagNumber(7)
  set currentSet($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCurrentSet() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrentSet() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get numOfSets => $_getSZ(7);
  @$pb.TagNumber(8)
  set numOfSets($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNumOfSets() => $_has(7);
  @$pb.TagNumber(8)
  void clearNumOfSets() => $_clearField(8);
}

class BadmintonScoreResponse extends $pb.GeneratedMessage {
  factory BadmintonScoreResponse({
    $core.Iterable<LiveScore>? liveScores,
    $core.int? homeSetScore,
    $core.int? awaySetScore,
    $core.int? homeTotalPoint,
    $core.int? awayTotalPoint,
    $core.String? servingSide,
    $core.int? currentSet,
    $core.String? numOfSets,
  }) {
    final result = create();
    if (liveScores != null) result.liveScores.addAll(liveScores);
    if (homeSetScore != null) result.homeSetScore = homeSetScore;
    if (awaySetScore != null) result.awaySetScore = awaySetScore;
    if (homeTotalPoint != null) result.homeTotalPoint = homeTotalPoint;
    if (awayTotalPoint != null) result.awayTotalPoint = awayTotalPoint;
    if (servingSide != null) result.servingSide = servingSide;
    if (currentSet != null) result.currentSet = currentSet;
    if (numOfSets != null) result.numOfSets = numOfSets;
    return result;
  }

  BadmintonScoreResponse._();

  factory BadmintonScoreResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BadmintonScoreResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BadmintonScoreResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..pPM<LiveScore>(1, _omitFieldNames ? '' : 'liveScores',
        subBuilder: LiveScore.create)
    ..aI(2, _omitFieldNames ? '' : 'homeSetScore')
    ..aI(3, _omitFieldNames ? '' : 'awaySetScore')
    ..aI(4, _omitFieldNames ? '' : 'homeTotalPoint')
    ..aI(5, _omitFieldNames ? '' : 'awayTotalPoint')
    ..aOS(6, _omitFieldNames ? '' : 'servingSide')
    ..aI(7, _omitFieldNames ? '' : 'currentSet')
    ..aOS(8, _omitFieldNames ? '' : 'numOfSets')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BadmintonScoreResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BadmintonScoreResponse copyWith(
          void Function(BadmintonScoreResponse) updates) =>
      super.copyWith((message) => updates(message as BadmintonScoreResponse))
          as BadmintonScoreResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BadmintonScoreResponse create() => BadmintonScoreResponse._();
  @$core.override
  BadmintonScoreResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BadmintonScoreResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BadmintonScoreResponse>(create);
  static BadmintonScoreResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LiveScore> get liveScores => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get homeSetScore => $_getIZ(1);
  @$pb.TagNumber(2)
  set homeSetScore($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHomeSetScore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHomeSetScore() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get awaySetScore => $_getIZ(2);
  @$pb.TagNumber(3)
  set awaySetScore($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAwaySetScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearAwaySetScore() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get homeTotalPoint => $_getIZ(3);
  @$pb.TagNumber(4)
  set homeTotalPoint($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHomeTotalPoint() => $_has(3);
  @$pb.TagNumber(4)
  void clearHomeTotalPoint() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get awayTotalPoint => $_getIZ(4);
  @$pb.TagNumber(5)
  set awayTotalPoint($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAwayTotalPoint() => $_has(4);
  @$pb.TagNumber(5)
  void clearAwayTotalPoint() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get servingSide => $_getSZ(5);
  @$pb.TagNumber(6)
  set servingSide($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasServingSide() => $_has(5);
  @$pb.TagNumber(6)
  void clearServingSide() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get currentSet => $_getIZ(6);
  @$pb.TagNumber(7)
  set currentSet($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCurrentSet() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrentSet() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get numOfSets => $_getSZ(7);
  @$pb.TagNumber(8)
  set numOfSets($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNumOfSets() => $_has(7);
  @$pb.TagNumber(8)
  void clearNumOfSets() => $_clearField(8);
}

class MarketResponse extends $pb.GeneratedMessage {
  factory MarketResponse({
    $core.Iterable<OddsResponse>? oddsList,
    $core.int? sportId,
    $core.int? leagueId,
    $fixnum.Int64? eventId,
    $core.int? marketId,
    $core.bool? isSuspended,
    $core.bool? isParlay,
    $core.bool? isCashOut,
    $core.int? promotionType,
    $core.int? groupId,
  }) {
    final result = create();
    if (oddsList != null) result.oddsList.addAll(oddsList);
    if (sportId != null) result.sportId = sportId;
    if (leagueId != null) result.leagueId = leagueId;
    if (eventId != null) result.eventId = eventId;
    if (marketId != null) result.marketId = marketId;
    if (isSuspended != null) result.isSuspended = isSuspended;
    if (isParlay != null) result.isParlay = isParlay;
    if (isCashOut != null) result.isCashOut = isCashOut;
    if (promotionType != null) result.promotionType = promotionType;
    if (groupId != null) result.groupId = groupId;
    return result;
  }

  MarketResponse._();

  factory MarketResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarketResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarketResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..pPM<OddsResponse>(1, _omitFieldNames ? '' : 'oddsList',
        protoName: 'oddsList', subBuilder: OddsResponse.create)
    ..aI(2, _omitFieldNames ? '' : 'sportId')
    ..aI(3, _omitFieldNames ? '' : 'leagueId')
    ..aInt64(4, _omitFieldNames ? '' : 'eventId')
    ..aI(5, _omitFieldNames ? '' : 'marketId')
    ..aOB(6, _omitFieldNames ? '' : 'isSuspended')
    ..aOB(7, _omitFieldNames ? '' : 'isParlay')
    ..aOB(8, _omitFieldNames ? '' : 'isCashOut')
    ..aI(9, _omitFieldNames ? '' : 'promotionType')
    ..aI(10, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketResponse copyWith(void Function(MarketResponse) updates) =>
      super.copyWith((message) => updates(message as MarketResponse))
          as MarketResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketResponse create() => MarketResponse._();
  @$core.override
  MarketResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarketResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarketResponse>(create);
  static MarketResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<OddsResponse> get oddsList => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get sportId => $_getIZ(1);
  @$pb.TagNumber(2)
  set sportId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSportId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSportId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get leagueId => $_getIZ(2);
  @$pb.TagNumber(3)
  set leagueId($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLeagueId() => $_has(2);
  @$pb.TagNumber(3)
  void clearLeagueId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get eventId => $_getI64(3);
  @$pb.TagNumber(4)
  set eventId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEventId() => $_has(3);
  @$pb.TagNumber(4)
  void clearEventId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get marketId => $_getIZ(4);
  @$pb.TagNumber(5)
  set marketId($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMarketId() => $_has(4);
  @$pb.TagNumber(5)
  void clearMarketId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isSuspended => $_getBF(5);
  @$pb.TagNumber(6)
  set isSuspended($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsSuspended() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsSuspended() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isParlay => $_getBF(6);
  @$pb.TagNumber(7)
  set isParlay($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsParlay() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsParlay() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isCashOut => $_getBF(7);
  @$pb.TagNumber(8)
  set isCashOut($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsCashOut() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsCashOut() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get promotionType => $_getIZ(8);
  @$pb.TagNumber(9)
  set promotionType($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPromotionType() => $_has(8);
  @$pb.TagNumber(9)
  void clearPromotionType() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get groupId => $_getIZ(9);
  @$pb.TagNumber(10)
  set groupId($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasGroupId() => $_has(9);
  @$pb.TagNumber(10)
  void clearGroupId() => $_clearField(10);
}

class OddsResponse extends $pb.GeneratedMessage {
  factory OddsResponse({
    $core.String? selectionHomeId,
    $core.String? selectionAwayId,
    $core.String? selectionDrawId,
    $core.String? points,
    OddsStyleResponse? oddsHome,
    OddsStyleResponse? oddsAway,
    OddsStyleResponse? oddsDraw,
    $core.String? strOfferId,
    $core.bool? isMainLine,
    $core.bool? isSuspended,
    $core.bool? isHidden,
    $core.String? playerName,
    $core.String? playerId,
    $core.int? period,
  }) {
    final result = create();
    if (selectionHomeId != null) result.selectionHomeId = selectionHomeId;
    if (selectionAwayId != null) result.selectionAwayId = selectionAwayId;
    if (selectionDrawId != null) result.selectionDrawId = selectionDrawId;
    if (points != null) result.points = points;
    if (oddsHome != null) result.oddsHome = oddsHome;
    if (oddsAway != null) result.oddsAway = oddsAway;
    if (oddsDraw != null) result.oddsDraw = oddsDraw;
    if (strOfferId != null) result.strOfferId = strOfferId;
    if (isMainLine != null) result.isMainLine = isMainLine;
    if (isSuspended != null) result.isSuspended = isSuspended;
    if (isHidden != null) result.isHidden = isHidden;
    if (playerName != null) result.playerName = playerName;
    if (playerId != null) result.playerId = playerId;
    if (period != null) result.period = period;
    return result;
  }

  OddsResponse._();

  factory OddsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OddsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OddsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'selectionHomeId')
    ..aOS(2, _omitFieldNames ? '' : 'selectionAwayId')
    ..aOS(3, _omitFieldNames ? '' : 'selectionDrawId')
    ..aOS(4, _omitFieldNames ? '' : 'points')
    ..aOM<OddsStyleResponse>(5, _omitFieldNames ? '' : 'oddsHome',
        subBuilder: OddsStyleResponse.create)
    ..aOM<OddsStyleResponse>(6, _omitFieldNames ? '' : 'oddsAway',
        subBuilder: OddsStyleResponse.create)
    ..aOM<OddsStyleResponse>(7, _omitFieldNames ? '' : 'oddsDraw',
        subBuilder: OddsStyleResponse.create)
    ..aOS(8, _omitFieldNames ? '' : 'strOfferId')
    ..aOB(9, _omitFieldNames ? '' : 'isMainLine')
    ..aOB(10, _omitFieldNames ? '' : 'isSuspended')
    ..aOB(11, _omitFieldNames ? '' : 'isHidden')
    ..aOS(12, _omitFieldNames ? '' : 'playerName')
    ..aOS(13, _omitFieldNames ? '' : 'playerId')
    ..aI(14, _omitFieldNames ? '' : 'period')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OddsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OddsResponse copyWith(void Function(OddsResponse) updates) =>
      super.copyWith((message) => updates(message as OddsResponse))
          as OddsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OddsResponse create() => OddsResponse._();
  @$core.override
  OddsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OddsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OddsResponse>(create);
  static OddsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get selectionHomeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set selectionHomeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSelectionHomeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSelectionHomeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get selectionAwayId => $_getSZ(1);
  @$pb.TagNumber(2)
  set selectionAwayId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSelectionAwayId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSelectionAwayId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get selectionDrawId => $_getSZ(2);
  @$pb.TagNumber(3)
  set selectionDrawId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSelectionDrawId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSelectionDrawId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get points => $_getSZ(3);
  @$pb.TagNumber(4)
  set points($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPoints() => $_has(3);
  @$pb.TagNumber(4)
  void clearPoints() => $_clearField(4);

  @$pb.TagNumber(5)
  OddsStyleResponse get oddsHome => $_getN(4);
  @$pb.TagNumber(5)
  set oddsHome(OddsStyleResponse value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasOddsHome() => $_has(4);
  @$pb.TagNumber(5)
  void clearOddsHome() => $_clearField(5);
  @$pb.TagNumber(5)
  OddsStyleResponse ensureOddsHome() => $_ensure(4);

  @$pb.TagNumber(6)
  OddsStyleResponse get oddsAway => $_getN(5);
  @$pb.TagNumber(6)
  set oddsAway(OddsStyleResponse value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasOddsAway() => $_has(5);
  @$pb.TagNumber(6)
  void clearOddsAway() => $_clearField(6);
  @$pb.TagNumber(6)
  OddsStyleResponse ensureOddsAway() => $_ensure(5);

  @$pb.TagNumber(7)
  OddsStyleResponse get oddsDraw => $_getN(6);
  @$pb.TagNumber(7)
  set oddsDraw(OddsStyleResponse value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasOddsDraw() => $_has(6);
  @$pb.TagNumber(7)
  void clearOddsDraw() => $_clearField(7);
  @$pb.TagNumber(7)
  OddsStyleResponse ensureOddsDraw() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get strOfferId => $_getSZ(7);
  @$pb.TagNumber(8)
  set strOfferId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasStrOfferId() => $_has(7);
  @$pb.TagNumber(8)
  void clearStrOfferId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isMainLine => $_getBF(8);
  @$pb.TagNumber(9)
  set isMainLine($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIsMainLine() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsMainLine() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isSuspended => $_getBF(9);
  @$pb.TagNumber(10)
  set isSuspended($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIsSuspended() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsSuspended() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get isHidden => $_getBF(10);
  @$pb.TagNumber(11)
  set isHidden($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasIsHidden() => $_has(10);
  @$pb.TagNumber(11)
  void clearIsHidden() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get playerName => $_getSZ(11);
  @$pb.TagNumber(12)
  set playerName($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPlayerName() => $_has(11);
  @$pb.TagNumber(12)
  void clearPlayerName() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get playerId => $_getSZ(12);
  @$pb.TagNumber(13)
  set playerId($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasPlayerId() => $_has(12);
  @$pb.TagNumber(13)
  void clearPlayerId() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get period => $_getIZ(13);
  @$pb.TagNumber(14)
  set period($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasPeriod() => $_has(13);
  @$pb.TagNumber(14)
  void clearPeriod() => $_clearField(14);
}

class OddsStyleResponse extends $pb.GeneratedMessage {
  factory OddsStyleResponse({
    $core.String? decimal,
    $core.String? malay,
    $core.String? indo,
    $core.String? hk,
  }) {
    final result = create();
    if (decimal != null) result.decimal = decimal;
    if (malay != null) result.malay = malay;
    if (indo != null) result.indo = indo;
    if (hk != null) result.hk = hk;
    return result;
  }

  OddsStyleResponse._();

  factory OddsStyleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OddsStyleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OddsStyleResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'decimal')
    ..aOS(2, _omitFieldNames ? '' : 'malay')
    ..aOS(3, _omitFieldNames ? '' : 'indo')
    ..aOS(4, _omitFieldNames ? '' : 'hk')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OddsStyleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OddsStyleResponse copyWith(void Function(OddsStyleResponse) updates) =>
      super.copyWith((message) => updates(message as OddsStyleResponse))
          as OddsStyleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OddsStyleResponse create() => OddsStyleResponse._();
  @$core.override
  OddsStyleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OddsStyleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OddsStyleResponse>(create);
  static OddsStyleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get decimal => $_getSZ(0);
  @$pb.TagNumber(1)
  set decimal($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDecimal() => $_has(0);
  @$pb.TagNumber(1)
  void clearDecimal() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get malay => $_getSZ(1);
  @$pb.TagNumber(2)
  set malay($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMalay() => $_has(1);
  @$pb.TagNumber(2)
  void clearMalay() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get indo => $_getSZ(2);
  @$pb.TagNumber(3)
  set indo($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIndo() => $_has(2);
  @$pb.TagNumber(3)
  void clearIndo() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get hk => $_getSZ(3);
  @$pb.TagNumber(4)
  set hk($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHk() => $_has(3);
  @$pb.TagNumber(4)
  void clearHk() => $_clearField(4);
}

class OutrightOddsResponse extends $pb.GeneratedMessage {
  factory OutrightOddsResponse({
    $core.String? selectionId,
    $core.String? selectionName,
    $core.String? selectionLogo,
    $core.String? offerId,
    $core.double? odds,
    $core.String? cls,
    $core.bool? isSuspended,
  }) {
    final result = create();
    if (selectionId != null) result.selectionId = selectionId;
    if (selectionName != null) result.selectionName = selectionName;
    if (selectionLogo != null) result.selectionLogo = selectionLogo;
    if (offerId != null) result.offerId = offerId;
    if (odds != null) result.odds = odds;
    if (cls != null) result.cls = cls;
    if (isSuspended != null) result.isSuspended = isSuspended;
    return result;
  }

  OutrightOddsResponse._();

  factory OutrightOddsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OutrightOddsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OutrightOddsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'selectionId')
    ..aOS(2, _omitFieldNames ? '' : 'selectionName')
    ..aOS(3, _omitFieldNames ? '' : 'selectionLogo')
    ..aOS(4, _omitFieldNames ? '' : 'offerId')
    ..aD(5, _omitFieldNames ? '' : 'odds')
    ..aOS(6, _omitFieldNames ? '' : 'cls')
    ..aOB(7, _omitFieldNames ? '' : 'isSuspended')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutrightOddsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutrightOddsResponse copyWith(void Function(OutrightOddsResponse) updates) =>
      super.copyWith((message) => updates(message as OutrightOddsResponse))
          as OutrightOddsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OutrightOddsResponse create() => OutrightOddsResponse._();
  @$core.override
  OutrightOddsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OutrightOddsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OutrightOddsResponse>(create);
  static OutrightOddsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get selectionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set selectionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSelectionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSelectionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get selectionName => $_getSZ(1);
  @$pb.TagNumber(2)
  set selectionName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSelectionName() => $_has(1);
  @$pb.TagNumber(2)
  void clearSelectionName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get selectionLogo => $_getSZ(2);
  @$pb.TagNumber(3)
  set selectionLogo($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSelectionLogo() => $_has(2);
  @$pb.TagNumber(3)
  void clearSelectionLogo() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get offerId => $_getSZ(3);
  @$pb.TagNumber(4)
  set offerId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOfferId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOfferId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get odds => $_getN(4);
  @$pb.TagNumber(5)
  set odds($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOdds() => $_has(4);
  @$pb.TagNumber(5)
  void clearOdds() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get cls => $_getSZ(5);
  @$pb.TagNumber(6)
  set cls($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCls() => $_has(5);
  @$pb.TagNumber(6)
  void clearCls() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isSuspended => $_getBF(6);
  @$pb.TagNumber(7)
  set isSuspended($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsSuspended() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsSuspended() => $_clearField(7);
}

class OutrightLineResponse extends $pb.GeneratedMessage {
  factory OutrightLineResponse({
    $core.Iterable<OutrightOddsResponse>? oddsList,
    $core.String? lineName,
    $core.int? lineOrder,
  }) {
    final result = create();
    if (oddsList != null) result.oddsList.addAll(oddsList);
    if (lineName != null) result.lineName = lineName;
    if (lineOrder != null) result.lineOrder = lineOrder;
    return result;
  }

  OutrightLineResponse._();

  factory OutrightLineResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OutrightLineResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OutrightLineResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..pPM<OutrightOddsResponse>(1, _omitFieldNames ? '' : 'oddsList',
        subBuilder: OutrightOddsResponse.create)
    ..aOS(2, _omitFieldNames ? '' : 'lineName')
    ..aI(3, _omitFieldNames ? '' : 'lineOrder')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutrightLineResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutrightLineResponse copyWith(void Function(OutrightLineResponse) updates) =>
      super.copyWith((message) => updates(message as OutrightLineResponse))
          as OutrightLineResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OutrightLineResponse create() => OutrightLineResponse._();
  @$core.override
  OutrightLineResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OutrightLineResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OutrightLineResponse>(create);
  static OutrightLineResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<OutrightOddsResponse> get oddsList => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get lineName => $_getSZ(1);
  @$pb.TagNumber(2)
  set lineName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLineName() => $_has(1);
  @$pb.TagNumber(2)
  void clearLineName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get lineOrder => $_getIZ(2);
  @$pb.TagNumber(3)
  set lineOrder($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLineOrder() => $_has(2);
  @$pb.TagNumber(3)
  void clearLineOrder() => $_clearField(3);
}

class OutrightEventResponse extends $pb.GeneratedMessage {
  factory OutrightEventResponse({
    $core.Iterable<OutrightLineResponse>? lines,
    $core.int? sportId,
    $core.int? leagueId,
    $fixnum.Int64? eventId,
    $core.String? eventName,
    $core.bool? isSuspended,
    $core.String? endDate,
    $fixnum.Int64? endTime,
  }) {
    final result = create();
    if (lines != null) result.lines.addAll(lines);
    if (sportId != null) result.sportId = sportId;
    if (leagueId != null) result.leagueId = leagueId;
    if (eventId != null) result.eventId = eventId;
    if (eventName != null) result.eventName = eventName;
    if (isSuspended != null) result.isSuspended = isSuspended;
    if (endDate != null) result.endDate = endDate;
    if (endTime != null) result.endTime = endTime;
    return result;
  }

  OutrightEventResponse._();

  factory OutrightEventResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OutrightEventResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OutrightEventResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..pPM<OutrightLineResponse>(1, _omitFieldNames ? '' : 'lines',
        subBuilder: OutrightLineResponse.create)
    ..aI(2, _omitFieldNames ? '' : 'sportId')
    ..aI(3, _omitFieldNames ? '' : 'leagueId')
    ..aInt64(4, _omitFieldNames ? '' : 'eventId')
    ..aOS(5, _omitFieldNames ? '' : 'eventName')
    ..aOB(6, _omitFieldNames ? '' : 'isSuspended')
    ..aOS(7, _omitFieldNames ? '' : 'endDate')
    ..aInt64(8, _omitFieldNames ? '' : 'endTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutrightEventResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutrightEventResponse copyWith(
          void Function(OutrightEventResponse) updates) =>
      super.copyWith((message) => updates(message as OutrightEventResponse))
          as OutrightEventResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OutrightEventResponse create() => OutrightEventResponse._();
  @$core.override
  OutrightEventResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OutrightEventResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OutrightEventResponse>(create);
  static OutrightEventResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<OutrightLineResponse> get lines => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get sportId => $_getIZ(1);
  @$pb.TagNumber(2)
  set sportId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSportId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSportId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get leagueId => $_getIZ(2);
  @$pb.TagNumber(3)
  set leagueId($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLeagueId() => $_has(2);
  @$pb.TagNumber(3)
  void clearLeagueId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get eventId => $_getI64(3);
  @$pb.TagNumber(4)
  set eventId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEventId() => $_has(3);
  @$pb.TagNumber(4)
  void clearEventId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get eventName => $_getSZ(4);
  @$pb.TagNumber(5)
  set eventName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEventName() => $_has(4);
  @$pb.TagNumber(5)
  void clearEventName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isSuspended => $_getBF(5);
  @$pb.TagNumber(6)
  set isSuspended($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsSuspended() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsSuspended() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get endDate => $_getSZ(6);
  @$pb.TagNumber(7)
  set endDate($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEndDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearEndDate() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get endTime => $_getI64(7);
  @$pb.TagNumber(8)
  set endTime($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEndTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearEndTime() => $_clearField(8);
}

class BetSlipStatusResponse extends $pb.GeneratedMessage {
  factory BetSlipStatusResponse({
    $core.String? ticketId,
    $core.String? status,
  }) {
    final result = create();
    if (ticketId != null) result.ticketId = ticketId;
    if (status != null) result.status = status;
    return result;
  }

  BetSlipStatusResponse._();

  factory BetSlipStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BetSlipStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BetSlipStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ticketId')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BetSlipStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BetSlipStatusResponse copyWith(
          void Function(BetSlipStatusResponse) updates) =>
      super.copyWith((message) => updates(message as BetSlipStatusResponse))
          as BetSlipStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BetSlipStatusResponse create() => BetSlipStatusResponse._();
  @$core.override
  BetSlipStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BetSlipStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BetSlipStatusResponse>(create);
  static BetSlipStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ticketId => $_getSZ(0);
  @$pb.TagNumber(1)
  set ticketId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTicketId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTicketId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);
}

class HotEventsResponse extends $pb.GeneratedMessage {
  factory HotEventsResponse({
    $core.Iterable<HotEventResponse>? events,
  }) {
    final result = create();
    if (events != null) result.events.addAll(events);
    return result;
  }

  HotEventsResponse._();

  factory HotEventsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HotEventsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HotEventsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..pPM<HotEventResponse>(1, _omitFieldNames ? '' : 'events',
        subBuilder: HotEventResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HotEventsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HotEventsResponse copyWith(void Function(HotEventsResponse) updates) =>
      super.copyWith((message) => updates(message as HotEventsResponse))
          as HotEventsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HotEventsResponse create() => HotEventsResponse._();
  @$core.override
  HotEventsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HotEventsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HotEventsResponse>(create);
  static HotEventsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<HotEventResponse> get events => $_getList(0);
}

class HotEventResponse extends $pb.GeneratedMessage {
  factory HotEventResponse({
    EventResponse? event,
    $core.int? leagueId,
    $core.String? leagueName,
    $core.int? leagueOrder,
    $core.int? leaguePriorityOrder,
    $core.String? leagueLogo,
  }) {
    final result = create();
    if (event != null) result.event = event;
    if (leagueId != null) result.leagueId = leagueId;
    if (leagueName != null) result.leagueName = leagueName;
    if (leagueOrder != null) result.leagueOrder = leagueOrder;
    if (leaguePriorityOrder != null)
      result.leaguePriorityOrder = leaguePriorityOrder;
    if (leagueLogo != null) result.leagueLogo = leagueLogo;
    return result;
  }

  HotEventResponse._();

  factory HotEventResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HotEventResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HotEventResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..aOM<EventResponse>(1, _omitFieldNames ? '' : 'event',
        subBuilder: EventResponse.create)
    ..aI(2, _omitFieldNames ? '' : 'leagueId')
    ..aOS(3, _omitFieldNames ? '' : 'leagueName')
    ..aI(4, _omitFieldNames ? '' : 'leagueOrder')
    ..aI(5, _omitFieldNames ? '' : 'leaguePriorityOrder')
    ..aOS(6, _omitFieldNames ? '' : 'leagueLogo')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HotEventResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HotEventResponse copyWith(void Function(HotEventResponse) updates) =>
      super.copyWith((message) => updates(message as HotEventResponse))
          as HotEventResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HotEventResponse create() => HotEventResponse._();
  @$core.override
  HotEventResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HotEventResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HotEventResponse>(create);
  static HotEventResponse? _defaultInstance;

  @$pb.TagNumber(1)
  EventResponse get event => $_getN(0);
  @$pb.TagNumber(1)
  set event(EventResponse value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEvent() => $_has(0);
  @$pb.TagNumber(1)
  void clearEvent() => $_clearField(1);
  @$pb.TagNumber(1)
  EventResponse ensureEvent() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get leagueId => $_getIZ(1);
  @$pb.TagNumber(2)
  set leagueId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLeagueId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLeagueId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get leagueName => $_getSZ(2);
  @$pb.TagNumber(3)
  set leagueName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLeagueName() => $_has(2);
  @$pb.TagNumber(3)
  void clearLeagueName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get leagueOrder => $_getIZ(3);
  @$pb.TagNumber(4)
  set leagueOrder($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLeagueOrder() => $_has(3);
  @$pb.TagNumber(4)
  void clearLeagueOrder() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get leaguePriorityOrder => $_getIZ(4);
  @$pb.TagNumber(5)
  set leaguePriorityOrder($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLeaguePriorityOrder() => $_has(4);
  @$pb.TagNumber(5)
  void clearLeaguePriorityOrder() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get leagueLogo => $_getSZ(5);
  @$pb.TagNumber(6)
  set leagueLogo($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLeagueLogo() => $_has(5);
  @$pb.TagNumber(6)
  void clearLeagueLogo() => $_clearField(6);
}

class PopularLeaguesResponse extends $pb.GeneratedMessage {
  factory PopularLeaguesResponse({
    $core.Iterable<LeagueResponse>? leagues,
  }) {
    final result = create();
    if (leagues != null) result.leagues.addAll(leagues);
    return result;
  }

  PopularLeaguesResponse._();

  factory PopularLeaguesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PopularLeaguesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PopularLeaguesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app.proto'),
      createEmptyInstance: create)
    ..pPM<LeagueResponse>(1, _omitFieldNames ? '' : 'leagues',
        subBuilder: LeagueResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PopularLeaguesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PopularLeaguesResponse copyWith(
          void Function(PopularLeaguesResponse) updates) =>
      super.copyWith((message) => updates(message as PopularLeaguesResponse))
          as PopularLeaguesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PopularLeaguesResponse create() => PopularLeaguesResponse._();
  @$core.override
  PopularLeaguesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PopularLeaguesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PopularLeaguesResponse>(create);
  static PopularLeaguesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LeagueResponse> get leagues => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
