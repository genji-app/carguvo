import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class PillTabChip extends StatelessWidget {
  const PillTabChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    super.key,
    this.iconBuilder,
    this.backgroundColor = AppColorStyles.backgroundTertiary,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  final Widget Function(bool isSelected)? iconBuilder;

  final Color backgroundColor;

  static const constraints = BoxConstraints(minHeight: 32, minWidth: 56);
  static const padding = EdgeInsets.symmetric(horizontal: 14, vertical: 6);
  static const double iconSize = 20;
  static const Duration _fade = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isSelected
        ? AppColors.yellow300
        : AppColorStyles.contentSecondary;

    return ConstrainedBox(
      constraints: constraints,
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        shape: const StadiumBorder(),
        color: backgroundColor,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: SoundTap.wrap(onPressed),
          borderRadius: BorderRadius.circular(999),
          mouseCursor: SystemMouseCursors.click,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
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
              ),
              Padding(
                padding: padding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: [
                    if (isSelected && iconBuilder != null)
                      SizedBox.square(
                        dimension: iconSize,
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
                        style: AppTextStyles.labelSmall(color: labelColor),
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

class PillTabRow extends StatefulWidget {
  const PillTabRow({
    required this.itemCount,
    required this.itemBuilder,
    required this.selectedIndex,
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  final int itemCount;

  final Widget Function(BuildContext context, int index) itemBuilder;

  final int selectedIndex;
  final EdgeInsets padding;

  @override
  State<PillTabRow> createState() => _PillTabRowState();
}

class _PillTabRowState extends State<PillTabRow> {
  final List<GlobalKey> _keys = <GlobalKey>[];

  void _syncKeys() {
    while (_keys.length < widget.itemCount) {
      _keys.add(GlobalKey());
    }
    if (_keys.length > widget.itemCount) {
      _keys.removeRange(widget.itemCount, _keys.length);
    }
  }

  @override
  void didUpdateWidget(covariant PillTabRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centreSelected());
    }
  }

  void _centreSelected() {
    if (!mounted) return;
    final int i = widget.selectedIndex;
    if (i < 0 || i >= _keys.length) return;
    final BuildContext? ctx = _keys[i].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncKeys();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < widget.itemCount; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            KeyedSubtree(key: _keys[i], child: widget.itemBuilder(context, i)),
          ],
        ],
      ),
    );
  }
}
