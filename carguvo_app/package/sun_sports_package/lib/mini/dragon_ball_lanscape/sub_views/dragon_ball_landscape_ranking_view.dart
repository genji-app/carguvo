import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/mini_game/data/dragon_ball_http_repository.dart';
import 'package:sun_sports/mini/component/mini_loading_gate.dart';
import 'package:sun_sports/mini/dragon_ball/sub_views/dragon_ball_bet_history_view.dart'
    show kDragonBallFullTimeFormat;
import 'package:sun_sports/mini/dragon_ball_lanscape/sub_views/dragon_ball_landscape_sub_view_scaffold.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_common.dart';

const double _kTypeColW = 130;
const double _kBetColW = 70;
const double _kWinColW = 110;

class DragonBallLandscapeRankingView extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;
  final BorderRadius borderRadius;

  const DragonBallLandscapeRankingView({
    required this.onBack,
    required this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  State<DragonBallLandscapeRankingView> createState() =>
      _DragonBallLandscapeRankingViewState();
}

class _DragonBallLandscapeRankingViewState
    extends State<DragonBallLandscapeRankingView> {
  static const _repo = DragonBallHttpRepository();

  int _page = 1;
  int _maxPages = 1;
  bool _loading = true;
  Object? _error;
  List<DragonBallRankItem> _rows = const [];

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
    return DragonBallLandscapeSubViewScaffold(
      title: 'Xếp hạng',
      onBack: widget.onBack,
      onClose: widget.onClose,
      borderRadius: widget.borderRadius,
      child: Column(
        children: [
          const _HeaderRow(),
          Expanded(
            child: MiniLoadingGate(loading: _loading, child: _body()),
          ),
          DragonBallLandscapePaginationBar(
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
      return _hint('Không tải được xếp hạng. Vui lòng thử lại.');
    }
    if (_rows.isEmpty) {
      return _hint('Chưa có dữ liệu xếp hạng.');
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _rows.length,
        itemBuilder: (context, i) =>
            _RankRow(item: _rows[i], showDivider: i != _rows.length - 1),
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
      height: kDragonBallLandscapeColumnHeaderHeight,
      color: AppColorStyles.backgroundSecondary,
      child: Row(
        children: [
          SizedBox(
            width: _kTypeColW,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text('Loại', style: style),
            ),
          ),
          Expanded(child: Text('Tài khoản', style: style)),
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

class _RankRow extends StatelessWidget {
  final DragonBallRankItem item;
  final bool showDivider;

  const _RankRow({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final time = DateTime.fromMillisecondsSinceEpoch(item.createdTime);
    final isJackpot = item.description.toLowerCase().contains('nổ hũ');
    return Container(
      height: kDragonBallLandscapeRowHeight,
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
            width: _kTypeColW,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isJackpot
                      ? MinipokerGoldNumber(item.description)
                      : Text(
                          item.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 18 / 12,
                            color: AppColors.green400,
                          ),
                        ),
                  const SizedBox(height: 4),
                  Text(
                    kDragonBallFullTimeFormat.format(time),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      height: 16 / 10,
                      color: AppColorStyles.contentTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 20 / 14,
                color: AppColorStyles.contentPrimary,
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
            width: _kWinColW,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: MinipokerGoldNumber(
                  MoneyFormatter.formatWithCommas(item.money),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
