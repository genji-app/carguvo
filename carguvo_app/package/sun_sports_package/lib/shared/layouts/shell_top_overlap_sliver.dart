import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/shared/layouts/shell_top_block.dart';

class ShellTopOverlapSliver extends ConsumerWidget {
  const ShellTopOverlapSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double extent = ShellTopMetrics.blockHeight(ref);
    final double chatHeight = ShellTopMetrics.hasChat(ref)
        ? ShellTopMetrics.chat(ref)
        : 0.0;
    final ScrollHideNotifier scrollHide = ref.watch(scrollHideProvider);

    return ShellTopOverlapReserve(
      extent: extent,
      chatHeight: chatHeight,
      progress: scrollHide.progress,
    );
  }
}

class ShellTopOverlapReserve extends LeafRenderObjectWidget {
  const ShellTopOverlapReserve({
    required this.extent,
    required this.chatHeight,
    required this.progress,
    super.key,
  });

  final double extent;
  final double chatHeight;
  final ValueListenable<double> progress;

  @override
  RenderShellTopOverlapReserve createRenderObject(BuildContext context) =>
      RenderShellTopOverlapReserve(
        extent: extent,
        chatHeight: chatHeight,
        progress: progress,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderShellTopOverlapReserve renderObject,
  ) {
    renderObject
      ..extent = extent
      ..chatHeight = chatHeight
      ..progress = progress;
  }
}

class RenderShellTopOverlapReserve extends RenderSliver {
  RenderShellTopOverlapReserve({
    required double extent,
    required double chatHeight,
    required ValueListenable<double> progress,
  }) : _extent = extent,
       _chatHeight = chatHeight,
       _progress = progress;

  double _extent;
  double get extent => _extent;
  set extent(double value) {
    if (_extent == value) return;
    _extent = value;
    markNeedsLayout();
  }

  double _chatHeight;
  double get chatHeight => _chatHeight;
  set chatHeight(double value) {
    if (_chatHeight == value) return;
    _chatHeight = value;
    markNeedsLayout();
  }

  ValueListenable<double> _progress;
  ValueListenable<double> get progress => _progress;
  set progress(ValueListenable<double> value) {
    if (identical(_progress, value)) return;
    if (attached) _progress.removeListener(markNeedsLayout);
    _progress = value;
    if (attached) _progress.addListener(markNeedsLayout);
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _progress.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _progress.removeListener(markNeedsLayout);
    super.detach();
  }

  double get pinBottom =>
      ScrollHideNotifier.headerHeight -
      _progress.value.clamp(0.0, 1.0) *
          ShellTopMetrics.blockSlide(_chatHeight > 0) +
      _chatHeight;

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    final double remaining = constraints.remainingPaintExtent;

    final double layoutExtent = clampDouble(
      _extent - constraints.scrollOffset,
      0.0,
      remaining,
    );
    final double paintExtent = clampDouble(
      math.max(layoutExtent, pinBottom),
      0.0,
      remaining,
    );

    geometry = SliverGeometry(
      scrollExtent: _extent,
      layoutExtent: layoutExtent,
      paintExtent: paintExtent,
      maxPaintExtent: math.max(_extent, pinBottom),
      hitTestExtent: 0.0,
      cacheExtent: calculateCacheOffset(constraints, from: 0.0, to: _extent),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('extent', _extent))
      ..add(DoubleProperty('chatHeight', _chatHeight))
      ..add(DoubleProperty('pinBottom', pinBottom));
  }
}
