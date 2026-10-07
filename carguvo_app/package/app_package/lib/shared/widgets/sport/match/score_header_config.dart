class ScoreHeaderConfig {
  final List<String> columns;
  final bool hasPts;
  final String totalLabel;

  final String? prefixColumn;

  static const double columnWidth = 28.0;

  static const double columnGap = 2.5;

  static const double columnGapDesktop = 16.0;

  const ScoreHeaderConfig({
    required this.columns,
    required this.hasPts,
    this.totalLabel = 'Tổng',
    this.prefixColumn,
  });

  int get totalColumnCount =>
      (prefixColumn != null ? 1 : 0) + columns.length + (hasPts ? 1 : 0) + 1;

  double totalWidth({bool isDesktop = false}) =>
      totalColumnCount * columnWidth +
      (totalColumnCount - 1) * (isDesktop ? columnGapDesktop : columnGap);

  static ScoreHeaderConfig forSport(int sportId) => switch (sportId) {
    2 => const ScoreHeaderConfig(
      columns: ['Q1', 'Q2', 'H1', 'Q3', 'Q4'],
      hasPts: false,
    ),
    4 => const ScoreHeaderConfig(
      columns: ['S1', 'S2', 'S3', 'S4', 'S5'],
      hasPts: true,
      prefixColumn: 'Set',
    ),
    5 => const ScoreHeaderConfig(
      columns: ['S1', 'S2', 'S3', 'S4', 'S5'],
      hasPts: false,
    ),
    7 => const ScoreHeaderConfig(columns: ['G1', 'G2', 'G3'], hasPts: false),
    _ => const ScoreHeaderConfig(columns: [], hasPts: false),
  };
}
