import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class GlowFilterTabbar<T> extends StatefulWidget {
  final List<T> tabs;

  final TabController? controller;

  final T? selectedTab;

  final void Function(T newTab, T currentTab)? onTabChanged;

  final String Function(T tab)? labelGetter;

  final Color? selectedColor;

  final Color? unselectedColor;

  final Color? borderColor;

  final EdgeInsets? tabPadding;

  final TextStyle? selectedTextStyle;

  final TextStyle? unselectedTextStyle;

  final Widget Function(T tab, bool isSelected)? indicatorBuilder;

  final Decoration? decoration;

  final Widget Function(T tab, bool isSelected)? iconBuilder;

  final Widget Function(T tab, bool isSelected)? badgeBuilder;

  final Key? Function(T tab)? itemKeyGetter;

  final Widget Function(T tab, Widget child)? itemWrapper;

  const GlowFilterTabbar({
    required this.tabs,
    this.controller,
    this.selectedTab,
    this.onTabChanged,
    super.key,
    this.labelGetter,
    this.selectedColor,
    this.unselectedColor,
    this.borderColor,
    this.tabPadding,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.indicatorBuilder,
    this.decoration,
    this.iconBuilder,
    this.badgeBuilder,
    this.itemKeyGetter,
    this.itemWrapper,
  });

  @override
  State<GlowFilterTabbar<T>> createState() => _GlowFilterTabbarState<T>();
}

class _GlowFilterTabbarState<T> extends State<GlowFilterTabbar<T>> {
  TabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateController();
  }

  @override
  void didUpdateWidget(GlowFilterTabbar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateController();
    }
  }

  void _updateController() {
    final TabController? newController =
        widget.controller ?? DefaultTabController.maybeOf(context);
    if (newController != _controller) {
      _controller?.removeListener(_handleTabControllerTick);
      _controller = newController;
      _controller?.addListener(_handleTabControllerTick);
    }
  }

  void _handleTabControllerTick() {
    if (mounted) {
      setState(() {
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleTabControllerTick);
    super.dispose();
  }

  int get _currentIndex {
    if (_controller != null) return _controller!.index;
    if (widget.selectedTab != null) {
      final index = widget.tabs.indexOf(widget.selectedTab as T);
      return index >= 0 ? index : 0;
    }
    return 0;
  }

  void _onTabTap(int index) {
    final currentTab = widget.tabs[_currentIndex];
    final newTab = widget.tabs[index];

    if (_controller != null) {
      _controller!.animateTo(index);
    }

    widget.onTabChanged?.call(newTab, currentTab);

    if (_controller == null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          widget.decoration ??
          BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.borderColor ?? const Color(0xFF252423),
                width: 0.5,
              ),
            ),
          ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(widget.tabs.length, (index) {
            final tab = widget.tabs[index];
            final isSelected = _currentIndex == index;
            final label = widget.labelGetter?.call(tab) ?? tab.toString();

            final Widget item = _GlowTabItem<T>(
              key: widget.itemKeyGetter?.call(tab),
              tab: tab,
              label: label,
              isSelected: isSelected,
              onTap: () => _onTabTap(index),
              tabPadding: widget.tabPadding,
              selectedTextStyle: widget.selectedTextStyle,
              unselectedTextStyle: widget.unselectedTextStyle,
              selectedColor: widget.selectedColor,
              unselectedColor: widget.unselectedColor,
              indicatorBuilder: widget.indicatorBuilder,
              iconBuilder: widget.iconBuilder,
              badgeBuilder: widget.badgeBuilder,
            );
            return widget.itemWrapper?.call(tab, item) ?? item;
          }),
        ),
      ),
    );
  }
}

class _GlowTabItem<T> extends StatelessWidget {
  final T tab;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsets? tabPadding;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Widget Function(T tab, bool isSelected)? indicatorBuilder;
  final Widget Function(T tab, bool isSelected)? iconBuilder;
  final Widget Function(T tab, bool isSelected)? badgeBuilder;

  const _GlowTabItem({
    required this.tab,
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.tabPadding,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorBuilder,
    this.iconBuilder,
    this.badgeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final activeStyle =
        selectedTextStyle ??
        AppTextStyles.labelSmall(color: selectedColor ?? AppColors.yellow300);

    final inactiveStyle =
        unselectedTextStyle ??
        AppTextStyles.labelSmall(
          color: unselectedColor ?? AppColorStyles.contentSecondary,
        );

    return GestureDetector(
      onTap: SoundTap.wrap(onTap),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            bottom: isSelected ? 0 : -4,
            left: -20,
            right: -20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              opacity: isSelected ? 1.0 : 0.0,
              child:
                  indicatorBuilder?.call(tab, isSelected) ??
                  ImageHelper.load(
                    path: AppIcons.sportStatusSelected,
                    fit: BoxFit.fill,
                  ),
            ),
          ),
          Container(
            padding:
                tabPadding ??
                const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    style: isSelected ? activeStyle : inactiveStyle,
                    child: Text(label),
                  ),
                  if (iconBuilder != null) ...[
                    const SizedBox(width: 6),
                    iconBuilder!(tab, isSelected),
                  ],
                  if (badgeBuilder != null) ...[
                    const SizedBox(width: 6),
                    badgeBuilder!(tab, isSelected),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
