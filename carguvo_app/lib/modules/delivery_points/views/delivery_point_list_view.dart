import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/core/helpers/status_helper.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/data/repositories/cargo_repository.dart';
import 'package:carguvo/modules/cargo/controllers/cargo_controller.dart';
import 'package:carguvo/modules/delivery_points/controllers/delivery_point_controller.dart';
import 'package:carguvo/routes/app_routes.dart';
import 'package:carguvo/widgets/app_card.dart';
import 'package:carguvo/widgets/status_badge.dart';
import 'package:carguvo/widgets/empty_state.dart';

class DeliveryPointListView extends GetView<DeliveryPointController> {
  const DeliveryPointListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Điểm giao hàng', style: AppTypography.heading3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          controller.deliveryPoints.length; // Explicit dependency
          Get.find<CargoController>()
              .cargoList
              .length; // Extra dependency for safety
          final points = controller.deliveryPoints;

          if (points.isEmpty) {
            return EmptyState(
              icon: Icons.location_on_outlined,
              title: 'Chưa có điểm giao',
              subtitle: 'Thêm điểm giao để quản lý lộ trình dễ dàng hơn',
              actionLabel: 'Thêm điểm giao',
              onAction: () => Get.toNamed(AppRoutes.addDeliveryPoint),
            );
          }

          final cargoRepo = Get.find<CargoRepository>();

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            itemCount: points.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.paddingMD),
            itemBuilder: (context, index) {
              final point = points[index];
              final cargos = cargoRepo.getByDeliveryPointId(point.id);
              final deliveredCount = cargos
                  .where((c) => c.status == CargoStatus.delivered)
                  .length;

              return AppCard(
                onTap: () => Get.toNamed(
                  AppRoutes.deliveryPointDetail,
                  arguments: point.id,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  point.receiverName,
                                  style: AppTypography.labelLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: StatusHelper.deliveryStatusLabel(point.status),
                          color: StatusHelper.deliveryStatusColor(point.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (point.phone.isNotEmpty)
                      _infoRow(Icons.phone_outlined, point.phone),
                    if (point.address.isNotEmpty)
                      _infoRow(Icons.business_outlined, point.address),
                    const SizedBox(height: 12),
                    Divider(color: AppColors.divider.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng: ${cargos.length} kiện',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Đã giao: $deliveredCount kiện',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_delivery_points',
        onPressed: () => Get.toNamed(AppRoutes.addDeliveryPoint),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Thêm điểm'),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textHint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
