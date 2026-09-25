import 'package:flutter/foundation.dart';
import 'package:betting_domain/betting_domain.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/services/models/bet_model.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';

abstract class BettingRepository {
  Future<CalculateBetResponse> calculateBet(CalculateBetRequest request, {int? sportId});
  Future<PlaceBetResponse> placeBet(PlaceBetRequest request, {int? sportId});

  Future<CalculateBetResponse> calculateParlayBet(
    List<SingleBetData> comboBets,
    String oddsStyle,
  );

  Future<PlaceBetResponse> placeParlayBet(
    List<SingleBetData> comboBets,
    int stake,
    String oddsStyle,
  );
}

class BettingRepositoryImpl implements BettingRepository {
  final SbHttpManager _http;

  BettingRepositoryImpl({SbHttpManager? http})
    : _http = http ?? SbHttpManager.instance;

  static int _parlayRouteSportId(List<SingleBetData> comboBets) =>
      BettingRestRules.parlayRouteSportId([
        for (final b in comboBets) b.sportId,
      ]);

  @override
  Future<CalculateBetResponse> calculateBet(CalculateBetRequest request, {int? sportId}) async {
    final body = {
      'leagueId': request.leagueId,
      'matchTime': request.matchTime,
      'isLive': request.isLive,
      'offerId': request.offerId,
      'selectionId': request.selectionId,
      'displayOdds': request.displayOdds,
      'oddsStyle': request.oddsStyle,
    };

    final response = await _http.calculateBets(body, sportId: sportId);
    return CalculateBetResponse.fromJson(response);
  }

  @override
  Future<PlaceBetResponse> placeBet(PlaceBetRequest request, {int? sportId}) async {
    final selectionsJson = request.selections.map((s) {
      return s.toRequestJson(s.stake ?? 0);
    }).toList();

    final effectiveSportId = sportId ??
        (request.selections.isNotEmpty ? request.selections.first.sportId : 1);

    final body = {
      'acceptBetterOdds': request.acceptBetterOdds,
      'acceptMaxStake': request.acceptMaxStake,
      'matchId': request.matchId,
      'selections': selectionsJson,
      'singleBet': request.singleBet,
    };

    debugPrint('[BettingRepository] placeBet body: $body');

    final response = await _http.placeBets(body, sportId: effectiveSportId);
    debugPrint('[BettingRepository] placeBet response: $response');
    return PlaceBetResponse.fromJson(response);
  }

  @override
  Future<CalculateBetResponse> calculateParlayBet(
    List<SingleBetData> comboBets,
    String oddsStyle,
  ) async {
    final calculateBetRequests = comboBets.map((bet) {
      return {
        'displayOdds': bet.getOddsByStyle(OddsStyle.decimal),
        'isLive': bet.isLive,
        'leagueId': int.tryParse(bet.leagueIdString) ?? 0,
        'matchTime': bet.matchTimeISO,
        'offerId': bet.offerId ?? '',
        'selectionId': bet.selectionId ?? '',
      };
    }).toList();

    final body = {
      'calculateBetRequests': calculateBetRequests,
      'currency': 'VND',
      'oddsStyle': oddsStyle,
      'parlay': true,
    };

    final sportId = _parlayRouteSportId(comboBets);

    final response = await _http.calculateBetsParlay(body, sportId: sportId);
    return CalculateBetResponse.fromJson(response);
  }

  @override
  Future<PlaceBetResponse> placeParlayBet(
    List<SingleBetData> comboBets,
    int stake,
    String oddsStyle,
  ) async {
    final selections = comboBets.asMap().entries.map((entry) {
      final index = entry.key;
      final bet = entry.value;
      final selectionStake = index == 0 ? stake : 0;

      final betMarketId = bet.marketData.marketId;
      final int homeScore;
      final int awayScore;
      if (MarketHelper.isCornerMarket(betMarketId)) {
        homeScore = bet.eventData.cornersHome;
        awayScore = bet.eventData.cornersAway;
      } else if (MarketHelper.isExtraTime(betMarketId)) {
        homeScore = bet.eventData.homeScoreOT;
        awayScore = bet.eventData.awayScoreOT;
      } else {
        homeScore = bet.eventData.homeScore;
        awayScore = bet.eventData.awayScore;
      }
      return {
        'homeScore': homeScore,
        'awayScore': awayScore,
        'cls': bet.cls,
        'displayOdds': bet.getOddsByStyle(OddsStyle.decimal),
        'oddsStyle': oddsStyle,
        'selectionId': bet.selectionId ?? '',
        'selectionName': bet.selectionName,
        'offerId': bet.offerId ?? '',
        'stake': selectionStake,
        'trueOdds': 0,
        'winnings': 0,
      };
    }).toList();

    final body = {
      'acceptAllOdds': true,
      'acceptBetterOdds': true,
      'acceptMaxStake': true,
      'selections': selections,
      'singleBet': true,
      'parlay': true,
    };

    final sportId = _parlayRouteSportId(comboBets);

    final response = await _http.placeBetsParlay(body, sportId: sportId);

    try {
      final parsedResponse = PlaceBetResponse.fromJson(response);
      return parsedResponse;
    } catch (e, stackTrace) {

      final ticketId = response['ticketId']?.toString();
      final status = response['status']?.toString() ?? '';
      if (ticketId != null && ticketId.isNotEmpty && status == 'Active') {
        return PlaceBetResponse(
          ticketId: ticketId,
          status: status,
          errorCode: 0,
        );
      }
      rethrow;
    }
  }
}
