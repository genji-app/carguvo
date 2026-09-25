import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/mini/diamond/state/diamond_rank_provider.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_list_scaffold.dart';
import 'package:sun_sports/shared/widgets/loading/s88_loading.dart';

final DateFormat _timeFormat = DateFormat('HH:mm:ss, dd/MM/yyyy');

class DiamondRank extends ConsumerWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DiamondRank({
    this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  static const double _betW = 56;
  static const double _winW = 104;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diamondRankProvider);
    final notifier = ref.read(diamondRankProvider.notifier);
    return SizedBox(
      height: 630,
      child: DiamondListScaffold(
        title: I18n.mgRank,
        onBack: onBack,
        onClose: onClose,
        borderRadius: borderRadius,
        pageLabel: state.pageLabel,
        onPrev: (state.hasPrev && !state.loading) ? notifier.prev : null,
        onNext: (state.hasNext && !state.loading) ? notifier.next : null,
        columnHeader: _columnHeader(),
        body: _body(state),
      ),
    );
  }

  Widget _body(DiamondRankState state) {
    if (state.items.isNotEmpty) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: state.items.length,
        itemBuilder: (_, i) => _RankRow(record: state.items[i]),
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
    return _hint(state.error != null
        ? I18n.mgRankLoadError
        : I18n.mgRankEmpty);
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
              color: kDiamondTextTertiary,
            ),
          ),
        ),
      );

  Widget _columnHeader() {
    final s = diamondColumnLabelStyle();
    return ColoredBox(
      color: kDiamondStripBg,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
              child: Text(I18n.mgAccount, style: s),
            ),
          ),
          SizedBox(
            width: _betW,
            child: Text(I18n.mgBet, textAlign: TextAlign.center, style: s),
          ),
          SizedBox(
            width: _winW,
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

class _RankRow extends StatelessWidget {
  final DiamondRankRecord record;

  const _RankRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kDiamondDivider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: kDiamondTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(I18n.mgType, style: _meta()),
                      const SizedBox(width: 4),
                      Text(
                        record.typeLabel,
                        style: _meta().copyWith(
                          color: record.isJackpot
                              ? const Color(0xFFFFB732)
                              : const Color(0xFF86CB3C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_timeFormat.format(record.betTime.toLocal()),
                      style: _meta()),
                ],
              ),
            ),
          ),
          SizedBox(
            width: DiamondRank._betW,
            child:
                Center(child: DiamondGoldAmount(diamondMoneyShort(record.bet))),
          ),
          SizedBox(
            width: DiamondRank._winW,
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
        ],
      ),
    );
  }

  TextStyle _meta() => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: kDiamondTextSecondary,
      );
}
