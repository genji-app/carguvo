import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/providers/main_content_provider.dart';
import 'package:app_package/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:app_package/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:app_package/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:app_package/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_color.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_icons.dart';
import 'package:app_package/core/utils/styles/app_images.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/shared/widgets/cards/inner_shadow_card.dart';
import 'package:app_package/shared/widgets/scroll/scroll.dart';
import 'package:app_package/shared/widgets/toast/app_toast.dart';

class HomeMobileSportsSection extends ConsumerStatefulWidget {
  const HomeMobileSportsSection({super.key});

  @override
  ConsumerState<HomeMobileSportsSection> createState() =>
      _HomeMobileSportsSectionState();
}

class _SportCardData {
  final String name;
  final Color color;
  final String image;
  final int sportId;

  const _SportCardData({
    required this.name,
    required this.color,
    required this.image,
    required this.sportId,
  });
}

class _HomeMobileSportsSectionState
    extends ConsumerState<HomeMobileSportsSection> {
  static const Set<int> _supportedSportIds = {1, 2, 4, 5, 7};
  static const double _cardWidth = 154;
  static const double _cardHeight = 100;
  static const double _cardGap = 8;

  final ScrollController _scrollController = ScrollController();

  static List<_SportCardData> get _sportCards => [
    _SportCardData(
      name: 'BÓNG ĐÁ',
      color: const Color(0xFFFF5882),
      image: AppImages.personSoccer,
      sportId: 1,
    ),
    _SportCardData(
      name: 'BÓNG CHUYỀN',
      color: AppColors.yellow600,
      image: AppImages.personVolleyball,
      sportId: 5,
    ),
    _SportCardData(
      name: 'BÓNG RỔ',
      color: AppColors.blue700,
      image: AppImages.personBasketball,
      sportId: 2,
    ),
    _SportCardData(
      name: 'CẦU LÔNG',
      color: AppColors.red600,
      image: AppImages.personBadminton,
      sportId: 7,
    ),
    _SportCardData(
      name: 'QUẦN VỢT',
      color: const Color(0xFF21847B),
      image: AppImages.personTennis,
      sportId: 4,
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSportCardTap(int sportId, String sportName) {
    if (_supportedSportIds.contains(sportId)) {
      ref.read(previousContentProvider.notifier).state = MainContentType.home;
      final sport = v2.SportType.fromId(sportId) ?? v2.SportType.soccer;
      ref.read(selectedSportV2Provider.notifier).state = sport;

      ref
          .read(sportSocketAdapterProvider)
          .subscriptionManager
          .setActiveSport(sportId);

      ref.read(mainContentProvider.notifier).goToSportDetail();
    } else {
      AppToast.showError(context, message: 'Môn $sportName chưa được cập nhật');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(sbMaintenanceProvider)) return const SizedBox.shrink();

    final cards = _sportCards;
    final nameStyle = _nameStyle(context, cards);
    return InnerShadowCard(
      borderRadius: 16,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              child: Text(
                'Thể thao nổi bật',
                style: AppTextStyles.labelSmall(
                  context: context,
                  color: AppColorStyles.contentPrimary,
                ).copyWith(height: 24 / 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = math.max(
                    _cardWidth,
                    (constraints.maxWidth - _cardGap * (cards.length - 1)) /
                        cards.length,
                  );
                  final scale = cardWidth / _cardWidth;
                  return SizedBox(
                    height: _cardHeight * scale,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(scrollbars: false),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (_) => true,
                        child: AxisLockHorizontalScroll(
                          controller: _scrollController,
                          child: ListView.builder(
                            key: const PageStorageKey<String>(
                              'home_sports_scroll',
                            ),
                            controller: _scrollController,
                            physics: const NeverScrollableScrollPhysics(
                              parent: ClampingScrollPhysics(),
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: cards.length,
                            itemBuilder: (context, index) {
                              final card = cards[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index < cards.length - 1
                                      ? _cardGap
                                      : 0,
                                ),
                                child: GestureDetector(
                                  onTap: () =>
                                      _onSportCardTap(card.sportId, card.name),
                                  child: SizedBox(
                                    width: cardWidth,
                                    child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: SizedBox(
                                        width: _cardWidth,
                                        height: _cardHeight,
                                        child: _buildSportCard(
                                          card.name,
                                          card.color,
                                          card.image,
                                          nameStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _nameStyle(BuildContext context, List<_SportCardData> cards) {
    final style = AppTextStyles.textStyle(
      context: context,
      fontSize: 20,
      height: 1,
      fontWeight: FontWeight.w900,
      color: Colors.white,
    );
    final textScaler = MediaQuery.textScalerOf(context);
    var widest = 0.0;
    for (final card in cards) {
      final painter = TextPainter(
        text: TextSpan(text: card.name, style: style),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
      painter.dispose();
    }
    const available = _cardWidth - 8;
    if (widest <= available) return style;
    return style.copyWith(fontSize: style.fontSize! * available / widest);
  }

  Widget _buildSportCard(
    String sportName,
    Color backgroundColor,
    String imagePath,
    TextStyle nameStyle,
  ) {
    const radius = Radius.circular(12);
    return ClipRRect(
      borderRadius: const BorderRadius.all(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(radius),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ImageHelper.load(
                path: AppIcons.sunShadow,
                fit: BoxFit.cover,
                cacheWidth: 400,
                cacheHeight: 600,
              ),
            ),
            Positioned(
              top: -24,
              left: 0,
              right: 0,
              height: _cardWidth * 148 / 100,
              child: ImageHelper.load(
                path: imagePath,
                fit: BoxFit.cover,
                cacheWidth: 600,
                cacheHeight: 800,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 72,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: radius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.25, 1.0],
                    colors: [
                      backgroundColor.withValues(alpha: 0),
                      backgroundColor.withValues(alpha: 0.5),
                      backgroundColor,
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.bottomCenter,
                child: Text(
                  sportName,
                  style: nameStyle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _CardCornerCoverPainter(
                    color: AppColorStyles.backgroundTertiary,
                    radius: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardCornerCoverPainter extends CustomPainter {
  const _CardCornerCoverPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius))),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_CardCornerCoverPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
