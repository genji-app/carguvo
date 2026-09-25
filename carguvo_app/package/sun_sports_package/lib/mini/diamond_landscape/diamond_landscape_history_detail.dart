import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/mini/diamond/diamond_history_detail.dart';
import 'package:sun_sports/mini/diamond/state/diamond_history_provider.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/mini/diamond_landscape/widgets/diamond_landscape_list_scaffold.dart';

final DateFormat _detailTimeFormat = DateFormat('HH:mm:ss, dd/MM/yy');

class DiamondLandscapeHistoryDetail extends StatelessWidget {
  final DiamondHistoryRecord record;
  final VoidCallback onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DiamondLandscapeHistoryDetail({
    required this.record,
    required this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  static const double _kMatrixWidth = 200;
  static const double _kMatrixHeight = 195.2;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: borderRadius,
      ),
      child: Column(
        children: [
          DiamondLandscapeSubHeader(
            title: '#${record.sessionId}',
            onBack: onBack,
            onClose: onClose,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: _kMatrixWidth,
                    child: AspectRatio(
                      aspectRatio: _kMatrixWidth / _kMatrixHeight,
                      child: DiamondDetailMatrix(
                        key: ValueKey(record.sessionId),
                        symbols: record.symbols,
                        winLineIds: record.winLineIds,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _infoTable()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTable() {
    final rows = <(String, String, bool)>[
      (
        I18n.diamondTime,
        _detailTimeFormat.format(record.betTime.toLocal()),
        false,
      ),
      (I18n.diamondBetLevel, diamondMoney(record.bet), true),
      (I18n.diamondLinesBet, '${record.numLines}', false),
      (I18n.diamondTotalBet, diamondMoney(record.totalBet), true),
      (I18n.diamondLinesWon, '${record.winLineCount}', false),
      (I18n.diamondWinMoney, diamondMoney(record.money), true),
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
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
      height: 44,
      decoration: divider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF393836))),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 20 / 14,
                color: kDiamondTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (gold)
            Flexible(child: DiamondGoldAmount(value))
          else
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                  color: kDiamondTextPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
