import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/models_v2.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_detail_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/favorite_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/providers/vibrating_odds_provider.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/scroll_blocked_tap.dart';

final _kText14W700Secondary = AppTextStyles.textStyle(
    fontSize: 14, fontWeight: FontWeight.w700,
    color: AppColorStyles.contentSecondary);

class LeagueHeaderWidgetV2 extends ConsumerWidget {
  final LeagueModelV2 league;
  final bool isDesktop;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final bool showFavorite;

  final bool frameOnly;

  const LeagueHeaderWidgetV2({
    super.key,
    required this.league,
    this.isDesktop = false,
    this.isExpanded = true,
    this.onToggleExpand,
    this.showFavorite = true,
    this.frameOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (frameOnly) {
      return Container(
        height: 1,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -0.65),
              blurRadius: 0.5,
              spreadRadius: 0.05,
              blurStyle: BlurStyle.inner,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ],
        ),
      );
    }

    final sportIdForLeague = league.sportId != 0
        ? league.sportId
        : ref.watch(selectedSportV2Provider.select((s) => s.id));

    final isLeagueFavorited = ref.watch(
      favoriteProvider.select(
        (fav) => fav.favoritesBySport.containsKey(sportIdForLeague)
            ? fav.isLeagueFavorite(sportIdForLeague, league.leagueId)
            : league.isFavorited,
      ),
    );

    return ScrollBlockedTap(
      showClickCursor: onToggleExpand != null,
      onTap: onToggleExpand != null ? SoundTap.wrap(onToggleExpand) : null,
      behavior: HitTestBehavior.opaque,
      child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: isDesktop ? 48 : 40,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 16 : 12,
                vertical: 6,
              ),
              decoration: isExpanded
                  ? _HeaderDecorations.expanded
                  : _HeaderDecorations.collapsed,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildLeagueLogo(sportIdForLeague),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            league.displayName,
                            style: _kText14W700Secondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${league.events.length})',
                          style: _kText14W700Secondary,
                        ),
                      ],
                    ),
                  ),
                  if (showFavorite) ...[
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: SoundTap.wrap(() async {
                          if (!requireLogin(context, ref)) return;
                          final notifier = ref.read(favoriteProvider.notifier);
                          final fav = ref.read(favoriteProvider);
                          final sid = league.sportId != 0
                              ? league.sportId
                              : ref.read(selectedSportV2Provider).id;
                          final wasFavorited =
                              fav.favoritesBySport.containsKey(sid)
                              ? fav.isLeagueFavorite(sid, league.leagueId)
                              : league.isFavorited;
                          final success = wasFavorited
                              ? await notifier.removeFavoriteLeague(
                                  sportId: sid,
                                  leagueId: league.leagueId,
                                )
                              : await notifier.addFavoriteLeague(
                                  sportId: sid,
                                  leagueId: league.leagueId,
                                );
                          if (success) {
                            final info = ref.read(selectedLeagueInfoProvider);
                            if (info != null &&
                                info.leagueId == league.leagueId) {
                              ref.invalidate(leagueDetailEventsProvider(info));
                            }
                            if (context.mounted) {
                              AppToast.showSuccess(
                                context,
                                message: wasFavorited
                                    ? 'Đã xoá giải đấu khỏi yêu thích'
                                    : 'Đã thêm giải đấu vào yêu thích',
                              );
                            }
                          }
                        }),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: RepaintBoundary(
                            child: ImageHelper.load(
                              path: isLeagueFavorited
                                  ? AppIcons.iconFavoriteSelected
                                  : AppIcons.iconUnFavorite,
                              width: isDesktop ? 26 : 24,
                              height: isDesktop ? 26 : 24,
                              fit: BoxFit.contain,
                              color: isLeagueFavorited
                                  ? null
                                  : const Color(0xB3FFFCDB),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onToggleExpand != null)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: SoundTap.wrap(onToggleExpand),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: ShapeDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              turns: isExpanded ? 0.5 : 0,
                              child: RepaintBoundary(
                                child: ImageHelper.load(
                                  path: AppIcons.chevronUp,
                                  width: isDesktop ? 22 : 20,
                                  height: isDesktop ? 22 : 20,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _buildRungStrokeConsumer(),
          ],
      ),
    );
  }

  Widget _buildRungStrokeConsumer() {
    return Consumer(
      builder: (context, ref, _) {
        final hasVibrating = ref.watch(
          hasVibratingInLeagueProvider(league.leagueId),
        );

        if (!hasVibrating) return const SizedBox.shrink();

        return Positioned(
          left: 0,
          right: 0,
          top: 3,
          child: ImageHelper.load(path: AppIcons.rungStoke, fit: BoxFit.fill),
        );
      },
    );
  }

  static const _logoDecoration = BoxDecoration(
    color: Color(0xFFE0E0E0),
  );

  Widget _buildLeagueLogo(int currentSportId) {
    if (league.leagueLogo.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        child: Container(
          width: isDesktop ? 28 : 26,
          height: isDesktop ? 28 : 26,
          decoration: _logoDecoration,
          padding: const EdgeInsets.all(2),
          child: ImageHelper.load(
            path: league.leagueLogo,
            width: isDesktop ? 24 : 22,
            height: isDesktop ? 24 : 22,
            fit: BoxFit.contain,
            errorWidget: RepaintBoundary(
              child: ImageHelper.load(
                path: SportType.fromId(currentSportId)?.iconPath ?? '',
                width: isDesktop ? 24 : 22,
                height: isDesktop ? 24 : 22,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
            placeholder: const SizedBox.shrink(),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: ImageHelper.load(
        path: SportType.fromId(currentSportId)?.iconPath ?? '',
        width: isDesktop ? 26 : 24,
        height: isDesktop ? 26 : 24,
        fit: BoxFit.contain,
      ),
    );
  }
}

abstract class _HeaderDecorations {
  static final BoxShadow _topInnerShadow = BoxShadow(
    offset: const Offset(0, -0.65),
    blurRadius: 0.5,
    spreadRadius: 0.05,
    blurStyle: BlurStyle.inner,
    color: Colors.white.withValues(alpha: 0.15),
  );

  static final BoxDecoration expanded = BoxDecoration(
    color: AppColorStyles.backgroundQuaternary,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    ),
    boxShadow: [_topInnerShadow],
  );

  static final BoxDecoration collapsed = BoxDecoration(
    color: AppColorStyles.backgroundQuaternary,
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    boxShadow: [_topInnerShadow],
  );
}
