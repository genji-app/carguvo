import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/services/models/bet_model.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';

abstract class OutrightBettingRepository {
  Future<Map<String, dynamic>> calculateOutrightBet({
    required String leagueId,
    required String displayOdds,
    required String selectionId,
    String currency = 'VND',
  });

  Future<PlaceBetResponse> placeOutrightBet({
    required String cls,
    required double displayOdds,
    required String selectionId,
    required String selectionName,
    required int stake,
    required int winnings,
    bool acceptAllOdds = false,
    bool acceptBetterOdds = true,
  });
}

class OutrightBettingRepositoryImpl implements OutrightBettingRepository {
  final SbHttpManager _http;

  OutrightBettingRepositoryImpl({SbHttpManager? http})
    : _http = http ?? SbHttpManager.instance;

  @override
  Future<Map<String, dynamic>> calculateOutrightBet({
    required String leagueId,
    required String displayOdds,
    required String selectionId,
    String currency = 'VND',
  }) async {
    final body = {
      'leagueId': int.tryParse(leagueId) ?? leagueId,
      'displayOdds': displayOdds,
      'selectionId': selectionId,
      'currency': currency,
    };

    return await _http.calculateOutrightBets(body);
  }

  @override
  Future<PlaceBetResponse> placeOutrightBet({
    required String cls,
    required double displayOdds,
    required String selectionId,
    required String selectionName,
    required int stake,
    required int winnings,
    bool acceptAllOdds = false,
    bool acceptBetterOdds = true,
  }) async {
    final body = {
      'acceptAllOdds': acceptAllOdds,
      'acceptBetterOdds': acceptBetterOdds,
      'selection': {
        'cls': cls,
        'displayOdds': displayOdds,
        'selectionId': selectionId,
        'selectionName': selectionName,
        'stake': stake,
        'winnings': winnings,
      },
    };

    debugPrint('[OutrightBettingRepository] placeOutrightBet body: $body');

    final response = await _http.placeOutrightBets(body);
    debugPrint('[OutrightBettingRepository] placeOutrightBet response: $response');
    return PlaceBetResponse.fromJson(response);
  }
}
