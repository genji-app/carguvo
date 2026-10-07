import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';

import '../../common/domain/volta_bet_rules.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_feedback.dart';
import '../../common/volta_layout_spec.dart';
import '../../common/volta_icons.dart';

class VoltaActionRow extends ConsumerWidget {
  const VoltaActionRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRebet = ref.watch(voltaStateProvider.select((s) => s.canRebet));
    final canDouble = ref.watch(voltaStateProvider.select((s) => s.canDouble));
    final notifier = ref.read(voltaStateProvider.notifier);
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);

    return Container(
      height: spec.actionRowHeight,
      decoration: _rowDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          VoltaActionButton(
            style: VoltaActionButtonStyle.rebet,
            size: Size(spec.actionButtonWidth, spec.actionButtonHeight),
            enabled: canRebet,
            onTap: () => runBetAction(context, ref, notifier.rebet),
            child: VoltaIcons.redo(size: 28),
          ),
          SizedBox(width: spec.actionGap),
          VoltaActionButton(
            style: VoltaActionButtonStyle.doubleUp,
            size: Size(spec.actionButtonWidth, spec.actionButtonHeight),
            enabled: canDouble,
            onTap: () => runBetAction(context, ref, notifier.doubleStake),
            child: Text(
              'X2',
              style: AppTextStyles.labelLarge(
                color: VoltaColors.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void runBetAction(
    BuildContext context,
    WidgetRef ref,
    Future<VoltaBetOutcome> Function() action,
  ) {
    VoltaFeedback.click();
    if (!VoltaFeedback.requireSignedIn(context, ref)) return;
    unawaited(
      VoltaBetLoading.run(context, action).then((VoltaBetOutcome outcome) {
        if (!context.mounted) return;
        VoltaBetFeedback.show(context, outcome);
      }),
    );
  }

  static const BoxDecoration _rowDecoration = BoxDecoration(
    color: VoltaColors.surface,
    border: Border(top: BorderSide(color: VoltaColors.hairline)),
  );
}

@immutable
class VoltaActionButtonStyle {
  const VoltaActionButtonStyle._({required this.base, required this.glow});

  factory VoltaActionButtonStyle._of(
    List<int> base,
    int core,
    List<double> alpha,
  ) => VoltaActionButtonStyle._(
    base: <Color>[for (final int v in base) Color(0xFF000000 | v)],
    glow: <Color>[
      for (final double a in alpha)
        Color(((a * 255).round().clamp(0, 255) << 24) | core),
    ],
  );

  final List<Color> base;

  final List<Color> glow;

  static final VoltaActionButtonStyle rebet = VoltaActionButtonStyle._of(
    kVoltaActionBaseRebet,
    kVoltaActionGlowCoreRebet,
    kVoltaActionGlowAlphaRebet,
  );

  static final VoltaActionButtonStyle doubleUp = VoltaActionButtonStyle._of(
    kVoltaActionBaseDouble,
    kVoltaActionGlowCoreDouble,
    kVoltaActionGlowAlphaDouble,
  );
}

@immutable
class VoltaActionShape extends OutlinedBorder {
  const VoltaActionShape({required this.outerLeft});

  final bool outerLeft;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  Path _build(Rect rect) {
    final List<List<double>> pts = voltaActionOutline(
      rect.width,
      rect.height,
      outerLeft: outerLeft,
    );
    final double r = kVoltaActionCornerRatio * rect.height;
    final Path path = Path();
    Offset at(int i) =>
        rect.topLeft + Offset(pts[i][0], pts[i][1]);
    for (int i = 0; i < pts.length; i++) {
      final Offset cur = at(i);
      final Offset a = _towards(cur, at((i - 1 + pts.length) % pts.length), r);
      final Offset b = _towards(cur, at((i + 1) % pts.length), r);
      if (i == 0) {
        path.moveTo(a.dx, a.dy);
      } else {
        path.lineTo(a.dx, a.dy);
      }
      path.arcToPoint(b, radius: Radius.circular(r));
    }
    path.close();
    return path;
  }

  static Offset _towards(Offset from, Offset to, double d) {
    final Offset v = to - from;
    final double len = v.distance;
    if (len <= 0) return from;
    return from + v * (math.min(d, len / 2) / len);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => _build(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _build(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  VoltaActionShape copyWith({BorderSide? side}) => this;

  @override
  bool operator ==(Object other) =>
      other is VoltaActionShape && other.outerLeft == outerLeft;

  @override
  int get hashCode => outerLeft.hashCode;
}

@immutable
class VoltaActionGlowTransform extends GradientTransform {
  const VoltaActionGlowTransform({required this.outerLeft});

  final bool outerLeft;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double shortest = bounds.shortestSide;
    if (shortest <= 0) return null;
    final double sx =
        kVoltaActionGlowRX * bounds.width / (kVoltaActionGlowRY * shortest);
    final double sy = bounds.height / shortest;
    final double cx =
        bounds.left +
        (outerLeft ? kVoltaActionGlowX : 1 - kVoltaActionGlowX) * bounds.width;
    final double cy = bounds.top;
    return Matrix4.identity()
      ..translateByDouble(cx, cy, 0, 1)
      ..scaleByDouble(sx, sy, 1.0, 1.0)
      ..translateByDouble(-cx, -cy, 0, 1);
  }
}

class VoltaActionButton extends StatelessWidget {
  const VoltaActionButton({
    required this.style,
    required this.size,
    required this.enabled,
    required this.onTap,
    required this.child,
    this.outerLeft,
    this.frame,
  });

  final VoltaActionButtonStyle style;
  final Size size;

  final String? frame;

  final bool? outerLeft;

  final bool enabled;
  final VoidCallback onTap;
  final Widget child;

  static const List<BoxShadow> _shadows = <BoxShadow>[
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 1.35),
      blurRadius: 0.675,
    ),
    BoxShadow(color: Color(0x80000000), offset: Offset(0, 4), blurRadius: 4),
  ];

  @override
  Widget build(BuildContext context) {
    final bool outer = outerLeft ?? true;
    final ShapeBorder shape = outerLeft == null
        ? const StadiumBorder()
        : VoltaActionShape(outerLeft: outer);
    final bool useArt = kVoltaActionUseArtwork && frame != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: DecoratedBox(
            decoration: ShapeDecoration(shape: shape, shadows: _shadows),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                if (useArt)
                  Positioned.fill(
                    child: ImageHelper.load(
                      path: frame!,
                      fit: BoxFit.fill,
                      errorWidget: ClipPath(
                        clipper: ShapeBorderClipper(shape: shape),
                        child: _painted(outer),
                      ),
                    ),
                  )
                else
                  Positioned.fill(
                    child: ClipPath(
                      clipper: ShapeBorderClipper(shape: shape),
                      child: _painted(outer),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(
                    kVoltaActionLabelShift * size.width * (outer ? 1 : -1),
                    0,
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _painted(bool outer) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: style.base,
        stops: kVoltaActionBaseStops,
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                2 * (outer ? kVoltaActionGlowX : 1 - kVoltaActionGlowX) - 1,
                -1,
              ),
              radius: kVoltaActionGlowRY,
              colors: style.glow,
              stops: kVoltaActionGlowStops,
              transform: VoltaActionGlowTransform(outerLeft: outer),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 1,
          child: ColoredBox(
            color: Colors.white.withValues(alpha: kVoltaActionBottomRim),
          ),
        ),
      ],
    ),
  );
}
