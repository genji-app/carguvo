import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

import 'spotlight_controller.dart';
import 'spotlight_core.dart';

class SpotlightTheme {
  const SpotlightTheme({
    this.scrimColor = const Color(0x80000000),
    this.cardColor = const Color(0xFF150E08),
    this.cardBorderColor = const Color(0xFFFFE299),
    this.cardBorderWidth = 0.5,
    this.cardRadius = 18,
    this.cardMaxWidth = 320,
    this.highlightBorderColor = const Color(0xFFFFE299),
    this.highlightBorderWidth = 2.5,
    this.titleStyle = const TextStyle(
      color: Color(0xFFFEEE95),
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 24 / 16,
    ),
    this.bodyStyle = const TextStyle(
      color: Color(0xFFFFFEF5),
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
    ),
  });

  final Color scrimColor;
  final Color cardColor;
  final Color cardBorderColor;
  final double cardBorderWidth;
  final double cardRadius;
  final double cardMaxWidth;
  final Color highlightBorderColor;
  final double highlightBorderWidth;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
}

class _ViewData {
  const _ViewData({
    required this.step,
    required this.index,
    required this.length,
    required this.isFirst,
    required this.isLast,
    required this.showing,
    required this.rect,
  });

  final SpotlightStep step;
  final int index;
  final int length;
  final bool isFirst;
  final bool isLast;

  final bool showing;
  final Rect? rect;
}

class SpotlightHost extends ConsumerStatefulWidget {
  const SpotlightHost({
    required this.child,
    this.theme = const SpotlightTheme(),
    this.keepBelow,
    super.key,
  });

  final Widget child;
  final SpotlightTheme theme;

  final OverlayEntry? Function()? keepBelow;

  @override
  ConsumerState<SpotlightHost> createState() => _SpotlightHostState();
}

class _SpotlightHostState extends ConsumerState<SpotlightHost>
    with WidgetsBindingObserver {
  static const int _maxMeasureAttempts = 10;

  OverlayEntry? _entry;
  final ValueNotifier<_ViewData?> _data = ValueNotifier<_ViewData?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeEntry();
    _data.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final st = ref.read(spotlightControllerProvider);
    if (st.phase == SpotlightPhase.showing) _scheduleMeasure();
  }

  void _ensureEntry() {
    if (_entry != null) return;
    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (_) => _SpotlightView(
        data: _data,
        theme: widget.theme,
        onNext: () => ref.read(spotlightControllerProvider.notifier).next(),
        onPrev: () => ref.read(spotlightControllerProvider.notifier).prev(),
        onSkip: () => ref.read(spotlightControllerProvider.notifier).skip(),
      ),
    );
    final below = widget.keepBelow?.call();
    if (below != null && below.mounted) {
      try {
        overlay.insert(_entry!, below: below);
        return;
      } catch (_) {
      }
    }
    if (!_entry!.mounted) overlay.insert(_entry!);
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
    _data.value = null;
  }

  void _onStateChanged(SpotlightState st) {
    if (!st.isVisible || st.step == null) {
      _removeEntry();
      return;
    }
    _ensureEntry();
    _pushData(st, rect: null);
    if (st.phase == SpotlightPhase.showing) _scheduleMeasure();
  }

  void _scheduleMeasure({int attempt = 0}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final st = ref.read(spotlightControllerProvider);
      if (st.phase != SpotlightPhase.showing || st.step == null) return;
      final rect = SpotlightRegistry.instance.rectOf(st.step!.target);
      if (rect == null) {
        if (attempt < _maxMeasureAttempts) {
          _scheduleMeasure(attempt: attempt + 1);
        } else {
          debugPrint(
            '[Spotlight] Không đo được target ${st.step!.target} '
            '— thiếu SpotlightAnchor? Hiện tooltip fallback giữa màn.',
          );
          _pushData(st, rect: null, showingAnyway: true);
        }
        return;
      }
      _pushData(st, rect: rect, showingAnyway: true);
      _resettle(st.index);
    });
  }

  void _resettle(int index) {
    for (final ms in const [120, 300, 600, 1000]) {
      Future<void>.delayed(Duration(milliseconds: ms), () {
        if (!mounted) return;
        final st = ref.read(spotlightControllerProvider);
        if (st.phase != SpotlightPhase.showing || st.step == null) return;
        if (st.index != index) return;
        final rect = SpotlightRegistry.instance.rectOf(st.step!.target);
        if (rect != null) _pushData(st, rect: rect, showingAnyway: true);
      });
    }
  }

  void _pushData(SpotlightState st, {Rect? rect, bool showingAnyway = false}) {
    final step = st.step;
    if (step == null) return;
    _data.value = _ViewData(
      step: step,
      index: st.index,
      length: st.tour!.length,
      isFirst: st.isFirst,
      isLast: st.isLast,
      showing: showingAnyway || st.phase == SpotlightPhase.showing,
      rect: rect,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SpotlightState>(
      spotlightControllerProvider,
      (_, next) => _onStateChanged(next),
    );
    return widget.child;
  }
}

class _SpotlightView extends StatefulWidget {
  const _SpotlightView({
    required this.data,
    required this.theme,
    required this.onNext,
    required this.onPrev,
    required this.onSkip,
  });

  final ValueListenable<_ViewData?> data;
  final SpotlightTheme theme;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onSkip;

  @override
  State<_SpotlightView> createState() => _SpotlightViewState();
}

class _SpotlightViewState extends State<_SpotlightView>
    with TickerProviderStateMixin {
  late final AnimationController _scrimCtrl;
  late final AnimationController _fade;

  Rect? _rect;
  _ViewData? _card;
  _ViewData? _pending;
  Size _screen = const Size(1440, 1024);

  @override
  void initState() {
    super.initState();
    _scrimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener(_onFadeStatus);
    widget.data.addListener(_onData);
    _onData();
  }

  @override
  void dispose() {
    widget.data.removeListener(_onData);
    _scrimCtrl.dispose();
    _fade.dispose();
    super.dispose();
  }

  void _onData() {
    final d = widget.data.value;
    if (d == null) return;

    if (!d.showing) {
      _pending = null;
      if (_fade.value > 0) _fade.reverse();
      return;
    }

    if (_card?.index == d.index && _fade.value > 0) {
      setState(() {
        _card = d;
        _rect = d.rect;
      });
      return;
    }

    if (_fade.value == 0) {
      _pending = null;
      setState(() {
        _card = d;
        _rect = d.rect;
      });
      _fade.forward();
    } else {
      _pending = d;
      _fade.reverse();
    }
  }

  void _onFadeStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _pending != null) {
      final d = _pending!;
      _pending = null;
      setState(() {
        _card = d;
        _rect = d.rect;
      });
      _fade.forward();
    }
  }

  bool _hasHole(Rect? r) => r != null && r.width > 1 && r.height > 1;

  Rect? _visibleHole() {
    final r = _rect;
    if (r == null) return null;
    if (_fade.value <= 0.02) return null;
    return r;
  }

  @override
  Widget build(BuildContext context) {
    _screen = MediaQuery.sizeOf(context);
    final theme = widget.theme;

    return AnimatedBuilder(
      animation: Listenable.merge([_scrimCtrl, _fade]),
      builder: (context, _) {
        final holeForPaint = _visibleHole();
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: CustomPaint(
                  painter: _ScrimPainter(
                    rect: holeForPaint,
                    radius: _card?.step.highlightRadius ?? 12,
                    padding: _card?.step.highlightPadding ?? 8,
                    scrim: theme.scrimColor,
                    borderColor: theme.highlightBorderColor,
                    borderWidth: theme.highlightBorderWidth,
                    opacity: _scrimCtrl.value,
                  ),
                ),
              ),
            ),
            _buildCard(),
          ],
        );
      },
    );
  }

  Widget _fadedCard(_ViewData card, double cardW, _ArrowSide side) {
    return Opacity(
      opacity: _fade.value,
      child: _cardBox(card, cardW, side),
    );
  }

  Widget _buildCard() {
    final card = _card;
    final hole = _rect;
    if (card == null) return const SizedBox.shrink();

    const margin = 16.0;
    const gap = 10.0;
    final double cardW = widget.theme.cardMaxWidth
        .clamp(0.0, _screen.width - margin * 2)
        .toDouble();

    if (!_hasHole(hole)) {
      return Center(child: _fadedCard(card, cardW, _ArrowSide.none));
    }

    final p = card.step.placement;
    if (p == SpotlightPlacement.left || p == SpotlightPlacement.right) {
      final Rect r = hole!;
      final onLeft = p == SpotlightPlacement.left;
      const arrowW = 6.0;
      final double padding = card.step.highlightPadding;
      final double rawLeft = onLeft
          ? r.left - padding - gap - arrowW - cardW
          : r.right + padding + gap;
      final double left = rawLeft
          .clamp(margin, _screen.width - margin - cardW - arrowW)
          .toDouble();
      final double top = r.top
          .clamp(margin, _screen.height - margin - 120)
          .toDouble();
      final side = onLeft ? _ArrowSide.right : _ArrowSide.left;
      return Positioned(
        left: left,
        top: top,
        child: _fadedCard(card, cardW, side),
      );
    }

    final double cardH = _measuredCardHeight(card, cardW);
    final placeBelow = _resolvePlaceBelow(p, hole!, cardH);
    final double left = (hole.center.dx - cardW / 2)
        .clamp(margin, _screen.width - cardW - margin)
        .toDouble();
    _arrowAlong = (hole.center.dx - left).clamp(22.0, cardW - 22.0).toDouble();
    final side = placeBelow ? _ArrowSide.top : _ArrowSide.bottom;

    if (placeBelow) {
      return Positioned(
        left: left,
        top: hole.bottom + gap,
        child: _fadedCard(card, cardW, side),
      );
    }
    return Positioned(
      left: left,
      bottom: _screen.height - hole.top + gap,
      child: _fadedCard(card, cardW, side),
    );
  }

  double _arrowAlong = 0;

  double _measuredCardHeight(_ViewData data, double width) {
    const double chrome = 12 + 16 + 2 + 24 + 36 + 6;
    final double textW = width - 24;
    if (textW <= 0) return chrome;
    return chrome +
        _textHeight(data.step.title, widget.theme.titleStyle, textW) +
        _textHeight(data.step.body, widget.theme.bodyStyle, textW);
  }

  double _textHeight(String text, TextStyle style, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return tp.height;
  }

  bool _resolvePlaceBelow(SpotlightPlacement p, Rect hole, double cardH) {
    const margin = 16.0;
    const gap = 10.0;
    final bool wantBelow = switch (p) {
      SpotlightPlacement.top => false,
      SpotlightPlacement.bottom => true,
      _ => hole.center.dy < _screen.height / 2,
    };
    final bool fitsBelow = hole.bottom + gap + cardH <= _screen.height - margin;
    final bool fitsAbove = hole.top - gap - cardH >= margin;
    if (wantBelow) return fitsBelow || !fitsAbove;
    return !fitsAbove && fitsBelow;
  }

  Widget _cardBox(_ViewData data, double width, _ArrowSide side) {
    const double arrowShort = 6.0;
    const double arrowLong = 16.0;
    const double bleed = 1.0;
    final theme = widget.theme;

    final cardBody = Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        border: Border.all(
          color: theme.cardBorderColor,
          width: theme.cardBorderWidth,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.step.title, style: theme.titleStyle),
          const SizedBox(height: 2),
          Text(data.step.body, style: theme.bodyStyle),
          const SizedBox(height: 24),
          _footer(data),
        ],
      ),
    );

    _TrianglePainter painterFor(_ArrowSide s) => _TrianglePainter(
      theme.cardColor,
      s,
      borderColor: theme.cardBorderColor,
      borderWidth: theme.cardBorderWidth,
    );

    Widget hComposed(bool up) => Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: up ? arrowShort : 0,
            bottom: up ? 0 : arrowShort,
          ),
          child: cardBody,
        ),
        Positioned(
          left: (_arrowAlong - arrowLong / 2)
              .clamp(12.0, width - arrowLong - 12)
              .toDouble(),
          top: up ? 0 : null,
          bottom: up ? null : 0,
          child: CustomPaint(
            size: const Size(arrowLong, arrowShort + bleed),
            painter: painterFor(up ? _ArrowSide.top : _ArrowSide.bottom),
          ),
        ),
      ],
    );

    Widget vComposed(bool left) => Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: left ? arrowShort : 0,
            right: left ? 0 : arrowShort,
          ),
          child: cardBody,
        ),
        Positioned(
          left: left ? 0 : null,
          right: left ? null : 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: CustomPaint(
              size: const Size(arrowShort + bleed, arrowLong),
              painter: painterFor(left ? _ArrowSide.left : _ArrowSide.right),
            ),
          ),
        ),
      ],
    );

    final Widget composed = switch (side) {
      _ArrowSide.none => cardBody,
      _ArrowSide.top => hComposed(true),
      _ArrowSide.bottom => hComposed(false),
      _ArrowSide.left => vComposed(true),
      _ArrowSide.right => vComposed(false),
    };

    return Material(color: Colors.transparent, child: composed);
  }

  Widget _footer(_ViewData data) {
    Widget primary(String label) => _shineButton(
      onTap: widget.onNext,
      gradient: const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFFFFB600), Color(0xFFFFD670)],
        stops: [0, 0.722],
      ),
      child: Text(label, style: _btnDarkTextStyle),
    );

    if (data.length == 1) {
      return Row(children: [const Spacer(), primary('Đã hiểu')]);
    }
    return Row(
      children: [
        _shineButton(
          onTap: widget.onSkip,
          borderColor: const Color(0xFFFFE299),
          shine: false,
          child: const Text('Bỏ qua', style: _btnTextStyle),
        ),
        const SizedBox(width: 8),
        Text(
          '${data.index + 1}/${data.length}',
          style: const TextStyle(
            color: Color(0xFFFFFEF5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
          ),
        ),
        const Spacer(),
        if (!data.isFirst) ...[
          _shineButton(
            onTap: widget.onPrev,
            circle: true,
            child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
        ],
        primary(data.isLast ? 'Đã hiểu' : 'Tiếp tục'),
      ],
    );
  }

  Widget _shineButton({
    required Widget child,
    required VoidCallback onTap,
    Color? base,
    Gradient? gradient,
    Color? borderColor,
    bool circle = false,
    bool shine = true,
  }) {
    final radius = BorderRadius.circular(100);
    return GestureDetector(
      onTap: SoundTap.wrap(onTap),
      child: Container(
        height: 36,
        width: circle ? 36 : null,
        padding: circle ? null : const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: base,
          gradient: gradient,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : radius,
          border: borderColor == null ? null : Border.all(color: borderColor),
        ),
        foregroundDecoration: shine
            ? BoxDecoration(
                shape: circle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: circle ? null : radius,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x3DFFFFFF), Color(0x00FFFFFF)],
                  stops: [0, 0.55],
                ),
                border: Border.all(color: const Color(0x1FFFFFFF)),
              )
            : null,
        child: child,
      ),
    );
  }
}

const TextStyle _btnTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 14,
  fontWeight: FontWeight.w700,
  height: 20 / 14,
);

const TextStyle _btnDarkTextStyle = TextStyle(
  color: Color(0xFF070606),
  fontSize: 14,
  fontWeight: FontWeight.w700,
  height: 20 / 14,
);

enum _ArrowSide { none, top, bottom, left, right }

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(
    this.color,
    this.side, {
    this.borderColor,
    this.borderWidth = 0,
  });

  final Color color;
  final _ArrowSide side;

  final Color? borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (side == _ArrowSide.none) return;
    final w = size.width;
    final h = size.height;
    final List<Offset> pts = switch (side) {
      _ArrowSide.top => [Offset(0, h), Offset(w / 2, 0), Offset(w, h)],
      _ArrowSide.bottom => [Offset(0, 0), Offset(w / 2, h), Offset(w, 0)],
      _ArrowSide.left => [Offset(w, 0), Offset(0, h / 2), Offset(w, h)],
      _ArrowSide.right => [Offset(0, 0), Offset(w, h / 2), Offset(0, h)],
      _ArrowSide.none => const <Offset>[],
    };

    canvas.drawPath(
      Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..close(),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    final bc = borderColor;
    if (bc != null && borderWidth > 0) {
      canvas.drawPath(
        Path()
          ..moveTo(pts[0].dx, pts[0].dy)
          ..lineTo(pts[1].dx, pts[1].dy)
          ..lineTo(pts[2].dx, pts[2].dy),
        Paint()
          ..color = bc
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_TrianglePainter old) =>
      old.color != color ||
      old.side != side ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth;
}

class _ScrimPainter extends CustomPainter {
  const _ScrimPainter({
    required this.rect,
    required this.radius,
    required this.padding,
    required this.scrim,
    required this.borderColor,
    required this.borderWidth,
    required this.opacity,
  });

  final Rect? rect;
  final double radius;
  final double padding;
  final Color scrim;
  final Color borderColor;
  final double borderWidth;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final scrimPaint = Paint()
      ..color = scrim.withValues(alpha: scrim.a * opacity);
    final full = Offset.zero & size;

    if (rect == null) {
      canvas.drawRect(full, scrimPaint);
      return;
    }

    final double inset = borderWidth;
    final Rect raw = rect!.inflate(padding);
    final double maxX = (size.width - inset)
        .clamp(inset, double.infinity)
        .toDouble();
    final double maxY = (size.height - inset)
        .clamp(inset, double.infinity)
        .toDouble();
    final Rect clamped = Rect.fromLTRB(
      raw.left.clamp(inset, maxX).toDouble(),
      raw.top.clamp(inset, maxY).toDouble(),
      raw.right.clamp(inset, maxX).toDouble(),
      raw.bottom.clamp(inset, maxY).toDouble(),
    );

    final hole = RRect.fromRectAndRadius(clamped, Radius.circular(radius));

    canvas.saveLayer(full, Paint());
    canvas.drawRect(full, scrimPaint);
    canvas.drawRRect(hole, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    if (borderWidth > 0) {
      canvas.drawRRect(
        hole,
        Paint()
          ..color = borderColor.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );
    }
  }

  @override
  bool shouldRepaint(_ScrimPainter old) =>
      old.rect != rect ||
      old.opacity != opacity ||
      old.radius != radius ||
      old.padding != padding ||
      old.scrim != scrim ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth;
}
