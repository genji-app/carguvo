/// Trạng thái chuyến xe
enum TripStatus {
  active, // Đang chạy
  completed, // Hoàn thành
  paused, // Tạm dừng
}

/// Trạng thái hàng hóa
enum CargoStatus {
  pending, // Chưa lên xe
  loaded, // Đã lên xe
  delivered, // Đã giao
  failed, // Giao lỗi
  returned, // Hoàn hàng
}

/// Trạng thái điểm giao
enum DeliveryStatus {
  pending, // Chưa giao
  inProgress, // Đang giao
  completed, // Hoàn thành
}

/// Hành động timeline
enum TimelineAction {
  created, // Tạo kiện
  loaded, // Đã lên xe
  delivered, // Đã giao
  failed, // Giao lỗi
  returned, // Hoàn hàng
  updated, // Cập nhật
}

// ── Extension helpers ──
// Note: Labels moved to StatusHelper to avoid runtime resolution issues.
