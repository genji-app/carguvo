import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/diamond/state/diamond_history_provider.dart';
import 'package:sun_sports/mini/diamond/state/diamond_paylines.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

final DateFormat _detailTimeFormat = DateFormat('HH:mm:ss, dd/MM/yy');

class DiamondHistoryDetail extends StatelessWidget {
  final DiamondHistoryRecord record;
  final VoidCallback onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DiamondHistoryDetail({
    required this.record,
    required this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF252423),
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: AspectRatio(
                  aspectRatio: 250 / 244,
                  child: DiamondDetailMatrix(
                  key: ValueKey(record.sessionId),
                  symbols: record.symbols,
                  winLineIds: record.winLineIds,
                ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _infoTable(),
          ),
        ],
      ),
    );
  }

  Widget _header() => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text(
              '#${record.sessionId}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 28 / 18,
                color: kDiamondTextPrimary,
              ),
            ),
            const Spacer(),
            DiamondIconButton(
              iconPath: MiniGameIcons.diamondClose,
              onTap: SoundTap.wrap(onBack),
            ),
          ],
        ),
      );

  Widget _infoTable() {
    final rows = <(String, String, bool)>[
      (I18n.diamondTime, _detailTimeFormat.format(record.betTime.toLocal()), false),
      (I18n.diamondBetLevel, diamondMoney(record.bet), true),
      (I18n.diamondLinesBet, '${record.numLines}', false),
      (I18n.diamondTotalBet, diamondMoney(record.totalBet), true),
      (I18n.diamondLinesWon, '${record.winLineCount}', false),
      (I18n.diamondWinMoney, diamondMoney(record.money), true),
    ];
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          _infoRow(
            rows[i].$1,
            rows[i].$2,
            gold: rows[i].$3,
            divider: i < rows.length - 1,
          ),
      ],
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    required bool gold,
    required bool divider,
  }) {
    return Container(
      decoration: divider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF393836))),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 20 / 14,
                color: kDiamondTextSecondary,
              ),
            ),
          ),
          if (gold)
            DiamondGoldAmount(value)
          else
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 20 / 14,
                color: kDiamondTextPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

class DiamondDetailMatrix extends StatefulWidget {
  final List<int> symbols;
  final List<int> winLineIds;

  const DiamondDetailMatrix({
    required this.symbols,
    required this.winLineIds,
    super.key,
  });

  @override
  State<DiamondDetailMatrix> createState() => _DiamondDetailMatrixState();
}

class _DiamondDetailMatrixState extends State<DiamondDetailMatrix> {
  Timer? _cycleTimer;
  int _cycleIdx = 0;

  @override
  void initState() {
    super.initState();
    _startCycle();
  }

  @override
  void didUpdateWidget(DiamondDetailMatrix old) {
    super.didUpdateWidget(old);
    if (old.winLineIds != widget.winLineIds) {
      _cycleIdx = 0;
      _startCycle();
    }
  }

  void _startCycle() {
    _cycleTimer?.cancel();
    if (widget.winLineIds.length < 2) return;
    _cycleTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_cycleIdx >= widget.winLineIds.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _cycleIdx += 1);
    });
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    super.dispose();
  }

  int? _at(int col, int row) {
    final i = row * 3 + col;
    final symbols = widget.symbols;
    return (i >= 0 && i < symbols.length) ? symbols[i] : null;
  }

  @override
  Widget build(BuildContext context) {
    final wins = widget.winLineIds;
    final overlay = wins.isEmpty
        ? const <int>[]
        : <int>[wins[_cycleIdx.clamp(0, wins.length - 1)]];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A19),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0), width: 0.5),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x4D000000),
            Color(0x00000000),
            Color(0x00000000),
            Color(0x14FFFFFF),
          ],
          stops: [0, 0.06, 0.94, 1],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Stack(
        children: [
          if (overlay.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: DiamondWinLinesPainter(overlay),
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var col = 0; col < 3; col++) ...[
                Expanded(
                  child: Column(
                    children: List.generate(3, (row) {
                      final code = _at(col, 2 - row);
                      return Expanded(
                        child: LayoutBuilder(
                          builder: (context, c) => Center(
                            child: code == null
                                ? const SizedBox.shrink()
                                : ImageHelper.load(
                                    path: diamondSymbolAsset(code),
                                    height: c.maxHeight * 0.65,
                                    fit: BoxFit.fitHeight,
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (col < 2) const _DetailMatrixDivider(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailMatrixDivider extends StatelessWidget {
  const _DetailMatrixDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00FFFFFF), Color(0x1FFFFFFF), Color(0x00FFFFFF)],
          ),
        ),
      );
}
