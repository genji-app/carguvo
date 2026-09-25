import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class _GameCardData {
  final String name;
  final String provider;
  const _GameCardData({required this.name, required this.provider});
}

class HomeMobileLiveCasinoSection extends StatefulWidget {
  const HomeMobileLiveCasinoSection({super.key});

  @override
  State<HomeMobileLiveCasinoSection> createState() =>
      _HomeMobileLiveCasinoSectionState();
}

class _HomeMobileLiveCasinoSectionState
    extends State<HomeMobileLiveCasinoSection> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtStart = true;
  bool _isAtEnd = false;

  static const List<_GameCardData> _gameCards = [
    _GameCardData(name: 'SICBO 88', provider: 'sunwin'),
    _GameCardData(name: 'SICBO 88', provider: 'sunwin'),
    _GameCardData(name: 'SICBO 88', provider: 'sunwin'),
    _GameCardData(name: 'SICBO 88', provider: 'sunwin'),
    _GameCardData(name: 'SICBO 88', provider: 'sunwin'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollState();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateScrollState();
  }

  void _updateScrollState() {
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
    if (_isAtStart) return;

    final currentOffset = _scrollController.offset;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 8 - 12) / 3.0;
    final scrollDistance = cardWidth + 6.0;

    final newOffset = currentOffset - scrollDistance;
    final targetOffset = newOffset < 0 ? 0.0 : newOffset;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToNext() {
    if (_isAtEnd) return;

    final currentOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 8 - 12) / 3.0;
    final scrollDistance = cardWidth + 6.0;

    final newOffset = currentOffset + scrollDistance;
    final targetOffset = newOffset > maxScrollExtent
        ? maxScrollExtent
        : newOffset;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
          _buildSectionHeader('Live Casino'),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: Builder(
              builder: (context) {
                final cardWidth =
                    (MediaQuery.sizeOf(context).width - 8 - 12) / 3;
                final cardHeight = cardWidth * 140 / 100;
                return SizedBox(
                  height: cardHeight,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (_) => true,
                      child: ListView.builder(
                        key: const PageStorageKey<String>(
                          'home_live_casino_scroll',
                        ),
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: _gameCards.length,
                        itemExtent: cardWidth + 6,
                        itemBuilder: (context, index) {
                          final card = _gameCards[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < _gameCards.length - 1 ? 6 : 0,
                            ),
                            child: SizedBox(
                              width: cardWidth,
                              child: _buildGameCard(card.name, card.provider),
                            ),
                          );
                        },
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

  Widget _buildSectionHeader(String title) => Container(
    height: 40,
    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.labelSmall(
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

  Widget _buildGameCard(String gameName, String provider) {
    const backgroundColor = AppColors.orange700;

    return InnerShadowCard(
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
              clipBehavior: Clip.antiAliasWithSaveLayer,
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
                          style:
                              AppTextStyles.labelSmall(
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
}
