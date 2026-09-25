import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/mini/up_down/state/up_down_rank_provider.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_list_scaffold.dart';
import 'package:sun_sports/mini/up_down_landscape/widgets/up_down_landscape_list_scaffold.dart';
import 'package:sun_sports/shared/widgets/loading/s88_loading.dart';

final DateFormat _rankTimeFormat = DateFormat('HH:mm:ss, dd/MM/yyyy');

class UpDownLandscapeRank extends ConsumerWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const UpDownLandscapeRank({
    this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  static const double _typeW = 130;
  static const double _betW = 57;
  static const double _winW = 110;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(upDownRankProvider);
    final notifier = ref.read(upDownRankProvider.notifier);
    return UpDownLandscapeListScaffold(
      title: I18n.mgRank,
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

  Widget _body(UpDownRankState state) {
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
    if (state.error != null) return _hint(I18n.mgRankLoadError);
    return _hint(I18n.mgRankEmpty);
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
            width: _typeW,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(I18n.upDownTypeCol, style: s),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(I18n.mgAccount, style: s),
              ),
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
  final UpDownRankRecord record;

  const _RankRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: UpDownLandscapeListScaffold.kRowHeight,
      decoration: const BoxDecoration(
        color: kUpDownPanelBg,
        border: Border(bottom: BorderSide(color: kUpDownDivider)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: UpDownLandscapeRank._typeW,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.typeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _meta().copyWith(color: kUpDownGreen),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _rankTimeFormat.format(record.betTime.toLocal()),
                      maxLines: 1,
                      style: _meta().copyWith(
                        height: 16 / 12,
                        color: kUpDownTextTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Text(
                record.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                  color: kUpDownTextPrimary,
                ),
              ),
            ),
          ),
          SizedBox(
            width: UpDownLandscapeRank._betW,
            child: Center(
              child: UpDownGoldAmount(upDownMoneyShort(record.bet)),
            ),
          ),
          SizedBox(
            width: UpDownLandscapeRank._winW,
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
        height: 18 / 12,
        color: kUpDownTextSecondary,
      );
}
