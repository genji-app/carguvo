import 'dart:math' show min;

import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';

int dragonBallDecodeSymbol(int serverCode) {
  if (serverCode == 1) return 2;
  if (serverCode == 2) return 1;
  return serverCode;
}

String? dragonBallSymbolAsset(int displayCode) {
  switch (displayCode) {
    case 0:
      return MiniGameIcons.dbSymbolGoku;
    case 1:
      return MiniGameIcons.dbSymbolPiccolo;
    case 2:
      return MiniGameIcons.dbSymbolVegeta;
    case 3:
      return MiniGameIcons.dbSymbolYoungGoku;
    case 4:
      return MiniGameIcons.dbSymbolX3;
    case 5:
      return MiniGameIcons.dbSymbolX5;
    case 6:
      return MiniGameIcons.dbSymbolX10;
    case 7:
      return MiniGameIcons.dbSymbolWild;
    case 8:
      return MiniGameIcons.dbSymbolFrieza;
    default:
      return null;
  }
}

String dragonBallSymbolName(int displayCode) {
  switch (displayCode) {
    case 0:
      return 'GOKU';
    case 1:
      return 'PICO';
    case 2:
      return 'VEGE';
    case 3:
      return 'GOHA';
    case 4:
      return 'X3';
    case 5:
      return 'X5';
    case 6:
      return 'X10';
    case 7:
      return 'WILD';
    case 8:
      return 'FRIE';
    default:
      return '?$displayCode';
  }
}

const List<List<int>> kDragonBallLineTable = [
  [2, 2, 2], [1, 1, 1], [0, 0, 0], [2, 0, 2], [0, 2, 0],
  [2, 1, 2], [2, 1, 0], [0, 1, 2], [1, 0, 1], [1, 2, 1],
  [0, 1, 0], [2, 2, 1], [1, 1, 0], [1, 1, 2], [0, 0, 1],
  [1, 2, 2], [0, 1, 1], [2, 1, 1], [1, 0, 0], [2, 0, 1],
];

const Color kDragonBallLineColor = Color(0xFFFF993B);
const double kDragonBallLineWidth = 3;

class DragonBallSymbol extends StatelessWidget {
  final String? asset;
  final double size;

  const DragonBallSymbol({required this.asset, this.size = 40, super.key});

  static const double _kInnerInset = 2;

  @override
  Widget build(BuildContext context) {
    final a = asset;
    if (a == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
        ),
      );
    }
    final inner = (size - _kInnerInset * 2).clamp(0.0, size);
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: ImageHelper.load(
          path: a,
          width: inner,
          height: inner,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class DragonBallResultBox extends StatelessWidget {
  final List<int> symbols;
  final List<int> winLineIds;
  final double symbolSize;

  final List<int>? Function(int lid)? lineRowsResolver;

  const DragonBallResultBox({
    required this.symbols,
    this.winLineIds = const [],
    this.symbolSize = 44,
    this.lineRowsResolver,
    super.key,
  });

  static const double _padH = 10;
  static const double _padV = 12;

  static const double _kMinCellGap = 4;

  static const double _kCardGap = 8;

  static const Color _kDimColor = Color(0xB3000000);

  double _resolveSymbolSize(double totalWidth) {
    final avail = totalWidth - _kCardGap;
    if (avail <= 0) return symbolSize;
    final iconInner = avail * 3 / 5 - _padH * 2;
    final multInner = avail * 2 / 5 - _padH * 2;
    final fromIcon = (iconInner - _kMinCellGap * 2) / 3;
    final fromMult = (multInner - _kMinCellGap * 3) / 2;
    final fitted = min(symbolSize, min(fromIcon, fromMult));
    return fitted.clamp(0.0, symbolSize);
  }

  int? _serverCodeAt(int col, int row) {
    final i = row * 5 + col;
    if (i < 0 || i >= symbols.length) return null;
    return symbols[i];
  }

  Widget _cell(int col, int row, {required bool dimmed, required double size}) {
    final code = _serverCodeAt(col, row);
    final symbol = DragonBallSymbol(
      asset: code == null
          ? null
          : dragonBallSymbolAsset(dragonBallDecodeSymbol(code)),
      size: size,
    );
    if (!dimmed) return symbol;
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(_kDimColor, BlendMode.srcATop),
      child: symbol,
    );
  }

  List<int>? _rowsFor(int lid) {
    final resolver = lineRowsResolver;
    if (resolver != null) return resolver(lid);
    if (lid >= 0 && lid < kDragonBallLineTable.length) {
      return kDragonBallLineTable[lid];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final winRows = winLineIds
        .map(_rowsFor)
        .whereType<List<int>>()
        .toList(growable: false);
    final hasWins = winRows.isNotEmpty;

    final winningCells = <int>{};
    for (final rows in winRows) {
      for (var col = 0; col < 3 && col < rows.length; col++) {
        winningCells.add(rows[col] * 5 + col);
      }
    }

    bool dimIcon(int col, int row) =>
        hasWins && !winningCells.contains(row * 5 + col);

    bool dimMultiplier(int row) => hasWins && row != 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = _resolveSymbolSize(constraints.maxWidth);
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFF171614),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CustomPaint(
                    painter: hasWins
                        ? _DragonBallLinePainter(
                            lineRows: winRows,
                            symbolSize: size,
                            padH: _padH,
                            padV: _padV,
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _padH,
                        vertical: _padV,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var row = 0; row < 3; row++)
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                for (var col = 0; col < 3; col++)
                                  _cell(
                                    col,
                                    row,
                                    dimmed: dimIcon(col, row),
                                    size: size,
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: _kCardGap),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _padH,
                    vertical: _padV,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171614),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var row = 0; row < 3; row++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (var col = 3; col < 5; col++)
                              _cell(
                                col,
                                row,
                                dimmed: dimMultiplier(row),
                                size: size,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DragonBallWinLineOverlay extends StatelessWidget {
  final List<List<int>> lineRows;

  final double iconLeftFrac;
  final double iconTopFrac;
  final double iconWidthFrac;
  final double iconHeightFrac;

  const DragonBallWinLineOverlay({
    required this.lineRows,
    this.iconLeftFrac = 0.02,
    this.iconTopFrac = 0.06,
    this.iconWidthFrac = 0.58,
    this.iconHeightFrac = 0.88,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (lineRows.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _DragonBallWinLinePainter(
          lineRows: lineRows,
          iconLeftFrac: iconLeftFrac,
          iconTopFrac: iconTopFrac,
          iconWidthFrac: iconWidthFrac,
          iconHeightFrac: iconHeightFrac,
        ),
      ),
    );
  }
}

class _DragonBallWinLinePainter extends CustomPainter {
  final List<List<int>> lineRows;
  final double iconLeftFrac;
  final double iconTopFrac;
  final double iconWidthFrac;
  final double iconHeightFrac;

  const _DragonBallWinLinePainter({
    required this.lineRows,
    required this.iconLeftFrac,
    required this.iconTopFrac,
    required this.iconWidthFrac,
    required this.iconHeightFrac,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * iconLeftFrac;
    final top = size.height * iconTopFrac;
    final gridW = size.width * iconWidthFrac;
    final gridH = size.height * iconHeightFrac;
    if (gridW <= 0 || gridH <= 0) return;

    double cx(int col) => left + (col + 0.5) / 3 * gridW;
    double cy(int row) => top + (row + 0.5) / 3 * gridH;

    final paint = Paint()
      ..color = kDragonBallLineColor
      ..strokeWidth = kDragonBallLineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final rows in lineRows) {
      if (rows.length < 2) continue;
      final path = Path()..moveTo(cx(0), cy(rows[0]));
      for (var col = 1; col < rows.length && col < 3; col++) {
        path.lineTo(cx(col), cy(rows[col]));
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_DragonBallWinLinePainter oldDelegate) =>
      oldDelegate.lineRows != lineRows ||
      oldDelegate.iconLeftFrac != iconLeftFrac ||
      oldDelegate.iconTopFrac != iconTopFrac ||
      oldDelegate.iconWidthFrac != iconWidthFrac ||
      oldDelegate.iconHeightFrac != iconHeightFrac;
}

class _DragonBallLinePainter extends CustomPainter {
  final List<List<int>> lineRows;
  final double symbolSize;
  final double padH;
  final double padV;

  const _DragonBallLinePainter({
    required this.lineRows,
    required this.symbolSize,
    required this.padH,
    required this.padV,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final innerW = size.width - padH * 2;
    final innerH = size.height - padV * 2;
    if (innerW <= symbolSize || innerH <= symbolSize) return;
    final stepX = (innerW - symbolSize) / 2;
    final stepY = (innerH - symbolSize) / 2;

    final paint = Paint()
      ..color = kDragonBallLineColor
      ..strokeWidth = kDragonBallLineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final rows in lineRows) {
      if (rows.length < 3) continue;
      final path = Path();
      for (var col = 0; col < 3; col++) {
        final row = rows[col];
        final x = padH + col * stepX + symbolSize / 2;
        final y = padV + row * stepY + symbolSize / 2;
        if (col == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_DragonBallLinePainter oldDelegate) =>
      oldDelegate.lineRows != lineRows ||
      oldDelegate.symbolSize != symbolSize;
}
