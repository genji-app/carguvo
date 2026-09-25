import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/core/helpers/status_helper.dart';
import 'package:carguvo/core/extensions/date_extensions.dart';
import 'package:carguvo/modules/trips/controllers/trip_controller.dart';
import 'package:carguvo/routes/app_routes.dart';
import 'package:carguvo/widgets/app_card.dart';
import 'package:carguvo/widgets/status_badge.dart';
import 'package:carguvo/widgets/progress_bar.dart';
import 'package:carguvo/widgets/empty_state.dart';

class TripListView extends GetView<TripController> {
  const TripListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(child: _buildTripList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_trips',
        onPressed: () => Get.toNamed(AppRoutes.createTrip),
        icon: const Icon(Icons.add),
        label: const Text('Tạo chuyến'),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingLG,
        AppDimensions.paddingLG,
        AppDimensions.paddingLG,
        0,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: TextField(
        onChanged: controller.setSearch,
        decoration: InputDecoration(
          hintText: 'Tìm mã chuyến...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'Tất cả', 'index': -1},
      {'label': 'Đang chạy', 'index': TripStatus.active.index},
      {'label': 'Hoàn thành', 'index': TripStatus.completed.index},
      {'label': 'Tạm dừng', 'index': TripStatus.paused.index},
    ];

    return SizedBox(
      height: 40,
      child: Obx(() {
        controller.selectedFilter.value; // Explicit dependency
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLG,
          ),
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected =
                controller.selectedFilter.value == filter['index'];
            return ChoiceChip(
              label: Text(filter['label'] as String),
              selected: isSelected,
              onSelected: (_) => controller.setFilter(filter['index'] as int),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              backgroundColor: AppColors.card,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildTripList() {
    return Obx(() {
      controller.trips.length; // Explicit dependency
      final trips = controller.filteredTrips;

      if (trips.isEmpty) {
        return EmptyState(
          icon: Icons.local_shipping_outlined,
          title: 'Chưa có chuyến xe',
          subtitle: 'Tạo chuyến xe đầu tiên để bắt đầu quản lý hàng hóa',
          actionLabel: 'Tạo chuyến',
          onAction: () => Get.toNamed(AppRoutes.createTrip),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        itemCount: trips.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.paddingMD),
        itemBuilder: (context, index) {
          final trip = trips[index];
          final totalCargo = controller.getTotalCargo(trip.id);
          final delivered = controller.getDeliveredCargo(trip.id);
          final remaining = totalCargo - delivered;
          final progress = controller.getTripProgress(trip.id);

          return AppCard(
            onTap: () => Get.toNamed(AppRoutes.tripDetail, arguments: trip.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${trip.code}', style: AppTypography.labelLarge),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ngày tạo: ${trip.createdAt.formatted}',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                    StatusBadge(
                      label: StatusHelper.tripStatusLabel(trip.status),
                      color: StatusHelper.tripStatusColor(trip.status),
                      icon: StatusHelper.tripStatusIcon(trip.status),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingLG),

                // Stats row
                Row(
                  children: [
                    _statChip('Tổng', '$totalCargo', AppColors.secondary),
                    const SizedBox(width: 8),
                    _statChip('Đã giao', '$delivered', AppColors.primary),
                    const SizedBox(width: 8),
                    _statChip('Còn lại', '$remaining', AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingMD),

                // Progress
                AppProgressBar(progress: progress, showLabel: true),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: AppTypography.caption),
            const SizedBox(height: 2),
            Text(value, style: AppTypography.labelLarge.copyWith(color: color)),
            Text('kiện', style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}
