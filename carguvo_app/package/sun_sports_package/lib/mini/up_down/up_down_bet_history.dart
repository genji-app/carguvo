import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/up_down/state/up_down_card.dart';
import 'package:sun_sports/mini/up_down/state/up_down_history_provider.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_list_scaffold.dart';
import 'package:sun_sports/shared/widgets/loading/s88_loading.dart';

final DateFormat _historyTimeFormat = DateFormat('HH:mm:ss, dd/MM/yy');

class UpDownBetHistory extends ConsumerWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const UpDownBetHistory({
    this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  static const double _chooseW = 56;
  static const double _stepW = 56;

  static const double kPanelHeight = 700;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(upDownHistoryProvider);
    final notifier = ref.read(upDownHistoryProvider.notifier);
    return UpDownListScaffold(
      title: I18n.mgBetHistory,
      onBack: onBack,
      onClose: onClose,
      borderRadius: borderRadius,
      pageLabel: state.pageLabel,
      onPrev: (state.hasPrev && !state.loading) ? notifier.prev : null,
      onNext: (state.hasNext && !state.loading) ? notifier.next : null,
      columnHeader: _columnHeader(),
      body: _body(state),
    );
  }

  Widget _body(UpDownHistoryState state) {
    if (state.items.isNotEmpty) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: state.items.length,
        itemBuilder: (_, i) => _HistoryRow(record: state.items[i]),
      );
    }
    if (state.loading) {
      return const S88Loading(
        indicatorSize: 72,
        backgroundColor: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (state.error != null) {
      return _hint(I18n.mgHistoryLoadError);
    }
    return _hint(I18n.mgHistoryEmpty);
  }

  Widget _hint(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kUpDownGray,
            ),
          ),
        ),
      );

  Widget _columnHeader() {
    final s = upDownColumnLabelStyle();
    return ColoredBox(
      color: kUpDownStripBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: _chooseW,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(I18n.upDownSelectCol, style: s),
              ),
            ),
            Expanded(
                child: Text(I18n.upDownWinStepCol,
                    textAlign: TextAlign.center, style: s)),
            SizedBox(
                width: _stepW,
                child: Text(I18n.upDownStepCol, textAlign: TextAlign.center, style: s)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(I18n.mgWin, textAlign: TextAlign.right, style: s),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final UpDownBetHistoryRecord record;

  const _HistoryRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final card = decodeCard(record.card);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColoredBox(
          color: AppColorStyles.backgroundTertiary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              children: [
                Text('#${record.sessionId}', style: _meta()),
                const Spacer(),
                Text(
                  _historyTimeFormat.format(record.betTime.toLocal()),
                  style: _meta(),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 72,
          child: Row(
            children: [
              SizedBox(
                width: UpDownBetHistory._chooseW,
                child: Center(
                  child: _ChosenCard(card: card, predictId: record.predictId),
                ),
              ),
              Expanded(
                child: Center(child: UpDownGoldAmount(upDownMoney(record.bet))),
              ),
              SizedBox(
                width: UpDownBetHistory._stepW,
                child: Center(child: UpDownGoldAmount('${record.turn}')),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: UpDownGoldAmount(
                      upDownMoney(record.money),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _meta() => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: kUpDownGray,
      );
}

class _ChosenCard extends StatelessWidget {
  final UpDownCard card;
  final int predictId;

  const _ChosenCard({required this.card, required this.predictId});

  static const double _iconSize = 16;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (predictId == 1)
          ImageHelper.load(
            path: MiniGameIcons.upDownIconUp,
            width: _iconSize,
            height: _iconSize,
          ),
        _MiniCard(card: card),
        if (predictId == -1)
          ImageHelper.load(
            path: MiniGameIcons.upDownIconDown,
            width: _iconSize,
            height: _iconSize,
          ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final UpDownCard card;

  const _MiniCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return ImageHelper.load(
      path: card.faceAsset,
      width: 30,
      height: 40,
      fit: BoxFit.contain,
    );
  }
}
