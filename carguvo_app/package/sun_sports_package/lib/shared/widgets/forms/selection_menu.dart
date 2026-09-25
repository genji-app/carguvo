import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';

class SelectionMenuItem {
  final String value;
  final String label;
  final String? iconUrl;
  final String? iconAssetPath;
  final bool showDefaultIcon;

  const SelectionMenuItem({
    required this.value,
    required this.label,
    this.iconUrl,
    this.iconAssetPath,
    this.showDefaultIcon = false,
  });
}

class SelectionMenu {
  static const Color defaultHoverBackgroundColor = AppColors.gray300;

  static const double _menuBorderRadius = 12;

  static Future<String?> show({
    required BuildContext context,
    required List<SelectionMenuItem> items,
    required GlobalKey buttonKey,
    required double buttonWidth,
    String? selectedValue,
    Color hoverBackgroundColor = defaultHoverBackgroundColor,
  }) async {
    final RenderBox? buttonBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return null;

    final buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final buttonSize = buttonBox.size;

    final position = RelativeRect.fromLTRB(
      buttonPosition.dx,
      buttonPosition.dy + buttonSize.height + 4,
      buttonPosition.dx + buttonSize.width,
      double.infinity,
    );

    final selectedId = await _showMenuWithThemeOverride<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_menuBorderRadius),
        side: BorderSide(
          color: AppColors.gray700,
          width: 1,
        ),
      ),
      color: AppColors.gray500,
      constraints: BoxConstraints(
        minWidth: buttonWidth,
        maxWidth: buttonWidth,
        maxHeight: _calculateMaxHeight(items.length),
      ),
      items: List<PopupMenuEntry<String>>.generate(items.length, (index) {
        final item = items[index];
        return PopupMenuItem<String>(
          value: item.value,
          onTap: SoundEffects.instance.playTap,
          padding: EdgeInsets.zero,
          child: _SelectionMenuItemTile(
            item: item,
            isSelected: selectedValue == item.value,
            hoverBackgroundColor: hoverBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            isFirst: index == 0,
            isLast: index == items.length - 1,
            menuBorderRadius: _menuBorderRadius,
          ),
        );
      }),
    );

    return selectedId;
  }

  static Future<T?> _showMenuWithThemeOverride<T>({
    required BuildContext context,
    required RelativeRect position,
    required List<PopupMenuEntry<T>> items,
    required ShapeBorder shape,
    required Color color,
    required BoxConstraints constraints,
  }) async {
    final overlay = Overlay.of(context);
    final completer = Completer<BuildContext>();
    OverlayEntry? overrideEntry;
    overrideEntry = OverlayEntry(
      builder: (overlayContext) {
        final baseTheme = Theme.of(overlayContext);
        final basePopupTheme = PopupMenuTheme.of(overlayContext);
        return Theme(
          data: baseTheme.copyWith(
            popupMenuTheme: basePopupTheme.copyWith(
              menuPadding: EdgeInsets.zero,
            ),
          ),
          child: PopupMenuTheme(
            data: basePopupTheme.copyWith(menuPadding: EdgeInsets.zero),
            child: Builder(
              builder: (themedContext) {
                if (!completer.isCompleted) {
                  completer.complete(themedContext);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
    overlay.insert(overrideEntry);

    try {
      final themedContext = await completer.future;
      if (!themedContext.mounted) return null;
      return await showMenu<T>(
        context: themedContext,
        position: position,
        shape: shape,
        color: color,
        constraints: constraints,
        clipBehavior: Clip.antiAlias,
        items: items,
      );
    } finally {
      overrideEntry.remove();
    }
  }

  static Widget _buildIcon(SelectionMenuItem item) {
    if (item.iconAssetPath != null && item.iconAssetPath!.isNotEmpty) {
      return _buildIconContainer(child: _buildAssetIcon(item.iconAssetPath!));
    }

    if (item.iconUrl != null && item.iconUrl!.isNotEmpty) {
      return _buildIconContainer(child: _buildNetworkIcon(item.iconUrl!));
    }

    if (item.showDefaultIcon) {
      return _buildDefaultIcon();
    }

    return const SizedBox.shrink();
  }

  static Widget _buildIconContainer({required Widget child}) => Container(
    width: 32,
    height: 32,
    margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      color: AppColors.gray25,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.gray700, width: 0.5),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(7.5),
      child: child,
    ),
  );

  static Widget _buildAssetIcon(String assetPath) {
  
    return ImageHelper.load(
      path: assetPath,
      width: 32,
      height: 32,
      fit: BoxFit.cover,
    );
  }

  static Widget _buildNetworkIcon(String url) {
    return Builder(
      builder: (context) {
        try {
          return ImageHelper.load(
            path: url,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorWidget: const Icon(
              Icons.account_balance,
              size: 20,
              color: AppColors.gray950,
            ),
            placeholder: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.gray950,
                ),
              ),
            ),
          );
        } catch (e) {
          return const Icon(
            Icons.account_balance,
            size: 20,
            color: AppColors.gray950,
          );
        }
      },
    );
  }

  static Widget _buildDefaultIcon() => Container(
    width: 32,
    height: 32,
    margin: const EdgeInsets.only(right: 12),
    child: const Icon(Icons.account_balance, size: 20, color: AppColors.gray25),
  );

  static double _calculateMaxHeight(int itemCount) {
    const double itemHeight = 48.0;
    const double menuPadding = 8.0;
    const double maxScreenHeight = 400.0;

    final double calculatedHeight = (itemCount * itemHeight) + menuPadding;

    return calculatedHeight > maxScreenHeight
        ? maxScreenHeight
        : calculatedHeight;
  }
}

class _SelectionMenuItemTile extends StatefulWidget {
  const _SelectionMenuItemTile({
    required this.item,
    required this.isSelected,
    required this.hoverBackgroundColor,
    required this.padding,
    required this.isFirst,
    required this.isLast,
    required this.menuBorderRadius,
  });

  final SelectionMenuItem item;
  final bool isSelected;
  final Color hoverBackgroundColor;
  final EdgeInsetsGeometry padding;

  final bool isFirst;

  final bool isLast;

  final double menuBorderRadius;

  @override
  State<_SelectionMenuItemTile> createState() => _SelectionMenuItemTileState();
}

class _SelectionMenuItemTileState extends State<_SelectionMenuItemTile> {
  bool _isHovered = false;

  void _setHovered(bool value) {
    if (_isHovered == value) return;
    setState(() => _isHovered = value);
  }

  BorderRadius get _hoverBorderRadius {
    final corner = Radius.circular(widget.menuBorderRadius);
    return BorderRadius.only(
      topLeft: widget.isFirst ? corner : Radius.zero,
      topRight: widget.isFirst ? corner : Radius.zero,
      bottomLeft: widget.isLast ? corner : Radius.zero,
      bottomRight: widget.isLast ? corner : Radius.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _isHovered ? widget.hoverBackgroundColor : Colors.transparent,
          borderRadius: _hoverBorderRadius,
        ),
        padding: widget.padding,
        child: Row(
          children: [
            SelectionMenu._buildIcon(widget.item),
            Expanded(
              child: Text(
                widget.item.label,
                style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
              ),
            ),
            if (widget.isSelected)
              const Icon(Icons.check, size: 20, color: AppColors.yellow300),
          ],
        ),
      ),
    );
  }
}
