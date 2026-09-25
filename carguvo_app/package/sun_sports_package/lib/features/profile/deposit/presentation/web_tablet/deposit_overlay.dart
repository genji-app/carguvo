import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_overlay_provider.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_overlay_provider.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/deposit_payment_methods_grid_web.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/deposit_payment_method_container_web.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/deposit_header.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DepositOverlay extends ConsumerWidget {
  const DepositOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<bool>(depositOverlayVisibleProvider, (previous, next) {
      if (next) {
        ref.read(withdrawOverlayVisibleProvider.notifier).state = false;
      }
      if (next) {
        pushLivestreamOverlayBlock();
      } else {
        popLivestreamOverlayBlock();
      }
    });

    final isVisible = ref.watch(depositOverlayVisibleProvider);
    final selectedMethod = ref.watch(
      depositSelectionProvider.select((state) => state.selectedMethod),
    );

    if (isVisible && selectedMethod == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(depositSelectionProvider.notifier)
            .selectPaymentMethod(PaymentMethod.codepay);
      });
    }

    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: SoundTap.wrap(() {
              ref.read(depositOverlayVisibleProvider.notifier).state = false;
            }),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        Center(
          child: Material(
            elevation: 24,
            color: Colors.transparent,
            child: Container(
              width: 640,
              height: 823,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundSecondary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.75),
                    offset: const Offset(-20, 4),
                    blurRadius: 200,
                  ),
                  BoxShadow(
                    offset: const Offset(0, 0.5),
                    blurRadius: 0.5,
                    spreadRadius: 0,
                    blurStyle: BlurStyle.inner,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ],
                border: Border.all(color: AppColors.gray700, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DepositHeader(
                    onClose: () {
                      ref.read(depositOverlayVisibleProvider.notifier).state =
                          false;
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const DepositPaymentMethodsGridWeb(),
                          const SizedBox(height: 40),
                          Expanded(child: DepositPaymentMethodContainerWeb()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
