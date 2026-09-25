import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/features/home/domain/ncc_sportbook.dart';
import 'package:sun_sports/features/home/presentation/widgets/ncc_maintenance_badge.dart';
import 'package:sun_sports/features/home/presentation/ncc_launch_handler.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class HomeDesktopNccSection extends ConsumerWidget {
  const HomeDesktopNccSection({super.key});

  static List<_NccProvider> get _providers => [
    _NccProvider(
      type: NccProvider.ksport,
      name: 'KSPORT',
      image: AppImages.imageBannerKSport,
      gradientTop: const Color(0xFFCD2828),
      gradientBottom: const Color(0xFFA71B1B),
      borderColor: const Color(0xFFFF2424),
      overlayColor: const Color(0xFF6C1006),
      logoPath: AppIcons.iconKSport,
      imageRect: const Rect.fromLTWH(150, -2, 232.5, 160),
    ),
    _NccProvider(
      type: NccProvider.saba,
      name: 'SABA SPORT',
      image: AppImages.imageBannerSaba,
      gradientTop: const Color(0xFFB78300),
      gradientBottom: const Color(0xFF985800),
      borderColor: const Color(0xFFFFB700),
      overlayColor: const Color(0xFF985800),
      logoPath: AppIcons.iconSaba,
      imageRect: const Rect.fromLTWH(154, -2, 232.5, 160),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sbMaintenance = ref.watch(sbMaintenanceProvider);
    final providers = _providers;
    return Container(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.12),
          offset: const Offset(0, 0.5),
          blurRadius: 0.5,
          spreadRadius: 0,
          blurStyle: BlurStyle.inner,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Top nhà cung cấp'),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < providers.length; i++) ...[
                if (i > 0) const Gap(8),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap:
                        sbMaintenance && providers[i].type == NccProvider.ksport
                        ? null
                        : SoundTap.wrap(
                            () => _handleTap(ref, context, providers[i].type),
                          ),
                    child: _NccProviderCard(
                      provider: providers[i],
                      maintenance:
                          sbMaintenance &&
                          providers[i].type == NccProvider.ksport,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
  }

  Future<void> _handleTap(
    WidgetRef ref,
    BuildContext context,
    NccProvider type,
  ) => handleNccTap(ref, context, type);

  Widget _buildSectionHeader(String title) => Container(
    height: 44,
    padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: AppTextStyles.labelMedium(color: AppColorStyles.contentPrimary),
    ),
  );

}

class _NccProviderCard extends StatefulWidget {
  const _NccProviderCard({required this.provider, this.maintenance = false});

  final _NccProvider provider;

  final bool maintenance;

  @override
  State<_NccProviderCard> createState() => _NccProviderCardState();
}

class _NccProviderCardState extends State<_NccProviderCard> {
  static const double _designCardWidth = 390;
  static const double _cardAspectRatio = 390 / 160;

  static const double _overlayWidthFactor = 0.5;

  static const double _hoverScale = 1.08;
  static const Duration _hoverDuration = Duration(milliseconds: 250);
  static const Curve _hoverCurve = Curves.easeOutCubic;

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final hoverScale = _isHovered ? _hoverScale : 1.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / _designCardWidth;
          final imageRect = provider.imageRect;
          return AspectRatio(
            aspectRatio: _cardAspectRatio,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: provider.borderColor, width: 2),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [provider.gradientTop, provider.gradientBottom],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Positioned(
                      left: imageRect.left * scale,
                      top: imageRect.top * scale,
                      width: imageRect.width * scale,
                      height: imageRect.height * scale,
                      child: AnimatedScale(
                        scale: hoverScale,
                        duration: _hoverDuration,
                        curve: _hoverCurve,
                        alignment: Alignment.bottomCenter,
                        child: ImageHelper.load(
                          path: provider.image,
                          fit: BoxFit.cover,
                          cacheWidth: 800,
                          cacheHeight: 1000,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _overlayWidthFactor,
                          heightFactor: 1,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                              16 * scale,
                              16 * scale,
                              16 * scale,
                              24 * scale,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  provider.overlayColor,
                                  provider.overlayColor.withOpacity(0),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: hoverScale,
                                  duration: _hoverDuration,
                                  curve: _hoverCurve,
                                  child: _buildLogo(provider.logoPath, scale),
                                ),
                                Gap(12 * scale),
                                AnimatedScale(
                                  scale: hoverScale,
                                  duration: _hoverDuration,
                                  curve: _hoverCurve,
                                  child: Text(
                                    provider.name,
                                    style:
                                        AppTextStyles.headingXSmall(
                                          color: const Color(0xFFFFFEF5),
                                        ).copyWith(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20 * scale,
                                          height: 1,
                                        ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                            color: Colors.black.withOpacity(0.45),
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
                    if (widget.maintenance)
                      const Positioned(top: 0, right: 0, child: NccMaintenanceBadge()),
                  
],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo(String logoPath, double scale) {
    final size = 44 * scale;
    final cacheSize = (size * 2).round();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: ImageHelper.load(
        path: logoPath,
        width: size,
        height: size,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
        fit: BoxFit.contain,
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
    required this.imageRect,
  });

  final NccProvider type;
  final String name;
  final String image;
  final Color gradientTop;
  final Color gradientBottom;
  final Color borderColor;
  final Color overlayColor;
  final String logoPath;

  final Rect imageRect;
}
