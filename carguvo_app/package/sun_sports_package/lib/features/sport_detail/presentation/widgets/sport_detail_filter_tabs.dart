import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_date_provider.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_tab_provider.dart';
import 'package:sun_sports/shared/widgets/sport/enums/sport_filter_enums.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class SportDetailFilterTabs extends ConsumerWidget {
  final bool isDesktop;
  final ValueChanged<SportDetailFilterType>? onFilterChanged;

  final ValueChanged<String>? onDateSelected;

  const SportDetailFilterTabs({
    super.key,
    this.isDesktop = false,
    this.onFilterChanged,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportId = ref.watch(selectedSportV2Provider.select((s) => s.id));

    final filters = SportDetailFilterType.values
        .where(
          (filter) => filter != SportDetailFilterType.special || sportId == 1,
        )
        .toList();

    final dates =
        ref.watch(eventDatesProvider(sportId)).valueOrNull ?? const <String>[];

    return Container(
      decoration: isDesktop
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
              ),
            )
          : null,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 12),
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical:8.0),
          child: Row(
            children: [
              for (final filter in filters)
                _FilterTab(
                  filter: filter,
                  isDesktop: isDesktop,
                  onFilterChanged: onFilterChanged,
                ),
              for (final date in dates)
                _DateTab(
                  date: date,
                  isDesktop: isDesktop,
                  onDateSelected: onDateSelected,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterTab extends ConsumerWidget {
  final SportDetailFilterType filter;
  final bool isDesktop;
  final ValueChanged<SportDetailFilterType>? onFilterChanged;

  const _FilterTab({
    required this.filter,
    required this.isDesktop,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
      sportDetailTabProvider.select((selected) => selected == filter),
    );
    final hasDateSelected = ref.watch(
      sportDetailSelectedDateProvider.select((date) => date != null),
    );

    return _TabShell(
      label: filter.label,
      isSelected: isSelected && !hasDateSelected,
      isDesktop: isDesktop,
      onTap: () {
        ref.read(sportDetailSelectedDateProvider.notifier).state = null;
        onFilterChanged?.call(filter);
      },
    );
  }
}

class _DateTab extends ConsumerWidget {
  final String date;
  final bool isDesktop;
  final ValueChanged<String>? onDateSelected;

  const _DateTab({
    required this.date,
    required this.isDesktop,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
      sportDetailSelectedDateProvider.select((selected) => selected == date),
    );

    return _TabShell(
      label: date.toTabLabel(),
      isSelected: isSelected,
      isDesktop: isDesktop,
      onTap: () {
        ref.read(sportDetailSelectedDateProvider.notifier).state = date;
        onDateSelected?.call(date);
      },
    );
  }
}

class _TabShell extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDesktop;
  final VoidCallback onTap;

  const _TabShell({
    required this.label,
    required this.isSelected,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      alignment: Alignment.center,
      children: [
        if (isSelected)
          Positioned(
            bottom: 0,
            left: isDesktop ? 0 : -20,
            right: isDesktop ? 0 : -20,
            child: ImageHelper.load(
              path: AppIcons.sportStatusSelected,
              fit: BoxFit.fill,
            ),
          ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: isDesktop ? 16 : 10,
            horizontal: isDesktop ? 24 : 16,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.textStyle(
                fontSize: isDesktop ? 14 : 12,
                fontWeight: isDesktop ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.yellow300
                    : const Color(0xFF9C9B95),
              ),
            ),
          ),
        ),
      ],
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(onTap),
        behavior: HitTestBehavior.opaque,
        child: isDesktop
            ? content
            : Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: ColoredBox(
                    color: const Color(0xFF1B1A19),
                    child: content,
                  ),
                ),
              ),
      ),
    );
  }
}
