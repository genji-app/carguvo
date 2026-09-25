import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/services/models/ticket_model.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

abstract class HistoryRepository {
  Future<BetHistoryResponse> getBetHistory({String status = ''});
  Future<List<TicketModel>> getBetSlipByStatus(String status);
  Future<TicketModel?> getTicketById(String ticketId);
  Future<CashOutOptionsResponse?> getCashOutOptions(String ticketId);
  Future<CashOutResponse?> cashOut(String ticketId);
}

class HistoryRepositoryImpl implements HistoryRepository {
  final SbHttpManager _http;
  final AppLogger _logger = AppLogger(tag: 'History');

  HistoryRepositoryImpl({SbHttpManager? http})
    : _http = http ?? SbHttpManager.instance;

  @override
  Future<BetHistoryResponse> getBetHistory({String status = ''}) async {
    try {
      final response = await _http.betsReporting(status);
      return BetHistoryResponse.fromJson(response as Map<String, dynamic>);
    } catch (e, st) {
      _logger.e('getBetHistory failed', error: e, stackTrace: st);
      return const BetHistoryResponse();
    }
  }

  @override
  Future<List<TicketModel>> getBetSlipByStatus(String status) async {
    try {
      final response = await _http.getBetSlipByStatus(status);

      if (response['bets'] == null) return [];

      final betsData = response['bets'] as List<dynamic>;
      return betsData
          .map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      _logger.e('getBetSlipByStatus failed', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      final response = await _http.getStatusByTicketId(ticketId);

      if (response['ticket'] == null) return null;

      return TicketModel.fromJson(response['ticket'] as Map<String, dynamic>);
    } catch (e, st) {
      _logger.e('getTicketById failed', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<CashOutOptionsResponse?> getCashOutOptions(String ticketId) async {
    try {
      final response = await _http.getCashOut({'ticketId': ticketId});
      return CashOutOptionsResponse.fromJson(response);
    } catch (e, st) {
      _logger.e('getCashOutOptions failed', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<CashOutResponse?> cashOut(String ticketId) async {
    try {
      final response = await _http.cashOut({'ticketId': ticketId});
      return CashOutResponse.fromJson(response);
    } catch (e, st) {
      _logger.e('cashOut failed', error: e, stackTrace: st);
      return null;
    }
  }
}
