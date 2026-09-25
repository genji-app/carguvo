import 'package:hive/hive.dart';
import 'package:carguvo/data/local/hive_service.dart';
import 'package:carguvo/data/models/delivery_point_model.dart';
import 'package:carguvo/core/enums/enums.dart';

class DeliveryPointRepository {
  Box<DeliveryPointModel> get _box => HiveService.deliveryPointBox;

  /// Lấy tất cả điểm giao
  List<DeliveryPointModel> getAll() {
    return _box.values.toList();
  }

  /// Lấy điểm giao theo ID
  DeliveryPointModel? getById(String id) {
    try {
      return _box.values.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Lấy danh sách điểm giao theo chuyến
  List<DeliveryPointModel> getByTripId(String tripId) {
    return _box.values.where((d) => d.tripId == tripId).toList();
  }

  /// Đếm điểm giao chưa hoàn thành
  int countPendingByTripId(String tripId) {
    return _box.values
        .where(
          (d) => d.tripId == tripId && d.status != DeliveryStatus.completed,
        )
        .length;
  }

  /// Tổng điểm giao chưa hoàn thành (toàn bộ)
  int get totalPending {
    return _box.values
        .where((d) => d.status != DeliveryStatus.completed)
        .length;
  }

  /// Thêm điểm giao
  Future<void> add(DeliveryPointModel point) async {
    await _box.put(point.id, point);
  }

  /// Cập nhật điểm giao
  Future<void> update(DeliveryPointModel point) async {
    await _box.put(point.id, point);
  }

  /// Xóa điểm giao
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Xóa tất cả điểm giao theo chuyến
  Future<void> deleteByTripId(String tripId) async {
    final keys = _box.keys.where((key) {
      final point = _box.get(key);
      return point?.tripId == tripId;
    }).toList();
    await _box.deleteAll(keys);
  }

  /// Đếm điểm giao theo chuyến
  int countByTripId(String tripId) {
    return _box.values.where((d) => d.tripId == tripId).length;
  }

  /// Lấy danh sách khách hàng cũ (duy nhất theo tên, sđt, địa chỉ)
  List<DeliveryPointModel> getUniqueHistoryCustomers() {
    final uniqueCustomers = <String, DeliveryPointModel>{};
    for (var d in _box.values) {
      final key = '${d.receiverName}_${d.phone}_${d.address}';
      if (!uniqueCustomers.containsKey(key)) {
        uniqueCustomers[key] = d;
      }
    }
    return uniqueCustomers.values.toList();
  }
}
