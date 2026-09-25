import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/core/helpers/status_helper.dart';
import 'package:carguvo/data/repositories/delivery_point_repository.dart';
import 'package:carguvo/modules/cargo/controllers/cargo_controller.dart';
import 'package:carguvo/routes/app_routes.dart';
import 'package:carguvo/widgets/app_card.dart';
import 'package:carguvo/widgets/status_badge.dart';
import 'package:carguvo/widgets/empty_state.dart';

class CargoListView extends GetView<CargoController> {
  const CargoListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(child: _buildCargoList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_cargo',
        onPressed: () => Get.toNamed(AppRoutes.addCargo),
        icon: const Icon(Icons.add),
        label: const Text('Thêm hàng'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                style: AppTypography.heading3.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLG),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quản lý hàng hóa', style: AppTypography.heading2),
                  Text(
                    'Danh sách cần xử lý hôm nay',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
              // Swipe hint
              Row(
                children: [
                  Icon(Icons.swipe, size: 16, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text('Vuốt', style: AppTypography.caption),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Tất cả', 'Còn trên xe', 'Đã giao', 'Giao lỗi'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMD),
      child: SizedBox(
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
              final isSelected = controller.selectedFilter.value == index;
              return ChoiceChip(
                label: Text(filters[index]),
                selected: isSelected,
                onSelected: (_) => controller.setFilter(index),
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
      ),
    );
  }

  Widget _buildCargoList() {
    return Obx(() {
      controller.cargoList.length; // Explicit dependency
      controller.selectedFilter.value; // Explicit dependency
      final cargos = controller.filteredCargos;

      if (cargos.isEmpty) {
        return EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Chưa có hàng hóa',
          subtitle: 'Thêm hàng hóa để bắt đầu quản lý',
          actionLabel: 'Thêm hàng',
          onAction: () => Get.toNamed(AppRoutes.addCargo),
        );
      }

      final deliveryRepo = Get.find<DeliveryPointRepository>();

      return ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        itemCount: cargos.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.paddingSM),
        itemBuilder: (context, index) {
          final cargo = cargos[index];
          final dp = deliveryRepo.getById(cargo.deliveryPointId);

          return Dismissible(
            key: Key(cargo.id),
            background: _swipeBackground(
              color: AppColors.success,
              icon: Icons.check_circle,
              label: 'Đã giao',
              alignment: Alignment.centerLeft,
            ),
            secondaryBackground: _swipeBackground(
              color: AppColors.error,
              icon: Icons.error,
              label: 'Giao lỗi',
              alignment: Alignment.centerRight,
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // Swipe right → delivered
                await controller.updateCargoStatus(
                  cargo.id,
                  CargoStatus.delivered,
                );
                return false;
              } else {
                // Swipe left → show options
                final result = await Get.bottomSheet<CargoStatus>(
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingXXL),
                    decoration: const BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.radiusLG),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Cập nhật trạng thái',
                          style: AppTypography.heading3,
                        ),
                        const SizedBox(height: AppDimensions.paddingLG),
                        _statusOption(
                          CargoStatus.failed,
                          'Giao lỗi',
                          Icons.error_outline,
                          AppColors.error,
                        ),
                        _statusOption(
                          CargoStatus.returned,
                          'Hoàn hàng',
                          Icons.undo,
                          AppColors.warning,
                        ),
                        _statusOption(
                          CargoStatus.loaded,
                          'Trên xe',
                          Icons.local_shipping,
                          AppColors.statusLoaded,
                        ),
                        _statusOption(
                          CargoStatus.pending,
                          'Chưa lên xe',
                          Icons.inventory_2_outlined,
                          AppColors.statusPending,
                        ),
                      ],
                    ),
                  ),
                );
                if (result != null) {
                  await controller.updateCargoStatus(cargo.id, result);
                }
                return false;
              }
            },
            child: AppCard(
              onTap: () =>
                  Get.toNamed(AppRoutes.cargoDetail, arguments: cargo.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${cargo.cargoCode}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      StatusBadge(
                        label: StatusHelper.cargoStatusLabel(cargo.status),
                        color: StatusHelper.cargoStatusColor(cargo.status),
                        icon: StatusHelper.cargoStatusIcon(cargo.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(cargo.cargoName, style: AppTypography.heading3),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text('SỐ LƯỢNG', style: AppTypography.caption),
                      const SizedBox(width: 4),
                      Text(
                        '${cargo.quantity}',
                        style: AppTypography.labelMedium,
                      ),
                      const SizedBox(width: 16),
                      if (dp != null) ...[
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text('ĐIỂM GIAO', style: AppTypography.caption),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dp.address.isNotEmpty
                                ? dp.address
                                : dp.receiverName,
                            style: AppTypography.labelMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _swipeBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.button),
        ],
      ),
    );
  }

  Widget _statusOption(
    CargoStatus status,
    String label,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      onTap: () => Get.back(result: status),
    );
  }
}
