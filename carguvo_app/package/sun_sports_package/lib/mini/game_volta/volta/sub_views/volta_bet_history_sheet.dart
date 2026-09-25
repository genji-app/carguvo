import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import '../../common/data/volta_bet_history_api.dart';
import '../../common/domain/volta_paging.dart';
import '../../common/state/volta_models.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_icons.dart';
import '../../common/volta_rules.dart';
import '../../common/widgets/volta_gold_text.dart';
import '../../common/widgets/volta_sheet_scaffold.dart';

class VoltaBetRecord {
  final String sessionId;

  final VoltaSide side;

  final int stake;

  final int payout;

  final String homeTeam;
  final String awayTeam;

  final VoltaWinner winner;

  final DateTime placedAt;

  const VoltaBetRecord({
    required this.sessionId,
    required this.side,
    required this.stake,
    required this.payout,
    required this.homeTeam,
    required this.awayTeam,
    required this.winner,
    required this.placedAt,
  });

  bool get isWin => payout > 0;
}

final voltaBetHistoryProvider =
    FutureProvider.autoDispose<List<VoltaBetRow>>(
      (ref) => const VoltaBetHistoryApi().fetch(),
    );

final voltaBetHistoryPageProvider = StateProvider.autoDispose<int>((_) => 1);

class VoltaBetHistorySheet extends ConsumerWidget {
  const VoltaBetHistorySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<VoltaBetRow>> rows = ref.watch(
      voltaBetHistoryProvider,
    );

    return rows.when(
      loading: () => const VoltaSheetScaffold(
        title: 'Lịch sử cược',
      panelHeader: true,
        columns: _ColumnHeader(),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (Object _, StackTrace __) => const VoltaSheetScaffold(
        title: 'Lịch sử cược',
      panelHeader: true,
        columns: _ColumnHeader(),
        child: _EmptyState(message: 'Tải dữ liệu lịch sử thất bại'),
      ),
      data: (List<VoltaBetRow> all) => _Loaded(rows: all),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.rows});

  final List<VoltaBetRow> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int pages = VoltaPaging.pageCount(
      rows.length,
      VoltaRules.betHistoryPageSize,
    );
    final int page = ref
        .watch(voltaBetHistoryPageProvider)
        .clamp(1, pages);
    final List<VoltaBetRow> visible = VoltaPaging.pageOf(
      rows,
      page,
      VoltaRules.betHistoryPageSize,
    );

    return VoltaSheetScaffold(
      title: 'Lịch sử cược',
      panelHeader: true,
      columns: const _ColumnHeader(),
      footer: rows.isEmpty
          ? null
          : _Pagination(
              page: page,
              total: pages,
              onPage: (int next) => ref
                  .read(voltaBetHistoryPageProvider.notifier)
                  .state = next,
            ),
      child: rows.isEmpty
          ? const _EmptyState(message: 'Bạn chưa có lượt cược nào')
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: visible.length,
              itemExtent: _BetRecordTile.height,
              itemBuilder: (BuildContext context, int index) =>
                  _BetRecordTile(record: _toRecord(visible[index])),
            ),
    );
  }

  static VoltaBetRecord _toRecord(VoltaBetRow row) => VoltaBetRecord(
    sessionId: row.matchId.isNotEmpty
        ? '#${row.matchId}'
        : (row.ticketId.isEmpty ? '--' : '#${row.ticketId}'),
    side: row.side ?? VoltaSide.home,
    stake: row.stake,
    payout: row.payout,
    homeTeam: row.homeTeam,
    awayTeam: row.awayTeam,
    winner: row.winner,
    placedAt: row.placedAt ?? DateTime.now(),
  );
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader();

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.paragraphSmall(
      color: VoltaColors.contentPrimary,
    );
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: VoltaColors.surfaceSunken,
        border: Border(bottom: BorderSide(color: VoltaColors.divider)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 86, child: Text('Phiên', style: style)),
          Expanded(
            child: Text('Tổng cược', style: style, textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 110,
            child: Text(
              'Tổng thắng',
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _BetRecordTile extends StatelessWidget {
  const _BetRecordTile({required this.record});

  final VoltaBetRecord record;

  static const double height = 131;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: VoltaColors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 86, child: _sessionAndSide()),
              Expanded(
                child: Center(
                  child: VoltaGoldText(
                    _money(record.stake),
                    style: AppTextStyles.labelSmall(),
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: Text(
                  record.isWin ? '+ ${_money(record.payout)}' : '0',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.labelSmall(
                    color: record.isWin
                        ? VoltaColors.green400
                        : VoltaColors.contentTertiary,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: _teams()),
              _timestamp(),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _sessionAndSide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          record.sessionId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: AppTextStyles.paragraphSmall(
            color: VoltaColors.contentTertiary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 30,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _badgeDecoration,
          child: Text(
            record.side == VoltaSide.home ? 'Nhà' : 'Khách',
            style: AppTextStyles.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: VoltaColors.contentPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _teams() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _teamRow(record.homeTeam, record.winner == VoltaWinner.home),
        _teamRow(record.awayTeam, record.winner == VoltaWinner.away),
      ],
    );
  }

  Widget _teamRow(String name, bool won) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          won ? VoltaIcons.win(size: 16) : VoltaIcons.lose(size: 16),
          const SizedBox(width: _iconToName),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.paragraphSmall(
                color: VoltaColors.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const double _iconToName = 37;

  Widget _timestamp() {
    final d = record.placedAt;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          '${_two(d.day)}/${_two(d.month)}/${d.year}',
          style: AppTextStyles.paragraphMedium(
            color: VoltaColors.contentTertiary,
          ),
        ),
        Text(
          '${_two(d.hour)}:${_two(d.minute)}',
          style: AppTextStyles.paragraphMedium(
            color: VoltaColors.contentTertiary,
          ),
        ),
      ],
    );
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  static String _money(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static final BoxDecoration _badgeDecoration = BoxDecoration(
    color: VoltaColors.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const <BoxShadow>[
      BoxShadow(color: Color(0x99000000), offset: Offset(0, 1.6), blurRadius: 3.2),
    ],
  );
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.total,
    required this.onPage,
  });

  final int page;
  final int total;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: page > 1 ? () => onPage(page - 1) : null,
            icon: const Icon(Icons.chevron_left, size: 20),
            color: VoltaColors.contentSecondary,
          ),
          const SizedBox(width: 24),
          Text(
            '$page/$total',
            style: AppTextStyles.labelXSmall(
              color: VoltaColors.contentSecondary,
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: page < total ? () => onPage(page + 1) : null,
            icon: const Icon(Icons.chevron_right, size: 20),
            color: VoltaColors.contentSecondary,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      message,
      style: AppTextStyles.labelXSmall(color: VoltaColors.contentTertiary),
    ),
  );
}
