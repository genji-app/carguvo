import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/game/player/providers/asset_wipe_provider.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';

class BundleReloadOverlay extends ConsumerStatefulWidget {
  const BundleReloadOverlay({super.key});

  @override
  ConsumerState<BundleReloadOverlay> createState() =>
      _BundleReloadOverlayState();
}

class _BundleReloadOverlayState extends ConsumerState<BundleReloadOverlay> {
  bool _fadeCompleted = true;

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(assetWipePhaseProvider);
    final isReloading = phase == AssetWipePhase.reloading;

    if (isReloading && _fadeCompleted) {
      _fadeCompleted = false;
    }

    if (!isReloading && _fadeCompleted) {
      return const SizedBox.shrink();
    }

    final failed = ref.watch(assetWipeFailedProvider);

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !isReloading,
        child: AnimatedOpacity(
          opacity: isReloading ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 288),
          curve: Curves.easeOutCubic,
          onEnd: () {
            if (mounted && !isReloading && !_fadeCompleted) {
              setState(() => _fadeCompleted = true);
            }
          },
          child: Material(
            color: AppColorStyles.backgroundPrimary,
            child: failed
                ? _ReloadFailure(
                    onRetry: () =>
                        ref.read(assetWipeControllerProvider).retry(),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _ReloadFailure extends StatelessWidget {
  const _ReloadFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacingStyles.space400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Không tải được dữ liệu',
            textAlign: TextAlign.center,
            style: AppTextStyles.headingXSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
          const Gap(AppSpacingStyles.space200),
          Text(
            'Kiểm tra kết nối và thử lại để quay về trang chủ',
            textAlign: TextAlign.center,
            style: AppTextStyles.paragraphSmall(
              color: AppColorStyles.contentSecondary,
            ),
          ),
          const Gap(AppSpacingStyles.space800),
          ShineButton(
            style: ShineButtonStyle.primaryYellow,
            onPressed: onRetry,
            text: I18n.txtRetry,
          ),
        ],
      ),
    );
  }
}
