import 'volta_models.dart';

class VoltaHistoryGrid {
  const VoltaHistoryGrid._();

  static const int columns = 12;

  static const int rows = 4;

  static const int rowsWebDesktop = 6;

  static const int maxCells = rows * columns;

  static const int retentionCells = rowsWebDesktop * columns;

  static int maxCellsOf(int rowCount) => rowCount * columns;

  static int cellOfAge(int age, {int rowCount = rows}) {
    if (age < 0 || age >= maxCellsOf(rowCount)) return -1;
    final int row = age ~/ columns;
    final int k = age % columns;
    final int column = row.isEven ? (columns - 1 - k) : k;
    return row * columns + column;
  }

  static List<VoltaWinner?> layout(
    List<VoltaWinner> oldestFirst, {
    int rowCount = rows,
  }) {
    final int cap = maxCellsOf(rowCount);
    final List<VoltaWinner?> cells =
        List<VoltaWinner?>.filled(cap, null, growable: false);
    final int count = oldestFirst.length < cap ? oldestFirst.length : cap;
    for (int age = 0; age < count; age++) {
      final VoltaWinner winner = oldestFirst[oldestFirst.length - 1 - age];
      final int cell = cellOfAge(age, rowCount: rowCount);
      if (cell >= 0) cells[cell] = winner;
    }
    return List<VoltaWinner?>.unmodifiable(cells);
  }

  static ({int home, int away}) percents(
    List<VoltaWinner> oldestFirst, {
    int rowCount = rows,
  }) {
    final int cap = maxCellsOf(rowCount);
    final int count = oldestFirst.length < cap ? oldestFirst.length : cap;
    if (count == 0) return (home: 50, away: 50);

    int home = 0;
    for (int i = oldestFirst.length - count; i < oldestFirst.length; i++) {
      if (oldestFirst[i] == VoltaWinner.home) home++;
    }
    final int homePercent = (home / count * 100).round();
    return (home: homePercent, away: 100 - homePercent);
  }

  static List<VoltaWinner> fromCodes(List<Object?> raw) => List<VoltaWinner>
      .unmodifiable(raw.map(
        (Object? code) =>
            code == 'H' ? VoltaWinner.home : VoltaWinner.away,
      ));
}
