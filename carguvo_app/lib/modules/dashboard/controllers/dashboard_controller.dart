import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:carguvo/data/models/trip_model.dart';
import 'package:carguvo/data/repositories/trip_repository.dart';
import 'package:carguvo/data/repositories/cargo_repository.dart';
import 'package:carguvo/data/repositories/delivery_point_repository.dart';

class DashboardController extends GetxController {
  final _tripRepo = Get.find<TripRepository>();
  final _cargoRepo = Get.find<CargoRepository>();
  final _deliveryRepo = Get.find<DeliveryPointRepository>();

  // Reactive stats
  final totalTrips = 0.obs;
  final cargoOnTruck = 0.obs;
  final totalDelivered = 0.obs;
  final remainingPoints = 0.obs;
  final recentTrips = <TripModel>[].obs;

  @override
  void onInit() {
    debugPrint('DEBUG: DashboardController.onInit starting');
    super.onInit();
    refreshData();
    debugPrint('DEBUG: DashboardController.onInit finished');
  }

  void refreshData() {
    debugPrint('DEBUG: DashboardController.refreshData starting');
    try {
      totalTrips.value = _tripRepo.totalCount;
      cargoOnTruck.value = _cargoRepo.totalOnTruck;
      totalDelivered.value = _cargoRepo.totalDelivered;
      remainingPoints.value = _deliveryRepo.totalPending;

      final allTrips = _tripRepo.getAll();
      recentTrips.value = allTrips.take(5).toList();
      debugPrint('DEBUG: DashboardController.refreshData success');
    } catch (e) {
      debugPrint('DEBUG: DashboardController.refreshData error: $e');
    }
  }
}
