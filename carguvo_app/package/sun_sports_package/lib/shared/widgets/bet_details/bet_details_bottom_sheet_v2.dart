import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/platform_utils.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';
import 'package:sun_sports/shared/layouts/shell_nav_bottom_sheet_route.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/bet_details/bet_details_content.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:sun_sports/shared/widgets/bet_details/providers/betting_popup_v2_provider.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';

class BetDetailsBottomSheetV2 extends ConsumerStatefulWidget {
  final BettingPopupDataV2? data;
  final bool isVibrating;
  final bool isBottomSheet;

  const BetDetailsBottomSheetV2({
    super.key,
    this.data,
    this.isVibrating = false,
    this.isBottomSheet = false,
  });

  @override
  ConsumerState<BetDetailsBottomSheetV2> createState() =>
      _BetDetailsBottomSheetV2State();

  static Future<void> show(
    BuildContext context, {
    BettingPopupDataV2? data,
    bool isVibrating = false,
  }) {
    if (data != null) {
      ProviderScope.containerOf(context, listen: false)
          .read(bettingPopupV2Provider.notifier)
          .resetForNewPopup(data);
    }

    final isMobileScreen = ResponsiveBuilder.isMobile(context);
    final useBottomSheet =
        PlatformUtils.isMobile || (PlatformUtils.isWeb && isMobileScreen);

    pushLivestreamOverlayBlock();

    if (useBottomSheet) {
      ProviderScope.containerOf(context, listen: false)
          .read(scrollHideProvider)
          .show();

      final navigator = Navigator.of(context);
      final localizations = MaterialLocalizations.of(context);
      return navigator
          .push(
            ShellNavBottomSheetRoute<void>(
              builder: (context) => BetDetailsBottomSheetV2(
                data: data,
                isVibrating: isVibrating,
                isBottomSheet: true,
              ),
              capturedThemes: InheritedTheme.capture(
                from: context,
                to: navigator.context,
              ),
              isScrollControlled: true,
              enableDrag: true,
              isDismissible: true,
              backgroundColor: Colors.transparent,
              modalBarrierColor: Colors.black.withValues(alpha: 0.8),
              barrierLabel: localizations.scrimLabel,
              barrierOnTapHint: localizations.scrimOnTapHint(
                localizations.bottomSheetLabel,
              ),
            ),
          )
          .whenComplete(popLivestreamOverlayBlock);
    }

    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) =>
          BetDetailsBottomSheetV2(data: data, isVibrating: isVibrating),
    ).whenComplete(popLivestreamOverlayBlock);
  }
}

class _BetDetailsBottomSheetV2State
    extends ConsumerState<BetDetailsBottomSheetV2> {
  late File fileBorder;
  late File fileBackground;
  late RiveWidgetController controllerBorder;
  late RiveWidgetController controllerBackground;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      Future(() {
        if (!mounted) return;
        ref.read(bettingPopupV2Provider.notifier).initializeAsync();
      });
    }
    initRive();
  }

  void initRiveBorder() async {
    try {
      final file = await RiveHelper.getFile(AppRive.animCardBig);
      if (file == null || !mounted) return;
      fileBorder = file;
      controllerBorder = RiveWidgetController(fileBorder);
      if (mounted) {
        setState(() => isInitialized = true);
      }
    } catch (e) {
      debugPrint('Rive init error: $e');
    }
  }

  void initRiveBackground() async {
    try {
      final file = await RiveHelper.getFile(AppRive.animCardBigGlow);
      if (file == null || !mounted) return;
      fileBackground = file;
      controllerBackground = RiveWidgetController(fileBackground);
      if (mounted) {
        setState(() => isInitialized = true);
      }
    } catch (e) {
      debugPrint('Rive init error: $e');
    }
  }

  void initRive() {
    initRiveBorder();
    initRiveBackground();
  }

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    builder: (context, deviceType) {
      final isMobile = deviceType == DeviceType.mobile;
      final screenSize = MediaQuery.of(context).size;
      final maxHeight = screenSize.height * 0.9;
      final maxWidth = isMobile ? screenSize.width : 520.0;

      final content = Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(
              minWidth: isMobile ? 0 : 402,
              maxHeight: maxHeight,
              maxWidth: maxWidth,
            ),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundSecondary,
              borderRadius: isMobile
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    )
                  : BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 80,
                  offset: const Offset(0, -40),
                ),
              ],
            ),
            child: AnimatedPadding(
              padding: EdgeInsets.only(
                bottom: widget.isBottomSheet
                    ? ShellNavBottomSheetRoute.navClearance(context)
                    : 0,
              ),
              duration: const Duration(milliseconds: 100),
              curve: Curves.decelerate,
              child: ClipRRect(
                borderRadius: isMobile
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16),
                child: BetDetailsContent(
                  isMobile: isMobile,
                  isVibrating: widget.isVibrating,
                  isBottomSheet: widget.isBottomSheet,
                ),
              ),
            ),
          ),
          if (widget.isVibrating)
            Positioned.fill(child: IgnorePointer(child: _buildRiveborder())),
        ],
      );

      if (widget.isBottomSheet) {
        final mediaQuery = MediaQuery.of(context);
        return AnimatedPadding(
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          duration: const Duration(milliseconds: 100),
          curve: Curves.decelerate,
          child: MediaQuery(
            data: mediaQuery
                .removeViewInsets(removeBottom: true)
                .removePadding(removeBottom: true),
            child: content,
          ),
        );
      }

      return MediaQuery.removePadding(
        context: context,
        removeBottom: isMobile,
        child: Dialog(
          backgroundColor: Colors.transparent,
          alignment: Alignment.bottomCenter,
          insetPadding: isMobile
              ? EdgeInsets.zero
              : EdgeInsets.only(
                  bottom: 48,
                  left: (screenSize.width - maxWidth) / 2,
                  right: (screenSize.width - maxWidth) / 2,
                ),
          child: content,
        ),
      );
    },
  );

  Widget _buildRiveborder() {
    if (!isInitialized) {
      return const SizedBox.shrink();
    }
    return RiveWidget(controller: controllerBorder, fit: Fit.fill);
  }

  Widget _buildRivebackground() {
    if (!isInitialized) {
      return const SizedBox.shrink();
    }
    return RiveWidget(controller: controllerBackground, fit: Fit.cover);
  }
}
