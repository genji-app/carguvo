import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/features/mini_game/presentation/state/tai_xiu_state_provider.dart';

class TaiXiuHistoryDots extends StatelessWidget {
  final List<TaiXiuSessionHistoryLine> history;

  final double dotSize;

  final int maxDots;

  const TaiXiuHistoryDots({
    required this.history,
    this.dotSize = 14,
    this.maxDots = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: dotSize,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final line in history.take(maxDots).toList().reversed)
          TaiXiuHistoryDot(line: line, size: dotSize),
      ],
    ),
  );
}

class TaiXiuHistoryDot extends StatefulWidget {
  final TaiXiuSessionHistoryLine line;
  final double size;

  const TaiXiuHistoryDot({required this.line, this.size = 14, super.key});

  @override
  State<TaiXiuHistoryDot> createState() => _TaiXiuHistoryDotState();
}

class _TaiXiuHistoryDotState extends State<TaiXiuHistoryDot> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();

  static _TaiXiuHistoryDotState? _openDot;

  void _show() {
    if (!identical(_openDot, this)) {
      _openDot?._portal.hide();
    }
    _openDot = this;
    _portal.show();
  }

  void _hide() {
    if (identical(_openDot, this)) _openDot = null;
    _portal.hide();
  }

  void _toggle() => _portal.isShowing ? _hide() : _show();

  @override
  void dispose() {
    if (identical(_openDot, this)) _openDot = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
    link: _link,
    child: OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildOverlay,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _show(),
        onExit: (_) => _hide(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggle,
          child: ImageHelper.load(
            path: widget.line.isTai
                ? MiniGameIcons.txTaiCircle
                : MiniGameIcons.txXiuCircle,
            width: widget.size,
            height: widget.size,
          ),
        ),
      ),
    ),
  );

  Widget _buildOverlay(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: CompositedTransformFollower(
      link: _link,
      showWhenUnlinked: false,
      targetAnchor: Alignment.bottomCenter,
      followerAnchor: Alignment.topCenter,
      offset: const Offset(0, 6),
      child: IgnorePointer(child: _DotTooltip(line: widget.line)),
    ),
  );
}

class _DotTooltip extends StatelessWidget {
  final TaiXiuSessionHistoryLine line;

  const _DotTooltip({required this.line});

  @override
  Widget build(BuildContext context) {
    final label =
        '${line.isTai ? 'Tài' : 'Xỉu'}(${line.d1}-${line.d2}-${line.d3})';
    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: const BoxConstraints(minWidth: 72),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.yellow400, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '#${line.sessionId ?? '------'}',
              style: AppTextStyles.textStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: AppColors.yellow400,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.textStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
