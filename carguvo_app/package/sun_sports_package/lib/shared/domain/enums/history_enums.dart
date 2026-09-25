import 'package:sun_sports/core/services/models/ticket_model.dart';

enum HistoryFilter { all, pending, won, lost, cashout }

extension HistoryFilterX on HistoryFilter {
  String get apiValue {
    switch (this) {
      case HistoryFilter.all:
        return '';
      case HistoryFilter.pending:
        return BetStatuses.pending;
      case HistoryFilter.won:
        return BetStatuses.won;
      case HistoryFilter.lost:
        return BetStatuses.lost;
      case HistoryFilter.cashout:
        return BetStatuses.cashout;
    }
  }

  String get displayName {
    switch (this) {
      case HistoryFilter.all:
        return 'Tất cả';
      case HistoryFilter.pending:
        return 'Đang chờ';
      case HistoryFilter.won:
        return 'Thắng';
      case HistoryFilter.lost:
        return 'Thua';
      case HistoryFilter.cashout:
        return 'Đã rút';
    }
  }
}
