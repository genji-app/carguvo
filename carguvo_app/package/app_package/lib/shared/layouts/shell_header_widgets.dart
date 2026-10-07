import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:app_package/core/providers/slider_drawer_provider.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_icons.dart';
import 'package:app_package/core/utils/styles/app_images.dart';
import 'package:app_package/providers/main_content_provider.dart';
import 'package:app_package/shared/widgets/buttons/sound_tap.dart';

class ShellHeaderMenuButton extends ConsumerWidget {
  const ShellHeaderMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: 'Menu',
      child: GestureDetector(
        onTap: SoundTap.wrap(
          () => ref.read(sliderDrawerKeyProvider).currentState?.toggle(),
        ),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: ImageHelper.load(
              path: AppIcons.icMenu,
              width: 20,
              height: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class ShellHeaderGuestLogo extends StatelessWidget {
  const ShellHeaderGuestLogo({super.key});

  static const double _kMinWidth = 375;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < _kMinWidth) {
      return const SizedBox.shrink();
    }
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [Gap(4), ShellHeaderLogoButton()],
    );
  }
}

class ShellHeaderLogoButton extends ConsumerWidget {
  const ShellHeaderLogoButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: SoundTap.wrap(
        () => ref.read(mainContentProvider.notifier).goToHome(),
      ),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: AppImages.logoUrl.isEmpty
            ? null
            : Center(
                child: ImageHelper.load(
                  path: AppImages.logoUrl,
                  width: 36,
                  height: 34,
                  fit: BoxFit.contain,
                ),
              ),
      ),
    );
  }
}
