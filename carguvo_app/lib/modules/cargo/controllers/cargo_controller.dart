import 'package:get/get.dart';
import 'package:carguvo/modules/timeline/controllers/timeline_controller.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/core/utils/id_generator.dart';
import 'package:carguvo/data/models/cargo_model.dart';
import 'package:carguvo/data/models/timeline_model.dart';
import 'package:carguvo/data/repositories/cargo_repository.dart';
import 'package:carguvo/data/repositories/delivery_point_repository.dart';
import 'package:carguvo/data/repositories/timeline_repository.dart';
import 'package:carguvo/data/models/delivery_point_model.dart';
import 'package:carguvo/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:carguvo/modules/trips/controllers/trip_controller.dart';

class CargoController extends GetxController {
  final _cargoRepo = Get.find<CargoRepository>();
  final _timelineRepo = Get.find<TimelineRepository>();

  // Observable state
  final cargoList = <CargoModel>[].obs;
  final selectedFilter = 0.obs; // 0=all, 1=on truck, 2=delivered, 3=failed

  @override
  void onInit() {
    super.onInit();
    loadCargos();
  }

  void loadCargos() {
    cargoList.value = _cargoRepo.getAll();
  }

  List<CargoModel> get filteredCargos {
    switch (selectedFilter.value) {
      case 1: // Còn trên xe
        return cargoList.where((c) => c.status == CargoStatus.loaded).toList();
      case 2: // Đã giao
        return cargoList
            .where((c) => c.status == CargoStatus.delivered)
            .toList();
      case 3: // Giao lỗi
        return cargoList
            .where(
              (c) =>
                  c.status == CargoStatus.failed ||
                  c.status == CargoStatus.returned,
            )
            .toList();
      default: // Tất cả
        return cargoList.toList();
    }
  }

  void setFilter(int index) {
    selectedFilter.value = index;
  }

  /// Thêm hàng hóa mới
  Future<void> addCargo({
    required String tripId,
    required String cargoCode,
    required String cargoName,
    String cargoType = '',
    int quantity = 1,
    String? deliveryPointId,
    String? receiverName,
    String? phone,
    String? address,
    String note = '',
    CargoStatus initialStatus = CargoStatus.pending,
  }) async {
    String finalDpId = deliveryPointId ?? '';

    // If no ID but has info, create new DP for this trip
    if (finalDpId.isEmpty && receiverName != null && receiverName.isNotEmpty) {
      final dpRepo = Get.find<DeliveryPointRepository>();
      final newDp = DeliveryPointModel(
        id: IdGenerator.generate(),
        tripId: tripId,
        receiverName: receiverName,
        phone: phone ?? '',
        address: address ?? '',
        note: 'Tạo từ hàng hóa',
      );
      await dpRepo.add(newDp);
      finalDpId = newDp.id;
    }

    final cargo = CargoModel(
      id: IdGenerator.generate(),
      tripId: tripId,
      deliveryPointId: finalDpId,
      cargoCode: cargoCode,
      cargoName: cargoName,
      cargoType: cargoType,
      quantity: quantity,
      statusIndex: initialStatus.index,
      note: note,
      createdAt: DateTime.now(),
    );

    await _cargoRepo.add(cargo);

    // Log timeline
    await _logTimeline(cargo.id, tripId, TimelineAction.created);
    if (initialStatus == CargoStatus.loaded) {
      await _logTimeline(cargo.id, tripId, TimelineAction.loaded);
    }

    loadCargos();
    _refreshDashboard();
    _refreshTripController();
    Get.back();
    Get.snackbar('Thành công', 'Đã thêm kiện #$cargoCode');
  }

  /// Cập nhật hàng hóa
  Future<void> updateCargo(
    String id, {
    required String cargoCode,
    required String cargoName,
    String cargoType = '',
    int quantity = 1,
    String? deliveryPointId,
    String? receiverName,
    String? phone,
    String? address,
    String note = '',
    required CargoStatus status,
  }) async {
    final cargo = _cargoRepo.getById(id);
    if (cargo == null) return;

    String finalDpId = deliveryPointId ?? '';

    // If no ID but has info, create new DP for this trip
    if (finalDpId.isEmpty && receiverName != null && receiverName.isNotEmpty) {
      final dpRepo = Get.find<DeliveryPointRepository>();
      final newDp = DeliveryPointModel(
        id: IdGenerator.generate(),
        tripId: cargo.tripId,
        receiverName: receiverName,
        phone: phone ?? '',
        address: address ?? '',
        note: 'Tạo từ hàng hóa (Sửa)',
      );
      await dpRepo.add(newDp);
      finalDpId = newDp.id;
    }

    cargo.cargoCode = cargoCode;
    cargo.cargoName = cargoName;
    cargo.cargoType = cargoType;
    cargo.quantity = quantity;
    cargo.deliveryPointId = finalDpId;
    cargo.note = note;
    cargo.status = status;

    await _cargoRepo.update(cargo);
    await _logTimeline(id, cargo.tripId, TimelineAction.updated);

    loadCargos();
    _refreshDashboard();
    _refreshTripController();
    Get.back();
    Get.snackbar('Thành công', 'Đã cập nhật kiện #$cargoName');
  }

  /// Cập nhật trạng thái hàng hóa
  Future<void> updateCargoStatus(String cargoId, CargoStatus newStatus) async {
    final cargo = _cargoRepo.getById(cargoId);
    if (cargo == null) return;

    cargo.status = newStatus;
    await _cargoRepo.update(cargo);

    // Determine timeline action
    TimelineAction? action;
    switch (newStatus) {
      case CargoStatus.loaded:
        action = TimelineAction.loaded;
        break;
      case CargoStatus.delivered:
        action = TimelineAction.delivered;
        break;
      case CargoStatus.failed:
        action = TimelineAction.failed;
        break;
      case CargoStatus.returned:
        action = TimelineAction.returned;
        break;
      default:
        break;
    }

    if (action != null) {
      await _logTimeline(cargoId, cargo.tripId, action);
    }

    loadCargos();
    _refreshDashboard();
    _refreshTimeline();
    _refreshTripController();
  }

  /// Xóa hàng
  Future<void> deleteCargo(String cargoId) async {
    await _cargoRepo.delete(cargoId);
    loadCargos();
    _refreshDashboard();
    _refreshTripController();
  }

  /// Lấy hàng còn trên xe gom theo điểm giao
  Map<String, List<CargoModel>> getOnTruckGroupedByDeliveryPoint() {
    final onTruck = _cargoRepo.getOnTruck();
    final grouped = <String, List<CargoModel>>{};

    for (final cargo in onTruck) {
      final key = cargo.deliveryPointId.isEmpty
          ? 'unknown'
          : cargo.deliveryPointId;
      grouped.putIfAbsent(key, () => []).add(cargo);
    }

    return grouped;
  }

  /// Log timeline tự động
  Future<void> _logTimeline(
    String cargoId,
    String tripId,
    TimelineAction action,
  ) async {
    final entry = TimelineModel(
      id: IdGenerator.generate(),
      cargoId: cargoId,
      tripId: tripId,
      actionIndex: action.index,
      createdAt: DateTime.now(),
    );
    await _timelineRepo.add(entry);
    _refreshTimeline();
  }

  void _refreshDashboard() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().refreshData();
    }
  }

  void _refreshTimeline() {
    try {
      final ctrl = Get.find<TimelineController>();
      ctrl.loadTimeline();
    } catch (_) {}
  }

  void _refreshTripController() {
    if (Get.isRegistered<TripController>()) {
      Get.find<TripController>().refreshData();
    }
  }
}
