library;

import 'league_enums.dart';
import 'market_labels.dart';
import 'market_odds_rules.dart';

enum SelectionPick { home, away, draw }

class SelectionSpec {
  const SelectionSpec({
    required this.marketId,
    this.points = '',
    this.homeName = '',
    this.awayName = '',
    this.playerName = '',
    this.homeScore = '0',
    this.awayScore = '0',
  });

  final int marketId;

  final String points;

  final String homeName;
  final String awayName;

  final String playerName;

  final String homeScore;
  final String awayScore;
}

class SelectionLabels {
  SelectionLabels._();

  static String _pickEn(SelectionPick pick) {
    switch (pick) {
      case SelectionPick.home:
        return 'Home';
      case SelectionPick.away:
        return 'Away';
      case SelectionPick.draw:
        return 'Draw';
    }
  }

  static String selectionName(
    SelectionSpec s, {
    required SelectionPick pick,
    bool isSpecialOutright = false,
    String? playerName,
  }) {
    final id = s.marketId;
    final player = playerName ?? s.playerName;

    if (isSpecialOutright) {
      return s.homeName.isNotEmpty ? s.homeName : _pickEn(pick);
    }

    if (MarketOddsRules.isPlayerMarket(id) && player.isNotEmpty) return player;

    if (MarketOddsRules.isWindowedNextNone(id) && pick == SelectionPick.draw) {
      return 'None';
    }

    if (MarketOddsRules.isEuropeanHandicap(id)) return _pickEn(pick);

    if (MarketOddsRules.isHandicap(id)) {
      return switch (pick) {
        SelectionPick.home => s.homeName,
        SelectionPick.away => s.awayName,
        SelectionPick.draw => 'Draw',
      };
    }

    if (MarketOddsRules.isOverUnder(id)) {
      return pick == SelectionPick.home ? 'Over' : 'Under';
    }

    if (MarketOddsRules.isDoubleChance(id)) {
      return switch (pick) {
        SelectionPick.home => '1X',
        SelectionPick.away => 'X2',
        SelectionPick.draw => '12',
      };
    }

    if (MarketOddsRules.isOddEven(id)) {
      return pick == SelectionPick.home ? 'Odd' : 'Even';
    }

    if (MarketOddsRules.isCorrectScore(id)) {
      return _scoreToPick(s.points) ?? s.points;
    }

    if (MarketOddsRules.isYesNo(id)) {
      return pick == SelectionPick.home ? 'Yes' : 'No';
    }

    if (CorrectScoreLabels.isWinningMargin(id)) {
      return CorrectScoreLabels.marginIsHome(s.points) ? 'Home' : 'Away';
    }

    if (id == 150) return pick == SelectionPick.home ? 'Draw' : 'Away';
    if (id == 151) return pick == SelectionPick.home ? 'Home' : 'Draw';

    if (MarketOddsRules.isCornerRange(id)) return s.points;

    if (MarketOddsRules.isHalfTimeFullTime(id)) {
      return MarketLabels.htFtSelectionCode(s.points);
    }

    if (MarketLabels.isCombo(id)) {
      return MarketLabels.comboSelectionName(id, s.points);
    }

    if (MarketOddsRules.isOverExactlyUnder(id)) {
      return switch (pick) {
        SelectionPick.home => 'Over',
        SelectionPick.away => 'Under',
        SelectionPick.draw => 'Exact',
      };
    }

    if (id == 103 && pick == SelectionPick.draw) return 'Both Teams';

    if (id == 65 || id == 87 || id == 88) {
      if (pick == SelectionPick.home) return '1st Half';
      if (pick == SelectionPick.away) return '2nd Half';
    }

    if ((MarketOddsRules.isTotalScore(id) && id != 1007) ||
        MarketOddsRules.isExactGoals(id)) {
      final p = s.points;
      if (p.length >= 3 && p[1] == ':') {
        final from = p[0];
        final to = p[2];
        return from == to ? from : '$from-$to';
      }
      return p;
    }

    return _pickEn(pick);
  }

  static String clsFor(
    SelectionSpec s, {
    required SelectionPick pick,
    bool isSpecialOutright = false,
  }) {
    if (isSpecialOutright) return s.points;
    final parsed = double.tryParse(s.points);
    if (MarketOddsRules.isCorrectScore(s.marketId) || parsed == null) {
      return s.points;
    }
    if (s.marketId == 68 || MarketLabels.isCombo(s.marketId)) return s.points;
    if (s.marketId == 147 || s.marketId == 1003) {
      return '${s.homeScore}:${s.awayScore}';
    }

    final abs = parsed.abs();
    var value = abs;
    if (MarketOddsRules.isHandicap(s.marketId)) {
      if (parsed > 0) {
        if (pick == SelectionPick.away) value = -abs;
      } else {
        if (pick == SelectionPick.home) value = -abs;
      }
    }
    if (value == value.floorToDouble()) return '${value.toInt()}.0';
    return value.toString();
  }

  static String slipPickLabel(SelectionSpec s, SelectionPick pick) {
    final id = s.marketId;

    if (MarketOddsRules.isPlayerMarket(id) && s.playerName.isNotEmpty) {
      return s.playerName;
    }

    if (MarketOddsRules.isCorrectScore(id)) {
      return CorrectScoreLabels.getDisplayText(s.points, marketId: id);
    }

    if (CorrectScoreLabels.isWinningMargin(id)) {
      final team =
          CorrectScoreLabels.marginIsHome(s.points) ? s.homeName : s.awayName;
      return '$team ${CorrectScoreLabels.marginDisplayText(s.points)}';
    }

    if ((MarketOddsRules.isTotalScore(id) && id != 1007) ||
        MarketOddsRules.isExactGoals(id)) {
      return MarketLabels.totalScoreLabel(s.points);
    }

    if (MarketOddsRules.isCornerRange(id)) return s.points;

    if (MarketOddsRules.isHalfTimeFullTime(id)) {
      return MarketLabels.htFtLabel(
        s.points,
        homeName: s.homeName,
        awayName: s.awayName,
      );
    }

    if (MarketLabels.isCombo(id)) {
      return MarketLabels.comboCellLabel(
            id,
            s.points,
            homeName: s.homeName,
            awayName: s.awayName,
          ) ??
          s.points;
    }

    if (id == 65 || id == 87 || id == 88) {
      if (pick == SelectionPick.home) return 'Hiệp 1';
      if (pick == SelectionPick.away) return 'Hiệp 2';
      return 'Hòa';
    }

    if (pick == SelectionPick.draw) {
      if (id == 177 || id == 190 || id == 199 || id == 1005) {
        return 'Không có phạt góc';
      }
      if (id == 178 || id == 191) return 'Không có bàn thắng';
    }

    if (MarketOddsRules.isYesNo(id)) {
      return '${pick == SelectionPick.home ? 'Có' : 'Không'}'
          '${_viPointsSuffix(s, pick)}';
    }

    if (id == 130) {
      return '${pick == SelectionPick.home ? 'Tài' : 'Xỉu'}'
          '${_viPointsSuffix(s, pick)}';
    }

    if (id == 150) return pick == SelectionPick.home ? 'Hòa' : s.awayName;
    if (id == 151) return pick == SelectionPick.home ? s.homeName : 'Hòa';

    if (MarketOddsRules.isHandicap(id)) {
      final team = pick == SelectionPick.home ? s.homeName : s.awayName;
      return '$team${_viPointsSuffix(s, pick)}';
    }

    if (MarketOddsRules.isOverUnder(id)) {
      return '${pick == SelectionPick.home ? 'Tài' : 'Xỉu'}'
          '${_viPointsSuffix(s, pick)}';
    }

    if (MarketOddsRules.isDoubleChance(id)) {
      final name = pick == SelectionPick.home
          ? '1X'
          : pick == SelectionPick.away
              ? 'X2'
              : '12';
      return '$name${_viPointsSuffix(s, pick)}';
    }

    if (MarketOddsRules.isOddEven(id)) {
      return '${pick == SelectionPick.home ? 'Lẻ' : 'Chẵn'}'
          '${_viPointsSuffix(s, pick)}';
    }

    final team = pick == SelectionPick.home
        ? s.homeName
        : pick == SelectionPick.away
            ? s.awayName
            : 'Hòa';
    return '$team${_viPointsSuffix(s, pick)}';
  }

  static String _viPointsSuffix(SelectionSpec s, SelectionPick pick) {
    final raw = s.points;
    if (raw.isEmpty) return '';
    if (double.tryParse(raw) == 0) return '';
    return ' (${_viDisplayedPoints(s, pick, raw)})';
  }

  static String _viDisplayedPoints(
    SelectionSpec s,
    SelectionPick pick,
    String raw,
  ) {
    if (!MarketOddsRules.isHandicap(s.marketId) || pick != SelectionPick.away) {
      return raw;
    }
    final value = double.tryParse(raw);
    if (value == null) return raw;
    if (value == 0) return raw.replaceFirst('-', '');
    return raw.startsWith('-') ? raw.substring(1) : '-$raw';
  }

  static String? _scoreToPick(String points) {
    final scores = points.split(RegExp(r'[:\-]'));
    if (scores.length < 2) return null;
    final first = int.tryParse(scores[0]) ?? 0;
    final second = int.tryParse(scores[1]) ?? 0;
    if (first > second) return 'Home';
    if (first < second) return 'Away';
    return 'Draw';
  }

  static SelectionPick _mapPick(OddsType t) => switch (t) {
        OddsType.away => SelectionPick.away,
        OddsType.draw => SelectionPick.draw,
        _ => SelectionPick.home,
      };

  static String apiSelectionName({
    required int marketId,
    required OddsType pick,
    required String points,
    required String homeName,
    required String awayName,
    String playerName = '',
    String homeScore = '0',
    String awayScore = '0',
    bool isSpecialOutright = false,
  }) {
    final s = SelectionSpec(
      marketId: marketId,
      points: points,
      homeName: homeName,
      awayName: awayName,
      playerName: playerName,
      homeScore: homeScore,
      awayScore: awayScore,
    );
    return selectionName(s, pick: _mapPick(pick), isSpecialOutright: isSpecialOutright);
  }

  static String displayLabel({
    required int marketId,
    required OddsType pick,
    required String points,
    required String homeName,
    required String awayName,
    required String playerName,
    String homeScore = '0',
    String awayScore = '0',
  }) {
    final s = SelectionSpec(
      marketId: marketId,
      points: points,
      homeName: homeName,
      awayName: awayName,
      playerName: playerName,
      homeScore: homeScore,
      awayScore: awayScore,
    );
    return slipPickLabel(s, _mapPick(pick));
  }

  static String clsValue({
    required int marketId,
    required OddsType pick,
    required String points,
    String homeScore = '0',
    String awayScore = '0',
    bool isSpecialOutright = false,
  }) {
    final s = SelectionSpec(
      marketId: marketId,
      points: points,
      homeScore: homeScore,
      awayScore: awayScore,
    );
    return clsFor(s, pick: _mapPick(pick), isSpecialOutright: isSpecialOutright);
  }
}
