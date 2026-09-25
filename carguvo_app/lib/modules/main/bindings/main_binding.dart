import 'package:get/get.dart';
import 'package:carguvo/modules/main/controllers/main_controller.dart';
import 'package:carguvo/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:carguvo/modules/trips/controllers/trip_controller.dart';
import 'package:carguvo/modules/cargo/controllers/cargo_controller.dart';
import 'package:carguvo/modules/delivery_points/controllers/delivery_point_controller.dart';
import 'package:carguvo/modules/timeline/controllers/timeline_controller.dart';
import 'package:carguvo/modules/settings/controllers/settings_controller.dart';
import 'package:carguvo/data/repositories/trip_repository.dart';
import 'package:carguvo/data/repositories/cargo_repository.dart';
import 'package:carguvo/data/repositories/delivery_point_repository.dart';
import 'package:carguvo/data/repositories/timeline_repository.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<TripRepository>(() => TripRepository(), fenix: true);
    Get.lazyPut<CargoRepository>(() => CargoRepository(), fenix: true);
    Get.lazyPut<DeliveryPointRepository>(
      () => DeliveryPointRepository(),
      fenix: true,
    );
    Get.lazyPut<TimelineRepository>(() => TimelineRepository(), fenix: true);

    // Controllers
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<TripController>(() => TripController(), fenix: true);
    Get.lazyPut<CargoController>(() => CargoController(), fenix: true);
    Get.lazyPut<DeliveryPointController>(
      () => DeliveryPointController(),
      fenix: true,
    );
    Get.lazyPut<TimelineController>(() => TimelineController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
  }
}
