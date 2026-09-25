import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/mini/diamond/diamond_history_detail.dart';
import 'package:sun_sports/mini/diamond/state/diamond_history_provider.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_list_scaffold.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/loading/s88_loading.dart';

final DateFormat _hms = DateFormat('HH:mm:ss');
final DateFormat _dmy = DateFormat('dd/MM/yy');

class DiamondHistory extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DiamondHistory({
    this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  ConsumerState<DiamondHistory> createState() => _DiamondHistoryState();

  static const double _betW = 48;
  static const double _lineW = 64;
  static const double _winW = 76;
  static const double _chevW = 28;
}

class _DiamondHistoryState extends ConsumerState<DiamondHistory> {
  DiamondHistoryRecord? _detail;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diamondHistoryProvider);
    final notifier = ref.read(diamondHistoryProvider.notifier);

    if (_detail != null) {
      return DiamondHistoryDetail(
        record: _detail!,
        borderRadius: widget.borderRadius,
        onBack: () => setState(() => _detail = null),
        onClose: widget.onClose,
      );
    }

    return SizedBox(
      height: 610,
      child: DiamondListScaffold(
        title: I18n.mgBetHistory,
        onBack: widget.onBack,
        onClose: widget.onClose,
        borderRadius: widget.borderRadius,
        pageLabel: state.pageLabel,
        onPrev: (state.hasPrev && !state.loading) ? notifier.prev : null,
        onNext: (state.hasNext && !state.loading) ? notifier.next : null,
        columnHeader: _columnHeader(),
        body: _body(state),
      ),
    );
  }

  Widget _columnHeader() {
    final s = diamondColumnLabelStyle();
    return ColoredBox(
      color: kDiamondStripBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(I18n.diamondTime, style: s)),
            SizedBox(
              width: DiamondHistory._betW,
              child: Text(I18n.mgBet, textAlign: TextAlign.center, style: s),
            ),
            SizedBox(
              width: DiamondHistory._lineW,
              child: Text(I18n.diamondWinningLines, textAlign: TextAlign.center, style: s),
            ),
            SizedBox(
              width: DiamondHistory._winW,
              child: Text(I18n.diamondWinMoney, textAlign: TextAlign.right, style: s),
            ),
            const SizedBox(width: DiamondHistory._chevW),
          ],
        ),
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
        state.error != null
            ? I18n.mgHistoryLoadError
            : I18n.mgHistoryEmpty,
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
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kDiamondDivider)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${record.sessionId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 16 / 10,
                        color: kDiamondTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_hms.format(time)}\n${_dmy.format(time)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 16 / 10,
                        color: kDiamondTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: DiamondHistory._betW,
                child: Center(child: DiamondGoldAmount(diamondMoney(record.bet))),
              ),
              SizedBox(
                width: DiamondHistory._lineW,
                child: Center(
                  child: DiamondGoldAmount('${record.winLineCount}'),
                ),
              ),
              SizedBox(
                width: DiamondHistory._winW,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: DiamondGoldAmount(
                    diamondMoney(record.money),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              SizedBox(
                width: DiamondHistory._chevW,
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: kDiamondTextTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
