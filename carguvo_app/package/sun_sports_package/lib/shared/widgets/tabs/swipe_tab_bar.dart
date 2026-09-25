library;

import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind, lerpDouble;

import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/game/category/game_category_button.dart';
import 'package:sun_sports/shared/widgets/gestures/tab_pager.dart';
import 'package:sun_sports/shared/widgets/scroll/scroll.dart';

@immutable
class SwipeTabItem {
  const SwipeTabItem({
    required this.label,
    this.iconBuilder,
    this.markerIconBuilder,
    this.key,
  });

  final String label;

  final Widget Function(bool isSelected)? iconBuilder;

  final Widget Function(bool isSelected)? markerIconBuilder;

  final Object? key;
}

class SwipeTabBar extends StatefulWidget {
  const SwipeTabBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.compact = false,
    this.tabBar = false,
    this.backgroundColor,
    this.indicatorColor,
    this.storageKey,
  });

  final List<SwipeTabItem> items;

  final int selectedIndex;

  final ValueChanged<int> onSelect;

  final EdgeInsetsGeometry padding;

  final bool compact;

  final bool tabBar;

  final Color? backgroundColor;

  final Color? indicatorColor;

  final PageStorageKey<String>? storageKey;

  @override
  State<SwipeTabBar> createState() => _SwipeTabBarState();
}

class _SwipeTabBarState extends State<SwipeTabBar> {
  final Map<int, GlobalKey> _itemKeys = <int, GlobalKey>{};

  final ScrollGestureAxisLock _wheelAxisLock = ScrollGestureAxisLock();

  final ScrollController _stripScroll = ScrollController();

  final GlobalKey _stripKey = GlobalKey();

  List<_TabSlot> _slots = const <_TabSlot>[];

  bool _revealedOnce = false;

  bool get _isTabBar => widget.compact && widget.tabBar;

  @override
  void didUpdateWidget(SwipeTabBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) _revealSelected();
    if (old.items.length != widget.items.length) _scheduleMeasure();
  }

  @override
  void dispose() {
    _stripScroll.dispose();
    super.dispose();
  }

  void _revealSelected() {
    final int index = widget.selectedIndex;
    if (index < 0 || index >= widget.items.length) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final RenderObject? object = _itemKeys[index]?.currentContext
          ?.findRenderObject();
      if (object == null || !_stripScroll.hasClients) return;

      _stripScroll.position.ensureVisible(
        object,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _measureSlots() {
    if (!mounted || !_stripScroll.hasClients) return;
    final RenderObject? stripObject = _stripKey.currentContext
        ?.findRenderObject();
    if (stripObject is! RenderBox || !stripObject.attached) return;

    final double scrolled = _stripScroll.offset;
    final List<_TabSlot> next = <_TabSlot>[];
    for (int i = 0; i < widget.items.length; i++) {
      final RenderObject? object = _itemKeys[i]?.currentContext
          ?.findRenderObject();
      if (object is! RenderBox || !object.attached) break;
      final double left =
          object.localToGlobal(Offset.zero, ancestor: stripObject).dx + scrolled;
      next.add(_TabSlot(left: left, width: object.size.width));
    }
    if (_slotsEqual(next, _slots)) return;
    setState(() => _slots = next);
  }

  static bool _slotsEqual(List<_TabSlot> a, List<_TabSlot> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureSlots());
  }

  double _rowHeight(BuildContext context) {
    if (widget.compact) return _compactRowHeight(context);

    const double kPaddingV = 8 * 2;
    const double kIcon = 24;
    const double kGap = 2;
    const double kFontSize = 12;
    const double kHeightFactor = 18 / 12;

    final double lineHeight =
        MediaQuery.textScalerOf(context).scale(kFontSize) * kHeightFactor;
    final double needed = kPaddingV + kIcon + kGap + lineHeight;
    const double floor = 62;
    return needed > floor ? needed.ceilToDouble() : floor;
  }

  double _compactRowHeight(BuildContext context) {
    final double kPaddingV =
        (_isTabBar
                ? GameCategoryButton.tabBarPadding
                : GameCategoryButton.compactPadding)
            .vertical;
    const double kIcon = GameCategoryButton.compactIconSize;
    const double kFontSize = 14;
    const double kHeightFactor = 20 / 14;

    final double lineHeight =
        MediaQuery.textScalerOf(context).scale(kFontSize) * kHeightFactor;
    final double needed = kPaddingV + math.max(kIcon, lineHeight);
    final double floor =
        (_isTabBar
                ? GameCategoryButton.tabBarConstraints
                : GameCategoryButton.compactConstraints)
            .minHeight;
    return needed > floor ? needed.ceilToDouble() : floor;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox(height: _rowHeight(context));
    }

    if (!_revealedOnce) {
      _revealedOnce = true;
      _revealSelected();
    }
    if (_isTabBar) _scheduleMeasure();

    return SizedBox(
      height: _rowHeight(context),
      child: _isTabBar ? _withIndicator(context) : _buildStrip(context),
    );
  }

  Widget _buildStrip(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: ListView.separated(
        controller: _stripScroll,
        cacheExtent: 3000.0,
        key: widget.storageKey,
        padding: widget.padding,
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final GlobalKey key = _itemKeys.putIfAbsent(index, () => GlobalKey());
          final SwipeTabItem item = widget.items[index];
          final bool isSelected = index == widget.selectedIndex;

          final Widget button = GameCategoryButton(
            label: item.label,
            isSelected: isSelected,
            compact: widget.compact,
            tabBar: _isTabBar,
            backgroundColor: widget.backgroundColor,
            onPressed: () => widget.onSelect(index),
            iconBuilder: item.iconBuilder,
            markerIconBuilder: item.markerIconBuilder,
          );

          return VerticalWheelForwarder(
            axisLock: _wheelAxisLock,
            child: Align(key: key, alignment: Alignment.center, child: button),
          );
        },
      ),
    );
  }

  Widget _withIndicator(BuildContext context) {
    final TabPagerController? pager = TabPagerScope.maybeOf(context);
    final int selected = widget.selectedIndex;

    return Stack(
      key: _stripKey,
      fit: StackFit.passthrough,
      children: <Widget>[
        _buildStrip(context),
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _TabIndicatorPainter(
                  slots: _slots,
                  repaint: Listenable.merge(<Listenable?>[
                    _stripScroll,
                    if (pager != null) ...<Listenable>[pager.offset, pager],
                  ]),
                  position: () => pager?.position ?? selected.toDouble(),
                  scrolled: () =>
                      _stripScroll.hasClients ? _stripScroll.offset : 0.0,
                  color: widget.indicatorColor ?? AppColors.yellow300,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

@immutable
class _TabSlot {
  const _TabSlot({required this.left, required this.width});

  final double left;
  final double width;

  double get center => left + width / 2;

  @override
  bool operator ==(Object other) =>
      other is _TabSlot && other.left == left && other.width == width;

  @override
  int get hashCode => Object.hash(left, width);
}

class _TabIndicatorPainter extends CustomPainter {
  _TabIndicatorPainter({
    required this.slots,
    required this.position,
    required this.scrolled,
    required this.color,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final List<_TabSlot> slots;
  final double Function() position;
  final double Function() scrolled;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (slots.isEmpty) return;

    final double p = position()
        .clamp(0.0, (slots.length - 1).toDouble())
        .toDouble();
    final int i = p.floor();
    final int j = math.min(i + 1, slots.length - 1);
    final double t = p - i;
    final double center = lerpDouble(slots[i].center, slots[j].center, t)!;
    final double maxWidth = lerpDouble(slots[i].width, slots[j].width, t)!;

    final double width = math.min(GameCategoryButton.indicatorWidth, maxWidth);
    const double thickness = GameCategoryButton.indicatorThickness;
    final double left = center - scrolled() - width / 2;
    final double top =
        size.height - GameCategoryButton.indicatorBottom - thickness;
    final Rect rect = Rect.fromLTWH(left, top, width, thickness);

    if (rect.right < 0 || rect.left > size.width) return;

    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: <Color>[
          color.withValues(alpha: 0.0),
          color,
          color.withValues(alpha: 0.0),
        ],
        stops: const <double>[0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(999)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TabIndicatorPainter old) =>
      old.slots != slots || old.color != color;
}
