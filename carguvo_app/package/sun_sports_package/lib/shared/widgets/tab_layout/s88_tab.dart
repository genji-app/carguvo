import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/core/services/models/sport_enums.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/border_radius_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

final List<S88TabItem> sportTabItems = [
  S88TabItem(text: 'Bóng đá', iconPath: AppIcons.iconSoccer),
  S88TabItem(text: 'Cầu lông', iconPath: AppIcons.iconBadminton),
  S88TabItem(text: 'Bóng rổ', iconPath: AppIcons.iconBasketball),
  S88TabItem(text: 'Bóng chuyền', iconPath: AppIcons.iconVolleyball),
  S88TabItem(text: 'Quần vợt', iconPath: AppIcons.iconTennis),
];

final List<int> sportIds = [
  SportType.soccer.id,
  SportType.badminton.id,
  SportType.basketball.id,
  SportType.volleyball.id,
  SportType.tennis.id,
];

const double kS88TabGlowHeight = 55.252;

const double kS88TabGlowSpread = 46.32;

const double _kGlowRx = 78.59;
const double _kGlowRy = 55.064;

const double _kGlowCenterX = 0.4968;

@immutable
class _GlowEllipse extends GradientTransform {
  const _GlowEllipse();

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double base = bounds.shortestSide;
    if (base <= 0) return null;
    final double cx = bounds.left + bounds.width * _kGlowCenterX;
    final double cy = bounds.bottom;
    return Matrix4.identity()
      ..translateByDouble(cx, cy, 0, 1)
      ..scaleByDouble(_kGlowRx / base, _kGlowRy / base, 1, 1)
      ..translateByDouble(-cx, -cy, 0, 1);
  }
}

class _S88TabGlow extends StatelessWidget {
  const _S88TabGlow();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(_kGlowCenterX * 2 - 1, 1),
            radius: 1,
            transform: _GlowEllipse(),
            colors: [
              Color(0x1FF6DC6F),
              Color(0x17C0A953),
              Color(0x0F897738),
              Color(0x0853441C),
              Color(0x001C1200),
            ],
            stops: [0, 0.25, 0.5, 0.75, 1],
          ),
        ),
      ),
    );
  }
}

class S88TabItem {
  final String text;
  final String? iconPath;

  const S88TabItem({required this.text, this.iconPath});
}

class S88Tab extends StatelessWidget {
  final List<S88TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  final double? width;

  final double height;

  final bool isScrollable;

  final double scrollableTabWidth;

  final Color defaultColor;

  final Color selectedColor;

  final BorderRadius borderRadius;

  final Color backgroundColor;

  final double selectedIndicatorSpread;

  final EdgeInsets tabPadding;

  final double fontSize;

  final FontWeight fontWeight;

  const S88Tab({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.width,
    this.height = 40,
    this.isScrollable = false,
    this.scrollableTabWidth = 88,
    Color? defaultColor,
    Color? selectedColor,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    this.selectedIndicatorSpread = 0,
    EdgeInsets? tabPadding,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
  }) : defaultColor = defaultColor ?? AppColors.gray300,
       selectedColor = selectedColor ?? AppColors.yellow300,
       borderRadius =
           borderRadius ??
           const BorderRadius.only(
             topLeft: Radius.circular(AppBorderRadiusStyles.radius300),
             topRight: Radius.circular(AppBorderRadiusStyles.radius300),
           ),
       backgroundColor = backgroundColor ?? AppColorStyles.backgroundTertiary,
       tabPadding = tabPadding ?? const EdgeInsets.all(0);

  @override
  Widget build(BuildContext context) {
    final rowChildren = List.generate(tabs.length, (index) {
      final item = tabs[index];
      final isSelected = selectedIndex == index;
      final tile = _S88TabTile(
        text: item.text,
        iconPath: item.iconPath,
        isSelected: isSelected,
        defaultColor: defaultColor,
        selectedColor: selectedColor,
        tabPadding: tabPadding,
        fontSize: fontSize,
        fontWeight: fontWeight,
        indicatorSpread: selectedIndicatorSpread,
        onTap: () => onTabChanged(index),
      );
      if (isScrollable) {
        return SizedBox(width: scrollableTabWidth, child: tile);
      }
      return Expanded(child: tile);
    });

    final rowOrScroll = isScrollable
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(mainAxisSize: MainAxisSize.min, children: rowChildren),
          )
        : Row(children: rowChildren);

    final content = ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: backgroundColor,
              ),
            ),
          ),
          rowOrScroll,
        ],
      ),
    );

    if (width != null) {
      return SizedBox(width: width, height: height, child: content);
    }
    return SizedBox(height: height, child: content);
  }
}

class _S88TabTile extends StatelessWidget {
  final String text;
  final String? iconPath;
  final bool isSelected;
  final Color defaultColor;
  final Color selectedColor;
  final EdgeInsets tabPadding;
  final double fontSize;
  final FontWeight fontWeight;
  final double indicatorSpread;
  final VoidCallback onTap;

  const _S88TabTile({
    required this.text,
    this.iconPath,
    required this.isSelected,
    required this.defaultColor,
    required this.selectedColor,
    required this.tabPadding,
    required this.fontSize,
    required this.fontWeight,
    required this.indicatorSpread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : defaultColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(onTap),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (isSelected)
              Positioned(
                bottom: 0,
                left: -indicatorSpread,
                right: -indicatorSpread,
                height: kS88TabGlowHeight,
                child: const _S88TabGlow(),
              ),
            Center(
              child: Padding(
                padding: tabPadding,
                child: Stack(
                  children: [
                    Container(
                      height: 26,
                      padding: const EdgeInsets.only(top: 2, bottom: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (iconPath != null) ...[
                            RepaintBoundary(
                              child: ImageHelper.load(
                                path: iconPath!,
                                width: 16,
                                height: 16,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            text,
                            style: AppTextStyles.paragraphXSmall(color: color),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                selectedColor.withValues(alpha: 0),
                                selectedColor.withValues(alpha: 0.241),
                                selectedColor.withValues(alpha: 0.486),
                                selectedColor.withValues(alpha: 0.724),
                                selectedColor.withValues(alpha: 0.883),
                                selectedColor.withValues(alpha: 0.724),
                                selectedColor.withValues(alpha: 0.486),
                                selectedColor.withValues(alpha: 0.241),
                                selectedColor.withValues(alpha: 0),
                              ],
                              stops: const [
                                0, 0.125, 0.25, 0.375, 0.5,
                                0.625, 0.75, 0.875, 1,
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
