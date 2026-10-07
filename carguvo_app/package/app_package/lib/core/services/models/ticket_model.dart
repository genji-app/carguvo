import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_model.freezed.dart';
part 'ticket_model.g.dart';

@freezed
sealed class TicketModel with _$TicketModel {
  const factory TicketModel({
    @JsonKey(name: 'ticketId') required String ticketId,
    required String status,
    required int stake,
    @JsonKey(name: 'potentialWinnings') int? potentialWinnings,
    @JsonKey(name: 'actualWinnings') int? actualWinnings,
    required String odds,
    @JsonKey(name: 'selections')
    @Default([])
    List<TicketSelectionModel> selections,
    @JsonKey(name: 'createdAt') required String createdAt,
    @JsonKey(name: 'settledAt') String? settledAt,
    @JsonKey(name: 'cashOutAmount') int? cashOutAmount,
    @JsonKey(name: 'cashOutAvailable') @Default(false) bool cashOutAvailable,
  }) = _TicketModel;

  factory TicketModel.fromJson(Map<String, dynamic> json) =>
      _$TicketModelFromJson(json);
}

@freezed
sealed class TicketSelectionModel with _$TicketSelectionModel {
  const factory TicketSelectionModel({
    @JsonKey(name: 'eventId') int? eventId,
    @JsonKey(name: 'eventName') required String eventName,
    @JsonKey(name: 'selectionId') String? selectionId,
    @JsonKey(name: 'selectionName') required String selectionName,
    required String odds,
    required String status,
    @JsonKey(name: 'result') MatchResultModel? result,
  }) = _TicketSelectionModel;

  factory TicketSelectionModel.fromJson(Map<String, dynamic> json) =>
      _$TicketSelectionModelFromJson(json);
}

@freezed
sealed class MatchResultModel with _$MatchResultModel {
  const factory MatchResultModel({
    @JsonKey(name: 'homeScore') required int homeScore,
    @JsonKey(name: 'awayScore') required int awayScore,
  }) = _MatchResultModel;

  factory MatchResultModel.fromJson(Map<String, dynamic> json) =>
      _$MatchResultModelFromJson(json);
}

@freezed
sealed class BetHistoryResponse with _$BetHistoryResponse {
  const factory BetHistoryResponse({
    @Default([]) List<TicketModel> bets,
    @Default(0) int total,
    @JsonKey(name: 'totalStake') @Default(0) int totalStake,
    @JsonKey(name: 'totalWinnings') @Default(0) int totalWinnings,
  }) = _BetHistoryResponse;

  factory BetHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$BetHistoryResponseFromJson(json);
}

@freezed
sealed class CashOutRequest with _$CashOutRequest {
  const factory CashOutRequest({
    @JsonKey(name: 'ticketId') required String ticketId,
  }) = _CashOutRequest;

  factory CashOutRequest.fromJson(Map<String, dynamic> json) =>
      _$CashOutRequestFromJson(json);
}

@freezed
sealed class CashOutOptionsResponse with _$CashOutOptionsResponse {
  const factory CashOutOptionsResponse({
    @JsonKey(name: 'ticketId') required String ticketId,
    @Default(false) bool available,
    @JsonKey(name: 'cashOutAmount') int? cashOutAmount,
    @JsonKey(name: 'originalStake') int? originalStake,
    @JsonKey(name: 'potentialWinnings') int? potentialWinnings,
    int? profit,
    @JsonKey(name: 'profitPercentage') double? profitPercentage,
    String? reason,
  }) = _CashOutOptionsResponse;

  factory CashOutOptionsResponse.fromJson(Map<String, dynamic> json) =>
      _$CashOutOptionsResponseFromJson(json);
}

@freezed
sealed class CashOutResponse with _$CashOutResponse {
  const factory CashOutResponse({
    @JsonKey(name: 'ticketId') required String ticketId,
    required String status,
    @JsonKey(name: 'cashOutAmount') int? cashOutAmount,
    int? profit,
    String? message,
    @JsonKey(name: 'errorCode') @Default(0) int errorCode,
  }) = _CashOutResponse;

  factory CashOutResponse.fromJson(Map<String, dynamic> json) =>
      _$CashOutResponseFromJson(json);
}

abstract class BetStatuses {
  static const String pending = 'pending';
  static const String won = 'won';
  static const String lost = 'lost';
  static const String voided = 'void';
  static const String cashout = 'cashout';
  static const String cancelled = 'cancelled';
}

extension TicketModelX on TicketModel {
  bool get isPending => status == BetStatuses.pending;

  bool get isWon => status == BetStatuses.won;

  bool get isLost => status == BetStatuses.lost;

  bool get isVoided => status == BetStatuses.voided;

  bool get isCashedOut => status == BetStatuses.cashout;

  bool get isSettled => !isPending;

  double get stakeK => stake / 1000.0;

  double get potentialWinningsK => (potentialWinnings ?? 0) / 1000.0;

  double get actualWinningsK => (actualWinnings ?? 0) / 1000.0;

  double get cashOutAmountK => (cashOutAmount ?? 0) / 1000.0;

  double get profitLoss {
    if (isWon) return actualWinningsK - stakeK;
    if (isLost) return -stakeK;
    if (isCashedOut) return cashOutAmountK - stakeK;
    return 0.0;
  }

  String get formattedStake => '${stakeK.toStringAsFixed(0)}K';

  String get formattedStatus {
    switch (status) {
      case BetStatuses.pending:
        return 'Đang chờ';
      case BetStatuses.won:
        return 'Thắng';
      case BetStatuses.lost:
        return 'Thua';
      case BetStatuses.voided:
        return 'Hủy';
      case BetStatuses.cashout:
        return 'Đã rút';
      default:
        return status;
    }
  }
}

extension CashOutOptionsResponseX on CashOutOptionsResponse {
  double get cashOutAmountK => (cashOutAmount ?? 0) / 1000.0;

  bool get isProfitable => (profit ?? 0) > 0;
}

extension CashOutResponseX on CashOutResponse {
  bool get isSuccess => status == 'SUCCESS' && errorCode == 0;

  double get cashOutAmountK => (cashOutAmount ?? 0) / 1000.0;
}
