import 'package:get/get.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/core/utils/id_generator.dart';
import 'package:carguvo/data/models/delivery_point_model.dart';
import 'package:carguvo/data/repositories/delivery_point_repository.dart';
import 'package:carguvo/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:carguvo/modules/trips/controllers/trip_controller.dart';

class DeliveryPointController extends GetxController {
  final _deliveryRepo = Get.find<DeliveryPointRepository>();

  final deliveryPoints = <DeliveryPointModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDeliveryPoints();
  }

  void loadDeliveryPoints() {
    deliveryPoints.value = _deliveryRepo.getAll();
  }

  Future<void> addDeliveryPoint({
    required String tripId,
    required String receiverName,
    String phone = '',
    String address = '',
    String note = '',
  }) async {
    final point = DeliveryPointModel(
      id: IdGenerator.generate(),
      tripId: tripId,
      receiverName: receiverName,
      phone: phone,
      address: address,
      note: note,
      statusIndex: DeliveryStatus.pending.index,
    );

    await _deliveryRepo.add(point);
    loadDeliveryPoints();
    _refreshDashboard();
    _refreshTripController();
    Get.back();
    Get.snackbar('Thành công', 'Đã thêm điểm giao: $receiverName');
  }

  Future<void> updateDeliveryPoint(
    String id, {
    required String receiverName,
    String phone = '',
    String address = '',
    String note = '',
    required DeliveryStatus status,
  }) async {
    final point = _deliveryRepo.getById(id);
    if (point != null) {
      point.receiverName = receiverName;
      point.phone = phone;
      point.address = address;
      point.note = note;
      point.status = status;
      await _deliveryRepo.update(point);
      loadDeliveryPoints();
      _refreshDashboard();
      _refreshTripController();
      Get.back();
      Get.snackbar('Thành công', 'Đã cập nhật điểm giao: $receiverName');
    }
  }

  Future<void> deleteDeliveryPoint(String id) async {
    await _deliveryRepo.delete(id);
    loadDeliveryPoints();
    _refreshDashboard();
    _refreshTripController();
  }

  Future<void> updateStatus(String id, DeliveryStatus status) async {
    final point = _deliveryRepo.getById(id);
    if (point != null) {
      point.status = status;
      await _deliveryRepo.update(point);
      loadDeliveryPoints();
      _refreshDashboard();
      _refreshTripController();
    }
  }

  void _refreshDashboard() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().refreshData();
    }
  }

  void _refreshTripController() {
    if (Get.isRegistered<TripController>()) {
      Get.find<TripController>().refreshData();
    }
  }
}
