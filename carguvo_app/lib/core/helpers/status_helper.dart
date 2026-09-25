import 'package:flutter/material.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/core/theme/app_colors.dart';

class StatusHelper {
  StatusHelper._();

  // ── Cargo Status ──

  static Color cargoStatusColor(CargoStatus status) {
    switch (status) {
      case CargoStatus.pending:
        return AppColors.statusPending;
      case CargoStatus.loaded:
        return AppColors.statusLoaded;
      case CargoStatus.delivered:
        return AppColors.statusDelivered;
      case CargoStatus.failed:
        return AppColors.statusFailed;
      case CargoStatus.returned:
        return AppColors.statusReturned;
    }
  }

  static Color cargoStatusBgColor(CargoStatus status) {
    switch (status) {
      case CargoStatus.pending:
        return AppColors.statusPending.withValues(alpha: 0.1);
      case CargoStatus.loaded:
        return AppColors.statusLoaded.withValues(alpha: 0.1);
      case CargoStatus.delivered:
        return AppColors.successLight;
      case CargoStatus.failed:
        return AppColors.errorLight;
      case CargoStatus.returned:
        return AppColors.warningLight;
    }
  }

  static IconData cargoStatusIcon(CargoStatus status) {
    switch (status) {
      case CargoStatus.pending:
        return Icons.inventory_2_outlined;
      case CargoStatus.loaded:
        return Icons.local_shipping_outlined;
      case CargoStatus.delivered:
        return Icons.check_circle_outline;
      case CargoStatus.failed:
        return Icons.error_outline;
      case CargoStatus.returned:
        return Icons.undo_outlined;
    }
  }

  // ── Trip Status ──

  static Color tripStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.active:
        return AppColors.primary;
      case TripStatus.completed:
        return AppColors.success;
      case TripStatus.paused:
        return AppColors.textHint;
    }
  }

  static Color tripStatusBgColor(TripStatus status) {
    switch (status) {
      case TripStatus.active:
        return AppColors.primaryLight;
      case TripStatus.completed:
        return AppColors.successLight;
      case TripStatus.paused:
        return AppColors.statusPending.withValues(alpha: 0.1);
    }
  }

  static IconData tripStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.active:
        return Icons.local_shipping;
      case TripStatus.completed:
        return Icons.check_circle;
      case TripStatus.paused:
        return Icons.pause_circle_filled;
    }
  }

  // ── Delivery Status ──

  static Color deliveryStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return AppColors.statusPending;
      case DeliveryStatus.inProgress:
        return AppColors.primary;
      case DeliveryStatus.completed:
        return AppColors.success;
    }
  }

  static Color deliveryStatusBgColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return AppColors.statusPending.withValues(alpha: 0.1);
      case DeliveryStatus.inProgress:
        return AppColors.primaryLight;
      case DeliveryStatus.completed:
        return AppColors.successLight;
    }
  }

  // ── Timeline Action ──

  static IconData timelineActionIcon(TimelineAction action) {
    switch (action) {
      case TimelineAction.created:
        return Icons.add_box_outlined;
      case TimelineAction.loaded:
        return Icons.local_shipping_outlined;
      case TimelineAction.delivered:
        return Icons.check_circle_outline;
      case TimelineAction.failed:
        return Icons.error_outline;
      case TimelineAction.returned:
        return Icons.keyboard_return;
      case TimelineAction.updated:
        return Icons.edit_note;
    }
  }

  static Color timelineActionColor(TimelineAction action) {
    switch (action) {
      case TimelineAction.created:
        return AppColors.primary;
      case TimelineAction.loaded:
        return AppColors.secondary;
      case TimelineAction.delivered:
        return AppColors.success;
      case TimelineAction.failed:
        return AppColors.error;
      case TimelineAction.returned:
        return AppColors.warning;
      case TimelineAction.updated:
        return AppColors.info;
    }
  }

  static String timelineActionLabel(TimelineAction action) {
    switch (action) {
      case TimelineAction.created:
        return 'Tạo kiện';
      case TimelineAction.loaded:
        return 'Đã lên xe';
      case TimelineAction.delivered:
        return 'Đã giao';
      case TimelineAction.failed:
        return 'Giao lỗi';
      case TimelineAction.returned:
        return 'Hoàn hàng';
      case TimelineAction.updated:
        return 'Cập nhật';
    }
  }

  static String cargoStatusLabel(CargoStatus status) {
    switch (status) {
      case CargoStatus.pending:
        return 'Chưa lên xe';
      case CargoStatus.loaded:
        return 'Đã lên xe';
      case CargoStatus.delivered:
        return 'Đã giao';
      case CargoStatus.failed:
        return 'Giao lỗi';
      case CargoStatus.returned:
        return 'Hoàn hàng';
    }
  }

  static String tripStatusLabel(TripStatus status) {
    switch (status) {
      case TripStatus.active:
        return 'Đang chạy';
      case TripStatus.completed:
        return 'Hoàn thành';
      case TripStatus.paused:
        return 'Tạm dừng';
    }
  }

  static String deliveryStatusLabel(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'Chưa giao';
      case DeliveryStatus.inProgress:
        return 'Đang giao';
      case DeliveryStatus.completed:
        return 'Hoàn thành';
    }
  }
}
