import 'package:hive/hive.dart';
import 'package:carguvo/data/local/hive_service.dart';
import 'package:carguvo/data/models/timeline_model.dart';

class TimelineRepository {
  Box<TimelineModel> get _box => HiveService.timelineBox;

  /// Lấy tất cả timeline, mới nhất trước
  List<TimelineModel> getAll() {
    final items = _box.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  /// Lấy timeline theo chuyến
  List<TimelineModel> getByTripId(String tripId) {
    final items = _box.values.where((t) => t.tripId == tripId).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  /// Lấy timeline theo hàng hóa
  List<TimelineModel> getByCargoId(String cargoId) {
    final items = _box.values.where((t) => t.cargoId == cargoId).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  /// Thêm event
  Future<void> add(TimelineModel event) async {
    await _box.put(event.id, event);
  }

  /// Xóa theo chuyến
  Future<void> deleteByTripId(String tripId) async {
    final keys = _box.keys.where((key) {
      final item = _box.get(key);
      return item?.tripId == tripId;
    }).toList();
    await _box.deleteAll(keys);
  }
}
