import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

import 'styled_menu_item.dart';
import 'styled_menu_trigger.dart';

class StyledMenuConfig {
  const StyledMenuConfig({
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
}

typedef StyledMenuTriggerBuilder =
    Widget Function(
      BuildContext context,
      MenuController controller,
      bool isOpen,
      StyledMenuConfig config,
    );

class StyledMenu<T> extends StatefulWidget {
  const StyledMenu({
    required this.items,
    required this.configBuilder,
    required this.selectedValue,
    required this.onChanged,
    super.key,
    this.minWidth = 160.0,
    this.maxWidth,
    this.height = 40.0,
    this.triggerBuilder,
    this.menuWidth,
    this.offset = const Offset(0, 4),
    this.header,
  });

  final List<T> items;
  final StyledMenuConfig Function(T item) configBuilder;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final double minWidth;
  final double? maxWidth;
  final double? height;
  final double? menuWidth;
  final StyledMenuTriggerBuilder? triggerBuilder;
  final Offset offset;
  final Widget? header;

  @override
  State<StyledMenu<T>> createState() => _StyledMenuState<T>();
}

class _StyledMenuState<T> extends State<StyledMenu<T>> {
  final FocusNode _buttonFocusNode = FocusNode(
    debugLabel: 'Styled Menu Button',
  );
  final ValueNotifier<bool> _isOpenNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    _isOpenNotifier.dispose();
    super.dispose();
  }

  void _activate(T selection) {
    if (widget.selectedValue != selection) {
      widget.onChanged(selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveMenuWidth = widget.menuWidth ?? widget.minWidth;

    return MenuAnchor(
      alignmentOffset: widget.offset,
      childFocusNode: _buttonFocusNode,
      onOpen: () => _isOpenNotifier.value = true,
      onClose: () => _isOpenNotifier.value = false,
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
        backgroundColor: const WidgetStatePropertyAll(
          AppColorStyles.backgroundTertiary,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        minimumSize: WidgetStatePropertyAll(Size(effectiveMenuWidth, 0)),
      ),
      menuChildren: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.header != null) widget.header!,
            ...widget.items.map((entry) {
              final config = widget.configBuilder(entry);
              return StyledMenuItem(
                selected: widget.selectedValue == entry,
                onPressed: () => _activate(entry),
                minWidth: effectiveMenuWidth,
                leadingIcon: config.leadingIcon,
                trailingIcon: config.trailingIcon,
                child: Text(config.label),
              );
            }),
          ],
        ),
      ],
      builder: (context, controller, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isOpenNotifier,
          builder: (context, isOpen, _) {
            final config = widget.configBuilder(widget.selectedValue);
            if (widget.triggerBuilder != null) {
              return widget.triggerBuilder!(
                context,
                controller,
                isOpen,
                config,
              );
            }
            return StyledMenuTrigger(
              label: config.label,
              isOpen: isOpen,
              minWidth: widget.minWidth,
              maxWidth: widget.maxWidth ?? widget.minWidth,
              height: widget.height,
              leadingIcon: config.leadingIcon,
              trailingIcon: config.trailingIcon,
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
            );
          },
        );
      },
    );
  }
}
