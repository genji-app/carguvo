import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/up_down/state/up_down_card.dart';
import 'package:sun_sports/mini/up_down/state/up_down_history_provider.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_list_scaffold.dart';
import 'package:sun_sports/mini/up_down_landscape/widgets/up_down_landscape_list_scaffold.dart';
import 'package:sun_sports/shared/widgets/loading/s88_loading.dart';

final DateFormat _historyTimeFormat = DateFormat('HH:mm:ss, dd/MM/yy');

class UpDownLandscapeBetHistory extends ConsumerWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const UpDownLandscapeBetHistory({
    this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  static const double _sessionW = 118;
  static const double _chooseW = 72;
  static const double _stepW = 56;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(upDownHistoryProvider);
    final notifier = ref.read(upDownHistoryProvider.notifier);
    return UpDownLandscapeListScaffold(
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
    if (state.error != null) return _hint(I18n.mgHistoryLoadError);
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
      child: Row(
        children: [
          SizedBox(
            width: _sessionW,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(I18n.upDownSessionCol, style: s),
              ),
            ),
          ),
          SizedBox(
            width: _chooseW,
            child: Text(
              I18n.upDownSelectCol,
              textAlign: TextAlign.center,
              style: s,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(I18n.upDownWinStepCol, style: s),
              ),
            ),
          ),
          SizedBox(
            width: _stepW,
            child: Text(
              I18n.upDownStepCol,
              textAlign: TextAlign.center,
              style: s,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(I18n.mgWin, textAlign: TextAlign.right, style: s),
            ),
          ),
        ],
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
    return Container(
      height: UpDownLandscapeListScaffold.kRowHeight,
      decoration: const BoxDecoration(
        color: kUpDownPanelBg,
        border: Border(bottom: BorderSide(color: kUpDownDivider)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: UpDownLandscapeBetHistory._sessionW,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shrink(child: Text('#${record.sessionId}', style: _meta())),
                  const SizedBox(height: 4),
                  _Shrink(
                    child: Text(
                      _historyTimeFormat.format(record.betTime.toLocal()),
                      maxLines: 1,
                      style: _meta(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: UpDownLandscapeBetHistory._chooseW,
            child: Center(
              child: _ChosenCard(card: card, predictId: record.predictId),
            ),
          ),
          Expanded(
            child: Center(child: UpDownGoldAmount(upDownMoney(record.bet))),
          ),
          SizedBox(
            width: UpDownLandscapeBetHistory._stepW,
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

  static const double _cardW = 26.65;
  static const double _cardH = 35.27;
  static const double _iconW = 20;
  static const double _iconH = 14.69;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _cardH,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageHelper.load(
            path: card.faceAsset,
            width: _cardW,
            height: _cardH,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: _iconW,
            height: _cardH,
            child: predictId == 0
                ? null
                : Align(
                    alignment: predictId == 1
                        ? Alignment.center
                        : Alignment.bottomCenter,
                    child: ImageHelper.load(
                      path: predictId == 1
                          ? MiniGameIcons.upDownIconUp
                          : MiniGameIcons.upDownIconDown,
                      width: _iconW,
                      height: _iconH,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Shrink extends StatelessWidget {
  final Widget child;

  const _Shrink({required this.child});

  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: child,
      );
}
