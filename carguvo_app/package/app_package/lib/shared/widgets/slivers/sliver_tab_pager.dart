import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable, debugPrint;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

bool debugTabPagerLayout = false;

class SliverTabPager extends MultiChildRenderObjectWidget {
  const SliverTabPager({
    required this.offset,
    required this.neighbourOnRight,
    required super.children,
    super.key,
    this.onCrossAxisExtent,
  });

  final ValueListenable<double> offset;

  final bool neighbourOnRight;

  final ValueChanged<double>? onCrossAxisExtent;

  @override
  RenderSliverTabPager createRenderObject(BuildContext context) {
    return RenderSliverTabPager(
      offset: offset,
      neighbourOnRight: neighbourOnRight,
      onCrossAxisExtent: onCrossAxisExtent,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverTabPager renderObject,
  ) {
    renderObject
      ..offset = offset
      ..neighbourOnRight = neighbourOnRight
      ..onCrossAxisExtent = onCrossAxisExtent;
  }
}

class RenderSliverTabPager extends RenderSliver
    with
        ContainerRenderObjectMixin<RenderSliver,
            SliverPhysicalContainerParentData> {
  RenderSliverTabPager({
    required ValueListenable<double> offset,
    required bool neighbourOnRight,
    this.onCrossAxisExtent,
  }) : _offset = offset,
       _neighbourOnRight = neighbourOnRight;

  ValueChanged<double>? onCrossAxisExtent;

  late final VoidCallback _onOffsetChanged = markNeedsPaint;

  ValueListenable<double> _offset;
  ValueListenable<double> get offset => _offset;
  set offset(ValueListenable<double> value) {
    if (identical(_offset, value)) return;
    if (attached) _offset.removeListener(_onOffsetChanged);
    _offset = value;
    if (attached) _offset.addListener(_onOffsetChanged);
    markNeedsPaint();
  }

  bool _neighbourOnRight;
  bool get neighbourOnRight => _neighbourOnRight;
  set neighbourOnRight(bool value) {
    if (_neighbourOnRight == value) return;
    _neighbourOnRight = value;
    markNeedsPaint();
  }

  final LayerHandle<ClipRectLayer> _clipLayer = LayerHandle<ClipRectLayer>();

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalContainerParentData) {
      child.parentData = SliverPhysicalContainerParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _offset.addListener(_onOffsetChanged);
  }

  @override
  void detach() {
    _offset.removeListener(_onOffsetChanged);
    super.detach();
  }

  @override
  void dispose() {
    _clipLayer.layer = null;
    super.dispose();
  }

  RenderSliver? get _active => firstChild;
  RenderSliver? get _neighbour {
    final RenderSliver? a = firstChild;
    return a == null ? null : childAfter(a);
  }

  String? _lastDebugLine;

  void _debugLog(String line) {
    if (!debugTabPagerLayout || line == _lastDebugLine) return;
    _lastDebugLine = line;
    debugPrint('[tab-pager] $line');
  }

  @override
  void performLayout() {
    assert(
      constraints.axis == Axis.vertical,
      'SliverTabPager mới chỉ dùng cho scroll dọc (cross axis = ngang).',
    );

    onCrossAxisExtent?.call(constraints.crossAxisExtent);

    final RenderSliver? active = _active;
    if (active == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    active.layout(constraints, parentUsesSize: true);
    final SliverGeometry ag = active.geometry!;
    if (ag.scrollOffsetCorrection != null) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: ag.scrollOffsetCorrection,
      );
      return;
    }

    final RenderSliver? neighbour = _neighbour;
    if (neighbour == null) {
      geometry = ag;
      assert(() {
        _debugLog(
          'idle active.paint=${ag.paintExtent.round()} '
          'active.layout=${ag.layoutExtent.round()} '
          'active.scroll=${ag.scrollExtent.round()} '
          'origin=${ag.paintOrigin.round()} '
          'remainingPaint=${constraints.remainingPaintExtent.round()} '
          'scrollOffset=${constraints.scrollOffset.round()} '
          'overlap=${constraints.overlap.round()}',
        );
        return true;
      }());
      return;
    }

    double extra = 0;
    for (int i = 0; i < 3; i++) {
      neighbour.layout(
        constraints.copyWith(scrollOffset: constraints.scrollOffset + extra),
        parentUsesSize: true,
      );
      final double? correction = neighbour.geometry!.scrollOffsetCorrection;
      if (correction == null) break;
      extra += correction;
    }

    final SliverGeometry ng = neighbour.geometry!;
    final double paintExtent = math.max(ag.paintExtent, ng.paintExtent);

    final double scrollExtent = math.max(ag.scrollExtent, ng.scrollExtent);
    final double layoutExtent = math.min(
      math.max(ag.layoutExtent, ng.layoutExtent),
      paintExtent,
    );
    assert(() {
      _debugLog(
        'DRAG active.paint=${ag.paintExtent.round()} '
        'active.scroll=${ag.scrollExtent.round()} '
        'neighbour.paint=${ng.paintExtent.round()} '
        'neighbour.scroll=${ng.scrollExtent.round()} '
        'neighbour.maxPaint=${ng.maxPaintExtent.round()} '
        'active.layout=${ag.layoutExtent.round()} '
        'origin=${ag.paintOrigin.round()} '
        'remainingPaint=${constraints.remainingPaintExtent.round()} '
        'scrollOffset=${constraints.scrollOffset.round()} '
        'overlap=${constraints.overlap.round()} '
        '=> clip=${paintExtent.round()} layout=${layoutExtent.round()}',
      );
      return true;
    }());
    geometry = SliverGeometry(
      scrollExtent: scrollExtent,
      paintOrigin: ag.paintOrigin,
      paintExtent: paintExtent,
      layoutExtent: layoutExtent,
      maxPaintExtent: math.max(
        math.max(ag.maxPaintExtent, ng.maxPaintExtent),
        math.max(paintExtent, scrollExtent),
      ),
      maxScrollObstructionExtent: ag.maxScrollObstructionExtent,
      hitTestExtent: ag.hitTestExtent,
      visible: paintExtent > 0,
      hasVisualOverflow: true,
      cacheExtent: ag.cacheExtent,
    );
  }

  double _crossOffsetOf(RenderSliver child) {
    final double dx = _offset.value;
    if (identical(child, firstChild)) return dx;
    final double width = constraints.crossAxisExtent;
    return dx + (_neighbourOnRight ? width : -width);
  }

  @override
  double childMainAxisPosition(RenderSliver child) => 0;

  @override
  double childCrossAxisPosition(RenderSliver child) => _crossOffsetOf(child);

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    transform.multiply(
      Matrix4.translationValues(_crossOffsetOf(child as RenderSliver), 0, 0),
    );
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    if (_offset.value != 0) return false;
    final RenderSliver? active = _active;
    if (active == null || !active.geometry!.visible) return false;
    return active.hitTest(
      result,
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderSliver? active = _active;
    final SliverGeometry? g = geometry;
    if (active == null || g == null || g.paintExtent <= 0) return;

    final RenderSliver? neighbour = _neighbour;
    final double dx = _offset.value;

    if (neighbour == null && dx == 0) {
      if (active.geometry!.visible) context.paintChild(active, offset);
      return;
    }

    final double width = constraints.crossAxisExtent;
    _clipLayer.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & Size(width, g.paintExtent),
      (PaintingContext innerContext, Offset innerOffset) {
        if (active.geometry!.visible) {
          innerContext.paintChild(active, innerOffset + Offset(dx, 0));
        }
        if (neighbour != null && neighbour.geometry!.visible) {
          innerContext.paintChild(
            neighbour,
            innerOffset + Offset(dx + (_neighbourOnRight ? width : -width), 0),
          );
        }
      },
      oldLayer: _clipLayer.layer,
    );
  }
}
