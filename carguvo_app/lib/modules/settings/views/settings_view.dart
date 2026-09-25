import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/modules/settings/controllers/settings_controller.dart';
import 'package:carguvo/widgets/app_card.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Cài đặt', style: AppTypography.heading3),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        children: [
          _buildInfoSection(),
          const SizedBox(height: AppDimensions.paddingLG),
          _buildDangerSection(),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thông tin ứng dụng', style: AppTypography.labelLarge),
          const SizedBox(height: 16),
          _settingItem(Icons.info_outline, 'Phiên bản', '1.0.0'),
        ],
      ),
    );
  }

  Widget _buildDangerSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vùng nguy hiểm',
            style: AppTypography.labelLarge.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.delete_forever_outlined,
              color: AppColors.error,
            ),
            title: const Text('Xóa toàn bộ dữ liệu'),
            subtitle: const Text('Hành động này không thể hoàn tác'),
            onTap: () => _confirmClearData(),
          ),
        ],
      ),
    );
  }

  Widget _settingItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(title, style: AppTypography.bodyMedium),
          const Spacer(),
          if (value.isNotEmpty)
            Text(value, style: AppTypography.bodySmall)
          else
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textHint,
            ),
        ],
      ),
    );
  }

  // Widget _divider() => Divider(color: AppColors.divider.withValues(alpha: 0.5));

  void _confirmClearData() {
    Get.defaultDialog(
      title: 'Xóa dữ liệu?',
      middleText: 'Toàn bộ thông tin chuyến xe và hàng hóa sẽ bị xóa sạch.',
      textCancel: 'Hủy',
      textConfirm: 'Xác nhận xóa',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        controller.clearData();
        Get.back();
      },
    );
  }
}
