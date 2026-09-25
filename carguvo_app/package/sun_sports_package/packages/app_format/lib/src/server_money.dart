library;

int floorToThousand(int amount) {
  if (amount <= 0) return 0;
  return (amount ~/ 1000) * 1000;
}

int serverToActual(num serverValue) => (serverValue * 1000).toInt();

num actualToServer(int actualValue) => actualValue / 1000;

String formatServerMoney(num serverValue) {
  if (serverValue >= 1000) {
    final millions = serverValue / 1000;
    if (millions == millions.roundToDouble()) return '${millions.toInt()}M';
    return '${millions.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
  }
  if (serverValue == serverValue.toInt()) return '${serverValue.toInt()}K';
  return '${serverValue.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
}

const stakeNormalizeDebounce = Duration(milliseconds: 1000);
