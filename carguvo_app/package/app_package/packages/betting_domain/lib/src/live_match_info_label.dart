library;

bool isCornerMarketFull(int marketId) => [
      17, 18, 19, 20, 21, 22,
      56, 57,
      61, 62, 63, 64,
      66, 67,
      92, 93, 94, 95, 96,
      104, 105, 106, 107, 108, 109, 110, 111,
      112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125,
      126, 127, 128,
      131, 134, 135, 136,
      137,
      140, 141, 142, 144,
      145,
      197, 198,
      199, 1005,
      90, 91,
    ].contains(marketId);

bool isCardMarketFull(int marketId) =>
    const [29, 30, 31, 32, 33, 34, 138, 139, 143].contains(marketId);

String liveMatchInfoLabel({
  required int marketId,
  required String homeName,
  required String awayName,
  required int homeScore,
  required int awayScore,
  required int cornersHome,
  required int cornersAway,
  required int yellowCardsHome,
  required int yellowCardsAway,
  required int redCardsHome,
  required int redCardsAway,
}) {
  if (isCornerMarketFull(marketId)) {
    if (marketId == 61 || marketId == 62 || marketId == 134) {
      return '$homeName: $cornersHome phạt góc';
    }
    if (marketId == 63 || marketId == 64 || marketId == 135) {
      return '$awayName: $cornersAway phạt góc';
    }
    return 'Tổng: ${cornersHome + cornersAway} phạt góc';
  }

  if (isCardMarketFull(marketId)) {
    final bookings =
        (redCardsHome + redCardsAway) * 2 +
        (yellowCardsHome + yellowCardsAway);
    return 'Tổng: $bookings thẻ phạt';
  }

  return '$homeScore-$awayScore';
}
