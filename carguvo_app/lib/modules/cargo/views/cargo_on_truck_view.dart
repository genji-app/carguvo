import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/data/repositories/delivery_point_repository.dart';
import 'package:carguvo/modules/cargo/controllers/cargo_controller.dart';
import 'package:carguvo/widgets/empty_state.dart';

/// Màn hình "Hàng còn trên xe" - feature quan trọng nhất
class CargoOnTruckView extends StatelessWidget {
  const CargoOnTruckView({super.key});

  @override
  Widget build(BuildContext context) {
    final cargoCtrl = Get.find<CargoController>();
    final deliveryRepo = Get.find<DeliveryPointRepository>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Hàng còn trên xe', style: AppTypography.heading3),
        centerTitle: true,
      ),
      body: Obx(() {
        // Rebuild on cargo changes
        Get.find<CargoController>().cargoList.length;

        final grouped = cargoCtrl.getOnTruckGroupedByDeliveryPoint();
        final totalOnTruck = grouped.values.fold<int>(
          0,
          (sum, list) => sum + list.length,
        );

        if (totalOnTruck == 0) {
          return const EmptyState(
            icon: Icons.local_shipping_outlined,
            title: 'Không có hàng trên xe',
            subtitle: 'Tất cả hàng đã được giao hoặc chưa có hàng nào',
          );
        }

        return Column(
          children: [
            // Summary header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingXXL),
              margin: const EdgeInsets.all(AppDimensions.paddingLG),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_shipping,
                    size: 36,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalOnTruck',
                    style: AppTypography.heading1.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                  Text(
                    'kiện còn trên xe',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${grouped.length} điểm giao',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Grouped list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLG,
                ),
                itemCount: grouped.length,
                itemBuilder: (_, index) {
                  final entry = grouped.entries.toList()[index];
                  final dpId = entry.key;
                  final cargos = entry.value;
                  final dp = dpId != 'unknown'
                      ? deliveryRepo.getById(dpId)
                      : null;
                  final dpName = dp?.receiverName ?? 'Chưa gán điểm giao';
                  final dpAddress = dp?.address ?? '';

                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: AppDimensions.paddingMD,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMD,
                      ),
                      border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Point header
                        Container(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingLG,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppDimensions.radiusMD),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dpName,
                                      style: AppTypography.labelLarge,
                                    ),
                                    if (dpAddress.isNotEmpty)
                                      Text(
                                        dpAddress,
                                        style: AppTypography.bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  '${cargos.length} kiện',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Cargo items
                        ...cargos.map((cargo) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingLG,
                              vertical: AppDimensions.paddingSM,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '#${cargo.cargoCode}',
                                            style: AppTypography.labelSmall
                                                .copyWith(
                                                  color: AppColors.secondary,
                                                ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              cargo.cargoName,
                                              style: AppTypography.labelMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'SL: ${cargo.quantity}',
                                        style: AppTypography.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                // Quick action buttons
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _actionButton(
                                      icon: Icons.check_circle,
                                      color: AppColors.success,
                                      tooltip: 'Đã giao',
                                      onTap: () => cargoCtrl.updateCargoStatus(
                                        cargo.id,
                                        CargoStatus.delivered,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    _actionButton(
                                      icon: Icons.error,
                                      color: AppColors.error,
                                      tooltip: 'Giao lỗi',
                                      onTap: () => cargoCtrl.updateCargoStatus(
                                        cargo.id,
                                        CargoStatus.failed,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
