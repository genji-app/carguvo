import 'package:freezed_annotation/freezed_annotation.dart';

part 'bet_model.freezed.dart';
part 'bet_model.g.dart';

@freezed
sealed class BetSelectionModel with _$BetSelectionModel {
  const factory BetSelectionModel({
    required int eventId,
    required String eventName,
    @JsonKey(name: 'selectionId') required String selectionId,
    @JsonKey(name: 'selectionName') required String selectionName,
    @JsonKey(name: 'offerId') required String offerId,
    @JsonKey(name: 'displayOdds') required String displayOdds,
    @JsonKey(name: 'oddsStyle') @Default('decimal') String oddsStyle,
    @JsonKey(name: 'cls') required String cls,
    @JsonKey(name: 'leagueId') String? leagueId,
    @JsonKey(name: 'matchTime') String? matchTime,
    @JsonKey(name: 'isLive') @Default(false) bool isLive,
    @JsonKey(name: 'sportId') @Default(1) int sportId,
    @JsonKey(name: 'homeScore') int? homeScore,
    @JsonKey(name: 'awayScore') int? awayScore,
    double? stake,
    double? winnings,
  }) = _BetSelectionModel;

  factory BetSelectionModel.fromJson(Map<String, dynamic> json) =>
      _$BetSelectionModelFromJson(json);
}

@freezed
sealed class CalculateBetRequest with _$CalculateBetRequest {
  const factory CalculateBetRequest({
    @JsonKey(name: 'leagueId') required String leagueId,
    @JsonKey(name: 'matchTime') required String matchTime,
    @JsonKey(name: 'isLive') @Default(false) bool isLive,
    @JsonKey(name: 'offerId') required String offerId,
    @JsonKey(name: 'selectionId') required String selectionId,
    @JsonKey(name: 'displayOdds') required String displayOdds,
    @JsonKey(name: 'oddsStyle') @Default('decimal') String oddsStyle,
  }) = _CalculateBetRequest;

  factory CalculateBetRequest.fromJson(Map<String, dynamic> json) =>
      _$CalculateBetRequestFromJson(json);
}

@freezed
sealed class CalculateBetResponse with _$CalculateBetResponse {
  const factory CalculateBetResponse({
    @JsonKey(name: 'minStake', fromJson: _numToInt) @Default(0) int minStake,
    @JsonKey(name: 'maxStake', fromJson: _numToInt) @Default(0) int maxStake,
    @JsonKey(name: 'maxPayout') @Default(0) int maxPayout,
    @JsonKey(name: 'displayOdds') @Default('') String displayOdds,
    @JsonKey(name: 'trueOdds') double? trueOdds,
    @JsonKey(name: 'errorCode') @Default(0) int errorCode,
    String? message,
    @JsonKey(name: 'minMatches') @Default(2) int minMatches,
    @JsonKey(name: 'maxMatches') @Default(10) int maxMatches,
    @JsonKey(name: 'selectionIdOdds') Map<String, String>? selectionIdOdds,
  }) = _CalculateBetResponse;

  factory CalculateBetResponse.fromJson(Map<String, dynamic> json) =>
      _$CalculateBetResponseFromJson(json);
}

int _numToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.floor();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

@freezed
sealed class PlaceBetRequest with _$PlaceBetRequest {
  const factory PlaceBetRequest({
    @JsonKey(name: 'acceptBetterOdds') @Default(true) bool acceptBetterOdds,
    @JsonKey(name: 'acceptMaxStake') @Default(true) bool acceptMaxStake,
    @JsonKey(name: 'matchId') required int matchId,
    @JsonKey(name: 'selections') required List<BetSelectionModel> selections,
    @JsonKey(name: 'singleBet') @Default(true) bool singleBet,
    @JsonKey(name: 'parlay') @Default(false) bool parlay,
    @JsonKey(name: 'acceptAllOdds') @Default(true) bool acceptAllOdds,
  }) = _PlaceBetRequest;

  factory PlaceBetRequest.fromJson(Map<String, dynamic> json) =>
      _$PlaceBetRequestFromJson(json);
}

@freezed
sealed class PlaceBetResponse with _$PlaceBetResponse {
  const factory PlaceBetResponse({
    @JsonKey(name: 'ticketId') String? ticketId,
    required String status,
    @JsonKey(fromJson: _oddsToString) String? odds,
    @JsonKey(fromJson: _numToIntNullable) int? stake,
    @JsonKey(name: 'winning', fromJson: _numToIntNullable) int? winnings,
    @JsonKey(name: 'errorCode') @Default(0) int errorCode,
    String? message,
    @JsonKey(name: 'createdAt') String? createdAt,
    @JsonKey(name: 'values', fromJson: _valuesToDoubles) List<double>? values,
  }) = _PlaceBetResponse;

  factory PlaceBetResponse.fromJson(Map<String, dynamic> json) =>
      _$PlaceBetResponseFromJson(json);
}

String? _oddsToString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

int? _numToIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.floor();
  if (value is String) return int.tryParse(value);
  return null;
}

List<double>? _valuesToDoubles(dynamic value) {
  if (value is! List) return null;
  final result = <double>[];
  for (final e in value) {
    final d = e is num ? e.toDouble() : double.tryParse(e.toString());
    if (d != null && d > 0) result.add(d);
  }
  return result.isEmpty ? null : result;
}

extension BetSelectionModelX on BetSelectionModel {
  double get oddsValue => double.tryParse(displayOdds) ?? 0.0;

  double calculateWinnings(double stakeAmount) {
    final odds = oddsValue;
    if (stakeAmount <= 0 || odds == 0) return 0;
    switch (oddsStyle) {
      case 'ma':
        if (odds > 0 && odds <= 1) return stakeAmount * odds + stakeAmount;
        if (odds < 0) return stakeAmount + stakeAmount * -odds;
        return stakeAmount;
      case 'in':
        if (odds >= 1) return stakeAmount * odds + stakeAmount;
        if (odds < -1) return stakeAmount + stakeAmount * -odds;
        return stakeAmount;
      case 'hk':
        return stakeAmount * odds + stakeAmount;
      default:
        return stakeAmount * odds;
    }
  }

  Map<String, dynamic> toRequestJson(double stakeAmount) {
    final winningsValue = winnings ?? calculateWinnings(stakeAmount);
    return {
      'homeScore': homeScore?.toString() ?? '0',
      'awayScore': awayScore?.toString() ?? '0',
      'cls': cls,
      'displayOdds': oddsValue,
      'oddsStyle': oddsStyle,
      'selectionId': selectionId,
      'selectionName': selectionName,
      'offerId': offerId,
      'stake': stakeAmount.toInt(),
      'trueOdds': 0,
      'winnings': winningsValue.round(),
      'sportId': sportId,
    };
  }
}

extension CalculateBetResponseX on CalculateBetResponse {
  bool get isSuccess => errorCode == 0;

  double get minStakeK => minStake / 1000.0;

  double get maxStakeK => maxStake / 1000.0;

  double get maxPayoutK => maxPayout / 1000.0;
}

extension PlaceBetResponseX on PlaceBetResponse {
  bool get isSuccess {
    if (ticketId != null && ticketId!.isNotEmpty && errorCode == 0) {
      return true;
    }
    final validStatuses = ['Active', 'SUCCESS', 'Pending', 'Accepted'];
    return validStatuses.contains(status) && errorCode == 0;
  }

  bool get oddsChanged => errorCode == 1002;

  bool get insufficientBalance => errorCode == 1001;

  double? get serverCurrentOdds {
    final v = values;
    if (v == null || v.length < 2) return null;
    return v.last;
  }
}
