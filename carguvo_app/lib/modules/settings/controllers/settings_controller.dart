import 'package:get/get.dart';
import 'package:carguvo/data/local/hive_service.dart';
import 'package:carguvo/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:carguvo/modules/trips/controllers/trip_controller.dart';
import 'package:carguvo/modules/cargo/controllers/cargo_controller.dart';
import 'package:carguvo/modules/delivery_points/controllers/delivery_point_controller.dart';
import 'package:carguvo/modules/timeline/controllers/timeline_controller.dart';

class SettingsController extends GetxController {
  Future<void> clearData() async {
    await HiveService.clearAll();

    // Reset all controllers
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().refreshData();
    }
    if (Get.isRegistered<TripController>()) {
      Get.find<TripController>().loadTrips();
    }
    if (Get.isRegistered<CargoController>()) {
      Get.find<CargoController>().loadCargos();
    }
    if (Get.isRegistered<DeliveryPointController>()) {
      Get.find<DeliveryPointController>().loadDeliveryPoints();
    }
    if (Get.isRegistered<TimelineController>()) {
      Get.find<TimelineController>().loadTimeline();
    }

    Get.snackbar('Đã xóa', 'Toàn bộ dữ liệu ứng dụng đã được xóa sạch');
  }
}
