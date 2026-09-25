import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/stats/stats_widget.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class StatsDialogConfig {
  final double widthFactor;

  final double heightFactor;

  final double horizontalPadding;

  final double verticalPadding;

  const StatsDialogConfig({
    this.widthFactor = 0.8,
    this.heightFactor = 0.85,
    this.horizontalPadding = 40,
    this.verticalPadding = 24,
  });

  static const desktop = StatsDialogConfig(
    widthFactor: 0.8,
    heightFactor: 0.85,
    horizontalPadding: 40,
    verticalPadding: 24,
  );

  static const mobile = StatsDialogConfig(
    widthFactor: 1.0,
    heightFactor: 0.9,
    horizontalPadding: 0,
    verticalPadding: 0,
  );

  static const tablet = StatsDialogConfig(
    widthFactor: 0.7,
    heightFactor: 0.8,
    horizontalPadding: 24,
    verticalPadding: 16,
  );
}

class StatsDialog extends StatelessWidget {
  final int eventStatsId;

  final int sportId;

  final String title;

  final StatsDialogConfig config;

  final double? width;

  final double? height;

  const StatsDialog({
    super.key,
    required this.eventStatsId,
    required this.sportId,
    required this.title,
    this.config = StatsDialogConfig.desktop,
    this.width,
    this.height,
  });

  static Future<void> show({
    required BuildContext context,
    required int eventStatsId,
    required int sportId,
    required String title,
    StatsDialogConfig config = StatsDialogConfig.desktop,
    double? width,
    double? height,
  }) {
    if (eventStatsId == 0) return Future.value();

    return showDialog<void>(
      context: context,
      builder: (context) => StatsDialog(
        eventStatsId: eventStatsId,
        sportId: sportId,
        title: title,
        config: config,
        width: width,
        height: height,
      ),
    );
  }

  static Future<void> showForMatch({
    required BuildContext context,
    required int eventStatsId,
    required String homeName,
    required String awayName,
    StatsDialogConfig config = StatsDialogConfig.desktop,
    double? width,
    double? height,
  }) {
    return show(
      context: context,
      eventStatsId: eventStatsId,
      sportId: SbHttpManager.instance.sportTypeId,
      title: '$homeName vs $awayName',
      config: config,
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final dialogWidth = width ?? mediaQuery.size.width * config.widthFactor;
    final dialogHeight = height ?? mediaQuery.size.height * config.heightFactor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: config.horizontalPadding,
        vertical: config.verticalPadding,
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StatsWidget(
                eventStatsId: eventStatsId,
                sportId: sportId,
                ignoreOverlayBlock: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Color(0xFF252525),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.labelMedium(
              color: AppColorStyles.contentPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: SoundTap.wrap(() => Navigator.of(context).pop()),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close,
              color: AppColorStyles.contentSecondary,
              size: 20,
            ),
          ),
        ),
      ],
    ),
  );
}

mixin StatsDialogMixin<T extends StatefulWidget> on State<T> {
  void showStatsDialog({
    required int eventStatsId,
    required int sportId,
    required String title,
    StatsDialogConfig config = StatsDialogConfig.desktop,
    double? width,
    double? height,
  }) {
    StatsDialog.show(
      context: context,
      eventStatsId: eventStatsId,
      sportId: sportId,
      title: title,
      config: config,
      width: width,
      height: height,
    );
  }

  void showStatsDialogForMatch({
    required int eventStatsId,
    required String homeName,
    required String awayName,
    StatsDialogConfig config = StatsDialogConfig.desktop,
    double? width,
    double? height,
  }) {
    StatsDialog.showForMatch(
      context: context,
      eventStatsId: eventStatsId,
      homeName: homeName,
      awayName: awayName,
      config: config,
      width: width,
      height: height,
    );
  }
}
