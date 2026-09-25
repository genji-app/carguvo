import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/preferences/bet/bet_preferences.dart';
import 'package:sun_sports/features/preferences/bet/odds_info.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

import 'odds_style_explanation.dart';

class OddsStyleDropdown extends ConsumerWidget {
  const OddsStyleDropdown({super.key});

  static const _menuItems = [
    OddsStyle.decimal,
    OddsStyle.hongKong,
    OddsStyle.indo,
    OddsStyle.malay,
  ];

  static const _menuMinWidth = 210.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(sbMaintenanceProvider)) return const SizedBox.shrink();

    return MenuAnchor(
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        backgroundColor: const WidgetStatePropertyAll(
          AppColorStyles.backgroundQuaternary,
        ),
        shadowColor: WidgetStatePropertyAll(
          Colors.black.withValues(alpha: 0.5),
        ),
        elevation: const WidgetStatePropertyAll(20),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: AppColorStyles.borderSecondary,
              width: 0.5,
            ),
          ),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(_menuMinWidth, 0)),
      ),
      alignmentOffset: const Offset(0, 8),
      menuChildren: [
        for (final style in _menuItems)
          _OddsStyleMenuItem(
            style: style,
            onSelect: (value) => ref
                .read(betPreferencesProvider.notifier)
                .updateOddsStyle(value),
          ),
      ],
      builder: (context, controller, _) {
        return _OddsStyleTrigger(
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
  }
}

class _OddsStyleMenuItem extends StatelessWidget {
  const _OddsStyleMenuItem({required this.style, required this.onSelect});

  final OddsStyle style;

  final ValueChanged<OddsStyle> onSelect;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final selected = ref.watch(
          betPreferencesProvider.select((s) => s.oddsStyle == style),
        );
        return MenuItemButton(
          onPressed: SoundTap.wrap(() => onSelect(style)),
          style: ButtonStyle(
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 8),
            ),
            minimumSize: const WidgetStatePropertyAll(
              Size(OddsStyleDropdown._menuMinWidth - 16, 0),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            backgroundColor: selected
                ? const WidgetStatePropertyAll(
                    AppColorStyles.backgroundTertiary,
                  )
                : null,
          ),
          child: SizedBox(
            width: OddsStyleDropdown._menuMinWidth - 32,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    style.label,
                    style: AppTextStyles.labelSmall(
                      color: selected
                          ? AppColors.green300
                          : AppColorStyles.contentPrimary,
                    ),
                  ),
                ),
                OddsStyleExplanationButton(odds: style),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OddsStyleTrigger extends StatelessWidget {
  const _OddsStyleTrigger({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(onPressed),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x33FFFFFF)),
            borderRadius: BorderRadius.circular(1000),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(1000),
            child: Stack(
              children: [
                Positioned.fill(
                  right: -1,
                  child: ImageHelper.load(
                    path: AppImages.backgroundOddStyle,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Tỷ lệ cược:',
                        style: AppTextStyles.labelXSmall(
                          color: AppColorStyles.contentTertiary,
                        ),
                      ),
                      const Gap(30),
                      Row(
                        children: [
                          Consumer(
                            builder: (context, ref, _) {
                              final oddsStyle = ref.watch(
                                betPreferencesProvider.select(
                                  (s) => s.oddsStyle,
                                ),
                              );
                              return Text(
                                oddsStyle.label,
                                style: AppTextStyles.labelXSmall(
                                  color: AppColors.green300,
                                ),
                              );
                            },
                          ),
                          const Gap(8),
                          ImageHelper.load(
                            path: AppIcons.iconSwitch,
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
