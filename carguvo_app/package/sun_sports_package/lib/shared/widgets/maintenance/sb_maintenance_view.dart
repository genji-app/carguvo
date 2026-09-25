import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/maintenance/maintenance_service.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class SbMaintenancePanel extends StatelessWidget {
  const SbMaintenancePanel({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColorStyles.backgroundPrimary,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: InnerShadowCard(
            borderRadius: 16,
            color: AppColorStyles.backgroundSecondary,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundSecondary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColorStyles.backgroundTertiary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.engineering_rounded,
                        color: AppColors.yellow300,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Thông báo',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.textStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message ?? MaintenanceService.defaultMessage,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.textStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColorStyles.contentSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class SbMaintenanceInline extends StatelessWidget {
  const SbMaintenanceInline({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        MaintenanceService.shortMessage,
        textAlign: TextAlign.center,
        style: AppTextStyles.paragraphSmall(
          color: AppColorStyles.contentTertiary,
        ),
      ),
    ),
  );
}

void showSbMaintenanceToast(BuildContext context) {
  AppToast.showGeneric(context, message: MaintenanceService.shortMessage);
}

bool blockedBySbMaintenance(BuildContext context, WidgetRef ref) {
  if (!ref.read(sbMaintenanceProvider)) return false;
  showSbMaintenanceToast(context);
  return true;
}
