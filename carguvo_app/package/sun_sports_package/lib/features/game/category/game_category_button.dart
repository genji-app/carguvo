import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class GameCategoryButton extends StatelessWidget {
  const GameCategoryButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    super.key,
    this.iconBuilder,
    this.markerIconBuilder,
    this.compact = false,
    this.tabBar = false,
    this.backgroundColor,
  });

  final String label;
  final bool isSelected;

  final VoidCallback onPressed;
  final Widget Function(bool isSelected)? iconBuilder;

  final Widget Function(bool isSelected)? markerIconBuilder;

  final bool compact;

  static const constraints = BoxConstraints(minHeight: 62, minWidth: 80);

  static const compactConstraints = BoxConstraints(minHeight: 32, minWidth: 56);

  static const compactPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 6,
  );

  static const double compactIconSize = 20;

  final Color? backgroundColor;

  final bool tabBar;

  static const double indicatorThickness = 2;

  static const double indicatorBottom = 4;

  static const double indicatorTopGap = 3;

  static const EdgeInsets tabBarPadding = EdgeInsets.fromLTRB(
    14,
    6,
    14,
    6 + indicatorTopGap,
  );

  static const BoxConstraints tabBarConstraints = BoxConstraints(
    minHeight: 32 + indicatorTopGap,
    minWidth: 56,
  );

  static const double indicatorWidth = 40;

  static const Duration _fade = Duration(milliseconds: 250);

  Color get _labelColor =>
      isSelected ? AppColors.yellow300 : AppColorStyles.contentSecondary;

  Widget _selectedBackground() => Positioned.fill(
    child: AnimatedOpacity(
      duration: _fade,
      curve: Curves.easeOut,
      opacity: isSelected ? 1.0 : 0.0,
      child: ImageHelper.load(
        path: AppImages.imgGameBgSelected,
        cacheWidth: 160,
        cacheHeight: 124,
        fit: BoxFit.cover,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact(context);

    final borderRadius = BorderRadius.circular(14);

    return ConstrainedBox(
      constraints: constraints,
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        color: backgroundColor ?? AppColorStyles.backgroundTertiary,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: SoundTap.wrap(onPressed),
          borderRadius: borderRadius,
          mouseCursor: SystemMouseCursors.click,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _selectedBackground(),

              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    if (iconBuilder != null) ...[
                      SizedBox.square(
                        dimension: 24,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: iconBuilder!(isSelected),
                        ),
                      ),
                    ],

                    Flexible(
                      child: AnimatedDefaultTextStyle(
                        duration: _fade,
                        curve: Curves.easeOut,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.paragraphXSmall(color: _labelColor),
                        child: Text(label),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, ShapeBorder shape, BorderRadius ink) {
    return ConstrainedBox(
      constraints: tabBarConstraints,
      child: Material(
        type: MaterialType.transparency,
        shape: shape,
        child: InkWell(
          onTap: SoundTap.wrap(onPressed),
          borderRadius: ink,
          mouseCursor: SystemMouseCursors.click,
          child: Padding(
            padding: tabBarPadding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6,
              children: [
                if (markerIconBuilder != null)
                  SizedBox.square(
                    dimension: compactIconSize,
                    child: Center(child: markerIconBuilder!(isSelected)),
                  )
                else if (isSelected && iconBuilder != null)
                  SizedBox.square(
                    dimension: compactIconSize,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: iconBuilder!(isSelected),
                    ),
                  ),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: _fade,
                    curve: Curves.easeOut,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall(color: _labelColor),
                    child: Text(label),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    const shape = StadiumBorder();
    final BorderRadius inkRadius = BorderRadius.circular(999);

    if (tabBar) return _buildTab(context, shape, inkRadius);

    return ConstrainedBox(
      constraints: compactConstraints,
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        shape: shape,
        color: backgroundColor ?? AppColorStyles.backgroundTertiary,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: SoundTap.wrap(onPressed),
          borderRadius: inkRadius,
          mouseCursor: SystemMouseCursors.click,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _selectedBackground(),

              Padding(
                padding: compactPadding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: [
                    if (isSelected && iconBuilder != null)
                      SizedBox.square(
                        dimension: compactIconSize,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: iconBuilder!(isSelected),
                        ),
                      ),

                    Flexible(
                      child: AnimatedDefaultTextStyle(
                        duration: _fade,
                        curve: Curves.easeOut,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall(color: _labelColor),
                        child: Text(label),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
