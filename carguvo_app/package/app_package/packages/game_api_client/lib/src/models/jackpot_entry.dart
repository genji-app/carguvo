part of 'models.dart';

@freezed
abstract class JackpotEntry with _$JackpotEntry {
  const factory JackpotEntry({
    @JsonKey(name: 'gameId', fromJson: _parseInt) @Default(0) int gameId,

    @JsonKey(name: 'gameName') @Default('') String gameName,

    @JsonKey(name: 'balance', fromJson: _parseNum) @Default(0) num balance,

    @JsonKey(name: 'betting', fromJson: _parseNum) @Default(0) num betting,
  }) = _JackpotEntry;

  factory JackpotEntry.fromJson(Map<String, dynamic> json) => _$JackpotEntryFromJson(json);
}

extension JackpotEntryListX on List<JackpotEntry> {
  JackpotEntry? get primaryJackpot {
    if (isEmpty) return null;

    final grand = where((e) => e.betting == 0 && e.balance > 0).toList();
    if (grand.isNotEmpty) {
      return grand.reduce((a, b) => a.balance > b.balance ? a : b);
    }

    final nonZero = where((e) => e.balance > 0).toList();
    if (nonZero.isEmpty) return null;
    return nonZero.reduce((a, b) => a.balance > b.balance ? a : b);
  }

  num get totalBalance => fold<num>(0, (sum, e) => sum + e.balance);
}
