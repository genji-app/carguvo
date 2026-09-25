import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/bet_details/bet_details_content.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/bet_details/providers/betting_popup_provider.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';

class BetDetailsBottomSheet extends ConsumerStatefulWidget {
  final BettingPopupData? data;

  final bool isVibrating;

  const BetDetailsBottomSheet({super.key, this.data, this.isVibrating = false});

  @override
  ConsumerState<BetDetailsBottomSheet> createState() =>
      _BetDetailsBottomSheetState();

  static Future<void> show(
    BuildContext context, {
    BettingPopupData? data,
    bool isVibrating = false,
  }) {
    if (data != null) {
      ProviderScope.containerOf(context, listen: false)
          .read(bettingPopupProvider.notifier)
          .resetForNewPopup(data);
    }
    pushLivestreamOverlayBlock();
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) =>
          BetDetailsBottomSheet(data: data, isVibrating: isVibrating),
    ).whenComplete(popLivestreamOverlayBlock);
  }
}

class _BetDetailsBottomSheetState extends ConsumerState<BetDetailsBottomSheet> {
  RiveWidgetController? _borderController;
  bool _isBorderInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      Future(() {
        if (!mounted) return;
        ref.read(bettingPopupProvider.notifier).initializeAsync();
      });
    }
    if (widget.isVibrating) {
      _initRiveBorder();
    }
  }

  Future<void> _initRiveBorder() async {
    try {
      final file = await RiveHelper.getFile(AppRive.animCardBig);
      if (file == null || !mounted) return;
      _borderController = RiveWidgetController(file);
      if (mounted) {
        setState(() => _isBorderInitialized = true);
      }
    } catch (e) {
      debugPrint('Rive init error: $e');
    }
  }

  @override
  void dispose() {
    _borderController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    builder: (context, deviceType) {
      final isMobile = deviceType == DeviceType.mobile;
      final screenSize = MediaQuery.of(context).size;
      final maxHeight = screenSize.height * 0.9;
      final maxWidth = isMobile ? screenSize.width : 520.0;

      Widget content = InnerShadowCard(
        child: Container(
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
            ),
          ),
        ),
      );

      if (widget.isVibrating) {
        content = Stack(
          clipBehavior: Clip.none,
          children: [
            content,
            if (_isBorderInitialized && _borderController != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: RiveWidget(
                    controller: _borderController!,
                    fit: Fit.fill,
                  ),
                ),
              ),
          ],
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
}
