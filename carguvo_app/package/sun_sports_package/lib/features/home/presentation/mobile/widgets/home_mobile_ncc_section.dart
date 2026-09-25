import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/home/domain/ncc_sportbook.dart';
import 'package:sun_sports/features/home/presentation/ncc_launch_handler.dart';
import 'package:sun_sports/features/home/presentation/widgets/ncc_maintenance_badge.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class HomeMobileNccSection extends ConsumerWidget {
  const HomeMobileNccSection({super.key});

  static List<_NccProvider> get _providers => [
    _NccProvider(
      type: NccProvider.ksport,
      name: 'KSPORT',
      image: AppImages.imageBannerKSportMobile,
      gradientTop: const Color(0xFFCD2828),
      gradientBottom: const Color(0xFFA71B1B),
      borderColor: const Color(0xFFFF2424),
      overlayColor: const Color(0xFF6C1006),
      logoPath: AppIcons.iconKSport,
      logoWidth: 29.682,
      logoHeight: 29.684,
      logoGap: 8.095,
    ),
    _NccProvider(
      type: NccProvider.saba,
      name: 'SABA SPORT',
      image: AppImages.imageBannerSabaMobile,
      gradientTop: const Color(0xFFB78300),
      gradientBottom: const Color(0xFF985800),
      borderColor: const Color(0xFFFFB700),
      overlayColor: const Color(0xFF985800),
      logoPath: AppIcons.iconSaba,
      logoWidth: 26,
      logoHeight: 26,
    ),
    _NccProvider(
      type: NccProvider.bti,
      name: 'BTI SPORT',
      image: AppImages.imageBannerBTI,
      gradientTop: const Color(0xFF008FB7),
      gradientBottom: const Color(0xFF007798),
      borderColor: const Color(0xFF00E5FF),
      overlayColor: const Color(0xFF29799C),
      logoPath: AppIcons.iconBTI,
      logoWidth: 26,
      logoHeight: 26,
      overlayFrom: const Color(0x0006396C),
    ),
    _NccProvider(
      type: NccProvider.imSport,
      name: 'IM ESPORT',
      image: AppImages.imageBannerIMEsport,
      gradientTop: const Color(0xFF7628B1),
      gradientBottom: const Color(0xFF6926A4),
      borderColor: const Color(0xFFE74FFF),
      overlayColor: const Color(0xFF53066C),
      logoPath: AppIcons.iconIMEsport,
      logoWidth: 37.801,
      logoHeight: 17.299,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sbMaintenance = ref.watch(sbMaintenanceProvider);
    final providers = _providers;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < providers.length; i++) ...[
            if (i > 0) const Gap(8),
            Expanded(
              child: _buildInkWell(context, ref, providers[i], sbMaintenance),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInkWell(
    BuildContext context,
    WidgetRef ref,
    _NccProvider provider,
    bool sbMaintenance,
  ) {
    final isMaintenance = sbMaintenance && provider.type == NccProvider.ksport;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: isMaintenance
          ? null
          : SoundTap.wrap(() => _handleTap(ref, context, provider.type)),
      child: _buildProviderCard(provider, maintenance: isMaintenance),
    );
  }

  static Future<void> _handleTap(
    WidgetRef ref,
    BuildContext context,
    NccProvider type,
  ) => handleNccTap(ref, context, type);

  static const double _designCardWidth = 92;
  static const double _designCardHeight = 100;
  static const double _cardAspectRatio = _designCardWidth / _designCardHeight;

  static const double _overlayHeightFactor = 1.0;

  static const double _cardPaddingX = 12;
  static const double _cardPaddingY = 8;

  static const double _designNameSize = 10.794;
  static const double _nameLineHeight = 13.492 / _designNameSize;

  static Widget _buildProviderCard(
    _NccProvider provider, {
    bool maintenance = false,
  }) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = constraints.maxWidth / _designCardWidth;
      return AspectRatio(
        aspectRatio: _cardAspectRatio,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: provider.borderColor, width: 0.5),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [provider.gradientTop, provider.gradientBottom],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11.5),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ImageHelper.load(
                    path: provider.image,
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    cacheHeight: 300,
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: _overlayHeightFactor,
                      child: Container(
                        width: constraints.maxWidth,
                        padding: EdgeInsets.symmetric(
                          horizontal: _cardPaddingX * scale,
                          vertical: _cardPaddingY * scale,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              provider.overlayFrom ??
                                  provider.overlayColor.withValues(alpha: 0),
                              provider.overlayColor,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildLogo(provider, scale),
                            Gap(provider.logoGap * scale),
                            Text(
                              provider.name,
                              style:
                                  AppTextStyles.headingXSmall(
                                    color: const Color(0xFFFFFEF5),
                                  ).copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: _designNameSize * scale,
                                    height: _nameLineHeight,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final isLoading = ref.watch(
                        nccLaunchProvider.select((p) => p == provider.type),
                      );
                      if (!isLoading) return const SizedBox.shrink();
                      return ColoredBox(
                        color: Colors.black.withValues(alpha: 0.45),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFFFFFEF5),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (maintenance)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: NccMaintenanceBadge(),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );

  static const double _logoBoxHeight = 29.684;

  static Widget _buildLogo(_NccProvider provider, double scale) {
    final logoWidth = provider.logoWidth * scale;
    final logoHeight = provider.logoHeight * scale;
    return SizedBox(
      height: _logoBoxHeight * scale,
      child: Center(
        child: ImageHelper.load(
          path: provider.logoPath,
          width: logoWidth,
          height: logoHeight,
          cacheWidth: (logoWidth * 2).round(),
          cacheHeight: (logoHeight * 2).round(),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _NccProvider {
  const _NccProvider({
    required this.type,
    required this.name,
    required this.image,
    required this.gradientTop,
    required this.gradientBottom,
    required this.borderColor,
    required this.overlayColor,
    required this.logoPath,
    required this.logoWidth,
    required this.logoHeight,
    this.logoGap = 6,
    this.overlayFrom,
  });

  final NccProvider type;
  final String name;
  final String image;
  final Color gradientTop;
  final Color gradientBottom;
  final Color borderColor;
  final Color overlayColor;
  final String logoPath;

  final double logoWidth;
  final double logoHeight;

  final double logoGap;

  final Color? overlayFrom;
}
