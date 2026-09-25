import 'package:flutter/material.dart' hide CloseButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/services/storage/quick_guide_settings.dart';
import 'package:sun_sports/core/services/storage/search_onboarding_storage.dart';
import 'package:sun_sports/core/services/storage/sound_settings.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/onboarding/onboarding.dart';
import 'package:sun_sports/features/preferences/preferences.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/after_route_transition.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/input/input.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AfterRouteTransition(
      placeholder: _SettingsSkeleton(),
      builder: _buildBody,
    );
  }

  static Widget _buildBody(BuildContext context) => const _SettingsBody();
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double height) => Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [bar(48), const Gap(32), bar(48)],
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const hPadding = 12.0;
    final navigator = ref.read(preferencesNavigatorProvider);
    final subColor = AppColorStyles.contentSecondary;

    final betPreferences = ref.watch(betPreferencesProvider);
    final currentOddsLabel = betPreferences.oddsStyle.label;

    Future<void> toggleSound(bool value) async {
      await SoundSettings.instance.setEnabled(value);
      if (value) {
        SoundEffects.instance.playTap();
      }
    }

    void setQuickGuide(bool value) {
      QuickGuideSettings.instance.setEnabled(value);
      if (!value) return;
      SearchOnboardingStorage.instance.setPending(true);
      final spotlight = ref.read(spotlightControllerProvider.notifier);
      final tour = ResponsiveBuilder.isMobile(context)
          ? sun88QuickGuideTourMobile
          : sun88QuickGuideTour;
      ref.read(profileHubControllerProvider).close();
      Future<void>.delayed(
        const Duration(milliseconds: 350),
        () => spotlight.start(tour),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: hPadding),
      child: Column(
        children: [
          if (!ref.watch(sbMaintenanceProvider)) ...[
            _SettingsListTile(
              title: const Text(I18n.txtOdds),
              helperText: const Text(I18n.txtOddsHelper),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentOddsLabel,
                    style: AppTextStyles.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: AppColors.yellow200,
                    ),
                  ),
                  const Gap(8),
                  Transform.flip(
                    flipX: true,
                    child: SizedBox.square(
                      dimension: 24,
                      child: ImageHelper.load(
                        path: AppIcons.icBack,
                        color: subColor,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: SoundTap.wrap(() {
                navigator.pushToBetPreferences(context);
              }),
            ),
            const Gap(32),
          ],

          ValueListenableBuilder<bool>(
            valueListenable: SoundSettings.instance.enabled,
            builder: (context, enabled, child) {
              return _SettingsListTile(
                title: const Text(I18n.txtSound),
                helperText: const Text(I18n.txtSoundHelper),
                trailing: SquishyWishySwitch(
                  value: enabled,
                  onChanged: toggleSound,
                ),
                onTap: () => toggleSound(!enabled),
              );
            },
          ),

          const Gap(32),

          ValueListenableBuilder<bool>(
            valueListenable: QuickGuideSettings.instance.enabled,
            builder: (context, enabled, child) {
              return _SettingsListTile(
                title: const Text('Hướng dẫn nhanh'),
                helperText: const Text(
                  'Bật hướng dẫn nhanh sau mỗi lần đăng nhập để xem lại, '
                  'tự động tắt tính năng sau khi xem xong hoặc bỏ qua.',
                ),
                trailing: SquishyWishySwitch(
                  value: enabled,
                  onChanged: setQuickGuide,
                ),
                onTap: () => setQuickGuide(!enabled),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsListTile extends StatelessWidget {
  const _SettingsListTile({
    required this.title,
    this.trailing,
    this.onTap,
    this.helperText,
  });

  final Widget title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? helperText;

  @override
  Widget build(BuildContext context) {
    const contentColor = AppColorStyles.contentPrimary;
    const tertiaryColor = AppColorStyles.contentTertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            minTileHeight: 48,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: DefaultTextStyle.merge(
              style: AppTextStyles.paragraphSmall(color: contentColor),
              child: title,
            ),
            trailing: trailing,
            onTap: onTap,
          ),
        ),
        if (helperText != null) ...[
          const Gap(8),
          Container(
            padding: const EdgeInsets.only(left: 16),
            alignment: Alignment.centerLeft,
            child: DefaultTextStyle.merge(
              style: AppTextStyles.paragraphXSmall(color: tertiaryColor),
              child: helperText!,
            ),
          ),
        ],
      ],
    );
  }
}
