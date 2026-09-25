import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/core/extensions/date_extensions.dart';
import 'package:carguvo/core/helpers/status_helper.dart';
import 'package:carguvo/data/repositories/cargo_repository.dart';
import 'package:carguvo/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:carguvo/modules/main/controllers/main_controller.dart';
import 'package:carguvo/routes/app_routes.dart';
import 'package:carguvo/widgets/summary_card.dart';
import 'package:carguvo/widgets/app_card.dart';
import 'package:carguvo/widgets/status_badge.dart';
import 'package:carguvo/widgets/progress_bar.dart';
import 'package:carguvo/widgets/empty_state.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => controller.refreshData(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppDimensions.paddingXXL),
                _buildSummaryCards(),
                const SizedBox(height: AppDimensions.paddingXXL),
                _buildRecentTrips(),
                const SizedBox(height: AppDimensions.paddingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row
        Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(
                  image: AssetImage('assets/images/app_icon.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Carguvo',
              style: AppTypography.heading3.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingLG),
        Text(now.formattedFull, style: AppTypography.bodySmall),
        const SizedBox(height: 4),
        Text('Xin chào, Tài xế 👋', style: AppTypography.heading1),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      // Force dependency registration
      controller.totalTrips.value;
      controller.cargoOnTruck.value;
      controller.totalDelivered.value;
      controller.remainingPoints.value;

      return GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.paddingMD,
        crossAxisSpacing: AppDimensions.paddingMD,
        childAspectRatio: 1.5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SummaryCard(
            title: 'Tổng chuyến',
            value: '${controller.totalTrips.value}',
            unit: '',
            icon: Icons.local_shipping_outlined,
            color: AppColors.secondary,
          ),
          SummaryCard(
            title: 'Hàng trên xe',
            value: '${controller.cargoOnTruck.value}',
            unit: 'kiện',
            icon: Icons.inventory_2_outlined,
            color: AppColors.primary,
          ),
          SummaryCard(
            title: 'Đã giao',
            value: '${controller.totalDelivered.value}',
            unit: 'kiện',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
          SummaryCard(
            title: 'Điểm còn lại',
            value: '${controller.remainingPoints.value}',
            unit: 'điểm',
            icon: Icons.location_on_outlined,
            color: AppColors.warning,
          ),
        ],
      );
    });
  }

  Widget _buildRecentTrips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Chuyến xe gần đây', style: AppTypography.heading3),
            TextButton(
              onPressed: () {
                final mainCtrl = Get.find<MainController>();
                mainCtrl.changePage(1);
              },
              child: Text(
                'Xem tất cả',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSM),
        Obx(() {
          controller.recentTrips.length; // Explicit dependency
          if (controller.recentTrips.isEmpty) {
            return const EmptyState(
              icon: Icons.local_shipping_outlined,
              title: 'Chưa có chuyến xe',
              subtitle: 'Tạo chuyến xe đầu tiên để bắt đầu',
            );
          }

          return Column(
            children: controller.recentTrips.map((trip) {
              final cargoRepo = Get.find<CargoRepository>();
              final total = cargoRepo.countByTripId(trip.id);
              final delivered = cargoRepo.countDeliveredByTripId(trip.id);
              final progress = total > 0 ? delivered / total : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
                child: AppCard(
                  onTap: () =>
                      Get.toNamed(AppRoutes.tripDetail, arguments: trip.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${trip.code}',
                            style: AppTypography.labelLarge,
                          ),
                          StatusBadge(
                            label: StatusHelper.tripStatusLabel(trip.status),
                            color: StatusHelper.tripStatusColor(trip.status),
                            icon: StatusHelper.tripStatusIcon(trip.status),
                          ),
                        ],
                      ),
                      if (trip.note.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          trip.note,
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppDimensions.paddingMD),
                      AppProgressBar(progress: progress, showLabel: true),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

//   Widget _quickActionCard({
  //     required IconData icon,
  //     required String label,
  //     required VoidCallback onTap,
  //   }) {
  //     return AppCard(
  //       onTap: onTap,
  //       padding: const EdgeInsets.all(AppDimensions.paddingLG),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(10),
  //             decoration: BoxDecoration(
  //               color: AppColors.primaryLight,
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Icon(icon, color: AppColors.primary, size: 24),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             label,
  //             style: AppTypography.labelSmall.copyWith(
  //               color: AppColors.textPrimary,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     );
  //   }
}
