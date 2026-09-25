import 'package:sun_sports/core/services/provider_game/provider_game_providers.dart';
import 'package:sun_sports/features/game/lobby_game_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/game/banner/banner_card.dart';
import 'package:sun_sports/features/game/banner/casino_provider_info.dart';
import 'package:sun_sports/features/game/banner/widgets/banner_card_text.dart';
import 'package:sun_sports/features/game/banner/widgets/provider_logos_group.dart';
import 'package:sun_sports/features/game/category/game_category_selection.dart';
import 'package:sun_sports/features/game/game_extensions.dart';

export 'banner_card.dart';
export 'casino_provider_info.dart';
export 'widgets/banner_card_text.dart';
export 'widgets/provider_logo_item.dart';
export 'widgets/provider_logos_group.dart';

class BannerProviders extends ConsumerWidget {
  final VoidCallback? onTap;

  final ValueChanged<CasinoProviderInfo>? onProviderSelected;

  const BannerProviders({super.key, this.onTap, this.onProviderSelected});

  void _handleProviderTap(
    BuildContext context,
    WidgetRef ref,
    CasinoProviderInfo provider,
  ) {
    if (onProviderSelected != null) {
      onProviderSelected!(provider);
      return;
    }

    final categories = ref.read(lobbyCategoriesProvider);
    final matched = categories
        .where((c) => c.id == provider.id && !c.isAll)
        .firstOrNull;

    ref.goToCasino(
      selection: matched == null
          ? const GameCategorySelection()
          : GameCategorySelection.fromCategory(matched),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;

        if (cardWidth < 620) {
          return _MediumBanner(
            isMobile: true,
            onTap: onTap,
            onProviderSelected: (p) => _handleProviderTap(context, ref, p),
          );
        }

        final isCompactDesktop = cardWidth < 780;
        final itemSize = isCompactDesktop ? 62.0 : 72.0;
        final spacing = isCompactDesktop ? 6.0 : 10.0;

        return _LargeBanner(
          isMobile: false,
          itemSize: itemSize,
          spacing: spacing,
          onTap: onTap,
          onProviderSelected: (p) => _handleProviderTap(context, ref, p),
        );
      },
    );
  }
}

class _MediumBanner extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onTap;
  final ValueChanged<CasinoProviderInfo>? onProviderSelected;

  const _MediumBanner({
    required this.isMobile,
    this.onTap,
    this.onProviderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 138,
      child: BannerCard(
        color: AppColorStyles.backgroundSecondary,
        colorOverlay: Colors.grey.withValues(alpha: 0.45),
        borderColor: const Color(0xFFF38744),
        borderWidth: 1,
        inlinePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        onTap: onTap,
        childTextContent: BannerCardText(
          title: '500+',
          subtitle: 'Casino games',
          titleColor: AppColors.orange400,
          isMobile: isMobile,
        ),
        inlineContentBuilder: (isCardHovered) => Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: AnimatedScale(
              scale: isCardHovered ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              alignment: Alignment.centerLeft,
              child: ProviderLogosGroup(
                itemSize: 40,
                spacing: 9.4,
                onProviderSelected: onProviderSelected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LargeBanner extends StatelessWidget {
  final bool isMobile;
  final double itemSize;
  final double spacing;
  final VoidCallback? onTap;
  final ValueChanged<CasinoProviderInfo>? onProviderSelected;

  const _LargeBanner({
    required this.isMobile,
    this.itemSize = 72,
    this.spacing = 10,
    this.onTap,
    this.onProviderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: BannerCard(
        color: AppColorStyles.backgroundSecondary,
        colorOverlay: Colors.grey.withValues(alpha: 0.45),
        borderColor: const Color(0xFFF38744),
        onTap: onTap,
        childTextContent: BannerCardText(
          title: '500+',
          subtitle: 'Casino games',
          titleColor: AppColors.orange400,
          isMobile: isMobile,
        ),
        overlayImageBuilder: (isCardHovered) => Positioned(
          top: (104 - itemSize) / 2,
          right: 20,
          child: AnimatedScale(
            scale: isCardHovered ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: Alignment.centerRight,
            child: ProviderLogosGroup(
              itemSize: itemSize,
              spacing: spacing,
              onProviderSelected: onProviderSelected,
            ),
          ),
        ),
      ),
    );
  }
}
