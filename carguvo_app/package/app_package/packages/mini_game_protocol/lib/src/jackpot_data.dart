import 'package:freezed_annotation/freezed_annotation.dart';

part 'jackpot_data.freezed.dart';

@freezed
sealed class JackpotData with _$JackpotData {
  const factory JackpotData({
    @Default(0) int jackpot,
    @Default(0) int accountId,
    @Default(0) int bet,
  }) = _JackpotData;
}

List<JackpotData> parseJackpotList(dynamic raw) {
  if (raw is! List) return const [];
  final result = <JackpotData>[];
  for (final e in raw) {
    if (e is! Map) continue;
    final dict = Map<String, dynamic>.from(e);
    result.add(JackpotData(
      jackpot: (dict['J'] as num?)?.toInt() ?? 0,
      accountId: (dict['aid'] as num?)?.toInt() ?? 0,
      bet: (dict['b'] as num?)?.toInt() ?? 0,
    ));
  }
  return result;
}
