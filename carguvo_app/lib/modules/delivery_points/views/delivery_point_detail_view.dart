import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/core/helpers/status_helper.dart';
import 'package:carguvo/data/models/cargo_model.dart';
import 'package:carguvo/data/models/delivery_point_model.dart';
import 'package:carguvo/data/repositories/delivery_point_repository.dart';
import 'package:carguvo/data/repositories/cargo_repository.dart';
import 'package:carguvo/modules/delivery_points/controllers/delivery_point_controller.dart';
import 'package:carguvo/routes/app_routes.dart';
import 'package:carguvo/widgets/app_card.dart';
import 'package:carguvo/widgets/status_badge.dart';

class DeliveryPointDetailView extends StatelessWidget {
  const DeliveryPointDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final dpId = Get.arguments as String;
    final dpRepo = Get.find<DeliveryPointRepository>();
    final cargoRepo = Get.find<CargoRepository>();
    final dpCtrl = Get.find<DeliveryPointController>();

    return Obx(() {
      dpCtrl.deliveryPoints.length;
      final dp = dpRepo.getById(dpId);
      if (dp == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Điểm giao')),
          body: const Center(child: Text('Không tìm thấy điểm giao')),
        );
      }

      final cargos = cargoRepo.getByDeliveryPointId(dpId);

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(dp.receiverName, style: AppTypography.heading3),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  Get.toNamed(AppRoutes.editDeliveryPoint, arguments: dpId),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDelete(dpId),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(dp),
              const SizedBox(height: AppDimensions.paddingLG),
              _infoRow(Icons.phone, 'Số điện thoại', dp.phone, isPhone: true),
              _infoRow(Icons.business, 'Địa chỉ', dp.address),
              _infoRow(
                Icons.note,
                'Ghi chú',
                dp.note.isEmpty ? 'Không có ghi chú' : dp.note,
              ),
              const SizedBox(height: 24),
              Text(
                'Hàng hóa tại điểm này (${cargos.length})',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: 12),
              ...cargos.map((cargo) => _buildCargoItem(cargo)),
              const SizedBox(height: 32),
              _buildStatusActions(dpId, dp.status, dpCtrl),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(DeliveryPointModel dp) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trạng thái điểm giao', style: AppTypography.caption),
                const SizedBox(height: 4),
                StatusBadge(
                  label: StatusHelper.deliveryStatusLabel(dp.status),
                  color: StatusHelper.deliveryStatusColor(dp.status),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textHint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isPhone ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCargoItem(CargoModel cargo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.cargoDetail, arguments: cargo.id),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: AppColors.textHint,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(cargo.cargoName, style: AppTypography.bodyMedium),
              ),
              StatusBadge(
                label: StatusHelper.cargoStatusLabel(cargo.status),
                color: StatusHelper.cargoStatusColor(cargo.status),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusActions(
    String id,
    DeliveryStatus currentStatus,
    DeliveryPointController ctrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cập nhật trạng thái điểm giao', style: AppTypography.labelLarge),
        const SizedBox(height: 12),
        Row(
          children: DeliveryStatus.values.map((status) {
            final isSelected = currentStatus == status;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => ctrl.updateStatus(id, status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      StatusHelper.deliveryStatusLabel(status),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _confirmDelete(String id) {
    Get.defaultDialog(
      title: 'Xóa điểm giao?',
      middleText: 'Hành động này không thể hoàn tác.',
      textCancel: 'Hủy',
      textConfirm: 'Xóa',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        Get.find<DeliveryPointController>().deleteDeliveryPoint(id);
        Get.back();
      },
    );
  }
}
