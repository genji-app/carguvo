library;

class MarketLabels {
  MarketLabels._();

static String? comboCellLabel(
    int marketId,
    String points, {
    String? homeName,
    String? awayName,
  }) {
    final home = (homeName == null || homeName.isEmpty) ? 'Nhà' : homeName;
    final away = (awayName == null || awayName.isEmpty) ? 'Khách' : awayName;
    if (marketId == 81 && points.length == 2) {
      final result = switch (points[0]) {
        '1' => home,
        '2' => 'Hòa',
        '3' => away,
        _ => null,
      };
      final btts = switch (points[1]) {
        '4' => 'Có',
        '5' => 'Không',
        _ => null,
      };
      if (result != null && btts != null) return '$btts & $result';
    }
    if (marketId == 98 && points.length == 2) {
      final dc = switch (points[0]) {
        '1' => '$home/Hòa',
        '2' => '$home/$away',
        '3' => '$away/Hòa',
        _ => null,
      };
      final btts = switch (points[1]) {
        '4' => 'Có',
        '5' => 'Không',
        _ => null,
      };
      if (dc != null && btts != null) return '$btts & $dc';
    }
    if (marketId == 82) {
      final parts = points.split(':');
      if (parts.length == 2 && (parts[0] == '6' || parts[0] == '3')) {
        return '$home/Tài (${parts[1]})';
      }
    }
    return null;
  }

static String comboSelectionName(int marketId, String points) {
    if (marketId == 81 && points.length == 2) {
      final result = switch (points[0]) {
        '1' => 'H',
        '2' => 'D',
        '3' => 'A',
        _ => null,
      };
      final btts = switch (points[1]) {
        '4' => 'Y',
        '5' => 'N',
        _ => null,
      };
      if (result != null && btts != null) return '$result$btts';
    }
    if (marketId == 98 && points.length == 2) {
      final dc = switch (points[0]) {
        '1' => 'Home/Draw',
        '2' => 'Home/Away',
        '3' => 'Away/Draw',
        _ => null,
      };
      final btts = switch (points[1]) {
        '4' => 'Yes',
        '5' => 'No',
        _ => null,
      };
      if (dc != null && btts != null) return '$dc & $btts';
    }
    if (marketId == 82 && (points.startsWith('6:') || points.startsWith('3:'))) {
      return 'Home/Over';
    }
    return points;
  }

static int comboSortKey(String points) {
    if (points.length == 2) {
      final d1 = int.tryParse(points[0]) ?? 9;
      final d2 = points[1] == '4' ? 0 : 1;
      return d1 * 2 + d2;
    }
    return int.tryParse(points.split(':').first) ?? 99;
  }

static String htFtLabel(String points, {String? homeName, String? awayName}) {
    final home = (homeName == null || homeName.isEmpty) ? 'Nhà' : homeName;
    final away = (awayName == null || awayName.isEmpty) ? 'Khách' : awayName;
    String? part(String digit) => switch (digit) {
          '1' => home,
          '2' => away,
          '3' => 'Hòa',
          _ => null,
        };
    if (points.length == 2) {
      final first = part(points[0]);
      final second = part(points[1]);
      if (first != null && second != null) return '$first/$second';
    }
    return points;
  }

static String htFtSelectionCode(String points) {
    String? code(String digit) => switch (digit) {
          '1' => 'H',
          '2' => 'A',
          '3' => 'D',
          _ => null,
        };
    if (points.length == 2) {
      final first = code(points[0]);
      final second = code(points[1]);
      if (first != null && second != null) return '$first$second';
    }
    return points;
  }

static int htFtSortKey(String points) {
    int order(String digit) => switch (digit) {
          '1' => 0,
          '3' => 1,
          '2' => 2,
          _ => 3,
        };
    if (points.length != 2) return 99;
    return order(points[0]) * 3 + order(points[1]);
  }

static String totalScoreLabel(String points) {
    if (points.length >= 3 && points[1] == ':') {
      final from = points[0];
      final to = points[2];
      return from == to ? from : '$from-$to';
    }
    return points;
  }

  static bool isCombo(int id) => const [81, 82, 98].contains(id);
}

class CorrectScoreLabels {
  CorrectScoreLabels._();

static bool isAOS(String points) => points == '9:9';

static bool isWinningMargin(int marketId) => marketId == 1017;

static String marginDisplayText(String points) {
    final n = int.tryParse(points) ?? 0;
    final margin = n > 3 ? n - 3 : n;
    return margin >= 3 ? '3+' : '$margin';
  }

static bool marginIsHome(String points) => (int.tryParse(points) ?? 0) <= 3;

static String getDisplayText(String points, {int marketId = 0}) {
    if (isWinningMargin(marketId)) return marginDisplayText(points);
    if (points == '9:9') return 'AOS';
    return points.replaceAll(':', '-');
  }

static (int homeScore, int awayScore)? parseScores(String points) {
    var parts = points.split(':');
    if (parts.length != 2) {
      parts = points.split('-');
    }
    if (parts.length != 2) return null;

    final homeScore = int.tryParse(parts[0]);
    final awayScore = int.tryParse(parts[1]);
    if (homeScore == null || awayScore == null) return null;

    return (homeScore, awayScore);
  }
}
