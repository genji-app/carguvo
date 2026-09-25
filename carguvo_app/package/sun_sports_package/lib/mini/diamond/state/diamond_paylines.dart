import 'package:flutter/material.dart';

const List<List<int>> kDiamondPaylines = <List<int>>[
  [2, 2, 2],
  [1, 1, 1],
  [0, 0, 0],
  [2, 0, 2],
  [0, 2, 0],
  [2, 1, 2],
  [2, 1, 0],
  [0, 1, 2],
  [1, 0, 1],
  [1, 2, 1],
  [0, 1, 0],
  [2, 2, 1],
  [1, 1, 0],
  [1, 1, 2],
  [0, 0, 1],
  [1, 2, 2],
  [0, 1, 1],
  [2, 1, 1],
  [1, 0, 0],
  [2, 0, 1],
];

const int kDiamondLineCount = 20;

List<int> get kDiamondAllLines =>
    List<int>.generate(kDiamondLineCount, (i) => i);

const List<Color> kDiamondLineColors = <Color>[
  Color(0xFFFF5C5C), Color(0xFFFFC24B), Color(0xFF4BE0A8), Color(0xFF4BB8FF),
  Color(0xFFB98CFF), Color(0xFFFF8CD4), Color(0xFF9CE24B), Color(0xFFFFE45C),
  Color(0xFF5CD6FF), Color(0xFFFF7A4B),
];

Color diamondLineColor(int lineId) =>
    kDiamondLineColors[lineId % kDiamondLineColors.length];

Offset diamondCellCenter(int col, int row, Size size) {
  final cw = size.width / 3;
  final ch = size.height / 3;
  return Offset(cw * (col + 0.5), ch * (row + 0.5));
}

class DiamondPaylineIconPainter extends CustomPainter {
  final List<int> line;
  final Color lineColor;
  final Color cellColor;
  final Color cellBorder;

  const DiamondPaylineIconPainter({
    required this.line,
    required this.lineColor,
    this.cellColor = const Color(0xFFF3E4C6),
    this.cellBorder = const Color(0x33000000),
  });

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 1.5;
    final cw = (size.width - gap * 2) / 3;
    final ch = (size.height - gap * 2) / 3;
    final radius = Radius.circular(cw * 0.18);

    final cellPaint = Paint()..color = cellColor;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = cellBorder;
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(col * (cw + gap), row * (ch + gap), cw, ch),
          radius,
        );
        canvas.drawRRect(rect, cellPaint);
        canvas.drawRRect(rect, borderPaint);
      }
    }

    final path = Path();
    for (var col = 0; col < 3; col++) {
      final row = line[col];
      final c = Offset(
        col * (cw + gap) + cw / 2,
        row * (ch + gap) + ch / 2,
      );
      if (col == 0) {
        path.moveTo(c.dx, c.dy);
      } else {
        path.lineTo(c.dx, c.dy);
      }
    }
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(DiamondPaylineIconPainter old) =>
      old.line != line ||
      old.lineColor != lineColor ||
      old.cellColor != cellColor;
}

class DiamondWinLinesPainter extends CustomPainter {
  final List<int> winLineIds;

  const DiamondWinLinesPainter(this.winLineIds);

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0x66FFA61E)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFFFC24B);
    for (final id in winLineIds) {
      if (id < 0 || id >= kDiamondLineCount) continue;
      final def = kDiamondPaylines[id];
      final path = Path();
      for (var col = 0; col < 3; col++) {
        final c = diamondCellCenter(col, 2 - def[col], size);
        if (col == 0) {
          path.moveTo(c.dx, c.dy);
        } else {
          path.lineTo(c.dx, c.dy);
        }
      }
      canvas.drawPath(path, glow);
      canvas.drawPath(path, line);
    }
  }

  @override
  bool shouldRepaint(DiamondWinLinesPainter old) =>
      old.winLineIds != winLineIds;
}
