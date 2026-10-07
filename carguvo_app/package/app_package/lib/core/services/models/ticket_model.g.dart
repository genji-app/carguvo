
part of 'ticket_model.dart';

_TicketModel _$TicketModelFromJson(Map<String, dynamic> json) => _TicketModel(
  ticketId: json['ticketId'] as String,
  status: json['status'] as String,
  stake: (json['stake'] as num).toInt(),
  potentialWinnings: (json['potentialWinnings'] as num?)?.toInt(),
  actualWinnings: (json['actualWinnings'] as num?)?.toInt(),
  odds: json['odds'] as String,
  selections:
      (json['selections'] as List<dynamic>?)
          ?.map((e) => TicketSelectionModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: json['createdAt'] as String,
  settledAt: json['settledAt'] as String?,
  cashOutAmount: (json['cashOutAmount'] as num?)?.toInt(),
  cashOutAvailable: json['cashOutAvailable'] as bool? ?? false,
);

Map<String, dynamic> _$TicketModelToJson(_TicketModel instance) =>
    <String, dynamic>{
      'ticketId': instance.ticketId,
      'status': instance.status,
      'stake': instance.stake,
      'potentialWinnings': instance.potentialWinnings,
      'actualWinnings': instance.actualWinnings,
      'odds': instance.odds,
      'selections': instance.selections.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt,
      'settledAt': instance.settledAt,
      'cashOutAmount': instance.cashOutAmount,
      'cashOutAvailable': instance.cashOutAvailable,
    };

_TicketSelectionModel _$TicketSelectionModelFromJson(
  Map<String, dynamic> json,
) => _TicketSelectionModel(
  eventId: (json['eventId'] as num?)?.toInt(),
  eventName: json['eventName'] as String,
  selectionId: json['selectionId'] as String?,
  selectionName: json['selectionName'] as String,
  odds: json['odds'] as String,
  status: json['status'] as String,
  result: json['result'] == null
      ? null
      : MatchResultModel.fromJson(json['result'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TicketSelectionModelToJson(
  _TicketSelectionModel instance,
) => <String, dynamic>{
  'eventId': instance.eventId,
  'eventName': instance.eventName,
  'selectionId': instance.selectionId,
  'selectionName': instance.selectionName,
  'odds': instance.odds,
  'status': instance.status,
  'result': instance.result?.toJson(),
};

_MatchResultModel _$MatchResultModelFromJson(Map<String, dynamic> json) =>
    _MatchResultModel(
      homeScore: (json['homeScore'] as num).toInt(),
      awayScore: (json['awayScore'] as num).toInt(),
    );

Map<String, dynamic> _$MatchResultModelToJson(_MatchResultModel instance) =>
    <String, dynamic>{
      'homeScore': instance.homeScore,
      'awayScore': instance.awayScore,
    };

_BetHistoryResponse _$BetHistoryResponseFromJson(Map<String, dynamic> json) =>
    _BetHistoryResponse(
      bets:
          (json['bets'] as List<dynamic>?)
              ?.map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalStake: (json['totalStake'] as num?)?.toInt() ?? 0,
      totalWinnings: (json['totalWinnings'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BetHistoryResponseToJson(_BetHistoryResponse instance) =>
    <String, dynamic>{
      'bets': instance.bets.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'totalStake': instance.totalStake,
      'totalWinnings': instance.totalWinnings,
    };

_CashOutRequest _$CashOutRequestFromJson(Map<String, dynamic> json) =>
    _CashOutRequest(ticketId: json['ticketId'] as String);

Map<String, dynamic> _$CashOutRequestToJson(_CashOutRequest instance) =>
    <String, dynamic>{'ticketId': instance.ticketId};

_CashOutOptionsResponse _$CashOutOptionsResponseFromJson(
  Map<String, dynamic> json,
) => _CashOutOptionsResponse(
  ticketId: json['ticketId'] as String,
  available: json['available'] as bool? ?? false,
  cashOutAmount: (json['cashOutAmount'] as num?)?.toInt(),
  originalStake: (json['originalStake'] as num?)?.toInt(),
  potentialWinnings: (json['potentialWinnings'] as num?)?.toInt(),
  profit: (json['profit'] as num?)?.toInt(),
  profitPercentage: (json['profitPercentage'] as num?)?.toDouble(),
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$CashOutOptionsResponseToJson(
  _CashOutOptionsResponse instance,
) => <String, dynamic>{
  'ticketId': instance.ticketId,
  'available': instance.available,
  'cashOutAmount': instance.cashOutAmount,
  'originalStake': instance.originalStake,
  'potentialWinnings': instance.potentialWinnings,
  'profit': instance.profit,
  'profitPercentage': instance.profitPercentage,
  'reason': instance.reason,
};

_CashOutResponse _$CashOutResponseFromJson(Map<String, dynamic> json) =>
    _CashOutResponse(
      ticketId: json['ticketId'] as String,
      status: json['status'] as String,
      cashOutAmount: (json['cashOutAmount'] as num?)?.toInt(),
      profit: (json['profit'] as num?)?.toInt(),
      message: json['message'] as String?,
      errorCode: (json['errorCode'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CashOutResponseToJson(_CashOutResponse instance) =>
    <String, dynamic>{
      'ticketId': instance.ticketId,
      'status': instance.status,
      'cashOutAmount': instance.cashOutAmount,
      'profit': instance.profit,
      'message': instance.message,
      'errorCode': instance.errorCode,
    };
