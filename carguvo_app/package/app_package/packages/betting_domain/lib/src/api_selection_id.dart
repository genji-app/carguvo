library;

const Set<int> goalscorerMarketIds = {153, 155, 156, 158, 1026, 1027};

String apiSelectionId(String selectionId, int eventId, {int marketId = 0, String playerId = ''}) {
  if (goalscorerMarketIds.contains(marketId) && playerId.isNotEmpty) {
    return '$playerId-$selectionId';
  }
  final period = deriveSelectionPeriod(selectionId, eventId);
  return period > 0 ? '$period-$selectionId' : selectionId;
}

int deriveSelectionPeriod(String selectionId, int eventId) {
  if (eventId <= 0 || selectionId.isEmpty) return 0;
  final eidStr = eventId.toString();
  if (selectionId.length < eidStr.length) return 0;
  final sub = int.tryParse(selectionId.substring(0, eidStr.length));
  if (sub == null) return 0;
  final period = sub - eventId;
  return (period > 0 && period < 100) ? period : 0;
}
