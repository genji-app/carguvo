import 'package:hive/hive.dart';
import 'package:carguvo/data/local/hive_service.dart';
import 'package:carguvo/data/models/trip_model.dart';

class TripRepository {
  Box<TripModel> get _box => HiveService.tripBox;

  /// Lấy tất cả chuyến, sắp xếp theo ngày tạo mới nhất
  List<TripModel> getAll() {
    final trips = _box.values.toList();
    trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return trips;
  }

  /// Lấy chuyến theo ID
  TripModel? getById(String id) {
    try {
      return _box.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Tạo chuyến mới
  Future<void> add(TripModel trip) async {
    await _box.put(trip.id, trip);
  }

  /// Cập nhật chuyến
  Future<void> update(TripModel trip) async {
    await _box.put(trip.id, trip);
  }

  /// Xóa chuyến
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Đếm tổng chuyến
  int get totalCount => _box.length;

  /// Lọc theo trạng thái
  List<TripModel> getByStatus(int statusIndex) {
    return _box.values.where((t) => t.statusIndex == statusIndex).toList();
  }
}
