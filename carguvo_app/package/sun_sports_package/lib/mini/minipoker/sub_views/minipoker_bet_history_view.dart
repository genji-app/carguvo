import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/mini_game/data/mini_poker_http_repository.dart';
import 'package:sun_sports/features/mini_game/logic/mau_binh_card_lib.dart';
import 'package:sun_sports/features/mini_game/logic/slot_history_pager.dart';
import 'package:sun_sports/mini/component/mini_loading_gate.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_sub_view_scaffold.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_card.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_common.dart';

final DateFormat _kMiniPokerTimeFormat = DateFormat('HH:mm:ss, dd/MM/yyyy');
String miniPokerFormatTime(int epochMs) =>
    _kMiniPokerTimeFormat.format(DateTime.fromMillisecondsSinceEpoch(epochMs));

class MinipokerBetHistoryEntry {
  final List<PorkerCard> cards;
  final String sessionId;
  final String time;
  final String bet;
  final String win;

  const MinipokerBetHistoryEntry({
    required this.cards,
    required this.sessionId,
    required this.time,
    required this.bet,
    required this.win,
  });
}

const double _kBetColW = 56;
const double _kWinColW = 104;

const double _kLsSessionColW = 118;
const double _kLsResultColW = 183;
const double _kLsBetColW = 57;

class MinipokerBetHistoryView extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;
  final BorderRadius borderRadius;
  final bool landscape;

  const MinipokerBetHistoryView({
    required this.onBack,
    required this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.landscape = false,
    super.key,
  });

  @override
  State<MinipokerBetHistoryView> createState() =>
      _MinipokerBetHistoryViewState();
}

class _MinipokerBetHistoryViewState extends State<MinipokerBetHistoryView> {
  static const _repo = MiniPokerHttpRepository();

  late final SlotHistoryPager<MiniPokerHistoryItem> _pager = SlotHistoryPager(
    fetchChunk: ({required int skip, required int limit}) async {
      final p = await _repo.fetchHistoryChunk(skip: skip, limit: limit);
      return SlotHistoryChunk(items: p.items, count: p.count);
    },
    createdTimeOf: (e) => e.createdTime,
    sessionIdOf: (e) => e.sessionId,
  );

  int _page = 1;
  int _maxPages = 1;
  bool _loading = true;
  Object? _error;
  List<MinipokerBetHistoryEntry> _rows = const [];

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
      final items = await _pager.page(page);
      if (!mounted || reqId != _reqId) return;
      if (items.isEmpty && page > _pager.maxPages) {
        _fetch(_pager.maxPages);
        return;
      }
      setState(() {
        _rows = items.map(_mapEntry).toList(growable: false);
        _maxPages = _pager.maxPages;
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

  MinipokerBetHistoryEntry _mapEntry(MiniPokerHistoryItem item) {
    return MinipokerBetHistoryEntry(
      cards: item.symbols
          .map((c) => MauBinhCard.decode(c).toPorkerCard())
          .toList(growable: false),
      sessionId: '#${item.sessionId}',
      time: miniPokerFormatTime(item.createdTime),
      bet: MoneyFormatter.formatWithCommas(item.betting),
      win: MoneyFormatter.formatWithCommas(item.money),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MinipokerSubViewScaffold(
      title: MinipokerSubView.betHistory.title,
      onBack: widget.onBack,
      onClose: widget.onClose,
      borderRadius: widget.borderRadius,
      child: Column(
        children: [
          if (widget.landscape)
            const _LandscapeHeaderRow()
          else
            const _HeaderRow(),
          Expanded(child: MiniLoadingGate(loading: _loading, child: _body())),
          MinipokerPaginationBar(
            page: _page,
            total: _maxPages,
            onPrev: (!_loading && _page > 1) ? () => _fetch(_page - 1) : null,
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
      return const _EmptyHint('Không tải được lịch sử. Vui lòng thử lại.');
    }
    if (_rows.isEmpty) {
      return const _EmptyHint('Chưa có lịch sử cược.');
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _rows.length,
        itemBuilder: (context, i) => widget.landscape
            ? _LandscapeHistoryRow(
                entry: _rows[i],
                showDivider: i != _rows.length - 1,
              )
            : _HistoryRow(
                entry: _rows[i],
                showDivider: i != _rows.length - 1,
              ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
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
              child: Text('Kết quả', style: style),
            ),
          ),
          SizedBox(
            width: _kBetColW,
            child: Text('Cược', textAlign: TextAlign.center, style: style),
          ),
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

class _HistoryRow extends StatelessWidget {
  final MinipokerBetHistoryEntry entry;
  final bool showDivider;

  const _HistoryRow({required this.entry, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final metaStyle = GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 18 / 12,
      color: AppColorStyles.contentSecondary,
    );
    return Container(
      height: 96,
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColorStyles.borderPrimary),
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [MinipokerResultCardBox(cards: entry.cards)],
                  ),
                ),
              ),
              SizedBox(
                width: _kBetColW,
                child: Center(child: MinipokerGoldNumber(entry.bet)),
              ),
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
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.sessionId, style: metaStyle),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    entry.time,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: metaStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LandscapeHeaderRow extends StatelessWidget {
  const _LandscapeHeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 18 / 12,
      color: AppColorStyles.contentSecondary,
    );
    return Container(
      height: 32,
      color: AppColorStyles.backgroundSecondary,
      child: Row(
        children: [
          SizedBox(
            width: _kLsSessionColW,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Phiên', style: style),
              ),
            ),
          ),
          SizedBox(
            width: _kLsResultColW,
            child: Text('Kết quả', textAlign: TextAlign.center, style: style),
          ),
          SizedBox(
            width: _kLsBetColW,
            child: Text('Cược', textAlign: TextAlign.center, style: style),
          ),
          Expanded(
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

class _LandscapeHistoryRow extends StatelessWidget {
  final MinipokerBetHistoryEntry entry;
  final bool showDivider;

  const _LandscapeHistoryRow({required this.entry, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final metaStyle = GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
      color: AppColorStyles.contentSecondary,
    );
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColorStyles.borderPrimary),
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: _kLsSessionColW,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.sessionId, style: metaStyle),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(entry.time, maxLines: 1, style: metaStyle),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: _kLsResultColW,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: MinipokerResultCardBox(cards: entry.cards)),
            ),
          ),
          SizedBox(
            width: _kLsBetColW,
            child: Center(child: MinipokerGoldNumber(entry.bet)),
          ),
          Expanded(
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
