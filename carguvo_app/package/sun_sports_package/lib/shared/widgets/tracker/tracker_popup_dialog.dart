import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/tracker/tracker_widget.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class TrackerPopupDialog extends StatelessWidget {
  final int eventStatsId;
  final int sportId;
  final String? homeName;
  final String? awayName;

  const TrackerPopupDialog({
    required this.eventStatsId,
    super.key,
    this.sportId = 1,
    this.homeName,
    this.awayName,
  });

  static Future<void> show({
    required BuildContext context,
    required int eventStatsId,
    int? sportId,
    String? homeName,
    String? awayName,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => TrackerPopupDialog(
        eventStatsId: eventStatsId,
        sportId: sportId ?? SbHttpManager.instance.sportTypeId,
        homeName: homeName,
        awayName: awayName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = ResponsiveBuilder.isDesktop(context);
    final dialogWidth = isDesktop ? (screenWidth / 2 - 32) : (screenWidth - 32);
    final dialogHeight = (dialogWidth * 9 / 16);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: InnerShadowCard(
        borderRadius: 16,
        color: AppColorStyles.backgroundSecondary,
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundSecondary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              _buildTrackerContent(dialogHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: AppColorStyles.borderPrimary, width: 1),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            homeName != null && awayName != null
                ? '$homeName vs $awayName'
                : 'Theo dõi trận đấu',
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColorStyles.contentPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: SoundTap.wrap(() => Navigator.of(context).pop()),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundTertiary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close,
              color: AppColorStyles.contentSecondary,
              size: 16,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildTrackerContent(double dialogHeight) => TrackerWidget(
    eventStatsId: eventStatsId,
    sportId: sportId,
    height: dialogHeight,
    ignoreOverlayBlock: true,
  );
}
