import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';

import 'casino_view.dart';

class CasinoScreen extends StatelessWidget {
  const CasinoScreen({
    super.key,
    this.backgroundColor = AppColorStyles.backgroundSecondary,
    this.showLiveChat = false,
  });

  final Color? backgroundColor;

  final bool showLiveChat;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final isMobile = deviceType == DeviceType.mobile;

        final hasOverlayHeader = !ResponsiveBuilder.isDesktop(context);

        if (isMobile) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: CasinoView(
              backgroundColor: backgroundColor,
              showLiveChat: showLiveChat,
              isMobile: true,
              hasOverlayHeader: hasOverlayHeader,
            ),
          );
        }

        final isTablet = deviceType == DeviceType.tablet;

        return SizedBox.expand(
          child: CasinoView(
            backgroundColor: backgroundColor,
            showLiveChat: showLiveChat,
            isMobile: false,
            hasOverlayHeader: hasOverlayHeader,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 0 : AppSpacingStyles.space800,
            ),
          ),
        );
      },
    );
  }
}
