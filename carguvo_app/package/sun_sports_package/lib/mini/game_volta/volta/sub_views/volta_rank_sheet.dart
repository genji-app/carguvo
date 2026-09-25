import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import '../../common/data/volta_rank_api.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_icons.dart';
import '../../common/widgets/volta_gold_text.dart';
import '../../common/widgets/volta_sheet_scaffold.dart';

class VoltaRankEntry {
  final int rank;
  final String username;
  final int winnings;

  const VoltaRankEntry({
    required this.rank,
    required this.username,
    required this.winnings,
  });
}

final voltaRankProvider = FutureProvider.autoDispose<List<VoltaRankRow>>(
  (ref) => const VoltaRankApi().fetch(),
);

class VoltaRankSheet extends ConsumerWidget {
  const VoltaRankSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<VoltaRankRow>> rows = ref.watch(voltaRankProvider);

    return VoltaSheetScaffold(
      title: 'Xếp hạng',
      panelHeader: true,
      columns: const _ColumnHeader(),
      fitContent: true,
      child: SizedBox(
        height: _RankTile.height * _rankRows,
        child: rows.when(
          loading: () => const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (Object _, StackTrace __) =>
              const _Empty(message: 'Không tải được bảng xếp hạng'),
          data: (List<VoltaRankRow> list) {
            if (list.isEmpty) {
              return const _Empty(message: 'Chưa có dữ liệu xếp hạng');
            }
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: list.length,
              itemExtent: _RankTile.height,
              itemBuilder: (BuildContext context, int index) => _RankTile(
                entry: VoltaRankEntry(
                  rank: index + 1,
                  username: list[index].username,
                  winnings: list[index].winnings,
                ),
                last: index == list.length - 1,
              ),
            );
          },
        ),
      ),
    );
  }
}

const int _rankRows = 10;

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.labelSmall(color: VoltaColors.contentSecondary),
      ),
    ),
  );
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader();

  static const double height = 34;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = AppTextStyles.labelXSmall(
      color: VoltaColors.contentSecondary,
    );
    return Container(
      height: height,
      color: VoltaColors.surfaceSunken,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: _RankTile.rankColumnWidth,
            child: Text('Hạng', style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Tài khoản', style: style),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Tiền thắng',
                style: style,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({required this.entry, required this.last});

  final VoltaRankEntry entry;

  final bool last;

  static const double height = 53;

  static const double rankColumnWidth = 83;

  static const double medalSize = 34.27;

  @override
  Widget build(BuildContext context) {
    final Widget? medal = VoltaIcons.medalForRank(entry.rank, size: medalSize);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: VoltaColors.divider)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: rankColumnWidth,
            child: Center(
              child:
                  medal ??
                  Text(
                    '${entry.rank}',
                    style: AppTextStyles.labelSmall(color: Colors.white),
                  ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                entry.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.paragraphSmall(
                  color: VoltaColors.contentPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: VoltaGoldText(
                _money(entry.winnings),
                textAlign: TextAlign.right,
                style: AppTextStyles.labelSmall(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _money(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
