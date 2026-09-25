import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/forms/selection_menu.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

enum SelectionIconStyle {
  defaultStyle,

  minimal,

  custom,
}

class SelectionField extends StatefulWidget {
  final String label;

  final String? errorMessage;

  final String? selectedValue;

  final String placeholder;

  final List<SelectionMenuItem> items;

  final void Function(String value) onSelected;

  final void Function(String invalidValue)? onSelectionError;

  final SelectionIconStyle iconStyle;

  final Widget? Function(SelectionMenuItem selectedItem)? buildSelectedIcon;

  final String? bottomSheetTitle;

  final EdgeInsets? padding;

  final bool enableSearch;

  final String? searchHint;

  final bool isLoading;

  final bool showIconsInBottomSheet;

  const SelectionField({
    super.key,
    required this.label,
    this.errorMessage,
    this.selectedValue,
    required this.placeholder,
    required this.items,
    required this.onSelected,
    this.onSelectionError,
    this.iconStyle = SelectionIconStyle.defaultStyle,
    this.buildSelectedIcon,
    this.bottomSheetTitle,
    this.padding,
    this.enableSearch = false,
    this.searchHint,
    this.isLoading = false,
    this.showIconsInBottomSheet = true,
  });

  @override
  State<SelectionField> createState() => _SelectionFieldState();
}

class _SelectionFieldState extends State<SelectionField> {
  final GlobalKey _buttonKey = GlobalKey();
  final ValueNotifier<bool> _isMenuOpen = ValueNotifier<bool>(false);
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<List<SelectionMenuItem>> _filteredItems =
      ValueNotifier<List<SelectionMenuItem>>([]);

  @override
  void initState() {
    super.initState();
    _filteredItems.value = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(SelectionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _filteredItems.value = widget.items;
          _searchController.clear();
        }
      });
    }
  }

  @override
  void dispose() {
    _isMenuOpen.dispose();
    _searchController.dispose();
    _filteredItems.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredItems.value = widget.items;
    } else {
      _filteredItems.value = widget.items
          .where((item) => item.label.toLowerCase().contains(query))
          .toList();
    }
  }

  SelectionMenuItem? get _selectedItem {
    if (widget.selectedValue == null || widget.items.isEmpty) {
      return null;
    }
    try {
      return widget.items.firstWhere(
        (item) => item.value == widget.selectedValue,
      );
    } catch (e) {
      if (widget.onSelectionError != null) {
        widget.onSelectionError!(widget.selectedValue!);
      }
      if (kDebugMode) {
        debugPrint(
          'SelectionField: Selected value "${widget.selectedValue}" not found in items',
        );
      }
      return null;
    }
  }

  Future<void> _showMobileBottomSheet() async {
    _searchController.clear();
    _filteredItems.value = widget.items;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.gray950,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.bottomSheetTitle ?? widget.label,
              style: AppTextStyles.headingSmall(color: AppColors.gray25),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ValueListenableBuilder<List<SelectionMenuItem>>(
                valueListenable: _filteredItems,
                builder: (context, filteredItems, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return ListTile(
                        leading: widget.showIconsInBottomSheet
                            ? _buildIconWidget(
                                    item,
                                    size: 32,
                                    showInBottomSheet: true,
                                  ) ??
                                  const SizedBox.shrink()
                            : null,
                        title: Text(
                          item.label,
                          style: AppTextStyles.paragraphMedium(
                            color: AppColors.gray25,
                          ),
                        ),
                        selected: widget.selectedValue == item.value,
                        selectedTileColor: AppColors.gray900.withValues(
                          alpha: 0.3,
                        ),
                        onTap: SoundTap.wrap(
                          () => Navigator.of(context).pop(item.value),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (selected != null && mounted && selected != widget.selectedValue) {
      widget.onSelected(selected);
    }
  }

  Widget? _buildIconWidget(
    SelectionMenuItem? item, {
    required double size,
    required bool showInBottomSheet,
  }) {
    if (item == null) return null;

    if (widget.iconStyle == SelectionIconStyle.custom &&
        widget.buildSelectedIcon != null) {
      return widget.buildSelectedIcon!(item);
    }

    if (item.iconUrl != null && item.iconUrl!.isNotEmpty) {
      if (showInBottomSheet) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.gray25,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ImageHelper.load(
              path: item.iconUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorWidget: Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: size * 0.5,
                  color: AppColors.gray400,
                ),
              ),
              placeholder: Center(
                child: SizedBox(
                  width: size * 0.5,
                  height: size * 0.5,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gray400,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      final iconWidget = ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ImageHelper.load(
          path: item.iconUrl!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorWidget: Icon(
            Icons.credit_card,
            size: size * 0.625,
            color: AppColors.gray950,
          ),
          placeholder: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: SizedBox(
                width: size * 0.5,
                height: size * 0.5,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.gray950,
                ),
              ),
            ),
          ),
        ),
      );

      if (widget.iconStyle == SelectionIconStyle.minimal) {
        return SizedBox(width: size, height: size, child: iconWidget);
      }

      return Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColors.gray25,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray700),
        ),
        child: iconWidget,
      );
    }

    if (item.iconAssetPath != null && item.iconAssetPath!.isNotEmpty) {
      if (showInBottomSheet) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.gray25,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray700, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ImageHelper.load(
              path: item.iconAssetPath!,
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          ),
        );
      }

      final iconWidget = ImageHelper.load(
        path: item.iconAssetPath!,
        width: size,
        height: size,
      );

      if (widget.iconStyle == SelectionIconStyle.minimal) {
        return SizedBox(width: size, height: size, child: iconWidget);
      }

      return Container(
        width: size,
        height: size,
        margin: const EdgeInsets.only(right: 8),
        child: iconWidget,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveBuilder.getDeviceType(context);
    final selectedItem = _selectedItem;
    final defaultPadding =
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.labelSmall(color: AppColors.gray300),
        ),
        if (widget.errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorMessage!,
            style: AppTextStyles.labelSmall(color: Colors.red),
          ),
        ],
        const SizedBox(height: 8),
        if (deviceType == DeviceType.mobile)
          InkWell(
            onTap: SoundTap.wrap(widget.isLoading ? null : _showMobileBottomSheet),
            borderRadius: BorderRadius.circular(12),
            child: Opacity(
              opacity: widget.isLoading ? 0.6 : 1.0,
              child: Container(
                height: 48,
                padding: defaultPadding,
                decoration: BoxDecoration(
                  color: AppColors.gray900,
                  border: Border.all(
                    color: widget.errorMessage != null
                        ? Colors.red
                        : AppColors.gray700,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (widget.isLoading) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.gray400,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (!widget.isLoading)
                      _buildIconWidget(
                            selectedItem,
                            size: 32,
                            showInBottomSheet: false,
                          ) ??
                          const SizedBox.shrink(),
                    Expanded(
                      child: Text(
                        selectedItem?.label ?? widget.placeholder,
                        style: AppTextStyles.paragraphMedium(
                          color: selectedItem != null
                              ? AppColors.gray25
                              : AppColors.gray400,
                        ),
                      ),
                    ),
                    if (!widget.isLoading)
                      ImageHelper.load(
                        path: AppIcons.chevronDown,
                        width: 20,
                        height: 20,
                        color: AppColors.gray25,
                      ),
                  ],
                ),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) => InkWell(
              onTap: SoundTap.wrap(widget.isLoading
                  ? null
                  : () async {
                      _isMenuOpen.value = true;

                      final selectedValue = await SelectionMenu.show(
                        context: context,
                        items: widget.items,
                        buttonKey: _buttonKey,
                        buttonWidth: constraints.maxWidth,
                        selectedValue: widget.selectedValue,
                      );

                      if (mounted) {
                        _isMenuOpen.value = false;
                      }

                      if (selectedValue != null &&
                          mounted &&
                          selectedValue != widget.selectedValue) {
                        widget.onSelected(selectedValue);
                      }
                    }),
              borderRadius: BorderRadius.circular(12),
              child: Opacity(
                opacity: widget.isLoading ? 0.6 : 1.0,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isMenuOpen,
                  builder: (context, isMenuOpen, child) {
                    return Container(
                      key: _buttonKey,
                      height: 48,
                      padding: defaultPadding,
                      decoration: BoxDecoration(
                        color: AppColors.gray900,
                        border: Border.all(
                          color: widget.errorMessage != null
                              ? Colors.red
                              : isMenuOpen
                              ? AppColors.yellow300
                              : AppColors.gray700,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if (widget.isLoading) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.gray400,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (!widget.isLoading)
                            _buildIconWidget(
                                  selectedItem,
                                  size: 32,
                                  showInBottomSheet: false,
                                ) ??
                                const SizedBox.shrink(),
                          Expanded(
                            child: Text(
                              selectedItem?.label ?? widget.placeholder,
                              style: AppTextStyles.paragraphMedium(
                                color: selectedItem != null
                                    ? AppColors.gray25
                                    : AppColors.gray400,
                              ),
                            ),
                          ),
                          if (!widget.isLoading)
                            ImageHelper.load(
                              path: isMenuOpen
                                  ? AppIcons.chevronUp
                                  : AppIcons.chevronDown,
                              width: 20,
                              height: 20,
                              color: AppColors.gray25,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
