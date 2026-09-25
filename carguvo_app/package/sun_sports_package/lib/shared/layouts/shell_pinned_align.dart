import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/providers/live_chat_expanded_provider.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/shared/layouts/shell_top_block.dart';

class ShellPinnedBlockAnchor extends StatelessWidget {
  const ShellPinnedBlockAnchor({required this.anchorKey, super.key});

  final GlobalKey anchorKey;

  @override
  Widget build(BuildContext context) =>
      SliverToBoxAdapter(child: SizedBox.shrink(key: anchorKey));
}

void alignUnderShellPinnedBlock({
  required ScrollController controller,
  required GlobalKey anchorKey,
  required ScrollHideNotifier scrollHide,
  required bool hasChat,
  required double chatHeight,
}) {
  if (controller.positions.length != 1) return;
  final ScrollPosition position = controller.position;
  if (!position.hasPixels || !position.hasContentDimensions) return;

  final RenderObject? anchor = anchorKey.currentContext?.findRenderObject();
  if (anchor is! RenderBox || !anchor.attached || !anchor.hasSize) return;
  final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(
    anchor,
  );
  if (viewport == null) return;
  final double natural = viewport.getOffsetToReveal(anchor, 0.0).offset;
  if (!natural.isFinite) return;

  double pin(double progress) => ShellTopMetrics.blockBottom(
    topPadding: 0,
    hasChat: hasChat,
    chatHeight: chatHeight,
    hideProgress: progress,
  );

  final double targetNow = natural - pin(scrollHide.progress.value);
  if (position.pixels <= targetNow + 0.5) return;

  final double targetShown = natural - pin(0.0);
  if (targetShown < ScrollHideNotifier.headerHeight + 2) {
    scrollHide.show();
    controller.jumpTo(math.max(position.minScrollExtent, targetShown));
    return;
  }
  scrollHide.pauseDetection();
  controller.jumpTo(math.max(position.minScrollExtent, targetNow));
}

void alignUnderShellPinnedBlockWithRef(
  WidgetRef ref, {
  required ScrollController controller,
  required GlobalKey anchorKey,
}) {
  alignUnderShellPinnedBlock(
    controller: controller,
    anchorKey: anchorKey,
    scrollHide: ref.read(scrollHideProvider),
    hasChat: ref.read(shellHasChatProvider),
    chatHeight:
        ref.read(isAuthenticatedProvider) && ref.read(liveChatExpandedProvider)
        ? ShellTopMetrics.chatExpanded
        : ShellTopMetrics.chatCollapsed,
  );
}
