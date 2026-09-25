import 'package:get/get.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/core/utils/id_generator.dart';
import 'package:carguvo/data/models/trip_model.dart';
import 'package:carguvo/data/repositories/trip_repository.dart';
import 'package:carguvo/data/repositories/cargo_repository.dart';
import 'package:carguvo/data/repositories/delivery_point_repository.dart';
import 'package:carguvo/data/repositories/timeline_repository.dart';
import 'package:carguvo/modules/dashboard/controllers/dashboard_controller.dart';

class TripController extends GetxController {
  final _tripRepo = Get.find<TripRepository>();
  final _cargoRepo = Get.find<CargoRepository>();
  final _deliveryRepo = Get.find<DeliveryPointRepository>();
  final _timelineRepo = Get.find<TimelineRepository>();

  // Observable state
  final trips = <TripModel>[].obs;
  final searchQuery = ''.obs;
  final selectedFilter = (-1).obs; // -1 = all

  @override
  void onInit() {
    super.onInit();
    loadTrips();
  }

  void loadTrips() {
    trips.value = _tripRepo.getAll();
  }

  List<TripModel> get filteredTrips {
    var list = trips.toList();

    // Filter by status
    if (selectedFilter.value >= 0) {
      list = list.where((t) => t.statusIndex == selectedFilter.value).toList();
    }

    // Filter by search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list
          .where(
            (t) =>
                t.code.toLowerCase().contains(query) ||
                t.note.toLowerCase().contains(query),
          )
          .toList();
    }

    return list;
  }

  void setFilter(int index) {
    selectedFilter.value = index;
  }

  void setSearch(String query) {
    searchQuery.value = query;
  }

  /// Tạo chuyến mới
  Future<void> createTrip({required String code, String note = ''}) async {
    final trip = TripModel(
      id: IdGenerator.generate(),
      code: code,
      note: note,
      createdAt: DateTime.now(),
      statusIndex: TripStatus.active.index,
    );

    await _tripRepo.add(trip);
    loadTrips();
    _refreshDashboard();
    Get.back();
    Get.snackbar('Thành công', 'Đã tạo chuyến #$code');
  }

  /// Cập nhật chuyến
  Future<void> updateTrip(
    String id, {
    required String code,
    String note = '',
  }) async {
    final trip = _tripRepo.getById(id);
    if (trip != null) {
      trip.code = code;
      trip.note = note;
      await _tripRepo.update(trip);
      loadTrips();
      _refreshDashboard();
      Get.back();
      Get.snackbar('Thành công', 'Đã cập nhật chuyến #$code');
    }
  }

  /// Cập nhật trạng thái chuyến
  Future<void> updateTripStatus(String tripId, TripStatus status) async {
    final trip = _tripRepo.getById(tripId);
    if (trip != null) {
      trip.status = status;
      await _tripRepo.update(trip);
      loadTrips();
      _refreshDashboard();
    }
  }

  /// Xóa chuyến và dữ liệu liên quan
  Future<void> deleteTrip(String tripId) async {
    await _cargoRepo.deleteByTripId(tripId);
    await _deliveryRepo.deleteByTripId(tripId);
    await _timelineRepo.deleteByTripId(tripId);
    await _tripRepo.delete(tripId);
    loadTrips();
    _refreshDashboard();
    Get.snackbar('Đã xóa', 'Chuyến xe đã được xóa');
  }

  /// Helper: get trip cargo stats
  int getTotalCargo(String tripId) => _cargoRepo.countByTripId(tripId);
  int getDeliveredCargo(String tripId) =>
      _cargoRepo.countDeliveredByTripId(tripId);
  int getRemainingPoints(String tripId) =>
      _deliveryRepo.countPendingByTripId(tripId);

  double getTripProgress(String tripId) {
    final total = getTotalCargo(tripId);
    if (total == 0) return 0.0;
    return getDeliveredCargo(tripId) / total;
  }

  void refreshData() {
    loadTrips();
    _refreshDashboard();
  }

  void _refreshDashboard() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().refreshData();
    }
  }
}
