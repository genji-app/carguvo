import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/core/helpers/status_helper.dart';
import 'package:carguvo/data/models/cargo_model.dart';
import 'package:carguvo/data/models/delivery_point_model.dart';
import 'package:carguvo/data/repositories/cargo_repository.dart';
import 'package:carguvo/data/repositories/delivery_point_repository.dart';
import 'package:carguvo/modules/cargo/controllers/cargo_controller.dart';
import 'package:carguvo/routes/app_routes.dart';
import 'package:carguvo/widgets/app_card.dart';
import 'package:carguvo/widgets/status_badge.dart';

class CargoDetailView extends StatelessWidget {
  const CargoDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final cargoId = Get.arguments as String;
    final cargoRepo = Get.find<CargoRepository>();
    final deliveryRepo = Get.find<DeliveryPointRepository>();
    final cargoCtrl = Get.find<CargoController>();

    return Obx(() {
      // Watch for changes
      cargoCtrl.cargoList.length;
      final cargo = cargoRepo.getById(cargoId);
      if (cargo == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Hàng hóa')),
          body: const Center(child: Text('Không tìm thấy hàng hóa')),
        );
      }

      final dp = deliveryRepo.getById(cargo.deliveryPointId);

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('#${cargo.cargoCode}', style: AppTypography.heading3),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  Get.toNamed(AppRoutes.editCargo, arguments: cargoId),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDelete(cargoId),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(cargo),
              const SizedBox(height: AppDimensions.paddingLG),
              _itemInfo('Tên hàng', cargo.cargoName),
              _itemInfo(
                'Loại hàng',
                cargo.cargoType.isEmpty ? 'N/A' : cargo.cargoType,
              ),
              _itemInfo('Số lượng', '${cargo.quantity} kiện'),
              const SizedBox(height: AppDimensions.paddingLG),
              _buildDeliveryInfo(dp),
              const SizedBox(height: AppDimensions.paddingLG),
              _itemInfo(
                'Ghi chú',
                cargo.note.isEmpty ? 'Không có ghi chú' : cargo.note,
              ),
              const SizedBox(height: 32),
              _buildStatusActions(cargoId, cargo.status, cargoCtrl),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(CargoModel cargo) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trạng thái hiện tại', style: AppTypography.caption),
                const SizedBox(height: 4),
                StatusBadge(
                  label: StatusHelper.cargoStatusLabel(cargo.status),
                  color: StatusHelper.cargoStatusColor(cargo.status),
                  icon: StatusHelper.cargoStatusIcon(cargo.status),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(DeliveryPointModel? dp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thông tin giao hàng', style: AppTypography.labelLarge),
        const SizedBox(height: 8),
        InkWell(
          onTap: dp == null
              ? null
              : () => Get.toNamed(
                  AppRoutes.deliveryPointDetail,
                  arguments: dp.id,
                ),
          child: AppCard(
            child: dp == null
                ? const Text('Chưa có thông tin điểm giao')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dp.receiverName, style: AppTypography.labelMedium),
                      const SizedBox(height: 4),
                      Text(dp.address, style: AppTypography.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        dp.phone,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusActions(
    String cargoId,
    CargoStatus currentStatus,
    CargoController ctrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cập nhật trạng thái nhanh', style: AppTypography.labelLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CargoStatus.values.map((status) {
            final isSelected = currentStatus == status;
            return InkWell(
              onTap: () => ctrl.updateCargoStatus(cargoId, status),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  StatusHelper.cargoStatusLabel(status),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _confirmDelete(String cargoId) {
    Get.defaultDialog(
      title: 'Xóa hàng hóa?',
      middleText: 'Hành động này không thể hoàn tác.',
      textCancel: 'Hủy',
      textConfirm: 'Xóa',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        Get.find<CargoController>().deleteCargo(cargoId);
        Get.back();
      },
    );
  }
}
