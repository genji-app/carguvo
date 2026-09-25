import 'package:intl/intl.dart';

import 'package:sun_sports/features/mini_game/messages/common/jackpot_data.dart';

const List<int> kDiamondChips = <int>[100, 1000, 10000];

const int kDiamondCellCount = 9;

int? diamondSymbolAt(List<int> symbols, int col, int row) {
  final i = row * 3 + col;
  if (i < 0 || i >= symbols.length) return null;
  return symbols[i];
}

class DiamondState {
  final int jackpot;

  final List<JackpotData> jackpots;

  final int selectedBet;

  final int accountId;

  final List<int> selectedLines;

  final List<int> symbols;

  final bool spinning;

  final List<int> winLineIds;

  final int moneyExchange;

  final int jackpotWin;

  final bool autoSpin;

  final bool fastSpin;

  final bool animating;

  const DiamondState({
    this.jackpot = 0,
    this.jackpots = const [],
    this.selectedBet = 100,
    this.accountId = 1,
    this.selectedLines = const [],
    this.symbols = const [],
    this.spinning = false,
    this.winLineIds = const [],
    this.moneyExchange = 0,
    this.jackpotWin = 0,
    this.autoSpin = false,
    this.fastSpin = false,
    this.animating = false,
  });

  int get totalBet => selectedBet * selectedLines.length;

  int get lineCount => selectedLines.length;

  bool get canSpin => selectedLines.isNotEmpty && !spinning && !animating;

  bool get busy => animating || autoSpin;

  int? symbolAt(int col, int row) => diamondSymbolAt(symbols, col, row);

  DiamondState copyWith({
    int? jackpot,
    List<JackpotData>? jackpots,
    int? selectedBet,
    int? accountId,
    List<int>? selectedLines,
    List<int>? symbols,
    bool? spinning,
    List<int>? winLineIds,
    int? moneyExchange,
    int? jackpotWin,
    bool? autoSpin,
    bool? fastSpin,
    bool? animating,
  }) {
    return DiamondState(
      jackpot: jackpot ?? this.jackpot,
      jackpots: jackpots ?? this.jackpots,
      selectedBet: selectedBet ?? this.selectedBet,
      accountId: accountId ?? this.accountId,
      selectedLines: selectedLines ?? this.selectedLines,
      symbols: symbols ?? this.symbols,
      spinning: spinning ?? this.spinning,
      winLineIds: winLineIds ?? this.winLineIds,
      moneyExchange: moneyExchange ?? this.moneyExchange,
      jackpotWin: jackpotWin ?? this.jackpotWin,
      autoSpin: autoSpin ?? this.autoSpin,
      fastSpin: fastSpin ?? this.fastSpin,
      animating: animating ?? this.animating,
    );
  }
}

final NumberFormat _moneyFormat = NumberFormat('#,###');

String diamondMoney(int value) => _moneyFormat.format(value);

String diamondMoneyShort(int value) {
  final abs = value.abs();
  if (abs >= 1000000000) return '${_shortNum(value / 1000000000)}B';
  if (abs >= 1000000) return '${_shortNum(value / 1000000)}M';
  if (abs >= 1000) return '${_shortNum(value / 1000)}K';
  return '$value';
}

String _shortNum(double v) {
  final s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}
