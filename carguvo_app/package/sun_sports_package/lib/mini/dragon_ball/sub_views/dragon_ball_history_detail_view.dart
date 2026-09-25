import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/mini_game/data/dragon_ball_http_repository.dart';
import 'package:sun_sports/features/mini_game/presentation/state/dragon_ball_state_provider.dart';
import 'package:sun_sports/mini/dragon_ball/sub_views/dragon_ball_bet_history_view.dart'
    show kDragonBallFullTimeFormat;
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_symbols.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_sub_view_scaffold.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_common.dart';

class DragonBallHistoryDetailView extends ConsumerWidget {
  final DragonBallHistoryItem item;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final BorderRadius borderRadius;

  const DragonBallHistoryDetailView({
    required this.item,
    required this.onBack,
    required this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MinipokerSubViewScaffold(
      title: '#${item.sessionId}',
      onBack: onBack,
      onClose: onClose,
      borderRadius: borderRadius,
      child: DragonBallHistoryDetailContent(item: item),
    );
  }
}

class DragonBallHistoryDetailContent extends ConsumerWidget {
  final DragonBallHistoryItem item;

  const DragonBallHistoryDetailContent({required this.item, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineTable = ref.watch(dragonBallLineTableProvider);
    final time = DateTime.fromMillisecondsSinceEpoch(item.createdTime);
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DragonBallResultBox(
              symbols: item.symbols,
              winLineIds: item.payoutLineIds,
              lineRowsResolver: lineTable.rowsFor,
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Thời gian',
              child: _PlainValue(kDragonBallFullTimeFormat.format(time)),
            ),
            _InfoRow(
              label: 'Mức cược',
              child: MinipokerGoldNumber(
                MoneyFormatter.formatWithCommas(item.betting),
              ),
            ),
            _InfoRow(
              label: 'Số line cược',
              child: _PlainValue('${item.numLines}'),
            ),
            _InfoRow(
              label: 'Tổng cược',
              child: MinipokerGoldNumber(
                MoneyFormatter.formatWithCommas(item.totalBet),
              ),
            ),
            _InfoRow(
              label: 'Số line trúng',
              child: _PlainValue('${item.wonLines}'),
            ),
            _InfoRow(
              label: 'Tiền thắng',
              showDivider: false,
              child: MinipokerGoldNumber(
                MoneyFormatter.formatWithCommas(item.money),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool showDivider;

  const _InfoRow({
    required this.label,
    required this.child,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColorStyles.borderPrimary),
              )
            : null,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 18 / 13,
              color: AppColorStyles.contentSecondary,
            ),
          ),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}

class _PlainValue extends StatelessWidget {
  final String text;

  const _PlainValue(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        color: AppColorStyles.contentPrimary,
      ),
    );
  }
}
