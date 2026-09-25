import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/mini_game/data/dragon_ball_http_repository.dart';
import 'package:sun_sports/mini/component/mini_loading_gate.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_sub_view_scaffold.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_common.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

final DateFormat kDragonBallTimeFormat = DateFormat('HH:mm:ss');
final DateFormat kDragonBallDateFormat = DateFormat('dd/MM/yy');

final DateFormat kDragonBallFullTimeFormat = DateFormat('HH:mm:ss, dd/MM/yyyy');

const double _kBetColW = 56;
const double _kLineColW = 72;
const double _kWinColW = 88;
const double _kChevronW = 28;

class DragonBallBetHistoryView extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;
  final ValueChanged<DragonBallHistoryItem> onItemTap;
  final BorderRadius borderRadius;

  const DragonBallBetHistoryView({
    required this.onBack,
    required this.onClose,
    required this.onItemTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  State<DragonBallBetHistoryView> createState() =>
      _DragonBallBetHistoryViewState();
}

class _DragonBallBetHistoryViewState extends State<DragonBallBetHistoryView> {
  static const _repo = DragonBallHttpRepository();

  int _page = 1;
  int _maxPages = 1;
  bool _loading = true;
  Object? _error;
  List<DragonBallHistoryItem> _rows = const [];

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
      final res = await _repo.fetchHistory(page: page);
      if (!mounted || reqId != _reqId) return;
      setState(() {
        _rows = res.items;
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

  @override
  Widget build(BuildContext context) {
    return MinipokerSubViewScaffold(
      title: 'Lịch sử cược',
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
        itemBuilder: (context, i) => _HistoryRow(
          item: _rows[i],
          showDivider: i != _rows.length - 1,
          onTap: () => widget.onItemTap(_rows[i]),
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
              child: Text('Thời gian', style: style),
            ),
          ),
          SizedBox(
            width: _kBetColW,
            child: Text('Cược', textAlign: TextAlign.center, style: style),
          ),
          SizedBox(
            width: _kLineColW,
            child:
                Text('Line trúng', textAlign: TextAlign.center, style: style),
          ),
          SizedBox(
            width: _kWinColW,
            child:
                Text('Tiền thắng', textAlign: TextAlign.right, style: style),
          ),
          const SizedBox(width: _kChevronW),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final DragonBallHistoryItem item;
  final bool showDivider;
  final VoidCallback onTap;

  const _HistoryRow({
    required this.item,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final metaStyle = GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 18 / 12,
      color: AppColorStyles.contentSecondary,
    );
    final time = DateTime.fromMillisecondsSinceEpoch(item.createdTime);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(onTap),
        child: Container(
          height: 78,
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
                        '#${item.sessionId}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 18 / 12,
                          color: AppColorStyles.contentPrimary,
                        ),
                      ),
                      Text(kDragonBallTimeFormat.format(time),
                          style: metaStyle),
                      Text(kDragonBallDateFormat.format(time),
                          style: metaStyle),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: _kBetColW,
                child: Center(
                  child: MinipokerGoldNumber(
                    MoneyFormatter.formatWithCommas(item.betting),
                  ),
                ),
              ),
              SizedBox(
                width: _kLineColW,
                child: Center(
                  child: MinipokerGoldNumber('${item.wonLines}'),
                ),
              ),
              SizedBox(
                width: _kWinColW,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: MinipokerGoldNumber(
                    MoneyFormatter.formatWithCommas(item.money),
                  ),
                ),
              ),
              const SizedBox(
                width: _kChevronW,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
