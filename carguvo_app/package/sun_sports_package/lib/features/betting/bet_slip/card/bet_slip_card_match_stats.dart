import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

import '../match_summary_stats_provider.dart';
import 'bet_slip_card_match.dart';

class BetSlipCardMatchWithStats extends ConsumerStatefulWidget {
  const BetSlipCardMatchWithStats({
    required this.betData,
    required this.hintData,
    this.summaryEventId,
    this.showSportIcon = false,
    super.key,
  });

  final BetCardMatchData betData;
  final HintData hintData;

  final int? summaryEventId;

  final bool showSportIcon;

  @override
  ConsumerState<BetSlipCardMatchWithStats> createState() =>
      _BetSlipCardMatchWithStatsState();
}

class _BetSlipCardMatchWithStatsState
    extends ConsumerState<BetSlipCardMatchWithStats> {
  bool _expanded = false;
  bool _loading = false;

  bool get _statsAvailable =>
      widget.betData.sport == SportType.soccer &&
      (widget.summaryEventId ?? 0) > 0;

  Future<void> _toggleStats() async {
    final id = widget.summaryEventId;
    if (id == null || id <= 0) return;
    if (_loading) return;

    if (_expanded) {
      setState(() => _expanded = false);
      return;
    }

    final cached = ref.read(matchSummaryStatsProvider(id));
    if (cached is AsyncData<MatchSummaryStats>) {
      setState(() => _expanded = true);
      return;
    }

    setState(() => _loading = true);
    try {
      final future = cached is AsyncError
          ? ref.refresh(matchSummaryStatsProvider(id).future)
          : ref.read(matchSummaryStatsProvider(id).future);
      await future;
      if (!mounted) return;
      setState(() {
        _loading = false;
        _expanded = true;
      });
    } on MatchNotStartedFailure {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.showGeneric(context, message: I18n.txtMatchNotStarted);
    } on GetMatchSummaryFailure catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.showError(
        context,
        message: localizedOrGenericError('getMatchSummary', e.errorMessage),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.showError(
        context,
        message: logAndGenericError('getMatchSummary', e),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = _statsAvailable;
    final stats = (_expanded && available)
        ? ref
              .watch(matchSummaryStatsProvider(widget.summaryEventId!))
              .asData
              ?.value
        : null;

    return BetSlipCardMatch(
      betData: widget.betData,
      hintData: widget.hintData,
      scoreIconEnabled: available,
      scoreIconLoading: _loading,
      onScoreIconTap: available ? _toggleStats : null,
      showSportIcon: widget.showSportIcon,
      statsContent: stats == null
          ? null
          : MatchSummaryStatsTable(
              stats: stats,
              matchTimeText: widget.betData.matchDateText,
            ),
    );
  }
}

class MatchSummaryStatsTable extends StatelessWidget {
  const MatchSummaryStatsTable({
    required this.stats,
    required this.matchTimeText,
    super.key,
  });

  final MatchSummaryStats stats;

  final String matchTimeText;

  static const double _headerHeight = 32;
  static const double _rowHeight = 36;
  static const double _teamColumnWidth = 192;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final teamColumnWidth = maxWidth >= _teamColumnWidth * 2
            ? _teamColumnWidth
            : maxWidth / 2;

        return ColoredBox(
          color: AppColorStyles.backgroundTertiary,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: teamColumnWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: _headerHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      color: AppColorStyles.backgroundSecondary,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        matchTimeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.paragraphXSmall(
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                    ),
                    _TeamRow(name: stats.homeName, logoUrl: stats.homeLogoUrl),
                    _TeamRow(name: stats.awayName, logoUrl: stats.awayLogoUrl),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    _StatColumn(
                      icon: _statIcon(AppIcons.phatGoc),
                      homeValue: stats.cornersHome,
                      awayValue: stats.cornersAway,
                    ),
                    _StatColumn(
                      icon: _statIcon(AppIcons.iconYellowCard),
                      homeValue: stats.yellowCardsHome,
                      awayValue: stats.yellowCardsAway,
                    ),
                    _StatColumn(
                      icon: _statIcon(AppIcons.iconRedCard),
                      homeValue: stats.redCardsHome,
                      awayValue: stats.redCardsAway,
                    ),
                    _StatColumn(
                      icon: _statIcon(AppIcons.iconSoccer),
                      homeValue: stats.totalGoalsHome,
                      awayValue: stats.totalGoalsAway,
                      highlighted: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statIcon(String path) =>
      SizedBox.square(dimension: 20, child: ImageHelper.load(path: path));
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.name, required this.logoUrl});

  final String name;
  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MatchSummaryStatsTable._rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (logoUrl.isNotEmpty)
            ImageHelper.getSmallLogo(imageUrl: logoUrl, size: 24)
          else
            const SizedBox.square(
              dimension: 24,
              child: Icon(
                Icons.sports_soccer,
                size: 18,
                color: AppColorStyles.contentSecondary,
              ),
            ),
          const Gap(8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.homeValue,
    required this.awayValue,
    this.highlighted = false,
  });

  final Widget icon;
  final int homeValue;
  final int awayValue;

  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MatchSummaryStatsTable._headerHeight,
                color: AppColorStyles.backgroundSecondary,
                alignment: Alignment.center,
                child: icon,
              ),
              _valueCell(homeValue),
              _valueCell(awayValue),
            ],
          ),
          if (highlighted)
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: IgnorePointer(
                    child: Container(
                      width: 28,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(color: AppColors.gray500, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _valueCell(int value) => SizedBox(
    height: MatchSummaryStatsTable._rowHeight,
    child: Center(
      child: Text(
        '$value',
        style: AppTextStyles.labelSmall(color: AppColorStyles.contentPrimary),
      ),
    ),
  );
}
