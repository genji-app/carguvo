import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class SportDesktopSectionTabs extends StatefulWidget {
  final List<String> sections;
  final int selectedIndex;
  final void Function(int)? onTabSelected;
  final bool isMobile;

  const SportDesktopSectionTabs({
    super.key,
    required this.sections,
    this.selectedIndex = 0,
    this.onTabSelected,
    this.isMobile = false,
  });

  @override
  State<SportDesktopSectionTabs> createState() =>
      _SportDesktopSectionTabsState();
}

class _SportDesktopSectionTabsState extends State<SportDesktopSectionTabs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final GlobalKey _rowKey = GlobalKey();
  double? _singleSetWidth;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndStartAnimation();
    });
  }

  void _measureAndStartAnimation() {
    final RenderBox? renderBox =
        _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final totalWidth = renderBox.size.width;
      setState(() {
        _singleSetWidth = totalWidth / 3;
      });
    }
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duplicatedSections = [
      ...widget.sections,
      ...widget.sections,
      ...widget.sections,
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: double.infinity,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final width = _singleSetWidth ?? 0;
                        if (width == 0) {
                          return _buildTabsRow(duplicatedSections);
                        }

                        final offset =
                            (_animationController.value * width) % width;

                        return Transform.translate(
                          offset: Offset(-offset, 0),
                          child: _buildTabsRow(duplicatedSections),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            bottom: 0,
            top: 0,
            child: Container(
              width: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF151410),
                    const Color(0xFF151410).withValues(alpha: 0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                width: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF151410).withValues(alpha: 0),
                      const Color(0xFF151410),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
              if (!widget.isMobile)
                Material(
                  color: const Color(0xFF302F2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: InkWell(
                    onTap: SoundTap.wrap(() {}),
                    borderRadius: BorderRadius.circular(4),
                    child: ImageHelper.load(
                      path: AppIcons.btnArrowRight,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabsRow(List<String> duplicatedSections) {
    return Row(
      key: _rowKey,
      mainAxisSize: MainAxisSize.min,
      children: duplicatedSections.asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value;
        final sectionIndex = index % widget.sections.length;
        final isSelected = widget.selectedIndex == sectionIndex;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _SectionTabItem(
            label: section,
            icon: null,
            isSelected: isSelected,
            onTap: () => widget.onTabSelected?.call(sectionIndex),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionTabItem extends StatelessWidget {
  final String label;
  final Widget? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SectionTabItem({
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: SoundTap.wrap(onTap),
      borderRadius: BorderRadius.circular(1000),
      child: Container(
        height: 48,
        padding: const EdgeInsets.only(left: 8, right: 15),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0x0AFFF6E4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1000),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            if (icon != null)
              SizedBox(width: 32, height: 32, child: icon)
            else
              Container(
                width: 32,
                height: 32,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1000),
                  ),
                ),
              ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall(color: const Color(0xFFAAA49B)),
            ),
          ],
        ),
      ),
    ),
  );
}
