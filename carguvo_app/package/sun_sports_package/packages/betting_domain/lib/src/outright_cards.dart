library;

class OutrightSelection {
  final String selectionId;
  final String selectionName;
  final String logoUrl;
  final String offerId;
  final double odds;
  final String selectionCode;

  const OutrightSelection({
    required this.selectionId,
    required this.selectionName,
    required this.logoUrl,
    required this.offerId,
    required this.odds,
    required this.selectionCode,
  });
}

class OutrightCard {
  final int outrightId;
  final int eventId;
  final String outrightName;

  final String eventName;
  final int lineOrder;

  final String endDate;

  final int startTime;
  final int leagueId;
  final String leagueLogo;
  final String leagueName;
  final List<OutrightSelection> selections;

  const OutrightCard({
    required this.outrightId,
    required this.eventId,
    required this.outrightName,
    required this.eventName,
    required this.lineOrder,
    required this.endDate,
    required this.startTime,
    required this.leagueId,
    required this.leagueLogo,
    required this.leagueName,
    required this.selections,
  });
}

List<OutrightCard> parseOutrightCards(List<dynamic> rawList) {
  final cards = <OutrightCard>[];
  for (final leagueRaw in rawList) {
    if (leagueRaw is! Map) continue;
    final leagueId = _safeInt(leagueRaw['2']);
    final leagueLogo = leagueRaw['3']?.toString() ?? '';
    final leagueName = leagueRaw['4']?.toString() ?? '';
    final events = leagueRaw['0'];
    if (events is! List) continue;

    for (final eventRaw in events) {
      if (eventRaw is! Map) continue;
      final eventId = _safeInt(eventRaw['3']);
      final eventName = eventRaw['4']?.toString() ?? '';
      final endDate = eventRaw['6']?.toString() ?? '';
      final endTime = _safeInt(eventRaw['7']);
      final lines = eventRaw['0'];
      if (lines is! List) continue;

      var lineIndex = 0;
      for (final lineRaw in lines) {
        if (lineRaw is! Map) continue;
        final i = lineIndex++;
        final selectionsRaw = lineRaw['0'];
        final selections = <OutrightSelection>[
          if (selectionsRaw is List)
            for (final s in selectionsRaw)
              if (s is Map)
                OutrightSelection(
                  selectionId: s['0']?.toString() ?? '',
                  selectionName: s['1']?.toString() ?? '',
                  logoUrl: s['2']?.toString() ?? '',
                  offerId: s['3']?.toString() ?? '',
                  odds: _safeDouble(s['4']),
                  selectionCode: s['5']?.toString() ?? '',
                ),
        ];
        if (selections.isEmpty) continue;

        cards.add(
          OutrightCard(
            outrightId: eventId * 1000 + i,
            eventId: eventId,
            outrightName: lineRaw['1']?.toString() ?? '',
            eventName: eventName,
            lineOrder: _safeInt(lineRaw['2']),
            endDate: endDate,
            startTime: endTime,
            leagueId: leagueId,
            leagueLogo: leagueLogo,
            leagueName: leagueName,
            selections: selections,
          ),
        );
      }
    }
  }
  return cards;
}

int _safeInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _safeDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
