import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';
import 'package:sun_sports/shared/widgets/bet_explanation/bet_explanation.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/tooltip/overlay_tooltip/smart_tooltip_controller.dart';

class ParlayExplanationButton extends StatefulWidget {
  static const double tapTargetSize = 44;

  static const double iconSize = 18;

  static const double anchorSize = 32;

  static const double _anchorHalo = (anchorSize - iconSize) / 2;
  static const double _centredInset = (tapTargetSize - iconSize) / 2;

  final HintData data;

  final Color? color;

  final EdgeInsetsDirectional iconPadding;

  final SmartTooltipController? controller;

  const ParlayExplanationButton({
    required this.data,
    super.key,
    this.color,
    this.iconPadding = const EdgeInsetsDirectional.all(_centredInset),
    this.controller,
  });

  @override
  State<ParlayExplanationButton> createState() =>
      _ParlayExplanationButtonState();
}

class _ParlayExplanationButtonState extends State<ParlayExplanationButton> {
  SmartTooltipController? _ownController;

  SmartTooltipController get _controller =>
      widget.controller ?? (_ownController ??= SmartTooltipController());

  @override
  void didUpdateWidget(covariant ParlayExplanationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && _ownController != null) {
      _ownController!.dispose();
      _ownController = null;
    }
  }

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconPadding = widget.iconPadding;
    const halo = ParlayExplanationButton._anchorHalo;
    assert(
      iconPadding.start >= halo &&
          iconPadding.top >= halo &&
          iconPadding.end >= halo &&
          iconPadding.bottom >= halo,
      'iconPadding must leave at least 7px on every side for the anchor',
    );
    final anchorPadding = EdgeInsetsDirectional.fromSTEB(
      iconPadding.start - halo,
      iconPadding.top - halo,
      iconPadding.end - halo,
      iconPadding.bottom - halo,
    );

    return SizedBox.square(
      dimension: ParlayExplanationButton.tapTargetSize,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          ParlayExplanationButton.tapTargetSize / 2,
        ),
        onTap: SoundTap.wrap(_controller.show),
        child: Padding(
          padding: anchorPadding,
          child: BetExplanationTooltip(
            hintData: widget.data,
            controller: _controller,
            config: BetTooltipConfig(
              triggerColor: widget.color,
              triggerSize: ParlayExplanationButton.iconSize,
              triggerPadding: EdgeInsets.zero,
              offset: const Offset(8, -4),
            ),
            triggerBuilder: (_) => SizedBox.square(
              dimension: ParlayExplanationButton.anchorSize,
              child: Center(
                child: SizedBox.square(
                  dimension: ParlayExplanationButton.iconSize,
                  child: ImageHelper.load(
                    path: AppIcons.iconInfo,
                    color: widget.color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
