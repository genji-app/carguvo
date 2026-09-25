import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/mini_game/data/mini_poker_http_repository.dart';
import 'package:sun_sports/mini/component/mini_loading_gate.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_bet_history_view.dart'
    show miniPokerFormatTime;
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_sub_view_scaffold.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_common.dart';

class MinipokerRankingEntry {
  final String username;
  final String type;
  final String time;
  final String bet;
  final String win;

  const MinipokerRankingEntry({
    required this.username,
    required this.type,
    required this.time,
    required this.bet,
    required this.win,
  });
}

const double _kBetColW = 56;
const double _kWinColW = 104;
const double _kColGap = 16;

class MinipokerRankingView extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;
  final BorderRadius borderRadius;

  const MinipokerRankingView({
    required this.onBack,
    required this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  State<MinipokerRankingView> createState() => _MinipokerRankingViewState();
}

class _MinipokerRankingViewState extends State<MinipokerRankingView> {
  static const _repo = MiniPokerHttpRepository();

  int _page = 1;
  int _maxPages = 1;
  bool _loading = true;
  Object? _error;
  List<MinipokerRankingEntry> _rows = const [];

  int _reqId = 0;

  @override
  void initState() {
    super.initState();
    _fetch(1);
  }

  Future<void> _fetch(int page) async {
    final reqId = ++_reqId;
    setState(() {
      _loading = true;
      _error = null;
      _page = page;
    });
    try {
      final res = await _repo.fetchRank(page: page);
      if (!mounted || reqId != _reqId) return;
      setState(() {
        _rows = res.items.map(_mapEntry).toList(growable: false);
        _maxPages = res.maxPages;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || reqId != _reqId) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  MinipokerRankingEntry _mapEntry(MiniPokerRankItem item) {
    return MinipokerRankingEntry(
      username: item.displayName,
      type: item.description,
      time: miniPokerFormatTime(item.createdTime),
      bet: MoneyFormatter.formatWithCommas(item.betting),
      win: MoneyFormatter.formatWithCommas(item.money),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MinipokerSubViewScaffold(
      title: MinipokerSubView.ranking.title,
      onBack: widget.onBack,
      onClose: widget.onClose,
      borderRadius: widget.borderRadius,
      child: Column(
        children: [
          const _HeaderRow(),
          Expanded(child: MiniLoadingGate(loading: _loading, child: _body())),
          MinipokerPaginationBar(
            page: _page,
            total: _maxPages,
            onPrev:
                (!_loading && _page > 1) ? () => _fetch(_page - 1) : null,
            onNext: (!_loading && _page < _maxPages)
                ? () => _fetch(_page + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_error != null) {
      return _hint('Không tải được xếp hạng. Vui lòng thử lại.');
    }
    if (_rows.isEmpty) {
      return _hint('Chưa có dữ liệu xếp hạng.');
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context)
          .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _rows.length,
        itemBuilder: (context, i) => _RankRow(
          entry: _rows[i],
          showDivider: i != _rows.length - 1,
        ),
      ),
    );
  }

  Widget _hint(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColorStyles.contentSecondary,
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 18 / 12,
      color: AppColorStyles.contentSecondary,
    );
    return Container(
      height: 34,
      color: AppColorStyles.backgroundSecondary,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text('Tài khoản', style: style),
            ),
          ),
          SizedBox(
            width: _kBetColW,
            child: Text('Cược', textAlign: TextAlign.right, style: style),
          ),
          const SizedBox(width: _kColGap),
          SizedBox(
            width: _kWinColW,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text('Thắng', textAlign: TextAlign.right, style: style),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final MinipokerRankingEntry entry;
  final bool showDivider;

  const _RankRow({required this.entry, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColorStyles.borderPrimary),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.username,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 20 / 14,
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _LoaiRow(type: entry.type),
                  const SizedBox(height: 4),
                  Text(
                    entry.time,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 18 / 12,
                      color: AppColorStyles.contentSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: _kBetColW,
            child: Align(
              alignment: Alignment.centerRight,
              child: MinipokerGoldNumber(entry.bet),
            ),
          ),
          const SizedBox(width: _kColGap),
          SizedBox(
            width: _kWinColW,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: MinipokerGoldNumber(entry.win),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoaiRow extends StatelessWidget {
  final String type;

  const _LoaiRow({required this.type});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Loại: ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 18 / 12,
            color: AppColorStyles.contentSecondary,
          ),
        ),
        Flexible(
          child: Text(
            type,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 18 / 12,
              color: AppColors.green400,
            ),
          ),
        ),
      ],
    );
  }
}
