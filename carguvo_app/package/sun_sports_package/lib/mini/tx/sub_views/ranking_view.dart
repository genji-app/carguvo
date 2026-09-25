import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/mini/component/mini_loading_gate.dart';

import 'ranking_row.dart';
import 'tai_xiu_sub_view_scaffold.dart';

final _taiXiuRankingProvider = FutureProvider.autoDispose<List<RankingEntry>>((
  ref,
) async {
  final baseUrl = (SbConfig.instance.mainConfig['api_domain'] as String? ?? '')
      .trim();
  if (baseUrl.isEmpty) {
    throw StateError('api_domain chưa được cấu hình');
  }
  final normalizedBase = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
  final url =
      '$normalizedBase/sa?command=fetch-mini-game-ranking&gameName=Tài Xỉu';
  final accessToken = SbHttpManager.instance.userToken;
  final resp = await Dio().get<Object>(
    url,
    options: accessToken.isEmpty
        ? null
        : Options(headers: {'Authorization': accessToken}),
  );
  return _parseRankingResponse(resp.data);
});

class RankingView extends ConsumerWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;

  const RankingView({required this.onBack, required this.onClose, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranking = ref.watch(_taiXiuRankingProvider);
    return TaiXiuSubViewScaffold(
      title: TaiXiuSubView.ranking.title,
      onBack: onBack,
      onClose: onClose,
      child: MiniLoadingGate(
        loading: ranking is AsyncLoading,
        child: ranking.when(
          data: (entries) => entries.isEmpty
              ? const Center(child: Text('Chưa có dữ liệu xếp hạng'))
              : _RankingTable(entries: entries),
          loading: () => const SizedBox.shrink(),
          error: (error, _) =>
              const Center(child: Text('Không tải được xếp hạng')),
        ),
      ),
    );
  }
}

class _RankingTable extends StatelessWidget {
  final List<RankingEntry> entries;

  const _RankingTable({required this.entries});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Gap(14),
      const _HeaderRow(),
      Expanded(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: entries.length,
            itemBuilder: (context, index) => RankingRow(
              rank: entries[index].rank ?? index + 1,
              entry: entries[index],
              showDivider: index != entries.length - 1,
            ),
          ),
        ),
      ),
    ],
  );
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.textStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 18 / 12,
      color: AppColorStyles.contentSecondary,
    );
    const headerPad = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    return ColoredBox(
      color: AppColorStyles.backgroundSecondary,
      child: Row(
        children: [
          SizedBox(
            width: kRankColumnWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Hạng', textAlign: TextAlign.center, style: style),
            ),
          ),
          Expanded(
            child: Padding(
              padding: headerPad,
              child: Text('Tài khoản', style: style),
            ),
          ),
          Padding(
            padding: headerPad,
            child: Text('Tiền thắng', style: style),
          ),
        ],
      ),
    );
  }
}

List<RankingEntry> _parseRankingResponse(Object? raw) {
  final root = _asMap(raw);
  final data = _asMap(root['data'] ?? root);
  final list =
      _asList(_firstTopUsers(data['topAssets'])) ??
      _asList(data['topUsers']) ??
      _asList(data['items']) ??
      const [];

  return [
    for (var i = 0; i < list.length; i++)
      if (list[i] is Map)
        _rankingEntryFromMap(
          Map<String, dynamic>.from(list[i] as Map),
          fallbackRank: i + 1,
        ),
  ];
}

Object? _firstTopUsers(Object? value) {
  final assets = _asList(value);
  if (assets == null || assets.isEmpty || assets.first is! Map) return null;
  return Map<String, dynamic>.from(assets.first as Map)['topUsers'];
}

RankingEntry _rankingEntryFromMap(
  Map<String, dynamic> map, {
  required int fallbackRank,
}) {
  return RankingEntry(
    rank: _intFrom(map['rank']) == 0 ? fallbackRank : _intFrom(map['rank']),
    username:
        '${map['displayName'] ?? map['userName'] ?? map['dn'] ?? 'Player'}',
    winAmount: _intFrom(map['total'] ?? map['money'] ?? map['winAmount']),
  );
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String) {
    final decoded = jsonDecode(value);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  return const {};
}

List<dynamic>? _asList(Object? value) => value is List ? value : null;

int _intFrom(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
