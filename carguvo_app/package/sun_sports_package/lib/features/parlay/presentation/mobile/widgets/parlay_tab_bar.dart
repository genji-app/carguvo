import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class ParlayTabBar extends ConsumerWidget {
  const ParlayTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(
      parlayStateProvider.select((state) => state.tab),
    );
    final notifier = ref.read(parlayStateProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            _ParlayTab(
              label: 'Cược đơn',
              icon: AppIcons.sportSingleTicket,
              isActive: currentTab == ParlayTab.single,
              onTap: () => notifier.selectTab(ParlayTab.single),
            ),
            _ParlayTab(
              label: 'Cược xiên',
              icon: AppIcons.sportComboTicket,
              isActive: currentTab == ParlayTab.combo,
              onTap: () => notifier.selectTab(ParlayTab.combo),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParlayTab extends StatelessWidget {
  final String label;
  final String? icon;
  final String? badge;
  final bool isActive;
  final VoidCallback onTap;

  const _ParlayTab({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
    this.badge,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: SoundTap.wrap(onTap),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromRGBO(249, 219, 175, 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                ImageHelper.load(path: icon!, width: 20, height: 20),
                const Gap(4),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppTextStyles.labelSmall(
                    color: isActive
                        ? AppColorStyles.contentPrimary
                        : AppColorStyles.contentSecondary,
                  ),
                ),
              ),
              if (badge != null) ...[
                const Gap(4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.orange300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      badge!,
                      style: AppTextStyles.labelXSmall(
                        color: AppColors.gray950,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
