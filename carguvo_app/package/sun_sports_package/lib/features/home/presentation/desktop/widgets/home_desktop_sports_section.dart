import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class HomeDesktopSportsSection extends ConsumerWidget {
  const HomeDesktopSportsSection({super.key});

  static const Set<int> _supportedSportIds = {1, 2, 4, 5, 7};

  static List<Map<String, dynamic>> get _sportCards => [
    {
      'name': 'BÓNG ĐÁ',
      'color': const Color(0xFFFF5882),
      'image': AppImages.personSoccer,
      'sportId': 1,
    },
    {
      'name': 'BÓNG CHUYỀN',
      'color': AppColors.yellow600,
      'image': AppImages.personVolleyball,
      'sportId': 5,
    },
    {
      'name': 'BÓNG RỔ',
      'color': AppColors.blue700,
      'image': AppImages.personBasketball,
      'sportId': 2,
    },
    {
      'name': 'CẦU LÔNG',
      'color': AppColors.red600,
      'image': AppImages.personBadminton,
      'sportId': 7,
    },
    {
      'name': 'QUẦN VỢT',
      'color': const Color(0xFF21847B),
      'image': AppImages.personTennis,
      'sportId': 4,
    },
  ];

  void _onSportCardTap(
    BuildContext context,
    WidgetRef ref,
    int sportId,
    String sportName,
  ) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(sbMaintenanceProvider)) return const SizedBox.shrink();

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
          _buildSectionHeader('Thể thao nổi bật'),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: Row(
              children: _sportCards.asMap().entries.map((entry) {
                final index = entry.key;
                final card = entry.value;
                final sportId = card['sportId'] as int;
                final sportName = card['name'] as String;
                return Expanded(
                  child: Row(
                    children: [
                      if (index > 0) const Gap(8),
                      Expanded(
                        child: InkWell(
                          onTap: SoundTap.wrap(
                            () => _onSportCardTap(
                              context,
                              ref,
                              sportId,
                              sportName,
                            ),
                          ),
                          child: _SportCard(
                            sportName: sportName,
                            backgroundColor: card['color'] as Color,
                            imagePath: card['image'] as String,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Container(
    height: 44,
    padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.labelMedium(
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildNavigationButton(IconData icon) => Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: BorderRadius.circular(100),
    ),
    child: Center(
      child: Icon(icon, size: 20, color: AppColorStyles.contentPrimary),
    ),
  );
}

class _SportCard extends StatefulWidget {
  const _SportCard({
    required this.sportName,
    required this.backgroundColor,
    required this.imagePath,
  });

  final String sportName;
  final Color backgroundColor;
  final String imagePath;

  @override
  State<_SportCard> createState() => _SportCardState();
}

class _SportCardState extends State<_SportCard> {
  static const double _hoverScale = 1.08;
  static const Duration _duration = Duration(milliseconds: 250);
  static const Curve _curve = Curves.easeOutCubic;

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isHovered ? _hoverScale : 1.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InnerShadowCard(
        borderRadius: 12,
        child: AspectRatio(
          aspectRatio: 149 / 200,
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 1.0,
                      child: ImageHelper.load(
                        path: AppIcons.sunShadow,
                        fit: BoxFit.cover,
                        cacheWidth: 600,
                        cacheHeight: 800,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedScale(
                      scale: scale,
                      duration: _duration,
                      curve: _curve,
                      alignment: Alignment.bottomCenter,
                      child: ImageHelper.load(
                        path: widget.imagePath,
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        cacheHeight: 1000,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.25, 1.0],
                          colors: [
                            widget.backgroundColor.withOpacity(0),
                            widget.backgroundColor.withOpacity(0.5),
                            widget.backgroundColor,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 12, bottom: 32),
                      alignment: Alignment.center,
                      child: AnimatedScale(
                        scale: scale,
                        duration: _duration,
                        curve: _curve,
                        child: Text(
                          widget.sportName,
                          style:
                              AppTextStyles.headingXSmall(
                                color: const Color(0xFFFFFEF5),
                              ).copyWith(
                                fontWeight: FontWeight.w900,
                                height: 20 / 20,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
