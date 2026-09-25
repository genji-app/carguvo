import 'package:hive/hive.dart';
import 'package:carguvo/data/local/hive_service.dart';
import 'package:carguvo/data/models/cargo_model.dart';
import 'package:carguvo/core/enums/enums.dart';

class CargoRepository {
  Box<CargoModel> get _box => HiveService.cargoBox;

  /// Lấy tất cả hàng hóa, mới nhất trước
  List<CargoModel> getAll() {
    final cargos = _box.values.toList();
    cargos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return cargos;
  }

  /// Lấy hàng hóa theo ID
  CargoModel? getById(String id) {
    try {
      return _box.values.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Lấy danh sách hàng theo chuyến
  List<CargoModel> getByTripId(String tripId) {
    return _box.values.where((c) => c.tripId == tripId).toList();
  }

  /// Lấy danh sách hàng theo điểm giao
  List<CargoModel> getByDeliveryPointId(String deliveryPointId) {
    return _box.values
        .where((c) => c.deliveryPointId == deliveryPointId)
        .toList();
  }

  /// Lấy hàng còn trên xe (status = loaded)
  List<CargoModel> getOnTruck() {
    return _box.values.where((c) => c.status == CargoStatus.loaded).toList();
  }

  /// Lấy hàng còn trên xe theo chuyến
  List<CargoModel> getOnTruckByTrip(String tripId) {
    return _box.values
        .where((c) => c.tripId == tripId && c.status == CargoStatus.loaded)
        .toList();
  }

  /// Tổng hàng đã giao
  int get totalDelivered {
    return _box.values.where((c) => c.status == CargoStatus.delivered).length;
  }

  /// Tổng hàng còn trên xe
  int get totalOnTruck {
    return _box.values.where((c) => c.status == CargoStatus.loaded).length;
  }

  /// Thêm hàng
  Future<void> add(CargoModel cargo) async {
    await _box.put(cargo.id, cargo);
  }

  /// Cập nhật hàng
  Future<void> update(CargoModel cargo) async {
    await _box.put(cargo.id, cargo);
  }

  /// Xóa hàng
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Xóa tất cả hàng theo chuyến
  Future<void> deleteByTripId(String tripId) async {
    final keys = _box.keys.where((key) {
      final cargo = _box.get(key);
      return cargo?.tripId == tripId;
    }).toList();
    await _box.deleteAll(keys);
  }

  /// Đếm hàng theo chuyến
  int countByTripId(String tripId) {
    return _box.values.where((c) => c.tripId == tripId).length;
  }

  /// Đếm hàng đã giao theo chuyến
  int countDeliveredByTripId(String tripId) {
    return _box.values
        .where((c) => c.tripId == tripId && c.status == CargoStatus.delivered)
        .length;
  }
}
