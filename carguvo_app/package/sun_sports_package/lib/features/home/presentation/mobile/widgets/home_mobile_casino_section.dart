import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class _CasinoCardData {
  final String name;
  final String provider;
  final Color color;

  const _CasinoCardData({
    required this.name,
    required this.provider,
    required this.color,
  });
}

class HomeMobileCasinoSection extends StatefulWidget {
  const HomeMobileCasinoSection({super.key});

  @override
  State<HomeMobileCasinoSection> createState() =>
      _HomeMobileCasinoSectionState();
}

class _HomeMobileCasinoSectionState extends State<HomeMobileCasinoSection> {
  final ScrollController _scrollController = ScrollController();

  bool _isAtStart = true;
  bool _isAtEnd = false;

  double _cachedCardWidth = 0;
  double _cachedScrollDistance = 0;

  static const List<_CasinoCardData> _casinoCards = [
    _CasinoCardData(name: 'SUN RỒNG', provider: 'sunwin', color: Color(0xFF905215)),
    _CasinoCardData(name: 'SUN CÁ', provider: 'sunwin', color: Color(0xFF628B1B)),
    _CasinoCardData(name: 'XÓC ĐĨA', provider: 'sunwin', color: Color(0xFF9F9705)),
    _CasinoCardData(name: 'SICBO 88', provider: 'sunwin', color: Color(0xFFB93815)),
    _CasinoCardData(name: 'TÀI XỈU', provider: 'sunwin', color: Color(0xFF90152C)),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCachedDimensions();
  }

  void _updateCachedDimensions() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = ResponsiveBuilder.isTablet(context);
    final itemsPerView = isTablet ? 5 : 3;
    const paddingH = 8.0;
    const gap = 6.0;
    final gapTotal = (itemsPerView - 1) * gap;
    _cachedCardWidth = (screenWidth - paddingH - gapTotal) / itemsPerView;
    _cachedScrollDistance = _cachedCardWidth + gap;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollStateAfterAnimation() {
    if (!_scrollController.hasClients) return;

    final currentOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    final isAtStart = currentOffset <= 1;
    final isAtEnd = currentOffset >= maxScrollExtent - 1;

    if (_isAtStart != isAtStart || _isAtEnd != isAtEnd) {
      setState(() {
        _isAtStart = isAtStart;
        _isAtEnd = isAtEnd;
      });
    }
  }

  void _scrollToPrevious() {
    if (_isAtStart || !_scrollController.hasClients) return;

    final currentOffset = _scrollController.offset;
    final newOffset = currentOffset - _cachedScrollDistance;
    final targetOffset = newOffset < 0 ? 0.0 : newOffset;

    _scrollController
        .animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          _updateScrollStateAfterAnimation();
        });
  }

  void _scrollToNext() {
    if (_isAtEnd || !_scrollController.hasClients) return;

    final currentOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    final newOffset = currentOffset + _cachedScrollDistance;
    final targetOffset = newOffset > maxScrollExtent
        ? maxScrollExtent
        : newOffset;

    _scrollController
        .animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          _updateScrollStateAfterAnimation();
        });
  }

  @override
  Widget build(BuildContext context) => InnerShadowCard(
    borderRadius: 12,
    child: Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Casino nổi bật'),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: SizedBox(
              height: _cachedCardWidth > 0 ? _cachedCardWidth * 140 / 100 : 168,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (_) => true,
                  child: ListView.builder(
                    key: const PageStorageKey<String>('home_casino_scroll'),
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _casinoCards.length,
                    itemExtent: _cachedCardWidth + 6,
                    itemBuilder: (context, index) {
                      final card = _casinoCards[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < _casinoCards.length - 1 ? 6 : 0,
                        ),
                        child: SizedBox(
                          width: _cachedCardWidth,
                          child: _buildCasinoCard(
                            card.name,
                            card.provider,
                            card.color,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSectionHeader(String title) => Container(
    height: 40,
    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.labelSmall(
              context: context,
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavigationButton(Icons.chevron_left, isLeft: true),
            const Gap(4),
            _buildNavigationButton(Icons.chevron_right, isLeft: false),
          ],
        ),
      ],
    ),
  );

  Widget _buildNavigationButton(IconData icon, {required bool isLeft}) {
    final canNavigate = isLeft ? !_isAtStart : !_isAtEnd;

    return GestureDetector(
      onTap: SoundTap.wrap(() {
        if (isLeft) {
          _scrollToPrevious();
        } else {
          _scrollToNext();
        }
      }),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: canNavigate
                ? Colors.orange[200]
                : AppColorStyles.contentPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCasinoCard(
    String gameName,
    String provider,
    Color backgroundColor,
  ) =>
      InnerShadowCard(
        borderRadius: 10,
        child: AspectRatio(
          aspectRatio: 100 / 140,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                clipBehavior: Clip.antiAlias,
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ImageHelper.load(
                        path: AppIcons.sunShadow,
                        fit: BoxFit.cover,
                        cacheWidth: 400,
                        cacheHeight: 600,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.25, 1.0],
                          colors: [
                            backgroundColor.withOpacity(0),
                            backgroundColor.withOpacity(0.5),
                            backgroundColor,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            gameName,
                            style: AppTextStyles.labelSmall(
                              context: context,
                              color: const Color(0xFFFFFEF5),
                            ).copyWith(
                              fontWeight: FontWeight.w900,
                              height: 14 / 14,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(2),
                          Text(
                            provider,
                            style: AppTextStyles.labelXXSmall(
                              context: context,
                              color: AppColorStyles.contentPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
