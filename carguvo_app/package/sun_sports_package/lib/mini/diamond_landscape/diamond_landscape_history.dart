import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/mini/diamond/state/diamond_history_provider.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/mini/diamond_landscape/diamond_landscape_history_detail.dart';
import 'package:sun_sports/mini/diamond_landscape/widgets/diamond_landscape_list_scaffold.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/loading/s88_loading.dart';

final DateFormat _hms = DateFormat('HH:mm:ss');
final DateFormat _dmy = DateFormat('dd/MM/yy');

class DiamondLandscapeHistory extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DiamondLandscapeHistory({
    this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  ConsumerState<DiamondLandscapeHistory> createState() =>
      _DiamondLandscapeHistoryState();

  static const double _timeW = 72;
  static const double _sessionW = 79;
  static const double _betW = 80;
  static const double _lineW = 82;
  static const double _chevW = 28;
}

class _DiamondLandscapeHistoryState
    extends ConsumerState<DiamondLandscapeHistory> {
  DiamondHistoryRecord? _detail;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diamondHistoryProvider);
    final notifier = ref.read(diamondHistoryProvider.notifier);

    if (_detail != null) {
      return DiamondLandscapeHistoryDetail(
        record: _detail!,
        borderRadius: widget.borderRadius,
        onBack: () => setState(() => _detail = null),
        onClose: widget.onClose,
      );
    }

    return DiamondLandscapeListScaffold(
      title: I18n.mgBetHistory,
      onBack: widget.onBack,
      onClose: widget.onClose,
      borderRadius: widget.borderRadius,
      pageLabel: state.pageLabel,
      onPrev: (state.hasPrev && !state.loading) ? notifier.prev : null,
      onNext: (state.hasNext && !state.loading) ? notifier.next : null,
      columnHeader: _columnHeader(),
      body: _body(state),
    );
  }

  Widget _columnHeader() {
    final s = diamondColumnLabelStyle();
    return ColoredBox(
      color: kDiamondStripBg,
      child: Row(
        children: [
          SizedBox(
            width: DiamondLandscapeHistory._timeW,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(I18n.diamondTime, style: s),
              ),
            ),
          ),
          SizedBox(
            width: DiamondLandscapeHistory._sessionW,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(I18n.diamondSessionCol, style: s),
              ),
            ),
          ),
          SizedBox(
            width: DiamondLandscapeHistory._betW,
            child: Text(I18n.mgBet, textAlign: TextAlign.center, style: s),
          ),
          SizedBox(
            width: DiamondLandscapeHistory._lineW,
            child: Text(
              I18n.diamondWinningLines,
              textAlign: TextAlign.center,
              style: s,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                I18n.diamondWinMoney,
                textAlign: TextAlign.right,
                style: s,
              ),
            ),
          ),
          const SizedBox(width: DiamondLandscapeHistory._chevW),
        ],
      ),
    );
  }

  Widget _body(DiamondHistoryState state) {
    if (state.items.isNotEmpty) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: state.items.length,
        itemBuilder: (_, i) => _HistoryRow(
          record: state.items[i],
          onTap: () => setState(() => _detail = state.items[i]),
        ),
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
    return Center(
      child: Text(
        state.error != null ? I18n.mgHistoryLoadError : I18n.mgHistoryEmpty,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: kDiamondTextTertiary,
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final DiamondHistoryRecord record;
  final VoidCallback onTap;

  const _HistoryRow({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final time = record.betTime.toLocal();
    return SoundTap(
      onTap: onTap,
      child: Container(
        height: DiamondLandscapeListScaffold.kRowHeight,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kDiamondDivider)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: DiamondLandscapeHistory._timeW,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NoWrap(child: Text(_hms.format(time), style: _meta())),
                    _NoWrap(child: Text(_dmy.format(time), style: _meta())),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: DiamondLandscapeHistory._sessionW,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '#${record.sessionId}',
                    maxLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      color: kDiamondTextPrimary,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: DiamondLandscapeHistory._betW,
              child: Center(
                child: DiamondGoldAmount(diamondMoney(record.bet)),
              ),
            ),
            SizedBox(
              width: DiamondLandscapeHistory._lineW,
              child: Center(
                child: DiamondGoldAmount('${record.winLineCount}'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: DiamondGoldAmount(
                    diamondMoney(record.money),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: DiamondLandscapeHistory._chevW,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: kDiamondTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _meta() => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 16 / 10,
        color: kDiamondTextTertiary,
      );
}

class _NoWrap extends StatelessWidget {
  final Widget child;

  const _NoWrap({required this.child});

  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: DefaultTextStyle.merge(
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          child: child,
        ),
      );
}
